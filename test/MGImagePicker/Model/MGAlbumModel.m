//
//  MGAlbumModel.m
//  test
//
//  Created by hehaichi on 2017/11/28.
//  Copyright © 2017年 app. All rights reserved.
//  相册模型

#import "MGAlbumModel.h"
#import "MGAssetModel.h"
@implementation MGAlbumModel
- (instancetype)init {
    if (self = [super init]) {
        _selectedAssetModelArray = [NSMutableArray array];
    }
    return self;
}

- (void)reSort {
    // 重新排序
    NSInteger i = 1;
    for (MGAssetModel * model in self.selectedAssetModelArray) {
        model.selectedIndex = i;
        model.selected = YES;
        i++;
    }
}
@end
