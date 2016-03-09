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

#import "CMISHttpRequest.h"
#import "CMISHttpResponse.h"
#import "CMISErrors.h"
#import "CMISLog.h"
#import "CMISReachability.h"

//Exception names as returned in the <!--exception> tag
NSString * const kCMISExceptionInvalidArgument         = @"invalidArgument";
NSString * const kCMISExceptionNotSupported            = @"notSupported";
NSString * const kCMISExceptionObjectNotFound          = @"objectNotFound";
NSString * const kCMISExceptionPermissionDenied        = @"permissionDenied";
NSString * const kCMISExceptionRuntime                 = @"runtime";
NSString * const kCMISExceptionConstraint              = @"constraint";
NSString * const kCMISExceptionContentAlreadyExists    = @"contentAlreadyExists";
NSString * const kCMISExceptionFilterNotValid          = @"filterNotValid";
NSString * const kCMISExceptionNameConstraintViolation = @"nameConstraintViolation";
NSString * const kCMISExceptionStorage                 = @"storage";
NSString * const kCMISExceptionStreamNotSupported      = @"streamNotSupported";
NSString * const kCMISExceptionUpdateConflict          = @"updateConflict";
NSString * const kCMISExceptionVersioning              = @"versioning";


@implementation CMISHttpRequest


+ (id)startRequest:(NSMutableURLRequest *)urlRequest
                      httpMethod:(CMISHttpRequestMethod)httpRequestMethod
                     requestBody:(NSData*)requestBody
                         headers:(NSDictionary*)additionalHeaders
          authenticationProvider:(id<CMISAuthenticationProvider>) authenticationProvider
                 completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
{
    CMISHttpRequest *httpRequest = [[self alloc] initWithHttpMethod:httpRequestMethod
                                                    completionBlock:completionBlock];
    httpRequest.requestBody = requestBody;
    httpRequest.additionalHeaders = additionalHeaders;
    httpRequest.authenticationProvider = authenticationProvider;
    
    if (![httpRequest startRequest:urlRequest]) {
        httpRequest = nil;
    }
    
    return httpRequest;
}


- (id)initWithHttpMethod:(CMISHttpRequestMethod)httpRequestMethod
         completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
{
    self = [super init];
    if (self) {
        _requestMethod = httpRequestMethod;
        _completionBlock = completionBlock;
    }
    return self;
}


- (BOOL)startRequest:(NSMutableURLRequest*)urlRequest
{
    BOOL startedRequest = NO;

    if (self.requestBody) {
        if ([CMISLog sharedInstance].logLevel == CMISLogLevelTrace) {
            CMISLogTrace(@"Request body: %@", [[NSString alloc] initWithData:self.requestBody encoding:NSUTF8StringEncoding]);
        }
        
        [urlRequest setHTTPBody:self.requestBody];
    }
    
    [self.authenticationProvider.httpHeadersToApply enumerateKeysAndObjectsUsingBlock:^(NSString *headerName, NSString *header, BOOL *stop) {
        [urlRequest addValue:header forHTTPHeaderField:headerName];
        if ([CMISLog sharedInstance].logLevel == CMISLogLevelTrace) {
            CMISLogTrace(@"Added header: %@ with value: %@", headerName, header);
        }
    }];
    
    [self.additionalHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *headerName, NSString *header, BOOL *stop) {
        [urlRequest addValue:header forHTTPHeaderField:headerName];
        if ([CMISLog sharedInstance].logLevel == CMISLogLevelTrace) {
            CMISLogTrace(@"Added header: %@ with value: %@", headerName, header);
        }
    }];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:NO];
    CMISReachability *reachability = [CMISReachability networkReachability];
    
    if (self.connection && reachability.hasNetworkConnection) {
        [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [self.connection start];
        startedRequest = YES;
    } else if (!reachability.hasNetworkConnection) {
        NSError *noConnectionError = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeNoNetworkConnection detailedDescription:kCMISErrorDescriptionNoNetworkConnection];
        [self connection:self.connection didFailWithError:noConnectionError];
    }
    else {
        if (self.completionBlock) {
            NSString *detailedDescription = [NSString stringWithFormat:@"Could not create connection to %@", urlRequest.URL];
            NSError *cmisError = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeConnection detailedDescription:detailedDescription];
            void (^completionBlock)(CMISHttpResponse *httpResponse, NSError *error);
            completionBlock = self.completionBlock;
            self.completionBlock = nil; // Prevent multiple execution if method on this request gets called inside completion block
            completionBlock(nil, cmisError);
        }
    }
    
    return startedRequest;
}

- (void)cancel
{
    if (self.connection) {
        void (^completionBlock)(CMISHttpResponse *httpResponse, NSError *error);
        completionBlock = self.completionBlock; // remember completion block in order to invoke it after the connection was cancelled
        
        self.completionBlock = nil; // prevent potential NSURLConnection delegate callbacks to invoke the completion block redundantly
        
        [self.connection cancel];
        
        self.connection = nil;
        
        if (completionBlock) {
            NSError *cmisError = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeCancelled detailedDescription:@"Request was cancelled"];
            completionBlock(nil, cmisError);
        }
    }
}


- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [self.authenticationProvider canAuthenticateAgainstProtectionSpace:protectionSpace];
}


- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [self.authenticationProvider didCancelAuthenticationChallenge:challenge];
}


- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [self.authenticationProvider didReceiveAuthenticationChallenge:challenge];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.responseBody = [[NSMutableData alloc] init];
    if ([response isKindOfClass:NSHTTPURLResponse.class]) {
        self.response = (NSHTTPURLResponse*)response;
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseBody appendData:data];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.authenticationProvider updateWithHttpURLResponse:self.response];

    if (self.completionBlock) {
        CMISErrorCodes cmisErrorCode = kCMISErrorCodeConnection;
        
        // swap error code if necessary
        if (error.code == NSURLErrorCancelled) {
            cmisErrorCode = kCMISErrorCodeCancelled;
        } else if (error.code == kCMISErrorCodeNoNetworkConnection) {
            cmisErrorCode = kCMISErrorCodeNoNetworkConnection;
        }
        
        NSError *cmisError = [CMISErrors cmisError:error cmisErrorCode:cmisErrorCode];
        self.completionBlock(nil, cmisError);
    }
    
    self.completionBlock = nil;
    self.connection = nil;
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.authenticationProvider updateWithHttpURLResponse:self.response];
    
    if (self.completionBlock) {
        NSError *cmisError = nil;
        CMISHttpResponse *httpResponse = [CMISHttpResponse responseUsingURLHTTPResponse:self.response data:self.responseBody];
        if ([self checkStatusCodeForResponse:httpResponse httpRequestMethod:self.requestMethod error:&cmisError]) {
            self.completionBlock(httpResponse, nil);
        } else {
            self.completionBlock(nil, cmisError);
        }
    }
    
    self.completionBlock = nil;
    self.connection = nil;
}

- (BOOL)checkStatusCodeForResponse:(CMISHttpResponse *)response httpRequestMethod:(CMISHttpRequestMethod)httpRequestMethod error:(NSError **)error
{
    if ([CMISLog sharedInstance].logLevel == CMISLogLevelTrace) {
        CMISLogTrace(@"Response status code: %d", (int)response.statusCode);
        CMISLogTrace(@"Response body: %@", [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding]);
    }
    
    if ( (httpRequestMethod == HTTP_GET && response.statusCode != 200 && response.statusCode != 206)
        || (httpRequestMethod == HTTP_POST && response.statusCode != 200 && response.statusCode != 201)
        || (httpRequestMethod == HTTP_DELETE && response.statusCode != 204)
        || (httpRequestMethod == HTTP_PUT && ((response.statusCode < 200 || response.statusCode > 299)))) {
        if (error) {
            NSString *exception = response.exception;
            NSString *errorMessage = response.errorMessage;
            if (errorMessage == nil) {
                errorMessage = response.statusCodeMessage; // fall back to HTTP error message
            }
            
            switch (response.statusCode) {
                case 400:
                    if ([exception isEqualToString:kCMISExceptionFilterNotValid]) {
                        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeFilterNotValid
                                                 detailedDescription:errorMessage];
                    } else {
                        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument
                                                 detailedDescription:errorMessage];
                    }
                    break;
                case 401:
                    *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeUnauthorized
                                             detailedDescription:errorMessage];
                    break;
                case 403:
                    if ([exception isEqualToString:kCMISExceptionStreamNotSupported]) {
                        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeStreamNotSupported
                                                 detailedDescription:errorMessage];
                    } else {
                        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodePermissionDenied
                                                 detailedDescription:errorMessage];
                    }
                    break;
                case 404:
                    *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeObjectNotFound
                                             detailedDescription:errorMessage];
                    break;
                case 405:
                    *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeNotSupported
                                             detailedDescription:errorMessage];
                    break;
                case 407:
                    *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeProxyAuthentication
                                             detailedDescription:errorMessage];
                    break;
                case 409:
                    if ([exception isEqualToString:kCMISExceptionContentAlreadyExists]) {
                        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeContentAlreadyExists
                                                 detailedDescription:errorMessage];
                    } else if ([exception isEqualToString:kCMISExceptionVersioning]) {
                        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeVersioning
                                                 detailedDescription:errorMessage];
                    } else if ([exception isEqualToString:kCMISExceptionUpdateConflict]) {
                        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeUpdateConflict
                                                 detailedDescription:errorMessage];
                    } else if ([exception isEqualToString:kCMISExceptionNameConstraintViolation]) {
                        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeNameConstraintViolation
                                                 detailedDescription:errorMessage];
                    } else {
                        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeConstraint
                                                 detailedDescription:errorMessage];
                    }
                    break;
                default:
                    if ([exception isEqualToString:kCMISExceptionStorage]) {
                        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeStorage
                                                 detailedDescription:errorMessage];
                    } else {
                        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeRuntime
                                                 detailedDescription:response.errorMessage];
                    }
            }
        }
        return NO;
    }
    return YES;
}

@end
