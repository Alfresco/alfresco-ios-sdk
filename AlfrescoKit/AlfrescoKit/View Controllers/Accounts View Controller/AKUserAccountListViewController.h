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

/** AKUserAccountListViewController
 
 Author: Tauseef Mughal (Alfresco)
 */

#import <UIKit/UIKit.h>

@protocol AKUserAccount;
@class AKUserAccountListViewController;

@protocol AKUserAccountListViewControllerDelegate <NSObject>

- (void)userAccountListViewController:(AKUserAccountListViewController *)accountListViewController
                 didLoginSuccessfully:(BOOL)loginSuccessful
                            toAccount:(id<AKUserAccount>)account
                      creatingSession:(id<AlfrescoSession>)session
                                error:(NSError *)error;
- (void)didSelectLocalFilesOnUserAccountListViewController:(AKUserAccountListViewController *)accountListViewController;

@optional
- (void)userAccountListViewController:(AKUserAccountListViewController *)accountListViewController
                 didSelectUserAccount:(id)userAccount;

@end

@interface AKUserAccountListViewController : AKUIViewController

@property (nonatomic, weak) id<AKUserAccountListViewControllerDelegate> delegate;

- (instancetype)initWithAccountList:(NSArray *)accountList;
- (instancetype)initWithAccountList:(NSArray *)accountList delegate:(id<AKUserAccountListViewControllerDelegate>)delegate;

@end
