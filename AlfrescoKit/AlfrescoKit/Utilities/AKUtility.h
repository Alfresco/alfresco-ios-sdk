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

/** Utility class to provide helper functions to AlfrescoKit
 
 Author: Tauseef Mughal (Alfresco)
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AKUtility : NSObject

+ (NSString *)stringDateFromDate:(NSDate *)date;
+ (NSString *)stringForFileSize:(unsigned long long)fileSize;
+ (UIImage *)smallIconForType:(NSString *)type;

+ (NSString *)onPremiseServerURLWithProtocol:(NSString *)protocol serverAddress:(NSString *)serverAddress port:(NSString *)port;

@end
