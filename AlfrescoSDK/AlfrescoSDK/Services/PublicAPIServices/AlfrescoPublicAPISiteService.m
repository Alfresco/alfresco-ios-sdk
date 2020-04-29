/*******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
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
 ******************************************************************************/

#import "AlfrescoPublicAPISiteService.h"
#import "AlfrescoLegacyAPISiteService.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoBasicAuthenticationProvider.h"
#import "AlfrescoErrors.h"
#import "AlfrescoURLUtils.h"
#import "AlfrescoSortingUtils.h"
#import "AlfrescoPagingUtils.h"
#import "AlfrescoDocumentFolderService.h"
#import "AlfrescoLog.h"
#import "AlfrescoProperty.h"
#import <objc/runtime.h>

@interface AlfrescoPublicAPISiteService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, weak, readwrite) id<AlfrescoAuthenticationProvider> authenticationProvider;
@property (nonatomic, strong, readwrite) NSArray *supportedSortKeys;
@property (nonatomic, strong, readwrite) NSString *defaultSortKey;
@property (nonatomic, strong, readwrite) AlfrescoSiteCache *siteCache;
@property (nonatomic, strong, readwrite) AlfrescoFolder *sitesRootFolder;
@end

@implementation AlfrescoPublicAPISiteService

#pragma mark Public service methods

- (id)initWithSession:(id<AlfrescoSession>)session
{
    if (self = [super init])
    {
        self.session = session;
        self.baseApiUrl = [[self.session.baseUrl absoluteString] stringByAppendingString:kAlfrescoPublicAPIPath];
        id authenticationObject = [session objectForParameter:kAlfrescoAuthenticationProviderObjectKey];
        self.authenticationProvider = nil;
        if ([authenticationObject isKindOfClass:[AlfrescoBasicAuthenticationProvider class]])
        {
            self.authenticationProvider = (AlfrescoBasicAuthenticationProvider *)authenticationObject;
        }
        self.defaultSortKey = kAlfrescoSortByTitle;
        self.supportedSortKeys = @[kAlfrescoSortByTitle, kAlfrescoSortByShortname];

        id cachedObj = [self.session objectForParameter:kAlfrescoSessionCacheSites];
        if (cachedObj)
        {
            AlfrescoLogTrace(@"Found an existing SiteCache in session");
            self.siteCache = (AlfrescoSiteCache *)cachedObj;
        }
        else
        {
            self.siteCache = [AlfrescoSiteCache new];
            [self.session setObject:self.siteCache forParameter:kAlfrescoSessionCacheSites];
            AlfrescoLogDebug(@"Created new SiteCache object");
        }
    }
    return self;
}

- (void)clear
{
    [self.siteCache clear];
}

- (AlfrescoRequest *)retrieveAllSitesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:-1];
    return [self retrieveAllSitesWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
        completionBlock(pagingResult.objects, error);
    }];
}

- (AlfrescoRequest *)retrieveAllSitesWithListingContext:(AlfrescoListingContext *)listingContext
                           completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    AlfrescoRequest *request = nil;
    if (!self.siteCache.isCacheBuilt)
    {
        __weak typeof(self) weakSelf = self;
        request = [self.siteCache buildCacheWithDelegate:self completionBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                AlfrescoRequest *fetchRequest = [weakSelf fetchAllSitesWithListingContext:(AlfrescoListingContext *)listingContext completionBlock:completionBlock];
                request.httpRequest = fetchRequest.httpRequest;
            }
            else
            {
                completionBlock(nil, error);
            }
        }];
    }
    else
    {
        request = [self fetchAllSitesWithListingContext:(AlfrescoListingContext *)listingContext completionBlock:completionBlock];
    }
    
    return request;
}

- (AlfrescoRequest *)retrieveSitesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:-1];
    return [self retrieveSitesWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
        completionBlock(pagingResult.objects, error);
    }];
}

- (AlfrescoRequest *)retrieveSitesWithListingContext:(AlfrescoListingContext *)listingContext
                                     completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    AlfrescoRequest *request = nil;
    if (!self.siteCache.isCacheBuilt)
    {
        __weak typeof(self) weakSelf = self;
        request = [self.siteCache buildCacheWithDelegate:self completionBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                NSArray *sortedSites = [AlfrescoSortingUtils sortedArrayForArray:weakSelf.siteCache.memberSites
                                                                         sortKey:weakSelf.defaultSortKey ascending:YES];
                NSArray *filteredSites = [self sitesArrayByApplyingFilter:listingContext.listingFilter sites:sortedSites];
                AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:filteredSites
                                                                                listingContext:listingContext];
                completionBlock(pagingResult, nil);
            }
            else
            {
                completionBlock(nil, error);
            }
        }];
    }
    else
    {
        AlfrescoLogDebug(@"Cache hit: returning my sites from cache");
        NSArray *sortedSites = [AlfrescoSortingUtils sortedArrayForArray:self.siteCache.memberSites
                                                                 sortKey:self.defaultSortKey ascending:YES];
        NSArray *filteredSites = [self sitesArrayByApplyingFilter:listingContext.listingFilter sites:sortedSites];
        AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:filteredSites
                                                                        listingContext:listingContext];
        completionBlock(pagingResult, nil);
    }
    
    return request;
}

