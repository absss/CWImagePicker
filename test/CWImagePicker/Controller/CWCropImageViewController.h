//
//  CWCropImageViewController.h
//  test
//
//  Created by hehaichi on 2017/12/4.
//  Copyright © 2017年 app. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CWCropImageViewController;
@protocol CWCropImageViewControllerDelegate <NSObject>
@optional
/**
 已选择

 @param cropperViewController self
 @param editedImage 裁剪之后得到的image
 */
- (void)imageCropper:(CWCropImageViewController *)cropperViewController didFinished:(UIImage *)editedImage;

/**
 取消选择

 @param cropperViewController self
 */
- (void)imageCropperDidCancel:(CWCropImageViewController *)cropperViewController;

/**
 //裁剪框的样式，在这个协议方法中自定义你需要的裁剪框样式

 @param cropperViewController self
 @return 返回显示的裁剪框
 */
- (UIView *)imageCropFrameView:(CWCropImageViewController *)cropperViewController;

@end
@interface CWCropImageViewController : UIViewController
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, weak) id<CWCropImageViewControllerDelegate> delegate;
@property (nonatomic, assign) CGRect cropFrame;
- (instancetype)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio;

@end
