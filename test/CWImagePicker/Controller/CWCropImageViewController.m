//
//  CWCropImageViewController.m
//  test
//
//  Created by hehaichi on 2017/12/4.
//  Copyright © 2017年 app. All rights reserved.
//

#import "CWCropImageViewController.h"
#import "CWImageManager.h"

@interface CWCropImageViewController ()
@property(nonatomic,strong)UIImage *originalImage;
@property(nonatomic,strong)UIImage *editedImage;

@property(nonatomic,strong)UIImageView *showImgView;
@property(nonatomic,strong)UIView *overlayView;
@property(nonatomic,strong)UIView *ratioView;
@property(nonatomic,strong)UIButton *cancelButton;
@property(nonatomic,strong)UIButton *confirmButton;
@property(nonatomic,strong)UIView * bottomView;
@property(nonatomic,strong)UIView * navigationBarView;

@property(nonatomic,assign)CGRect oldFrame;
@property(nonatomic,assign)CGRect largeFrame;
@property(nonatomic,assign)CGRect smallFrame;

@property(nonatomic,assign)CGFloat limitRatio;
@property(nonatomic,assign)CGFloat allowMinRatio;
@property(nonatomic,assign)CGFloat overlayAlpha;
@property(nonatomic,assign)CGFloat scrollRatio;

@property(nonatomic,assign)CGRect latestFrame;
@end

@implementation CWCropImageViewController

- (id)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio {
    self = [super init];
    if (self) {
        UIEdgeInsets insets = [CWImageManager shareIntance].option.cropFrameInsets;
        cropFrame.origin = CGPointMake(cropFrame.origin.x + insets.left - insets.right, cropFrame.origin.y + insets.top - insets.bottom);
        self.cropFrame = cropFrame;
        self.limitRatio = limitRatio;
        self.originalImage = originalImage;
        self.allowMinRatio = 1.0f;
        self.overlayAlpha = 0.5;
        self.scrollRatio = 0.11;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self initView];
    
    [self setupNavigationBar];
}


- (void)initView {
    
    [self initOldFrame];
    self.latestFrame = self.oldFrame;
    self.showImgView.frame = self.oldFrame;
    
    self.largeFrame = CGRectMake(0, 0, self.limitRatio * self.oldFrame.size.width, self.limitRatio * self.oldFrame.size.height);
    self.smallFrame = CGRectMake(0, 0, self.allowMinRatio * self.oldFrame.size.width, self.allowMinRatio * self.oldFrame.size.height);
    
    [self addGestureRecognizers];
    [self.view addSubview:self.showImgView];
    [self.view addSubview:self.overlayView];
    [self.view addSubview:self.ratioView];
    
//    [self.view addSubview:self.bottomView];
//    [self.view addSubview:self.cancelButton];
//    [self.view addSubview:self.confirmButton];

    [self overlayClipping];
}


- (void)overlayClipping
{
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, CGRectMake(0, 0,
                                        self.ratioView.frame.origin.x,
                                        self.overlayView.frame.size.height));
    CGPathAddRect(path, nil, CGRectMake(
                                        self.ratioView.frame.origin.x + self.ratioView.frame.size.width,
                                        0,
                                        self.overlayView.frame.size.width - self.ratioView.frame.origin.x - self.ratioView.frame.size.width,
                                        self.overlayView.frame.size.height));
    CGPathAddRect(path, nil, CGRectMake(0, 0,
                                        self.overlayView.frame.size.width,
                                        self.ratioView.frame.origin.y));
    CGPathAddRect(path, nil, CGRectMake(0,
                                        self.ratioView.frame.origin.y + self.ratioView.frame.size.height,
                                        self.overlayView.frame.size.width,
                                        self.overlayView.frame.size.height - self.ratioView.frame.origin.y + self.ratioView.frame.size.height));
    maskLayer.path = path;
    self.overlayView.layer.mask = maskLayer;
    CGPathRelease(path);
}

- (void)setupNavigationBar{
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithTitle:CWIPlocalString(@"CWIPStr_Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithTitle:CWIPlocalString(@"CWIPStr_Confirm") style:UIBarButtonItemStylePlain target:self action:@selector(confirm:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.navigationItem.rightBarButtonItem = rightItem;
}

// register all gestures
- (void) addGestureRecognizers
{
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
}

#pragma mark - target selector
//- (UINavigationBar *)
- (void)cancel:(id)sender {
    if ([self.delegate respondsToSelector:@selector(imageCropperDidCancel:)]) {
        [self.delegate imageCropperDidCancel:self];
    }
}

- (void)confirm:(id)sender {
    if ([self.delegate respondsToSelector:@selector(imageCropper:didFinished:)]) {
        [self.delegate imageCropper:self didFinished:[self getSubImage]];
    }
}

- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = self.showImgView;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
//        self.overlayView.alpha = 0.0;
        
        CGFloat scale = pinchGestureRecognizer.scale;
        view.transform = CGAffineTransformScale(view.transform, scale, scale);
        pinchGestureRecognizer.scale = 1;
    }
    else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
