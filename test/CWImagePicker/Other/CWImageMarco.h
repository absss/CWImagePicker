//
//  CWImageMarco.h
//  test
//
//  Created by hehaichi on 2017/11/28.
//  Copyright © 2017年 app. All rights reserved.
//

#ifndef CWImageMarco_h
#define CWImageMarco_h


#import "CWIPTool.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CWAlbumModel.h"
#import "CWIPAssetModel.h"
#import "UIViewController+CWAlertView.m"

#pragma mark - Function

#define CWIPColorFromHex(rgbValue) [UIColor colorWithRed:((float)(((rgbValue) & 0xFF0000) >> 16))/255.0 green:((float)(((rgbValue) & 0xFF00) >> 8))/255.0 blue:((float)((rgbValue) & 0xFF))/255.0 alpha:1.0]
#define CWIPRandom(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]
#define CWIPRandomColor CWIPRandom(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))
#define CWIPScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define CWIPScreenWidth  ([UIScreen mainScreen].bounds.size.width)
#define CWIPlocalString(keyName) (NSLocalizedStringFromTable(keyName,@"CWIPLocalizable",nil))

#define CWIPRectLog(imageContainerRect) NSLog(@"x:%lf,y:%lf,w:%lf,h:%lf",imageContainerRect.origin.x,imageContainerRect.origin.y,imageContainerRect.size.width,imageContainerRect.size.height);
#define CWIPPointLogi(point) NSLog(@"x:%lf,y:%lf",point.x,point.y);
#define CWIPSizeLog(asize) NSLog(@"w:%lf,h:%lf",asize.width,asize,height);

#define CWIPDarkColor CWIPColorFromHex(0x2b2c37)
#define CWIPGreenColor CWIPColorFromHex(0x1bac19)

#pragma mark - Const

#define kCWIPThumbnailEdge 4
#define kCWIPThumbnailNumberOfRow 4
#define kCWIPThumbnailSelectdButtonLength 30


#pragma mark - Block Weak self

#if __has_include(<ReactiveCocoa/ReactiveCocoa.h>)
#import <ReactiveCocoa/ReactiveCocoa.h>
#ifndef spweakify
#define spweakify(...) @weakify(__VA_ARGS__)
#endif

#ifndef spstrongify
#define spstrongify(...) @strongify(__VA_ARGS__)
#endif

#else
#ifndef spweakify
#if DEBUG
#define spweakify(object) @autoreleasepool{} __weak __typeof__(object) weak##_##object = object
#else
#define spweakify(object) @try{} @finally{} {} __weak __typeof__(object) weak##_##object = object
#endif
#endif

#ifndef spstrongify
#if DEBUG
#define spstrongify(object) @autoreleasepool{} __typeof__(object) object = weak##_##object
#else
#define spstrongify(object) @try{} @finally{} __typeof__(object) object = weak##_##object
#endif
#endif

#endif




#endif /* CWImageMarco_h */
