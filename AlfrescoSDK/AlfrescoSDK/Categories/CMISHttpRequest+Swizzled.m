/*
 ******************************************************************************
 * Copyright (C) 2005-2014 Alfresco Software Limited.
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

#import "CMISHttpRequest+Swizzled.h"
#import <objc/runtime.h>
#import "CMISLog.h"
#import "CMISErrors.h"
#import "AlfrescoReachability.h"

@implementation CMISHttpRequest (Swizzled)

+ (void)load
{
    Method originalMethod = class_getInstanceMethod(self, @selector(startRequest:));
    Method swizzledMethod = class_getInstanceMethod(self, @selector(startRequestSwizzled:));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (BOOL)startRequestSwizzled:(NSMutableURLRequest *)urlRequest
{
    BOOL startedRequest = NO;
    
    if (self.requestBody)
    {
        if ([CMISLog sharedInstance].logLevel == CMISLogLevelTrace)
        {
            CMISLogTrace(@"Request body: %@", [[NSString alloc] initWithData:self.requestBody encoding:NSUTF8StringEncoding]);
        }
        
        [urlRequest setHTTPBody:self.requestBody];
    }
    
    [self.authenticationProvider.httpHeadersToApply enumerateKeysAndObjectsUsingBlock:^(NSString *headerName, NSString *header, BOOL *stop) {
        [urlRequest addValue:header forHTTPHeaderField:headerName];
    }];
    
    [self.additionalHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *headerName, NSString *header, BOOL *stop) {
        [urlRequest addValue:header forHTTPHeaderField:headerName];
    }];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:NO];
    AlfrescoReachability *reach = [AlfrescoReachability internetReachability];
    
    if (self.connection && reach.hasInternetConnection)
    {
        [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [self.connection start];
        startedRequest = YES;
    }
    else if (!reach.hasInternetConnection)
    {
        // Caste the additional error code to CMISErrorCodes
        NSError *noConnectionError = [CMISErrors createCMISErrorWithCode:(CMISErrorCodes)kCMISErrorCodeNoNetworkConnection detailedDescription:kCMISErrorDescriptionNoNetworkConnection];
        [self connection:self.connection didFailWithError:noConnectionError];
    }
    else
    {
        if (self.completionBlock)
        {
            NSString *detailedDescription = [NSString stringWithFormat:@"Could not create connection to %@", urlRequest.URL];
            NSError *cmisError = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeConnection detailedDescription:detailedDescription];
            self.completionBlock(nil, cmisError);
        }
    }
    
    return startedRequest;
}

@end
