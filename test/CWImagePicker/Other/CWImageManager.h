//
//  CWImageManager.h
//  test
//
//  Created by hehaichi on 2017/11/28.
//  Copyright © 2017年 app. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "CWImageMarco.h"
#import "CWIPImagePickerOption.h"
#import "CWIPCache.h"

typedef void(^CWGetAllAlbumArrayCompleteBlock)(NSArray <CWAlbumModel *> * array);

typedef void(^CWGetAllAssetsAndThumbnailImagesArrayAssetsBlock)(NSArray <CWIPAssetModel *> * array);

typedef void(^CWGetAllImagesArrayImagesBlock)(NSArray <UIImage *> * array);

typedef void(^CWGetImageFromAssetResultBlock)(UIImage * image, NSDictionary  *  info);

typedef void(^CWGetImageFromAssetProgressBlock)(double progress, NSError *error, BOOL *stop, NSDictionary *info);

@interface CWImageManager : NSObject
@property(nonatomic,strong)CWIPImagePickerOption * option;

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
 是否支持Photos框架

 @return 结果
 */
+ (BOOL)isSupportPhotosFramework;

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
+ (void)getAllAlbumArray:(CWGetAllAlbumArrayCompleteBlock)completion;


/**
 从相册中获取所有的asset和image (asset可以理解为图片的索引，通过asset可以从PHImageManager取得image对象)

 @param assetsBlock 从系统中取到asset数组之后的回调,
 */
+ (void)getAllAssetsAndThumbnailImagesArray:(CWGetAllAssetsAndThumbnailImagesArrayAssetsBlock)assetsBlock;

/**
 通过asset对象获得缩略图对象

 @param assetModel CWIPAssetModel对象
 @param size 缩略图的尺寸，该值不可传入CGSizeZero 经过实测: [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeZero contentMode:PHImageContentModeDefault 得到的缩略图的分辨率 不如 [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill 得到的分辨率高，故要求传入缩略图尺寸，
 @param completion 结果回调
 */
+ (void)thumbnailImageWithAsset:(CWIPAssetModel *)assetModel withImageSize:(CGSize)size withCompleteBlock:(CWGetImageFromAssetResultBlock)completion;

/**
 通过asset对象获得原图对象，可能返回不清晰的缩略图

 @param assetModel CWIPAssetModel对象
 @param completion 结果回调
 */
+ (void)originImageWithAsset:(CWIPAssetModel *)assetModel withCompleteBlock:(CWGetImageFromAssetResultBlock)completion;


/**
  通过asset对象获得原图对象

 @param assetModel CWIPAssetModel对象
 @param completion 结果回调
 @param progressHandler 过程回调,在iClouds中下载的过程
 */
+ (void)originImageWithAsset:(CWIPAssetModel *)assetModel withCompleteBlock:(CWGetImageFromAssetResultBlock)completion withProgressBlock:(CWGetImageFromAssetProgressBlock)progressHandler;

/**
 从相册->assetArray

 @param album 相册
 @return 返回array
 */
+ (NSArray < CWIPAssetModel *> *)assetsWithAlbumCollection:(CWAlbumModel *)album;


@end
