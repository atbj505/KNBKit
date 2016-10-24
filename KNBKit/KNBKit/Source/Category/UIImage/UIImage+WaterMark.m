//
//  UIImage+WaterMark.m
//  KenuoTraining
//
//  Created by Robert on 16/4/20.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import "UIImage+WaterMark.h"

const int wLeft = 50;
const int wTop = 50;

@implementation UIImage (WaterMark)

+ (UIImage *)imageWithText:(NSString *)text frame:(CGRect)frame {

    NSUInteger GapH = KNB_SCREEN_WIDTH / 3;
    NSUInteger GapV = KNB_SCREEN_HEIGHT / 3;
    
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0.0);
    
    NSUInteger totalX = 0;
    NSUInteger totalY = 0;
    NSUInteger textX = 0;
    NSUInteger textY = 0;
    NSUInteger textWidth = 50;
    NSUInteger textHeight = 20;
    
    while (totalY < frame.size.height) {
        textX = wLeft + totalX;
        textY = wTop + totalY;
        
        totalX += textWidth + GapH;
        
        if (totalX >= frame.size.width) {
            totalX = textWidth + GapH;
            textX = wLeft;
            totalY += textHeight + GapV;
            textY = totalY + wTop;
        }
        
        CGRect frame = CGRectMake(textX, textY, textWidth, textHeight);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSaveGState(context);
        
        CGPoint point = frame.origin;
        
        CGContextTranslateCTM(context, point.x, point.y);
        CGAffineTransform transform = CGAffineTransformMakeRotation(-M_PI_4);
        CGContextConcatCTM(context, transform);
        CGContextTranslateCTM(context, -point.x, -point.y);
        
        NSDictionary *attributeDict =
        @{
          NSFontAttributeName : [UIFont boldSystemFontOfSize:14],
          NSForegroundColorAttributeName : [UIColor whiteColor],
          NSStrokeColorAttributeName : [UIColor lightGrayColor],
          NSStrokeWidthAttributeName : @(2)
          };
        [text drawInRect:frame withAttributes:attributeDict];
        
        CGContextRestoreGState(context);
        
    }
    
    UIImage *waterIconImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return waterIconImage;
}

@end
