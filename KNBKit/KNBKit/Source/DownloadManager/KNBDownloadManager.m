//
//  KNBDownloadManager.m
//  KenuoTraining
//
//  Created by Robert on 16/3/9.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import "KNBDownloadManager.h"
#import "KNBDownloadModel.h"
#import "NSString+Empty.h"
#import "KNBPrecompile.h"

// 缓存主目录
#define KNBDownloadCachesDirectory [KNB_PATH_CACHE stringByAppendingPathComponent:@"KNBDownload"]

// 保存文件名
#define KNBDownloadFileName(url) [self.name isEmpty]||!self.name ? url.lastPathComponent : self.name

// 文件的存放路径
#define KNBDownloadCachesFullpath(url) [KNBDownloadCachesDirectory stringByAppendingPathComponent:KNBDownloadFileName(url)]

#define KNBDownloadCachesPartPath(url) [@"KNBDownload" stringByAppendingPathComponent:KNBDownloadFileName(url)]

// 文件的已下载长度
#define KNBDownloadLength(url) [[[NSFileManager defaultManager] attributesOfItemAtPath:KNBDownloadCachesFullpath(url) error:nil][NSFileSize] integerValue]

// 存储文件总长度的文件路径
#define KNBDownloadTotalLengthFullpath [KNBDownloadCachesDirectory stringByAppendingPathComponent:@"totalLength.plist"]

// 下载文件信息
#define KNBDownloadingFile [KNBDownloadCachesDirectory stringByAppendingPathComponent:@"downloadingFile.plist"]

@interface KNBDownloadManager () <NSURLSessionDelegate>

@property (nonatomic, strong) NSMutableDictionary *tasks;

@property (nonatomic, strong) NSMutableDictionary *sessionModels;

@property (nonatomic, copy) NSString *name;

@end

@implementation KNBDownloadManager

+ (instancetype)shareInstance {
    static KNBDownloadManager *downloadManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadManager = [[KNBDownloadManager alloc] init];
    });
    return downloadManager;
}

- (void)download:(NSString *)url
            name:(NSString *)name
        progress:(KNBDownloadProgressBlock)progressBlock
        complete:(KNBDownloadCompleteBlock)completeBlock {
    
    [self createDirectory];
    self.name = name;
    
    self.progressBlock = progressBlock;
    self.completeBlock = completeBlock;
    
    if (!url) return;
    
    if ([self isCompletion:url]) {
        if (completeBlock) {
            completeBlock(url , KNBDownloadCachesFullpath(url), nil);
        }
        return;
    }
    
    // 暂停
    if ([self.tasks valueForKey:KNBDownloadFileName(url)]) {
        NSURLSessionDataTask *task = [self getTask:url];
        if (task.state != NSURLSessionTaskStateRunning){
            [task resume];
        }
        return;
    }
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    
    NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:KNBDownloadCachesFullpath(url) append:YES];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-", KNBDownloadLength(url)];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    // 创建一个Data任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    NSUInteger taskIdentifier = arc4random() % ((arc4random() % 10000 + arc4random() % 10000));
    [task setValue:@(taskIdentifier) forKeyPath:@"taskIdentifier"];
    
    // 保存任务
    [self.tasks setValue:task forKey:KNBDownloadFileName(url)];
    
    KNBDownloadModel *sessionModel = [[KNBDownloadModel alloc] init];
    sessionModel.url = url;
    sessionModel.name = KNBDownloadFileName(url);
    sessionModel.stream = stream;
    [self.sessionModels setValue:sessionModel forKey:@(task.taskIdentifier).stringValue];
    
    [task resume];
    if (self.startBlock) {
        self.startBlock(url ,KNBDownloadCachesPartPath(url));
    }
}

- (void)pause:(NSString *)url {
    NSURLSessionDataTask *task = [self getTask:url];
    [task suspend];
    
    KNBDownloadModel *sessionModel = [self getSessionModel:task.taskIdentifier];
    CGFloat progress = [self progress:sessionModel.url];
    if (self.pauseBlock) {
        self.pauseBlock(url, progress);
    }
}

- (void)pauseAllFile {
    NSArray *array = [self.tasks allValues];
    for (NSURLSessionDownloadTask *task in array) {
        if (task.state == NSURLSessionTaskStateRunning) {
            [self pause:[task.currentRequest.URL absoluteString]];
        }
    }
}

- (BOOL)isCompletion:(NSString *)url {
    if ([self fileTotalLength:url] && KNBDownloadLength(url) == [self fileTotalLength:url]) {
        return YES;
    }
    return NO;
}

- (BOOL)isDownLoadIng:(NSString *)url {
    NSURLSessionDataTask *task = [self getTask:url];
    if (task && task.state == NSURLSessionTaskStateRunning) {
        return YES;
    }
    return NO;
}

- (CGFloat)progress:(NSString *)url {
    return [self fileTotalLength:url] == 0 ? 0.0 : 1.0 * KNBDownloadLength(url) /  [self fileTotalLength:url];
}

- (NSInteger)fileTotalLength:(NSString *)url {
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:KNBDownloadTotalLengthFullpath];
    return [dic[KNBDownloadFileName(url)] integerValue];
}

