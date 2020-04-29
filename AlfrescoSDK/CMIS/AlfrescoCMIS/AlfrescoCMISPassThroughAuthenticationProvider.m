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

#import "AlfrescoCMISPassThroughAuthenticationProvider.h"
#import "AlfrescoLog.h"

@interface AlfrescoCMISPassThroughAuthenticationProvider ()
@property (nonatomic, strong, readwrite) id<AlfrescoAuthenticationProvider> authProvider;
@property (nonatomic, strong, readwrite) NSDictionary *httpHeadersToApply;
@end

@implementation AlfrescoCMISPassThroughAuthenticationProvider

- (id)initWithAlfrescoAuthenticationProvider:(id<AlfrescoAuthenticationProvider>)authProvider
{
    self = [super init];
    if (nil != self)
    {
        self.authProvider = authProvider;
        self.httpHeadersToApply = [authProvider willApplyHTTPHeadersForSession:nil];
    }
    return self;
}


- (void)updateWithHttpURLResponse:(NSHTTPURLResponse *)httpUrlResponse
{
    // No-op
}

- (BOOL)canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return YES;
}

- (void)didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    // No-op
}

- (void)didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if (challenge.previousFailureCount == 0)
    {
        /**
         * Note: The AlfrescoSDK does not specifically support additional authentication method schemes including:
         *    NSURLAuthenticationMethodHTTPBasic
         *    NSURLAuthenticationMethodHTTPDigest
         *    NSURLAuthenticationMethodNTLM
         * unless the authentication crediential are passed in the request header.
         *
         * The SDK handles NSURLAuthenticationMethodClientCertificate in AlfrescoClientCertificateHTTPRequest
         */

        if (challenge.proposedCredential)
        {
            AlfrescoLogDebug(@"Authenticating with proposed credential");
            [challenge.sender useCredential:challenge.proposedCredential forAuthenticationChallenge:challenge];
        }
        else
        {
            AlfrescoLogDebug(@"Authenticating without credential");
            [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
        }
    }
    else
    {
        AlfrescoLogDebug(@"Authentication failed, cancelling logon");
        [challenge.sender cancelAuthenticationChallenge:challenge];
    }
}

- (void)didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
          completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    if (challenge.previousFailureCount == 0)
    {
        if (challenge.proposedCredential)
        {
            AlfrescoLogDebug(@"Authenticating with proposed credential");
            completionHandler(NSURLSessionAuthChallengeUseCredential, challenge.proposedCredential);
        }
        else
        {
            AlfrescoLogDebug(@"Authenticating without credential");
            completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
        }
    }
    else
    {
        AlfrescoLogDebug(@"Authentication failed, cancelling logon");
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

@end
