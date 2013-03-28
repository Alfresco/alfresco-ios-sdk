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

#import "AlfrescoSiteCache.h"
#import "AlfrescoOnPremiseJoinSiteRequest.h"
#import "AlfrescoInternalConstants.h"

@interface AlfrescoSiteCache ()
@property (nonatomic, strong) NSMutableArray * sitesCache;
@property (nonatomic, assign, readwrite) BOOL hasMoreSites;
@property (nonatomic, assign, readwrite) BOOL hasMoreMemberSites;
@property (nonatomic, assign, readwrite) BOOL hasMoreFavoriteSites;
@property (nonatomic, assign, readwrite) BOOL hasMorePendingSites;
@end

@implementation AlfrescoSiteCache

- (id)init
{
    self = [super init];
    if (nil != self)
    {
        _sitesCache = [NSMutableArray arrayWithCapacity:0];
        _hasMoreFavoriteSites = YES;
        _hasMoreMemberSites = YES;
        _hasMorePendingSites = YES;
        _hasMoreSites = YES;
    }
    return self;
}

+ (id)siteCacheForSession:(id<AlfrescoSession>)session
{
    static dispatch_once_t singleDispatchToken;
    static AlfrescoSiteCache *cache = nil;
    dispatch_once(&singleDispatchToken, ^{
        cache = [[self alloc] init];
        if (cache)
        {
            NSString *key = [NSString stringWithFormat:@"%@%@",kAlfrescoSessionInternalCache, [AlfrescoSiteCache class]];
            [session setObject:cache forParameter:key];
        }
    });
    return cache;
}

- (NSArray *)allSites
{
    return self.sitesCache;
}

- (NSArray *)memberSites
{
    NSPredicate *memberPredicate = [NSPredicate predicateWithFormat:@"isMember == YES"];
    return [self.sitesCache filteredArrayUsingPredicate:memberPredicate];
}

- (NSArray *)favoriteSites
{
    NSPredicate *favoritePredicate = [NSPredicate predicateWithFormat:@"isFavorite == YES"];
    return [self.sitesCache filteredArrayUsingPredicate:favoritePredicate];
}

- (NSArray *)pendingMemberSites
{
    NSPredicate *pendingMemberPredicate = [NSPredicate predicateWithFormat:@"isPendingMember == YES"];
    return [self.sitesCache filteredArrayUsingPredicate:pendingMemberPredicate];
}


- (void)addMemberSite:(AlfrescoSite *)memberSite
{
    if (nil == memberSite)
    {
        return;
    }
    [memberSite performSelector:@selector(changeMemberState:) withObject:[NSNumber numberWithBool:YES]];
    NSUInteger foundSiteIndex = [self.sitesCache indexOfObject:memberSite];
    if (NSNotFound == foundSiteIndex)
    {
        [self.sitesCache addObject:memberSite];
    }
    else
    {
        [self.sitesCache replaceObjectAtIndex:foundSiteIndex withObject:memberSite];
    }
}

- (void)addFavoriteSite:(AlfrescoSite *)favoriteSite
{
    if (nil == favoriteSite)
    {
        return;
    }
    [favoriteSite performSelector:@selector(changeFavouriteState:) withObject:[NSNumber numberWithBool:YES]];
    NSUInteger foundSiteIndex = [self.sitesCache indexOfObject:favoriteSite];
    if (NSNotFound == foundSiteIndex)
    {
        [self.sitesCache addObject:favoriteSite];
    }
    else
    {
        [self.sitesCache replaceObjectAtIndex:foundSiteIndex withObject:favoriteSite];
    }
}

- (void)addPendingSite:(AlfrescoSite *)pendingSite
{
    if (nil == pendingSite)
    {
        return;
    }
    [pendingSite performSelector:@selector(changePendingState:) withObject:[NSNumber numberWithBool:YES]];
    NSUInteger foundSiteIndex = [self.sitesCache indexOfObject:pendingSite];
    if (NSNotFound == foundSiteIndex)
    {
        [self.sitesCache addObject:pendingSite];
    }
    else
    {
        [self.sitesCache replaceObjectAtIndex:foundSiteIndex withObject:pendingSite];
    }
}

- (AlfrescoSite *)addPendingRequest:(AlfrescoOnPremiseJoinSiteRequest *)pendingRequest
{
    if (nil == pendingRequest)
    {
        return nil;
    }
    AlfrescoSite *site = [self objectWithIdentifier:pendingRequest.shortName];
    if (site)
    {
        [self addPendingSite:site];
    }
    else
    {
        NSMutableDictionary *siteProperties = [NSMutableDictionary dictionary];
        [siteProperties setValue:pendingRequest.shortName forKey:kAlfrescoJSONShortname];
        [siteProperties setValue:[NSNumber numberWithBool:YES] forKey:kAlfrescoSiteIsPendingMember];
        site = [[AlfrescoSite alloc] initWithProperties:siteProperties];
        [self.sitesCache addObject:site];
    }
    return site;
}

