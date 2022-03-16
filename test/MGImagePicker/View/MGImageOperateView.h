//
//  MGImageOperateView.h
//  test
//
//  Created by hehaichi on 2017/11/29.
//  Copyright © 2017年 app. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGImageMarco.h"

@interface MGImageOperateView : UIView
@property(nonatomic,assign,readonly)BOOL enable;
@property(nonatomic,assign)NSInteger selectedCount;

@property(nonatomic,strong)UIButton * scanButton;
@property(nonatomic,strong)UIButton * completeButton;

@property(nonatomic,copy)void(^imageOperateViewScanActionBlock)(UIButton *sender);
@property(nonatomic,copy)void(^imageOperateViewSendActionBlock)(UIButton *sender);
@end

@interface MGImageSelectButton:UIButton
@property(nonatomic,assign) NSInteger count;
@property(nonatomic,assign) BOOL showCount;

@property(nonatomic,copy)void(^showCountButtonActionBlock)(MGImageSelectButton * sender);

@end
