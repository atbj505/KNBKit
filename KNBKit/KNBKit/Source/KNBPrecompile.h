//
//  KNBPrecompile.h
//  KenuoTraining
//
//  Created by Robert on 16/2/22.
//  Copyright © 2016年 Robert. All rights reserved.
//

#ifndef KNBPrecompile_h
#define KNBPrecompile_h

//主代理
#define KNB_AppDelegate  ((AppDelegate *)[UIApplication sharedApplication].delegate)

//单例宏定义.h
#define KNB_DEFINE_SINGLETON_FOR_HEADER(className) \
\
+ (className *)shareInstance;

//单例宏定义.m
#define KNB_DEFINE_SINGLETON_FOR_CLASS(className) \
\
+ (className *)shareInstance { \
static className *instance = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
instance = [[self alloc] init]; \
}); \
return instance; \
}

//色值宏定义
#define KNB_RGBA(r,g,b,a)   [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define KNB_RGB(r,g,b)      [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

//字体大小
#define KNB_FONT_SIZE_DEFAULT(size) [UIFont systemFontOfSize:size]
#define KNB_FONT_SIZE_BOLD(size)    [UIFont boldSystemFontOfSize:size]

//当前系统版本
#define KNB_SYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

//App版本
#define KNB_APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

//设备屏幕高度
#define KNB_SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

//设备屏幕宽度
#define KNB_SCREEN_WIDTH  [[UIScreen mainScreen] bounds].size.width

#define KNB_NAVI_HEIGHT 64

//屏幕大小
#define KNB_SCREEN_BOUNDS [[UIScreen mainScreen] bounds]

//背景颜色
#define KNB_BG_COLOR [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]

#define KNB_NAV_COLOR [UIColor colorWithRed:255/255.0 green:61/255.0 blue:124/255.0 alpha:1.0]
//沙盒路径
#define KNB_PATH_SANDBOX    ( NSHomeDirectory() )
#define KNB_PATH_DOCUMENTS  ( NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] )
#define KNB_PATH_LIBRARY    ( NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0] )
#define KNB_PATH_CACHE      ( NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] )
#define KNB_PATH_TMP        ( NSTemporaryDirectory() )

//weakSelf
#define KNB_WS(weakSelf)  __weak __typeof(self)weakSelf = self;

//strongSelf
#define KNB_SS(strongSelf, weakSelf) __strong __typeof(weakSelf)strongSelf = weakSelf;

#endif /* KNBPrecompile_h */
