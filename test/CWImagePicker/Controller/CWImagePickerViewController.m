//
//  CWImagePickerViewController.m
//  test
//
//  Created by hehaichi on 2017/11/28.
//  Copyright © 2017年 app. All rights reserved.
//

#import "CWImagePickerViewController.h"
#import "CWAllImageViewController.h"
#import "CWAlbumCategoryViewController.h"
#import "UIViewController+CWAlertView.h"
@interface CWImagePickerViewController ()<UINavigationBarDelegate,UINavigationControllerDelegate>

@end

@implementation CWImagePickerViewController
- (instancetype)initWithOption:(CWIPImagePickerOption *)option{
    self = [super init];
    if (self) {
        _option = option;
        [CWImageManager shareIntance].option = option;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
        CWAlbumCategoryViewController * vc = [CWAlbumCategoryViewController new];
        CWAllImageViewController *vc2 = [CWAllImageViewController new];
        
        [self setBackbarItemChinese:vc];
        [self setBackbarItemChinese:vc2];
        [self setCancelButton:vc];
        [self setCancelButton:vc2];
    
        [self setupNavigationBar];
        if ([self.cwDelegate respondsToSelector:@selector(cwNavigationBarForCWImagePicker:)]) {
            [self.cwDelegate cwNavigationBarForCWImagePicker:self.navigationBar];
        }
        
        [self pushViewController:vc animated:YES];
        [self pushViewController:vc2 animated:YES];
        [vc2 loadAllImageData];
        self.delegate = self;
   
    
}

- (void)setOption:(CWIPImagePickerOption *)option{
    _option = option;
    [CWImageManager shareIntance].option = option;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)setupNavigationBar{
    //设置背景颜色
    [self.navigationBar setBackgroundImage:[CWIPTool imageWithColor:CWIPDarkColor size:CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetMaxY(self.navigationBar.frame)) alpha:0.85] forBarMetrics:UIBarMetricsDefault];
    
    //设置导航栏返回按钮的颜色
    self.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    UIBarButtonItem * item = [[UIBarButtonItem alloc]initWithTitle:CWIPlocalString(@"CWIPStr_Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [self setBackbarItemChinese:viewController];
}

- (void)setBackbarItemChinese:(UIViewController *)vc{
    UIBarButtonItem *backIetm = [[UIBarButtonItem alloc] init];
    backIetm.title = CWIPlocalString(@"CWIPStr_Back");
    vc.navigationItem.backBarButtonItem = backIetm;
}

- (void)setCancelButton:(UIViewController *)vc{
    UIBarButtonItem * item = [[UIBarButtonItem alloc]initWithTitle:CWIPlocalString(@"CWIPStr_Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    vc.navigationItem.rightBarButtonItem = item;
}

#pragma mark - target selector
- (void)cancelAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc{
    NSLog(@"%s",__func__);
}
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion{
    //清空缓存
    [CWImageManager clearCache];
    [super dismissViewControllerAnimated:flag completion:completion];
}

@end
