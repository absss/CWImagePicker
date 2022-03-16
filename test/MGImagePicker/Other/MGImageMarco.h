//
//  MGImageMarco.h
//  test
//
//  Created by hehaichi on 2017/11/28.
//  Copyright © 2017年 app. All rights reserved.
//

#ifndef MGImageMarco_h
#define MGImageMarco_h


#import "MGImagePickerTool.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MGAlbumModel.h"
#import "MGAssetModel.h"
#import "UIViewController+CWAlertView.m"

#pragma mark - Function

#define MGColorFromHex(rgbValue) [UIColor colorWithRed:((float)(((rgbValue) & 0xFF0000) >> 16))/255.0 green:((float)(((rgbValue) & 0xFF00) >> 8))/255.0 blue:((float)((rgbValue) & 0xFF))/255.0 alpha:1.0]

#define MGScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define MGScreenWidth  ([UIScreen mainScreen].bounds.size.width)
#define MGMaxScreenWidth MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
#define MGMinScreenWidth MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
#define MG_IS_IPHONEX ((MGMaxScreenWidth>=812)?YES:NO)
#define MG_NAVIGATION_HEIGHT (MG_IS_IPHONEX ? 88 : 64)

#define MGLocalString(keyName) (NSLocalizedStringFromTable(keyName,@"CWIPLocalizable",nil))

#define MGDarkColor MGColorFromHex(0x2b2c37)
#define MGGreenColor MGColorFromHex(0x1bac19)

#pragma mark - Const

#define kMGThumbnailEdge 4
#define kMGThumbnailNumberOfRow 4
#define kMGThumbnailSelectdButtonLength 30




#endif /* MGImageMarco_h */
