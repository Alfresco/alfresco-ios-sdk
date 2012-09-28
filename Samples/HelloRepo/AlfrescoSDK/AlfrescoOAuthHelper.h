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
#import "AlfrescoOAuthLoginViewController.h"

@interface AlfrescoOAuthHelper : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
/**
 @param authorizationCode the authorization code retrieved from the Cloud server at first login
 @param oauthData - the AlfrescoOAuthData. This object must have the api key, secret key and redirect URI set
 @param completionBlock
 */
+ (void)retrieveOAuthDataForAuthorizationCode:(NSString *)authorizationCode
                                    oauthData:(AlfrescoOAuthData *)oauthData
                              completionBlock:(AlfrescoOAuthCompletionBlock)completionBlock;

/**
 @param oauthData - the AlfrescoOAuthData, used for refreshing the access token. For that the AlfrescoOAuthData set needs to contain the api key, secret key, refresh token, and current access token 
 @param completionBlock
 */
+ (void)refreshAccessToken:(AlfrescoOAuthData *)oauthData
           completionBlock:(AlfrescoOAuthCompletionBlock)completionBlock;


@end
