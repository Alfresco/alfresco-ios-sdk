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
@end

@implementation AlfrescoSiteCache

- (id)init
{
    self = [super init];
    if (nil != self)
    {
        _sitesCache = [NSMutableArray arrayWithCapacity:0];
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

- (void)addMemberSites:(NSArray *)memberSites
{
    if (nil == memberSites)
    {
        return;
    }
    for (AlfrescoSite *site in memberSites)
    {
        AlfrescoSite *memberSite = [self alfrescoSiteFromSite:site siteFlag:AlfrescoSiteMember boolValue:YES];
        [self addToCache:memberSite];
    }    
}

- (void)addFavoriteSites:(NSArray *)favoriteSites
{
    if (nil == favoriteSites)
    {
        return;
    }
    for (AlfrescoSite *site in favoriteSites)
    {
        AlfrescoSite *favoriteSite = [self alfrescoSiteFromSite:site siteFlag:AlfrescoSiteFavorite boolValue:YES];
        [self addToCache:favoriteSite];
    }    
}

/**
 this is used for cloud service.
 */
- (void)addPendingSites:(NSArray *)pendingSites
{
    if (nil == pendingSites)
    {
        return;
    }
    for (AlfrescoSite *site in pendingSites)
    {
        AlfrescoSite *pendingSite = [self alfrescoSiteFromSite:site siteFlag:AlfrescoSitePendingMember boolValue:YES];
        [self addToCache:pendingSite];
    }
}

/**
 this method is for On Premise only. Here we get Join Requests objects back. 
 If we have the site in the cache already, we replace it with the flag pending set to true.
 We then add it to the cache.
 If we cannot find an existing item in the special, we construct a  site based on the shortname and flag alone.
 */
- (void)addPendingRequests:(NSArray *)pendingRequests
{
    if (nil == pendingRequests)
    {
        return;
    }
    for (AlfrescoOnPremiseJoinSiteRequest *pendingRequest in pendingRequests)
    {
        AlfrescoSite *site = [self objectWithIdentifier:pendingRequest.shortName];
        if (site)
        {
            AlfrescoSite *pendingSite = [self alfrescoSiteFromSite:site siteFlag:AlfrescoSitePendingMember boolValue:YES];
            [self addToCache:pendingSite];
        }
        else
        {
            NSMutableDictionary *siteProperties = [NSMutableDictionary dictionary];
            [siteProperties setValue:pendingRequest.shortName forKey:kAlfrescoJSONShortname];
            [siteProperties setValue:[NSNumber numberWithBool:YES] forKey:kAlfrescoSiteIsPendingMember];
            site = [[AlfrescoSite alloc] initWithProperties:siteProperties];
            [self addToCache:site];
        }
    }
    
}



#pragma methods each implementor of AlfrescoCache must implement
/**
 adds an array from All sites into the cache
 */
- (void)addObjectsToCache:(NSArray *)objectsArray
{
    if (nil == objectsArray)
    {
        return;
    }
    if (0 == objectsArray.count)
    {
        return;
    }
    [self.sitesCache addObjectsFromArray:objectsArray];
}

/**
 adds a single site to the cache. In the code we use this only for adding individual sites from either favourites, members or pending methods.
 Therefore, we add this site to the special cache - instead of the general one.
 */
- (void)addToCache:(AlfrescoSite *)site
{
    if ([self.sitesCache containsObject:site])
    {
        return;
    }
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
