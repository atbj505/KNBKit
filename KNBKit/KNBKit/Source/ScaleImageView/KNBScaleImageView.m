//
//  KNBScaleImageView.m
//  KenuoTraining
//
//  Created by Robert on 16/3/4.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import "KNBScaleImageView.h"
#import <AVFoundation/AVFoundation.h>
#import "KNBUserInfo.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSString+Contain.h"
#import <LCProgressHUD/LCProgressHUD.h>
#import <Masonry/Masonry.h>
#import "UIView+Frame.h"

static const CGFloat KNBMinimumZoomScale = 0.5;

static const CGFloat KNBMaximumZoomScale = 3.0;

@interface KNBScaleImageView () <UIScrollViewDelegate>

/**
 *  放大缩小图片用
 */
@property (nonatomic, strong) UIScrollView *scrollView;

/**
 *  显示图片用
 */
@property (nonatomic, strong) UIImageView *imageView;

/**
 *  遮挡视图
 */
@property (nonatomic, strong) UIView *blurView;

/**
 *  重新加载按钮
 */
@property (nonatomic, strong) UIButton *reloadButton;

/**
 *  保存图片用
 */
@property (nonatomic, strong) UIButton *saveButton;

/**
 *  视频播放用
 */
@property (nonatomic, strong) AVPlayer *avPlayer;

@property (nonatomic, strong) AVPlayerLayer *avPlayerLayer;

@end

@implementation KNBScaleImageView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.scrollView];
        [self addSubview:self.blurView];
        [self addSubview:self.saveButton];
    }
    return self;
}

-(void)dealloc {
    KNB_REMOVE_NOTIFICATION(AVPlayerItemDidPlayToEndTimeNotification, self, nil);
}

- (void)restScale {
    [self.scrollView setZoomScale:1.0];
}

#pragma mark - Masonry
+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    KNB_WS(weakSelf);
    
    [self.blurView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.and.left.and.right.mas_equalTo(weakSelf);
        make.height.mas_equalTo(49);
    }];
    
    [_saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.mas_bottom).offset(-10);
        make.centerX.mas_equalTo(weakSelf.mas_centerX);
        make.width.mas_equalTo(45);
        make.height.mas_equalTo(30);
    }];
    
    [super updateConstraints];
}

#pragma mark - Action
- (void)saveImage:(UIButton *)btn {
    if (_scrollView.zoomScale != 1.0) {
        [self.scrollView zoomToRect:self.bounds animated:YES];
    }
    UIImageWriteToSavedPhotosAlbum(self.imageView.image, nil, nil, nil);
    KNB_PerformOnMainThread(^{
        [LCProgressHUD showSuccess:@"保存成功"];
    });
}

- (void)playVideo {
    KNB_ADD_NOTIFICATION(AVPlayerItemDidPlayToEndTimeNotification, self, @selector(playerItemDidReachEnd:), [self.avPlayer currentItem]);
    [self.layer addSublayer:self.avPlayerLayer];
    [self.avPlayer play];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *item = [notification object];
    [item seekToTime:kCMTimeZero];
}

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (_scrollView.zoomScale == 1.0) {
        CGPoint point = [tap locationInView:self];
        
        CGFloat zoomWidth = self.width / KNBMaximumZoomScale;
        CGFloat zoomHeight = self.height / KNBMaximumZoomScale;
        
        [self.scrollView zoomToRect:CGRectMake(point.x - zoomWidth / 2, point.y - zoomHeight / 2, zoomWidth, zoomHeight) animated:YES];
        
    }else {
        [self.scrollView zoomToRect:self.bounds animated:YES];
    }
    
}

- (void)dismiss {
    if (self.delegate && [self.delegate respondsToSelector:@selector(singleTapImage:)]) {
        [self.delegate singleTapImage:self];
    }
}

- (void)reloadImage {
    [self showImageWithUrl:[NSURL URLWithString:self.imageUrl]];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setScrollViewContentInset];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale {
    [scrollView setZoomScale:scale animated:NO];
}

