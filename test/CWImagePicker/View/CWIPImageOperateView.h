//
//  CWIPImageOperateView.h
//  test
//
//  Created by hehaichi on 2017/11/29.
//  Copyright © 2017年 app. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWImageMarco.h"

@interface CWIPImageOperateView : UIView
@property(nonatomic,assign,readonly)BOOL enable;
@property(nonatomic,assign)NSInteger selectedCount;

@property(nonatomic,strong)UIButton * scanButton;
@property(nonatomic,strong)UIButton * completeButton;

@property(nonatomic,copy)void(^imageOperateViewScanActionBlock)(UIButton *sender);
@property(nonatomic,copy)void(^imageOperateViewSendActionBlock)(UIButton *sender);
@end

@interface CWIPShowCountButton:UIButton
@property(nonatomic,assign)NSInteger count;
@property(nonatomic,assign)BOOL enableShowCount;

@property(nonatomic,copy)void(^showCountButtonActionBlock)(CWIPShowCountButton * sender);

@end
