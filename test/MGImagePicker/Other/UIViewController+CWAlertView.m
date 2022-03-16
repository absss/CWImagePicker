//
//  UIViewController+CWAlertView.m
//  test
//
//  Created by hehaichi on 2017/12/6.
//  Copyright © 2017年 app. All rights reserved.
//
#import <Photos/Photos.h>
#import "UIViewController+CWAlertView.h"

@implementation UIViewController (CWAlertView)
- (void)alertViewWithTitle:(NSString *)title{
    if (NSClassFromString(@"UIAlertController")) {
        UIAlertController * vc = [UIAlertController  alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:vc animated:YES completion:nil];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:nil];
        [vc addAction:action];
    }else{
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:title message:@"" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
        [alertView show];
    }
    
}


@end
