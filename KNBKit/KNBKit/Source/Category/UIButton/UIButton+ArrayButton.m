//
//  UIButton+ArrayButton.m
//  RYSearch
//
//  Created by Robert on 15/4/24.
//  Copyright (c) 2015年 Robert. All rights reserved.
//

#import "UIButton+ArrayButton.h"
#import "KNBPrecompile.h"

static const int TextFount = 9;
static const int ButtonHeight = 18;
int Left = 0;
int Top = 0;

@implementation UIButton (ArrayButton)

+ (NSArray *)ButtonWithArray:(NSArray *)array Gap:(NSUInteger)gap tag:(NSInteger)tag {

    NSMutableArray *buttonArray = [NSMutableArray array];
    NSUInteger totalX = 0;
    NSUInteger totalY = 0;
    for (int i = 0; i < array.count; i++) {
        NSString *title = array[i];
        UIButton *button = [[self alloc] buttonSetting];
        [button setTitle:title forState:UIControlStateNormal];
        button.tag = i + tag;
        
        button.frame = CGRectMake(0, 0, KNB_SCREEN_WIDTH, ButtonHeight);
        [button sizeToFit];
        
        NSUInteger ButtonX = Left + totalX;
        NSUInteger ButtonY = Top + totalY;
        
        NSUInteger ButtonWidth = button.bounds.size.width;
        totalX += ButtonWidth + gap;
        
        if (totalX >= KNB_SCREEN_WIDTH) {
            totalX = ButtonWidth + gap;
            ButtonX = Left;
            totalY += ButtonHeight + 5;
            ButtonY = totalY + Top;
        }
        
        button.frame = CGRectMake(ButtonX, ButtonY, 18, 18);
        
        [buttonArray addObject:button];
    }
    return buttonArray;
}

+ (NSArray *)ButtonWithArray:(NSArray *)array Gap:(NSUInteger)gap {
    return [self ButtonWithArray:array Gap:gap tag:0];
}

//button基本设置
- (UIButton *)buttonSetting {
    UIButton *button = [[UIButton alloc] init];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [button setBackgroundColor:[UIColor blackColor]];
    button.titleLabel.font = [UIFont systemFontOfSize:TextFount];
//    button.layer.cornerRadius = 5;
//    button.layer.borderColor = [UIColor whiteColor].CGColor;
//    button.layer.borderWidth = 1;
    return button;
}

@end
