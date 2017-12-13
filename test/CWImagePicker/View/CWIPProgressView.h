//
//  CWIPProgressView.h
//  test
//
//  Created by hehaichi on 2017/12/5.
//  Copyright © 2017年 app. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CWIPProgressView : UIView
@property (nonatomic, assign) double progress;

- (void)showInView:(UIView *)view;
- (void)dissmiss;
@end
