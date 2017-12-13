//
//  CWImageScanCollectionViewCell.m
//  test
//
//  Created by hehaichi on 2017/12/1.
//  Copyright © 2017年 app. All rights reserved.
//

#import "CWImageScanCollectionViewCell.h"
#import "CWImageMarco.h"
#import "CWImageManager.h"
#import "CWIPProgressView.h"

@interface CWImageScanCollectionViewCell()<UIScrollViewDelegate>
@property(nonatomic,strong)CWIPProgressView * progressView;
@end
@implementation CWImageScanCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.scrollView];
        [self.scrollView addSubview:self.imageContainerView];
        [self.imageContainerView addSubview:self.imageView];
        self.contentView.backgroundColor = [UIColor blackColor];
        
    }
    return self;
}

//该setter方法只会在cell被dispaly的时候调用，这样的话，使得没有被浏览的cell不会加载图片
- (void)setImageAsset:(CWIPAssetModel *)imageAsset{
    _imageAsset = imageAsset;
    [CWImageManager originImageWithAsset:imageAsset withCompleteBlock:^(UIImage *image,NSDictionary *info) {
        _imageView.image = image;
            [self resizeContainerView];
        if ([self.delegate respondsToSelector:@selector(imageDidLoad:withCell:)]) {
            [self.delegate imageDidLoad:image withCell:self];
        }

    } withProgressBlock:nil];
}

- (void)setAllowMinScale:(CGFloat)allowMinScale{
    _allowMinScale = allowMinScale;
    _scrollView.minimumZoomScale = allowMinScale;
}

#pragma mark - getter
- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:self.contentView.frame];
        _scrollView.delegate = self;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.bouncesZoom = YES;
        _scrollView.minimumZoomScale = 1;
        _scrollView.maximumZoomScale = 4;
        _scrollView.bounces = YES;
    
    }
    return _scrollView;
}

- (UIView *)imageContainerView{
    if (!_imageContainerView) {
        _imageContainerView = [[UIView alloc]initWithFrame:self.contentView.frame];
        _imageContainerView.clipsToBounds = YES;
    }
    return _imageContainerView;
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView =[[UIImageView alloc]initWithFrame:self.contentView.frame];
        _imageView.backgroundColor = [UIColor blackColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer * tapGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        UITapGestureRecognizer * doubleTapGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
        doubleTapGest.numberOfTapsRequired = 2;
        [tapGest requireGestureRecognizerToFail:doubleTapGest];
        [_imageView addGestureRecognizer:tapGest];
        [_imageView addGestureRecognizer:doubleTapGest];
    }
    return _imageView;
}

- (CWIPProgressView *)progressView{
    if (!_progressView) {
        _progressView = [CWIPProgressView new];
    }
    return _progressView;
}

#pragma mark - target selector

- (void)tapAction:(UITapGestureRecognizer *)sender{
    if ([self.delegate respondsToSelector:@selector(didSingleTapImageView)]) {
        [self.delegate didSingleTapImageView];
    }
}

- (void)doubleTapAction:(UITapGestureRecognizer *)sender{
    if ([self.delegate respondsToSelector:@selector(didDoubleTapImageView)]) {
        BOOL flag = [self.delegate didDoubleTapImageView];
        [UIView animateWithDuration:0.4 animations:^{
            self.scrollView.zoomScale = flag?1.0:2.0;
        }];
        
    }
    
}
#pragma mark - private method
- (CGFloat)zoomImageWithSize:(CGSize)targetSize animate:(BOOL)animate{
    CGFloat wScale =  targetSize.width/CGRectGetWidth(self.imageView.frame);
    CGFloat targetScale = wScale;
    [self.scrollView setZoomScale:targetScale animated:animate];
    return targetScale;
}

- (CGRect)imageViewRectWithImageLoad{
    CGFloat IW = self.imageView.image.size.width;
    CGFloat IH = self.imageView.image.size.height;
    CGFloat CW = CGRectGetWidth(self.contentView.frame);
    CGFloat CH = CGRectGetHeight(self.contentView.frame);
    CGFloat W,H;
    if (IW/IH > CW/CH) {
        W = CW;
        H = CW * IH / IW;
    }else{
        H = CH;
        W = CH * IW / IH;
    }
    return CGRectMake(0, self.contentView.center.y-H/2,W,H);
}

- (void)resizeContainerView{
    CGRect rect  = [self imageViewRectWithImageLoad];
    self.imageContainerView.frame = rect;
    self.imageView.frame = self.imageContainerView.bounds;
}

- (void)refreshViewFrame{
    CGFloat offsetX = (CGRectGetWidth(_scrollView.frame) > _scrollView.contentSize.width) ? ((CGRectGetWidth(_scrollView.frame) - _scrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (CGRectGetHeight(_scrollView.frame) > _scrollView.contentSize.height) ? ((CGRectGetHeight(_scrollView.frame) - _scrollView.contentSize.height) * 0.5) : 0.0;
    self.imageContainerView.center = CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX, _scrollView.contentSize.height * 0.5 + offsetY);
    
    
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    [self refreshViewFrame];
    if ([self.delegate respondsToSelector:@selector(imageScanCellScrollViewDidZoom: withCell:)]) {
        [self.delegate imageScanCellScrollViewDidZoom:scrollView withCell:self];
    }
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageContainerView;
}
@end
