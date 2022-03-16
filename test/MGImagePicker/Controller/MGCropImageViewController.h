//
//  MGCropImageViewController.h
//  test
//
//  Created by hehaichi on 2017/12/4.
//  Copyright © 2017年 app. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MGCropImageViewController;
@protocol MGCropImageViewControllerDelegate <NSObject>
@optional
/**
 已选择

 @param cropperViewController self
 @param editedImage 裁剪之后得到的image
 */
- (void)imageCropper:(MGCropImageViewController *)cropperViewController didFinished:(UIImage *)editedImage;

/**
 取消选择

 @param cropperViewController self
 */
- (void)imageCropperDidCancel:(MGCropImageViewController *)cropperViewController;

/**
 //裁剪框的样式，在这个协议方法中自定义你需要的裁剪框样式

 @param cropperViewController self
 @return 返回显示的裁剪框
 */
- (UIView *)imageCropFrameView:(MGCropImageViewController *)cropperViewController;

@end
@interface MGCropImageViewController : UIViewController
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, weak) id<MGCropImageViewControllerDelegate> delegate;
@property (nonatomic, assign) CGRect cropFrame;
- (instancetype)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio;

@end
