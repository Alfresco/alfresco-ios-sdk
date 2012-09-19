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
#import "AlfrescoAuthenticationProvider.h"
@class AlfrescoOAuthData;
typedef void (^AlfrescoOAuthCompletionBlock)(AlfrescoOAuthData * oauthData, NSError *error);

@interface AlfrescoOAuthAuthenticationProvider : NSObject <AlfrescoAuthenticationProvider, NSURLConnectionDelegate, NSURLConnectionDataDelegate>

/**---------------------------------------------------------------------------------------
 * @name Creates an authentication provider with a plain username and password.
 *  ---------------------------------------------------------------------------------------
 */

/** Creates an instance of an AlfrescoBasicAuthenticationProvider with a username and password.
 
 @param apiKey the api key to be used for authentication.
 @param secretKey The secret key - associated with the api key.
 @param redirectURLString the URL callback - if provided.
 @return Authentication provider instance.
 */
- (id)initWithAPIKey:(NSString *)apiKey secretKey:(NSString *)secretKey redirectURLString:(NSString *)redirectURLString;
- (void)authenticateWithRequest:(NSURLRequest *)request completionBlock:(AlfrescoOAuthCompletionBlock)completionBlock;
+ (NSURL *)authenticateURLFromAPIKey:(NSString *)apiKey secretKey:(NSString *)secretKey redirectURIString:(NSString *)redirectURLString;
@end
