//
//  MGImagePickerHandler.h
//  test
//
//  Created by hehaichi on 2017/11/28.
//  Copyright © 2017年 app. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "MGImageMarco.h"
#import "MGImagePickerOption.h"
#import "CWIPCache.h"

typedef void(^MGAllAlbumsBlock)(NSArray <MGAlbumModel *> * array);

typedef void(^MGAllAssetsBlock)(NSArray <MGAssetModel *> * array);

typedef void(^MGAllImagesBlock)(NSArray <UIImage *> * array);

typedef void(^MGImageFromAssetResultBlock)(UIImage * image, NSDictionary  *  info);

typedef void(^MGImageFromAssetProgressBlock)(double progress, NSError *error, BOOL *stop, NSDictionary *info);

@interface MGImagePickerHandler : NSObject

@property(nonatomic,strong)MGImagePickerOption * option;

/**
 图片缓存
 */
@property(nonatomic,strong)CWIPCache * cache;

+ (instancetype)shareIntance;

/**
清空缓存
 */
+ (void)clearCache;

/**
 请求访问相册的权限，系统会弹框，
 
 @param block 完成之后的回调
 */
+ (void)accessToUsePhotoLibrarycompletion:(void(^)(BOOL canUse))block;


/**
 请求访问相机的权限，系统会弹框
 
 @param block 完成之后的回调
 */
+ (void)accessToCameracompletion:(void(^)(BOOL canUse))block;

/**
 是否有权限使用相册
 
 @return 返回结果
 */

+ (BOOL)isCanUsePhotos;

/**
是否有权限访问相机
 
 @return 结果
 */
+ (BOOL)isCanUseCamera;

/**
 是否具备相机的功能

 @return 结果
 */
+ (BOOL) isCameraAvailable;

/**
 是否具备后置相机的功能
 
 @return 结果
 */
+ (BOOL) isRearCameraAvailable;

/**
 是否具备前置相机的功能
 
 @return 结果
 */
+ (BOOL) isFrontCameraAvailable;

/**
 获取所有的相册组

 @param completion 完成之后的结果回调
 */
+ (void)getAllAlbums:(MGAllAlbumsBlock)completion;


/**
 从相册中获取所有的asset和image (asset可以理解为图片的索引，通过asset可以从PHImageManager取得image对象)

 @param assetsBlock 从系统中取到asset数组之后的回调,
 */
+ (void)getAllAssets:(MGAllAssetsBlock)assetsBlock;

/**
 通过asset对象获得缩略图对象

 @param assetModel MGAssetModel对象
 @param size 缩略图的尺寸，该值不可传入CGSizeZero 经过实测: [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeZero contentMode:PHImageContentModeDefault 得到的缩略图的分辨率 不如 [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill 得到的分辨率高，故要求传入缩略图尺寸，
 @param completion 结果回调
 */
+ (void)thumbnailImageWithAsset:(MGAssetModel *)assetModel size:(CGSize)size completion:(MGImageFromAssetResultBlock)completion;

/**
 通过asset对象获得原图对象，可能返回不清晰的缩略图

 @param assetModel MGAssetModel对象
 @param completion 结果回调
 */
+ (void)originImageWithAsset:(MGAssetModel *)assetModel completion:(MGImageFromAssetResultBlock)completion;


/**
  通过asset对象获得原图对象

 @param assetModel MGAssetModel对象
 @param completion 结果回调
 @param progressHandler 过程回调,在iClouds中下载的过程
 */
+ (void)originImageWithAsset:(MGAssetModel *)assetModel completion:(MGImageFromAssetResultBlock)completion progress:(MGImageFromAssetProgressBlock)progressHandler;

/**
 从相册中获取assets

 @param album 相册
 @return 返回array
 */
+ (NSArray < MGAssetModel *> *)assetsWithAlbum:(MGAlbumModel *)album;


@end
