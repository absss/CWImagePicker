//
//  CWIPBaseCollectionViewController.m
//  test
//
//  Created by hehaichi on 2017/12/1.
//  Copyright © 2017年 app. All rights reserved.
//

#import "CWIPBaseCollectionViewController.h"


@interface CWIPBaseCollectionViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@end

@implementation CWIPBaseCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.itemSize = CGSizeMake(CWIPScreenWidth, CWIPScreenHeight);
        if (!self.navigationController.isNavigationBarHidden) {
            flowLayout.sectionInset = UIEdgeInsetsMake(-64, 0, 0, 0);
        }else{
            flowLayout.sectionInset = UIEdgeInsetsMake(-20, 0, 0, 0);
        }
        
        _collectionView = [[UICollectionView alloc]initWithFrame: CGRectMake(0, 0, CWIPScreenWidth,CWIPScreenHeight) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor blackColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:NSClassFromString(self.reuseId) forCellWithReuseIdentifier:self.reuseId];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = NO;
        _collectionView.alwaysBounceHorizontal = NO;
        _collectionView.bounces = NO;
     
        
    }
    return _collectionView;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.reuseId forIndexPath:indexPath];
    return cell;
    
}


@end
