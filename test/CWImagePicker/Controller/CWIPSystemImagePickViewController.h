//
//  CWIPSystemImagePickViewController.h
//  test
//
//  Created by hehaichi on 2017/12/6.
//  Copyright © 2017年 app. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWIPImagePickerDelegate.h"
#import "CWIPImagePickerOption.h"
@interface CWIPSystemImagePickViewController : UIImagePickerController
@property(nonatomic,weak)id<CWIPImagePickerDelegate>cwDelegate;
@property(nonatomic,strong)CWIPImagePickerOption * option;

- (instancetype)initWithOption:(CWIPImagePickerOption *)option;
@end
