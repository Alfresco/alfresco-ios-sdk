/*
  Licensed to the Apache Software Foundation (ASF) under one
  or more contributor license agreements.  See the NOTICE file
  distributed with this work for additional information
  regarding copyright ownership.  The ASF licenses this file
  to you under the Apache License, Version 2.0 (the
  "License"); you may not use this file except in compliance
  with the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an
  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  KIND, either express or implied.  See the License for the
  specific language governing permissions and limitations
  under the License.
 */

#import "CMISBase64Encoder.h"
#import "CMISStandardAuthenticationProvider.h"
#import "CMISLog.h"

@interface CMISStandardAuthenticationProvider ()
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@end

@implementation CMISStandardAuthenticationProvider


- (id)initWithUsername:(NSString *)username password:(NSString *)password
{
    self = [super init];
    if (self) {
        self.username = username;
        self.password = password;
    }
    
    return self;
}


- (id)initWithCredential:(NSURLCredential *)credential
{
    self = [super init];
    if (self) {
        self.credential = credential;
    }
    return self;
}


- (NSDictionary *)httpHeadersToApply
{
    if (self.username.length > 0 && self.password.length > 0) {
        NSMutableString *loginString = [NSMutableString stringWithFormat:@"%@:%@", self.username, self.password];
        NSString *encodedLoginData = [CMISBase64Encoder stringByEncodingText:[loginString dataUsingEncoding:NSUTF8StringEncoding]];
        NSString *authHeader = [NSString stringWithFormat:@"Basic %@", encodedLoginData];
        return [NSDictionary dictionaryWithObject:authHeader forKey:@"Authorization"];
    }
    return [NSDictionary dictionary];
}


- (BOOL)canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    // default implementation mimics default NSURLConnectionDelegate behavior
    NSString *authenticationMethod = protectionSpace.authenticationMethod;
    if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate] && self.credential.identity) {
        return YES; // client certificate requested and certificate identity available
    }
    if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic] && self.credential.user && self.credential.hasPassword) {
        return YES; // basic authentication requested and username & password available
    }
    
    return NO;
}


- (void)didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    // nothing to do in the default implementation
}


- (void)didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if (challenge.previousFailureCount == 0) {
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate] &&
            self.credential.identity) {
            CMISLogDebug(@"Authenticating with client certificate");
            [challenge.sender useCredential:self.credential forAuthenticationChallenge:challenge];
        } else if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic] &&
                   self.credential.user && self.credential.hasPassword) {
            CMISLogDebug(@"Authenticating with username and password");
            [challenge.sender useCredential:self.credential forAuthenticationChallenge:challenge];
        } else if (challenge.proposedCredential) {
            CMISLogDebug(@"Authenticating with proposed credential");
            [challenge.sender useCredential:challenge.proposedCredential forAuthenticationChallenge:challenge];
        } else {
            CMISLogDebug(@"Authenticating without credential");
            [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
        }
    } else {
        CMISLogDebug(@"Authentication failed, cancelling logon");
        [challenge.sender cancelAuthenticationChallenge:challenge];
    }
}


- (void)updateWithHttpURLResponse:(NSHTTPURLResponse*)httpUrlResponse
{
    // nothing to do in the default implementation
}


@end
