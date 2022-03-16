//
//  MGImageScanCollectionViewCell.h
//  test
//
//  Created by hehaichi on 2017/12/1.
//  Copyright © 2017年 app. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGImageMarco.h"
@class MGImageScanCollectionViewCell;
@protocol MGImageScanCollectionViewCellDelegate<NSObject>
@optional
/**
 单击大图的效果
 
 @return 返回隐藏还是显示头部和底部
 */
- (BOOL)didSingleTapImageView;

/**
 双击或者更多次点击
 
 @return 返回放大还是回复原状
 */
- (BOOL)didDoubleTapImageView;

/**
 图片完成导入

 @param image image
 @param cell cell
 */
- (void)imageDidLoad:(UIImage *)image withCell:(UICollectionViewCell *)cell;

/**
 图片缩放

 @param scrollView scrollView
 @param cell cell
 */
- (void)imageScanCellScrollViewDidZoom:(UIScrollView *)scrollView withCell:(MGImageScanCollectionViewCell *)cell;

@end



@interface MGImageScanCollectionViewCell : UICollectionViewCell
@property(nonatomic,strong)MGAssetModel * imageAsset;
@property(nonatomic,strong)UIScrollView * scrollView;
@property(nonatomic,strong)UIImageView * imageView;
@property(nonatomic,strong)UIView * imageContainerView;
@property(nonatomic,weak)id<MGImageScanCollectionViewCellDelegate>delegate;
@property(nonatomic,assign)CGFloat allowMinScale;
- (void)resizeContainerView;
- (CGRect)imageViewRectWithImageLoad;
- (CGFloat)zoomImageWithSize:(CGSize)targetSize animate:(BOOL)animate;
- (void)clearOriginImageifDontNeed;
@end


@interface MGSmallImageCollectionViewCell : UICollectionViewCell
@property(nonatomic,strong)UIImageView * imageView;
@property(nonatomic,strong)MGAssetModel * imageAsset;
@end
