//
//  KNBBaseRequest.m
//  KenuoTraining
//
//  Created by Robert on 16/3/12.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import "KNBBaseRequest.h"
#import "KNBBaseRequestAccessory.h"
#import "KNBMainConfigModel.h"

@interface KNBBaseRequest ()

@property (nonatomic, strong) KNBBaseRequestAccessory *accessory;
@property (nonatomic, strong) NSMutableDictionary *baseConfigureDic;

@end

@implementation KNBBaseRequest

- (instancetype)init {
    if (self = [super init]) {
        [self addAccessory:self.accessory];
    }
    return self;
}

- (NSInteger)getRequestStatuCode {
    NSDictionary *jsonDic = self.responseJSONObject;
    return [[jsonDic objectForKey:@"result"] integerValue];
}

- (BOOL)requestSuccess {
    return [self getRequestStatuCode] == 200;
}

- (NSString *)errMessage {
    NSDictionary *jsonDic = self.responseJSONObject;
    return [jsonDic objectForKey:@"message"];
}

- (NSTimeInterval)requestTimeoutInterval {
    return 15;
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}

- (YTKRequestSerializerType)requestSerializerType {
    return YTKRequestSerializerTypeJSON;
}

- (NSMutableDictionary *)baseMuDic {
    NSDictionary *dic = @{@"user_token":[KNBUserInfo shareInstance].userToken ? : @""};
    [self.baseConfigureDic addEntriesFromDictionary:dic];
    return self.baseConfigureDic;
}

- (NSMutableDictionary *)baseConfigureDic {
    if (!_baseConfigureDic) {
        _baseConfigureDic = [NSMutableDictionary dictionaryWithObject:KNB_APP_VERSION forKey:@"ver_num"];
    }
    return _baseConfigureDic;
}

- (id)requestArgument {
    return self.baseMuDic;
}

#pragma mark - Getter&Setter
- (KNBBaseRequestAccessory *)accessory {
    if (!_accessory) {
        _accessory = [[KNBBaseRequestAccessory alloc] init];
    }
    return _accessory;
}

- (NSString *)hudString {
    return _hudString ? _hudString : @"";
}

+ (NSString *)requestArticleId:(NSString *)articleId {
    if (articleId.length == 0 || [articleId isKindOfClass:[NSNull class]]) {
        return nil;
    }
    NSString *contentUrlString = [[KNBMainConfigModel shareInstance] getRequestUrlWithKey:KNB_ArticleContent];
    NSString *urlString = [NSString stringWithFormat:@"%@%@?article_id=%@",[KNBMainConfigModel shareInstance].getBaseUrl,contentUrlString,articleId];
    return urlString;
}

@end
