//
//  MGAlbumModel.h
//  test
//
//  Created by hehaichi on 2017/11/28.
//  Copyright © 2017年 app. All rights reserved.
// 相册模型

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@class MGAssetModel;
@interface MGAlbumModel : NSObject
@property(nonatomic,strong) PHAssetCollection * assetCollection;
@property(nonatomic,strong) NSArray <MGAssetModel *>* assetModelArray;
@property(nonatomic,strong) NSMutableArray<MGAssetModel *> * selectedAssetModelArray; // 被选中的图片

// 重新排序
- (void)reSort;
@end
