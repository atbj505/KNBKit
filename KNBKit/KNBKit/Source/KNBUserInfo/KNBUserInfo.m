//
//  KNBUserInfo.m
//  KenuoTraining
//
//  Created by Robert on 16/2/23.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import "KNBUserInfo.h"

#define KNB_SAVE_LOGIN_VERSION @"KNB_SAVE_LOGIN_VERSION"

static NSString *const KNB_USER_LOGINSUCCESS = @"KNB_USER_LOGINSUCCESS";
static NSString *const KNB_USER_INFO = @"KNB_USER_INFO";
static NSString *const KNB_USER_PHOTO = @"user_photo";
static NSString *const KNB_USER_NAME = @"user_name";
static NSString *const KNB_USER_OFFICEID = @"office_id";
static NSString *const KNB_USER_PHONE = @"phone_num";
static NSString *const KNB_USER_OFFICE = @"office_name";
static NSString *const KNB_USER_ID = @"user_id";
static NSString *const KNB_USER_TYPE = @"user_type";
static NSString *const KNB_USER_TYPE_NAME = @"user_type_name";
static NSString *const KNB_USER_TOKEN = @"user_token";
static NSString *const KNB_USER_IMGS = @"lifeImgs";
static NSString *const KNB_USER_SPEC = @"specialitys";
static NSString *const KNB_USER_SELFINTRO = @"selfIntro";
static NSString *const KNB_USER_LEVEL = @"level";
static NSString *const KNB_USER_CACHETOKEN = @"KNB_USER_CACHETOKEN";
static NSString *const KNB_USER_MONEY = @"user_money";
static NSString *const KNB_USER_COMPNEYID = @"companyId";
static NSString *const KNB_USER_OFFICECODE = @"officeCode";
static NSString *const KNB_MTMYUSER_ID = @"mtmyUserId";

@interface KNBUserInfo ()

@property (nonatomic, copy, readwrite) NSString *userId;
@property (nonatomic, copy, readwrite) NSString *userPhoto;
@property (nonatomic, copy, readwrite) NSString *userName;
@property (nonatomic, copy, readwrite) NSString *userToken;
@property (nonatomic, copy, readwrite) NSString *userOffice;
@property (nonatomic, copy, readwrite) NSString *officeId;   //
@property (nonatomic, assign, readwrite) double userMoney; //余额
@property (nonatomic, copy, readwrite) NSString *userPhone;
@property (nonatomic, copy, readwrite) NSString *userType;// 0：管理员、1：培训师、2：美容师
@property (nonatomic, copy, readwrite) NSString *userTypeName; // 职位名称
@property (nonatomic, copy, readwrite) NSString *userIntro;
@property (nonatomic, copy, readwrite) NSArray *userLifeImgs;// 照片
@property (nonatomic, copy, readwrite) NSArray *userSpec;//标签
@property (nonatomic, copy, readwrite) NSString *cacheUserToken; //缓存token
@property (nonatomic, readwrite) NSInteger userLevel; // 用户等级
@property (nonatomic, readwrite) NSInteger companyId;//公司id
@property (nonatomic, readwrite) NSString *officeCode;//店铺code

@end

@implementation KNBUserInfo

