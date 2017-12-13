//
//  CWIPImagePickerOption.m
//  test
//
//  Created by hehaichi on 2017/12/5.
//  Copyright © 2017年 app. All rights reserved.
//

#import "CWIPImagePickerOption.h"

@implementation CWIPImagePickerOption
- (instancetype)init{
    self = [super init];
    if (self) {
        _maxAllowCount = 9;
        _needCrop = YES;
        _isMultiPage = YES;
        CGFloat w =  CWIPScreenWidth * 0.87;
        _cropFrameSize = CGSizeMake(w, w);
        _allowMaxZoomScale = 4;
        _sourceType = UIImagePickerControllerSourceTypeAlbum;
        
    }
    return self;
}
@end
