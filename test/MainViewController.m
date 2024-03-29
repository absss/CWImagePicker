//
//  MainViewController.m
//  test
//
//  Created by hehaichi on 2017/11/24.
//  Copyright © 2017年 app. All rights reserved.
//

#import "MainViewController.h"
#import "MGImagePicker.h"

@interface MainViewController ()<MGImagePickerDelegate>

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
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    UITapGestureRecognizer * reg = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(action)];
    [imageView addGestureRecognizer:reg];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    
}

- (void)action{
    
    UIAlertController * ac = [UIAlertController alertControllerWithTitle:@"请选择方式" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
   
    
    UIAlertAction * action3 = [UIAlertAction actionWithTitle:@"选择单张图片并裁剪" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MGImagePickerOption * option = [[MGImagePickerOption alloc]init];
        //可裁剪
        option.needCrop = YES;
        option.sourceType = UIImagePickerControllerSourceTypeAlbum;
        MGImagePickerViewController * picker = [[MGImagePickerViewController alloc]initWithOption: option];
        //设置代理
        picker.pickerDelegate = self;
        //弹出
        [self presentViewController:picker animated:YES completion:nil];
        
    }];
    UIAlertAction * action31 = [UIAlertAction actionWithTitle:@"选择单张图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MGImagePickerOption * option = [[MGImagePickerOption alloc]init];
        //可裁剪
        option.needCrop = NO;
        option.isMultiPage = YES;
        option.sourceType = UIImagePickerControllerSourceTypeAlbum;
        MGImagePickerViewController * picker = [[MGImagePickerViewController alloc]initWithOption: option];
        //设置代理
        picker.pickerDelegate = self;
        //弹出
        [self presentViewController:picker animated:YES completion:nil];
        
    }];
    UIAlertAction * action4 = [UIAlertAction actionWithTitle:@"选择多张图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MGImagePickerOption * option = [[MGImagePickerOption alloc]init];
        //可裁剪
        option.needCrop = NO;
        option.isMultiPage = YES;
        option.sourceType = UIImagePickerControllerSourceTypeAlbum;
        MGImagePickerViewController * picker = [[MGImagePickerViewController alloc]initWithOption: option];
        //设置代理
        picker.pickerDelegate = self;
        //弹出
        
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:picker animated:YES completion:nil];
        
    }];
    
  
    UIAlertAction * action5 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [ac addAction:action3];
    [ac addAction:action31];
    [ac addAction:action4];
     [ac addAction:action5];
    
    

    [self presentViewController:ac animated:YES completion:nil];
    

    
   
}

#pragma mark - MGImagePickerDelegate
- (void)controller:(UIViewController *)controller didSelectedCropImageWithImage:(UIImage *)image;{
    UIImageView  * imageView = (UIImageView *) [self.view viewWithTag:100];
    imageView.image = image;
}

- (void)cwNavigationBarForMGImagePicker:(UINavigationBar *)navigationBar{
     navigationBar.barTintColor = [UIColor colorWithWhite:0.1 alpha:1.0];
}

//- (void)controller:(UIViewController *)controller didSelectedImageArrayWithThumbnailImageArray:(NSArray *)thumbnailArray withAssetArray:(NSArray <MGAssetModel *> *)array{
//    MGAssetModel * asset = array.firstObject;
//    
//    if (asset) {
//         UIImageView  * imageView1 = (UIImageView *) [self.view viewWithTag:100];
//        CGFloat scale = [UIScreen mainScreen].scale;
//        [MGImagePickerHandler thumbnailImageWithAsset:asset size:CGSizeMake(CGRectGetWidth(imageView1.frame) *scale, CGRectGetHeight(imageView1.frame)*scale) completion:^(UIImage *image, NSDictionary *info) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                imageView1.image = image;
//            });
//        }];
//    }
//}

@end
