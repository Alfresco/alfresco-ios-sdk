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

#import "AlfrescoDefaultHTTPRequest.h"
#import "AlfrescoErrors.h"
#import "AlfrescoLog.h"

@interface AlfrescoDefaultHTTPRequest()

@property (nonatomic, strong) NSURLConnection * connection;
@property (nonatomic, strong) NSMutableData * responseData;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, copy) AlfrescoDataCompletionBlock completionBlock;

@end

@implementation AlfrescoDefaultHTTPRequest

#pragma public method

- (void)connectWithURL:(NSURL*)requestURL
                method:(NSString *)method
                headers:(NSDictionary *)headers
           requestBody:(NSData *)requestBody
       completionBlock:(AlfrescoDataCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    self.completionBlock = completionBlock;
    
    AlfrescoLogDebug(@"%@ %@", method, requestURL);
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:requestURL
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                          timeoutInterval:60];
    
    [urlRequest setHTTPMethod:method];
    
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *headerKey, NSString *headerValue, BOOL *stop){
        if ([AlfrescoLog sharedInstance].logLevel == AlfrescoLogLevelTrace)
        {
             AlfrescoLogTrace(@"headerKey = %@, headerValue = %@", headerKey, headerValue);
        }
        [urlRequest addValue:headerValue forHTTPHeaderField:headerKey];
    }];
    
    if (nil != requestBody)
    {
        [urlRequest setHTTPBody:requestBody];
        [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    
    self.responseData = nil;
    self.connection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
}

#pragma URL delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.responseData = [NSMutableData data];
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        self.statusCode = httpResponse.statusCode;
        {
            AlfrescoLogTrace(@"response status code: %d", self.statusCode);
        }
    }
    else
    {
        self.statusCode = -1;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (nil == data)
    {
        return;
    }
    if (0 == data.length)
    {
        return;
    }
    if (nil != self.responseData)
    {
        [self.responseData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error = nil;
    if (self.statusCode < 200 || self.statusCode > 299)
    {
        if (self.statusCode == 401)
        {
            error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeUnauthorisedAccess];
        }
        else
        {
            error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeHTTPResponse];
        }
    }
    
    if ([AlfrescoLog sharedInstance].logLevel == AlfrescoLogLevelTrace)
    {
        AlfrescoLogTrace(@"response body: %@", [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding]);
    }
    
    if (self.completionBlock != NULL)
    {
        if (error)
        {
            self.completionBlock(nil, error);
        }
        else
        {
            self.completionBlock(self.responseData, nil);
        }
    }
    
    self.completionBlock = nil;
    self.connection = nil;
    self.responseData = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[AlfrescoLog sharedInstance] logErrorFromError:error];
    
    if (self.completionBlock != NULL)
    {
        self.completionBlock(nil, error);
    }
    self.connection = nil;
}

#pragma Cancellation
- (void)cancel
{
    if (self.connection)
    {
        AlfrescoDataCompletionBlock dataCompletionBlock = self.completionBlock;
        self.completionBlock = nil;

        [self.connection cancel];
        self.connection = nil;

        NSError *alfrescoError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeNetworkRequestCancelled];
        dataCompletionBlock(nil, alfrescoError);
    }
}

@end
