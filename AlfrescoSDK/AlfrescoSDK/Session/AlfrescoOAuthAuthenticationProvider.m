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

#import "AlfrescoOAuthAuthenticationProvider.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoErrors.h"
#import "AlfrescoSessionDelegate.h"

@interface AlfrescoOAuthAuthenticationProvider ()
@property (nonatomic, strong, readwrite) NSMutableDictionary *httpHeaders;
@property (nonatomic, strong, readwrite) AlfrescoOAuthData *oauthData;
@property (nonatomic, strong, readwrite) NSURLConnection    * connection;
@property (nonatomic, strong, readwrite) NSMutableData      * receivedData;
@property (nonatomic, weak) id<AlfrescoSessionDelegate> sessionDelegate;
- (NSDictionary *)dictionaryFromJSONResponseWithError:(NSError **)outError;
@end

@implementation AlfrescoOAuthAuthenticationProvider
@synthesize httpHeaders = _httpHeaders;
@synthesize oauthData = _oauthData;
@synthesize connection = _connection;
@synthesize receivedData = _receivedData;


- (id)initWithOAuthData:(AlfrescoOAuthData *)oauthData
{
    self = [super init];
    if (nil != self)
    {
        self.oauthData = oauthData;
    }
    return self;
}





#pragma AlfrescoAuthenticationProvider method

- (NSDictionary *)willApplyHTTPHeadersForSession:(id<AlfrescoSession>)session
{
    if (nil == self.httpHeaders)
    {
        self.httpHeaders = [NSMutableDictionary dictionary];
        NSString *authHeader = [NSString stringWithFormat:@"%@ %@",self.oauthData.tokenType ,self.oauthData.accessToken];
        [self.httpHeaders setValue:authHeader forKey:@"Authorization"];
    }
    return self.httpHeaders;
}


- (void)sessionDidExpire:(id<AlfrescoSession>)session
{
    if (nil == session)
    {
        return;
    }
    self.sessionDelegate = session.sessionDelegate;
    if (nil != self.sessionDelegate)
    {
        if ([self.sessionDelegate respondsToSelector:@selector(sessionWillRefresh)])
        {
            [self.sessionDelegate sessionWillRefresh];
        }
    }
    NSString *baseURL = kAlfrescoOAuthCloudURL;
    if ([[session allParameterKeys] containsObject:kAlfrescoCloudTestParameter])
    {
        BOOL isTest = [[session objectForParameter:kAlfrescoCloudTestParameter] boolValue];
        if (isTest)
        {
            baseURL = kAlfrescoOAuthTestCloudURL;
        }
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:baseURL]
                                                           cachePolicy: NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval: 60];
    [request setHTTPMethod:@"POST"];
    NSMutableString *contentString = [NSMutableString string];
    NSString *refreshToken   = [kAlfrescoOAuthRefreshToken stringByReplacingOccurrencesOfString:kAlfrescoCode withString:self.oauthData.refreshToken];
    NSString *clientID = [kAlfrescoOAuthClientID stringByReplacingOccurrencesOfString:kAlfrescoClientID withString:self.oauthData.apiKey];
    NSString *secretID = [kAlfrescoOAuthClientSecret stringByReplacingOccurrencesOfString:kAlfrescoClientSecret withString:self.oauthData.secretKey];
    
    [contentString appendString:refreshToken];
    [contentString appendString:@"&"];
    [contentString appendString:clientID];
    [contentString appendString:@"&"];
    [contentString appendString:secretID];
    [contentString appendString:@"&"];
    [contentString appendString:kAlfrescoOAuthGrantTypeRefresh];
    NSLog(@"Token Staging URL is %@",contentString);
    
    NSData *data = [contentString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];    
}

#pragma private methods
- (NSDictionary *)dictionaryFromJSONResponseWithError:(NSError **)outError
{
    if (nil == self.receivedData)
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        }
        else
        {
            NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
            *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        }
        return nil;
    }
    if (0 == self.receivedData.length)
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        }
        else
        {
            NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
            *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        }
        return nil;
    }
    NSError *error = nil;
    id jsonDictionary = [NSJSONSerialization JSONObjectWithData:self.receivedData options:kNilOptions error:&error];
    if (nil == jsonDictionary)
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        }
        else
        {
            NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
            *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        }
        return nil;
    }
    
    if (![jsonDictionary isKindOfClass:[NSDictionary class]])
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        }
        else
        {
            NSError *underlyingError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
            *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:underlyingError andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        }
        return nil;
    }
    return (NSDictionary *)jsonDictionary;
}


#pragma NSURLConnection Delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (nil != data && data.length > 0)
    {
        NSError *error = nil;
        id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (nil != jsonObj)
        {
            if ([jsonObj isKindOfClass:[NSDictionary class]])
            {
                [self.receivedData appendBytes:[data bytes] length:data.length];
            }
            
        }
    }    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        int code = [httpResponse statusCode];
        NSLog(@"Status response is %d",code);
        if ( code < 200 || code > 299 )
        {
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (nil == self.sessionDelegate)
    {
        return;
    }
    if ([self.sessionDelegate respondsToSelector:@selector(sessionDidFailWithError:)])
    {
        [self.sessionDelegate sessionDidFailWithError:error];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (nil == self.sessionDelegate)
    {
        return;
    }
    NSError *error = nil;
    NSDictionary *jsonDict = [self dictionaryFromJSONResponseWithError:&error];
    if (nil == jsonDict)
    {
        if ([self.sessionDelegate respondsToSelector:@selector(sessionDidFailWithError:)])
        {
            [self.sessionDelegate sessionDidFailWithError:error];
        }
        return;
    }
        
    if ([[jsonDict allKeys] containsObject:kAlfrescoJSONError])
    {
        if ([self.sessionDelegate respondsToSelector:@selector(sessionDidExpire)])
        {
            [self.sessionDelegate sessionDidExpire];
        }
    }
    else if ([[jsonDict allKeys] containsObject:kAlfrescoJSONAccessToken])
    {
        [self.oauthData setOAuthDataWithJSONDictionary:jsonDict];
        if ([self.sessionDelegate respondsToSelector:@selector(sessionDidRefresh)])
        {
            [self.sessionDelegate sessionDidRefresh];
        }
    }
    else
    {
        if (nil == error)
        {
            error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        }
        else
        {
            NSError *underlyingError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
            error = [AlfrescoErrors alfrescoErrorWithUnderlyingError:underlyingError andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        }        
        if ([self.sessionDelegate respondsToSelector:@selector(sessionDidFailWithError:)])
        {
            [self.sessionDelegate sessionDidFailWithError:error];
        }
    }
}

@end
