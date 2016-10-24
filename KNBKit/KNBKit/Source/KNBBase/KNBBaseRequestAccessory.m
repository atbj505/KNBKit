//
//  KNBBaseRequestAccessory.m
//  KenuoTraining
//
//  Created by Robert on 16/3/17.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import "KNBBaseRequestAccessory.h"
#import "KNBBaseRequest.h"
#import <LCProgressHUD.h>
#import "NSString+Empty.h"
#import "AppDelegate.h"
#import <AFNetworking.h>

@implementation KNBBaseRequestAccessory

- (void)requestWillStart:(id)request {
    KNBBaseRequest *baseRequest = (KNBBaseRequest *)request;    
    if (baseRequest.needHud || ![baseRequest.hudString isEmpty]) {
        KNB_PerformOnMainThread(^{
            NSString *hudStirng = [baseRequest.hudString isEmpty] ? @"玩命加载中":baseRequest.hudString;
            [LCProgressHUD showLoading:hudStirng];
        });
    }
}

- (void)requestWillStop:(id)request {
    
}

- (void)requestDidStop:(id)request {
    KNBBaseRequest *baseRequest = (KNBBaseRequest *)request;
    
    if (baseRequest.needHud || ![baseRequest.hudString isEmpty]) {
        if (baseRequest.error || baseRequest.responseStatusCode != 200) {
            if ([AFNetworkReachabilityManager sharedManager].reachable) {
                KNB_PerformOnMainThread(^{
                    [LCProgressHUD showFailure:@"请求失败"];
                });
            }
            else {
                KNB_PerformOnMainThread(^{
                    [LCProgressHUD showFailure:@"网络状态差请稍后重试"];
                });
            }
        }
        else {
            KNB_PerformOnMainThread(^{
                if (baseRequest.getRequestStatuCode == 200) {
                    [LCProgressHUD hide];
                }
                else {
                    [LCProgressHUD showFailure:baseRequest.errMessage ? : @"出错啦!"];
                }
            });
        }
    }
}

@end
