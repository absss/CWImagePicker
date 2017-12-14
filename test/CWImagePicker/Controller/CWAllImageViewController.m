//
//  CWAllImageViewController.m
//  test
//
//  Created by hehaichi on 2017/11/28.
//  Copyright © 2017年 app. All rights reserved.
//

#import "CWAllImageViewController.h"
#import "CWImageScanCollectionViewController.h"
#import "CWImageManager.h"
#import "CWImagePickerViewController.h"
#import "CWIPImageOperateView.h"
#import "CWCropImageViewController.h"

@interface CWIPAllImageViewCollectionViewCell()
@property(nonatomic,strong)UIImageView * imageView;
@property(nonatomic,strong)CWIPShowCountButton * selectButton;
@end
@implementation CWIPAllImageViewCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.selectButton];
        spweakify(self);
        self.selectButton.showCountButtonActionBlock = ^(CWIPShowCountButton *sender) {
            spstrongify(self);
            [self selectAction:sender];
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

- (CWIPShowCountButton *)selectButton{
    if (!_selectButton) {
        _selectButton = [[CWIPShowCountButton alloc]initWithFrame:CGRectMake(CGRectGetMaxY(self.contentView.frame)-kCWIPThumbnailSelectdButtonLength, 0, kCWIPThumbnailSelectdButtonLength, kCWIPThumbnailSelectdButtonLength)];
        _selectButton.enableShowCount = [CWImageManager shareIntance].option.isMultiPage;
        _selectButton.hidden = [CWImageManager shareIntance].option.needCrop;
     
    }
    return _selectButton;
}
#pragma mark - setter
- (void)setImageAsset:(CWIPAssetModel *)imageAsset{
    _imageAsset = imageAsset;
    _selectButton.selected = imageAsset.selected;
    _selectButton.count = imageAsset.selectedIndex;
    UIImage * image = [[CWImageManager shareIntance].cache objectForKey:imageAsset.asset.localIdentifier];
    if (image) {
        _imageView.image = image;
    }else{
        //缓存图片
        [CWImageManager thumbnailImageWithAsset:imageAsset withImageSize:_imageView.frame.size withCompleteBlock:^(UIImage *image,NSDictionary *info) {
            _imageView.image = image;
            [[CWImageManager shareIntance].cache setObject:image forKey:imageAsset.asset.localIdentifier];
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

@interface CWAllImageViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,CWIPAllImageViewCollectionViewCellDelegate,CWCropImageViewControllerDelegate>
@property(nonatomic,strong)UICollectionView * collectionView;
@property(nonatomic,strong)CWIPImageOperateView * bottomView;

@property(nonatomic,strong)NSArray * dataArray;
//已选择图片数
@property(nonatomic,assign,readonly)NSInteger selectedCount;
@end

@implementation CWAllImageViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        _selectedAssetModelArray = @[].mutableCopy;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    
    [self.view addSubview:self.bottomView];
    [self setupBlock];
    
}

- (void)setupBlock{
   spweakify(self);
    self.bottomView.imageOperateViewSendActionBlock = ^(UIButton *sender) {
        spstrongify(self);
        CWImagePickerViewController * picker = ((CWImagePickerViewController *)self.navigationController);
        if ([picker.cwDelegate respondsToSelector:@selector(didSelectedImageArrayWithThumbnailImageArray:withAssetArray:)]) {
            NSMutableArray * mutArr = @[].mutableCopy;
            NSMutableArray * mutArr2 = @[].mutableCopy;
            for (CWIPAssetModel * model in self.selectedAssetModelArray) {
                UIImage * image = [[CWImageManager shareIntance].cache objectForKey:model.asset.localIdentifier];
                if (image) {
                    [mutArr addObject:image];
                    [mutArr2 addObject:model];
                }
            }
            [picker.cwDelegate didSelectedImageArrayWithThumbnailImageArray:mutArr withAssetArray:mutArr2];
        }
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];  
    };
    self.bottomView.imageOperateViewScanActionBlock = ^(UIButton *sender) {
        spstrongify(self);
        CWImageScanCollectionViewController * vc3 = [[CWImageScanCollectionViewController alloc]init];
        vc3.assetModelArray = self.dataArray;
        vc3.selectedAssetArray = self.selectedAssetModelArray;
        CWIPAssetModel * model = self.selectedAssetModelArray.firstObject;
        vc3.displayIndexPath = [NSIndexPath indexPathForItem:model.index inSection:0];
        [self.navigationController pushViewController:vc3 animated:YES];
    };
}
- (void)loadAllImageData{
    [CWImageManager getAllAssetsAndThumbnailImagesArray:^(NSArray<CWIPAssetModel *> *array) {
        self.dataArray = array;
         self.title = CWIPlocalString(@"CWIPStr_Title_allImage");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - UICollectionViewDataSource,UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CWIPAllImageViewCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
    cell.delegate = self;//记得先后顺序，先设置代理，在设置数据
    cell.imageAsset = self.dataArray[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if ([CWImageManager shareIntance].option.needCrop) {//需要裁剪
        [CWImageManager originImageWithAsset:self.dataArray[indexPath.row] withCompleteBlock:^(UIImage *image,NSDictionary *info) {
            if ([info[PHImageResultIsDegradedKey] isEqual:@0]) {//高清图
                CGFloat w = [CWImageManager shareIntance].option.cropFrameSize.width;
                CGFloat h = [CWImageManager shareIntance].option.cropFrameSize.height;
                CWCropImageViewController * cropVc = [[CWCropImageViewController alloc]initWithImage:image cropFrame:CGRectMake(CWIPScreenWidth/2-w/2, CWIPScreenHeight/2-h/2, w, h) limitScaleRatio:[CWImageManager shareIntance].option.allowMaxZoomScale];
                cropVc.delegate = self;
                if (![self.navigationController.visibleViewController isKindOfClass:NSClassFromString(@"CWCropImageViewController")]) {
                    [self.navigationController pushViewController:cropVc animated:YES];
                }

            }
        }];
        
    }else{
        CWImageScanCollectionViewController * vc3 = [[CWImageScanCollectionViewController alloc]init];
        vc3.assetModelArray = self.dataArray;
        vc3.selectedAssetArray = self.selectedAssetModelArray;
        vc3.displayIndexPath = indexPath;
        [self.navigationController pushViewController:vc3 animated:YES];
        
    }
 
}

#pragma mark - setter
- (void)setAlbumModel:(CWAlbumModel *)albumModel{
    _albumModel = albumModel;
    self.title = albumModel.assetCollection.localizedTitle;
    _dataArray = [CWImageManager assetsWithAlbumCollection:albumModel];
    
}
#pragma mark - getter
static NSString * reuseId = @"CWIPAllImageViewCollectionViewCell";
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.minimumLineSpacing = kCWIPThumbnailEdge;
        flowLayout.minimumInteritemSpacing = kCWIPThumbnailEdge;
        CGFloat itemLength = (CGRectGetWidth(self.view.frame)-kCWIPThumbnailNumberOfRow*(kCWIPThumbnailEdge+1))/kCWIPThumbnailNumberOfRow;
        flowLayout.itemSize = CGSizeMake(itemLength, itemLength);
        
        _collectionView = [[UICollectionView alloc]initWithFrame: CGRectMake(kCWIPThumbnailEdge, 0, CGRectGetWidth(self.view.frame)-2*kCWIPThumbnailEdge+1, CGRectGetHeight(self.view.frame)-CGRectGetHeight(self.bottomView.frame)-2) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[CWIPAllImageViewCollectionViewCell class] forCellWithReuseIdentifier:reuseId];
        
    }
    return _collectionView;
}

- (CWIPImageOperateView *)bottomView{
    if (!_bottomView) {
        if (![CWImageManager shareIntance].option.needCrop) {
            _bottomView = [[CWIPImageOperateView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame)-50, CGRectGetWidth(self.view.frame), 50)];
            _bottomView.backgroundColor = CWIPDarkColor;
        }else{
            _bottomView = nil;
        }
    }
    return _bottomView;
}

- (NSInteger)selectedCount{
    return self.selectedAssetModelArray.count;
}
#pragma mark - CWIPAllImageViewCollectionViewCellDelegate
- (void)didSelectedImageWithAssetModel:(CWIPAssetModel *)assetModel sender:(UIButton *)sender{
    if (self.selectedAssetModelArray.count >= [CWImageManager shareIntance].option.maxAllowCount && sender.selected) {
        NSString * str = [NSString stringWithFormat:CWIPlocalString(@"CWIPStr_Alert_maxSelectCount"), [CWImageManager shareIntance].option.maxAllowCount];
        sender.selected = NO;
        [self alertViewWithTitle:str];
        return;
    }
    BOOL selected = sender.selected;
    assetModel.selected = selected;//将数据的selected置为yes
    if ([CWImageManager shareIntance].option.isMultiPage) {//如果有裁剪，不会跑到这里来
        if (selected) {//选中某张图
            if (![self.selectedAssetModelArray containsObject:assetModel]) {
                [self.selectedAssetModelArray addObject:assetModel];
            }
        }else{//取消选中某张图
            if ([self.selectedAssetModelArray containsObject:assetModel]) {
                [self.selectedAssetModelArray removeObject:assetModel];
            }
        }
    }else{
        if (selected) {//选中某张图
            if (![self.selectedAssetModelArray containsObject:assetModel]) {
                for (CWIPAssetModel * model in self.selectedAssetModelArray) {
                    model.selected = NO;//其他未选中的数据的selected都置为no//数组中其实只有一个数据，所以for循环其实跑的很快
                }
                [self refreshSelectedCount];
                [self.selectedAssetModelArray removeAllObjects];
                [self.selectedAssetModelArray addObject:assetModel];
            }
        }else{//取消选中某张图
            if ([self.selectedAssetModelArray containsObject:assetModel]) {
                [self.selectedAssetModelArray removeObject:assetModel];
            }
        }
    }
    [self refreshSelectedCount];

}

#pragma mark - private method
- (void)refreshCollectionView{
    [self.collectionView reloadData];
}
- (void)refreshSelectedCount{
    self.bottomView.selectedCount = self.selectedCount;
    NSMutableArray * indexPaths = @[].mutableCopy;
//    NSLog(@"selectedAssetModelArray.count:%ld",self.selectedAssetModelArray.count);
    int i = 0;
    for (CWIPAssetModel * cw_asset in self.selectedAssetModelArray) {
        cw_asset.selectedIndex = i+1;
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:cw_asset.index inSection:0];
        [indexPaths addObject:indexPath];
        i++;
    }
    [self.collectionView reloadItemsAtIndexPaths:indexPaths];
}

#pragma mark - CWCropImageViewControllerDelegate
- (void)imageCropper:(CWCropImageViewController *)cropperViewController didFinished:(UIImage *)editedImage{
    CWImagePickerViewController * picker = (CWImagePickerViewController *)self.navigationController;
    if ([picker.cwDelegate respondsToSelector:@selector(didSelectedCropImageWithImage:)]) {
        [picker.cwDelegate didSelectedCropImageWithImage:editedImage];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageCropperDidCancel:(CWCropImageViewController *)cropperViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc{
    NSLog(@"%s",__func__);
}
@end