- (AlfrescoRequest *)retrieveFavoriteSitesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:-1];
    return [self retrieveFavoriteSitesWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
        completionBlock(pagingResult.objects, error);
    }];
}

- (AlfrescoRequest *)retrieveFavoriteSitesWithListingContext:(AlfrescoListingContext *)listingContext
                                             completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    AlfrescoRequest *request = nil;
    if (!self.siteCache.isCacheBuilt)
    {
        __weak typeof(self) weakSelf = self;
        request = [self.siteCache buildCacheWithDelegate:self completionBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                NSArray *sortedSites = [AlfrescoSortingUtils sortedArrayForArray:weakSelf.siteCache.favoriteSites
                                                                         sortKey:weakSelf.defaultSortKey ascending:YES];
                NSArray *filteredSites = [self sitesArrayByApplyingFilter:listingContext.listingFilter sites:sortedSites];
                AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:filteredSites
                                                                                listingContext:listingContext];
                completionBlock(pagingResult, nil);
            }
            else
            {
                completionBlock(nil, error);
            }
        }];
    }
    else
    {
        AlfrescoLogDebug(@"Cache hit: returning favorite sites from cache");
        NSArray *sortedSites = [AlfrescoSortingUtils sortedArrayForArray:self.siteCache.favoriteSites
                                                                 sortKey:self.defaultSortKey ascending:YES];
        NSArray *filteredSites = [self sitesArrayByApplyingFilter:listingContext.listingFilter sites:sortedSites];
        AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:filteredSites
                                                                        listingContext:listingContext];
        completionBlock(pagingResult, nil);
    }
    
    return request;
}

- (AlfrescoRequest *)retrieveSiteWithShortName:(NSString *)siteShortName
                               completionBlock:(AlfrescoSiteCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:siteShortName argumentName:@"siteShortName"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    AlfrescoRequest *request = nil;
    if (!self.siteCache.isCacheBuilt)
    {
        __weak typeof(self) weakSelf = self;
        request = [self.siteCache buildCacheWithDelegate:self completionBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                // now the cache is built see if we have already retrieved it
                AlfrescoSite *cachedSite = [weakSelf.siteCache siteWithShortName:siteShortName];
                if (cachedSite != nil)
                {
                    completionBlock(cachedSite, nil);
                }
                else
                {
                    // site not cached yet, retrieve it
                    AlfrescoRequest *retrieveRequest = [weakSelf retrieveDataForSiteWithShortName:siteShortName completionBlock:^(AlfrescoSite *site, NSError *error) {
                        if (site != nil)
                        {
                            // cache the retrieved site
                            [weakSelf.siteCache cacheSite:site];
                            completionBlock(site, nil);
                        }
                        else
                        {
                            completionBlock(nil, error);
                        }
                    }];
                    
                    request.httpRequest = retrieveRequest.httpRequest;
                }
            }
            else
            {
                completionBlock(nil, error);
            }
        }];
    }
    else
    {
        // see if the site is already in the cache
        AlfrescoSite *cachedSite = [self.siteCache siteWithShortName:siteShortName];
        if (cachedSite != nil)
        {
            completionBlock(cachedSite, nil);
        }
        else
        {
            // site not cached yet, retrieve it
            __weak typeof(self) weakSelf = self;
            request = [self retrieveDataForSiteWithShortName:siteShortName completionBlock:^(AlfrescoSite *site, NSError *error) {
                if (site != nil)
                {
                    // cache the retrieved site
                    [weakSelf.siteCache cacheSite:site];
                    completionBlock(site, nil);
                }
                else
                {
                    completionBlock(nil, error);
                }
            }];
        }
    }
    
    return request;
}

- (AlfrescoRequest *)retrieveDocumentLibraryFolderForSite:(NSString *)siteShortName
                                          completionBlock:(AlfrescoFolderCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:siteShortName argumentName:@"siteShortName"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *requestString = [kAlfrescoPublicAPISiteContainers stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:siteShortName];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    __weak typeof(self) weakSelf = self;
    [self.session.networkProvider executeRequestWithURL:url
                                                session:self.session
                                        alfrescoRequest:request
                                        completionBlock:^(NSData *data, NSError *error){
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSDictionary *folderDict = [weakSelf dictionaryFromJSONData:data error:&conversionError];
            if (nil == folderDict)
            {
                completionBlock(nil, error);
            }
            else
            {
                id folderObj = [folderDict valueForKey:kAlfrescoJSONIdentifier];
                NSString *folderId = nil;
                if ([folderObj isKindOfClass:[NSString class]])
                {
                    folderId = [folderDict valueForKey:kAlfrescoJSONIdentifier];
                }
                else if([folderObj isKindOfClass:[NSDictionary class]])
                {
                    NSDictionary *folderIdDict = (NSDictionary *)folderObj;
                    folderId = [folderIdDict valueForKey:kAlfrescoJSONIdentifier];
                }
                
                if (nil == folderId)
                {
                    completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing]);
                }
                else
                {
                    AlfrescoDocumentFolderService *docService = [[AlfrescoDocumentFolderService alloc] initWithSession:weakSelf.session];
                    AlfrescoRequest *retrieveRequest = [docService retrieveNodeWithIdentifier:folderId completionBlock:^(AlfrescoNode *node, NSError *nodeError){
                        if (nil == node)
                        {
                            completionBlock(nil, nodeError);
                        }
                        else
                        {
                            completionBlock((AlfrescoFolder *)node, nil);
                        }
                    }];
                    
                    request.httpRequest = retrieveRequest.httpRequest;
                }
                
            }
            
        }
    }];
    
    return request;
}

