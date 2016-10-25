//
//  LLSimpleCamera+FocusBox.m
//  KenuoTraining
//
//  Created by Robert on 16/3/4.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import "LLSimpleCamera+FocusBox.h"
#import "UIColor+Hex.h"

@implementation LLSimpleCamera (FocusBox)

- (void)KNB_addDefaultFocusBox {
//    CALayer *focusBox = [[CALayer alloc] init];
//    focusBox.cornerRadius = 5.0f;
//    focusBox.bounds = CGRectMake(0.0f, 0.0f, 98, 98);
//    focusBox.borderWidth = 3.0f;
//    focusBox.borderColor = [[UIColor colorWithHex:0xff5e84] CGColor];
//    focusBox.opacity = 0.0f;
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 98, 98)];
    image.image = [UIImage imageNamed:@"camera-focus"];
    image.layer.opacity = 0.0f;
    [self.view.layer addSublayer:image.layer];
    
    CABasicAnimation *focusBoxAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    focusBoxAnimation.duration = 0.75;
    focusBoxAnimation.autoreverses = NO;
    focusBoxAnimation.repeatCount = 0.0;
    focusBoxAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    focusBoxAnimation.toValue = [NSNumber numberWithFloat:0.0];
    
    [self alterFocusBox:image.layer animation:focusBoxAnimation];
}

@end
