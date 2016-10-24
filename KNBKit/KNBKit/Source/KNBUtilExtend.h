//
//  KNBUtilExtend.h
//  KenuoTraining
//
//  Created by Robert on 16/2/22.
//  Copyright © 2016年 Robert. All rights reserved.
//

#ifndef KNBUtilExtend_h
#define KNBUtilExtend_h

//通知相关
CG_INLINE void KNB_ADD_NOTIFICATION(NSString *name, id target, SEL action, id object)
{
    [[NSNotificationCenter defaultCenter] addObserver:target selector:action name:name object:object];
}

CG_INLINE void KNB_REMOVE_NOTIFICATION(NSString *name, id target, id object)
{
    [[NSNotificationCenter defaultCenter] removeObserver:target name:name object:object];
}

CG_INLINE void KNB_POST_NOTIFICATION(NSString *name, id object, NSDictionary *userInfo)
{
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:object userInfo:userInfo];
}

CG_INLINE BOOL isNullStr(NSString *str)
{
    return (str.length == 0 || [str isKindOfClass:[NSNull class]]);
}

//Alert提示
CG_INLINE void KNB_AlertlogError (NSString* message)
{
    static UIAlertView *alertView = nil;
    if (!alertView)
    {
        alertView = [[UIAlertView alloc] initWithTitle:  @""
                                               message: message
                                              delegate: nil
                                     cancelButtonTitle: @"好的"
                                     otherButtonTitles: nil,
                     nil];
        [alertView show];
    }
    else
    {
        [alertView dismissWithClickedButtonIndex:0 animated:NO];
        alertView = nil;
        alertView = [[UIAlertView alloc] initWithTitle:  @""
                                               message: message
                                              delegate: nil
                                     cancelButtonTitle: @"好的"
                                     otherButtonTitles: nil,
                     nil];
        [alertView show];
    }
}

//多线程相关
CG_INLINE void KNB_PerformAsynchronous (void(^block)(void)) {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
}

CG_INLINE void KNB_PerformOnMainThread (void(^block)(void)) {
    dispatch_async(dispatch_get_main_queue(), block);
}

typedef NS_ENUM(NSUInteger, KNBRecorderType) {
    KNBRecorderPhoto = 2, //照片
    KNBRecorderVideo //视频
};


CG_INLINE NSURL *resourceSaveDirectory(NSString *userName, KNBRecorderType type) {
    NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:userName];
    
    BOOL isDir;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDir] || !isDir) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if (type == KNBRecorderVideo){
        dirPath = [dirPath stringByAppendingPathComponent:@"Video"];
    }else if (type == KNBRecorderPhoto) {
        dirPath = [dirPath stringByAppendingPathComponent:@"Photo"];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDir] || !isDir) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSURL *dirUrl = [NSURL fileURLWithPath:dirPath];;
    return dirUrl;
}


CG_INLINE NSURL *resourceAbsolutePath(NSString *userName, NSString *resourceName, KNBRecorderType type) {
    NSURL *dirUrl = resourceSaveDirectory(userName, type);
    
    NSURL *fileUrl = nil;
    
    if (type == KNBRecorderVideo) {
        fileUrl = [[dirUrl URLByAppendingPathComponent:resourceName] URLByAppendingPathExtension:@"mp4"];
    }else if (type == KNBRecorderPhoto) {
        fileUrl = [[dirUrl URLByAppendingPathComponent:resourceName] URLByAppendingPathExtension:@"jpg"];
    }
    return fileUrl;
}

CG_INLINE void removeResources(NSString *userName) {
    NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:userName];
    
    NSString *videoDirPath = [dirPath stringByAppendingPathComponent:@"Video"];
    NSString *photoDirPath = [dirPath stringByAppendingPathComponent:@"Photo"];
    
    [[NSFileManager defaultManager] removeItemAtPath:videoDirPath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:photoDirPath error:nil];
}

CG_INLINE NSString *combineResourceUrl(NSString *url) {
//    NSString *complteString = [NSString stringWithFormat:@"%@%@", [[KNBMainConfigModel shareInstance] getRequestUrlWithKey:KNBResourceUrl], url];
//    return complteString;
    return url;
}

CG_INLINE BOOL isPhoneNumber(NSString *number){
    //* 普通
    NSString *MB=@"^1[3-9]\\d{9}$";
    //* 移动
    NSString *CM=@"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    //* 联通
    NSString *CU=@"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    //* 电信
    NSString *CT=@"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    
    NSPredicate *regextestmb = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",MB];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CT];
    if(([regextestmb evaluateWithObject:number] ==YES) ||
       ([regextestcm evaluateWithObject:number] ==YES) ||
       ([regextestct evaluateWithObject:number] ==YES) ||
       ([regextestcu evaluateWithObject:number] ==YES)) {
        return YES;
    }
    else {
        return NO;
    }
}

#endif /* KNBUtilExtend_h */
