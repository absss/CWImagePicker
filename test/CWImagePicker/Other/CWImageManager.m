//
//  CWImageManager.m
//  test
//
//  Created by hehaichi on 2017/11/28.
//  Copyright © 2017年 app. All rights reserved.
//

#import "CWImageManager.h"

@implementation CWImageManager
+ (instancetype)shareIntance{
    static dispatch_once_t onceToken;
    static CWImageManager * manager = nil;
    dispatch_once(&onceToken, ^{
        
        manager = [[CWImageManager alloc]init];
        CWIPImagePickerOption * option = [[CWIPImagePickerOption alloc]init];
        manager.option = option;
        CWIPCache * cache = [[CWIPCache alloc]init];
        manager.cache = cache;

    });
    return manager;
}

- (void)setOption:(CWIPImagePickerOption *)option{
    if (option) {
        _option = option;
    }
}

+ (void)getAllAlbumArray:(void(^)(NSArray <CWAlbumModel *>*array))completion{
      NSMutableArray * albumArray = @[].mutableCopy;
    //获取相机胶卷相册
    PHFetchResult<PHAssetCollection *> *cameraRollCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection * album in cameraRollCollections) {
        CWAlbumModel * cw_album = [CWAlbumModel new];
        cw_album.assetCollection = album;
        [albumArray addObject:cw_album];
    }
    
    //获取自定义相册
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection * album in assetCollections) {
        CWAlbumModel * cw_album = [CWAlbumModel alloc];
        cw_album.assetCollection = album;
        [albumArray addObject:cw_album];
    }
    if (completion && albumArray.count>0) {
        completion((NSArray *)albumArray);
    }
}

+ (void)getAllAssetsAndThumbnailImagesArray:(void(^)(NSArray <CWIPAssetModel *>*array))assetsBlock{
    // 获得所有的自定义相簿
    NSMutableArray * allAssetArray = @[].mutableCopy;
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    // 获得相机胶卷（系统相簿）
    PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    
    if (cameraRoll) {
         PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:cameraRoll options:nil];
        int i = 0;
        for (PHAsset *asset in assets) {
            CWIPAssetModel * cw_asset = [CWIPAssetModel new];
            cw_asset.index = i;
            cw_asset.asset = asset;
            [allAssetArray addObject:cw_asset];
            i++;
        }
    }
    // 遍历所有的自定义相簿
    for (PHAssetCollection *assetCollection in assetCollections) {
        PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        int i = 0;
        for (PHAsset *asset in assets) {
            CWIPAssetModel * cw_asset = [CWIPAssetModel new];
            cw_asset.asset = asset;
            cw_asset.index = i;
            [allAssetArray addObject:cw_asset];
            i++;
        }
        
    }
    //执行assetsBlock
    if (assetsBlock && allAssetArray.count>0) {
        assetsBlock(allAssetArray);
    }

}

+ (BOOL)isCanUsePhotos {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusRestricted ||
            status == PHAuthorizationStatusDenied) {
            //无权限
            return NO;
        }
    return YES;
}

+ (BOOL)isCanUseCamera {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted||authStatus == AVAuthorizationStatusDenied){
        return  NO;
    }else{
        return YES;
    }
}

+ (BOOL)isSupportPhotosFramework{
    if (NSClassFromString(@"PHAsset")) {
        return YES;
    }
    return NO;
}

+ (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

+ (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

+ (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}



+ (void)thumbnailImageWithAsset:(CWIPAssetModel *)assetModel withImageSize:(CGSize)size withCompleteBlock:(CWGetImageFromAssetResultBlock)completion{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    [[PHImageManager defaultManager] requestImageForAsset:assetModel.asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (completion && result) {
            completion(result,info);
        }
    }];
}

+ (void)originImageWithAsset:(CWIPAssetModel *)assetModel withCompleteBlock:(CWGetImageFromAssetResultBlock)completion{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = YES;//允许异步下载
    CGSize size = CGSizeMake(assetModel.asset.pixelWidth, assetModel.asset.pixelHeight);
    [[PHImageManager defaultManager] requestImageForAsset:assetModel.asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (completion && result) {
            completion(result,info);
        }
    }];
    
    
}

+ (void)originImageWithAsset:(CWIPAssetModel *)assetModel withCompleteBlock:(CWGetImageFromAssetResultBlock)completion withProgressBlock:(CWGetImageFromAssetProgressBlock)progressHandler{
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = YES;//允许异步下载

    CGSize size = CGSizeMake(assetModel.asset.pixelWidth, assetModel.asset.pixelHeight);
    [[PHImageManager defaultManager] requestImageForAsset:assetModel.asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (completion && result) {
            completion(result,info);
        }
    }];
    option.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{//在主线程中执行
            if (progressHandler) {
                progressHandler(progress,error,stop,info);
            }
        });
    };
}

+ (NSArray < CWIPAssetModel *> *)assetsWithAlbumCollection:(CWAlbumModel *)album{
    NSMutableArray * allAssetArray = @[].mutableCopy;
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:album.assetCollection options:nil];
    int i = 0;
    for (PHAsset *asset in assets) {
        CWIPAssetModel * cw_asset = [CWIPAssetModel new];
        cw_asset.asset = asset;
        cw_asset.index = i;
        [allAssetArray addObject:cw_asset];
        i++;
    }
    return allAssetArray.copy;
}

+ (void)clearCache;{
    [[CWImageManager shareIntance].cache removeAllObjects];
    
}


@end
