//
//  MGImagePickerViewController.m
//  test
//
//  Created by hehaichi on 2017/11/28.
//  Copyright © 2017年 app. All rights reserved.
//

#import "MGImagePickerViewController.h"
#import "MGAlbumViewController.h"
#import "UIViewController+CWAlertView.h"
#import "MGImagePickerHandler.h"

@interface MGImagePickerViewController ()<UINavigationBarDelegate,UINavigationControllerDelegate>

@end

@implementation MGImagePickerViewController
- (instancetype)initWithOption:(MGImagePickerOption *)option{
    self = [super init];
    if (self) {
        _option = option;
        [MGImagePickerHandler shareIntance].option = option;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
        MGAlbumViewController *vc2 = [MGAlbumViewController new];
        [self setBackbarItemChinese:vc2];
        [self setCancelButton:vc2];
        [self setupNavigationBar];
        [self pushViewController:vc2 animated:YES];
        self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


- (void)setOption:(MGImagePickerOption *)option{
    _option = option;
    [MGImagePickerHandler shareIntance].option = option;
}

- (void)setupNavigationBar{
    //设置背景颜色
    [self.navigationBar setBackgroundImage:[MGImagePickerTool imageWithColor:MGDarkColor size:CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetMaxY(self.navigationBar.frame)) alpha:0.99] forBarMetrics:UIBarMetricsDefault];
    
    //设置导航栏返回按钮的颜色
    self.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18], NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [self setBackbarItemChinese:viewController];
}

- (void)setBackbarItemChinese:(UIViewController *)vc{
    UIBarButtonItem *backIetm = [[UIBarButtonItem alloc] init];
    backIetm.title = MGLocalString(@"MGStr_Back");
    vc.navigationItem.backBarButtonItem = backIetm;
}

- (void)setCancelButton:(UIViewController *)vc{
    UIBarButtonItem * item = [[UIBarButtonItem alloc]initWithTitle:MGLocalString(@"MGStr_Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    vc.navigationItem.leftBarButtonItem = item;
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
    [MGImagePickerHandler clearCache];
    MGImagePickerHandler.shareIntance.albumModelArray = nil;
    MGImagePickerHandler.shareIntance.currentAlbumModel = nil;
    [MGImagePickerHandler.shareIntance.selectedAssetModelArray removeAllObjects];;
    [super dismissViewControllerAnimated:flag completion:completion];
}

@end
