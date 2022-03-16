//
//  MGAlbumViewCollectionViewCell.h
//  test
//
//  Created by hehaichi on 2022/3/16.
//  Copyright © 2022 app. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGAlbumModel.h"


@protocol MGAlbumViewCollectionViewCellDelegate<NSObject>
- (void)didSelectedImageWithAssetModel:(MGAssetModel *)assetModel sender:(UIButton *)sender;
@end
@interface MGAlbumViewCollectionViewCell:UICollectionViewCell
@property(nonatomic,strong) MGAssetModel * imageAsset;
@property(nonatomic,weak) id<MGAlbumViewCollectionViewCellDelegate>delegate;
@end

