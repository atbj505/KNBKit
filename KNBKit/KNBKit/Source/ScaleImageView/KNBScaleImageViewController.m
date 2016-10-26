//
//  KNBScaleImageViewController.m
//  KenuoTraining
//
//  Created by Robert on 16/3/7.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import "KNBScaleImageViewController.h"
#import "KNBScaleImageCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "KNBTransitionAnimation.h"
#import "UIView+Frame.h"
#import <Masonry/Masonry.h>
#import "KNBPrecompile.h"
#import "KNBUtilExtend.h"

static NSString * const KNBPublishContentItemType = @"KNBPublishContentItemType";
static NSString * const KNBPublishContentItemName = @"KNBPublishContentItemName";
static NSString * const KNBPublishContentItemPreviewImage = @"KNBPublishContentItemPreviewImage";
static NSString * const KNBPublishContentItemOriginImage = @"KNBPublishContentItemOriginImage";

@interface KNBScaleImageViewController () <UICollectionViewDelegate, UICollectionViewDataSource, KNBScaleImageViewDelegate>

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) UILabel *pageLabel;

@property (nonatomic, strong) NSIndexPath *preIndexPath;

@end

@implementation KNBScaleImageViewController

- (instancetype)init {
    if (self = [super init]) {
        
        [self.view addSubview:self.imageBrowser];
        
        [self.view addSubview:self.pageLabel];
    }
    return self;
}

#pragma mark - Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor blackColor];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.enabled = false;
    self.pageLabel.text = [NSString stringWithFormat:@"%@ / %@",@(self.currentIndexPath.row + 1), @(self.imagesData.count)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.delegate = nil;
    self.navigationController.interactivePopGestureRecognizer.enabled = true;
}

#pragma mark - Private Method
- (void)viewWillLayoutSubviews {
    KNB_WS(weakSelf);
    
    [self.pageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-45);
        make.height.mas_equalTo(20);
        make.centerX.mas_equalTo(weakSelf.view.mas_centerX);
    }];
}

- (void)dismiss {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - KNBScaleImageViewDelegate
- (void)singleTapImage:(KNBScaleImageView *)imageView {
    [self dismiss];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imagesData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KNBScaleImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    self.preIndexPath = indexPath;
    
    if (!cell) {
        cell = [[KNBScaleImageCell alloc]initWithFrame:self.view.bounds];
    }
    
    id imageItem = self.imagesData[indexPath.row];
    
    cell.scaleImage.delegate = self;
    
    if ([imageItem isKindOfClass:[UIImage class]]) { //图片数据源
        cell.scaleImage.image = imageItem;
    }else if ([imageItem isKindOfClass:[NSString class]]){ //图片URL数据源
        cell.scaleImage.imageUrl = imageItem;
    }else if ([imageItem isKindOfClass:[NSDictionary class]]) { //字典数据源
        if ([imageItem[KNBPublishContentItemType] integerValue] == KNBRecorderVideo) {
            cell.scaleImage.videoName = imageItem[KNBPublishContentItemName];
        }else {
            cell.scaleImage.image = imageItem[KNBPublishContentItemOriginImage];
        }
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)index {
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    KNBScaleImageCell *scaleCell = (KNBScaleImageCell *)cell;
    [scaleCell.scaleImage restScale];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int itemIndex = (scrollView.contentOffset.x + self.imageBrowser.frame.size.width * 0.5) / self.imageBrowser.frame.size.width;
    if (!self.imagesData) return;
    int indexOnPageControl = itemIndex % self.imagesData.count;
    
    self.pageLabel.text = [NSString stringWithFormat:@"%d / %lu",indexOnPageControl+1,(unsigned long)self.imagesData.count];
}

#pragma mark - Getter && setter
- (void)setCurrentIndexPath:(NSIndexPath *)currentIndexPath {
    _currentIndexPath = currentIndexPath;
    if (self.currentIndexPath) {
        [_imageBrowser scrollToItemAtIndexPath:self.currentIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

- (UICollectionView *)imageBrowser {
    if (!_imageBrowser) {
        _imageBrowser = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) collectionViewLayout:self.flowLayout];
        _imageBrowser.backgroundColor = [UIColor clearColor];
        _imageBrowser.pagingEnabled = YES;
        _imageBrowser.scrollEnabled = YES;
        _imageBrowser.showsHorizontalScrollIndicator = NO;
        _imageBrowser.showsVerticalScrollIndicator = NO;
        [_imageBrowser registerClass:[KNBScaleImageCell class] forCellWithReuseIdentifier:@"Cell"];
        _imageBrowser.dataSource = self;
        _imageBrowser.delegate = self;
    }
    return _imageBrowser;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.itemSize = CGSizeMake(self.view.width, self.view.height);
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _flowLayout;
}

- (UILabel *)pageLabel {
    if (!_pageLabel) {
        _pageLabel = [[UILabel alloc] init];
        _pageLabel.font = KNB_FONT_SIZE_DEFAULT(12);
        _pageLabel.textColor = [UIColor whiteColor];
        _pageLabel.textAlignment = NSTextAlignmentCenter;
        _pageLabel.backgroundColor = [UIColor clearColor];
        _pageLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
        _pageLabel.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        _pageLabel.layer.shadowOpacity = 0.4f;
        _pageLabel.layer.shadowRadius = 1.0f;
    }
    return _pageLabel;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    
    UIImageView *fromView;
    UIView *toView;
    UIView *fromViewSuperView;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(scaleImageViewControllerFromView)] && [self.delegate respondsToSelector:@selector(scaleImageViewControllerToView)] && [self.delegate respondsToSelector:@selector(scaleImageViewControllerFromViewSuperView)]) {
        
        fromView = [self.delegate scaleImageViewControllerFromView];
        toView = [self.delegate scaleImageViewControllerToView];
        fromViewSuperView = [self.delegate scaleImageViewControllerFromViewSuperView];
        
    }else {
        return nil;
    }
    
    if (operation == UINavigationControllerOperationPush) {
        return [KNBTransitionAnimation animationWithTransitionType:KNBTransitionAnimationPush FromView:fromView FromViewSuperView:fromViewSuperView ToView:toView];
    }else {
        return [KNBTransitionAnimation animationWithTransitionType:KNBTransitionAnimationPop FromView:fromView FromViewSuperView:fromViewSuperView ToView:toView];
    }
}

@end
