//
//  MGAlbumsView.h
//  test
//
//  Created by hehaichi on 2022/3/15.
//  Copyright © 2022 app. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MGAlbumModel;
NS_ASSUME_NONNULL_BEGIN

@interface MGAlbumCategoryView : UIView
@property(nonatomic,strong)NSArray *albumArray; // 可供选择的相册集
@property (nonatomic, copy) void(^didSelectAlbumBlock)(MGAlbumModel *model);
@end

NS_ASSUME_NONNULL_END
