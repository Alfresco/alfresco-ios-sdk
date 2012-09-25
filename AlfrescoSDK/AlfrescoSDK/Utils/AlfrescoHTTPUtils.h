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

#import <Foundation/Foundation.h>
#import "AlfrescoErrors.h"
#import "AlfrescoSession.h"
#import "AlfrescoAuthenticationProvider.h"
#import <objc/runtime.h>

@interface AlfrescoHTTPUtils : NSObject
/** Executes a request for the given REST API. The URL used for the request is the combination of
 the session's baseUrl property and the contents of the given api parameter.
 
 @param api The URL string for the HTTP request excluding the Alfresco repository base URL.
 @param baseUrl The URL string for the base API
 @param session the AuthenticationProvider
 @param outError The error reference that's filled when the request fails.
 @return The HTTP response data.
 */
+ (NSData *)executeRequest:(NSString *)api
           baseUrlAsString:(NSString *)baseUrl
                   session:(id<AlfrescoSession>)session
                     error:(NSError **)outError;


/** Executes a request for the given REST API. The URL used for the request is the combination of
 the session's baseUrl property and the contents of the given api parameter.
 When data is provided, the request body is filled with the data parameter.
 
 @param api The URL for the HTTP request excluding the Alfresco repository base URL.
 @param baseUrl the URL string
 @param session
 @param data The NSData instance that's used for the HTTP body of the request.
 @param httpMethod The http method (GET, POST, PUT or DELETE), that's used when executing the request.
 @param outError The error reference that's filled when the request fails.
 @return The HTTP response data.
 */
+ (NSData *)executeRequest:(NSString *)api
           baseUrlAsString:(NSString *)baseUrl
                   session:(id<AlfrescoSession>)session
                      data:(NSData *)data
                httpMethod:(NSString *)httpMethod
                     error:(NSError **)outError;


/** Executes a request for full REST URL.
 When data is provided, the request body is filled with the data parameter.
 
 @param url The full URL for the HTTP request.
 @param session
 @param data The NSData instance that's used for the HTTP body of the request.
 @param httpMethod The http method (GET, POST, PUT or DELETE), that's used when executing the request.
 @param outError The error reference that's filled when the request fails.
 @return The HTTP response data.
 */
+ (NSData *)executeRequestWithURL:(NSURL *)url
                          session:(id<AlfrescoSession>)session
                             data:(NSData *)data
                       httpMethod:(NSString *)httpMethod
                            error:(NSError **)outError;


/** Executes a request for full REST URL.
 When data is provided, the request body is filled with the data parameter.
 
 @param url The full URL for the HTTP request.
 @param data The NSData instance that's used for the HTTP body of the request.
 @param httpMethod The http method (GET, POST, PUT or DELETE), that's used when executing the request.
 @param outError The error reference that's filled when the request fails.
 @return The HTTP response data.
 */
+ (NSData *)executeRequestWithURL:(NSURL *)url
                             data:(NSData *)data
                       httpMethod:(NSString *)httpMethod
                            error:(NSError **)outError;


@end
