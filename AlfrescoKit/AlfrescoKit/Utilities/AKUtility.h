//
//  AKUtility.h
//  AlfrescoKit
//
//  Created by Tauseef Mughal on 09/01/2015.
//  Copyright (c) 2015 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AKUtility : NSObject

+ (NSString *)stringDateFromDate:(NSDate *)date;
+ (NSString *)stringForFileSize:(unsigned long long)fileSize;
+ (UIImage *)smallIconForType:(NSString *)type;

@end
