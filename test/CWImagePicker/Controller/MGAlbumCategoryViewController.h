//
//  MGAlbumCategoryViewController.h
//  test
//
//  Created by hehaichi on 2017/11/28.
//  Copyright © 2017年 app. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGImageMarco.h"
#import "MGImagePickerHandler.h"

@interface MGAlbumCategoryViewController : UIViewController
@property(nonatomic,copy)NSArray <MGAlbumModel *> * albumArray;
- (void )loadAlbumDatacompletion:(void(^)(NSArray *array))complete;
@end
