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
            NSString *key = [NSString stringWithFormat:@"%@.%@",kAlfrescoSessionInternalCache, [AlfrescoSiteCache class]];
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
    if (!memberSite) return;
    [memberSite performSelector:@selector(changeMemberState:) withObject:[NSNumber numberWithBool:YES]];
    if (![self.sitesCache containsObject:memberSite])
    {
        [self.sitesCache addObject:memberSite];
    }
}

- (void)addFavoriteSite:(AlfrescoSite *)favoriteSite
{
    if (!favoriteSite) return;
    [favoriteSite performSelector:@selector(changeFavouriteState:) withObject:[NSNumber numberWithBool:YES]];
    if (![self.sitesCache containsObject:favoriteSite])
    {
        [self.sitesCache addObject:favoriteSite];
    }    
}

- (void)addPendingSite:(AlfrescoSite *)pendingSite
{
    if (!pendingSite) return;
    [pendingSite performSelector:@selector(changePendingState:) withObject:[NSNumber numberWithBool:YES]];
    if (![self.sitesCache containsObject:pendingSite])
    {
        [self.sitesCache addObject:pendingSite];
    }
}

- (AlfrescoSite *)addPendingRequest:(AlfrescoOnPremiseJoinSiteRequest *)pendingRequest
{
    if (!pendingRequest) return nil;
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
        [self addToCache:site];
    }
    return site;
}

- (void)removeMemberSite:(AlfrescoSite *)memberSite
{
    if (!memberSite) return;
    [memberSite performSelector:@selector(changeMemberState:) withObject:[NSNumber numberWithBool:NO]];
    if ([self.sitesCache containsObject:memberSite] && !memberSite.isFavorite)
    {
        [self.sitesCache removeObject:memberSite];
    }
}

- (void)removeFavoriteSite:(AlfrescoSite *)favoriteSite
{
    if (!favoriteSite) return;
    [favoriteSite performSelector:@selector(changeFavouriteState:) withObject:[NSNumber numberWithBool:NO]];
    if ([self.sitesCache containsObject:favoriteSite] && !favoriteSite.isMember && !favoriteSite.isPendingMember)
    {
        [self.sitesCache addObject:favoriteSite];
    }
}

- (void)removePendingSite:(AlfrescoSite *)pendingSite
{
    if (!pendingSite) return;
    [pendingSite performSelector:@selector(changePendingState:) withObject:[NSNumber numberWithBool:NO]];
    if ([self.sitesCache containsObject:pendingSite] && !pendingSite.isFavorite)
    {
        [self.sitesCache removeObject:pendingSite];
    }
}

- (void)addSites:(NSArray *)sites hasMoreSites:(BOOL)hasMoreSites
{
    if (nil == sites)return;
    [self.sitesCache addObjectsFromArray:sites];
    self.hasMoreSites = hasMoreSites;
}

- (void)addMemberSites:(NSArray *)memberSites hasMoreMemberSites:(BOOL)hasMoreMemberSites
{
    if (nil == memberSites)return;
    for (AlfrescoSite *site in memberSites)
    {
        [self addMemberSite:site];
    }
    self.hasMoreMemberSites = hasMoreMemberSites;
}

- (void)addFavoriteSites:(NSArray *)favoriteSites hasMoreFavoriteSites:(BOOL)hasMoreFavoriteSites
{
    if (nil == favoriteSites)return;
    for (AlfrescoSite *site in favoriteSites)
    {
        [self addFavoriteSite:site];
    }
    self.hasMoreFavoriteSites = hasMoreFavoriteSites;
}

- (void)addPendingSites:(NSArray *)pendingSites hasMorePendingSites:(BOOL)hasMorePendingSites
{
    if (nil == pendingSites)return;
    for (AlfrescoSite *site in pendingSites)
    {
        [self addPendingSite:site];
    }
    self.hasMorePendingSites = hasMorePendingSites;
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
    if (nil == pendingRequests)return nil;
    for (AlfrescoOnPremiseJoinSiteRequest *pendingRequest in pendingRequests)
    {
        [self addPendingRequest:pendingRequest];
    }
    return [self pendingMemberSites];
    
}

#pragma methods each implementor of AlfrescoCache must implement
/**
 adds an array from All sites into the cache
 */
- (void)addObjectsToCache:(NSArray *)objectsArray
{
    if (nil == objectsArray)return;
    if (0 == objectsArray.count)return;
    [self.sitesCache addObjectsFromArray:objectsArray];
}

/**
 adds a single site to the cache. In the code we use this only for adding individual sites from either favourites, members or pending methods.
 Therefore, we add this site to the special cache - instead of the general one.
 */
