//
//  MGImagePickerViewController.h
//  test
//
//  Created by hehaichi on 2017/11/28.
//  Copyright © 2017年 app. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGImagePickerOption.h"
#import "MGImagePickerDelegate.h"

@class MGAssetModel;
@interface MGImagePickerViewController : UINavigationController
@property(nonatomic,strong) MGImagePickerOption *option;
@property(nonatomic,weak) id<MGImagePickerDelegate> pickerDelegate;

- (instancetype)initWithOption:(MGImagePickerOption *)option;
@end
