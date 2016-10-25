//
//  KNBNetworkMonitor.m
//  KenuoTraining
//
//  Created by 刘随义 on 16/8/11.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import "KNBNetworkMonitor.h"
#import "AFNetworkReachabilityManager.h"
#import "CustomIOSAlertView.h"
#import "NSString+Size.h"

@interface KNBNetworkMonitor ()

@end

@implementation KNBNetworkMonitor

+ (instancetype)shareInstance {
    static KNBNetworkMonitor *sharedNetworkMonitor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedNetworkMonitor = [[KNBNetworkMonitor alloc] init];
    });
    return sharedNetworkMonitor;
}

- (void)startNetworkMonitoring {
    KNB_WS(weakSelf);
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        KNB_AlertlogError(@"当前无网络请稍后再试");
    }
    else if ([AFNetworkReachabilityManager sharedManager].reachableViaWiFi) {
        if (weakSelf.block) {
            weakSelf.block();
        }
    }
    else {
        CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
        [alertView setContainerView:[weakSelf createDemoView]];
        [alertView setButtonTitles:[NSMutableArray arrayWithArray:weakSelf.buttonTitles]];
        [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
            if (buttonIndex == 1) {
                if (weakSelf.block) {
                    weakSelf.block();
                }
            }
            [alertView close];
        }];
        [alertView setUseMotionEffects:true];
        [alertView show];
    }
}

- (UIView *)createDemoView {
    UIView *textView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 80)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 230, 60)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = self.massage;
    label.numberOfLines = 2;
    [textView addSubview:label];
    return textView;
}

@end
