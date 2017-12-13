//
//  CWAllImageViewController.h
//  test
//
//  Created by hehaichi on 2017/11/28.
//  Copyright © 2017年 app. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWImageMarco.h"
#import "CWAlbumModel.h"
@protocol CWIPAllImageViewCollectionViewCellDelegate<NSObject>
- (void)didSelectedImageWithAssetModel:(CWIPAssetModel *)assetModel sender:(UIButton *)sender;
@end
@interface CWIPAllImageViewCollectionViewCell:UICollectionViewCell
@property(nonatomic,strong)CWIPAssetModel * imageAsset;
@property(nonatomic,weak)id<CWIPAllImageViewCollectionViewCellDelegate>delegate;
@end


@interface CWAllImageViewController : UIViewController
@property(nonatomic,strong)CWAlbumModel * albumModel;
@property(nonatomic,strong)NSMutableArray * selectedAssetModelArray;
- (void)loadAllImageData;
- (void)refreshCollectionView;
@end
