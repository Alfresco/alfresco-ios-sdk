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

#import "AlfrescoConnectionDiagnosticUtils.h"
#import "AlfrescoConstants.h" 

@implementation AlfrescoConnectionDiagnosticUtils

+ (NSDictionary *)createDictionaryForStartEventForEventName:(NSString *)eventName
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:eventName forKey:kAlfrescoConfigurationDiagnosticDictionaryEventName];
    [dict setObject:[NSNumber numberWithInteger:ConnectionDiagnosticStatusLoading] forKey:kAlfrescoConfigurationDiagnosticDictionaryStatus];
    
    return dict;
}

+ (NSDictionary *)changeDictionaryForEndEvent:(NSDictionary *)dict isSuccess:(BOOL)isSuccess error:(NSError *)error
{
    NSMutableDictionary *mutableDict = [dict mutableCopy];
    
    if(isSuccess)
    {
        [mutableDict setObject:[NSNumber numberWithInteger:ConnectionDiagnosticStatusSuccess] forKey:kAlfrescoConfigurationDiagnosticDictionaryStatus];
    }
    else
    {
        [mutableDict setObject:[NSNumber numberWithInteger:ConnectionDiagnosticStatusFailure] forKey:kAlfrescoConfigurationDiagnosticDictionaryStatus];
    }
    
    if(!isSuccess && error)
    {
        [mutableDict setObject:error forKey:kAlfrescoConfigurationDiagnosticDictionaryError];
    }
    
    return [mutableDict copy];
}

@end
