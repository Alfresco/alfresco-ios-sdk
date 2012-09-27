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

#import "AlfrescoSession.h"
#import "AlfrescoFolder.h"
#import "AlfrescoRepositoryInfo.h"
#import "AlfrescoConstants.h"
#import "AlfrescoCloudNetwork.h"
#import "AlfrescoOAuthData.h"

@interface AlfrescoCloudSession : NSObject <AlfrescoSession>
@property (nonatomic, strong, readonly) AlfrescoCloudNetwork *network;
@property (nonatomic, strong) AlfrescoOAuthData *oauthData;


/**
 Note: Cloud networks are also termed domains or tenants. Each user will have a default "home" network (or domain, or tenant) assigned.
 This method parses the available networks on The Cloud and selects the home-network for the registered user.
 If no home network is found, an error is returned and the AlfrescoSession object will be nil.
 
 @param emailAddress - the email address of the user to be used for sign up
 @param password - password
 @param apiKey - apiKey to authenticate app at server with
 @param parameters - an NSDictionary settings object with additional parameters to be used for authentication (optional)
 @param completionBlock (AlfrescoSessionCompletionBlock). If successful, the block returns a valid AlfrescoSession object - or nil if error occurs.
 */
+ (void)connectWithEmailAddress:(NSString *)emailAddress
                       password:(NSString *)password
                         apiKey:(NSString *)apiKey
                     parameters:(NSDictionary *)parameters
                completionBlock:(AlfrescoSessionCompletionBlock)completionBlock;


/**
 The method looks for a specific Cloud network and returns a AlfrescoSession object if successful.
 
 @param emailAddress - the email address of the user to be used for sign up
 @param password - password
 @param apiKey - apiKey to authenticate app at server with
 @param networkIdentifer - the network/tenant/domain in the Cloud to connect to
 @param parameters - an NSDictionary settings object with additional parameters to be used for authentication (optional)
 @param completionBlock (AlfrescoSessionCompletionBlock). If successful, the block returns a valid AlfrescoSession object - or nil if error occurs.
 */
+ (void)connectWithEmailAddress:(NSString *)emailAddress
                       password:(NSString *)password
                         apiKey:(NSString *)apiKey
               networkIdentifer:(NSString *)networkIdentifer
                     parameters:(NSDictionary *)parameters
                completionBlock:(AlfrescoSessionCompletionBlock)completionBlock;



+ (void)connectWithOAuthData:(AlfrescoOAuthData *)oauthData
                  parameters:(NSDictionary *)parameters
             completionBlock:(AlfrescoSessionCompletionBlock)completionBlock;

+ (void)connectWithOAuthData:(AlfrescoOAuthData *)oauthData
            networkIdentifer:(NSString *)networkIdentifer
                  parameters:(NSDictionary *)parameters
             completionBlock:(AlfrescoSessionCompletionBlock)completionBlock;


/**
 This method obtains a list of available Cloud networks (or domains/tenants) for the registered user.
 @param completionBlock (AlfrescoArrayCompletionBlock). If successful, the block returns an NSArray object with a list of available networks - or nil if error occurs.
 */
- (void)retrieveNetworksWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock;



@end
