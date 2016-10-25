//
//  KNBDownloadManager.h
//  KenuoTraining
//
//  Created by Robert on 16/3/9.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import <Foundation/Foundation.h>

// 开始下载
typedef void(^KNBDownloadStartBlock)(NSString *fileUrl, NSString *savePath);
// 暂停下载
typedef void(^KNBDownloadPauseBlock)(NSString *fileUrl, CGFloat progress);

// 开始进度
typedef void(^KNBDownloadProgressBlock)(NSString *fileUrl, NSInteger receivedSize,
                                        NSInteger expectedSize, CGFloat progress);
// 下载完成
typedef void(^KNBDownloadCompleteBlock)(NSString *fileUrl, NSString *savePath, NSError *error);

@interface KNBDownloadManager : NSObject

+ (instancetype)shareInstance;

@property (nonatomic, strong, readonly) NSMutableDictionary *tasks;
@property (nonatomic, copy) KNBDownloadStartBlock startBlock;
@property (nonatomic, copy) KNBDownloadPauseBlock pauseBlock;
@property (nonatomic, copy) KNBDownloadProgressBlock progressBlock;
@property (nonatomic, copy) KNBDownloadCompleteBlock completeBlock;

/**
 *  开启下载
 *
 *  @param url           下载URL
 *  @param name          下载资源名称 默认为url.lastPathComponent
 *  @param progressBlock 下载进度回调
 *  @param pauseBlock    下载暂停回调
 *  @param completeBlock 下载完成回调
 */
- (void)download:(NSString *)url
            name:(NSString *)name
        progress:(KNBDownloadProgressBlock)progressBlock
        complete:(KNBDownloadCompleteBlock)completeBlock;

/**
 *  暂停下载任务
 *
 *  @param url 下载URL
 */
- (void)pause:(NSString *)url;

/**
 *  暂停全部
 */
- (void)pauseAllFile;

/**
 *  根据URL查询下载进度
 *
 *  @param url 下载URL
 *
 *  @return 下载进度
 */
- (CGFloat)progress:(NSString *)url;

/**
 *  获取下载资源大小
 *
 *  @param url 下载URL
 *
 *  @return 资源大小
 */
- (NSInteger)fileTotalLength:(NSString *)url;

/**
 *  判断该资源是否下载完成
 *
 *  @param url 下载地址
 *
 *  @return 完成情况
 */
- (BOOL)isCompletion:(NSString *)url;

/**
 *  判断是否正在下载
 *
 *  @param url url
 *
 *  @return 正在
 */
- (BOOL)isDownLoadIng:(NSString *)url;

/**
 *  删除该资源
 *
 *  @param url 下载地址
 */
- (void)deleteFile:(NSString *)url;

/**
 *  清空所有下载资源
 */
- (void)deleteAllFile;

/**
 *  获取所有下载的任务
 *
 *  @return 任务数组
 */
- (NSArray *)getAllDownLoadRequest;

@end
