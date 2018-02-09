//
//  CWIPImagePickerDelegate.h
//  test
//
//  Created by hehaichi on 2017/12/6.
//  Copyright © 2017年 app. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CWIPAssetModel;
@protocol CWIPImagePickerDelegate <NSObject>
@optional
- (UIViewController *)viewController;
/**
 返回裁剪后的图片
 
 @param image 图片
 */
- (void)cwController:(UIViewController *)controller didSelectedCropImageWithImage:(UIImage *)image;

/**
 选取单张图片

 @param image  image
 */
- (void)cwController:(UIViewController *)controller didSelectedImageWithImage:(UIImage *)image;
/**
 选择多张图片

 @param thumbnailArray 假如是单选，则数组中只有一个
 @param array CWIPAssetModel对象，与thumbnailArray对应
 */
- (void)cwController:(UIViewController *)controller didSelectedImageArrayWithThumbnailImageArray:(NSArray *)thumbnailArray withAssetArray:(NSArray <CWIPAssetModel *> *)array;

/**
 设置导航栏

 @param navigationBar navigationBar
 */
- (void)cwNavigationBarForCWImagePicker:(UINavigationBar *)navigationBar;
@end
