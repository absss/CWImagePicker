//
//  UIViewController+CWAlertView.h
//  test
//
//  Created by hehaichi on 2017/12/6.
//  Copyright © 2017年 app. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (CWAlertView)<UIImagePickerControllerDelegate,UIActionSheetDelegate>
- (void)alertViewWithTitle:(NSString *)title;

@end
