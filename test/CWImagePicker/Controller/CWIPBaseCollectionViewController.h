//
//  CWIPBaseCollectionViewController.h
//  test
//
//  Created by hehaichi on 2017/12/1.
//  Copyright © 2017年 app. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWImageMarco.h"
#import "CWImageManager.h"

@interface CWIPBaseCollectionViewController : UIViewController
@property(nonatomic,strong)CWIPAssetModel * imageAsset;
@property(nonatomic,strong)UICollectionView * collectionView;
@property(nonatomic,strong)NSString * reuseId;
@end
