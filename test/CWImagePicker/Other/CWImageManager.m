//
//  CWImageManager.m
//  test
//
//  Created by hehaichi on 2017/11/28.
//  Copyright © 2017年 app. All rights reserved.
//

#import "CWImageManager.h"

#define EKOIPiOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define EKOIPiOS10_2Later ([UIDevice currentDevice].systemVersion.floatValue >= 10.2f)
#define EKOIPiOS10_3Later ([UIDevice currentDevice].systemVersion.floatValue >= 10.3f)
#define EKOIPiOS11Later ([UIDevice currentDevice].systemVersion.floatValue >= 11.0f)

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
    NSMutableArray *albums = [NSMutableArray array];
    
    //获取相机胶卷相册
    NSMutableArray *assetSubtypes = @[
                                      //                        @(PHAssetCollectionSubtypeSmartAlbumUserLibrary),//所有图片
                                      //                        @(PHAssetCollectionSubtypeSmartAlbumSelfPortraits),//自拍 iOS9
                                      //                        @(PHAssetCollectionSubtypeSmartAlbumScreenshots),//屏幕快照 iOS9
                                      //                        @(PHAssetCollectionSubtypeSmartAlbumBursts),//连拍快照
                                      //                        @(PHAssetCollectionSubtypeSmartAlbumPanoramas),//全景照片
                                      //                        @(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded),//最近添加
                                      //                        @(PHAssetCollectionSubtypeSmartAlbumFavorites),//个人收藏
                                      //                        @(PHAssetCollectionSubtypeSmartAlbumDepthEffect),//人像 iOS10.2
                                      //                        @(PHAssetCollectionSubtypeSmartAlbumLivePhotos), //实况图片 iOS 10.3
                                      //                        @(PHAssetCollectionSubtypeSmartAlbumLongExposures),//长曝光 iOS11
                                      //                        @(PHAssetCollectionSubtypeSmartAlbumAnimated),//动图 iOS11
                                      ].mutableCopy;
    
    [assetSubtypes addObject:@(PHAssetCollectionSubtypeSmartAlbumUserLibrary)];
    if (EKOIPiOS9Later) {
        [assetSubtypes addObject:@(PHAssetCollectionSubtypeSmartAlbumSelfPortraits)];
        [assetSubtypes addObject:@(PHAssetCollectionSubtypeSmartAlbumScreenshots)];
    }
    [assetSubtypes addObject:@(PHAssetCollectionSubtypeSmartAlbumBursts)];
    [assetSubtypes addObject:@(PHAssetCollectionSubtypeSmartAlbumPanoramas)];
    [assetSubtypes addObject:@(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded)];
    [assetSubtypes addObject:@(PHAssetCollectionSubtypeSmartAlbumFavorites)];
    if (EKOIPiOS10_2Later) {
        [assetSubtypes addObject:@(PHAssetCollectionSubtypeSmartAlbumDepthEffect)];
    }
    if (EKOIPiOS10_3Later) {
        [assetSubtypes addObject:@(PHAssetCollectionSubtypeSmartAlbumLivePhotos)];
    }
    if (EKOIPiOS11Later) {
        [assetSubtypes addObject:@(PHAssetCollectionSubtypeSmartAlbumLongExposures)];
        [assetSubtypes addObject:@(PHAssetCollectionSubtypeSmartAlbumAnimated)];
    }
    
    for (int i = 0; i < assetSubtypes.count; i++) {
        PHAssetCollectionSubtype type = (PHAssetCollectionSubtype )[assetSubtypes[i] integerValue];
        PHFetchResult<PHAssetCollection *> *cameraRollCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:type options:nil];
        for (PHAssetCollection * album in cameraRollCollections) {
            NSInteger estimatedCount = album.estimatedAssetCount;
            if (estimatedCount>0||estimatedCount == NSNotFound) {
                CWAlbumModel * model = [CWAlbumModel new];
                model.assetCollection = album;
                
                if (album.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                    [albums insertObject:model atIndex:0];
                }else{
                    [albums addObject:model];
                }
            }
        }
    }
    
    //用户自定义的相册
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection * album in assetCollections) {
        NSInteger estimatedCount = album.estimatedAssetCount;
        if (estimatedCount>0||estimatedCount == NSNotFound) {
            CWAlbumModel * cw_album = [CWAlbumModel alloc];
            cw_album.assetCollection = album;
            [albums addObject:cw_album];
        }
    }
    if (completion) {
        completion((NSArray *)albums);
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

+ (void)accessToUsePhotoLibraryWithCompleteBlock:(void(^)(BOOL canUse))block{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            if (block) {
                block(YES);
            }
        }else{
            if (block) {
                block(NO);
            }
        }
    }];
}

+ (void)accessToCameraWithCompleteBlock:(void(^)(BOOL canUse))block{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            if (block) {
                block(YES);
            }
        }else{
            if (block) {
                block(NO);
            }
        }
    }];
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
    CGFloat scale = [UIScreen mainScreen].scale;
    size = CGSizeMake(size.width*scale, size.height*scale);
    
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
