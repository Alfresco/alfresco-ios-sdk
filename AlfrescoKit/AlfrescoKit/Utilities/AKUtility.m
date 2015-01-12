/*
 ******************************************************************************
 * Copyright (C) 2005-2015 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Mobile SDK.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *****************************************************************************
 */

#import "AKUtility.h"

static NSDictionary *smallIconMappings;
static NSString * const kSmallThumbnailImageMappingPlist = @"SmallThumbnailImageMapping";

@implementation AKUtility

+ (NSString *)stringDateFromDate:(NSDate *)date
{
    if (nil == date)
    {
        return @"";
    }
    
    NSDate *today = [NSDate date];
    NSDate *earliest = [today earlierDate:date];
    BOOL isTodayEarlierDate = (today == earliest);
    NSDate *latest = isTodayEarlierDate ? date : today;
    
    NSString *(^relativeDateString)(NSString *key, NSInteger param) = ^NSString *(NSString *key, NSInteger param) {
        NSString *dateKey = [NSString stringWithFormat:@"relative.date.%@.%@", isTodayEarlierDate ? @"future" : @"past", key];
        return [NSString stringWithFormat:NSLocalizedString(dateKey, @"Date string"), param];
    };
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *components = [calendar components:unitFlags fromDate:earliest toDate:latest options:0];
    
    if (components.year >= 2)
    {
        return relativeDateString(@"n-years", components.year);
    }
    else if (components.year >= 1)
    {
        return relativeDateString(@"one-year", components.year);
    }
    else if (components.month >= 2)
    {
        return relativeDateString(@"n-months", components.month);
    }
    else if (components.month >= 1)
    {
        return relativeDateString(@"one-month", components.month);
    }
    else if (components.day >= 14)
    {
        return relativeDateString(@"n-weeks", floor(components.day / 7.0));
    }
    else if (components.day >= 7)
    {
        return relativeDateString(@"one-week", floor(components.day / 7.0));
    }
    else if (components.day >= 2)
    {
        return relativeDateString(@"n-days", components.day);
    }
    else if (components.day >= 1)
    {
        return relativeDateString(@"one-day", components.day);
    }
    else if (components.hour >= 2)
    {
        return relativeDateString(@"n-hours", components.hour);
    }
    else if (components.hour >= 1)
    {
        return relativeDateString(@"one-hour", components.hour);
    }
    else if (components.minute >= 2)
    {
        return relativeDateString(@"n-minutes", components.minute);
    }
    else if (components.minute >= 1)
    {
        return relativeDateString(@"one-minute", components.minute);
    }
    else if (components.second >= 2)
    {
        return relativeDateString(@"n-seconds", components.second);
    }
    
    return NSLocalizedString(@"relative.date.just-now", @"Just now");
}

+ (NSString *)stringForFileSize:(unsigned long long)fileSize
{
    double floatSize = fileSize;
    if (fileSize < 1023)
    {
        return([NSString stringWithFormat:@"%llu %@", fileSize, NSLocalizedString(@"file.size.bytes", @"file bytes, used as follows: '100 bytes'")]);
    }
    
    floatSize = floatSize / 1024;
    if (floatSize < 1023)
    {
        return([NSString stringWithFormat:@"%1.1f %@",floatSize, NSLocalizedString(@"file.size.kilobytes", @"Abbreviation for Kilobytes, used as follows: '17KB'")]);
    }
    
    floatSize = floatSize / 1024;
    if (floatSize < 1023)
    {
        return([NSString stringWithFormat:@"%1.1f %@",floatSize, NSLocalizedString(@"file.size.megabytes", @"Abbreviation for Megabytes, used as follows: '2MB'")]);
    }
    
    floatSize = floatSize / 1024;
    
    return ([NSString stringWithFormat:@"%1.1f %@",floatSize, NSLocalizedString(@"file.size.gigabytes", @"Abbrevation for Gigabyte, used as follows: '1GB'")]);
}

+ (UIImage *)smallIconForType:(NSString *)type
{
    type = [type lowercaseString];
    
    if (!smallIconMappings)
    {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:kSmallThumbnailImageMappingPlist ofType:@"plist"];
        smallIconMappings = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    }
    
    NSString *imageName = [smallIconMappings objectForKey:type];
    
    if (!imageName)
    {
        imageName = @"small_document.png";
    }
    
    return [UIImage imageNamed:imageName];
}

@end
