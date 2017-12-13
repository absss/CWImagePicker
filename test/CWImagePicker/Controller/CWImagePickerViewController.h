//
//  CWImagePickerViewController.h
//  test
//
//  Created by hehaichi on 2017/11/28.
//  Copyright © 2017年 app. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWIPImagePickerOption.h"
#import "CWIPImagePickerDelegate.h"

@class CWIPAssetModel;

@interface CWImagePickerViewController : UINavigationController
@property(nonatomic,strong)CWIPImagePickerOption *option;
@property(nonatomic,weak)id<CWIPImagePickerDelegate> cwDelegate;

- (instancetype)initWithOption:(CWIPImagePickerOption *)option;
@end
