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
#import "AlfrescoLog.h"

#define TIMEOUTINTERVAL 120

@interface AlfrescoSiteCache ()
@property (nonatomic, assign, readwrite) BOOL isCacheBuilt;
@property (nonatomic, strong, readwrite) NSArray *memberSites;
@property (nonatomic, strong, readwrite) NSArray *favoriteSites;
@property (nonatomic, strong, readwrite) NSArray *pendingSites;

@property (nonatomic, weak) id<AlfrescoSiteCacheDataDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *memberSiteData;
@property (nonatomic, strong) NSMutableArray *favoriteSiteData;
@property (nonatomic, strong) NSMutableArray *pendingSiteData;
@property (nonatomic, strong) NSMutableDictionary *internalSiteCache;
@end

@implementation AlfrescoSiteCache

- (instancetype)initWithSiteCacheDataDelegate:(id<AlfrescoSiteCacheDataDelegate>)siteCacheDataDelegate
{
    self = [super init];
    if (nil != self)
    {
        self.isCacheBuilt = NO;
        self.delegate = siteCacheDataDelegate;
    }
    return self;
}

/**
 clears all entries in the cache
 */
- (void)clear
{
    self.isCacheBuilt = NO;
    [self.internalSiteCache removeAllObjects];
}

- (AlfrescoRequest *)buildCacheWithCompletionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    AlfrescoLogDebug(@"Building site cache");

    // start the daisy chained methods to collect all the data required to build the initial caches
    AlfrescoLogDebug(@"Requesting member site data from delegate");
    __block AlfrescoRequest *request = [self.delegate retrieveMemberSiteDataWithCompletionBlock:^(NSArray *memberData, NSError *error) {
        if (memberData != nil)
        {
            // store member site data
            self.memberSiteData = [NSMutableArray arrayWithArray:memberData];
            
            // get favorite data
            AlfrescoLogDebug(@"Requesting favorite site data from delegate");
            request = [self.delegate retrieveFavoriteSiteDataWithCompletionBlock:^(NSArray *favoriteData, NSError *error) {
                if (favoriteData != nil)
                {
                    // store favorite site data
                    self.favoriteSiteData = [NSMutableArray arrayWithArray:favoriteData];
                    
                    // get pending data
                    AlfrescoLogDebug(@"Requesting pending site data from delegate");
                    request = [self.delegate retrievePendingSiteDataWithCompletionBlock:^(NSArray *pendingData, NSError *error) {
                        if (pendingData != nil)
                        {
                            // store the pending data
                            self.pendingSiteData = [NSMutableArray arrayWithArray:pendingData];
                            
                            // process the data
                            [self processCacheDataWithCompletionBlock:completionBlock];
                        }
                        else
                        {
                            completionBlock(NO, error);
                        }
                    }];
                }
                else
                {
                    completionBlock(NO, error);
                }
            }];
        }
        else
        {
            completionBlock(NO, error);
        }
    }];
    
    return request;
}

