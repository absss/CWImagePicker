//
//  CWAlbumCategoryViewController.m
//  test
//
//  Created by hehaichi on 2017/11/28.
//  Copyright © 2017年 app. All rights reserved.
//

#import "CWAlbumCategoryViewController.h"
#import "CWAllImageViewController.h"

@interface CWAlbumCategoryTableViewCell:UITableViewCell
@property(nonatomic,strong)UIImageView * thumbnailImageView;
@property(nonatomic,strong)UILabel * albumTitleLabel;
@property(nonatomic,strong)UIView * sepLine;
@property(nonatomic,strong)CWAlbumModel * albumModel;
@end
@implementation CWAlbumCategoryTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self.contentView addSubview:self.thumbnailImageView];
        [self.contentView addSubview:self.albumTitleLabel];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self.contentView addSubview:self.sepLine];
        
    }
    return self;
        
        
}
- (void)setAlbumModel:(CWAlbumModel *)albumModel{
    _albumModel = albumModel;
    NSArray * albumArr = [CWImageManager assetsWithAlbumCollection:albumModel];
    NSInteger count = albumArr.count;
    NSString * title = albumModel.assetCollection.localizedTitle;
    if (count>0) {
            [CWImageManager thumbnailImageWithAsset:albumArr.lastObject withImageSize:CGSizeMake(CGRectGetHeight(self.frame), CGRectGetHeight(self.frame)) withCompleteBlock:^(UIImage *image, NSDictionary *info) {
                self.thumbnailImageView.image = image;
            }];

    }else{
        self.thumbnailImageView.image = [UIImage imageNamed:@"CWIPResource.bundle/thumbnailImage.png"];
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
        _thumbnailImageView.backgroundColor = CWIPRandomColor;
        
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
    self.thumbnailImageView.frame = CGRectMake(0,0, w, w);
    self.sepLine.frame = CGRectMake(0, w-0.5, CGRectGetWidth(self.frame), 0.5);
}
@end

@interface CWAlbumCategoryViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView * tableView;
@end

@implementation CWAlbumCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = CWIPlocalString(@"CWIPStr_Phonos");
     [self.view addSubview:self.tableView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //if nil ,load data
    if (!(self.albumArray.count > 0)) {
        [self loadAlbumDataWithCompleteBlock:^(NSArray *array) {
            self.albumArray = array;
            [self.tableView reloadData];
        }];
    }
}

#pragma mark - private method
- (void)loadAlbumDataWithCompleteBlock:(void (^)(NSArray *))complete{
    [CWImageManager getAllAlbumArray:^(NSArray<CWAlbumModel *> *array) {
        if (complete) {
            complete(array);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CWAllImageViewController * vc = [CWAllImageViewController new];
    
    [self.navigationController pushViewController:vc animated:YES];
}

static NSString * reuseId = @"CWAlbumCategoryTableViewCell";
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.estimatedSectionHeaderHeight = 0.01;
        _tableView.estimatedSectionFooterHeight = 0.01;
        [_tableView registerClass:[CWAlbumCategoryTableViewCell class] forCellReuseIdentifier:reuseId];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.albumArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CWAlbumCategoryTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
        cell= [[CWAlbumCategoryTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
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
    CWAllImageViewController * vc2 = [CWAllImageViewController new];
    vc2.albumModel = self.albumArray[indexPath.row];
    [self.navigationController pushViewController:vc2 animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
