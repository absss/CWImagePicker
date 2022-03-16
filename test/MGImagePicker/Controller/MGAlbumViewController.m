//
//  MGAlbumViewController.m
//  test
//
//  Created by hehaichi on 2017/11/28.
//  Copyright © 2017年 app. All rights reserved.
//

#import "MGAlbumViewController.h"
#import "MGImageScanController.h"
#import "MGImagePickerHandler.h"
#import "MGImagePickerViewController.h"
#import "MGImageOperateView.h"
#import "MGCropImageViewController.h"
#import "MGAlbumCategoryView.h"


@interface MGAlbumViewCollectionViewCell()
@property(nonatomic,strong) UIImageView * imageView;
@property(nonatomic,strong) UILabel * numberLabel;
@property(nonatomic,strong) MGImageSelectButton * selectButton;
@end
@implementation MGAlbumViewCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.numberLabel];
        [self.contentView addSubview:self.selectButton];
        __weak typeof(self) weakSelf = self;
        self.selectButton.showCountButtonActionBlock = ^(MGImageSelectButton *sender) {
            [weakSelf selectAction:sender];
        };
        
    }
    return self;
}



#pragma mark - getter
- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]initWithFrame:self.contentView.frame];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (MGImageSelectButton *)selectButton{
    if (!_selectButton) {
        _selectButton = [[MGImageSelectButton alloc]initWithFrame:CGRectMake(CGRectGetMaxY(self.contentView.frame)-kMGThumbnailSelectdButtonLength, 0, kMGThumbnailSelectdButtonLength, kMGThumbnailSelectdButtonLength)];
        _selectButton.showCount = MGImagePickerHandler.shareIntance.option.isMultiPage;
        _selectButton.hidden = [MGImagePickerHandler shareIntance].option.needCrop;
     
    }
    return _selectButton;
}

- (UILabel *)numberLabel {
    if (!_numberLabel) {
        _numberLabel = [[UILabel alloc]init];
        _numberLabel.frame = CGRectMake(10, 0, kMGThumbnailSelectdButtonLength, kMGThumbnailSelectdButtonLength);
        _numberLabel.textColor = UIColor.redColor;
    }
    return _numberLabel;
}
#pragma mark - setter
- (void)setImageAsset:(MGAssetModel *)imageAsset{
    _imageAsset = imageAsset;
    _selectButton.selected = imageAsset.selected;
    if (imageAsset.selectedIndex > 0 &&  imageAsset.selected) {
        _numberLabel.hidden = YES;
//        _numberLabel.text = [NSString stringWithFormat:@"%ld",imageAsset.selectedIndex];
        _selectButton.count = imageAsset.selectedIndex;
    } else {
        _numberLabel.hidden = YES;
        _numberLabel.text = @"";
        _selectButton.count = 0;
    }
    UIImage * image = [[MGImagePickerHandler shareIntance].cache objectForKey:imageAsset.asset.localIdentifier];
    if (image) {
        _imageView.image = image;
    }else{
        //把所有的缩略图都缓存起来也消耗不了多大内存(实测)，但是理论上会让滑动速度变快，关键是在大图不显示的时候，一定不能让它存在于内存中，一张小图也就几万像素，一张大图几百万像素，差了一万倍
        [MGImagePickerHandler thumbnailImageWithAsset:imageAsset size:_imageView.frame.size completion:^(UIImage *image,NSDictionary *info) {
            _imageView.image = image;
            [[MGImagePickerHandler shareIntance].cache setObject:image forKey:imageAsset.asset.localIdentifier];
        }];
        
    }
    
}

#pragma mark - target selector
- (void)selectAction:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(didSelectedImageWithAssetModel:sender:)]) {
        [self.delegate didSelectedImageWithAssetModel:self.imageAsset sender:sender];  
    }
}

@end

@interface MGAlbumViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,MGAlbumViewCollectionViewCellDelegate,MGCropImageViewControllerDelegate>
@property(nonatomic,strong)UICollectionView * collectionView;
@property(nonatomic,strong)MGImageOperateView * bottomView;
@property(nonatomic,strong)UIButton * titleView;
@property(nonatomic,strong)MGAlbumCategoryView * albumCategoryView;
@property(nonatomic,strong)NSArray * dataArray;
@end

@implementation MGAlbumViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.bottomView];
    [self setupBlock];
    self.navigationItem.titleView = self.titleView;
    [self.view addSubview:self.albumCategoryView];
    [self initData];
}


