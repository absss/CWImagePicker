//
//  CWIPImagePickerOption.h
//  test
//
//  Created by hehaichi on 2017/12/5.
//  Copyright © 2017年 app. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CWImageMarco.h"
typedef NS_ENUM(NSInteger, CWImagePickerControllerSourceType) {
    CWImagePickerControllerSourceTypeCamera,
    UIImagePickerControllerSourceTypeAlbum
};
@interface CWIPImagePickerOption : NSObject

/**
 是否需要裁剪，默认是
 */
@property(nonatomic,assign)BOOL needCrop;

/**
 裁剪框的尺寸，默认为宽度的3/4
 */
@property(nonatomic,assign)CGSize cropFrameSize;

@property(nonatomic,assign)UIEdgeInsets cropFrameInsets;
/**
 允许放大的最大倍数
 */
@property(nonatomic,assign)CGFloat allowMaxZoomScale;
/**
 是否需要多图选择，默认否，为YES时，needCrop无效
 */
@property(nonatomic,assign)BOOL isMultiPage;

//默认选择相册
@property(nonatomic,assign)CWImagePickerControllerSourceType sourceType;
/**
 最大允许选择多少张，默认9张
 */
@property(nonatomic,assign)NSInteger maxAllowCount;

@end
