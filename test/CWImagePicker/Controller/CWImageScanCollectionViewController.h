//
//  CWImageScanCollectionViewController.h
//  test
//
//  Created by hehaichi on 2017/11/28.
//  Copyright © 2017年 app. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWImageMarco.h"
@interface CWImageScanCollectionViewController : UIViewController
/**
 所有的图片的assetArray
 */
@property(nonatomic,strong)NSArray<CWIPAssetModel *> * assetModelArray;

/**
 被选中的indexpath
 */
@property(nonatomic,strong)NSIndexPath * displayIndexPath;

/**
 被选中的assetArray
 */
@property(nonatomic,strong)NSMutableArray<CWIPAssetModel *> * selectedAssetArray;


@end
