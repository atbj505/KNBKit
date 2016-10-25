//
//  KNBLogManager.m
//  KenuoTraining
//
//  Created by 吴申超 on 16/3/23.
//  Copyright © 2016年 Robert. All rights reserved.
//

#import "KNBLogManager.h"

@interface KNBLogManager ()

@property (nonatomic, strong) NSFileHandle *fileHandle;

@end

@implementation KNBLogManager

+ (instancetype)shareInstance {
    static KNBLogManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super  init];
    if (self) {
        NSString *logFilePath = [self logFilePath];
        NSLog(@"LogPath=========%@",logFilePath);
        if ([[NSFileManager defaultManager] fileExistsAtPath:logFilePath]) {
            _fileHandle = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
        }
        else {
            [self deleteOldLogFile];
            if ([[NSFileManager defaultManager] createFileAtPath:logFilePath contents:nil attributes:nil]) {
                _fileHandle = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
            }
        }
    }
    return self;
}

- (void)log:(NSString *)logMsg {
    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(dispatchQueue, ^(void) {
        if (_fileHandle) {
            [_fileHandle seekToEndOfFile];
            [_fileHandle writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
            NSString *timeString = [NSString stringWithFormat:@"\n====%@====\n",[self dateFormatter:@"MM:dd HH:mm:ss"]];
            
            if ([logMsg isEqualToString:@"\n"]) {
                [_fileHandle writeData:[timeString dataUsingEncoding:NSUTF8StringEncoding]];
                [_fileHandle writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [_fileHandle writeData:[@"\n==========\n" dataUsingEncoding:NSUTF8StringEncoding]];
            }
            else {
                [_fileHandle writeData:[timeString dataUsingEncoding:NSUTF8StringEncoding]];
                [_fileHandle writeData:[logMsg dataUsingEncoding:NSUTF8StringEncoding]];
                [_fileHandle writeData:[@"\n==========\n" dataUsingEncoding:NSUTF8StringEncoding]];
            }
        }
    });
}


/**
  * 删除旧的文件
  */
- (void)deleteOldLogFile {
    NSString *extension = @"txt";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        if ([[filename pathExtension] isEqualToString:extension]) {
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
        }
    }
}

/**
 * 文件保存路径
 */
- (NSString *)logFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSMutableString *path = [[NSMutableString alloc] initWithString:documentsDirectory];
    [path appendString:[NSString stringWithFormat:@"/Log_%@.txt", [self dateFormatter:@"yyyy-MM-dd"]]];
    return path;
}


/**
 * 获取文件时间
 */
- (NSString *)dateFormatter:(NSString *)matter {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:matter];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    return dateTime;
}

@end
