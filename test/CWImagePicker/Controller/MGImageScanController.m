//
//  MGImageScanController.m
//  test
//
//  Created by hehaichi on 2017/11/28.
//  Copyright © 2017年 app. All rights reserved.
//

#import "MGImageScanController.h"
#import "MGImageOperateView.h"
#import "MGImagePickerHandler.h"
#import "MGImageMarco.h"
#import "MGImageScanCollectionViewCell.h"
#import "MGCropImageViewController.h"
#import "MGImagePickerViewController.h"
#import "MGAlbumViewController.h"

@interface CWSmallImageCollectionViewCell : UICollectionViewCell
@property(nonatomic,strong)UIImageView * imageView;
@property(nonatomic,strong)MGAssetModel * imageAsset;


@end
@implementation CWSmallImageCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.imageView];
    }
    return self;
}
#pragma mark - setter
- (void)setImageAsset:(MGAssetModel *)imageAsset{
    _imageAsset = imageAsset;
    [MGImagePickerHandler thumbnailImageWithAsset:imageAsset size:self.imageView.frame.size completion:^(UIImage *image,NSDictionary * info) {
        self.imageView.image = image;
    }];
    if (imageAsset.isDisplay) {
        self.contentView.layer.borderColor = MGGreenColor.CGColor;
        self.contentView.layer.borderWidth = 1.5;
    }else{
        self.contentView.layer.borderColor = [UIColor clearColor].CGColor;
        self.contentView.layer.borderWidth = 0.0;
    }
}


- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]initWithFrame: self.contentView.frame];
    }
    return _imageView;
}

@end
@interface MGImageScanController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,MGImageScanCollectionViewCellDelegate,MGCropImageViewControllerDelegate,UINavigationControllerDelegate>
@property(nonatomic,strong)MGImageOperateView * bottomView;
@property(nonatomic,strong)UICollectionView * collectionView;//使用collectionView好处是有复用
@property(nonatomic,strong)UICollectionView * smallCollectionView;
@property(nonatomic,assign)NSInteger currentPage;

@property(nonatomic,assign,getter=isEnlager)BOOL enlarger;
@property(nonatomic,assign,getter=headAndFootIsHidden)BOOL hiddenHeadAndFoot;



@end

@implementation MGImageScanController

static NSString * reuseId = @"MGImageScanCollectionViewCell";
static NSString * reuseId2 = @"CWSmallImageCollectionViewCell";
const static int kSmallImageCollectionViewTag = 99;
const static int kBigImageCollectionViewTag = 999;

- (instancetype)init{
    self = [super init];
    if (self) {
        _enlarger = NO;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.delegate = self;
    [self setupRightNavigationBar];
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.smallCollectionView];
    [self.view addSubview:self.bottomView];
    
    [self setupBlock];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark - setter
- (void)setAssetModelArray:(NSArray<MGAssetModel *> *)assetModelArray{
    _assetModelArray = assetModelArray;
}

- (void)setHiddenHeadAndFoot:(BOOL)hiddenHeadAndFoot{
    _hiddenHeadAndFoot = hiddenHeadAndFoot;
    self.navigationController.navigationBarHidden = hiddenHeadAndFoot;
    self.bottomView.hidden = hiddenHeadAndFoot;
    if (hiddenHeadAndFoot) {
        self.smallCollectionView.hidden = YES;
    } else {
        self.smallCollectionView.hidden = self.selectedAssetArray.count>0? NO: YES;
    }
}


- (void)setDisplayIndexPath:(NSIndexPath *)displayIndexPath{
    _displayIndexPath = displayIndexPath;
    MGAssetModel * selectedModel = self.assetModelArray[displayIndexPath.row];
    selectedModel.displayed = YES;
    for (MGAssetModel * model in self.assetModelArray) {
        if (model.index == displayIndexPath.row) {
            model.displayed = YES;
        }else{
            model.displayed = NO;
        }
    }
    _currentPage = self.displayIndexPath.row;
}


#pragma - mark getter
- (MGImageOperateView *)bottomView{
    if (!_bottomView) {
        CGFloat bottomOffset = MG_IS_IPHONEX ? 34 : 0;
        _bottomView = [[MGImageOperateView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame)-50-bottomOffset, CGRectGetWidth(self.view.frame), 50+bottomOffset)];
        _bottomView.backgroundColor = MGDarkColor;
        _bottomView.scanButton.hidden = YES;
        _bottomView.selectedCount = _selectedAssetArray.count;
    }
    return _bottomView;
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.itemSize = CGSizeMake(MGScreenWidth, MGScreenHeight);
         flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc]initWithFrame: CGRectMake(0, 0, MGScreenWidth,MGScreenHeight) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[MGImageScanCollectionViewCell class] forCellWithReuseIdentifier:reuseId];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.contentSize = CGSizeMake(self.assetModelArray.count*MGScreenWidth, MGScreenHeight);
        _collectionView.alwaysBounceVertical = NO;
        _collectionView.alwaysBounceHorizontal = NO;
        _collectionView.bounces = NO;
        _collectionView.tag = kBigImageCollectionViewTag;
        [_collectionView selectItemAtIndexPath:self.displayIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionRight];
    }
    return _collectionView;
}