#pragma mark - private method
- (void)refreshUI{
    self.bottomView.selectedCount = MGImagePickerHandler.shareIntance.currentAlbumModel.selectedAssetModelArray.count;
    [self.collectionView reloadData];
}

- (void)setupBlock{
    __weak typeof(self) weakSelf = self;
    self.bottomView.imageOperateViewSendActionBlock = ^(UIButton *sender) {
        MGImagePickerViewController * picker = ((MGImagePickerViewController *)weakSelf.navigationController);
        if ([picker.pickerDelegate respondsToSelector:@selector(controller:didSelectedImageArrayWithThumbnailImageArray:withAssetArray:)]) {
            NSMutableArray * mutArr = @[].mutableCopy;
            NSMutableArray * mutArr2 = @[].mutableCopy;
            for (MGAssetModel * model in MGImagePickerHandler.shareIntance.currentAlbumModel.selectedAssetModelArray) {
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
    self.bottomView.imageOperateViewScanActionBlock = ^(UIButton *sender) {
        MGImageScanController * vc3 = [[MGImageScanController alloc]init];
        MGAssetModel * model = MGImagePickerHandler.shareIntance.currentAlbumModel.selectedAssetModelArray.firstObject;
        vc3.displayIndexPath = [NSIndexPath indexPathForItem:model.index inSection:0];
        [weakSelf.navigationController pushViewController:vc3 animated:YES];
    };
    
    self.albumCategoryView.didSelectAlbumBlock = ^(MGAlbumModel * _Nonnull model) {
        [weakSelf setCurrentAlbumModel:model];
        [weakSelf showOrDissmissAlbumCategoryView:weakSelf.titleView];
    };
}

- (void)initData {
    [[MGImagePickerHandler shareIntance] loadData];
    NSArray *albumModelArray =  MGImagePickerHandler.shareIntance.albumModelArray;
    [self setCurrentAlbumModel:albumModelArray.firstObject];
    self.albumCategoryView.frame = CGRectMake(0, MG_NAVIGATION_HEIGHT, CGRectGetWidth(self.view.frame), 60*albumModelArray.count);
    [self.albumCategoryView refreshUI];
}

- (void)showOrDissmissAlbumCategoryView:(UIButton *)sender {
    
    if (sender.selected) {
        self.albumCategoryView.transform = CGAffineTransformIdentity;
        [UIView animateWithDuration:0.3 animations:^{
            self.albumCategoryView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -self.albumCategoryView.frame.size.height);
        } completion:^(BOOL finished) {
            self.albumCategoryView.hidden = YES;
        }];
    } else {
        self.albumCategoryView.hidden = NO;
        self.albumCategoryView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -self.albumCategoryView.frame.size.height);
        [UIView animateWithDuration:0.3 animations:^{
            self.albumCategoryView.transform = CGAffineTransformIdentity;
        }];
    }
    sender.selected = !sender.selected;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - UICollectionViewDataSource,UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return MGImagePickerHandler.shareIntance.currentAlbumModel.assetModelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MGAlbumViewCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
    cell.delegate = self;//记得先后顺序，先设置代理，在设置数据
    cell.imageAsset = MGImagePickerHandler.shareIntance.currentAlbumModel.assetModelArray[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if ([MGImagePickerHandler shareIntance].option.needCrop) {//需要裁剪
        [MGImagePickerHandler originImageWithAsset:MGImagePickerHandler.shareIntance.currentAlbumModel.assetModelArray[indexPath.row] completion:^(UIImage *image,NSDictionary *info) {
            if ([info[PHImageResultIsDegradedKey] isEqual:@0]) {//高清图
                CGFloat w = [MGImagePickerHandler shareIntance].option.cropFrameSize.width;
                CGFloat h = [MGImagePickerHandler shareIntance].option.cropFrameSize.height;
                MGCropImageViewController * cropVc = [[MGCropImageViewController alloc]initWithImage:image cropFrame:CGRectMake(MGScreenWidth/2-w/2, MGScreenHeight/2-h/2, w, h) limitScaleRatio:[MGImagePickerHandler shareIntance].option.allowMaxZoomScale];
                cropVc.delegate = self;
                if (![self.navigationController.visibleViewController isKindOfClass:NSClassFromString(@"MGCropImageViewController")]) {
                    [self.navigationController pushViewController:cropVc animated:YES];
                }

            }
        }];
        
    }else{
        MGImageScanController * vc3 = [[MGImageScanController alloc]init];
        vc3.displayIndexPath = indexPath;
        [self.navigationController pushViewController:vc3 animated:YES];   
    }
}

#pragma mark - setter
- (void)setCurrentAlbumModel:(MGAlbumModel *)currentAlbumModel {
    MGImagePickerHandler.shareIntance.currentAlbumModel = currentAlbumModel;
    [currentAlbumModel reSort];
    [self.titleView setTitle:currentAlbumModel.assetCollection.localizedTitle forState:UIControlStateNormal];
    [self.titleView setTitle:currentAlbumModel.assetCollection.localizedTitle forState:UIControlStateSelected];
    [self refreshUI];
}

#pragma mark - getter
static NSString * reuseId = @"MGAlbumViewCollectionViewCell";
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.minimumLineSpacing = kMGThumbnailEdge;
        flowLayout.minimumInteritemSpacing = kMGThumbnailEdge;
        CGFloat itemLength = (CGRectGetWidth(self.view.frame)-kMGThumbnailNumberOfRow*(kMGThumbnailEdge+1))/kMGThumbnailNumberOfRow;
        flowLayout.itemSize = CGSizeMake(itemLength, itemLength);
        
        _collectionView = [[UICollectionView alloc]initWithFrame: CGRectMake(kMGThumbnailEdge, 0, CGRectGetWidth(self.view.frame)-2*kMGThumbnailEdge+1, CGRectGetHeight(self.view.frame)-CGRectGetHeight(self.bottomView.frame)-2) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[MGAlbumViewCollectionViewCell class] forCellWithReuseIdentifier:reuseId];
        
    }
    return _collectionView;
}

