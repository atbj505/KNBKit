//
//  NSDate+BTAddition.m
//  BEConnector
//
//  Created by andy on 3/18/15.
//  Copyright (c) 2015 NationSky. All rights reserved.
//

#import "NSDate+BTAddition.h"

@implementation NSDate (BTAddition)
- (NSString*)transformToFuzzyDate
{
    NSDate *nowDate = [NSDate date];
    NSUInteger timeInterval = [nowDate timeIntervalSinceDate:self];
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    //  通过已定义的日历对象，获取某个时间点的NSDateComponents表示，并设置需要表示哪些信息（NSYearCalendarUnit, NSMonthCalendarUnit, NSDayCalendarUnit等）
    NSDateComponents *nowDateComponents = [greCalendar components:NSCalendarUnitEra | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | kCFCalendarUnitWeek | NSCalendarUnitWeekday | NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekOfYear fromDate:nowDate];
    
    NSDateComponents *selfDateComponents = [greCalendar components:NSCalendarUnitEra | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | kCFCalendarUnitWeek | NSCalendarUnitWeekday | NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekOfYear fromDate:self];
    
    if (timeInterval < 5 * 60) {
        return @"刚刚";
    }
    else if (timeInterval < 60 * 60) {
        NSString *dateString = [NSString stringWithFormat:@"%u分钟前",timeInterval / 60];
        return dateString;
    }
    else if (timeInterval < 24 * 60 * 60 && nowDateComponents.day == selfDateComponents.day) {
        NSString *dateString = [NSString stringWithFormat:@"%u小时前",timeInterval / (60 * 60)];
        return dateString;
    }
    else if (nowDateComponents.day != selfDateComponents.day && timeInterval < 24 * 60 * 60){
        return @"昨天";
    }
    else if (nowDateComponents.day == (selfDateComponents.day + 1)) {
        return @"昨天";
    }
    else if (nowDateComponents.weekOfMonth == selfDateComponents.weekOfMonth) {
        NSArray *weekdays = @[@"temp",@"星期日",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六"];
        NSString *dateString = weekdays[selfDateComponents.weekday];
        return dateString;
    }
    else if ([self timeIntervalSince1970] == 0) {
        return @"";
    }
    else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd HH:mm"];
        NSString *dateString = [dateFormatter stringFromDate:self];
        return dateString;
    }
}

