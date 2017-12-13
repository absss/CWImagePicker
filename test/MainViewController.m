//
//  MainViewController.m
//  test
//
//  Created by hehaichi on 2017/11/24.
//  Copyright © 2017年 app. All rights reserved.
//

#import "MainViewController.h"
#import "HCPopTransition.h"
#import "HCBasePopViewController.h"
@interface MainViewController ()<UIViewControllerTransitioningDelegate>

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.transitioningDelegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    HCBasePopViewController * vc =  [HCBasePopViewController new];
    vc.transitioningDelegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return [HCPopTransition new];
}

//- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
//    
//}
@end