- (MGImageOperateView *)bottomView{
    if (!_bottomView) {
        CGFloat bottomOffset = MG_IS_IPHONEX ? 34 : 0;
        if (![MGImagePickerHandler shareIntance].option.needCrop) {
            _bottomView = [[MGImageOperateView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame)-50-bottomOffset, CGRectGetWidth(self.view.frame), 50+bottomOffset)];
            _bottomView.backgroundColor = MGDarkColor;
        }else{
            _bottomView = nil;
        }
    }
    return _bottomView;
}

- (UIButton *)titleView {
    if (!_titleView) {
        _titleView = [UIButton buttonWithType:UIButtonTypeCustom];
        [_titleView addTarget:self action:@selector(showOrDissmissAlbumCategoryView:) forControlEvents:UIControlEventTouchUpInside];
        self.titleView.frame = CGRectMake(0, 0, 100, 30);
    }
    return _titleView;
}


- (MGAlbumCategoryView *)albumCategoryView {
    if (!_albumCategoryView) {
        _albumCategoryView = [[MGAlbumCategoryView alloc]init];
        self.albumCategoryView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -self.albumCategoryView.frame.size.height);
        self.albumCategoryView.hidden = YES;
    }
    return _albumCategoryView;
}

#pragma mark - MGAlbumViewCollectionViewCellDelegate
- (void)didSelectedImageWithAssetModel:(MGAssetModel *)assetModel sender:(UIButton *)sender{
    if (MGImagePickerHandler.shareIntance.currentAlbumModel.selectedAssetModelArray.count >= [MGImagePickerHandler shareIntance].option.maxAllowCount && sender.selected) {
        NSString * str = [NSString stringWithFormat:MGLocalString(@"CWIPStr_Alert_maxSelectCount"), [MGImagePickerHandler shareIntance].option.maxAllowCount];
        sender.selected = NO;
        [self alertViewWithTitle:str];
        return;
    }
    BOOL selected = sender.selected;
    [MGImagePickerHandler.shareIntance selectAssetModel:assetModel albumModel:MGImagePickerHandler.shareIntance.currentAlbumModel selected:selected];
    [self refreshUI];
}


#pragma mark - MGCropImageViewControllerDelegate
- (void)imageCropper:(MGCropImageViewController *)cropperViewController didFinished:(UIImage *)editedImage{
    MGImagePickerViewController * picker = (MGImagePickerViewController *)self.navigationController;
    if ([picker.pickerDelegate respondsToSelector:@selector(controller:didSelectedCropImageWithImage:)]) {
        [picker.pickerDelegate controller:cropperViewController didSelectedCropImageWithImage:editedImage];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageCropperDidCancel:(MGCropImageViewController *)cropperViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc{
    NSLog(@"%s",__func__);
}
@end
