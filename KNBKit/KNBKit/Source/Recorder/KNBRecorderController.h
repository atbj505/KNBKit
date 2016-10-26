//
//  KNBRecorderController.h
//  KenuoTraining
//
//  Created by Robert on 16/3/3.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KNBUtilExtend.h"

@interface KNBRecorderController : UIViewController

/**
 *  预览回调
 */
@property (nonatomic, copy) void (^didSelectedConfirmBlock)(KNBRecorderType type, NSString *name, UIImage *resizeImage, UIImage *originImage);

/**
 *  初始化类方法
 *
 *  @param type 类型
 *  @param name 视频/照片名称
 *
 *  @return 实例
 */
+ (KNBRecorderController *)recorderWithType:(KNBRecorderType)type Name:(NSString *)name;

@end
