//
//  MGImagePickerHandler.m
//  test
//
//  Created by hehaichi on 2017/11/28.
//  Copyright © 2017年 app. All rights reserved.
//

#import "MGImagePickerHandler.h"

#define IOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define IOS10_2Later ([UIDevice currentDevice].systemVersion.floatValue >= 10.2f)
#define IOS10_3Later ([UIDevice currentDevice].systemVersion.floatValue >= 10.3f)
#define IOS11Later ([UIDevice currentDevice].systemVersion.floatValue >= 11.0f)

@implementation MGImagePickerHandler
+ (instancetype)shareIntance{
    static dispatch_once_t onceToken;
    static MGImagePickerHandler * manager = nil;
    dispatch_once(&onceToken, ^{
        
        manager = [[MGImagePickerHandler alloc]init];
        MGImagePickerOption * option = [[MGImagePickerOption alloc]init];
        manager.option = option;
        CWIPCache * cache = [[CWIPCache alloc]init];
        manager.cache = cache;

    });
    return manager;
}

- (void)setOption:(MGImagePickerOption *)option{
    if (option) {
        _option = option;
    }
}

+ (void)getAllAlbums:(void(^)(NSArray <MGAlbumModel *>*array))completion{
    
    NSMutableArray *albums = [NSMutableArray array];
    //获取相机胶卷相册
    NSMutableArray *assetSubtypes = @[].mutableCopy;
    [assetSubtypes addObject:@(PHAssetCollectionSubtypeSmartAlbumUserLibrary)];//所有图片
    if (IOS9Later) {
        [assetSubtypes addObject:@(PHAssetCollectionSubtypeSmartAlbumSelfPortraits)];//自拍
        [assetSubtypes addObject:@(PHAssetCollectionSubtypeSmartAlbumScreenshots)];//屏幕快照
    }
    [assetSubtypes addObject:@(PHAssetCollectionSubtypeSmartAlbumBursts)];//连拍快照
    [assetSubtypes addObject:@(PHAssetCollectionSubtypeSmartAlbumPanoramas)];//全景照片
    [assetSubtypes addObject:@(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded)];//最近添加
    [assetSubtypes addObject:@(PHAssetCollectionSubtypeSmartAlbumFavorites)];//个人收藏
    if (IOS10_2Later) {
        [assetSubtypes addObject:@(PHAssetCollectionSubtypeSmartAlbumDepthEffect)];//人像
    }
    if (IOS10_3Later) {
        [assetSubtypes addObject:@(PHAssetCollectionSubtypeSmartAlbumLivePhotos)];//实况图片
    }
    if (IOS11Later) {
        [assetSubtypes addObject:@(PHAssetCollectionSubtypeSmartAlbumLongExposures)];//长曝光
        [assetSubtypes addObject:@(PHAssetCollectionSubtypeSmartAlbumAnimated)];//动图
    }
    
    for (int i = 0; i < assetSubtypes.count; i++) {
        PHAssetCollectionSubtype type = (PHAssetCollectionSubtype )[assetSubtypes[i] integerValue];
        PHFetchResult<PHAssetCollection *> *cameraRollCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:type options:nil];
        for (PHAssetCollection * album in cameraRollCollections) {
            NSInteger estimatedCount = album.estimatedAssetCount;
            if (estimatedCount>0||estimatedCount == NSNotFound) {
                MGAlbumModel * model = [MGAlbumModel new];
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
    for (PHAssetCollection * collection in assetCollections) {
        NSInteger estimatedCount = collection.estimatedAssetCount;
        if (estimatedCount>0||estimatedCount == NSNotFound) {
            MGAlbumModel * album = [MGAlbumModel alloc];
            album.assetCollection = collection;
            [albums addObject:album];
        }
    }
    if (completion) {
        completion((NSArray *)albums);
    }
}

+ (void)getAllAssets:(void(^)(NSArray <MGAssetModel *>*array))assetsBlock{
    // 获得所有的自定义相簿
    NSMutableArray * allAssetArray = [NSMutableArray array];
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    // 获得相机胶卷（系统相簿）
    PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    
    if (cameraRoll) {
         PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:cameraRoll options:nil];
        int i = 0;
        for (PHAsset *asset in assets) {
            MGAssetModel * assetModel = [MGAssetModel new];
            assetModel.index = i;
            assetModel.asset = asset;
            [allAssetArray addObject:assetModel];
            i++;
        }
    }
    // 遍历所有的自定义相簿
    for (PHAssetCollection *assetCollection in assetCollections) {
        PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        int i = 0;
        for (PHAsset *asset in assets) {
            MGAssetModel * assetModel = [MGAssetModel new];
            assetModel.asset = asset;
            assetModel.index = i;
            [allAssetArray addObject:assetModel];
            i++;
        }
        
    }
    //执行assetsBlock
    if (assetsBlock && allAssetArray.count>0) {
        assetsBlock(allAssetArray);
    }

}

+ (void)accessToUsePhotoLibrarycompletion:(void(^)(BOOL canUse))block{
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

+ (void)accessToCameracompletion:(void(^)(BOOL canUse))block{
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


+ (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

+ (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

+ (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}



+ (void)thumbnailImageWithAsset:(MGAssetModel *)assetModel size:(CGSize)size completion:(MGImageFromAssetResultBlock)completion{
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

+ (void)originImageWithAsset:(MGAssetModel *)assetModel completion:(MGImageFromAssetResultBlock)completion{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = YES;//允许异步下载
    CGSize size = CGSizeMake(assetModel.asset.pixelWidth, assetModel.asset.pixelHeight);
    [[PHImageManager defaultManager] requestImageForAsset:assetModel.asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (completion && result) {
            completion(result,info);
        }
    }];
    
    
}

+ (void)originImageWithAsset:(MGAssetModel *)assetModel completion:(MGImageFromAssetResultBlock)completion progress:(MGImageFromAssetProgressBlock)progressHandler {
    
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

+ (NSArray < MGAssetModel *> *)assetsWithAlbum:(MGAlbumModel *)album{
    NSMutableArray * allAssetArray = [NSMutableArray array];
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:album.assetCollection options:nil];
    int i = 0;
    for (PHAsset *asset in assets) {
        MGAssetModel * assetModel = [[MGAssetModel alloc]init];
        assetModel.asset = asset;
        assetModel.index = i;
        [allAssetArray addObject:assetModel];
        i++;
    }
    return allAssetArray.copy;
}

+ (void)clearCache;{
    [[MGImagePickerHandler shareIntance].cache removeAllObjects];
    
}


@end