- (void)addToCache:(AlfrescoSite *)site
{
    if ([self.sitesCache containsObject:site])return;
    AlfrescoSite *siteInCache = [self objectWithIdentifier:site.identifier];
    if (nil != siteInCache)
    {
        [self removeFromCache:siteInCache];
    }
    [self.sitesCache addObject:site];
}

/**
 removes an individual site from the special cache. We need to check whether the site has any other flag set. E.g. a favourite site can be
 also a member site. If one of the "special" flags (fav/mem/pending) is set we keep it in the cache.
 */
- (void)removeFromCache:(AlfrescoSite *)site
{
    AlfrescoSite *siteInCache = [self objectWithIdentifier:site.identifier];
    if (siteInCache)
    {
        [self.sitesCache removeObject:siteInCache];
        if ( (site.isFavorite && siteInCache.isFavorite) ||
            (site.isMember && siteInCache.isMember) ||
            (site.isPendingMember && siteInCache.isPendingMember) )
        {
            [self.sitesCache addObject:site];
        }
    }
}

/**
 clear both caches: general (all sites) and special (fav/mem/pending)
 */
- (void)clear
{
    [self.sitesCache removeAllObjects];
}
/**
 the method returns the first entry found for the identifier. Typically, a site id is unique - but this may not always be the case(?)
 */
- (id)objectWithIdentifier:(NSString *)identifier
{
    if (!identifier)return nil;
    NSPredicate *idPredicate = [NSPredicate predicateWithFormat:@"identifier == %@",identifier];
    NSArray *results = [self.sitesCache filteredArrayUsingPredicate:idPredicate];
    return (0 == results.count) ? nil : results[0];
}

- (BOOL)isInCache:(AlfrescoSite *)object
{
    NSPredicate *idPredicate = [NSPredicate predicateWithFormat:@"identifier == %@",object.identifier];
    NSArray *results = [self.sitesCache filteredArrayUsingPredicate:idPredicate];
    return (results.count > 0) ? YES : NO;
}

/**
 internal method that returns a site with one of the 3 flags set (fav/mem/pending)
 */
- (AlfrescoSite *)alfrescoSiteFromSite:(AlfrescoSite *)site siteFlag:(AlfrescoSiteFlags)siteFlag boolValue:(BOOL)boolValue
{
    NSMutableDictionary *properties = [self sitePropertiesFromSite:site];
    switch (siteFlag)
    {
        case AlfrescoSiteFavorite:
            [properties setObject:[NSNumber numberWithBool:boolValue] forKey:kAlfrescoSiteIsFavorite];
            break;
        case AlfrescoSiteMember:
            [properties setObject:[NSNumber numberWithBool:boolValue] forKey:kAlfrescoSiteIsMember];
            break;
        case AlfrescoSitePendingMember:
            [properties setObject:[NSNumber numberWithBool:boolValue] forKey:kAlfrescoSiteIsPendingMember];
            break;
        case AlfrescoSiteAll:
            break;
    }
    return [[AlfrescoSite alloc] initWithProperties:properties];
}


#pragma private methods
- (NSMutableDictionary *)sitePropertiesFromSite:(AlfrescoSite *)site
{
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    if (site.summary)
    {
        [properties setObject:site.summary forKey:kAlfrescoJSONDescription];
    }
    if (site.title)
    {
        [properties setObject:site.title forKey:kAlfrescoJSONTitle];
    }
    switch (site.visibility)
    {
        case AlfrescoSiteVisibilityPublic:
            [properties setObject:kAlfrescoJSONVisibilityPUBLIC forKey:kAlfrescoJSONVisibility];
            break;
        case AlfrescoSiteVisibilityPrivate:
            [properties setObject:kAlfrescoJSONVisibilityPRIVATE forKey:kAlfrescoJSONVisibility];
            break;
        case AlfrescoSiteVisibilityModerated:
            [properties setObject:kAlfrescoJSONVisibilityMODERATED forKey:kAlfrescoJSONVisibility];
            break;
    }
    if (site.GUID)
    {
        [properties setObject:site.GUID forKey:kAlfrescoJSONGUID];
    }
    if (site.shortName)
    {
        [properties setObject:site.shortName forKey:kAlfrescoJSONShortname];
    }
    if (site.identifier)
    {
        [properties setObject:site.shortName forKey:kAlfrescoJSONIdentifier];
    }
    [properties setValue:[NSNumber numberWithBool:site.isFavorite] forKey:kAlfrescoSiteIsFavorite];
    [properties setValue:[NSNumber numberWithBool:site.isMember] forKey:kAlfrescoSiteIsMember];
    [properties setValue:[NSNumber numberWithBool:site.isPendingMember] forKey:kAlfrescoSiteIsPendingMember];
    return properties;
}

@end
