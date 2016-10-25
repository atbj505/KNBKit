//
//  KNBScaleImageView.h
//  KenuoTraining
//
//  Created by Robert on 16/3/4.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KNBScaleImageView;

@protocol KNBScaleImageViewDelegate <NSObject>

- (void)singleTapImage:(KNBScaleImageView *)imageView;

@end

@interface KNBScaleImageView : UIView

/**
 *  当前显示图片
 */
@property (nonatomic, strong) UIImage *image;

/**
 *  图片URL 用于读取远程图片
 */
@property (nonatomic, strong) NSString *imageUrl;

/**
 *  视频文件名称
 */
@property (nonatomic, strong) NSString *videoName;

/**
 *  是否需要遮挡视图
 */
@property (nonatomic, assign) bool needBlurView;

@property (nonatomic, weak) id <KNBScaleImageViewDelegate> delegate;

/**
 *  重置放大倍数
 */
- (void)restScale;

@end
