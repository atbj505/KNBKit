//
//  NSString+Empty.m
//  KenuoTraining
//
//  Created by Robert on 16/3/9.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import "NSString+Empty.h"

@implementation NSString (Empty)

- (BOOL)isEmpty {
    NSLog(@"%@",self);
    
    return nil == self
    || 0 == [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length];
}

@end
