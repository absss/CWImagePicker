//
//  CWIPSystemImagePickViewController.m
//  test
//
//  Created by hehaichi on 2017/12/6.
//  Copyright © 2017年 app. All rights reserved.
//

#import "CWIPSystemImagePickViewController.h"
#import "CWCropImageViewController.h"
#import "CWImageMarco.h"
#import "CWImageManager.h"
#import "UIViewController+CWAlertView.h"
#define ORIGINAL_MAX_WIDTH 640.0f
@interface CWIPSystemImagePickViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,CWCropImageViewControllerDelegate>
@end
@implementation CWIPSystemImagePickViewController

- (instancetype)initWithOption:(CWIPImagePickerOption *)option
{
    self = [super init];
    
    if (self) {
        _option = option;
        [CWImageManager shareIntance].option = option;
        [self setup];
    }
    return self;
}
- (BOOL)setup{
    if ([CWImageManager shareIntance].option.sourceType == CWImagePickerControllerSourceTypeCamera) {
        if ([CWImageManager isCameraAvailable]) {
            self.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            return YES;
        }else{
            NSLog(@"获取不到相机,可能没有相机这个设备");
            return NO;
        }
    }else{
        if ([CWImageManager isCanUsePhotos]) {
            return YES;
        }else{
            return NO;
        }
    }   
}


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.delegate = self;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if ([self.cwDelegate respondsToSelector:@selector(cwNavigationBarForCWImagePicker:)]) {
        [self.cwDelegate cwNavigationBarForCWImagePicker:self.navigationBar];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    portraitImg = [self imageByScalingToMaxSize:portraitImg];
    if ([CWImageManager shareIntance].option.needCrop) {
        CGFloat w = [CWImageManager shareIntance].option.cropFrameSize.width;
        CGFloat h = [CWImageManager shareIntance].option.cropFrameSize.height;
        CWCropImageViewController * cropVc = [[CWCropImageViewController alloc]initWithImage:portraitImg cropFrame:CGRectMake(CWIPScreenWidth/2-w/2, CWIPScreenHeight/2-h/2, w, h) limitScaleRatio:[CWImageManager shareIntance].option.allowMaxZoomScale];
        cropVc.delegate = self;
        cropVc.title = CWIPlocalString(@"CWIPStr_selectImageTitle");
//        cropVc.navigationController.navigationBarHidden = NO;
        
        if (![self.visibleViewController isKindOfClass:NSClassFromString(@"CWCropImageViewController")]) {
            [self pushViewController:cropVc animated:YES];
        }
       
    }else{
        if ([self.cwDelegate respondsToSelector:@selector(didSelectedImageWithImage:)]) {
            [self.cwDelegate didSelectedImageWithImage:portraitImg];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -  CWCropImageViewControllerDelegate
- (void)imageCropper:(CWCropImageViewController *)cropperViewController didFinished:(UIImage *)editedImage{
    if ([self.cwDelegate respondsToSelector:@selector(didSelectedCropImageWithImage:)]) {
        [self.cwDelegate didSelectedCropImageWithImage:editedImage];
         [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    
}

- (void)imageCropperDidCancel:(CWCropImageViewController *)cropperViewController{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}


- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)dealloc{
    NSLog(@"%s",__func__);
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion{
    [CWImageManager clearCache];
    [super dismissViewControllerAnimated:flag completion:completion];
}

@end
