/*
 ******************************************************************************
 * Copyright (C) 2005-2012 Alfresco Software Limited.
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

#import "AlfrescoDefaultNetworkProvider.h"
#import "AlfrescoErrors.h"
#import "AlfrescoSession.h"
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoDefaultHTTPRequest.h"
#import "AlfrescoInternalConstants.h"

@interface AlfrescoDefaultNetworkProvider ()

- (void)requestWithURL:(NSURL *)requestURL
                method:(NSString *)method
               headers:(NSDictionary *)header
           requestBody:(NSData *)data
       completionBlock:(AlfrescoDataCompletionBlock)completionBlock;
@end

@implementation AlfrescoDefaultNetworkProvider

- (void)executeRequestWithURL:(NSURL *)url
                      session:(id<AlfrescoSession>)session
              completionBlock:(AlfrescoDataCompletionBlock)completionBlock
{
    [self executeRequestWithURL:url session:session requestBody:nil method:kAlfrescoHTTPGet completionBlock:completionBlock];
}

- (void)executeRequestWithURL:(NSURL *)url
                      session:(id<AlfrescoSession>)session
                       method:(NSString *)method
              completionBlock:(AlfrescoDataCompletionBlock)completionBlock
{
    [self executeRequestWithURL:url session:session requestBody:nil method:method completionBlock:completionBlock];
}


- (void)executeRequestWithURL:(NSURL *)url
                      session:(id<AlfrescoSession>)session
                  requestBody:(NSData *)requestBody
                       method:(NSString *)method
              completionBlock:(AlfrescoDataCompletionBlock)completionBlock
{
    id authenticationProvider = [session objectForParameter:kAlfrescoAuthenticationProviderObjectKey];
    NSDictionary *httpHeaders = [authenticationProvider willApplyHTTPHeadersForSession:nil];
    [self requestWithURL:url method:method headers:httpHeaders requestBody:requestBody completionBlock:completionBlock];
}

- (void)requestWithURL:(NSURL *)requestURL
                method:(NSString *)method
               headers:(NSDictionary *)header
           requestBody:(NSData *)data
       completionBlock:(AlfrescoDataCompletionBlock)completionBlock;
{
    AlfrescoDefaultHTTPRequest *alfrescoDefaultRequest = [[AlfrescoDefaultHTTPRequest alloc] init];
    if (alfrescoDefaultRequest)
    {
        [alfrescoDefaultRequest connectWithURL:requestURL method:method header:header requestBody:data completionBlock:completionBlock];
    }
    else
    {
        completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeUnknown]);
    }
}

@end
