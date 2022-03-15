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
        _selectButton.showCount = [MGImagePickerHandler shareIntance].option.isMultiPage;
        _selectButton.hidden = [MGImagePickerHandler shareIntance].option.needCrop;
     
    }
    return _selectButton;
}
#pragma mark - setter
- (void)setImageAsset:(MGAssetModel *)imageAsset{
    _imageAsset = imageAsset;
    _selectButton.selected = imageAsset.selected;
    _selectButton.count = imageAsset.selectedIndex;
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

@property(nonatomic,strong)NSArray * dataArray;
//已选择图片数
@property(nonatomic,assign,readonly)NSInteger selectedCount;
@end

@implementation MGAlbumViewController
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
    __weak typeof(self) weakSelf = self;
    self.bottomView.imageOperateViewSendActionBlock = ^(UIButton *sender) {
        
        MGImagePickerViewController * picker = ((MGImagePickerViewController *)weakSelf.navigationController);
        if ([picker.pickerDelegate respondsToSelector:@selector(controller:didSelectedImageArrayWithThumbnailImageArray:withAssetArray:)]) {
            NSMutableArray * mutArr = @[].mutableCopy;
            NSMutableArray * mutArr2 = @[].mutableCopy;
            for (MGAssetModel * model in weakSelf.selectedAssetModelArray) {
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
        vc3.assetModelArray = weakSelf.dataArray;
        vc3.selectedAssetArray = weakSelf.selectedAssetModelArray;
        MGAssetModel * model = weakSelf.selectedAssetModelArray.firstObject;
        vc3.displayIndexPath = [NSIndexPath indexPathForItem:model.index inSection:0];
        [weakSelf.navigationController pushViewController:vc3 animated:YES];
    };
}
- (void)loadAllImageData{
    [MGImagePickerHandler getAllAssets:^(NSArray<MGAssetModel *> *array) {
        self.dataArray = array;
         self.title = MGLocalString(@"CWIPStr_Title_allImage");
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
    MGAlbumViewCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
    cell.delegate = self;//记得先后顺序，先设置代理，在设置数据
    cell.imageAsset = self.dataArray[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if ([MGImagePickerHandler shareIntance].option.needCrop) {//需要裁剪
        [MGImagePickerHandler originImageWithAsset:self.dataArray[indexPath.row] completion:^(UIImage *image,NSDictionary *info) {
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
        vc3.assetModelArray = self.dataArray;
        vc3.selectedAssetArray = self.selectedAssetModelArray;
        vc3.displayIndexPath = indexPath;
        [self.navigationController pushViewController:vc3 animated:YES];
        
    }
 
}

#pragma mark - setter
- (void)setAlbumModel:(MGAlbumModel *)albumModel{
    _albumModel = albumModel;
    self.title = albumModel.assetCollection.localizedTitle;
    _dataArray = [MGImagePickerHandler assetsWithAlbum:albumModel];
    
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

- (NSInteger)selectedCount{
    return self.selectedAssetModelArray.count;
}
#pragma mark - MGAlbumViewCollectionViewCellDelegate
- (void)didSelectedImageWithAssetModel:(MGAssetModel *)assetModel sender:(UIButton *)sender{
    if (self.selectedAssetModelArray.count >= [MGImagePickerHandler shareIntance].option.maxAllowCount && sender.selected) {
        NSString * str = [NSString stringWithFormat:MGLocalString(@"CWIPStr_Alert_maxSelectCount"), [MGImagePickerHandler shareIntance].option.maxAllowCount];
        sender.selected = NO;
        [self alertViewWithTitle:str];
        return;
    }
    BOOL selected = sender.selected;
    assetModel.selected = selected;//将数据的selected置为yes
    if ([MGImagePickerHandler shareIntance].option.isMultiPage) {//如果有裁剪，不会跑到这里来
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
                for (MGAssetModel * model in self.selectedAssetModelArray) {
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
    for (MGAssetModel * cw_asset in self.selectedAssetModelArray) {
        cw_asset.selectedIndex = i+1;
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:cw_asset.index inSection:0];
        [indexPaths addObject:indexPath];
        i++;
    }
    [self.collectionView reloadItemsAtIndexPaths:indexPaths];
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
