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

#pragma methods each implementor of AlfrescoCache must implement
- (void)addToCache:(AlfrescoSite *)site
{
    AlfrescoSite *siteInCache = [self objectWithIdentifier:site.identifier];
    if (nil != siteInCache)
    {
        [self removeFromCache:siteInCache];
    }
    [self.siteCache addObject:site];
}

- (void)removeFromCache:(AlfrescoSite *)site
{
    AlfrescoSite *siteInCache = [self objectWithIdentifier:site.identifier];
    if (siteInCache)
    {
        [self.siteCache removeObject:siteInCache];
    }
    if ( (site.isFavorite && siteInCache.isFavorite) ||
        (site.isMember && siteInCache.isMember) ||
        (site.isPendingMember && siteInCache.isPendingMember) )
    {
        [self.siteCache addObject:site];
    }
}

- (void)clear
{
    [self.siteCache removeAllObjects];
}

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

- (BOOL)isInCache:(id)object
{
    return [self.siteCache containsObject:object];
}



@end
