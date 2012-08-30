/*******************************************************************************
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
 ******************************************************************************/

#import "AlfrescoBasicAuthenticationProvider.h"
#import "CMISBase64Encoder.h"

@interface AlfrescoBasicAuthenticationProvider ()

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong, readwrite) NSDictionary *httpHeaders;
@property (nonatomic, strong, readwrite) NSDictionary *queryStringParametersToApply;

@end

@implementation AlfrescoBasicAuthenticationProvider

@synthesize username = _username;
@synthesize password = _password;
@synthesize httpHeaders = _httpHeaders;
@synthesize queryStringParametersToApply = _queryStringParametersToApply;

- (id)initWithUsername:(NSString *)username andPassword:(NSString *)password
{
    self = [super init];
    if(self)
    {
        self.username = username;
        self.password = password;
        
        // create a plaintext string in the format username:password
        NSMutableString *loginString = [NSMutableString stringWithFormat:@"%@:%@", self.username, self.password];
        
        // employ the Base64 encoding above to encode the authentication tokens
        NSString *encodedLoginData = [CMISBase64Encoder stringByEncodingText:[loginString dataUsingEncoding:NSUTF8StringEncoding]];
        
        // create the contents of the header 
        NSString *authHeader = [NSString stringWithFormat:@"Basic %@", encodedLoginData];
        NSMutableDictionary *httpHeader = [NSMutableDictionary dictionaryWithCapacity:1];
        [httpHeader setValue:authHeader forKey:@"Authorization"];
        [self willApplyHttpHeaders:httpHeader];
    }
    
    return self;
}

#pragma mark AlfrescoAuthenticationProvider Delegate methods

- (void)willApplyHttpHeaders:(NSDictionary *)httpHeaders
{
    self.httpHeaders = [NSDictionary dictionaryWithDictionary:httpHeaders];
}

- (NSDictionary *)httpHeadersToApply
{
    return self.httpHeaders;
}


@end
