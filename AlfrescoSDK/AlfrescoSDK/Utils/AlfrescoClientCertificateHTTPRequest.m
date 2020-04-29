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

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    if (challenge.previousFailureCount > 1)
    {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        return;
    }
    
    NSURLProtectionSpace *protectionSpace = challenge.protectionSpace;
    NSString *authenticationMethod = protectionSpace.authenticationMethod;
    
    BOOL isAllowedHost = [self verifyHost:self.requestURL.host matchesHost:challenge.protectionSpace.host];
    if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate] && isAllowedHost && self.credential)
    {
        completionHandler(NSURLSessionAuthChallengeUseCredential, self.credential);
    }
    else if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }
    else
    {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

- (BOOL)verifyHost:(NSString *)host1 matchesHost:(NSString *)host2
{
    if ([host1 isEqualToString:host2])
    {
        return YES;
    }

    NSArray *host1Components = [host1 componentsSeparatedByString:@"."];
    NSArray *host2Components = [host2 componentsSeparatedByString:@"."];

    if (host1Components.count != host2Components.count)
    {
        return NO;
    }

    NSUInteger index = [host1Components indexOfObjectPassingTest:^BOOL(NSString *component1, NSUInteger idx, BOOL *stop) {
        NSString *component2 = host2Components[idx];
        if ([component1 isEqualToString:@"*"] || [component2 isEqualToString:@"*"] || [component1 isEqualToString:component2])
        {
            return NO;
        }

        return YES;
    }];

    return index == NSNotFound;
}

@end
