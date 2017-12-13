//
//  CWIPAssetModel.h
//  test
//
//  Created by hehaichi on 2017/11/29.
//  Copyright © 2017年 app. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface CWIPAssetModel : NSObject

/**
 图片信息
 */
@property(nonatomic,strong)PHAsset * asset;

/**
 是否被选中
 */
@property(nonatomic,assign,getter=isSelected)BOOL selected;

/**
 在所有图片排序中的index
 */
@property(nonatomic,assign)NSInteger index;

/**
 被选中的所有图片中的index
 */
@property(nonatomic,assign)NSInteger selectedIndex;


/**
 正在被展示
 */
@property(nonatomic,assign,getter=isDisplay)BOOL displayed;

@end
