//
//  KNBFileReader.m
//  KenuoTraining
//
//  Created by Robert on 16/3/18.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import "KNBFileReaderController.h"
#import <NJKWebViewProgress/NJKWebViewProgress.h>
#import <NJKWebViewProgress/NJKWebViewProgressView.h>
#import "UIColor+Hex.h"
#import "UIImage+WaterMark.h"
#import "KNBUserInfo.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import "UIView+Frame.h"
#import "KNBPrecompile.h"
#import "KNBUtilExtend.h"

@interface KNBFileReaderController() <UIWebViewDelegate, NJKWebViewProgressDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

//@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) NJKWebViewProgress *progressProxy;

@property (nonatomic, strong) NJKWebViewProgressView *progressView;

@property (nonatomic, assign) CGFloat fileProgress;//观看文件进度

@property (nonatomic, strong) UIImageView *waterMarkImageView;

@property (nonatomic, assign) BOOL statusBarHidden;

@property (nonatomic, assign) CGFloat loadProgress;//加载进度

@end

@implementation KNBFileReaderController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.fileName;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
//    [self.view addSubview:self.backButton];
    [self.view addSubview:self.waterMarkImageView];
    [self addleftBarItemImageName:@"icon_return" sel:@selector(backToRoot)];
    [self addRightBarItemImageName:@"" sel:nil];
    self.progressProxy = [[NJKWebViewProgress alloc] init];
    self.webView.delegate = _progressProxy;
    self.progressProxy.webViewProxyDelegate = self;
    self.progressProxy.progressDelegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.webView.userInteractionEnabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (KNB_SYSTEM_VERSION >= 8.0) {
        self.navigationController.hidesBarsOnTap = YES;
        self.navigationController.hidesBarsOnSwipe = YES;
        [self.navigationController.barHideOnTapGestureRecognizer addTarget:self action:@selector(barHideOnTap)];
        [self.navigationController.barHideOnSwipeGestureRecognizer addTarget:self action:@selector(barHideOnSwipe)];
    }
    [self.view addSubview:self.progressView];
    
    if (self.fileUrl) {
        NSString *urlString = self.fileUrl;
        if (![urlString hasPrefix:@"http"]) {
            urlString = [NSString stringWithFormat:@"http://%@",self.fileUrl];
        }
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    }else if (self.filePath) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:self.filePath]]];
    }
}
//点击手势隐藏/显示导航栏
- (void)barHideOnTap {
    self.statusBarHidden = self.navigationController.navigationBarHidden;
    CGFloat originY = self.statusBarHidden ? 0 : 64;
    [UIView animateWithDuration:0.30 animations:^{
        self.progressView.frame = CGRectMake(0, originY, KNB_SCREEN_WIDTH, 3.0f);
    }];
    [self prefersStatusBarHidden];
    [self setNeedsStatusBarAppearanceUpdate];
}
//滑动手势隐藏导航栏方法
- (void)barHideOnSwipe {
    self.statusBarHidden = YES;
    [UIView animateWithDuration:0.30 animations:^{
        self.progressView.frame = CGRectMake(0, 0, KNB_SCREEN_WIDTH, 3.0f);
    }];
    [self prefersStatusBarHidden];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    if (self.webView.scrollView.contentSize.height <= self.view.height) {
//        self.fileProgress = 1.0f;
//    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(fileReader:fileProgress:)]) {
        [self.delegate fileReader:self fileProgress:self.fileProgress];
    }
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    if (self.navigationController) {
        self.navigationController.navigationBarHidden = NO;
    }
    [self.progressView removeFromSuperview];
}

- (void)backToRoot {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addRightBarItemImageName:(NSString *)imgName sel:(SEL)sel {
    NSArray *items = [self barButtonImageName:imgName sel:sel leftEdg:20];
    self.navigationItem.rightBarButtonItems = items;
}

- (void)addleftBarItemImageName:(NSString *)imgName sel:(SEL)sel {
    NSArray *items = [self barButtonImageName:imgName sel:sel leftEdg:-30];
    self.navigationItem.leftBarButtonItems = items;
}


- (NSArray *)barButtonImageName:(NSString *)imgName sel:(SEL)sel leftEdg:(CGFloat)edg{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 40, 44);
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0, edg, 0, 0)];
    [backBtn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [backBtn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    UIBarButtonItem *placeHolditem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    return @[item, placeHolditem];
}

#pragma mark - NJKWebViewProgressDelegate
- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress {
    [self.progressView setProgress:progress animated:NO];
    if (progress >= 1.0) {//加载出来后设置webview可滑动
        if (self.preFileProgress) {
            CGFloat contentOffsetY = self.preFileProgress * self.webView.scrollView.contentSize.height - self.view.height;
            CGPoint contentoffset = CGPointMake(0, contentOffsetY);
            [self.webView.scrollView setContentOffset:contentoffset animated:YES];
        }
        if (self.filePath) {//已下载
            self.webView.userInteractionEnabled = YES;
            return;
        }
        if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
            KNB_AlertlogError(@"当前无网络请稍后再试");
            self.webView.userInteractionEnabled = NO;
            return;
        }else {//有网络
            self.webView.userInteractionEnabled = YES;
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.fileProgress = (scrollView.contentOffset.y + self.view.height) / scrollView.contentSize.height;
    
}
//- (void)viewWillLayoutSubviews {
//    KNB_WS(weakSelf);
//    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(weakSelf.view.mas_left).offset(10);
//        make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-5);
//    }];
//}

#pragma mark - Getter
- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, KNB_SCREEN_WIDTH, KNB_SCREEN_HEIGHT)];
        _webView.scalesPageToFit = YES;
        _webView.scrollView.delegate = self;
    }
    return _webView;
}

//- (UIButton *)backButton {
//    if (!_backButton) {
//        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _backButton.titleLabel.font = KNB_FONT_SIZE_BOLD(16);
//        [_backButton setTitleColor:[UIColor colorWithHex:0xff5e84] forState:UIControlStateNormal];
//        [_backButton setTitle:@"返回" forState:UIControlStateNormal];
//        _backButton.layer.shadowColor = [UIColor blackColor].CGColor;
//        _backButton.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
//        _backButton.layer.shadowOpacity = 0.4f;
//        _backButton.layer.shadowRadius = 1.0f;
//        [_backButton sizeToFit];
//        [_backButton addTarget:self action:@selector(backToRoot) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _backButton;
//}

- (NJKWebViewProgressView *)progressView {
    if (!_progressView) {
        CGFloat progressBarHeight = 3.f;
        _progressView = [[NJKWebViewProgressView alloc] initWithFrame:CGRectMake(0, 64, KNB_SCREEN_WIDTH, progressBarHeight)];
        _progressView.progressBarView.backgroundColor = [UIColor colorWithHex:0xfe98b0];
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    return _progressView;
}

- (UIImageView *)waterMarkImageView {
    if (!_waterMarkImageView) {
        _waterMarkImageView = [[UIImageView alloc] initWithFrame:self.webView.frame];
        _waterMarkImageView.image = [UIImage imageWithText:[KNBUserInfo shareInstance].userName frame:_waterMarkImageView.frame];
    }
    return _waterMarkImageView;
}

@end
