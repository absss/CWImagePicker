//
//  CWIPAssetModel.m
//  test
//
//  Created by hehaichi on 2017/11/29.
//  Copyright © 2017年 app. All rights reserved.
//

#import "CWIPAssetModel.h"

@implementation CWIPAssetModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        _index = -1;
        _selectedIndex = -1;
    }
    return self;
}
@end
