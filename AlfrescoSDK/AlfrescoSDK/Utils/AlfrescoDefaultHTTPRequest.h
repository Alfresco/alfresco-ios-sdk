/*
 ******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
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

// The AlfrescoDefaultHTTPRequest class utilizes NSURLSession to make requests.

// Author: Tauseef Mughal (Alfresco)

#import <Foundation/Foundation.h>
#import "AlfrescoConstants.h"
#import "AlfrescoRequest.h"
#import "AlfrescoSession.h"

@interface AlfrescoDefaultHTTPRequest : NSObject <AlfrescoCancellableRequest, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong, readonly) NSURL *requestURL;

- (void)connectWithURL:(NSURL*)requestURL
                method:(NSString *)method
               session:(id<AlfrescoSession>)session
           requestBody:(NSData *)requestBody
       completionBlock:(AlfrescoDataCompletionBlock)completionBlock;

- (void)connectWithURL:(NSURL*)requestURL
                method:(NSString *)method
               session:(id<AlfrescoSession>)session
           requestBody:(NSData *)requestBody
          outputStream:(NSOutputStream *)outputStream
       completionBlock:(AlfrescoDataCompletionBlock)completionBlock;

@end
