//
//  KNBTransitionAnimation.h
//  KenuoTraining
//
//  Created by Robert on 16/4/3.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIViewControllerTransitioning.h>

typedef NS_ENUM(NSUInteger, KNBTransitionAnimationType) {
    KNBTransitionAnimationPush,
    KNBTransitionAnimationPop
};

@interface KNBTransitionAnimation : NSObject <UIViewControllerAnimatedTransitioning>

+ (KNBTransitionAnimation *)animationWithTransitionType:(KNBTransitionAnimationType)type FromView:(UIImageView *)fromView FromViewSuperView:(UIView *)superView ToView:(UIView *)toView;

@end
