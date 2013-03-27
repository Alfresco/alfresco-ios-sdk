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

typedef enum
{
    AlfrescoSiteFavorite = 0,
    AlfrescoSiteMember,
    AlfrescoSitePendingMember,
    AlfrescoSiteAll    
} AlfrescoSiteFlags;

@class AlfrescoOnPremiseJoinSiteRequest;

@interface AlfrescoSiteCache : NSObject
@property (nonatomic, assign, readonly) BOOL hasMoreSites;
@property (nonatomic, assign, readonly) BOOL hasMoreMemberSites;
@property (nonatomic, assign, readonly) BOOL hasMoreFavoriteSites;
@property (nonatomic, assign, readonly) BOOL hasMorePendingSites;
/**
 initialiser
 */
+ (id)siteCacheForSession:(id<AlfrescoSession>)session;

/**
 clears all entries in the cache
 */
- (void)clear;

/**
 returns my sites
 */
- (NSArray *)memberSites;

/**
 returns favourite sites
 */
- (NSArray *)favoriteSites;

/**
 returns sites for which a join request is pending (this would only be MODERATED sites)
 */
- (NSArray *)pendingMemberSites;

/**
 returns the entire site cache
 */
- (NSArray *)allSites;

- (void)addMemberSite:(AlfrescoSite *)memberSite;

- (void)addFavoriteSite:(AlfrescoSite *)favoriteSite;

- (void)addPendingSite:(AlfrescoSite *)pendingSite;

- (AlfrescoSite *)addPendingRequest:(AlfrescoOnPremiseJoinSiteRequest *)pendingRequest;

- (void)removeMemberSite:(AlfrescoSite *)memberSite;

- (void)removeFavoriteSite:(AlfrescoSite *)favoriteSite;

- (void)removePendingSite:(AlfrescoSite *)pendingSite;

- (void)addSites:(NSArray *)sites hasMoreSites:(BOOL)hasMoreSites;

- (void)addMemberSites:(NSArray *)memberSites hasMoreMemberSites:(BOOL)hasMoreMemberSites;

- (void)addFavoriteSites:(NSArray *)favoriteSites hasMoreFavoriteSites:(BOOL)hasMoreFavoriteSites;

- (void)addPendingSites:(NSArray *)pendingSites hasMorePendingSites:(BOOL)hasMorePendingSites;

- (void)addSites:(NSArray *)sites;

- (void)addMemberSites:(NSArray *)memberSites;

- (void)addFavoriteSites:(NSArray *)favoriteSites;

- (void)addPendingSites:(NSArray *)pendingSites;

- (NSArray *)addPendingRequests:(NSArray *)pendingRequests;

@end
