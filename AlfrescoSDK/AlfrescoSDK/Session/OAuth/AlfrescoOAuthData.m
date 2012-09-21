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

#import "AlfrescoOAuthData.h"
#import "AlfrescoInternalConstants.h"

@interface AlfrescoOAuthData ()
@property (nonatomic, strong, readwrite) NSString           * accessToken;
@property (nonatomic, strong, readwrite) NSString           * refreshToken;
@property (nonatomic, strong, readwrite) NSNumber           * expiresIn;
@property (nonatomic, strong, readwrite) NSString           * tokenType;
@property (nonatomic, strong, readwrite) NSString           * scope;
@property (nonatomic, strong, readwrite) NSString           * apiKey;
@property (nonatomic, strong, readwrite) NSString           * secretKey;
@property (nonatomic, strong, readwrite) NSString           * redirectURI;

@end

@implementation AlfrescoOAuthData
@synthesize accessToken = _accessToken;
@synthesize refreshToken = _refreshToken;
@synthesize expiresIn = _expiresIn;
@synthesize tokenType = _tokenType;
@synthesize scope = _scope;
@synthesize apiKey = _apiKey;
@synthesize secretKey = _secretKey;
@synthesize redirectURI = _redirectURI;

- (id)initWithAPIKey:(NSString *)apiKey secretKey:(NSString *)secretKey redirectURI:(NSString *)redirectURI
{
    self = [super init];
    if (nil != self)
    {
        self.apiKey = apiKey;
        self.secretKey = secretKey;
        self.redirectURI = redirectURI;
        self.accessToken = nil;
        self.refreshToken = nil;
        self.expiresIn = nil;
        self.tokenType = nil;
        self.scope = nil;
    }
    return self;
}

- (void)setOAuthDataWithJSONDictionary:(NSDictionary *)jsonDictionary
{
    if (nil != jsonDictionary)
    {
        self.accessToken    = [jsonDictionary valueForKey:kAlfrescoJSONAccessToken];
        self.refreshToken   = [jsonDictionary valueForKey:kAlfrescoJSONRefreshToken];
        self.expiresIn      = [jsonDictionary valueForKey:kAlfrescoJSONExpiresIn];
        self.scope          = [jsonDictionary valueForKey:kAlfrescoJSONScope];
        self.tokenType      = [jsonDictionary valueForKey:kAlfrescoJSONTokenType];
    }
    
}


@end
