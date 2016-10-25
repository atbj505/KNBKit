//
//  KNBMakePhoneManager.m
//  KenuoTraining
//
//  Created by 吴申超 on 16/4/25.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import "KNBMakePhoneManager.h"
#import "NSString+Empty.h"

@interface KNBMakePhoneManager ()<UIAlertViewDelegate>

@property (nonatomic, copy) NSString *phoneString;

@end

@implementation KNBMakePhoneManager

+ (instancetype)shareInstance {
    static KNBMakePhoneManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)makePhone:(NSString *)phone controller:(UIViewController *)controller {
    self.phoneString = phone;
    if ([phone isEmpty]) {
        KNB_AlertlogError(@"电话号码不能为空!");
        return;
    }
    
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType isEqualToString:@"iPod touch"]||
       [deviceType isEqualToString:@"iPad"]||
       [deviceType isEqualToString:@"iPhone Simulator"]||
       [deviceType isEqualToString:@"iPad Simulator"]) {
        KNB_AlertlogError(@"该设备不支持拨打电话!");
        return;
    }

//    NSString *message = [NSString stringWithFormat:@"是否拨打该电话:%@", phone];
//    
//    if (KNB_SYSTEM_VERSION < 8.0) {
//        [[[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil] show];
//    }
//    else {
//        KNB_WS(weakSelf);
//        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//            
//        }];
//        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [weakSelf makePhone:phone];
//        }];
//        UIAlertController *alterController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
//        [alterController addAction:cancelAction];
//        [alterController addAction:sureAction];
//        [controller presentViewController:alterController animated:YES completion:nil];
//    }
    
    [self makePhone:self.phoneString]; //直接显示手机号

}

- (void)makePhone:(NSString *)phone {
    NSString *num = [[NSString alloc] initWithFormat:@"telprompt://%@",phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0) {
    if (buttonIndex == 1) {
        [self makePhone:self.phoneString];
    }
}

@end