//        [self performSelector:@selector(delayChangeAlpha) withObject:self afterDelay:1];

        CGRect newFrame = self.showImgView.frame;
        newFrame = [self handleScaleOverflow:newFrame];
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:0.4 animations:^{
            self.showImgView.frame = newFrame;
            self.latestFrame = newFrame;
        }];
    }
}

- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = self.showImgView;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
//        self.overlayView.alpha = 0.0;
        // calculate accelerator
        CGFloat absCenterX = self.cropFrame.origin.x + self.cropFrame.size.width / 2;
        CGFloat absCenterY = self.cropFrame.origin.y + self.cropFrame.size.height / 2;
        CGFloat scaleRatio = self.showImgView.frame.size.width / self.cropFrame.size.width;
        CGFloat acceleratorX = 1 - ABS(absCenterX - view.center.x) / (scaleRatio * absCenterX);
        CGFloat acceleratorY = 1 - ABS(absCenterY - view.center.y) / (scaleRatio * absCenterY);
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x * acceleratorX, view.center.y + translation.y * acceleratorY}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
        
        
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
//        [self performSelector:@selector(delayChangeAlpha) withObject:self afterDelay:0.6];
        //移动速度
        CGPoint speed = [panGestureRecognizer velocityInView:self.view];
        CGFloat offSetX = speed.x * self.scrollRatio;
        CGFloat offSetY = speed.y * self.scrollRatio;
        
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
             CGPoint center = self.showImgView.center;
            center.x += offSetX;
            center.y += offSetY;
            _showImgView.center = center;
        } completion:nil];
        
        // bounce to original frame
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:0.3 animations:^{
            self.showImgView.frame = newFrame;
            self.latestFrame = newFrame;
        }];
     
    }
}

- (CGRect)handleScaleOverflow:(CGRect)newFrame {
    // bounce to original frame
    CGPoint oriCenter = CGPointMake(newFrame.origin.x + newFrame.size.width/2, newFrame.origin.y + newFrame.size.height/2);
    if (newFrame.size.width < self.oldFrame.size.width) {
        newFrame = self.oldFrame;
    }
    if (newFrame.size.width > self.largeFrame.size.width) {
        newFrame = self.largeFrame;
    }
    if (newFrame.size.width < self.smallFrame.size.width) {
        newFrame = self.smallFrame;
    }
    newFrame.origin.x = oriCenter.x - newFrame.size.width/2;
    newFrame.origin.y = oriCenter.y - newFrame.size.height/2;
    return newFrame;
}

- (CGRect)handleBorderOverflow:(CGRect)newFrame {
    // horizontally
    if (newFrame.origin.x > self.cropFrame.origin.x) newFrame.origin.x = self.cropFrame.origin.x;
    if (CGRectGetMaxX(newFrame) < self.cropFrame.size.width+self.cropFrame.origin.x) newFrame.origin.x = self.cropFrame.size.width+self.cropFrame.origin.x - newFrame.size.width;
    
    // vertically
    if (newFrame.origin.y > self.cropFrame.origin.y) newFrame.origin.y = self.cropFrame.origin.y;
    if (CGRectGetMaxY(newFrame) < self.cropFrame.origin.y + self.cropFrame.size.height) {
        newFrame.origin.y = self.cropFrame.origin.y + self.cropFrame.size.height - newFrame.size.height;
    }
    // adapt horizontally rectangle
    if (self.showImgView.frame.size.width > self.showImgView.frame.size.height && newFrame.size.height <= self.cropFrame.size.height) {
        newFrame.origin.y = self.cropFrame.origin.y + (self.cropFrame.size.height - newFrame.size.height) / 2;
    }
    return newFrame;
}

