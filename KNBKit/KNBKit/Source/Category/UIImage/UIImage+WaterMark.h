//
//  UIImage+WaterMark.h
//  KenuoTraining
//
//  Created by Robert on 16/4/20.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (WaterMark)

+ (UIImage *)imageWithText:(NSString *)text frame:(CGRect)frame;

@end