- (void)deleteFile:(NSString *)url
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:KNBDownloadCachesFullpath(url)]) {
        
        // 删除沙盒中的资源
        [fileManager removeItemAtPath:KNBDownloadCachesFullpath(url) error:nil];
        // 删除任务
        [self.tasks removeObjectForKey:KNBDownloadFileName(url)];
        [self.sessionModels removeObjectForKey:@([self getTask:url].taskIdentifier).stringValue];
        // 删除资源总长度
        if ([fileManager fileExistsAtPath:KNBDownloadTotalLengthFullpath]) {
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:KNBDownloadTotalLengthFullpath];
            [dict removeObjectForKey:KNBDownloadFileName(url)];
            [dict writeToFile:KNBDownloadTotalLengthFullpath atomically:YES];
            
        }
        if ([fileManager fileExistsAtPath:KNBDownloadingFile]) {
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:KNBDownloadingFile];
            [dict removeObjectForKey:url];
            [dict writeToFile:KNBDownloadingFile atomically:YES];
            
        }
    }
}

- (void)deleteAllFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:KNBDownloadCachesDirectory]) {
        // 删除沙盒中所有资源
        [fileManager removeItemAtPath:KNBDownloadCachesDirectory error:nil];
        // 删除任务
        [[self.tasks allValues] makeObjectsPerformSelector:@selector(cancel)];
        [self.tasks removeAllObjects];
        
        for (KNBDownloadModel *sessionModel in [self.sessionModels allValues]) {
            [sessionModel.stream close];
        }
        [self.sessionModels removeAllObjects];
        
        // 删除资源总长度
        if ([fileManager fileExistsAtPath:KNBDownloadTotalLengthFullpath]) {
            [fileManager removeItemAtPath:KNBDownloadTotalLengthFullpath error:nil];
        }
        if ([fileManager fileExistsAtPath:KNBDownloadingFile]) {
            [fileManager removeItemAtPath:KNBDownloadingFile error:nil];
        }
    }
}

- (NSArray *)getAllDownLoadRequest {
    return [NSDictionary dictionaryWithContentsOfFile:KNBDownloadingFile].allKeys;
}

#pragma mark - Private Method
- (void)createDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:KNBDownloadCachesDirectory]) {
        [fileManager createDirectoryAtPath:KNBDownloadCachesDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

- (NSURLSessionDataTask *)getTask:(NSString *)url {
    return (NSURLSessionDataTask *)[self.tasks valueForKey:KNBDownloadFileName(url)];
}

- (KNBDownloadModel *)getSessionModel:(NSUInteger)taskIdentifier {
    return (KNBDownloadModel *)[self.sessionModels valueForKey:@(taskIdentifier).stringValue];
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    KNBDownloadModel *sessionModel = [self getSessionModel:dataTask.taskIdentifier];
    
    // 打开流
    [sessionModel.stream open];
    
    // 获得服务器这次请求 返回数据的总长度
    NSInteger totalLength = [response.allHeaderFields[@"Content-Length"] integerValue] + KNBDownloadLength(sessionModel.url);
    sessionModel.totalLength = totalLength;
    
    // 存储总长度
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:KNBDownloadTotalLengthFullpath];
    if (dict == nil) dict = [NSMutableDictionary dictionary];
    dict[KNBDownloadFileName(sessionModel.url)] = @(totalLength);
    [dict writeToFile:KNBDownloadTotalLengthFullpath atomically:YES];
    
    NSMutableDictionary *downloadDict = [NSMutableDictionary dictionaryWithContentsOfFile:KNBDownloadingFile];
    if (downloadDict == nil) downloadDict = [NSMutableDictionary dictionary];
    downloadDict[sessionModel.url] = KNBDownloadFileName(sessionModel.url);
    [downloadDict writeToFile:KNBDownloadingFile atomically:YES];
    
    // 接收这个请求，允许接收服务器的数据
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    KNBDownloadModel *sessionModel = [self getSessionModel:dataTask.taskIdentifier];
    
    // 写入数据
    [sessionModel.stream write:data.bytes maxLength:data.length];
    
    // 下载进度
    NSUInteger receivedSize = KNBDownloadLength(sessionModel.url);
    NSUInteger expectedSize = sessionModel.totalLength;
    CGFloat progress = 1.0 * receivedSize / expectedSize;
    if (self.progressBlock) {
        self.progressBlock(sessionModel.url ,receivedSize, expectedSize, progress);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    KNBDownloadModel *sessionModel = [self getSessionModel:task.taskIdentifier];
    if (!sessionModel) return;
    
    if ([self isCompletion:sessionModel.url]) {
        if (self.completeBlock) {
            self.completeBlock(sessionModel.url ,KNBDownloadCachesFullpath(sessionModel.url), nil);
        }
    } else if (error){
        if (self.completeBlock) {
            self.completeBlock(sessionModel.url ,nil, error);
        }
    }
    
    [sessionModel.stream close];
    sessionModel.stream = nil;
    
    [self.tasks removeObjectForKey:KNBDownloadFileName(sessionModel.url)];
    [self.sessionModels removeObjectForKey:@(task.taskIdentifier).stringValue];
}

#pragma mark - Getter
- (NSMutableDictionary *)tasks {
    if (!_tasks) {
        _tasks = [NSMutableDictionary dictionary];
    }
    return _tasks;
}

- (NSMutableDictionary *)sessionModels {
    if (!_sessionModels) {
        _sessionModels = [NSMutableDictionary dictionary];
    }
    return _sessionModels;
}

@end