- (UIImage *)getSubImage{
    CGRect squareFrame = self.cropFrame;
    CGFloat scaleRatio = self.latestFrame.size.width / self.originalImage.size.width;
    CGFloat x = (squareFrame.origin.x - self.latestFrame.origin.x) / scaleRatio;
    CGFloat y = (squareFrame.origin.y - self.latestFrame.origin.y) / scaleRatio;
    CGFloat w = squareFrame.size.width / scaleRatio;
    CGFloat h = squareFrame.size.width / scaleRatio;
    if (self.latestFrame.size.width < self.cropFrame.size.width) {
        CGFloat newW = self.originalImage.size.width;
        CGFloat newH = newW * (self.cropFrame.size.height / self.cropFrame.size.width);
        x = 0; y = y + (h - newH) / 2;
        w = newH; h = newH;
    }
    if (self.latestFrame.size.height < self.cropFrame.size.height) {
        CGFloat newH = self.originalImage.size.height;
        CGFloat newW = newH * (self.cropFrame.size.width / self.cropFrame.size.height);
        x = x + (w - newW) / 2; y = 0;
        w = newH; h = newH;
    }
    CGRect myImageRect = CGRectMake(x, y, w, h);
    CGImageRef imageRef = self.originalImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
    CGSize size;
    size.width = myImageRect.size.width;
    size.height = myImageRect.size.height;
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myImageRect, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    return smallImage;
}

- (void)initOldFrame{
    CGFloat IW = self.showImgView.image.size.width;
    CGFloat IH = self.showImgView.image.size.height;
    CGFloat CW = CGRectGetWidth(self.view.frame);
    CGFloat CH = CGRectGetHeight(self.view.frame);
    CGFloat W,H;
    if (IW/IH > CW/CH) {
        W = CW;
        H = CW * IH / IW;
    }else{
        H = CH;
        W = CH * IW / IH;
    }
   CGRect imagerect = CGRectMake(0, self.view.center.y-H/2,W,H);
    CGFloat rate = CGRectGetHeight(imagerect)/CGRectGetWidth(imagerect);
    CGFloat cropH = CGRectGetHeight(self.cropFrame) * rate;
    CGFloat cropW = CGRectGetHeight(self.cropFrame) / rate;
    if (rate > 1) {
        _oldFrame = CGRectMake( CGRectGetMidX(self.cropFrame)-CGRectGetWidth(self.cropFrame)/2,CGRectGetMidY(self.cropFrame)-cropH/2, CGRectGetWidth(self.cropFrame), cropH);
    }else{
          _oldFrame = CGRectMake( CGRectGetMidX(self.cropFrame)-cropW/2,CGRectGetMidY(self.cropFrame)-CGRectGetHeight(self.cropFrame)/2, cropW, CGRectGetHeight(self.cropFrame));
    }
}

- (void)delayChangeAlpha{
    self.overlayView.alpha = self.overlayAlpha;
}
#pragma mark - getter


- (UIImageView * )showImgView{
    if (!_showImgView) {
        _showImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        [_showImgView setMultipleTouchEnabled:YES];
        [_showImgView setUserInteractionEnabled:YES];
        [_showImgView setImage:self.originalImage];
        [_showImgView setUserInteractionEnabled:YES];
        [_showImgView setMultipleTouchEnabled:YES];
    }
    return _showImgView;
}

- (UIView *)overlayView{
    if (!_overlayView) {
        _overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
        _overlayView.alpha = self.overlayAlpha;
        _overlayView.backgroundColor = [UIColor blackColor];
        _overlayView.userInteractionEnabled = NO;
        _overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return _overlayView;
}

- (UIView *)ratioView{
    if (!_ratioView) {
        if([self.delegate respondsToSelector:@selector(imageCropFrameView:)]){
            _ratioView = [self.delegate imageCropFrameView:self];
        }else{
            _ratioView = [[UIView alloc] initWithFrame:self.oldFrame];
        }
        _ratioView.frame = self.cropFrame;
        _ratioView.layer.borderColor = [UIColor whiteColor].CGColor;
        _ratioView.layer.borderWidth = 1;
        _ratioView.autoresizingMask = UIViewAutoresizingNone;
    
    }
    return _ratioView;
}

- (UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50.0f, 100, 50)];
        _cancelButton.backgroundColor = [UIColor blackColor];
        _cancelButton.titleLabel.textColor = [UIColor whiteColor];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [_cancelButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_cancelButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_cancelButton.titleLabel setNumberOfLines:0];
        [_cancelButton setTitleEdgeInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
        [_cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 100.0f, self.view.frame.size.height - 50.0f, 100, 50)];
        _confirmButton.backgroundColor = [UIColor blackColor];
        _confirmButton.titleLabel.textColor = [UIColor whiteColor];
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [_confirmButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        _confirmButton.titleLabel.textColor = [UIColor whiteColor];
        [_confirmButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_confirmButton.titleLabel setNumberOfLines:0];
        [_confirmButton setTitleEdgeInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
        [_confirmButton addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _confirmButton;
}

- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-50, CGRectGetWidth(self.view.frame), 50)];
        _bottomView.backgroundColor = [UIColor blackColor];
    }
    return _bottomView;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

- (void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}
@end