- (AlfrescoRequest *)retrievePendingSitesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:-1];
    
    return [self retrievePendingSitesWithListingContext:listingContext completionblock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
        completionBlock(pagingResult.objects, error);
    }];
}

- (AlfrescoRequest *)retrievePendingSitesWithListingContext:(AlfrescoListingContext *)listingContext completionblock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    AlfrescoRequest *request = nil;
    if (!self.siteCache.isCacheBuilt)
    {
        __weak typeof(self) weakSelf = self;
        request = [self.siteCache buildCacheWithDelegate:self completionBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                NSArray *sortedSites = [AlfrescoSortingUtils sortedArrayForArray:weakSelf.siteCache.pendingSites
                                                                         sortKey:weakSelf.defaultSortKey ascending:YES];
                AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedSites
                                                                                listingContext:listingContext];
                completionBlock(pagingResult, nil);
            }
            else
            {
                completionBlock(nil, error);
            }
        }];
    }
    else
    {
        AlfrescoLogDebug(@"Cache hit: returning pending sites from cache");
        NSArray *sortedSites = [AlfrescoSortingUtils sortedArrayForArray:self.siteCache.pendingSites
                                                                 sortKey:self.defaultSortKey ascending:YES];
        AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedSites
                                                                        listingContext:listingContext];
        completionBlock(pagingResult, nil);
    }
    
    return request;
}


- (AlfrescoRequest *)addFavoriteSite:(AlfrescoSite *)site
                     completionBlock:(AlfrescoSiteCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:site argumentName:@"site"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoPublicAPIAddFavoriteSite];
    NSData *jsonData = [self jsonDataForAddingFavoriteSite:site.GUID];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    __weak typeof(self) weakSelf = self;
    [self.session.networkProvider executeRequestWithURL:url
                                                session:self.session
                                            requestBody:jsonData
                                                 method:kAlfrescoHTTPPost
                                        alfrescoRequest:request
                                        completionBlock:^(NSData *data, NSError *error){
                                            if (nil == data)
                                            {
                                                completionBlock(nil, error);
                                            }
                                            else
                                            {
                                                // update the state of the site
                                                [weakSelf.siteCache cacheSite:site member:site.isMember pending:site.isPendingMember favorite:YES];
                                                completionBlock(site, error);
                                            }
                                        }];
    
    return request;
}

- (AlfrescoRequest *)removeFavoriteSite:(AlfrescoSite *)site
                        completionBlock:(AlfrescoSiteCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:site argumentName:@"site"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    NSString *requestString = [kAlfrescoPublicAPIRemoveFavoriteSite stringByReplacingOccurrencesOfString:kAlfrescoSiteGUID
                                                                                             withString:site.GUID];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    __weak typeof(self) weakSelf = self;
    [self.session.networkProvider executeRequestWithURL:url
                                                session:self.session
                                            requestBody:nil
                                                 method:kAlfrescoHTTPDelete
                                        alfrescoRequest:request
                                        completionBlock:^(NSData *data, NSError *error){
                                            if (nil == data)
                                            {
                                                completionBlock(nil, error);
                                            }
                                            else
                                            {
                                                // update the state of the site
                                                [weakSelf.siteCache cacheSite:site member:site.isMember pending:site.isPendingMember favorite:NO];
                                                completionBlock(site, error);
                                            }
                                        }];
    
    return request;
}

- (AlfrescoRequest *)joinSite:(AlfrescoSite *)site
              completionBlock:(AlfrescoSiteCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:site argumentName:@"site"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoPublicAPIJoinSite];
    NSData *jsonData = [self jsonDataForJoiningSite:site.identifier comment:@""];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    __weak typeof(self) weakSelf = self;
    [self.session.networkProvider executeRequestWithURL:url
                                                session:self.session
                                            requestBody:jsonData
                                                 method:kAlfrescoHTTPPost
                                        alfrescoRequest:request
                                        completionBlock:^(NSData *data, NSError *error){
                                            if (nil == data)
                                            {
                                                completionBlock(nil, error);
                                            }
                                            else
                                            {
                                                NSError *jsonError = nil;
                                                AlfrescoSite *requestedSite = [weakSelf singleJoinRequestSiteFromJSONData:data error:&jsonError];
                                                if (requestedSite)
                                                {
                                                    if (requestedSite.visibility == AlfrescoSiteVisibilityPublic)
                                                    {
                                                        // update the state of the site
                                                        [weakSelf.siteCache cacheSite:site member:YES pending:NO favorite:site.isFavorite];
                                                        completionBlock(site, nil);
                                                    }
                                                    else
                                                    {
                                                        // update the state of the site
                                                        [weakSelf.siteCache cacheSite:site member:NO pending:YES favorite:site.isFavorite];
                                                        completionBlock(site, nil);
                                                    }
                                                }
                                                else
                                                {
                                                    completionBlock(nil, jsonError);
                                                }
                                            }
                                        }];
    
    return request;
}


