//
//  LLSimpleCameraIntercepter.m
//  KenuoTraining
//
//  Created by Robert on 16/3/4.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import "LLSimpleCameraIntercepter.h"
#import "LLSimpleCamera+FocusBox.h"
#import <objc/runtime.h>

@implementation LLSimpleCameraIntercepter

+ (LLSimpleCameraIntercepter *)shareInstance {
    static LLSimpleCameraIntercepter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (void)load {
    [super load];
    
    [LLSimpleCameraIntercepter shareInstance];
}

- (instancetype)init {
    if (self = [super init]) {
        Method originMathod = class_getInstanceMethod([LLSimpleCamera class], @selector(addDefaultFocusBox));
        Method swizzleMathod = class_getInstanceMethod([LLSimpleCamera class], @selector(KNB_addDefaultFocusBox));
        method_exchangeImplementations(originMathod, swizzleMathod);
    }
    return self;
}

@end
