//
//  KNBTransitionAnimation.m
//  KenuoTraining
//
//  Created by Robert on 16/4/3.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import "KNBTransitionAnimation.h"
#import "KNBScaleImageViewController.h"
#import "UIImage+fixOrientation.h"

@interface KNBTransitionAnimation ()

@property (nonatomic, assign) KNBTransitionAnimationType type;

@property (nonatomic, strong) UIImageView *fromView;

@property (nonatomic, strong) UIView *fromViewSuperView;

@property (nonatomic, strong) UIView *toView;

@end

@implementation KNBTransitionAnimation

+ (KNBTransitionAnimation *)animationWithTransitionType:(KNBTransitionAnimationType)type FromView:(UIImageView *)fromView FromViewSuperView:(UIView *)superView ToView:(UIView *)toView {
    KNBTransitionAnimation *animation = [[KNBTransitionAnimation alloc] initWithTransitionType:type FromView:fromView FromViewSuperView:superView ToView:toView];
    return animation;
}

- (instancetype)initWithTransitionType:(KNBTransitionAnimationType)type FromView:(UIImageView *)fromView FromViewSuperView:(UIView *)superView ToView:(UIView *)toView{
    if (self = [super init]) {
        self.type = type;
        self.fromView = fromView;
        self.toView = toView;
        self.fromViewSuperView = superView;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.5f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.type == KNBTransitionAnimationPush) {
        [self pushAnimationWithContext:transitionContext];
    }else if (self.type == KNBTransitionAnimationPop) {
        [self popAnimationWithContext:transitionContext];
    }
}

- (void)pushAnimationWithContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *containerView = [transitionContext containerView];
    
    UIImageView *tempView = [[UIImageView alloc] initWithFrame:self.fromView.frame];
    tempView.image = [self.fromView.image fixOrientation];
    tempView.contentMode = UIViewContentModeScaleAspectFit;
    
    tempView.frame = [self.fromView convertRect:self.fromView.bounds toView: containerView];
    
    self.fromView.hidden = YES;
    self.toView.superview.alpha = 0;
    self.toView.hidden = YES;
    
    [containerView addSubview:self.toView.superview];
    [containerView addSubview:tempView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 usingSpringWithDamping:1 initialSpringVelocity:1 / 0.55 options:0 animations:^{
        tempView.frame = [self.toView convertRect:self.toView.bounds toView:containerView];
        self.toView.superview.alpha = 1;
    } completion:^(BOOL finished) {
        tempView.hidden = YES;
        self.toView.hidden = NO;
        [transitionContext completeTransition:YES];
    }];
}

- (void)popAnimationWithContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *containerView = [transitionContext containerView];
    UIView *tempView = containerView.subviews.lastObject;
    
    self.fromView.hidden = YES;
    self.toView.hidden = YES;
    tempView.hidden = NO;
    
    [containerView insertSubview:self.fromViewSuperView atIndex:0];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 usingSpringWithDamping:1 initialSpringVelocity:1 / 0.55 options:0 animations:^{
        tempView.frame = [self.fromView convertRect:self.fromView.bounds toView:containerView];
        self.toView.superview.alpha = 0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
        self.fromView.hidden = NO;
        [tempView removeFromSuperview];
    }];
}

@end
