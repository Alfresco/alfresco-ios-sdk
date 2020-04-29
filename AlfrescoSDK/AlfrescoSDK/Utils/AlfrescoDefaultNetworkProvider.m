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

#import "AlfrescoDefaultNetworkProvider.h"
#import "AlfrescoErrors.h"
#import "AlfrescoDefaultHTTPRequest.h"
#import "AlfrescoUntrustedSSLHTTPRequest.h"
#import "AlfrescoClientCertificateHTTPRequest.h"
#import "AlfrescoInternalConstants.h"

@implementation AlfrescoDefaultNetworkProvider

- (void)executeRequestWithURL:(NSURL *)url
                      session:(id<AlfrescoSession>)session
              alfrescoRequest:(AlfrescoRequest *)alfrescoRequest
              completionBlock:(AlfrescoDataCompletionBlock)completionBlock
{
    [self executeRequestWithURL:url session:session requestBody:nil method:kAlfrescoHTTPGet alfrescoRequest:alfrescoRequest completionBlock:completionBlock];
}

- (void)executeRequestWithURL:(NSURL *)url
                      session:(id<AlfrescoSession>)session
              alfrescoRequest:(AlfrescoRequest *)alfrescoRequest
                 outputStream:(NSOutputStream *)outputStream
              completionBlock:(AlfrescoDataCompletionBlock)completionBlock
{
    [self executeRequestWithURL:url session:session requestBody:nil method:kAlfrescoHTTPGet alfrescoRequest:alfrescoRequest outputStream:outputStream completionBlock:completionBlock];
}

- (void)executeRequestWithURL:(NSURL *)url
                      session:(id<AlfrescoSession>)session
                       method:(NSString *)method
              alfrescoRequest:(AlfrescoRequest *)alfrescoRequest
              completionBlock:(AlfrescoDataCompletionBlock)completionBlock
{
    [self executeRequestWithURL:url session:session requestBody:nil method:method alfrescoRequest:alfrescoRequest completionBlock:completionBlock];
}

/**
 * The request is handed off to the appropriate HTTPRequest class, depending on the SSL trust flag
 */
- (void)executeRequestWithURL:(NSURL *)url
                      session:(id<AlfrescoSession>)session
                  requestBody:(NSData *)requestBody
                       method:(NSString *)method
              alfrescoRequest:(AlfrescoRequest *)alfrescoRequest
              completionBlock:(AlfrescoDataCompletionBlock)completionBlock
{
    [self executeRequestWithURL:url session:session requestBody:requestBody method:method alfrescoRequest:alfrescoRequest outputStream:nil completionBlock:completionBlock];
}

- (void)executeRequestWithURL:(NSURL *)url
                      session:(id<AlfrescoSession>)session
                  requestBody:(NSData *)requestBody
                       method:(NSString *)method
              alfrescoRequest:(AlfrescoRequest *)alfrescoRequest
                 outputStream:(NSOutputStream *)outputStream
              completionBlock:(AlfrescoDataCompletionBlock)completionBlock
{
    BOOL allowUntrustedSSLCertificate = NO;
    BOOL connectUsingClientCertificate = NO;
    
    id obj = [session objectForParameter:kAlfrescoAllowUntrustedSSLCertificate];
    if (obj != nil)
    {
        allowUntrustedSSLCertificate = [obj boolValue];
    }
    
    id useClientCertificate = [session objectForParameter:kAlfrescoConnectUsingClientSSLCertificate];
    if (useClientCertificate != nil)
    {
        connectUsingClientCertificate = [useClientCertificate boolValue];
    }
    
    AlfrescoDefaultHTTPRequest *alfrescoHTTPRequest = nil;
    if (connectUsingClientCertificate)
    {
        NSURLCredential *credential = [session objectForParameter:kAlfrescoClientCertificateCredentials];
        alfrescoHTTPRequest = [[AlfrescoClientCertificateHTTPRequest alloc] initWithCertificateCredential:credential];
    }
    else if (allowUntrustedSSLCertificate)
    {
        alfrescoHTTPRequest = [[AlfrescoUntrustedSSLHTTPRequest alloc] init];
    }
    else
    {
        alfrescoHTTPRequest = [[AlfrescoDefaultHTTPRequest alloc] init];
    }
    
    if (alfrescoHTTPRequest && !alfrescoRequest.isCancelled)
    {
        if (outputStream)
        {
            [alfrescoHTTPRequest connectWithURL:url
                                         method:method
                                        session:session
                                    requestBody:requestBody
                                   outputStream:outputStream
                                completionBlock:completionBlock];
        }
        else
        {
            [alfrescoHTTPRequest connectWithURL:url
                                         method:method
                                        session:session
                                    requestBody:requestBody
                                completionBlock:completionBlock];
        }
        alfrescoRequest.httpRequest = alfrescoHTTPRequest;
    }
    else
    {
        NSError *error = nil;
        if (alfrescoRequest.isCancelled)
        {
            error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeNetworkRequestCancelled];
        }
        else
        {
            error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeUnknown];
        }
        if (completionBlock != NULL)
        {
            completionBlock(nil, error);
        }
    }
}

@end
