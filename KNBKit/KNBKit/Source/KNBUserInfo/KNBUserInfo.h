//
//  KNBUserInfo.h
//  KenuoTraining
//
//  Created by Robert on 16/2/23.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KNBUserType) {
    KNBUserType_Admin = 0,
    KNBUserType_Trainer = 1,
    KNBUserType_Beautician = 2
};

@interface KNBUserInfo : NSObject

+ (KNBUserInfo *)shareInstance;

/**
 *  是否首次登陆
 */
@property (nonatomic, assign, readonly) BOOL isFirstLogin;

/**
 *  用户信息
 */
@property (nonatomic, strong, readonly) NSDictionary *userInfo;
@property (nonatomic, copy, readonly) NSString *userId;
@property (nonatomic, copy, readonly) NSString *userToken;
@property (nonatomic, copy, readonly) NSString *userPhoto; // 头像
@property (nonatomic, copy, readonly) NSString *userName;   // 姓名
@property (nonatomic, copy, readonly) NSString *userOffice; // 地址
@property (nonatomic, copy, readonly) NSString *officeId;   //
@property (nonatomic, assign, readonly) double userMoney; //余额
@property (nonatomic, copy, readonly) NSString *userPhone; // 电话
@property (nonatomic, copy, readonly) NSString *userType;// 0：管理员、1：培训师、2：美容师
@property (nonatomic, copy, readonly) NSString *userTypeName; // 职位名称
@property (nonatomic, copy, readonly) NSString *userIntro;// 简介
@property (nonatomic, copy, readonly) NSArray *userLifeImgs;// 照片
@property (nonatomic, copy, readonly) NSArray *userSpec;//特长
@property (nonatomic, copy, readonly) NSString *cacheUserToken; //缓存的token
@property (nonatomic, assign, readonly) NSInteger companyId;//公司id
@property (nonatomic, copy, readonly) NSString *officeCode;//店铺code
@property (nonatomic, assign, readonly) NSInteger mtmyUserId;//每天美耶ID

/**
 *  注册用户信息
 *
 *  @param userInfo 用户信息
 */
- (void)registUserInfo:(NSDictionary *)userInfo;

/**
 *  登录成功
 */
- (void)loginSuccess;

/**
 *  登出抹除数据
 */
- (void)logout;

/**
 需要重新登录
 */
- (BOOL)needLoginAgain;

/**
 *  同步用户信息
 */
- (void)syncUserPhotoUrl:(NSString *)photoUrl;
- (void)syncUserIntroDes:(NSString *)introDes;
- (void)syncUserLifeImages:(NSArray *)lifeImgs;
- (void)syncUserSpec:(NSArray *)spec;
- (void)syncUserMoney:(double)userMoney;

/**
 *  用户类型
 *
 *  @return 用户类型文字描述
 */
- (NSString *)userTypeDesc;
+ (NSString *)userTypeDes:(NSInteger)userType;
/**
 *  用户类型 (美容师有等级)
 */
- (NSString *)userTypeIconName;
+ (NSString *)userTypeIcon:(NSInteger)userType userLevel:(NSInteger)level;

@end
