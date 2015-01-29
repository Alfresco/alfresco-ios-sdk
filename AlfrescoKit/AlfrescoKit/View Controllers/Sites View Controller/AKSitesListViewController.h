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

/** AKSitesListViewController
 
 Author: Tauseef Mughal (Alfresco)
 */

#import <UIKit/UIKit.h>
#import "AKNetworkActivity.h"

@class AKSitesListViewController;

@protocol AKSitesListViewControllerDelegate <NSObject, AKNetworkActivity>

- (void)sitesListViewController:(AKSitesListViewController *)sitesListViewController
                  didSelectSite:(AlfrescoSite *)site
          documentLibraryFolder:(AlfrescoFolder *)documentLibraryFolder
                          error:(NSError *)error;

@end

@interface AKSitesListViewController : AKUIViewController

@property (nonatomic, weak) id<AKSitesListViewControllerDelegate> delegate;

- (instancetype)initWithSession:(id<AlfrescoSession>)session;
- (instancetype)initWithSession:(id<AlfrescoSession>)session delegate:(id<AKSitesListViewControllerDelegate>)delegate;
- (instancetype)initWithListingContext:(AlfrescoListingContext *)listingContext session:(id<AlfrescoSession>)session;
- (instancetype)initWithListingContext:(AlfrescoListingContext *)listingContext delegate:(id<AKSitesListViewControllerDelegate>)delegate session:(id<AlfrescoSession>)session;

- (void)updateSession:(id<AlfrescoSession>)session;

@end
