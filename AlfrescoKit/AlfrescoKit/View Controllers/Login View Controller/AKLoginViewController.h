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

/** Provides a basic login username and password entry. Attempts logging in before
 invoking the callback with the appropiate response.
 
 Author: Tauseef Mughal (Alfresco)
 */

#import <UIKit/UIKit.h>
#import "AKUserAccount.h"
#import "AKNetworkActivity.h"

@class AKLoginViewController;

@protocol AKLoginViewControllerDelegate <NSObject, AKNetworkActivity>

- (void)loginViewController:(AKLoginViewController *)loginController
       didLoginSuccessfully:(BOOL)loginSuccessful
                  toAccount:(id<AKUserAccount>)account
                   username:(NSString *)username
                   password:(NSString *)password
            creatingSession:(id<AlfrescoSession>)session
                      error:(NSError *)error;

@end

@interface AKLoginViewController : AKUIViewController

@property (nonatomic, weak) id<AKLoginViewControllerDelegate> delegate;

- (instancetype)initWithUserAccount:(id<AKUserAccount>)userAccount;
- (instancetype)initWithUserAccount:(id<AKUserAccount>)userAccount delegate:(id<AKLoginViewControllerDelegate>)delegate;

@end
