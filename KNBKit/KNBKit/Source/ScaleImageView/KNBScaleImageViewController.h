//
//  KNBScaleImageViewController.h
//  KenuoTraining
//
//  Created by Robert on 16/3/7.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KNBScaleImageViewController;

@protocol KNBScaleImageViewControllerDelegate <NSObject>

- (UIImageView*)scaleImageViewControllerFromView;

- (UIView *)scaleImageViewControllerFromViewSuperView;

- (UIView*)scaleImageViewControllerToView;

@end

@interface KNBScaleImageViewController : UIViewController <UINavigationControllerDelegate>

@property (nonatomic, strong) UICollectionView *imageBrowser;

@property (nonatomic, strong) NSArray *imagesData;

@property (nonatomic, assign) NSIndexPath *currentIndexPath;

@property (nonatomic, assign) id<KNBScaleImageViewControllerDelegate> delegate;

@end