- (AlfrescoRequest *)cancelPendingJoinRequestForSite:(AlfrescoSite *)site
                                     completionBlock:(AlfrescoSiteCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:site argumentName:@"site"];
    [AlfrescoErrors assertArgumentNotNil:site.identifier argumentName:@"site.identifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    NSString *requestString = [kAlfrescoPublicAPICancelJoinRequests stringByReplacingOccurrencesOfString:kAlfrescoSiteId
                                                                                             withString:site.identifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    __weak typeof(self) weakSelf = self;
    [self.session.networkProvider executeRequestWithURL:url
                                                session:self.session
                                            requestBody:nil
                                                 method:kAlfrescoHTTPDelete
                                        alfrescoRequest:request
                                        completionBlock:^(NSData *data, NSError *error){
                                            if (nil == data)
                                            {
                                                completionBlock(nil, error);
                                            }
                                            else
                                            {
                                                // update the state of the site
                                                [weakSelf.siteCache cacheSite:site member:NO pending:NO favorite:site.isFavorite];
                                                completionBlock(site, error);
                                            }
                                        }];
    
    return request;
}

- (AlfrescoRequest *)leaveSite:(AlfrescoSite *)site
               completionBlock:(AlfrescoSiteCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:site argumentName:@"site"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    NSString *requestString = [kAlfrescoPublicAPILeaveSite stringByReplacingOccurrencesOfString:kAlfrescoSiteId
                                                                                    withString:site.identifier];
    requestString = [requestString stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    __weak typeof(self) weakSelf = self;
    [self.session.networkProvider executeRequestWithURL:url
                                                session:self.session
                                            requestBody:nil
                                                 method:kAlfrescoHTTPDelete
                                        alfrescoRequest:request
                                        completionBlock:^(NSData *data, NSError *error){
                                            if (nil == data)
                                            {
                                                completionBlock(nil, error);
                                            }
                                            else
                                            {
                                                // update the state of the site
                                                [weakSelf.siteCache cacheSite:site member:NO pending:NO favorite:site.isFavorite];
                                                completionBlock(site, error);
                                            }
                                        }];
    
    return request;
}

- (AlfrescoRequest *)retrieveAllMembersOfSite:(AlfrescoSite *)site
                              completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:-1];
    return [self retrieveAllMembersOfSite:site listingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
        completionBlock(pagingResult.objects, error);
    }];
}

- (AlfrescoRequest *)retrieveAllMembersOfSite:(AlfrescoSite *)site
                               listingContext:(AlfrescoListingContext *)listingContext
                              completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:site argumentName:@"site"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    NSString *requestString = [kAlfrescoPublicAPISiteMembers stringByReplacingOccurrencesOfString:kAlfrescoSiteId
                                                                                      withString:site.identifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString listingContext:listingContext];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    __weak typeof(self) weakSelf = self;
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *members = [weakSelf membersArrayWithData:data error:&conversionError];
            if (conversionError == nil)
            {
                NSDictionary *pagingInfo = [AlfrescoObjectConverter paginationJSONFromData:data error:&conversionError];
                AlfrescoPagingResult *pagingResult = nil;
                if (members && pagingInfo)
                {
                    BOOL hasMore = [[pagingInfo valueForKeyPath:kAlfrescoPublicAPIJSONHasMoreItems] boolValue];
                    // PublicAPI does not currently return totalItems for this API request
                    pagingResult = [[AlfrescoPagingResult alloc] initWithArray:members hasMoreItems:hasMore totalItems:-1];
                }
                completionBlock(pagingResult, nil);
            }
            else
            {
                completionBlock(nil, conversionError);
            }
            
        }
    }];
    return request;
}

- (AlfrescoRequest *)searchMembersOfSite:(AlfrescoSite *)site
                                keywords:(NSString *)keywords
                          listingContext:(AlfrescoListingContext *)listingContext
                         completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:site argumentName:@"site"];
    [AlfrescoErrors assertArgumentNotNil:keywords argumentName:@"keywords"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    // NOTE: we request all members here as the cloud does not support filtering, yet!
    NSString *requestString = [kAlfrescoPublicAPISiteMembers stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:site.identifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString listingContext:nil];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    __weak typeof(self) weakSelf = self;
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *members = [weakSelf membersArrayWithData:data error:&conversionError];
            if (conversionError == nil)
            {
                // do manual filtering of users until the Cloud supports it
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(identifier contains[cd] %@) OR (fullName contains [cd] %@)", keywords, keywords];
                NSArray *filteredMembers = [members filteredArrayUsingPredicate:predicate];
                
                // apply paging
                AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:filteredMembers listingContext:listingContext];
                completionBlock(pagingResult, error);
            }
            else
            {
                completionBlock(nil, conversionError);
            }
        }
    }];
    
    return request;
}

