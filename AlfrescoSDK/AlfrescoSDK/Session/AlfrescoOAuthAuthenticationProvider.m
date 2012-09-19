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
#import "AlfrescoOAuthData.h"

@interface AlfrescoOAuthAuthenticationProvider ()
@property (nonatomic, strong, readwrite) NSURLConnection    * connection;
@property (nonatomic, strong, readwrite) NSMutableData      * receivedData;
@property (nonatomic, strong, readwrite) NSString * apiKey;
@property (nonatomic, strong, readwrite) NSString * secretKey;
@property (nonatomic, strong, readwrite) NSString * redirectURIString;
@property (nonatomic, strong, readwrite) NSMutableDictionary *httpHeaders;
@property (nonatomic, strong, readwrite) AlfrescoOAuthData *oauthData;
@property (nonatomic, copy, readwrite) AlfrescoOAuthCompletionBlock completionBlock;
- (void)authenticateWithAuthorisationCode:(NSString *)code;
- (AlfrescoOAuthData *)oauthDataFromJSONResponseWithError:(NSError **)outError;
@end

@implementation AlfrescoOAuthAuthenticationProvider
@synthesize apiKey = _apiKey;
@synthesize secretKey = _secretKey;
@synthesize redirectURIString = _redirectURIString;
@synthesize httpHeaders = _httpHeaders;
@synthesize oauthData = _oauthData;

+ (NSURL *)authenticateURLFromAPIKey:(NSString *)apiKey secretKey:(NSString *)secretKey redirectURIString:(NSString *)redirectURLString
{
    NSMutableString *uriString = [NSMutableString string];
    [uriString appendString:kAlfrescoOAuthAuthorizeURL];
    NSString *clientId = [kAlfrescoOAuthClientID stringByReplacingOccurrencesOfString:kAlfrescoClientID withString:apiKey];
    NSString *redirect = [kAlfrescoOAuthRedirectURI stringByReplacingOccurrencesOfString:kAlfrescoRedirectURI withString:redirectURLString];
    [uriString appendString:[NSString stringWithFormat:@"?%@",clientId]];
    [uriString appendString:[NSString stringWithFormat:@"&%@",redirect]];
    [uriString appendString:[NSString stringWithFormat:@"&%@",kAlfrescoOAuthScope]];
    [uriString appendString:[NSString stringWithFormat:@"&%@",kAlfrescoOAuthResponseType]];
    return [NSURL URLWithString:uriString];
}


- (id)initWithAPIKey:(NSString *)apiKey secretKey:(NSString *)secretKey redirectURLString:(NSString *)redirectURLString
{
    self = [super init];
    if (nil != self)
    {
        self.apiKey = apiKey;
        self.secretKey = secretKey;
        self.redirectURIString = redirectURLString;
    }
    return self;
}

- (void)authenticateWithRequest:(NSURLRequest *)request completionBlock:(AlfrescoOAuthCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    [AlfrescoErrors assertArgumentNotNil:request argumentName:@"request"];
    self.completionBlock = completionBlock;
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
}



#pragma private methods
- (void)authenticateWithAuthorisationCode:(NSString *)code
{
    NSLog(@"IN authenticateWithAuthorisationCode:%@",code);
    NSURL *url = [NSURL URLWithString:kAlfrescoOAuthTokenURL];
    [self.connection cancel];
    self.connection = nil;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url
                                                           cachePolicy: NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval: 60];
    
    [request setHTTPMethod:@"POST"];
    
    NSMutableString *contentString = [NSMutableString string];
    NSString *codeID   = [kAlfrescoOAuthCode stringByReplacingOccurrencesOfString:kAlfrescoCode withString:code];
    NSString *clientID = [kAlfrescoOAuthClientID stringByReplacingOccurrencesOfString:kAlfrescoClientID withString:self.apiKey];
    NSString *secretID = [kAlfrescoOAuthClientSecret stringByReplacingOccurrencesOfString:kAlfrescoClientSecret withString:self.secretKey];
    NSString *redirect = [kAlfrescoOAuthRedirectURI stringByReplacingOccurrencesOfString:kAlfrescoRedirectURI withString:self.redirectURIString];
    
    [contentString appendString:codeID];
    [contentString appendString:@"&"];
    [contentString appendString:clientID];
    [contentString appendString:@"&"];
    [contentString appendString:secretID];
    [contentString appendString:@"&"];
    [contentString appendString:kAlfrescoOAuthGrantType];
    [contentString appendString:@"&"];
    [contentString appendString:redirect];
    
    NSData *data = [contentString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
}

- (AlfrescoOAuthData *)oauthDataFromJSONResponseWithError:(NSError **)outError
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
    
    if ([[jsonDictionary allKeys] containsObject:kAlfrescoJSONError])
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
    
    AlfrescoOAuthData *oauthData = [[AlfrescoOAuthData alloc] initWithOAuthData:jsonDictionary];
    return oauthData;
}


#pragma AlfrescoAuthenticationProvider method

- (NSDictionary *)willApplyHTTPHeadersForSession:(id<AlfrescoSession>)session
{
    if (nil == self.httpHeaders)
    {
        self.httpHeaders = [NSMutableDictionary dictionary];
    }
    NSString *authHeader = [NSString stringWithFormat:@"Bearer "];
    [self.httpHeaders setValue:authHeader forKey:@"Authorization"];
    return self.httpHeaders;
}

#pragma NSURLConnectionDelegate/NSURLConnectionDataDelegate methods


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"NSURLConnectionDataDelegate::didReceiveData");
    NSLog(@"bytes received %@",[NSString stringWithUTF8String:[data bytes]]);
    if (nil != data)
    {
        if (0 < data.length)
        {
            NSLog(@"appending data by %d bytes", data.length);
            NSError *error = nil;
            id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (nil == error && nil != jsonObj)
            {
                if ([jsonObj isKindOfClass:[NSDictionary class]])
                {
                    NSLog(@"NSURLConnectionDataDelegate::didReceiveData JSON data correspond to NSDictionary");
                    [self.receivedData appendBytes:[data bytes] length:data.length];
                }
                else
                {
                    NSLog(@"JSON data don't correspond to NSDictionary");
                }
            }
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"NSURLConnectionDataDelegate::didReceiveResponse");
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSLog(@"the response we get back is a HTTP Response");
        NSURL *responseURL = response.URL;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        NSString *urlString = [responseURL absoluteString];
        NSLog(@"Response url is %@ and the status code is %d",urlString, httpResponse.statusCode);
        NSArray *components = [urlString componentsSeparatedByString:@"code="];
        if (2 == components.count)
        {
            self.receivedData = [NSMutableData data];
            NSString *codeString = [components objectAtIndex:1];
            NSArray *codeIDComponents = [codeString componentsSeparatedByString:@"&"];
            if (0 < codeIDComponents.count)
            {
                NSString *codeId = [codeIDComponents objectAtIndex:0];
                NSLog(@"Authentication code is %@",codeId);
                [self authenticateWithAuthorisationCode:codeId];
            }
        }
        
    }
    else
    {
        NSLog(@"the response we get back is not a HTTP Response");
    }
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"NSURLConnectionDataDelegate::connectionDidFinishLoading");
    NSError *error = nil;
    AlfrescoOAuthData *oauthData = [self oauthDataFromJSONResponseWithError:&error];
    self.completionBlock(oauthData, error);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"NSURLConnectionDataDelegate::didFailWithError %@ and code %d",[error localizedDescription], [error code]);
    self.completionBlock(nil, error);
}

@end
