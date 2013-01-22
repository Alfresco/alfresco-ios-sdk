/*
 ******************************************************************************
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
 *****************************************************************************
 */

#import "AlfrescoGDHTTPRequest.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoErrors.h"

@interface AlfrescoGDHTTPRequest()

@property (nonatomic, strong) GDHttpRequest *httpRequest;
@property (nonatomic, strong) NSDictionary *headers;
@property (nonatomic, strong) NSData *requestBody;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, copy) AlfrescoDataCompletionBlock completionBlock;

- (void)connectWithURL:(NSURL*)requestURL
                method:(NSString *)method
                header:(NSDictionary *)header
           requestBody:(NSData *)requestBody
       completionBlock:(AlfrescoDataCompletionBlock)completionBlock;

+ (id<AlfrescoHTTPRequest>)requestWithURL:(NSURL *)requestURL
                method:(NSString *)method
               headers:(NSDictionary *)header
           requestBody:(NSData *)data
       completionBlock:(AlfrescoDataCompletionBlock)completionBlock;

@end

@implementation AlfrescoGDHTTPRequest

@synthesize httpRequest = _httpRequest;
@synthesize headers = _headers;
@synthesize requestBody = _requestBody;
@synthesize responseData = _responseData;
@synthesize completionBlock = _completionBlock;

#pragma mark - AlfrescoHTTPRequest Functions

+ (id<AlfrescoHTTPRequest>)executeRequestWithURL:(NSURL *)url
                      session:(id<AlfrescoSession>)session
              completionBlock:(AlfrescoDataCompletionBlock)completionBlock
{
    return [self executeRequestWithURL:url session:session requestBody:nil method:kAlfrescoHTTPGet completionBlock:completionBlock];
}

+ (id<AlfrescoHTTPRequest>)executeRequestWithURL:(NSURL *)url
                      session:(id<AlfrescoSession>)session
                       method:(NSString *)method
              completionBlock:(AlfrescoDataCompletionBlock)completionBlock
{
    return [self executeRequestWithURL:url session:session requestBody:nil method:method completionBlock:completionBlock];
}


+ (id<AlfrescoHTTPRequest>)executeRequestWithURL:(NSURL *)url
                      session:(id<AlfrescoSession>)session
                  requestBody:(NSData *)requestBody
                       method:(NSString *)method
              completionBlock:(AlfrescoDataCompletionBlock)completionBlock
{
    id authenticationProvider = [session objectForParameter:kAlfrescoAuthenticationProviderObjectKey];
    NSDictionary *httpHeaders = [authenticationProvider willApplyHTTPHeadersForSession:nil];
    return [self requestWithURL:url method:method headers:httpHeaders requestBody:requestBody completionBlock:completionBlock];
}

#pragma mark - Private Functions

+ (id<AlfrescoHTTPRequest>)requestWithURL:(NSURL *)requestURL
                method:(NSString *)method
               headers:(NSDictionary *)header
           requestBody:(NSData *)data
       completionBlock:(AlfrescoDataCompletionBlock)completionBlock
{
    AlfrescoGDHTTPRequest *alfrescoGDRequest = [[self alloc] init];
    if (alfrescoGDRequest)
    {
        [alfrescoGDRequest connectWithURL:requestURL method:method header:header requestBody:data completionBlock:completionBlock];
    }
    else
    {
        completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeUnknown]);
    }
    return alfrescoGDRequest;
}

- (void)connectWithURL:(NSURL*)requestURL
                method:(NSString *)method
                header:(NSDictionary *)header
           requestBody:(NSData *)requestBody
       completionBlock:(AlfrescoDataCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    self.headers = header;
    self.requestBody = requestBody;
    self.responseData = [NSMutableData data];
    self.completionBlock = completionBlock;
    
    _httpRequest = [[GDHttpRequest alloc] init];
    _httpRequest.delegate = self;
    
    // open request
    [_httpRequest open:[method UTF8String] withUrl:[[requestURL absoluteString] UTF8String] withAsync:YES];
    
    /////// SYNCHRONOUS CALLS /////////
    // add headers
//    [self.headers enumerateKeysAndObjectsUsingBlock:^(NSString *headerKey, NSString *headerValue, BOOL *stop) {
//        [_httpRequest setRequestHeader:[headerKey UTF8String] withValue:[headerValue UTF8String]];
//    }];
//    
//    // send the request
//    if (self.requestBody)
//    {
//        [_httpRequest sendData:requestBody];
//    }
//    else
//    {
//        [_httpRequest send];
//    }
//
//    [_httpRequest.delegate onStatusChange:_httpRequest];
    /////// SYNCHRONOUS CALLS /////////
}

#pragma mark - GDHttpRequestDelegate Functions

- (void)onStatusChange:(id)httpRequest
{
    int state = [(GDHttpRequest *)httpRequest getState];
    switch (state)
    {
        case GDHttpRequest_OPENED:
        {
            [self.headers enumerateKeysAndObjectsUsingBlock:^(NSString *headerKey, NSString *headerValue, BOOL *stop) {
                [httpRequest setRequestHeader:[headerKey UTF8String] withValue:[headerValue UTF8String]];
            }];
            
            if (self.requestBody)
            {
                [httpRequest sendData:self.requestBody];
            }
            else
            {
                [httpRequest send];
            }
        }
            break;
            
        case GDHttpRequest_LOADING:
        {
            GDDirectByteBuffer *buffer = [httpRequest getReceiveBuffer];
            int length = [buffer bytesUnread];
            char raw[length];
            
            [buffer read:raw toMaxLength:length];
            
            [self.responseData appendBytes:raw length:length];
        }
            break;
            
        case GDHttpRequest_DONE:
        {
            int statusCode = [httpRequest getStatus];
            
            NSError *error = nil;
            if (statusCode < 200 || statusCode > 299)
            {
                error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeHTTPResponse];
            }
            
            /////// ASYNCRONOUS CALLS /////////
            self.completionBlock(self.responseData, error);
            /////// ASYNCRONOUS CALLS /////////
            
//            /////// SYNCHRONOUS CALLS /////////
//            if ([httpRequest getStatus] == 200)
//            {
//                GDDirectByteBuffer* buf  = [httpRequest getReceiveBuffer];
//                int len  = [buf bytesUnread];
//                char raw[len];
//                
//                [buf read:raw toMaxLength:len];
//                NSData* data  = [[NSData alloc] initWithBytes:raw length:len];
//                
//                if ([data length] > 0)
//                {
//                    self.completionBlock(data, error);
//                }
//            }
            /////// SYNCHRONOUS CALLS /////////
            
            self.requestBody = nil;
            self.responseData = nil;
            self.completionBlock = nil;
        }
            break;
            
        default:
            break;
    }
}

@end
