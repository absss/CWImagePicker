//
//  CWIPCropFrameView.m
//  test
//
//  Created by hehaichi on 2017/12/4.
//  Copyright © 2017年 app. All rights reserved.
//

#import "CWIPCropFrameView.h"

@interface CWIPCropFrameView()
@property(nonatomic,strong)NSArray *rowLineArray;
@property(nonatomic,strong)NSArray *columnLineArray;
@end

@implementation CWIPCropFrameView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 1;
    if (self) {
//        for (UIView * line in self.rowLineArray) {
//            [self addSubview:line];
//        }
//        for (UIView *line in self.columnLineArray) {
//            [self addSubview:line];
//        }
    }
    
    return self;
}
- (void)setFrameWithAnimation:(CGRect)frame withAnimateTime:(NSTimeInterval)timeInterval{
    [UIView animateWithDuration:timeInterval animations:^{
        self.frame = frame;
    }];
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    CGFloat row_w = CGRectGetWidth(self.frame)/3;
    CGFloat row_h = CGRectGetHeight(self.frame);
    CGFloat column_w = CGRectGetWidth(self.frame);
    CGFloat column_h = CGRectGetHeight(self.frame)/3;
    
    for (int i = 0; i<self.rowLineArray.count; i++) {
        UIView *line = self.rowLineArray[i];
        line.frame = CGRectMake((i+1)*row_w, 0, 1, row_h);
    }
    for (int i = 0; i<self.columnLineArray.count; i++) {
        UIView *line = self.columnLineArray[i];
        line.frame = CGRectMake(0, column_h*(i+1), column_w,1);
    }
}

- (NSArray *)rowLineArray{
    if (!_rowLineArray) {
        NSMutableArray * array = @[].mutableCopy;
        for (int i = 1; i<3; i++) {
            UIView * line = [[UIView alloc]init];
            line.alpha = 0.5;
            line.backgroundColor = [UIColor whiteColor];
            [array addObject:line];
        }
        _rowLineArray = array.copy;
    }
    return _rowLineArray;
}

- (NSArray *)columnLineArray{
    if (!_columnLineArray) {
        NSMutableArray * array = @[].mutableCopy;
        for (int i = 1; i<3; i++) {
            UIView * line = [[UIView alloc]init];
            line.alpha = 0.5;
            line.backgroundColor = [UIColor whiteColor];
            [array addObject:line];
        }
        _columnLineArray = array.copy;
    }
    return _columnLineArray;
}
@end
