//
//  MGImageScanCollectionViewCell.m
//  test
//
//  Created by hehaichi on 2017/12/1.
//  Copyright © 2017年 app. All rights reserved.
//

#import "MGImageScanCollectionViewCell.h"
#import "MGImageMarco.h"
#import "MGImagePickerHandler.h"
#import "MGProgressView.h"

@interface MGImageScanCollectionViewCell()<UIScrollViewDelegate>
@property(nonatomic,strong)MGProgressView * progressView;
@end
@implementation MGImageScanCollectionViewCell
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
- (void)setImageAsset:(MGAssetModel *)imageAsset{
    _imageAsset = imageAsset;
    [MGImagePickerHandler originImageWithAsset:imageAsset completion:^(UIImage *image,NSDictionary *info) {
        _imageView.image = image;
        [self resizeContainerView];
        if ([self.delegate respondsToSelector:@selector(imageDidLoad:withCell:)]) {
            [self.delegate imageDidLoad:image withCell:self];
        }

    } progress:nil];
    //collectionview复用时，会有两个cell存在于内存中，但是没有被显示的那个cell中的图片应该也被销毁
    [self clearOriginImageifDontNeed];
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

- (MGProgressView *)progressView{
    if (!_progressView) {
        _progressView = [MGProgressView new];
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
- (void)clearOriginImageifDontNeed{
    if (!self.imageAsset.isDisplay) {
        self.imageView.image = nil;
    }
}

- (CGFloat)zoomImageWithSize:(CGSize)targetSize animate:(BOOL)animate{
    CGFloat wScale =  targetSize.width/CGRectGetWidth(self.imageView.frame);
    CGFloat targetScale = wScale;
    [self.scrollView setZoomScale:targetScale animated:animate];
    return targetScale;
}

- (CGSize)resizeImage{
    CGFloat IW = self.imageView.image.size.width;
    CGFloat IH = self.imageView.image.size.height;
    CGFloat CW = CGRectGetWidth(self.contentView.frame);
    CGFloat CH = CGRectGetHeight(self.contentView.frame);
    CGFloat W,H;
    if (IW == 0 ||
        IH == 0 ||
        CW == 0 ||
        CH == 0 ) {
        return CGSizeZero;
    }
    if (IW/IH > CW/CH) {
        W = CW;
        H = CW * IH / IW;
    }else{
        H = CH;
        W = CH * IW / IH;
    }
 
    return CGSizeMake(W, H);
}

- (void)resizeContainerView{
    CGSize imgSize = [self resizeImage];
    CGRect rect  = CGRectMake(0, 0, imgSize.width, imgSize.height);
    self.imageContainerView.frame = rect;
    self.imageContainerView.center = self.contentView.center;
    self.imageView.frame = self.imageContainerView.bounds;
    [self refreshViewFrame];
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

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [self refreshViewFrame];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view {
    [self refreshViewFrame];
}


- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageContainerView;
}
@end

@implementation MGSmallImageCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.imageView];
    }
    return self;
}
#pragma mark - setter
- (void)setImageAsset:(MGAssetModel *)imageAsset{
    _imageAsset = imageAsset;
    [MGImagePickerHandler thumbnailImageWithAsset:imageAsset size:self.imageView.frame.size completion:^(UIImage *image,NSDictionary * info) {
        self.imageView.image = image;
    }];
    if (imageAsset.isDisplay) {
        self.contentView.layer.borderColor = MGGreenColor.CGColor;
        self.contentView.layer.borderWidth = 2.0f;
    }else{
        self.contentView.layer.borderColor = [UIColor clearColor].CGColor;
        self.contentView.layer.borderWidth = 0.0f;
    }
}


- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]initWithFrame: self.contentView.frame];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

@end