- (void)processCacheDataWithCompletionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    // this could take some time, especially if sites have to be individually retrieved,
    // so move all this off the main thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *namesOfMissingSites = [NSMutableArray array];

        self.internalSiteCache = [NSMutableDictionary dictionary];

        // add sites the user is a member of to the internal cache with member flag set
        for (AlfrescoSite *site in self.memberSiteData)
        {
            [self cacheSite:site member:YES pending:NO favorite:NO];
        }

        // determine what form the favorite data is (onprem will be site names, public api will be site objects)
        if (self.favoriteSiteData.count > 0)
        {
            // retrieve first object to get type
            id firstObj = self.favoriteSiteData.firstObject;
            if ([firstObj isKindOfClass:[AlfrescoSite class]])
            {
                for (AlfrescoSite *site in self.favoriteSiteData)
                {
                    AlfrescoSite *cachedSite = (self.internalSiteCache)[site.shortName];
                    if (cachedSite != nil)
                    {
                        // if site is already cached just update favorite flag
                        [self updateFavoriteStateForSite:cachedSite state:YES];
                    }
                    else
                    {
                        // add the site to the cache marked as a favorite
                        [self cacheSite:site member:NO pending:NO favorite:YES];
                    }
                }
            }
            else
            {
                for (NSString *siteShortName in self.favoriteSiteData)
                {
                    AlfrescoSite *cachedSite = (self.internalSiteCache)[siteShortName];
                    if (cachedSite != nil)
                    {
                        // if site is already cached just update favorite flag
                        [self updateFavoriteStateForSite:cachedSite state:YES];
                    }
                    else
                    {
                        // add site to list to retrieve individually
                        [namesOfMissingSites addObject:siteShortName];
                    }
                }
            }
        }

        // determine what form the pending data is (onprem will be site names, public api will be site objects)
        if (self.pendingSiteData.count > 0)
        {
            // retrieve first object to get type
            id firstObj = self.pendingSiteData.firstObject;
            if ([firstObj isKindOfClass:[AlfrescoSite class]])
            {
                for (AlfrescoSite *site in self.pendingSiteData)
                {
                    AlfrescoSite *cachedSite = (self.internalSiteCache)[site.shortName];
                    if (cachedSite != nil)
                    {
                        // if site is already cached just update pending flag
                        [self updatePendingStateForSite:cachedSite state:YES];
                    }
                    else
                    {
                        // add the site to the cache marked as pending
                        [self cacheSite:site member:NO pending:YES favorite:NO];
                    }
                }
            }
            else
            {
                // add all the pending site names to the list of sites that need fetching
                [namesOfMissingSites addObjectsFromArray:self.pendingSiteData];
            }
        }

        if (namesOfMissingSites.count > 0)
        {
            // retrieve all the sites we don't have full data for (NOTE: blocks until they are retrieved or times out)
            // TODO: we need a MUCH nicer way of doing this, can we use pre-defined blocks i.e. last one sets flags
            
            AlfrescoLogDebug(@"Fetching missing site data");
            
            __block BOOL allSitesFetched = NO;
            NSString *siteName = nil;
            for (int i = 0; i < namesOfMissingSites.count; i++)
            {
                siteName = namesOfMissingSites[i];
                
                AlfrescoLogDebug(@"Fetching site data for site: %@", siteName);
                [self.delegate retrieveDataForSiteWithShortName:siteName completionBlock:^(AlfrescoSite *site, NSError *error) {
                    if (site != nil)
                    {
                        // add site to the internal cache with appropriate state
                        [self cacheSite:site member:NO
                              pending:[self.pendingSiteData containsObject:site.identifier]
                             favorite:[self.favoriteSiteData containsObject:site.identifier]];
                    }
                    
                    // determine whether we've finished
                    if (i == namesOfMissingSites.count-1)
                    {
                        allSitesFetched = YES;
                    }
                }];
            }
            
            // block until all sites are fetched or we timeout....we MUST find a better way of doing this!!
            NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:TIMEOUTINTERVAL];
            do {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
            } while (!allSitesFetched && [timeoutDate timeIntervalSinceNow] > 0 );
        }
        
        // now the caches have been built do some cleanup
        self.isCacheBuilt = YES;
        [self.memberSiteData removeAllObjects];
        [self.favoriteSiteData removeAllObjects];
        [self. pendingSiteData removeAllObjects];
        
        AlfrescoLogDebug(@"Site cache successfully built on background thread");
        
        // let the original caller know the cache is built on the main thread
        if (completionBlock != NULL)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(YES, nil);
            });
        }
    });
}

- (NSArray *)memberSites
{
    NSPredicate *memberPredicate = [NSPredicate predicateWithFormat:@"isMember == YES"];
    return [[self.internalSiteCache allValues]  filteredArrayUsingPredicate:memberPredicate];
}

- (NSArray *)pendingSites
{
    NSPredicate *pendingPredicate = [NSPredicate predicateWithFormat:@"isPendingMember == YES"];
    return [[self.internalSiteCache allValues] filteredArrayUsingPredicate:pendingPredicate];
}

- (NSArray *)favoriteSites
{
    NSPredicate *favoritePredicate = [NSPredicate predicateWithFormat:@"isFavorite == YES"];
    return [[self.internalSiteCache allValues] filteredArrayUsingPredicate:favoritePredicate];
}

- (void)cacheSite:(AlfrescoSite *)site
{
    // add the site to the internal cache with it's current state
    (self.internalSiteCache)[site.identifier] = site;
    
    AlfrescoLogTrace(@"Cached site: %@", site.shortName);
}

- (void)cacheSite:(AlfrescoSite *)site member:(BOOL)member pending:(BOOL)pending favorite:(BOOL)favorite
{
    // apply the given state to the given site object
    [self updateMemberStateForSite:site state:member];
    [self updatePendingStateForSite:site state:pending];
    [self updateFavoriteStateForSite:site state:favorite];
    
    // add the site to the internal cache
    (self.internalSiteCache)[site.identifier] = site;
    
    AlfrescoLogTrace(@"Cached site: %@", site.shortName);
}

- (AlfrescoSite *)siteWithShortName:(NSString *)shortName
{
    return (self.internalSiteCache)[shortName];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (void)updateMemberStateForSite:(AlfrescoSite *)site state:(BOOL)state
{
    SEL changeMemberStateSelector = sel_registerName("changeMemberState:");
    [site performSelector:changeMemberStateSelector withObject:@(state)];
}

- (void)updatePendingStateForSite:(AlfrescoSite *)site state:(BOOL)state
{
    SEL changePendingStateSelector = sel_registerName("changePendingState:");
    [site performSelector:changePendingStateSelector withObject:@(state)];
}

- (void)updateFavoriteStateForSite:(AlfrescoSite *)site state:(BOOL)state
{
    SEL changeFavoriteStateSelector = sel_registerName("changeFavoriteState:");
    [site performSelector:changeFavoriteStateSelector withObject:@(state)];
}

#pragma clang diagnostic pop

@end