- (AlfrescoRequest *)isPerson:(AlfrescoPerson *)person
                 memberOfSite:(AlfrescoSite *)site
              completionBlock:(AlfrescoMemberCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:person argumentName:@"person"];
    [AlfrescoErrors assertArgumentNotNil:site argumentName:@"site"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *requestString = [kAlfrescoPublicAPILeaveSite stringByReplacingOccurrencesOfString:kAlfrescoSiteId
                                                                                    withString:site.identifier];
    requestString = [requestString stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:person.identifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session requestBody:nil method:kAlfrescoHTTPGet alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        
        // if person is not member : the request returns error and data is nil so its difficult to differenciate if request failed or person is not member
        if (error)
        {
            completionBlock(YES, NO, nil);
        }
        else
        {
            completionBlock(YES, YES, nil);
        }
    }];
    
    return request;
}

#pragma mark Data parsing methods

- (AlfrescoSite *)singleJoinRequestSiteFromJSONData:(NSData *)data error:(NSError **)outError
{
    if (nil == data)
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        }
        else
        {
            NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
            *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        }
        return nil;
    }
    NSError *error = nil;
    id jsonRequestObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if(error)
    {
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeSites];
        return nil;
    }
    if (![jsonRequestObj isKindOfClass:[NSDictionary class]])
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeSitesNoSites];
        }
        else
        {
            NSError *underlyingError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeSitesNoSites];
            *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:underlyingError andAlfrescoErrorCode:kAlfrescoErrorCodeSitesNoSites];
        }
        return nil;
    }
    NSDictionary *jsonDict = (NSDictionary *)jsonRequestObj;
    if (![[jsonDict allKeys] containsObject:kAlfrescoPublicAPIJSONEntry])
    {
        NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        return nil;
    }
    AlfrescoSite *requestedSite = nil;
    id dataObj = jsonDict[kAlfrescoPublicAPIJSONEntry];
    if (![dataObj isKindOfClass:[NSDictionary class]])
    {
        NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        return nil;
    }
    else
    {
        NSDictionary *entryDict = (NSDictionary *)dataObj;
        id siteObj = entryDict[kAlfrescoJSONSite];
        if (nil == siteObj)
        {
            NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
            *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
            return nil;
        }
        else if (![siteObj isKindOfClass:[NSDictionary class]])
        {
            NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
            *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
            return nil;
        }
        else
        {
            requestedSite = [[AlfrescoSite alloc] initWithProperties:(NSDictionary *)siteObj];
        }
        
    }
    return requestedSite;
}

- (NSArray *)joinRequestSitesArrayFromJSONData:(NSData *)data error:(NSError **)outError
{
    NSArray *entriesArray = [AlfrescoObjectConverter arrayJSONEntriesFromListData:data error:outError];
    if (nil == entriesArray)
    {
        return nil;
    }
    NSDictionary *individualSiteEntry = nil;
    NSMutableArray *requestedSites = [NSMutableArray array];
    for (NSDictionary *entryDict in entriesArray)
    {
        individualSiteEntry = [entryDict valueForKey:kAlfrescoPublicAPIJSONEntry];
        if (nil != individualSiteEntry)
        {
            id siteObj = individualSiteEntry[kAlfrescoJSONSite];
            if ([siteObj isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *siteProperties = (NSDictionary *)siteObj;
                AlfrescoSite *site = [[AlfrescoSite alloc] initWithProperties:siteProperties];
                [requestedSites addObject:site];
            }
        }
        else
        {
            if (nil == *outError)
            {
                *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
            }
            else
            {
                NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
                *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeSites];
            }
            return nil;
        }
        
    }
    return requestedSites;
}

- (NSArray *)siteArrayWithData:(NSData *)data error:(NSError **)outError
{
    NSArray *entriesArray = [AlfrescoObjectConverter arrayJSONEntriesFromListData:data error:outError];
    if (nil != entriesArray)
    {
        NSMutableArray *resultsArray = [NSMutableArray arrayWithCapacity:entriesArray.count];
        
        for (NSDictionary *entryDict in entriesArray)
        {
            NSMutableDictionary *individualEntry = [NSMutableDictionary dictionaryWithDictionary:[entryDict valueForKey:kAlfrescoPublicAPIJSONEntry]];
            AlfrescoSite *site = [[AlfrescoSite alloc] initWithProperties:individualEntry];
            [resultsArray addObject:site];
        }
        return resultsArray;
    }
    else
        return nil;
}

- (AlfrescoSite *)siteFromJSONData:(NSData *)data error:(NSError **)outError
{
    NSDictionary *entryDictionary = [AlfrescoObjectConverter dictionaryJSONEntryFromListData:data error:outError];
    return [[AlfrescoSite alloc] initWithProperties:entryDictionary];
}

