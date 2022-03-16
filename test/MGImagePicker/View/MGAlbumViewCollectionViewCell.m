//
//  MGAlbumViewCollectionViewCell.m
//  test
//
//  Created by hehaichi on 2022/3/16.
//  Copyright © 2022 app. All rights reserved.
//

#import "MGAlbumViewCollectionViewCell.h"
#import "MGImageOperateView.h"
#import "MGImagePickerHandler.h"

@interface MGAlbumViewCollectionViewCell()
@property(nonatomic,strong) UIImageView * imageView;
@property(nonatomic,strong) UILabel * numberLabel;
@property(nonatomic,strong) MGImageSelectButton * selectButton;
@end
@implementation MGAlbumViewCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.numberLabel];
        [self.contentView addSubview:self.selectButton];
        __weak typeof(self) weakSelf = self;
        self.selectButton.showCountButtonActionBlock = ^(MGImageSelectButton *sender) {
            [weakSelf selectAction:sender];
        };
        
    }
    return self;
}



#pragma mark - getter
- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]initWithFrame:self.contentView.frame];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (MGImageSelectButton *)selectButton{
    if (!_selectButton) {
        _selectButton = [[MGImageSelectButton alloc]initWithFrame:CGRectMake(CGRectGetMaxY(self.contentView.frame)-kMGThumbnailSelectdButtonLength, 0, kMGThumbnailSelectdButtonLength, kMGThumbnailSelectdButtonLength)];
        _selectButton.showCount = MGImagePickerHandler.shareIntance.option.isMultiPage;
        _selectButton.hidden = [MGImagePickerHandler shareIntance].option.needCrop;
     
    }
    return _selectButton;
}

- (UILabel *)numberLabel {
    if (!_numberLabel) {
        _numberLabel = [[UILabel alloc]init];
        _numberLabel.frame = CGRectMake(10, 0, kMGThumbnailSelectdButtonLength, kMGThumbnailSelectdButtonLength);
        _numberLabel.textColor = UIColor.redColor;
    }
    return _numberLabel;
}
#pragma mark - setter
- (void)setImageAsset:(MGAssetModel *)imageAsset{
    _imageAsset = imageAsset;
    _selectButton.selected = imageAsset.selected;
//    _numberLabel.text = [@(imageAsset.index) stringValue];
    if (imageAsset.selectedIndex > 0 &&  imageAsset.selected) {
        _selectButton.count = imageAsset.selectedIndex;
    } else {
        _selectButton.count = 0;
    }
    UIImage * image = [[MGImagePickerHandler shareIntance].cache objectForKey:imageAsset.asset.localIdentifier];
    if (image) {
        _imageView.image = image;
    }else{
        //把所有的缩略图都缓存起来也消耗不了多大内存(实测)，但是理论上会让滑动速度变快，关键是在大图不显示的时候，一定不能让它存在于内存中，一张小图也就几万像素，一张大图几百万像素，差了一万倍
        [MGImagePickerHandler thumbnailImageWithAsset:imageAsset size:_imageView.frame.size completion:^(UIImage *image,NSDictionary *info) {
            _imageView.image = image;
            [[MGImagePickerHandler shareIntance].cache setObject:image forKey:imageAsset.asset.localIdentifier];
        }];
        
    }
    
}

#pragma mark - target selector
- (void)selectAction:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(didSelectedImageWithAssetModel:sender:)]) {
        [self.delegate didSelectedImageWithAssetModel:self.imageAsset sender:sender];
    }
}

@end
