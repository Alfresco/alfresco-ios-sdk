/*
 ******************************************************************************
 * Copyright (C) 2005-2015 Alfresco Software Limited.
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

#import "AKLoginService.h"
#import "AKUtility.h"

@implementation AKLoginService

- (AlfrescoRequest *)loginToAccount:(id<AKUserAccount>)userAccount networkIdentifier:(NSString *)networkIdentifier completionBlock:(AKLoginCompletionBlock)completionBlock
{
    AlfrescoRequest *loginRequest = nil;
    
    if (userAccount.isOnPremiseAccount)
    {
        loginRequest = [self loginToOnPremiseRepositoryWithAccount:userAccount password:userAccount.password completionBlock:completionBlock];
    }
    else
    {
        loginRequest = [self loginToCloudRepositoryWithAccount:userAccount networkIdentifier:networkIdentifier completionBlock:completionBlock];
    }
    
    return loginRequest;
}

#pragma mark - Private Functions

- (AlfrescoRequest *)loginToOnPremiseRepositoryWithAccount:(id<AKUserAccount>)account password:(NSString *)password completionBlock:(AKLoginCompletionBlock)completionBlock
{
    AlfrescoRequest *loginRequest = nil;
    
    NSString *repoServerURLString = [AKUtility onPremiseServerURLWithProtocol:account.protocol serverAddress:account.serverAddress port:account.serverPort];
    NSURL *repoURL = [NSURL URLWithString:repoServerURLString];
    
    loginRequest = [AlfrescoRepositorySession connectWithUrl:repoURL username:account.username password:account.password completionBlock:^(id<AlfrescoSession> session, NSError *error) {
        if (error)
        {
            completionBlock(NO, nil, error);
        }
        else
        {
            completionBlock(YES, session, error);
        }
    }];
    
    return loginRequest;
}

- (AlfrescoRequest *)loginToCloudRepositoryWithAccount:(id<AKUserAccount>)account networkIdentifier:(NSString *)networkIdentifier completionBlock:(AKLoginCompletionBlock)completionBlock
{
    AlfrescoRequest *loginRequest = nil;
    
    if (networkIdentifier)
    {
        loginRequest = [AlfrescoCloudSession connectWithOAuthData:account.oAuthData networkIdentifer:networkIdentifier completionBlock:^(id<AlfrescoSession> session, NSError *error) {
            completionBlock(!!session, session, error);
        }];
    }
    else
    {
        loginRequest = [AlfrescoCloudSession connectWithOAuthData:account.oAuthData completionBlock:^(id<AlfrescoSession> session, NSError *error) {
            completionBlock(!!session, session, error);
        }];
    }
    
    return loginRequest;
}

@end
