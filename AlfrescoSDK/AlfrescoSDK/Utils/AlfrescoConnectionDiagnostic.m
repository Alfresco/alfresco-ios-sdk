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

#import "AlfrescoConnectionDiagnostic.h"
#import "AlfrescoConstants.h" 

@interface AlfrescoConnectionDiagnostic ()
@property (nonatomic, strong) NSString *eventName;
@end

@implementation AlfrescoConnectionDiagnostic

- (instancetype)initWithEventName:(NSString *)eventName
{
    self = [super init];
    if (self)
    {
        _eventName = eventName;
    }
    return self;
}

- (void)notifyEventStart
{
    NSDictionary *userInfo = @{ kAlfrescoConfigurationDiagnosticDictionaryEventName : self.eventName,
                                kAlfrescoConfigurationDiagnosticDictionaryStatus : @(AlfrescoConnectionDiagnosticStatusLoading) };
    [[NSNotificationCenter defaultCenter] postNotificationName:kAlfrescoConfigurationDiagnosticDidStartEventNotification object:nil userInfo:userInfo];
}

- (void)notifyEventSuccess
{
    NSDictionary *userInfo = @{ kAlfrescoConfigurationDiagnosticDictionaryEventName : self.eventName,
                                kAlfrescoConfigurationDiagnosticDictionaryStatus : @(AlfrescoConnectionDiagnosticStatusSuccess) };
    [[NSNotificationCenter defaultCenter] postNotificationName:kAlfrescoConfigurationDiagnosticDidEndEventNotification object:nil userInfo:userInfo];
}

- (void)notifyEventFailureWithError:(NSError *)error
{
    NSDictionary *userInfo = @{ kAlfrescoConfigurationDiagnosticDictionaryEventName : self.eventName,
                                kAlfrescoConfigurationDiagnosticDictionaryStatus : @(AlfrescoConnectionDiagnosticStatusFailure) };
    
    if (error)
    {
        NSMutableDictionary *mutable = [userInfo mutableCopy];
        mutable[kAlfrescoConfigurationDiagnosticDictionaryError] = error;
        userInfo = [NSDictionary dictionaryWithDictionary:mutable];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAlfrescoConfigurationDiagnosticDidEndEventNotification object:nil userInfo:userInfo];
}


@end
