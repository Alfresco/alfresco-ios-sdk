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

#import "AlfrescoClientCertificateHTTPRequest.h"

@interface AlfrescoClientCertificateHTTPRequest ()
@property (nonatomic, strong) NSURLCredential *credential;
@end

@implementation AlfrescoClientCertificateHTTPRequest

- (id)initWithCertificateCredential:(NSURLCredential *)credential
{
    self = [super init];
    if (self)
    {
        self.credential = credential;
    }
    return self;
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    if ([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate] && self.credential.identity)
    {
        // Client certificate requested and certificate identity available
        return YES;
    }
    
    return NO;
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    // nothing to do in the default implementation
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    BOOL isExpectedHost = [self.requestURL.host isEqualToString:challenge.protectionSpace.host];
    if (challenge.previousFailureCount == 0 && isExpectedHost && [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate])
    {
        [[challenge sender] useCredential:self.credential forAuthenticationChallenge:challenge];
    }
    else
    {
        [challenge.sender cancelAuthenticationChallenge:challenge];
    }
}

@end