- (void)removeMemberSite:(AlfrescoSite *)memberSite
{
    if (nil == memberSite)
    {
        return;
    }
    [memberSite performSelector:@selector(changeMemberState:) withObject:[NSNumber numberWithBool:NO]];
    if ([self.sitesCache containsObject:memberSite] && !memberSite.isFavorite)
    {
        [self.sitesCache removeObject:memberSite];
    }
}

- (void)removeFavoriteSite:(AlfrescoSite *)favoriteSite
{
    if (nil == favoriteSite)
    {
        return;
    }
    [favoriteSite performSelector:@selector(changeFavouriteState:) withObject:[NSNumber numberWithBool:NO]];
    if ([self.sitesCache containsObject:favoriteSite] && !favoriteSite.isMember && !favoriteSite.isPendingMember)
    {
        [self.sitesCache addObject:favoriteSite];
    }
}

- (void)removePendingSite:(AlfrescoSite *)pendingSite
{
    if (nil == pendingSite)
    {
        return;
    }
    [pendingSite performSelector:@selector(changePendingState:) withObject:[NSNumber numberWithBool:NO]];
    if ([self.sitesCache containsObject:pendingSite] && !pendingSite.isFavorite)
    {
        [self.sitesCache removeObject:pendingSite];
    }
}

- (void)addSites:(NSArray *)sites hasMoreSites:(BOOL)hasMoreSites
{
    self.hasMoreSites = hasMoreSites;
    if (nil == sites)
    {
        return;
    }
    for (AlfrescoSite *site in sites)
    {
        NSUInteger foundIndex = [self.sitesCache indexOfObject:site];
        if (NSNotFound == foundIndex)
        {
            [self.sitesCache addObject:site];
        }
    }
}

- (void)addMemberSites:(NSArray *)memberSites hasMoreMemberSites:(BOOL)hasMoreMemberSites
{
    self.hasMoreMemberSites = hasMoreMemberSites;
    if (nil == memberSites)
    {
        return;
    }
    for (AlfrescoSite *site in memberSites)
    {
        [self addMemberSite:site];
    }
}

- (void)addFavoriteSites:(NSArray *)favoriteSites hasMoreFavoriteSites:(BOOL)hasMoreFavoriteSites
{
    self.hasMoreFavoriteSites = hasMoreFavoriteSites;
    if (nil == favoriteSites)
    {
        return;
    }
    for (AlfrescoSite *site in favoriteSites)
    {
        [self addFavoriteSite:site];
    }
}

- (void)addPendingSites:(NSArray *)pendingSites hasMorePendingSites:(BOOL)hasMorePendingSites
{
    self.hasMorePendingSites = hasMorePendingSites;
    if (nil == pendingSites)
    {
        return;
    }
    for (AlfrescoSite *site in pendingSites)
    {
        [self addPendingSite:site];
    }
}

- (void)addSites:(NSArray *)sites
{
    [self addSites:sites hasMoreSites:NO];
}


- (void)addMemberSites:(NSArray *)memberSites
{
    [self addMemberSites:memberSites hasMoreMemberSites:NO];
}

- (void)addFavoriteSites:(NSArray *)favoriteSites
{
    [self addFavoriteSites:favoriteSites hasMoreFavoriteSites:NO];
}

- (void)addPendingSites:(NSArray *)pendingSites
{
    [self addPendingSites:pendingSites hasMorePendingSites:NO];
}

- (NSArray *)addPendingRequests:(NSArray *)pendingRequests
{
    if (nil == pendingRequests)
    {
        return nil;
    }
    for (AlfrescoOnPremiseJoinSiteRequest *pendingRequest in pendingRequests)
    {
        [self addPendingRequest:pendingRequest];
    }
    return [self pendingMemberSites];
    
}

- (void)clear
{
    [self.sitesCache removeAllObjects];
}

/**
 the method returns the first entry found for the identifier. Typically, a site id is unique - but this may not always be the case(?)
 */
- (AlfrescoSite *)objectWithIdentifier:(NSString *)identifier
{
    if (!identifier)return nil;
    NSPredicate *idPredicate = [NSPredicate predicateWithFormat:@"identifier == %@",identifier];
    NSArray *results = [self.sitesCache filteredArrayUsingPredicate:idPredicate];
    return (0 == results.count) ? nil : results[0];
}


@end