+ (KNBUserInfo *)shareInstance {
    static KNBUserInfo *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (BOOL)isFirstLogin {
    NSString *success = [[NSUserDefaults standardUserDefaults] objectForKey:KNB_USER_LOGINSUCCESS];
    return success ? NO : YES;
}

/**
 *  登录成功
 */
- (void)loginSuccess {
    [[NSUserDefaults standardUserDefaults] setObject:@"KNB_USER_LOGINSUCCESS"
                                              forKey:KNB_USER_LOGINSUCCESS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)registUserInfo:(NSDictionary *)userInfo {
    // 保存json
    NSDictionary *newDic = [self changeNullValue:userInfo];
    NSString *jsonStr = [self changeToJson:newDic];
    [[NSUserDefaults standardUserDefaults] setObject:jsonStr
                                              forKey:KNB_USER_INFO];
    // 缓存一份userToken
    [[NSUserDefaults standardUserDefaults] setObject:userInfo[KNB_USER_TOKEN] forKey:KNB_USER_CACHETOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)changeNullValue:(NSDictionary *)dic {
    NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    for (NSString *key in dic.allKeys) {
        if ([dic[key] isKindOfClass:[NSNull class]]) {
            [muDic setValue:@"" forKey:key];
        }
    }
    return muDic;
}

- (NSString *)changeToJson:(NSDictionary *)dic {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonStr;
}

- (NSDictionary *)userInfo {
    id jsonStr = [[NSUserDefaults standardUserDefaults] objectForKey:KNB_USER_INFO];
    if (jsonStr == nil) {
        return nil;
    }
    if ([jsonStr isKindOfClass:[NSDictionary class]]) {
        return jsonStr;
    }
    NSData *jsonData = [(NSString *)jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    return dic;
}

- (void)logout {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KNB_USER_LOGINSUCCESS];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KNB_USER_INFO];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 需要重新登录
 */
- (BOOL)needLoginAgain {
    NSString *loginVersion = [[NSUserDefaults standardUserDefaults] objectForKey:KNB_SAVE_LOGIN_VERSION];
    if (!loginVersion || ![loginVersion isEqualToString:KNB_APP_VERSION]) {
        [[NSUserDefaults standardUserDefaults] setObject:KNB_APP_VERSION forKey:KNB_SAVE_LOGIN_VERSION];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    return NO;
}

#pragma MAKR - sync user message
- (void)syncUserPhotoUrl:(NSString *)photoUrl {
    NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
    muDic[KNB_USER_PHOTO] = photoUrl ? : @"";
    [self registUserInfo:muDic];
}

- (void)syncUserLifeImages:(NSArray *)lifeImgs {
    NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
    muDic[KNB_USER_IMGS] = lifeImgs;
    [self registUserInfo:muDic];
}

- (void)syncUserIntroDes:(NSString *)introDes {
    NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
    muDic[KNB_USER_SELFINTRO] = introDes ? : @"";
    [self registUserInfo:muDic];
}

- (void)syncUserSpec:(NSArray *)spec {
    NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
    muDic[KNB_USER_SPEC] = spec;
    [self registUserInfo:muDic];
}

- (void)syncUserMoney:(double)userMoney {
    NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
    muDic[KNB_USER_MONEY] = @(userMoney);
    [self registUserInfo:muDic];

}

#pragma MAKR - get user message
- (NSString *)officeId {
    return self.userInfo[KNB_USER_OFFICEID];
}

- (NSString *)userId {
    return self.userInfo[KNB_USER_ID];
}

- (NSInteger )mtmyUserId {
    return [self.userInfo[KNB_MTMYUSER_ID] integerValue];
}


- (NSString *)userName {
    return self.userInfo[KNB_USER_NAME] ? : @"";
}

- (NSString *)userPhoto {
    return self.userInfo[KNB_USER_PHOTO] ? : @"";
}

- (NSString *)userOffice {
    return self.userInfo[KNB_USER_OFFICE] ? : @"";
}

- (NSString *)userPhone {
    return self.userInfo[KNB_USER_PHONE] ? : @"";
}

- (NSString *)userToken {
    return self.userInfo[KNB_USER_TOKEN] ? : @"";
}

- (NSArray *)userLifeImgs {
    return self.userInfo[KNB_USER_IMGS];
}

- (NSArray *)userSpec {
    return self.userInfo[KNB_USER_SPEC];
}

- (NSString *)userIntro {
    return self.userInfo[KNB_USER_SELFINTRO] ? : @"";
}

- (NSInteger)userLevel {
    return [self.userInfo[KNB_USER_LEVEL] integerValue];
}

- (double )userMoney {
    return [self.userInfo[KNB_USER_MONEY] doubleValue];
}

- (NSString *)cacheUserToken {
    _cacheUserToken = [[NSUserDefaults standardUserDefaults] objectForKey:KNB_USER_CACHETOKEN];
    return _cacheUserToken;
}

- (NSString *)userType {
    return self.userInfo[KNB_USER_TYPE];
}

- (NSString *)userTypeName {
    return self.userInfo[KNB_USER_TYPE_NAME];
}

- (NSString *)userTypeDesc {
    return [KNBUserInfo userTypeDes:[self.userType integerValue]] ? : @"";
}

- (NSInteger)companyId {
    return [self.userInfo[KNB_USER_COMPNEYID] integerValue];
}

- (NSString *)officeCode {
    return self.userInfo[KNB_USER_OFFICECODE];
}

+ (NSString *)userTypeDes:(NSInteger)userType {
    switch (userType) {
        case KNBUserType_Admin:
            return @"管理员";
            break;
        case KNBUserType_Trainer:
            return @"培训师";
            break;
        case KNBUserType_Beautician:
            return @"美容师";
            break;
        default:
            break;
    }
    return [KNBUserInfo shareInstance].userTypeName;
}

+ (NSString *)userTypeIcon:(NSInteger)userType userLevel:(NSInteger)level {
    NSString *name = @"";
    switch (userType) {
        case KNBUserType_Admin:
            name = @"icon_shopmanager";
            break;
        case KNBUserType_Trainer:
            name = @"icon_trainer";
            break;
        case KNBUserType_Beautician:
            switch (level) {
                case 0:
                    name = @"icon_bv1";
                    break;
                case 1:
                    name = @"icon_bv2";
                    break;
                case 2:
                    name = @"icon_bv3";
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    return name;
}

- (NSString *)userTypeIconName {
    return [KNBUserInfo userTypeIcon:[self.userType integerValue] userLevel:self.userLevel];
}

@end
