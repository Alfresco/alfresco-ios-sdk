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
#import "AlfrescoInternalConstants.h"
#import "AlfrescoLog.h"
#import "AlfrescoAuthenticationProvider.h"
#import "CMISReachability.h"

@interface AlfrescoDefaultHTTPRequest()
@property (nonatomic, strong) NSURLSession *URLSession;
@property (nonatomic, strong) NSURLSessionDataTask *sessionTask;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, copy) AlfrescoDataCompletionBlock completionBlock;
@property (nonatomic, strong, readwrite) NSURL *requestURL;
@property (nonatomic, strong) NSOutputStream *outputStream;
@end

@implementation AlfrescoDefaultHTTPRequest

#pragma public method

- (void)connectWithURL:(NSURL*)requestURL
                method:(NSString *)method
               session:(id<AlfrescoSession>)session
           requestBody:(NSData *)requestBody
       completionBlock:(AlfrescoDataCompletionBlock)completionBlock
{
    [self connectWithURL:requestURL method:method session:session requestBody:requestBody outputStream:nil completionBlock:completionBlock];
}

- (void)connectWithURL:(NSURL*)requestURL
                method:(NSString *)method
               session:(id<AlfrescoSession>)session
           requestBody:(NSData *)requestBody
          outputStream:(NSOutputStream *)outputStream
       completionBlock:(AlfrescoDataCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    // check network reachability (unless it's disabled) and return early if appropriate
    id checkNetworkReachability = [session objectForParameter:kAlfrescoCheckNetworkReachability];
    if (!checkNetworkReachability || [checkNetworkReachability boolValue])
    {
        CMISReachability *reachability = [CMISReachability networkReachability];
        if (!reachability.hasNetworkConnection)
        {
            NSError *noConnectionError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeNoNetworkConnection];
            
            if (completionBlock != NULL)
            {
                completionBlock(nil, noConnectionError);
            }
            
            return;
        }
    }

    self.completionBlock = completionBlock;
    self.requestURL = requestURL;
    AlfrescoLogDebug(@"%@ %@", method, requestURL);
    
    id authenticationProvider = [session objectForParameter:kAlfrescoAuthenticationProviderObjectKey];
    NSDictionary *headers = [authenticationProvider willApplyHTTPHeadersForSession:nil];
    
    NSTimeInterval timeout = 60;
    NSNumber *timeoutParameter = [session objectForParameter:kAlfrescoRequestTimeout];
    if (timeoutParameter)
    {
        timeout = [timeoutParameter doubleValue];
    }
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:requestURL
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                          timeoutInterval:timeout];
    
    [urlRequest setHTTPMethod:method];
    
    // check whether default cookie handling behaviour has been configured
    id httpShouldHandleCookies = [session objectForParameter:kAlfrescoHTTPShouldHandleCookies];
    if (httpShouldHandleCookies != nil)
    {
        urlRequest.HTTPShouldHandleCookies = [httpShouldHandleCookies boolValue];
    }
    
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
        
        if ([AlfrescoLog sharedInstance].logLevel == AlfrescoLogLevelTrace)
        {
            AlfrescoLogTrace(@"request body: %@", [[NSString alloc] initWithData:requestBody encoding:NSUTF8StringEncoding]);
        }
    }
    
    self.outputStream = outputStream;
    if (self.outputStream)
    {
        [self.outputStream open];
    }
    self.responseData = nil;
    
    // NOTE: we only create a default session configuration object as file upload/download is performed
    //       by the CMIS library, background mode was setup at session creation time
    
    // create session and task
    self.URLSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                    delegate:self
                                               delegateQueue:nil];
    self.sessionTask = [self.URLSession dataTaskWithRequest:urlRequest];
    
    // execute the request
    [self.sessionTask resume];
}

#pragma mark Session delegate methods

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSError *requestError = error;
    
    if (!requestError)
    {
        // no error returned but we also need to check response code
        if (self.statusCode < 200 || self.statusCode > 299)
        {
            if (self.statusCode == 401)
            {
                NSError *jsonError = nil;
                id jsonDictionary = [NSJSONSerialization JSONObjectWithData:self.responseData options:0 error:&jsonError];
                NSError *errorFromDescription = [AlfrescoErrors alfrescoErrorFromJSONParameters:jsonDictionary];
                
                if (!jsonError && errorFromDescription.code != kAlfrescoErrorCodeJSONParsing)
                {
                    requestError = errorFromDescription;
                }
                else
                {
                    requestError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeUnauthorisedAccess];
                }
            }
            else
            {
                NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
                if ([responseString rangeOfString:kAlfrescoCloudAPIRateLimitExceeded].location != NSNotFound)
                {
                    requestError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeAPIRateLimitExceeded];
                }
                else
                {
                    NSDictionary *userInfo = @{kAlfrescoErrorKeyHTTPResponseCode: @(self.statusCode),
                                               kAlfrescoErrorKeyHTTPResponseBody: self.responseData};
                    
                    requestError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeHTTPResponse userInfo:userInfo];
                }
            }
        }
        
        if ([AlfrescoLog sharedInstance].logLevel == AlfrescoLogLevelTrace)
        {
            AlfrescoLogTrace(@"response body: %@", [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding]);
        }
    }
    
    if (requestError)
    {
        // log the error (if it's likely to be an unrecoverable error)
        if (self.statusCode >= 500)
        {
            [[AlfrescoLog sharedInstance] logErrorFromError:requestError];
        }
        
        // make sure we don't return any result
        self.responseData = nil;
    }
    
    // call completion block
    if (self.completionBlock != NULL)
    {
        // call the completion block on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completionBlock(self.responseData, requestError);
        });
    }
    
    // clean up
    [self.outputStream close];
    self.outputStream = nil;
    self.sessionTask = nil;
    self.URLSession = nil;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
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
        if (self.outputStream)
        {
            uint8_t *readBytes = (uint8_t *)[data bytes];
            NSUInteger data_length = [data length];
            uint8_t buffer[data_length];
            (void)memcpy(buffer, readBytes, data_length);
            [self.outputStream write:(const uint8_t *)buffer maxLength:data_length];
        }
        else
        {
            [self.responseData appendData:data];
        }
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    self.responseData = [NSMutableData data];
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        self.statusCode = httpResponse.statusCode;
        
        if ([AlfrescoLog sharedInstance].logLevel == AlfrescoLogLevelTrace)
        {
            AlfrescoLogTrace(@"response status code: %d", self.statusCode);
        }
    }
    else
    {
        self.statusCode = -1;
    }
    
    completionHandler(NSURLSessionResponseAllow);
}

#pragma mark AlfrescoCancellableRequest method

- (void)cancel
{
    if (self.URLSession)
    {
        AlfrescoDataCompletionBlock dataCompletionBlock = self.completionBlock;
        self.completionBlock = nil;
        
        [self.URLSession invalidateAndCancel];
        self.URLSession = nil;
        
        [self.outputStream close];
        self.outputStream = nil;
        
        NSError *alfrescoError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeNetworkRequestCancelled];
        dataCompletionBlock(nil, alfrescoError);
    }
}

@end