- (NSString*)promptDateString
{
    NSDate* nowDate = [NSDate date];
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    //  通过已定义的日历对象，获取某个时间点的NSDateComponents表示，并设置需要表示哪些信息（NSYearCalendarUnit, NSMonthCalendarUnit, NSDayCalendarUnit等）
    NSDateComponents *nowDateComponents = [greCalendar components:NSCalendarUnitEra | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | kCFCalendarUnitWeek | NSCalendarUnitWeekday | NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekOfYear fromDate:nowDate];
    
    NSDateComponents *selfDateComponents = [greCalendar components:NSCalendarUnitEra | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | kCFCalendarUnitWeek | NSCalendarUnitWeekday | NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekOfYear fromDate:self];
    
    NSDateComponents *weeDateComponents = [[NSDateComponents alloc] init];
    [weeDateComponents setCalendar:[NSCalendar currentCalendar]];
    weeDateComponents.year = selfDateComponents.year;
    weeDateComponents.month = selfDateComponents.month;
    weeDateComponents.day = selfDateComponents.day;
    weeDateComponents.hour = 0;
    weeDateComponents.minute = 0;
    weeDateComponents.second = 0;
    
    NSDate *weeDate = [[weeDateComponents date] dateByAddingTimeInterval:24 * 60 * 60];
    
    NSString *lastComponents = nil;
//    NSString* twoComponent = nil;
//    NSInteger hour = nowDateComponents.hour;
//    
//    if (hour < 12) {
//        twoComponent = @"am";
//    }
//    else {
//        twoComponent = @"pm";
//        hour = hour - 12;
//    }
    //判断显示小时
    NSString *newHour = nil;
    if (selfDateComponents.hour < 10) {
        newHour = [NSString stringWithFormat:@"0%i",selfDateComponents.hour];
    }
    else {
        newHour = [NSString stringWithFormat:@"%i",selfDateComponents.hour];
    }
    
    //判断显示分钟
    NSString *minute = nil;
    if (selfDateComponents.minute < 10) {
        minute = [NSString stringWithFormat:@"0%i",selfDateComponents.minute];
    }
    else {
        minute = [NSString stringWithFormat:@"%i",selfDateComponents.minute];
    }

    lastComponents = [NSString stringWithFormat:@"%@:%@",newHour,minute];
    
    NSInteger timeInterval = [nowDate timeIntervalSinceDate:weeDate];
    NSString *dateString = nil;
    if (abs(timeInterval) < 24 * 60 * 60)
    {
        if (nowDateComponents.day == selfDateComponents.day) { //同一天判断上下午
            dateString = lastComponents;
        }
        else { //昨天
            dateString = [NSString stringWithFormat:@"%@ %@",@"yesterday",lastComponents];
        }
    }
    else if (nowDateComponents.weekOfMonth == selfDateComponents.weekOfMonth) {         NSArray *weekdays = @[@"temp",@"星期日",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六"];
        NSString* weekdayString = weekdays[selfDateComponents.weekday];
        dateString = [NSString stringWithFormat:@"%@%@",weekdayString,lastComponents];
    }
    else { //判断是否是同一年
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateString = [NSString stringWithFormat:@"%@ %@",[dateFormatter stringFromDate:self],lastComponents];
    }
    return dateString;
}

+ (NSDate *)dateWithTimestamp:(long long)timestamp;
{
    return [NSDate dateWithTimeIntervalSince1970:timestamp];
}

/**
 *  比较时间（self），获取间隔
 */
- (NSInteger)compareWithDate:(NSDate *)date
{
    return fabs([self timeIntervalSinceDate:date]);
}

/**
 *  比较时间（当前时间），获取间隔
 */
+ (NSInteger)compareCurrentTimeWithDate:(NSDate *)date
{
    return [[NSDate date] compareWithDate:date];
}

/**
 *  将字符串时间转换为NSDate
 *
 *  @param dateString 字符串时间 @"yyyy-MM-dd HH:mm:ss"
 *
 *  @return NSDate
 */
+ (NSDate *)getDate:(NSString *)dateString
{
    NSDateFormatter *forma = [[NSDateFormatter alloc] init];
    [forma setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSDate *date = [[NSDate alloc] init];
    NSDate *date = [forma dateFromString:dateString];
    return date;
}

/**
 *  将字符串时间转换为NSDate
 *
 *  @param dateTimeString 字符串时间 HH:mm:ss
 *
 *  @return NSDate
 */
+ (NSDate *)getDateTime:(NSString *)dateTimeString
{
    NSDateFormatter *forma = [[NSDateFormatter alloc] init];
    [forma setDateFormat:@"HH:mm:ss"];
//    NSDate *date = [[NSDate alloc] init];
    NSDate *date = [forma dateFromString:dateTimeString];
    return date;
}

/**
 *  判断是否在当前日期的后7天之内
 *
 *  @param dateString 字符串时间@
 *
 *  @return bool值
 */
+ (BOOL)insideOfSevenDaysWithDateString:(NSString *)dateString
{
    NSDate *date = [self getDate:dateString];
    NSString *currentDataString = [self getTheCurrentDateString];
    NSDate *currentDate = [self getDate:currentDataString];
    NSTimeInterval compareinterVal =  [date timeIntervalSince1970];
    NSTimeInterval currentInterVal = [currentDate timeIntervalSince1970];
    if (compareinterVal < currentInterVal) {
        return NO;
    }
    if ((compareinterVal - currentInterVal) > 7 * 24 * 3600) {
        return NO;
    }
    return YES;
}
/**
 *  判断是否在当前时间之前
 *
 *  @param dateString 字符串时间
 *
 *  @return bool值
 */
+ (BOOL)compareIsBeforeTheCurrentDateWithDateString:(NSString *)dateString {
    NSDate *date = [self getDate:dateString];
    NSString *currentDataString = [self getTheCurrentDateString];
    NSDate *currentDate = [self getDate:[NSString stringWithFormat:@"%@:00", currentDataString]];
    NSTimeInterval compareinterVal =  [date timeIntervalSince1970];
    NSTimeInterval currentInterVal = [currentDate timeIntervalSince1970];
    if (compareinterVal < currentInterVal) {
        return YES;
    }else {
        return NO;
    }
}

+ (NSString *)getTheCurrentDateString
{
    return [self getTheDateStringWithDate:[NSDate date]];
}

+ (NSString *)getTheCurrentDateSimpleFormat {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    return dateString;
}

+ (NSString *)getTheDateStringWithDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

+ (NSArray *)getMonthToTheMonth:(NSDate *)date OfTheMonth:(NSInteger )month {
    NSMutableArray *muDataArray = [NSMutableArray array];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    for (NSInteger i = month - 1; i >= 0; i--) {
        NSDateComponents *adcomps = [[NSDateComponents alloc] init];
        [adcomps setYear:0];
        [adcomps setMonth:-i];
        [adcomps setDay:0];
        NSDate *newdate = [calendar dateByAddingComponents:adcomps toDate:date options:0];
        NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
        [dateformat setDateFormat:@"yyyy-MM"];
        NSString *dateString = [dateformat stringFromDate:newdate];
        [muDataArray addObject:dateString];
    }
    return muDataArray;
}

+ (NSArray *)getMonthFromTheMonth:(NSDate *)date OfTheMonth:(NSInteger )month {
    NSMutableArray *muDataArray = [NSMutableArray array];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    for (NSInteger i = month - 1; i >= 0; i--) {
        NSDateComponents *adcomps = [[NSDateComponents alloc] init];
        [adcomps setYear:0];
        [adcomps setMonth:+i];
        [adcomps setDay:0];
        NSDate *newdate = [calendar dateByAddingComponents:adcomps toDate:date options:0];
        NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
        [dateformat setDateFormat:@"yyyy-MM"];
        NSString *dateString = [dateformat stringFromDate:newdate];
        [muDataArray addObject:dateString];
    }
    return muDataArray;
}

+ (NSString *)stringWithTimestamp:(long long)timestamp {
    NSString *time = [NSString stringWithFormat:@"%lld",timestamp];
    if (time.length > 11) {
        time = [time substringToIndex:10];
        timestamp = [time doubleValue];
    }
    NSDate *date = [self dateWithTimestamp:timestamp];
    NSString *str = [self getTheDateStringWithDate:date];
    return str;
}

+ (NSString *)changeToTimeString:(int)totalSeconds {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
//    int hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];

}

+ (NSString *)getResidualTime:(NSString *)time {
    NSDate *date = [self getDate:time];
    long long timeInterval = [date timeIntervalSinceDate:[NSDate date]];
    if (timeInterval <= 0) {
        return @"0天";
    }
    double hour = (timeInterval % (3600 * 24)) / 3600;
    double day = timeInterval / (24 * 3600);
    NSString *timeStr = @"";
    if (day > 0) {
        timeStr = [timeStr stringByAppendingString:[NSString stringWithFormat:@"%.0f天",day]];
    }
    if (hour > 0) {
        timeStr = [timeStr stringByAppendingString:[NSString stringWithFormat:@"%.0f时",hour]];
    }

    return timeStr;
}

+ (CGFloat)changeToFloatTime:(NSString *)time {
    CGFloat floatTime = 0.0;
    
    NSArray *array = [time componentsSeparatedByString:@":"];
    
    if (array) {
        floatTime = [array[0] intValue] * 60 * 60 + [array[1] intValue] * 60 + [array[2] intValue];
    }
    return floatTime;
}

+ (CGFloat)changeToFloatMinute:(NSString *)time {
    CGFloat floatMinutes = 0.0;
    
    NSArray *array = [time componentsSeparatedByString:@":"];
    
    if (array) {
        floatMinutes = [array[0] intValue] * 60 + [array[1] intValue];
    }
    return floatMinutes;
}

@end
