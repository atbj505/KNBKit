//
//  KNBRecorderPreviewController.m
//  KenuoTraining
//
//  Created by Robert on 16/3/4.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import "KNBRecorderPreviewController.h"
#import "KNBUserInfo.h"
#import "UIImage+Resize.h"
#import "KNBScaleImageView.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+VideoPreview.h"
#import <LLSimpleCamera/UIImage+fixOrientation.h>
#import <Masonry/Masonry.h>
#import "KNBPrecompile.h"

static const CGFloat KNBRecordPreviewImageWidth = 140;

@interface KNBRecorderPreviewController ()

@property (nonatomic, assign) KNBRecorderType   type;

@property (nonatomic, copy  ) NSString          *resourceName;

@property (nonatomic, strong) NSURL             *resourcepathUrl;

@property (nonatomic, strong) UIButton          *cancelButton;

@property (nonatomic, strong) UIButton          *confirmButton;

@property (nonatomic, strong) UIImage           *previewImage;

//视频相关
@property (nonatomic, strong) AVPlayer          *avPlayer;

@property (nonatomic, strong) AVPlayerLayer     *avPlayerLayer;

//照片相关
@property (nonatomic, strong) UIImage           *image;

@property (nonatomic, strong) KNBScaleImageView *imageView;

@end

@implementation KNBRecorderPreviewController

+ (KNBRecorderPreviewController *)PreviewWithType:(KNBRecorderType)type Name:(NSString *)name {
    KNBRecorderPreviewController *preViewVC = [[self alloc] initWithType:type Name:name];
    return preViewVC;
}

-(instancetype)initWithType:(KNBRecorderType)type Name:(NSString *)name {
    if (self = [super init]) {
        _type = type;
        _resourceName = name;
    }
    return self;
}

- (void)dealloc {
    KNB_REMOVE_NOTIFICATION(AVPlayerItemDidPlayToEndTimeNotification, self, nil);
}

- (void)attachToViewController:(UIViewController *)vc Frame:(CGRect)frame {
    [vc addChildViewController:self];
    self.view.frame = frame;
    [vc.view addSubview:self.view];
    [self didMoveToParentViewController:vc];
}

- (void)removeFromSuperViewcontroller {
    if (self.type == KNBRecorderPhoto) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didCancelPreview)]) {
            [self.delegate didCancelPreview];
        }
    }
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    if (_type == KNBRecorderPhoto) {
        //照片预览
        [self photoPreview];
    }else if (_type == KNBRecorderVideo) {
        //视频预览
        [self videoPreview];
    }
    
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.confirmButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_type == KNBRecorderVideo) {
        [self.avPlayer play];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - 视频预览
- (void)videoPreview {
    self.avPlayer = [AVPlayer playerWithURL:self.resourcepathUrl];
    
    self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    self.avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(playerItemDidReachEnd:)
//                                                 name:AVPlayerItemDidPlayToEndTimeNotification
//                                               object:[self.avPlayer currentItem]];
    
    KNB_ADD_NOTIFICATION(AVPlayerItemDidPlayToEndTimeNotification, self, @selector(playerItemDidReachEnd:), [self.avPlayer currentItem]);
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    self.avPlayerLayer.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
    [self.view.layer addSublayer:self.avPlayerLayer];
}


- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *item = [notification object];
    [item seekToTime:kCMTimeZero];
}

#pragma mark - 照片预览
- (void)photoPreview {
    [self.view addSubview:self.imageView];
    NSData *imageData = [NSData dataWithContentsOfURL:self.resourcepathUrl];
    UIImage *image = [UIImage imageWithData:imageData];
    self.image = image;
    self.imageView.image = self.image;
    self.imageView.needBlurView = YES;
}

#pragma mark - Target-Action
- (void)cancelButtonPressed:(UIButton *)button {
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtURL:self.resourcepathUrl error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    [self removeFromSuperViewcontroller];
}

- (void)confirmButtonPressed:(UIButton *)button {
    [self removeFromSuperViewcontroller];
    if (_delegate && [_delegate respondsToSelector:@selector(sendWithType:Name:PreviewImage:OriginImage:)]) {
        [self.delegate sendWithType:self.type Name:self.resourceName PreviewImage:self.previewImage OriginImage:self.image];
    }
}

#pragma mark - Getter
- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _cancelButton.tintColor = [UIColor whiteColor];
        _cancelButton.titleLabel.font = KNB_FONT_SIZE_DEFAULT(15);
        [_cancelButton setTitle:@"重拍" forState:UIControlStateNormal];
        _cancelButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        _cancelButton.layer.shadowColor = [UIColor blackColor].CGColor;
        _cancelButton.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        _cancelButton.layer.shadowOpacity = 0.4f;
        _cancelButton.layer.shadowRadius = 1.0f;
        [_cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _confirmButton.tintColor = [UIColor whiteColor];
        _confirmButton.titleLabel.font = KNB_FONT_SIZE_DEFAULT(15);
        [_confirmButton setTitle:@"使用" forState:UIControlStateNormal];
        _confirmButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        _confirmButton.layer.shadowColor = [UIColor blackColor].CGColor;
        _confirmButton.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        _confirmButton.layer.shadowOpacity = 0.4f;
        _confirmButton.layer.shadowRadius = 1.0f;
//        [_confirmButton sizeToFit];
        [_confirmButton addTarget:self action:@selector(confirmButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

- (NSURL *)resourcepathUrl {
    if (!_resourcepathUrl) {
        _resourcepathUrl = resourceAbsolutePath([KNBUserInfo shareInstance].userName, self.resourceName, self.type);
    }
    return _resourcepathUrl;
}

- (UIImage *)previewImage {
    if (!_previewImage) {
        if (_type == KNBRecorderVideo) {
            
            UIImage *imageFromUrl = [UIImage videoPreviewImage:self.resourcepathUrl];
            
            self.image = [imageFromUrl fixOrientation];
            
            CGSize resizeSize = CGSizeMake(KNBRecordPreviewImageWidth, KNBRecordPreviewImageWidth * self.image.size.height / self.image.size.width);
            
            _previewImage = [self.image resizedImage:resizeSize interpolationQuality:kCGInterpolationDefault];
            
        }else if (_type == KNBRecorderPhoto){
            
            CGSize resizeSize = CGSizeMake(KNBRecordPreviewImageWidth, KNBRecordPreviewImageWidth * self.image.size.height / self.image.size.width);
            
            UIImage *resizeImage = [self.image resizedImage:resizeSize interpolationQuality:kCGInterpolationDefault];
            _previewImage = resizeImage;
        }
    }
    return _previewImage;
}

- (KNBScaleImageView *)imageView {
    if (!_imageView) {
        _imageView = [[KNBScaleImageView alloc] initWithFrame:self.view.bounds];
    }
    return _imageView;
}

- (void)viewWillLayoutSubviews {
    KNB_WS(weakSelf);
    
    [self.cancelButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-10);
        make.left.mas_equalTo(weakSelf.view.mas_left).offset(10);
    }];
    
    [self.confirmButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-10);
        make.right.mas_equalTo(weakSelf.view.mas_right).offset(-10);
    }];
}

@end
