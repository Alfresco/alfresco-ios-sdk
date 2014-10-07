/*
 ******************************************************************************
 * Copyright (C) 2005-2013 Alfresco Software Limited.
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

#import <Foundation/Foundation.h>
#import "AlfrescoSite.h"
#import "AlfrescoSession.h"

@protocol AlfrescoSiteCacheDataDelegate <NSObject>
- (AlfrescoRequest *)retrieveMemberSiteDataWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock;
- (AlfrescoRequest *)retrieveFavoriteSiteDataWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock;
- (AlfrescoRequest *)retrievePendingSiteDataWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock;
- (AlfrescoRequest *)retrieveDataForSiteWithShortName:(NSString *)shortName completionBlock:(AlfrescoSiteCompletionBlock)completionBlock;
@end

@interface AlfrescoSiteCache : NSObject

@property (nonatomic, assign, readonly) BOOL isCacheBuilt;
@property (nonatomic, strong, readonly) NSArray *memberSites;
@property (nonatomic, strong, readonly) NSArray *favoriteSites;
@property (nonatomic, strong, readonly) NSArray *pendingSites;

- (AlfrescoRequest *)buildCacheWithDelegate:(id<AlfrescoSiteCacheDataDelegate>)delegate completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock;

- (void)cacheSite:(AlfrescoSite *)site;

- (void)cacheSite:(AlfrescoSite *)site member:(BOOL)member pending:(BOOL)pending favorite:(BOOL)favorite;

- (AlfrescoSite *)siteWithShortName:(NSString *)shortName;

- (void)clear;

@end
