//
//  MGAlbumCategoryView.m
//  test
//
//  Created by hehaichi on 2022/3/15.
//  Copyright © 2022 app. All rights reserved.
//

#import "MGAlbumCategoryView.h"
#import "MGAlbumModel.h"
#import "MGImagePickerHandler.h"


@interface MGAlbumCategoryTableViewCell:UITableViewCell
@property(nonatomic,strong)UIImageView * thumbnailImageView;
@property(nonatomic,strong)UILabel * albumTitleLabel;
@property(nonatomic,strong)UIView * sepLine;
@property(nonatomic,strong)MGAlbumModel * albumModel;
@property(nonatomic,assign)NSInteger count;
@end
@implementation MGAlbumCategoryTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        _count = 0;
        [self.contentView addSubview:self.thumbnailImageView];
        [self.contentView addSubview:self.albumTitleLabel];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self.contentView addSubview:self.sepLine];
        
    }
    return self;
        
        
}
- (void)setAlbumModel:(MGAlbumModel *)albumModel{
    _albumModel = albumModel;
    NSArray * albumArr = [MGImagePickerHandler assetsWithAlbum:albumModel];
    NSInteger count = albumArr.count;
    _count = count;
    NSString * title = albumModel.assetCollection.localizedTitle;
    CGFloat scale = [UIScreen mainScreen].scale;
    if (count>0) {
            [MGImagePickerHandler thumbnailImageWithAsset:albumArr.lastObject size:CGSizeMake(CGRectGetHeight(self.frame)*scale, CGRectGetHeight(self.frame)*scale) completion:^(UIImage *image, NSDictionary *info) {
                self.thumbnailImageView.image = image;
            }];

    }else{
        self.thumbnailImageView.image = [UIImage imageNamed:@"CWIPResource.bundle/placeholder.png"];
    }
    
    NSString * str = [NSString stringWithFormat:@"%@(%ld)",title,count];
    NSMutableAttributedString * mutAtt = [[NSMutableAttributedString alloc]initWithString:str];
    NSInteger number = [@(count)stringValue].length+2;
    [mutAtt addAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor],NSFontAttributeName:[UIFont systemFontOfSize:13]} range:NSMakeRange(str.length-number, number)];
    _albumTitleLabel.attributedText = mutAtt;
    
}

- (UILabel *)albumTitleLabel{
    if (!_albumTitleLabel) {
        _albumTitleLabel = [[UILabel alloc]init];
        _albumTitleLabel.font = [UIFont systemFontOfSize:14];
        
    }
    return _albumTitleLabel;
}

- (UIImageView *)thumbnailImageView{
    if (!_thumbnailImageView) {
        _thumbnailImageView = [[UIImageView alloc]init];
        _thumbnailImageView.backgroundColor = [UIColor whiteColor];
        _thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnailImageView.clipsToBounds = YES;
        
    }
    return _thumbnailImageView;
}

- (UIView *)sepLine{
    if (!_sepLine) {
        _sepLine = [UIView new];
        _sepLine.backgroundColor = [UIColor lightGrayColor];
        _sepLine.alpha = 0.5;
    }
    return _sepLine;
}
- (void)layoutSubviews{
    CGFloat w = CGRectGetHeight(self.frame);
    self.albumTitleLabel.frame = CGRectMake(w+15, 1, CGRectGetWidth(self.contentView.frame) -w -20, w-2);
    if (_count > 0) {
        self.thumbnailImageView.frame = CGRectMake(0,0, w, w);
    }else{
        self.thumbnailImageView.frame = CGRectMake(5,5, w-10, w-10);
    }
    
    self.sepLine.frame = CGRectMake(0, w-0.5, CGRectGetWidth(self.frame), 0.5);
}
@end

@interface MGAlbumCategoryView()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView * tableView;
@end

@implementation MGAlbumCategoryView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.tableView];
    }
    return self;
}
static NSString * reuseId = @"MGAlbumCategoryTableViewCell";
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.frame style:UITableViewStyleGrouped];

        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.estimatedSectionHeaderHeight = 0.01;
        _tableView.estimatedSectionFooterHeight = 0.01;
        [_tableView registerClass:[MGAlbumCategoryTableViewCell class] forCellReuseIdentifier:reuseId];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.tableView.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
}

- (void)setAlbumArray:(NSArray *)albumArray {
    _albumArray = albumArray;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.albumArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MGAlbumCategoryTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
        cell= [[MGAlbumCategoryTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    cell.albumModel = self.albumArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.albumArray.count) {
        if (self.didSelectAlbumBlock) {
            self.didSelectAlbumBlock(self.albumArray[indexPath.row]);
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end