#pragma mark - Private Method
- (void)setScrollViewContentInset {
    CGSize imageViewSize = self.imageView.size;
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    CGFloat verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0;
    CGFloat horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0;
    
    self.scrollView.contentInset = UIEdgeInsetsMake(verticalPadding, horizontalPadding, verticalPadding, horizontalPadding);
}

- (void)showImageWithUrl:(NSURL *)url {
    [self.reloadButton removeFromSuperview];
    
    KNB_WS(weakSelf);
    [self.imageView sd_setImageWithURL:url placeholderImage:nil options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize) {

    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.saveButton.hidden = NO;
            });
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = nil;
                [self addSubview:self.reloadButton];
            });
        }
    }];
}

#pragma mark - Setter && Getter
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.backgroundColor = [UIColor blackColor];
        _scrollView.minimumZoomScale = KNBMinimumZoomScale;
        _scrollView.maximumZoomScale = KNBMaximumZoomScale;
        _scrollView.delegate = self;
        [_scrollView addSubview:self.imageView];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [_scrollView addGestureRecognizer:doubleTap];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        tap.numberOfTapsRequired = 1;
        [_scrollView addGestureRecognizer:tap];
        
        [tap requireGestureRecognizerToFail:doubleTap];
    }
    return _scrollView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.image = self.image;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = YES;
    }
    return _imageView;
}

-(UIButton *)reloadButton {
    if (!_reloadButton) {
        _reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _reloadButton.backgroundColor = [UIColor clearColor];
        _reloadButton.titleLabel.font = KNB_FONT_SIZE_BOLD(15);
        [_reloadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_reloadButton setTitle:@"图片加载失败请点击重试" forState:UIControlStateNormal];
        [_reloadButton addTarget:self action:@selector(reloadImage) forControlEvents:UIControlEventTouchUpInside];
        [_reloadButton sizeToFit];
        _reloadButton.center = self.center;
    }
    return _reloadButton;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [[UIButton alloc] init];
        _saveButton.backgroundColor = [UIColor blackColor];
        _saveButton.titleLabel.font = KNB_FONT_SIZE_DEFAULT(14);
        _saveButton.layer.cornerRadius = 5;
        _saveButton.layer.borderWidth = 0.2;
        _saveButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _saveButton.layer.masksToBounds = YES;
        _saveButton.layer.shouldRasterize = YES;
        _saveButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [_saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_saveButton setTitle:@"保存" forState:UIControlStateNormal];
        [_saveButton addTarget:self action:@selector(saveImage:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

- (UIView *)blurView {
    if (!_blurView) {
        _blurView = [[UIView alloc] init];
        _blurView.backgroundColor = [UIColor blackColor];
        _blurView.alpha = 0.5f;
        _blurView.hidden = YES;
    }
    return _blurView;
}

- (AVPlayer *)avPlayer {
    if (!_avPlayer) {
        if ([self.videoName startsWith:@"file"]) {
            _avPlayer = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:self.videoName]];
        }else {
            _avPlayer = [[AVPlayer alloc] initWithURL:resourceAbsolutePath([KNBUserInfo shareInstance].userName, self.videoName, KNBRecorderVideo)];
        }
        _avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    }
    return _avPlayer;
}

- (AVPlayerLayer *)avPlayerLayer {
    if (!_avPlayerLayer) {
        _avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
        _avPlayerLayer.frame = KNB_SCREEN_BOUNDS;
    }
    return _avPlayerLayer;
}

- (void)setVideoName:(NSString *)videoName {
    _videoName = videoName;
    [self playVideo];
    self.saveButton.hidden = YES;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    self.imageView.image = image;
}

- (void)setImageUrl:(NSString *)imageUrl {
    _imageUrl = imageUrl;
    self.saveButton.hidden = YES;
    [self showImageWithUrl:[NSURL URLWithString:imageUrl]];
}

- (void)setNeedBlurView:(bool)needBlurView {
    _needBlurView = needBlurView;
    self.blurView.hidden = !needBlurView;
}

@end