- (AlfrescoSite *)siteFromFolder:(AlfrescoFolder *)folder
{
    // construct a properties object representing the site to create
    NSMutableDictionary *siteProperties = [NSMutableDictionary dictionaryWithCapacity:8];
    siteProperties[kAlfrescoJSONShortname] = folder.name;
    siteProperties[kAlfrescoJSONGUID] = folder.identifier;
    
    if (folder.summary != nil)
    {
        siteProperties[kAlfrescoJSONDescription] = folder.summary;
    }
    
    if (folder.title != nil)
    {
        siteProperties[kAlfrescoJSONTitle] = folder.title;
    }
    
    AlfrescoProperty *visibilityProperty = (folder.properties)[@"st:siteVisibility"];
    if (visibilityProperty != nil)
    {
        siteProperties[kAlfrescoJSONVisibility] = visibilityProperty.value;
    }
    
    // return a newly created site node
    return [[AlfrescoSite alloc] initWithProperties:siteProperties];
}

- (NSArray *)membersArrayWithData:(NSData *)data error:(NSError **)outError
{
    NSArray *entriesArray = [AlfrescoObjectConverter arrayJSONEntriesFromListData:data error:outError];
    if (nil != entriesArray)
    {
        NSMutableArray *resultsArray = [NSMutableArray arrayWithCapacity:entriesArray.count];
        
        for (NSDictionary *entry in entriesArray)
        {
            NSDictionary *entryProperties = [entry valueForKey:kAlfrescoPublicAPIJSONEntry];
            NSMutableDictionary *memberProperties = [NSMutableDictionary dictionaryWithDictionary:[entryProperties valueForKey:kAlfrescoJSONPerson]];
            
            AlfrescoCompany *company = [[AlfrescoCompany alloc] initWithProperties:memberProperties[kAlfrescoJSONCompany]];
            [memberProperties setValue:company forKey:kAlfrescoJSONCompany];
            AlfrescoPerson *person = [[AlfrescoPerson alloc] initWithProperties:memberProperties];
            [resultsArray addObject:person];
        }
        return resultsArray;
    }
    return nil;
}

- (NSArray *) specifiedSiteArrayFromJSONData:(NSData *)data error:(NSError **)outError
{
    NSArray *entriesArray = [AlfrescoObjectConverter arrayJSONEntriesFromListData:data error:outError];
    if (nil != entriesArray)
    {
        NSMutableArray *resultsArray = [NSMutableArray arrayWithCapacity:entriesArray.count];
        
        for (NSDictionary *entryDict in entriesArray)
        {
            NSDictionary *individualEntry = [entryDict valueForKey:kAlfrescoPublicAPIJSONEntry];
            id siteObj = [individualEntry valueForKey:kAlfrescoJSONSite];
            if (nil == siteObj)
            {
                if (nil == *outError)
                {
                    *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
                }
                else
                {
                    NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
                    *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
                    
                }
                return nil;
            }
            else
            {
                if (![siteObj isKindOfClass:[NSDictionary class]])
                {
                    if (nil == *outError)
                    {
                        *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
                    }
                    else
                    {
                        NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
                        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
                        
                    }
                    return nil;
                }
                else
                {
                    AlfrescoSite *site = [[AlfrescoSite alloc] initWithProperties:(NSDictionary *)siteObj];
                    [resultsArray addObject:site];
                }
                
            }
        }
        return resultsArray;
    }
    else
        return nil;
}

- (NSDictionary *)dictionaryFromJSONData:(NSData *)data error:(NSError **)outError
{
    NSArray *entriesArray = [AlfrescoObjectConverter arrayJSONEntriesFromListData:data error:outError];
    if (nil == entriesArray)
    {
        return nil;
    }
    NSDictionary *individualFolderEntry = nil;
    for (NSDictionary *entryDict in entriesArray)
    {
        individualFolderEntry = [entryDict valueForKey:kAlfrescoPublicAPIJSONEntry];
        if (nil != individualFolderEntry)
        {
            NSString *folderId = [individualFolderEntry valueForKey:@"folderId"];
            if (nil != folderId)
            {
                if ([folderId hasPrefix:kAlfrescoDocumentLibrary])
                {
                    return individualFolderEntry;
                }
            }
        }
        
    }
    if (nil == *outError)
    {
        *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
    }
    else
    {
        NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeSites];
    }
    return nil;
}


- (NSData *)jsonDataForAddingFavoriteSite:(NSString *)siteGUID
{
    NSDictionary *siteId = @{kAlfrescoJSONGUID: siteGUID};
    NSDictionary *site = @{kAlfrescoJSONSite: siteId};
    NSDictionary *jsonDict = @{kAlfrescoJSONTarget: site};
    NSError *error = nil;
    return [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
}

- (NSData *)jsonDataForJoiningSite:(NSString *)site comment:(NSString *)comment
{
    NSDictionary *jsonDict =  @{kAlfrescoJSONIdentifier: site, kAlfrescoJSONMessage: comment};
    NSError *error = nil;
    return [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
}


#pragma mark AlfrescoSiteCacheDataDelegate methods

- (AlfrescoRequest *)retrieveMemberSiteDataWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    AlfrescoRequest *alfrescoRequest = [[AlfrescoRequest alloc] init];
    __weak typeof(self) weakSelf = self;
    
    NSString *mySitesRequestString = [kAlfrescoPublicAPISiteForPerson stringByReplacingOccurrencesOfString:kAlfrescoPersonId
                                                                                               withString:self.session.personIdentifier];
    NSURL *memberApi = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:mySitesRequestString];
    [self.session.networkProvider executeRequestWithURL:memberApi session:self.session
                                        alfrescoRequest:alfrescoRequest completionBlock:^(NSData *data, NSError *error){
        if (data != nil)
        {
            NSError *conversionError = nil;
            NSArray *memberSiteData = [weakSelf specifiedSiteArrayFromJSONData:data error:&conversionError];
            completionBlock(memberSiteData, conversionError);
        }
        else
        {
            completionBlock(nil, error);
        }
    }];
    
    return alfrescoRequest;
}

