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
@property (nonatomic, strong, readwrite) NSString           * sessionState;
@property (nonatomic, strong, readwrite) NSNumber           * refreshTokenExpiresIn;
@end

@implementation AlfrescoOAuthData

- (id)initWithTokenType:(NSString *)tokenType
          accessToken:(NSString *)accessToken
 accessTokenExpiresIn:(NSNumber *)expiresIn
         refreshToken:(NSString *)refreshToken
refreshTokenExpiresIn:(NSNumber *)refreshTokenExpiresIn
           sessionState:(NSString *)sessionState
{
    self = [super init];
    
    if (nil != self)
    {
        self.tokenType = tokenType;
        self.accessToken = accessToken;
        self.expiresIn = expiresIn;
        self.refreshToken = refreshToken;
        self.refreshTokenExpiresIn = refreshTokenExpiresIn;
        self.sessionState = sessionState;
        self.scope = nil;
        self.apiKey = nil;
        self.secretKey = nil;
        self.redirectURI = nil;
    }
    
    return self;
}

- (id)initWithAPIKey:(NSString *)apiKey secretKey:(NSString *)secretKey
{
    return [self initWithAPIKey:apiKey secretKey:secretKey redirectURI:kAlfrescoCloudDefaultRedirectURI jsonDictionary:nil];
}

- (id)initWithAPIKey:(NSString *)apiKey secretKey:(NSString *)secretKey redirectURI:(NSString *)redirectURI
{
    return [self initWithAPIKey:apiKey secretKey:secretKey redirectURI:redirectURI jsonDictionary:nil];
}

- (id)initWithAPIKey:(NSString *)apiKey secretKey:(NSString *)secretKey jsonDictionary:(NSDictionary *)jsonDictionary
{
    return [self initWithAPIKey:apiKey secretKey:secretKey redirectURI:kAlfrescoCloudDefaultRedirectURI jsonDictionary:jsonDictionary];    
}

- (id)initWithAPIKey:(NSString *)apiKey secretKey:(NSString *)secretKey redirectURI:(NSString *)redirectURI jsonDictionary:(NSDictionary *)jsonDictionary
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
        if (nil != jsonDictionary)
        {
            self.accessToken    = [jsonDictionary valueForKey:kAlfrescoJSONAccessToken];
            self.refreshToken   = [jsonDictionary valueForKey:kAlfrescoJSONRefreshToken];
            self.expiresIn      = [jsonDictionary valueForKey:kAlfrescoJSONExpiresIn];
            self.scope          = [jsonDictionary valueForKey:kAlfrescoJSONScope];
            self.tokenType      = [jsonDictionary valueForKey:kAlfrescoJSONTokenType];
            
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if (nil != self.apiKey)
    {
        [aCoder encodeObject:self.apiKey forKey:@"apiKey"];
    }
    if (nil != self.secretKey)
    {
        [aCoder encodeObject:self.secretKey forKey:@"secretKey"];
    }
    if (nil != self.accessToken)
    {
        [aCoder encodeObject:self.accessToken forKey:@"accessToken"];
    }
    if (nil != self.refreshToken)
    {
        [aCoder encodeObject:self.refreshToken forKey:@"refreshToken"];
    }
    if (nil != self.expiresIn)
    {
        [aCoder encodeObject:self.expiresIn forKey:@"expiresIn"];
    }
    if (nil != self.tokenType)
    {
        [aCoder encodeObject:self.tokenType forKey:@"tokenType"];
    }
    if (nil != self.redirectURI)
    {
        [aCoder encodeObject:self.redirectURI forKey:@"redirectURI"];
    }
    if (nil != self.scope)
    {
        [aCoder encodeObject:self.scope forKey:@"scope"];
    }
    if (nil != self.sessionState)
    {
        [aCoder encodeObject:self.scope forKey:@"sessionState"];
    }
    if (nil != self.refreshTokenExpiresIn)
    {
        [aCoder encodeObject:self.scope forKey:@"refreshTokenExpiresIn"];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSString *apiKey = [aDecoder decodeObjectForKey:@"apiKey"];
    NSString *secretKey = [aDecoder decodeObjectForKey:@"secretKey"];
    NSString *redirectURI = [aDecoder decodeObjectForKey:@"redirectURI"];
    
    NSString *accessToken = [aDecoder decodeObjectForKey:@"accessToken"];
    NSString *refreshToken = [aDecoder decodeObjectForKey:@"refreshToken"];
    NSNumber *expiresIn = [aDecoder decodeObjectForKey:@"expiresIn"];
    NSString *tokenType = [aDecoder decodeObjectForKey:@"tokenType"];
    NSString *scope = [aDecoder decodeObjectForKey:@"scope"];
    NSString *sessionState = [aDecoder decodeObjectForKey:@"sessionState"];
    NSNumber *refreshTokenExpiresIn = [aDecoder decodeObjectForKey:@"refreshTokenExpiresIn"];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (nil != accessToken)
    {
        dictionary[kAlfrescoJSONAccessToken] = accessToken;
    }
    if (nil != refreshToken)
    {
        dictionary[kAlfrescoJSONRefreshToken] = refreshToken;
    }
    if (nil != expiresIn)
    {
        dictionary[kAlfrescoJSONExpiresIn] = expiresIn;
    }
    if (nil != tokenType)
    {
        dictionary[kAlfrescoJSONTokenType] = tokenType;
    }
    if (nil != scope)
    {
        dictionary[kAlfrescoJSONScope] = scope;
    }
    if (nil != sessionState)
    {
        return [self initWithTokenType:tokenType accessToken:accessToken accessTokenExpiresIn:expiresIn refreshToken:refreshToken refreshTokenExpiresIn:refreshTokenExpiresIn sessionState:sessionState];
    }
    
    if (0 < dictionary.count)
    {
        return [self initWithAPIKey:apiKey secretKey:secretKey redirectURI:redirectURI jsonDictionary:dictionary];
    }
    else
    {
        return [self initWithAPIKey:apiKey secretKey:secretKey redirectURI:redirectURI];
    }    
}

- (BOOL)areCredentialValid {
    NSDate *tokenExpireDate = [NSDate dateWithTimeIntervalSince1970:self.expiresIn.doubleValue];
    //Substract sessionExpirationTimeIntervalCheck time
    NSDate *currentDateThreshold = [tokenExpireDate dateByAddingTimeInterval:-kAlfrescoSessionExpirationTimeIntervalCheck];
    
    if ([NSDate.date compare:currentDateThreshold] == NSOrderedDescending ||
        [NSDate.date compare:tokenExpireDate] == NSOrderedDescending) {
        return NO;
    }
    
    return YES;
}

@end
