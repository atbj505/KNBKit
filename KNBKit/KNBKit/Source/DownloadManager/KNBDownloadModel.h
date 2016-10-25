//
//  KNBDownloadModel.h
//  KenuoTraining
//
//  Created by Robert on 16/3/9.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "KNBDownloadManager.h"

@interface KNBDownloadModel : NSObject

// 流
@property (nonatomic, strong) NSOutputStream *stream;

// 下载URL
@property (nonatomic, copy) NSString *url;

// 下载资源名称
@property (nonatomic, strong) NSString *name;

// 返回数据长度
@property (nonatomic, assign) NSInteger totalLength;


@end
