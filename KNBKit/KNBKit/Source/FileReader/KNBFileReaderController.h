//
//  KNBFileReaderController.h
//  KenuoTraining
//
//  Created by Robert on 16/3/18.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KNBFileReaderController;

@protocol KNBFileReaderControllerDelegate <NSObject>

- (void)fileReader:(KNBFileReaderController *)fileReader fileProgress:(CGFloat)progress;

@end

@interface KNBFileReaderController : UIViewController

@property (nonatomic, copy) NSString *fileUrl;

@property (nonatomic, copy) NSString *filePath;

@property (nonatomic, assign) NSInteger indexPathRow;

@property (nonatomic, strong) NSString *fileName;

//上次观看的进度
@property (nonatomic, assign) CGFloat preFileProgress;

@property (nonatomic, weak) id<KNBFileReaderControllerDelegate> delegate;

@end
