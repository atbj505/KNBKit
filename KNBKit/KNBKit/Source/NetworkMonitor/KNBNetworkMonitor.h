//
//  KNBNetworkMonitor.h
//  KenuoTraining
//
//  Created by 刘随义 on 16/8/11.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^KNBNetworkMonitorBlock)();

@interface KNBNetworkMonitor : NSObject

@property (nonatomic, strong) NSString *massage;

@property (nonatomic, strong) NSArray *buttonTitles;

@property (nonatomic, copy) KNBNetworkMonitorBlock block;

+ (instancetype)shareInstance;

- (void)startNetworkMonitoring;

@end
