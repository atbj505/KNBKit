//
//  NSString+Size.h
//  KenuoTraining
//
//  Created by Robert on 16/2/22.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Size)

/**
 *  计算文字高度
 *
 *  @param font  字体（默认为系统字体）
 *  @param width 宽度约束
 *
 *  @return 高度
 */
- (CGFloat)heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;

/**
 *  计算文字宽度
 *
 *  @param font   字体（默认为系统字体）
 *  @param height 高度约束
 *
 *  @return 宽度
 */
- (CGFloat)widthWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height;

@end
