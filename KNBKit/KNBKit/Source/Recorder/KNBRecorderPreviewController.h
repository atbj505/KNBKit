//
//  KNBRecorderPreviewController.h
//  KenuoTraining
//
//  Created by Robert on 16/3/4.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KNBRecorderController.h"

@protocol KNBRecorderPreviewControllerDelegate <NSObject>

- (void)sendWithType:(KNBRecorderType)type Name:(NSString *)name PreviewImage:(UIImage *)previewImage OriginImage:(UIImage *)originImage;

@optional
- (void)didCancelPreview;

@end


@interface KNBRecorderPreviewController : UIViewController

@property (nonatomic, weak) id<KNBRecorderPreviewControllerDelegate>delegate;

/**
 *  初始化类方法
 *
 *  @param type 类型
 *
 *  @return 实例
 */
+ (KNBRecorderPreviewController *)PreviewWithType:(KNBRecorderType)type Name:(NSString *)name;

/**
 *  吸附在指定VC上
 *
 *  @param vc    VC
 *  @param frame frame
 */
- (void)attachToViewController:(UIViewController *)vc Frame:(CGRect)frame;

/**
 *  从父VC上移除
 */
- (void)removeFromSuperViewcontroller;

@end
