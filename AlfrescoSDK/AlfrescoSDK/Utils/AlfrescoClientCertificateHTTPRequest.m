/*
 ******************************************************************************
 * Copyright (C) 2005-2013 Alfresco Software Limited.
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

@property (nonatomic, assign) SecIdentityRef identity;
@property (nonatomic, strong) NSArray *certificates;

@end

@implementation AlfrescoClientCertificateHTTPRequest

- (id)initWithIdentity:(SecIdentityRef)identity certificates:(NSArray *)certificates
{
    self = [super init];
    if (self)
    {
        self.identity = identity;
        self.certificates = certificates;
    }
    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    BOOL isExpectedHost = [self.requestURL.host isEqualToString:challenge.protectionSpace.host];
    if (challenge.previousFailureCount == 0 && isExpectedHost && [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate])
    {
        NSURLCredential *credential = [NSURLCredential credentialWithIdentity:self.identity certificates:self.certificates persistence:NSURLCredentialPersistenceForSession];
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    }
    else
    {
        [challenge.sender cancelAuthenticationChallenge:challenge];
    }
}

@end
