//
//  MGImageOperateView.m
//  test
//
//  Created by hehaichi on 2017/11/29.
//  Copyright © 2017年 app. All rights reserved.
//

#import "MGImageOperateView.h"
@interface MGImageOperateView()

@end
@implementation MGImageOperateView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _enable = NO;
        self.selectedCount = 0;
        
        [self addSubview:self.scanButton];
        [self addSubview:self.completeButton];
    }
    return self;
}

#pragma mark - setter
- (void)setSelectedCount:(NSInteger)selectedCount{
    _selectedCount = selectedCount;
    
    if (selectedCount > 0) {
        NSString * title = [NSString stringWithFormat:MGLocalString(@"MGStr_SendImage"),self.selectedCount];
        [self.completeButton setTitle:title forState:UIControlStateSelected];
        self.completeButton.userInteractionEnabled = YES;
        self.scanButton.userInteractionEnabled = YES;
        self.completeButton.selected = YES;
        self.scanButton.selected = YES;
        _enable = YES;
    }else{
        self.completeButton.userInteractionEnabled = NO;
        self.scanButton.userInteractionEnabled = NO;
        self.completeButton.selected = NO;
        self.scanButton.selected = NO;
        _enable = NO;
    }
    
}

- (UIButton *)scanButton{
    if (!_scanButton) {
        _scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _scanButton.frame = CGRectMake(0, 3, 50, 44);
        [_scanButton setTitle:MGLocalString(@"MGStr_Scan") forState:UIControlStateNormal];
        [_scanButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_scanButton setTitleColor:MGColorFromHex(0x697065) forState:UIControlStateNormal];
        _scanButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_scanButton addTarget:self action:@selector(scanAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _scanButton;
}

- (UIButton *)completeButton{
    if (!_completeButton) {
        _completeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _completeButton.frame = CGRectMake(CGRectGetWidth(self.frame)-13.5-60, 10, 60, 30);
        [_completeButton setTitle:MGLocalString(@"MGStr_Send") forState:UIControlStateNormal];
        [_completeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_completeButton setTitleColor:MGColorFromHex(0x697065) forState:UIControlStateNormal];
        [_completeButton setBackgroundImage:[MGImagePickerTool imageWithColor:MGColorFromHex(0x165414) size:CGSizeMake(60, 30)] forState:UIControlStateNormal];
        [_completeButton setBackgroundImage:[MGImagePickerTool imageWithColor:MGGreenColor size:CGSizeMake(60, 30)] forState:UIControlStateSelected];
        _completeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _completeButton.layer.cornerRadius = 5;
        _completeButton.layer.masksToBounds = YES;
         [_completeButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _completeButton;
}

- (void)scanAction:(UIButton *)sender{
    if (self.imageOperateViewScanActionBlock) {
        self.imageOperateViewScanActionBlock(sender);
    }
}

- (void)sendAction:(UIButton *)sender{
    if (self.imageOperateViewSendActionBlock) {
        self.imageOperateViewSendActionBlock(sender);
    }
}
@end


@interface MGImageSelectButton()
@property(nonatomic,strong)UILabel * countLabel;

@end
@implementation MGImageSelectButton
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage * normalImg = [UIImage imageNamed:@"MGImagePickerResource.bundle/photo_def_previewVc"];
        self.titleLabel.font = [UIFont systemFontOfSize:13];
        CGRect rect = frame;
        if (rect.size.height != rect.size.width || rect.size.width<25 || rect.size.width >44) {
             rect.size = CGSizeMake(40, 40);
        }
        self.frame = rect;

        [self setImage:normalImg forState:UIControlStateNormal];
        self.showCount = NO;
        
        [self addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
- (UILabel *)countLabel{
    if (!_countLabel) {
        _countLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.font = [UIFont systemFontOfSize:14];
        _countLabel.hidden = YES;
        _countLabel.text = @"";

    }
    return _countLabel;
}

- (void)selectAction:(MGImageSelectButton *)sender{
    sender.selected = !sender.selected;
    if (self.showCountButtonActionBlock) {
        self.showCountButtonActionBlock(self);
    }
}

- (void)setShowCount:(BOOL)showCount{
    _showCount = showCount;
    UIImage * selectedImg;
    if (!showCount) {
        [self.countLabel removeFromSuperview];
        selectedImg = [UIImage imageNamed:@"MGImagePickerResource.bundle/photo_sel_photoPickerVc"];
    }else{
        [self addSubview:self.countLabel];
        selectedImg = [UIImage imageNamed:@"MGImagePickerResource.bundle/photo_number_icon"];
    }
    [self setImage:selectedImg forState:UIControlStateSelected];
}

- (void)setCount:(NSInteger)count{
    if (count>0) {
        _countLabel.text = [@(count) stringValue];
    }
   
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected) {
        _countLabel.hidden = NO;
    }else{
        _countLabel.hidden = YES;
    }  
}
@end

