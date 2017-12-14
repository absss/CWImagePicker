//
//  MainViewController.m
//  test
//
//  Created by hehaichi on 2017/11/24.
//  Copyright © 2017年 app. All rights reserved.
//

#import "MainViewController.h"
#import "CWImagePicker.h"

@interface MainViewController ()<CWIPImagePickerDelegate>

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2-30 ,CGRectGetHeight(self.view.frame)/2-30, 60, 60)];
    [self.view addSubview:imageView];
    imageView.backgroundColor= [UIColor grayColor];
    imageView.layer.cornerRadius = 30;
    imageView.layer.masksToBounds = YES;
    imageView.tag = 100;
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer * reg = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(action)];
    [imageView addGestureRecognizer:reg];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    
}

- (void)action{
    
    UIAlertController * ac = [UIAlertController alertControllerWithTitle:@"请选择方式" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
   
    UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        CWIPImagePickerOption * option = [[CWIPImagePickerOption alloc]init];
        //可裁剪
        option.needCrop = YES;
        option.sourceType = CWImagePickerControllerSourceTypeCamera;
        CWImagePickerViewController * picker = [[CWImagePickerViewController alloc]initWithOption: option];
        CWIPSystemImagePickViewController * picker2 = [[CWIPSystemImagePickViewController alloc]initWithOption: option];
        //设置代理
        picker2.cwDelegate = self;
        picker.cwDelegate = self;
        //弹出
        [self presentViewController:picker2 animated:YES completion:nil];
        
    }];
  
    UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"使用系统提供的相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        CWIPImagePickerOption * option = [[CWIPImagePickerOption alloc]init];
        //可裁剪
        option.needCrop = YES;
        option.sourceType = UIImagePickerControllerSourceTypeAlbum;
        CWIPSystemImagePickViewController * picker2 = [[CWIPSystemImagePickViewController alloc]initWithOption: option];
        //设置代理
        picker2.cwDelegate = self;
        //弹出
        [self presentViewController:picker2 animated:YES completion:nil];
        
    }];
    UIAlertAction * action3 = [UIAlertAction actionWithTitle:@"选择自定义相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        CWIPImagePickerOption * option = [[CWIPImagePickerOption alloc]init];
        //可裁剪
        option.needCrop = YES;
        option.sourceType = UIImagePickerControllerSourceTypeAlbum;
        CWImagePickerViewController * picker = [[CWImagePickerViewController alloc]initWithOption: option];
        //设置代理
        picker.cwDelegate = self;
        //弹出
        [self presentViewController:picker animated:YES completion:nil];
        
    }];
    UIAlertAction * action4 = [UIAlertAction actionWithTitle:@"选择多张图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        CWIPImagePickerOption * option = [[CWIPImagePickerOption alloc]init];
        //可裁剪
        option.needCrop = NO;
        option.isMultiPage = YES;
        option.sourceType = UIImagePickerControllerSourceTypeAlbum;
        CWImagePickerViewController * picker = [[CWImagePickerViewController alloc]initWithOption: option];
        //设置代理
        picker.cwDelegate = self;
        //弹出
        [self presentViewController:picker animated:YES completion:nil];
        
    }];
    
  
    UIAlertAction * action5 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [ac addAction:action1];
    [ac addAction:action2];
    [ac addAction:action3];
    [ac addAction:action4];
     [ac addAction:action5];
    
    [self presentViewController:ac animated:YES completion:nil];
    
    
    
   
}

#pragma mark - CWIPImagePickerDelegate
- (void)didSelectedCropImageWithImage:(UIImage *)image;{
    UIImageView  * imageView = (UIImageView *) [self.view viewWithTag:100];
    imageView.image = image;
}

- (void)cwNavigationBarForCWImagePicker:(UINavigationBar *)navigationBar{
     navigationBar.barTintColor = [UIColor colorWithWhite:0.1 alpha:1.0];
}

@end