- (UICollectionView *)smallCollectionView{
    if (!_smallCollectionView) {
        if ([MGImagePickerHandler shareIntance].option.isMultiPage) {
            UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
            flowLayout.minimumLineSpacing = 10;
            flowLayout.minimumInteritemSpacing = 10;
            flowLayout.itemSize = CGSizeMake(35, 35);
            flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            
            _smallCollectionView = [[UICollectionView alloc]initWithFrame: CGRectMake(0,CGRectGetMaxY(self.view.frame)-CGRectGetHeight(self.bottomView.frame)-50, MGScreenWidth,50) collectionViewLayout:flowLayout];
            _smallCollectionView.backgroundColor = MGDarkColor;
            _smallCollectionView.delegate = self;
            _smallCollectionView.dataSource = self;
            [_smallCollectionView registerClass:[CWSmallImageCollectionViewCell class] forCellWithReuseIdentifier:reuseId2];
            _smallCollectionView.alwaysBounceVertical = NO;
            _smallCollectionView.alwaysBounceHorizontal = NO;
            _smallCollectionView.bounces = NO;
            _smallCollectionView.tag = kSmallImageCollectionViewTag;
            _smallCollectionView.hidden  = !(self.selectedAssetArray.count>0);
        }else{
            _smallCollectionView = nil;
        }
        
        
    }
    return _smallCollectionView;
}

#pragma mark - private method
- (void)refreshSelectedCount{
    _bottomView.selectedCount = self.selectedAssetArray.count;
    if (self.selectedAssetArray.count < 1) {
        self.smallCollectionView.hidden = YES;
    }else{
        self.smallCollectionView.hidden = NO;
    }
    NSMutableArray * indexPaths = @[].mutableCopy;
    int i = 0;
    for (MGAssetModel * assetModel in self.selectedAssetArray) {
        assetModel.selectedIndex = i+1;
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:assetModel.index inSection:0];
        [indexPaths addObject:indexPath];
        i++;
    }
    [self.collectionView reloadItemsAtIndexPaths:indexPaths];
    [self refreshRightNavItemWithIdx:self.assetModelArray[self.displayIndexPath.row].index];

}

