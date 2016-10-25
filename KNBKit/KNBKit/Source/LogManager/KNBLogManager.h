//
//  KNBLogManager.h
//  KenuoTraining
//
//  Created by 吴申超 on 16/3/23.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KNBLogManager : NSObject

+ (instancetype)shareInstance;

/**
 *  写入日志
 *
 *  @param logMsg 信息
 */
- (void)log:(NSString *)logMsg;

@end
