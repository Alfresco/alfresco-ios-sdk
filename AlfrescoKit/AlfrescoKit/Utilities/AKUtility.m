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
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger preservedComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
    
    // Only keep the date components
    NSDate *today = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:[NSDate date]]];
    date = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:date]];
    
    NSDate *earliest = [today earlierDate:date];
    BOOL isTodayEarlierDate = (today == earliest);
    NSDate *latest = isTodayEarlierDate ? date : today;
    
    NSString *(^relativeDateString)(NSString *key, NSInteger param) = ^NSString *(NSString *key, NSInteger param) {
        NSString *dateKey = [NSString stringWithFormat:@"relative.date.%@.%@", isTodayEarlierDate ? @"future" : @"past", key];
        return [NSString stringWithFormat:AKLocalizedString(dateKey, @"Date string"), param];
    };
    
    NSTimeInterval seconds_ago = [latest timeIntervalSinceDate:earliest];
    if (seconds_ago < 86400) // 24*60*60
    {
        return AKLocalizedString(@"relative.date.today", @"Today");;
    }
    
    double days_ago = round(seconds_ago / 86400); // 24*60*60
    if (days_ago == 1)
    {
        return relativeDateString(@"one-day", 0);
    }
    
    double weeks_ago = round(days_ago / 7);
    if (days_ago < 7)
    {
        return relativeDateString(@"n-days", days_ago);
    }
    if (weeks_ago == 1)
    {
        return relativeDateString(@"one-week", 0);
    }
    
    double months_ago = round(days_ago / 30);
    if (days_ago < 30)
    {
        return relativeDateString(@"n-weeks", weeks_ago);
    }
    if (months_ago == 1)
    {
        return relativeDateString(@"one-month", 0);
    }
    
    double years_ago = round(days_ago / 365);
    if (days_ago < 365)
    {
        return relativeDateString(@"n-months", months_ago);
    }
    if (years_ago == 1)
    {
        return relativeDateString(@"one-year", 0);
    }
    
    return relativeDateString(@"n-years", years_ago);
}

+ (NSString *)stringForFileSize:(unsigned long long)fileSize
{
    double floatSize = fileSize;
    if (fileSize < 1023)
    {
        
        return([NSString stringWithFormat:@"%llu %@", fileSize, AKLocalizedString(@"file.size.bytes", @"file bytes, used as follows: '100 bytes'")]);
    }
    
    floatSize = floatSize / 1024;
    if (floatSize < 1023)
    {
        return([NSString stringWithFormat:@"%1.1f %@", floatSize, AKLocalizedString(@"file.size.kilobytes", @"Abbreviation for Kilobytes, used as follows: '17KB'")]);
    }
    
    floatSize = floatSize / 1024;
    if (floatSize < 1023)
    {
        
        return([NSString stringWithFormat:@"%1.1f %@", floatSize, AKLocalizedString(@"file.size.megabytes", @"AAbbreviation for Megabytes, used as follows: '2MB'")]);
    }
    
    floatSize = floatSize / 1024;
    
    
    return ([NSString stringWithFormat:@"%1.1f %@", floatSize, AKLocalizedString(@"file.size.gigabytes", @"Abbrevation for Gigabyte, used as follows: '1GB'")]);
}

+ (UIImage *)smallIconForType:(NSString *)type
{
    type = [type lowercaseString];
    
    if (!smallIconMappings)
    {
        NSString *plistPath = [[NSBundle alfrescoKitBundle] pathForResource:kSmallThumbnailImageMappingPlist ofType:@"plist"];
        smallIconMappings = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    }
    
    NSString *imageName = [smallIconMappings objectForKey:type];
    
    if (!imageName)
    {
        imageName = @"small_document.png";
    }
    
    return [UIImage imageFromAlfrescoKitBundleNamed:imageName];
}

+ (NSString *)onPremiseServerURLWithProtocol:(NSString *)protocol serverAddress:(NSString *)serverAddress port:(NSString *)port
{
    return [NSString stringWithFormat:kAlfrescoOnPremiseServerURLFormatString, protocol, serverAddress, port];
}

@end
