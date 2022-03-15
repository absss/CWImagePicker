//
//  MGImageScanController.h
//  test
//
//  Created by hehaichi on 2017/11/28.
//  Copyright © 2017年 app. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGImageMarco.h"
@interface MGImageScanController : UIViewController
/**
 所有的图片的assetArray
 */
@property(nonatomic,strong)NSArray<MGAssetModel *> * assetModelArray;

/**
 正在显示的indexpath
 */
@property(nonatomic,strong)NSIndexPath * displayIndexPath;

/**
 被选中的assetArray
 */
@property(nonatomic,strong)NSMutableArray<MGAssetModel *> * selectedAssetArray;


@end
