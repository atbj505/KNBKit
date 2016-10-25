//
//  KNBMakePhoneManager.h
//  KenuoTraining
//
//  Created by 吴申超 on 16/4/25.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KNBMakePhoneManager : NSObject

+ (instancetype)shareInstance;

/**
 *  拨打电话
 *
 *  @param phone 电话
 */
- (void)makePhone:(NSString *)phone controller:(UIViewController *)controller;

@end
