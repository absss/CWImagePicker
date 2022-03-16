//
//  MGAlbumViewController.h
//  test
//
//  Created by hehaichi on 2017/11/28.
//  Copyright © 2017年 app. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGImageMarco.h"
#import "MGAlbumModel.h"
@protocol MGAlbumViewCollectionViewCellDelegate<NSObject>
- (void)didSelectedImageWithAssetModel:(MGAssetModel *)assetModel sender:(UIButton *)sender;
@end
@interface MGAlbumViewCollectionViewCell:UICollectionViewCell
@property(nonatomic,strong) MGAssetModel * imageAsset;
@property(nonatomic,weak) id<MGAlbumViewCollectionViewCellDelegate>delegate;
@end


@interface MGAlbumViewController : UIViewController
@end
