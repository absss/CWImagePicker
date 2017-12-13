//
//  CWAlbumCategoryViewController.h
//  test
//
//  Created by hehaichi on 2017/11/28.
//  Copyright © 2017年 app. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWImageMarco.h"
#import "CWImageManager.h"

@interface CWAlbumCategoryViewController : UIViewController
@property(nonatomic,copy)NSArray <CWAlbumModel *> * albumArray;
- (void )loadAlbumDataWithCompleteBlock:(void(^)(NSArray *array))complete;
@end
