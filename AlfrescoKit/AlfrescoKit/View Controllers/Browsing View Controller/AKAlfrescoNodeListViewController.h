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

/** Provides a basic list view controller to navigate through the repository hierarchy.
 
 Author: Tauseef Mughal (Alfresco)
 */

#import <UIKit/UIKit.h>
#import <AlfrescoSDK-iOS/AlfrescoSDK.h>

@class AKAlfrescoNodeListViewController;

@protocol AKAlfrescoNodeListViewControllerDelegate <NSObject>

@optional
- (void)listViewController:(AKAlfrescoNodeListViewController *)listViewController didRetrieveItems:(NSArray *)items;
- (void)listViewController:(AKAlfrescoNodeListViewController *)listViewController didFailToRetrieveItemsWithError:(NSError *)error;

- (void)listViewController:(AKAlfrescoNodeListViewController *)listViewController didSelectAlfrescoDocument:(AlfrescoDocument *)document;

@end

@interface AKAlfrescoNodeListViewController : AKUIViewController

@property (nonatomic, strong, readonly) AlfrescoFolder *folder;
@property (nonatomic, weak) id<AKAlfrescoNodeListViewControllerDelegate> delegate;

- (instancetype)initWithAlfrescoFolder:(AlfrescoFolder *)folder delegate:(id<AKAlfrescoNodeListViewControllerDelegate>)delegate session:(id<AlfrescoSession>)session;
- (instancetype)initWithAlfrescoFolder:(AlfrescoFolder *)folder listingContext:(AlfrescoListingContext *)listingcontext delegate:(id<AKAlfrescoNodeListViewControllerDelegate>)delegate session:(id<AlfrescoSession>)session;

- (void)updateSession:(id<AlfrescoSession>)session;

@end