- (AlfrescoRequest *)retrieveFavoriteSiteDataWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    AlfrescoRequest *alfrescoRequest = [[AlfrescoRequest alloc] init];
    __weak typeof(self) weakSelf = self;
    
    NSString *favSitesRequestString = [kAlfrescoPublicAPIFavoriteSiteForPerson stringByReplacingOccurrencesOfString:kAlfrescoPersonId
                                                                                                        withString:self.session.personIdentifier];
    NSURL *favApi = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:favSitesRequestString];
    [self.session.networkProvider executeRequestWithURL:favApi session:self.session
                                        alfrescoRequest:alfrescoRequest completionBlock:^(NSData *data, NSError *error){
        if (data != nil)
        {
            NSError *conversionError = nil;
            NSArray *favoriteSiteData = [weakSelf siteArrayWithData:data error:&conversionError];
            completionBlock(favoriteSiteData, conversionError);
        }
        else
        {
            completionBlock(nil, error);
        }
    }];
    
    return alfrescoRequest;
}

- (AlfrescoRequest *)retrievePendingSiteDataWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    AlfrescoRequest *alfrescoRequest = [[AlfrescoRequest alloc] init];
    __weak typeof(self) weakSelf = self;
    
    NSString *pendingRequestString = kAlfrescoPublicAPIJoinSite;
    NSURL *pendingApi = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:pendingRequestString];
    [self.session.networkProvider executeRequestWithURL:pendingApi session:self.session
                                        alfrescoRequest:alfrescoRequest completionBlock:^(NSData *data, NSError *error){
        if (data != nil)
        {
            NSError *conversionError = nil;
            NSArray *pendingSiteData = [weakSelf joinRequestSitesArrayFromJSONData:data error:&conversionError];
            completionBlock(pendingSiteData, conversionError);
        }
        else
        {
            completionBlock(nil, error);
        }
    }];
    
    return alfrescoRequest;
}

- (AlfrescoRequest *)retrieveDataForSiteWithShortName:(NSString *)shortName completionBlock:(AlfrescoSiteCompletionBlock)completionBlock
{
    AlfrescoRequest *alfrescoRequest = [[AlfrescoRequest alloc] init];
    __weak typeof(self) weakSelf = self;
    
    NSString *requestString = [kAlfrescoPublicAPISiteForShortname stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:shortName];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];

    [self.session.networkProvider executeRequestWithURL:url
                                                session:self.session
                                        alfrescoRequest:alfrescoRequest completionBlock:^(NSData *data, NSError *error){
        if (data != nil)
        {
            NSError *conversionError = nil;
            AlfrescoSite *site = [weakSelf siteFromJSONData:data error:&conversionError];
            completionBlock(site, conversionError);
        }
        else
        {
            completionBlock(nil, error);
        }
    }];
    
    return alfrescoRequest;
}

- (AlfrescoRequest *)searchWithKeywords:(NSString *)keywords completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    // Not supported with PublicAPI - defer to OnPremise APIs
    AlfrescoLegacyAPISiteService *legacyAPI = [[AlfrescoLegacyAPISiteService alloc] initWithSession:self.session];
    return [legacyAPI searchWithKeywords:keywords completionBlock:completionBlock];
}

- (AlfrescoRequest *)searchWithKeywords:(NSString *)keywords
                         listingContext:(AlfrescoListingContext *)listingContext
                        completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    // Not supported with PublicAPI - defer to OnPremise APIs
    AlfrescoLegacyAPISiteService *legacyAPI = [[AlfrescoLegacyAPISiteService alloc] initWithSession:self.session];
    return [legacyAPI searchWithKeywords:keywords listingContext:listingContext completionBlock:completionBlock];
}

#pragma mark Internal private methods

// NOTE: Ideally these methods should be in a common base class as it is identical to the implementation in AlfrescoLegacySiteService.m