- (void)setupBlock{
    __weak typeof(self) weakSelf = self;
    self.bottomView.imageOperateViewSendActionBlock = ^(UIButton *sender) {
        
        MGImagePickerViewController * picker = ((MGImagePickerViewController *)weakSelf.navigationController);
        if ([picker.pickerDelegate respondsToSelector:@selector(controller: didSelectedImageArrayWithThumbnailImageArray:withAssetArray:)]) {
            NSMutableArray * mutArr = @[].mutableCopy;
            NSMutableArray * mutArr2 =@[].mutableCopy;
            for (MGAssetModel * model in weakSelf.selectedAssetArray) {
                UIImage * image = [[MGImagePickerHandler shareIntance].cache objectForKey:model.asset.localIdentifier];
                if (image) {
                    [mutArr addObject:image];
                    [mutArr2 addObject:model];
                }
            }
            [picker.pickerDelegate controller:weakSelf didSelectedImageArrayWithThumbnailImageArray:mutArr withAssetArray:mutArr2];
        }
        [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
        
    };
}

- (void)setupRightNavigationBar{
    MGImageSelectButton * button = [[MGImageSelectButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    button.showCount = [MGImagePickerHandler shareIntance].option.isMultiPage;
    button.count = 1;
    __weak typeof(self) weakSelf = self;
    button.showCountButtonActionBlock = ^(MGImageSelectButton *sender) {
        [weakSelf selectAction:sender];
    };
    UIBarButtonItem * item = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = item;
}


#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView.tag == kBigImageCollectionViewTag) {//大图
        return self.assetModelArray.count;
    }else{//小图
        return self.selectedAssetArray.count;
    }
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView.tag == kBigImageCollectionViewTag) {
        MGImageScanCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
        cell.delegate = self;
        return cell;
    }else{
        CWSmallImageCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId2 forIndexPath:indexPath];
        cell.imageAsset = self.selectedAssetArray[indexPath.row];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0){
    if(collectionView.tag == kBigImageCollectionViewTag){
         ((MGImageScanCollectionViewCell *)cell).imageAsset = self.assetModelArray[indexPath.row];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if (collectionView.tag == kSmallImageCollectionViewTag) {
        self.displayIndexPath = indexPath;
        MGAssetModel * model = self.selectedAssetArray[indexPath.row];
        for (int i = 0; i < self.selectedAssetArray.count; i++) {
            if (i == indexPath.row) {
                model.displayed = YES;
            }else{
                model.displayed = NO;
            }
        }
        self.collectionView.contentOffset = CGPointMake(CGRectGetWidth(self.view.frame)*model.index, 0);
        [self.smallCollectionView reloadData];
        [self refreshRightNavItemWithIdx:model.index];
       
    }
}

- (void)refreshRightNavItemWithIdx:(NSInteger )idx{
    MGImageSelectButton * button = (MGImageSelectButton*)self.navigationItem.rightBarButtonItem.customView;
    MGAssetModel * model = self.assetModelArray[idx];
    button.selected = model.selected;
    button.count = model.selectedIndex;
     [button setNeedsLayout];
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_collectionView.tag == kBigImageCollectionViewTag) {//大collection
        NSInteger idx = scrollView.contentOffset.x/CGRectGetWidth(self.view.frame);
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        self.displayIndexPath = indexPath;
//        NSLog(@"当期页:%@,",indexPath);
        MGAssetModel * model = self.assetModelArray[idx];
        [self refreshRightNavItemWithIdx:idx];
        if (model.displayed) {
            [self.smallCollectionView reloadData];
        }
    }
}



#pragma mark - MGImageScanCollectionViewCellDelegate
- (BOOL)didSingleTapImageView{
    self.hiddenHeadAndFoot = !self.headAndFootIsHidden;
    return YES;
}


- (BOOL)didDoubleTapImageView{
    
     self.enlarger = !self.isEnlager;
    return self.enlarger;
}

#pragma mark - MGCropImageViewControllerDelegate
- (void)imageCropper:(MGCropImageViewController *)cropperViewController didFinished:(UIImage *)editedImage{
     [cropperViewController.navigationController popViewControllerAnimated:YES];
}

- (void)imageCropperDidCancel:(MGCropImageViewController *)cropperViewController{
    [cropperViewController.navigationController popViewControllerAnimated:YES];
}


#pragma mark - target selector
- (void)selectAction:(UIButton *)sender{
   
    if (self.selectedAssetArray.count >= [MGImagePickerHandler shareIntance].option.maxAllowCount &&  sender.selected) {
        NSString * str = [NSString stringWithFormat:MGLocalString(@"CWIPStr_Alert_maxSelectCount"), [MGImagePickerHandler shareIntance].option.maxAllowCount];
        [self alertViewWithTitle:str];
        sender.selected = NO;
        return;
    }
    
    MGAssetModel * model = self.assetModelArray[self.displayIndexPath.row];
    if ([MGImagePickerHandler shareIntance].option.isMultiPage) {
        if (sender.selected) {
            model.selected = YES;
            if (![self.selectedAssetArray containsObject:model]) {
                [self.selectedAssetArray addObject:model];
            }
        }else{
            model.selected = NO;
            if ([self.selectedAssetArray containsObject:model]) {
                [self.selectedAssetArray removeObject:model];
            }
        }
        [self.smallCollectionView reloadData];
        
    }else{
        if (sender.selected) {
            model.selected = YES;
            for (MGAssetModel * model in self.selectedAssetArray) {
                model.selected = NO;
            }
            [self refreshSelectedCount];
            [self.selectedAssetArray removeAllObjects];
            [self.selectedAssetArray addObject:model];
        }else{
            model.selected = NO;
            [self.selectedAssetArray removeObject:model];
        }
        
    }
  
    [self refreshSelectedCount];
}

- (void)dealloc{
    NSLog(@"%s",__func__);
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if ([viewController isKindOfClass:NSClassFromString(@"MGAlbumViewController")]) {
        [((MGAlbumViewController *)viewController) refreshCollectionView];
    }
}

@end
