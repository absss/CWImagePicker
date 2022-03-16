//
//  MGAssetModel.h
//  test
//
//  Created by hehaichi on 2017/11/29.
//  Copyright © 2017年 app. All rights reserved.
// 图片资源模型

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface MGAssetModel : NSObject

/**
 图片信息
 */
@property(nonatomic,strong) PHAsset * asset;

/**
 是否被选中
 */
@property(nonatomic,assign,getter=isSelected)BOOL selected;

/**
 在所在图册中的排序
 */
@property(nonatomic,assign)NSInteger index;

/**
 在被选中数组中排序
 */
@property(nonatomic,assign)NSInteger selectedIndex;

/**
 正在被展示
 */
@property(nonatomic,assign,getter=isDisplay)BOOL displayed;

@end