- (AlfrescoRequest *)fetchAllSitesWithListingContext:(AlfrescoListingContext *)listingContext
                                     completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    AlfrescoRequest *request = nil;
    __weak typeof(self) weakSelf = self;
    
    // define completion block to fetch the sites
    AlfrescoRequest * (^fetchSites)(AlfrescoFolder *sitesFolder) = ^AlfrescoRequest * (AlfrescoFolder *sitesFolder) {
        
        AlfrescoRequest *childRequest = nil;
        
        // If we have the paging request result already cached, we simply return it. Else, send a request to retrieve them.
        if ([self.siteCache shouldUseAllSitesCacheForListingContext:listingContext] || self.siteCache.hasAllSites)
        {
            AlfrescoLogDebug(@"Cache hit: returning all sites from cache");
            
            NSArray *sites = [self.siteCache cachedAllSitesForListingContext:listingContext];
            
            // filter sites
            NSArray *filteredSites = [self sitesArrayByApplyingFilter:listingContext.listingFilter sites:sites];
            
            // call the completion
            completionBlock([[AlfrescoPagingResult alloc] initWithArray:filteredSites
                                                           hasMoreItems:!self.siteCache.hasAllSites
                                                             totalItems:self.siteCache.totalSiteCount], nil);
        }
        else
        {
            AlfrescoDocumentFolderService *docFolderSvc = [[AlfrescoDocumentFolderService alloc] initWithSession:weakSelf.session];
            childRequest = [docFolderSvc retrieveChildrenInFolder:sitesFolder listingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
                if (pagingResult != nil)
                {
                    NSArray *children = pagingResult.objects;
                    NSMutableArray *sites = [NSMutableArray array];
                    __block AlfrescoSite *site = nil;
                    
                    [children enumerateObjectsUsingBlock:^(AlfrescoNode *node, NSUInteger idx, BOOL *stop) {
                        if (node.isFolder && [node.type isEqualToString:@"st:site"])
                        {
                            site = [weakSelf.siteCache siteWithShortName:node.name];
                            if (site == nil)
                            {
                                site = [weakSelf siteFromFolder:(AlfrescoFolder *)node];
                            }
                            [sites addObject:site];
                            [weakSelf.siteCache cacheSiteToAllSites:site atIndex:(idx + listingContext.skipCount) totalSites:pagingResult.totalItems];
                        }
                    }];
                    
                    // filter sites
                    NSArray *filteredSites = [self sitesArrayByApplyingFilter:listingContext.listingFilter sites:sites];
                    
                    // call the completion
                    completionBlock([[AlfrescoPagingResult alloc] initWithArray:filteredSites
                                                                   hasMoreItems:pagingResult.hasMoreItems
                                                                     totalItems:pagingResult.totalItems], nil);
                }
                else
                {
                    completionBlock(nil, error);
                }
            }];
        }
        
        return childRequest;
    };
    
    if (self.sitesRootFolder == nil)
    {
        // fetch the "Sites" root folder
        request = [self fetchSitesRootFolderWithCompletionBlock:^(AlfrescoFolder *sitesFolder, NSError *error) {
            if (sitesFolder != nil)
            {
                AlfrescoRequest *fetchRequest = fetchSites(sitesFolder);
                request.httpRequest = fetchRequest.httpRequest;
            }
            else
            {
                completionBlock(nil, error);
            }
        }];
    }
    else
    {
        request = fetchSites(self.sitesRootFolder);
    }
    
    return request;
}

- (AlfrescoRequest *)fetchSitesRootFolderWithCompletionBlock:(AlfrescoFolderCompletionBlock)completionBlock
{
    AlfrescoRequest *request = nil;
    AlfrescoDocumentFolderService *docFolderSvc = [[AlfrescoDocumentFolderService alloc] initWithSession:self.session];
    __weak typeof(self) weakSelf = self;
    
    request = [docFolderSvc retrieveChildrenInFolder:self.session.rootFolder completionBlock:^(NSArray *children, NSError *error) {
        if (children != nil)
        {
            // iterate round the results until we find the folder with a type of "st:sites"
            for (AlfrescoNode *node in children)
            {
                if (node.isFolder && [node.type isEqualToString:@"st:sites"])
                {
                    weakSelf.sitesRootFolder = (AlfrescoFolder *)node;
                    completionBlock(weakSelf.sitesRootFolder, nil);
                    break;
                }
            }
            
            // if we get here and the sitesRootFolder is not set send error
            if (weakSelf.sitesRootFolder == nil)
            {
                completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeSites]);
            }
        }
        else
        {
            completionBlock(nil, error);
        }
    }];
    
    return request;
}

- (NSArray *)sitesArrayByApplyingFilter:(AlfrescoListingFilter *)filter sites:(NSArray *)sites
{
    NSArray *filteredSites = sites;
    
    if (filter && [filter hasFilter:kAlfrescoFilterBySiteVisibility])
    {
        NSPredicate *siteVisibilityPredicate = nil;
        NSString *filterValue = [filter valueForFilter:kAlfrescoFilterBySiteVisibility];
        if ([filterValue isEqualToString:kAlfrescoFilterValueSiteVisibilityPublic])
        {
            siteVisibilityPredicate = [NSPredicate predicateWithFormat:@"visibility == %d", AlfrescoSiteVisibilityPublic];
        }
        else if ([filterValue isEqualToString:kAlfrescoFilterValueSiteVisibilityPrivate])
        {
            siteVisibilityPredicate = [NSPredicate predicateWithFormat:@"visibility == %d", AlfrescoSiteVisibilityPrivate];
        }
        else if ([filterValue isEqualToString:kAlfrescoFilterValueSiteVisibilityModerated])
        {
            siteVisibilityPredicate = [NSPredicate predicateWithFormat:@"visibility == %d", AlfrescoSiteVisibilityModerated];
        }
     
        if (siteVisibilityPredicate)
        {
            filteredSites = [sites filteredArrayUsingPredicate:siteVisibilityPredicate];
        }
    }
    
    return filteredSites;
}

@end
