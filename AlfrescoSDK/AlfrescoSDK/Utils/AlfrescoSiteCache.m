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
#import "AlfrescoJoinSiteRequest.h"
#import "AlfrescoInternalConstants.h"

@interface AlfrescoSiteCache ()
@property (nonatomic, strong) NSMutableArray * siteCache;
@end

@implementation AlfrescoSiteCache

- (id)init
{
    self = [super init];
    if (nil != self)
    {
        _siteCache = [NSMutableArray arrayWithCapacity:0];
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
            [session setObject:cache forCacheKey:key];
        }
    });
    return cache;
}

- (NSArray *)allSites
{
    return self.siteCache;
}

- (NSArray *)memberSites
{
    NSPredicate *memberPredicate = [NSPredicate predicateWithFormat:@"isMember == YES"];
    return [self.siteCache filteredArrayUsingPredicate:memberPredicate];
}

- (NSArray *)favoriteSites
{
    NSPredicate *favoritePredicate = [NSPredicate predicateWithFormat:@"isFavorite == YES"];
    return [self.siteCache filteredArrayUsingPredicate:favoritePredicate];
}

- (NSArray *)pendingMemberSites
{
    NSPredicate *pendingMemberPredicate = [NSPredicate predicateWithFormat:@"isPendingMember == YES"];
    return [self.siteCache filteredArrayUsingPredicate:pendingMemberPredicate];
}

- (void)addMemberSites:(NSArray *)memberSites
{
    for (AlfrescoSite *site in memberSites)
    {
        AlfrescoSite *memberSite = [self alfrescoSiteFromSite:site siteFlag:AlfrescoSiteMember boolValue:YES];
        [self addToCache:memberSite];
    }    
}

- (void)addFavoriteSites:(NSArray *)favoriteSites
{
    for (AlfrescoSite *site in favoriteSites)
    {
        AlfrescoSite *favoriteSite = [self alfrescoSiteFromSite:site siteFlag:AlfrescoSiteFavorite boolValue:YES];
        [self addToCache:favoriteSite];
    }    
}

- (void)addPendingSites:(NSArray *)pendingSites
{
    for (AlfrescoJoinSiteRequest *pendingRequest in pendingSites)
    {
        AlfrescoSite *site = [self objectWithIdentifier:pendingRequest.shortName];
        if (site)
        {
            AlfrescoSite *pendingSite = [self alfrescoSiteFromSite:site siteFlag:AlfrescoSitePendingMember boolValue:YES];
            [self addToCache:pendingSite];
        }
    }
}



#pragma methods each implementor of AlfrescoCache must implement
/**
 adds an entire Site array to the cache
 */
- (void)addObjectsToCache:(NSArray *)objectsArray
{
    for (AlfrescoSite *site in objectsArray)
    {
        [self addToCache:site];
    }
}

/**
 adds a single site to the cache. If a site with an identifer already exists in the cache, then
 we replace the cache entry with the site passed into this method. Most likely, the new site object will have
 some parameter flags set differently compared with the existing cache entry.
 */
- (void)addToCache:(AlfrescoSite *)site
{
    if ([self.siteCache containsObject:site])
    {
        return;
    }
    AlfrescoSite *siteInCache = [self objectWithIdentifier:site.identifier];
    if (nil != siteInCache)
    {
        [self removeFromCache:siteInCache];
    }
    [self.siteCache addObject:site];
}

/**
 removes a single site from the cache. However, we can only fully remove the site from the cache if all flags (pending, member, favorite) are
 set to Off. If on the other side, we remove only a single flag (e.g. favourite) but we still retain another (e.g. member) - then we replace
 the existing site in the cache with the object containing the new settings.
 */
- (void)removeFromCache:(AlfrescoSite *)site
{
    AlfrescoSite *siteInCache = [self objectWithIdentifier:site.identifier];
    if (siteInCache)
    {
        [self.siteCache removeObject:siteInCache];
        if ( (site.isFavorite && siteInCache.isFavorite) ||
            (site.isMember && siteInCache.isMember) ||
            (site.isPendingMember && siteInCache.isPendingMember) )
        {
            [self.siteCache addObject:site];
        }
    }
}

- (void)clear
{
    [self.siteCache removeAllObjects];
}
/**
 the method returns the first entry found for the identifier. Typically, a site id is unique - but this may not always be the case(?)
 */
- (id)objectWithIdentifier:(NSString *)identifier
{
    NSPredicate *idPredicate = [NSPredicate predicateWithFormat:@"identifier == %@",identifier];
    NSArray *results = [self.siteCache filteredArrayUsingPredicate:idPredicate];
    if (0 == results.count)
    {
        return nil;
    }
    else
    {
        return [results objectAtIndex:0];
    }
}

- (BOOL)isInCache:(AlfrescoSite *)object
{
    NSPredicate *idPredicate = [NSPredicate predicateWithFormat:@"identifier == %@",object.identifier];
    NSArray *results = [self.siteCache filteredArrayUsingPredicate:idPredicate];
    return (results.count > 0) ? YES : NO;
}

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
