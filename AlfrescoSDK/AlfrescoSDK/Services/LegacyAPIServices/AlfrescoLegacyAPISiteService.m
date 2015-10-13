/*******************************************************************************
 * Copyright (C) 2005-2014 Alfresco Software Limited.
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

#import "AlfrescoLegacyAPISiteService.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoCMISToAlfrescoObjectConverter.h"
#import "AlfrescoURLUtils.h"
#import "AlfrescoPagingUtils.h"
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoBasicAuthenticationProvider.h"
#import "AlfrescoDocumentFolderService.h"
#import "AlfrescoSortingUtils.h"
#import "AlfrescoLog.h"
#import "AlfrescoLegacyAPIJoinSiteRequest.h"
#import "AlfrescoProperty.h"

#define TIMEOUTINTERVAL 120

@interface AlfrescoLegacyAPISiteService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, strong, readwrite) AlfrescoCMISToAlfrescoObjectConverter *objectConverter;
@property (nonatomic, weak, readwrite) id<AlfrescoAuthenticationProvider> authenticationProvider;
@property (nonatomic, strong, readwrite) NSArray *supportedSortKeys;
@property (nonatomic, strong, readwrite) NSString *defaultSortKey;
@property (nonatomic, strong, readwrite) AlfrescoSiteCache *siteCache;
@property (nonatomic, strong, readwrite) NSMutableArray *joinRequests;
@property (nonatomic, strong, readwrite) AlfrescoFolder *sitesRootFolder;
@end

@implementation AlfrescoLegacyAPISiteService

#pragma mark Public service methods

- (id)initWithSession:(id<AlfrescoSession>)session
{
    if (self = [super init])
    {
        self.session = session;
        self.baseApiUrl = [[self.session.baseUrl absoluteString] stringByAppendingString:kAlfrescoLegacyAPIPath];
        self.objectConverter = [[AlfrescoCMISToAlfrescoObjectConverter alloc] initWithSession:self.session];
        id authenticationObject = [session objectForParameter:kAlfrescoAuthenticationProviderObjectKey];
        self.authenticationProvider = nil;
        if ([authenticationObject isKindOfClass:[AlfrescoBasicAuthenticationProvider class]])
        {
            self.authenticationProvider = (AlfrescoBasicAuthenticationProvider *)authenticationObject;
        }
        self.defaultSortKey = kAlfrescoSortByTitle;
        self.supportedSortKeys = @[kAlfrescoSortByTitle, kAlfrescoSortByShortname];
        self.joinRequests = [NSMutableArray array];

        id cachedObj = [self.session objectForParameter:kAlfrescoSessionCacheSites];
        if (cachedObj)
        {
            AlfrescoLogDebug(@"Found an existing SiteCache in session");
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
    
    __block AlfrescoDocumentFolderService *docService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.session];
    NSString *requestString = [kAlfrescoLegacySiteDoclibAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:siteShortName];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:[self.session.baseUrl absoluteString] extensionURL:requestString];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error){
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSString *folderId = nil;
            NSError *conversionError = nil;
            id jsonContainer = [NSJSONSerialization JSONObjectWithData:data options:0 error:&conversionError];
            if (nil != jsonContainer)
            {
                NSArray *containerArray = [jsonContainer valueForKey:kAlfrescoJSONContainers];
                if ( nil != containerArray && containerArray.count > 0)
                {
                    folderId = [containerArray[0] valueForKey:kAlfrescoJSONNodeRef];
                }
                if (nil != folderId)
                {
                    AlfrescoRequest *retrieveRequest = [docService retrieveNodeWithIdentifier:folderId completionBlock:^(AlfrescoNode *node, NSError *nodeError){
                        completionBlock((AlfrescoFolder *)node, nodeError);
                        docService = nil;
                    }];
                    
                    request.httpRequest = retrieveRequest.httpRequest;
                }
                else
                {
                    completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData]);
                }
            }
            else
            {
                completionBlock(nil, conversionError);
            }
            
        }
    }];
    return request;
}


- (AlfrescoRequest *)addFavoriteSite:(AlfrescoSite *)site
                     completionBlock:(AlfrescoSiteCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:site argumentName:@"site"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    NSString *requestString = [kAlfrescoLegacyPreferencesAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId
                                                                                                      withString:self.session.personIdentifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    NSData *jsonData = [self jsonDataForFavoriteSites:site.shortName addFavorite:YES];
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
    
    NSString *requestString = [kAlfrescoLegacyPreferencesAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId
                                                                                                      withString:self.session.personIdentifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    NSData *jsonData = [self jsonDataForFavoriteSites:site.shortName addFavorite:NO];
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
    if (site.visibility == AlfrescoSiteVisibilityPublic)
    {
        return [self joinPublicSite:site completionBlock:completionBlock];
    }
    else if (site.visibility == AlfrescoSiteVisibilityModerated)
    {
        return [self joinModeratedSite:site completionBlock:completionBlock];
    }
    else
    {
        NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeSites];
        completionBlock(nil, error);
        return nil;
    }
    
}

- (AlfrescoRequest *)retrievePendingSitesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:-1];
    
    return [self retrievePendingSitesWithListingContext:listingContext completionblock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
        completionBlock(pagingResult.objects, error);
    }];
}

- (AlfrescoRequest *)retrievePendingSitesWithListingContext:(AlfrescoListingContext *)listingContext
                                            completionblock:(AlfrescoPagingResultCompletionBlock)completionBlock
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


- (AlfrescoRequest *)cancelPendingJoinRequestForSite:(AlfrescoSite *)site
                                     completionBlock:(AlfrescoSiteCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:site argumentName:@"site"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSPredicate *joinPredicate = [NSPredicate predicateWithFormat:@"shortName == %@", site.identifier];
    NSArray *foundRequests = [self.joinRequests filteredArrayUsingPredicate:joinPredicate];
    if (0 == foundRequests.count)
    {
        NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeSitesNoSites];
        completionBlock(nil, error);
        return nil;
    }
    __block AlfrescoLegacyAPIJoinSiteRequest *foundRequest = foundRequests[0];
    NSString *requestString = [kAlfrescoLegacyCancelJoinRequestsAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId
                                                                                                  withString:site.identifier];
    requestString = [requestString stringByReplacingOccurrencesOfString:kAlfrescoInviteId withString:foundRequest.identifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    __weak typeof(self) weakSelf = self;
    [self.session.networkProvider executeRequestWithURL:url
                                                session:self.session
                                                 method:kAlfrescoHTTPDelete
                                        alfrescoRequest:request
                                        completionBlock:^(NSData *data, NSError *error){
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            [weakSelf.siteCache cacheSite:site member:NO pending:NO favorite:site.isFavorite];
            [weakSelf.joinRequests removeObject:foundRequest];
            completionBlock(site, nil);
        }
    }];
        
    return request;
}


- (AlfrescoRequest *)leaveSite:(AlfrescoSite *)site
               completionBlock:(AlfrescoSiteCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:site argumentName:@"site"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
        
    NSString *requestString = [kAlfrescoLegacyLeaveSiteAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId
                                                                                        withString:self.session.personIdentifier];
    requestString = [requestString stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:site.identifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    __weak typeof(self) weakSelf = self;
    [self.session.networkProvider executeRequestWithURL:url session:self.session method:kAlfrescoHTTPDelete alfrescoRequest:request completionBlock:^(NSData *data, NSError *error){
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            // update the state of the site
            [weakSelf.siteCache cacheSite:site member:NO pending:NO favorite:site.isFavorite];
            completionBlock(site, nil);
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
    
    NSString *requestString = [kAlfrescoLegacyJoinPublicSiteAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId
                                                                                             withString:site.identifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
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
            NSArray *members = [weakSelf membersArrayFromJSONData:data error:&conversionError];
            if (conversionError == nil)
            {
                AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:members listingContext:listingContext];
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
    
    NSString *requestString =  [kAlfrescoLegacyJoinPublicSiteAPI stringByAppendingString:kAlfrescoLegacySiteMembershipFilter];
    requestString = [requestString stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:site.identifier];
    requestString = [requestString stringByReplacingOccurrencesOfString:kAlfrescoSearchFilter withString:keywords];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
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
            NSArray *members = [weakSelf membersArrayFromJSONData:data error:&conversionError];
            if (conversionError == nil)
            {
                AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:members listingContext:listingContext];
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
    
    NSString *requestString = [kAlfrescoLegacyLeaveSiteAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:person.identifier];
    requestString = [requestString stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:site.identifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session method:kAlfrescoHTTPGet alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        
        // if person is not member : the request returns error and data is nil so its difficult to differentiate if request failed or person is not member
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

- (AlfrescoRequest *)searchWithKeywords:(NSString *)keywords
                        completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:keywords argumentName:@"searchTerm"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *requestString = [kAlfrescoLegacySiteSearchAPI stringByReplacingOccurrencesOfString:kAlfrescoSearchFilter withString:keywords];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];

    [self.session.networkProvider executeRequestWithURL:url session:self.session method:kAlfrescoHTTPGet alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error || data == nil)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *siteData = [self siteArrayFromJSONData:data error:&conversionError];
            completionBlock(siteData, conversionError);
        }
    }];
    return request;
}

#pragma mark Data parsing methods

- (AlfrescoLegacyAPIJoinSiteRequest *)singleJoinRequestFromJSONData:(NSData *)data error:(NSError **)outError
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
    if (![[jsonDict allKeys] containsObject:kAlfrescoJSONData])
    {
        NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        return nil;
    }
    
    id dataObj = jsonDict[kAlfrescoJSONData];
    if (![dataObj isKindOfClass:[NSDictionary class]])
    {
        NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        return nil;
    }
    else
    {
        return [[AlfrescoLegacyAPIJoinSiteRequest alloc] initWithProperties:(NSDictionary *)dataObj];
    }
}

- (NSArray *)joinRequestArrayFromJSONData:(NSData *)data error:(NSError **)outError
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
    if (![[jsonDict allKeys] containsObject:kAlfrescoJSONData])
    {
        NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        return nil;
    }
    
    id dataObj = jsonDict[kAlfrescoJSONData];
    if (![dataObj isKindOfClass:[NSArray class]])
    {
        NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        return nil;
    }
    NSMutableArray *allRequests = [NSMutableArray array];
    for (id requestObj in (NSArray *)dataObj)
    {
        [allRequests addObject:[[AlfrescoLegacyAPIJoinSiteRequest alloc] initWithProperties:requestObj]];
    }
    return allRequests;    
}


- (NSArray *)siteArrayFromJSONData:(NSData *)data error:(NSError **)outError
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
    id jsonSiteArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error)
    {
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeSites];
        return nil;
    }
    if (![jsonSiteArray isKindOfClass:[NSArray class]])
    {
        if ([jsonSiteArray isKindOfClass:[NSDictionary class]] && [[jsonSiteArray valueForKeyPath:@"status.code"] isEqualToNumber:@404])
        {
            // no results found
            return @[];
        }
        else
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
    }
    
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:[jsonSiteArray count]];
    for (NSDictionary *siteDict in jsonSiteArray)
    {
        // If the retrieved site is cached then return that one, as it will have the correct status flags set
        AlfrescoSite *retrievedSite = [[AlfrescoSite alloc] initWithProperties:siteDict];
        AlfrescoSite *cachedSite = [self.siteCache siteWithShortName:retrievedSite.shortName];
        
        [resultArray addObject:cachedSite ?: retrievedSite];
    }
    return resultArray;
}

- (AlfrescoSite *)siteFromJSONData:(NSData *)data error:(NSError **)outError
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
    id jsonSite = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if(error)
    {
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeSites];
        return nil;
    }
    if (![jsonSite isKindOfClass:[NSDictionary class]])
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        }
        else
        {
            NSError *underlyingError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
            *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:underlyingError andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        }
        return nil;
    }
    if ([[jsonSite valueForKeyPath:kAlfrescoJSONStatusCode] isEqualToNumber:@404])
    {
        //empty/non existent site - should this happen? error message?
        return nil;
    }
    
    // If the retrieved site is cached then return that one, as it will have the correct status flags set
    AlfrescoSite *retrievedSite = [[AlfrescoSite alloc] initWithProperties:jsonSite];
    AlfrescoSite *cachedSite = [self.siteCache siteWithShortName:retrievedSite.shortName];
    
    return cachedSite ?: retrievedSite;
}

- (AlfrescoSite *)siteFromFolder:(AlfrescoFolder *)folder
{
    // construct a properties object representing the site to create
    NSMutableDictionary *siteProperties = [NSMutableDictionary dictionaryWithCapacity:8];
    siteProperties[kAlfrescoJSONShortname] = folder.name;
    
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

    // If the retrieved site is cached then return that one, as it will have the correct status flags set
    AlfrescoSite *retrievedSite = [[AlfrescoSite alloc] initWithProperties:siteProperties];
    AlfrescoSite *cachedSite = [self.siteCache siteWithShortName:retrievedSite.shortName];
    
    return cachedSite ?: retrievedSite;
}

- (NSArray *)membersArrayFromJSONData:(NSData *)data error:(NSError *__autoreleasing *)outError
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
    id jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if(nil == jsonArray)
    {
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodePerson];
        return nil;
    }
    
    if (NO == [jsonArray isKindOfClass:[NSArray class]])
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        }
        else
        {
            NSError *underlyingError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
            *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:underlyingError andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        }
        return nil;
    }
    
    NSMutableArray *members = [[NSMutableArray alloc] init];
    for (NSDictionary *member in jsonArray)
    {
        NSMutableDictionary *memberProperties = [member valueForKey:kAlfrescoJSONAuthority];
        AlfrescoCompany *company = [[AlfrescoCompany alloc] initWithProperties:memberProperties];
        [memberProperties setValue:company forKey:kAlfrescoJSONCompany];
        AlfrescoPerson *person = [[AlfrescoPerson alloc] initWithProperties:memberProperties];
        [members addObject:person];
    }
    
    return members;
}

- (NSArray *)favoriteSitesArrayFromJSONData:(NSData *)data error:(NSError **)outError
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
    id favoriteSitesObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if(error)
    {
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeSites];
        return nil;
    }
    if (![favoriteSitesObject isKindOfClass:[NSDictionary class]])
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        }
        else
        {
            NSError *underlyingError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
            *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:underlyingError andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        }
        return nil;
    }
    NSDictionary *favouriteSitesDictionary = (NSDictionary *)favoriteSitesObject;
    NSMutableArray *resultArray = [NSMutableArray array];

    id favouriteSitesObj = [favouriteSitesDictionary valueForKeyPath:kAlfrescoLegacyFavoriteSites];
    if ([favouriteSitesObj isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *favDict = (NSDictionary *)favouriteSitesObj;
        for (NSString * favouriteSite in favDict)
        {
            id valueObj = [favDict valueForKey:favouriteSite];
            if ([valueObj isKindOfClass:[NSNumber class]])
            {
                BOOL isFavourite = [valueObj boolValue];
                if (isFavourite)
                {
                    [resultArray addObject:favouriteSite];
                }
            }
            else
            {
                [resultArray addObject:favouriteSite];
            }
        }
    }
    else if([favouriteSitesObj isKindOfClass:[NSArray class]])
    {
        NSArray *sitesArray = (NSArray *)favouriteSitesObj;
        for (NSString * favouriteSite in sitesArray)
        {
            [resultArray addObject:favouriteSite];
        }
    }
    return resultArray;
}

- (NSData *)jsonDataForJoiningPublicSite:(NSString *)personId
{
    NSDictionary *personDict = @{kAlfrescoJSONUserName: personId};
    NSDictionary *jsonDict = @{kAlfrescoJSONRole: kAlfrescoSiteConsumer, kAlfrescoJSONPerson: personDict};
    NSError *error = nil;
    return [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
}

- (NSData *)jsonDataForJoiningModeratedSite:(NSString *)personId comment:(NSString *)comment
{
    if (nil == comment)
    {
        comment = @"";
    }
    NSDictionary *jsonDict = @{kAlfrescoJSONInvitationType: kAlfrescoModerated, kAlfrescoJSONInviteeUsername: personId, kAlfrescoJSONInviteeComments: comment, kAlfrescoJSONInviteeRolename: kAlfrescoSiteConsumer};
    NSError *error = nil;
    return [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
}

- (NSData *)jsonDataForFavoriteSites:(NSString *)siteId addFavorite:(BOOL)addFavorite
{
    NSDictionary *favorite = @{kAlfrescoJSONFavorites: @{siteId: @(addFavorite)}};
    NSDictionary *sites = @{kAlfrescoJSONSites: favorite};
    NSDictionary *share = @{kAlfrescoJSONShare: sites};
    NSDictionary *alfresco = @{kAlfrescoJSONAlfresco: share};
    
    NSDictionary *jsonDict = @{kAlfrescoJSONOrg: alfresco};
    NSError *error = nil;
    return [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
}

#pragma mark AlfrescoSiteDataDelegate methods

- (AlfrescoRequest *)retrieveMemberSiteDataWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    AlfrescoRequest *alfrescoRequest = [[AlfrescoRequest alloc] init];
    __weak typeof(self) weakSelf = self;
    
    NSString *siteString = [kAlfrescoLegacySiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
    NSURL *mySitesAPI = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:siteString];
    [self.session.networkProvider executeRequestWithURL:mySitesAPI session:self.session
                                        alfrescoRequest:alfrescoRequest completionBlock:^(NSData *data, NSError *error){
        if (data != nil)
        {
            NSError *conversionError = nil;
            NSArray *memberSiteData = [weakSelf siteArrayFromJSONData:data error:&conversionError];
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
    
    NSString *favRequestString = [kAlfrescoLegacyFavoriteSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId
                                                                                                       withString:self.session.personIdentifier];
    NSURL *favouriteSitesURL = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:favRequestString];
    [self.session.networkProvider executeRequestWithURL:favouriteSitesURL session:self.session
                                        alfrescoRequest:alfrescoRequest completionBlock:^(NSData *data, NSError *error){
        if (data != nil)
        {
            NSError *conversionError = nil;
            NSArray *favoriteSiteData = [weakSelf favoriteSitesArrayFromJSONData:data error:&conversionError];
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
    
    NSString *pendingString = [kAlfrescoLegacyPendingJoinRequestsAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId
                                                                                                  withString:self.session.personIdentifier];
    NSURL *pendingSitesAPI = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:pendingString];
    [self.session.networkProvider executeRequestWithURL:pendingSitesAPI session:self.session
                                        alfrescoRequest:alfrescoRequest completionBlock:^(NSData *data, NSError *error){
        if (data != nil)
        {
            NSError *conversionError = nil;
            NSArray *joinRequestData = [weakSelf joinRequestArrayFromJSONData:data error:&conversionError];
            NSMutableArray *pendingSiteNames = [NSMutableArray arrayWithCapacity:joinRequestData.count];
            for (AlfrescoLegacyAPIJoinSiteRequest *joinRequest in joinRequestData)
            {
                [pendingSiteNames addObject:joinRequest.shortName];
            }
            
            completionBlock(pendingSiteNames, conversionError);
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
    
    NSString *requestString = [kAlfrescoLegacySitesShortnameAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:shortName];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    [self.session.networkProvider executeRequestWithURL:url session:self.session
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

#pragma mark Internal private methods

- (AlfrescoRequest *)joinPublicSite:(AlfrescoSite *)site completionBlock:(AlfrescoSiteCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:site argumentName:@"site"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    NSString *requestString = [kAlfrescoLegacyJoinPublicSiteAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId
                                                                                             withString:site.identifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    NSData *jsonData = [self jsonDataForJoiningPublicSite:self.session.personIdentifier];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    __weak typeof(self) weakSelf = self;
    [self.session.networkProvider executeRequestWithURL:url session:self.session requestBody:jsonData method:kAlfrescoHTTPPost alfrescoRequest:request completionBlock:^(NSData *data, NSError *error){
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            // update the state of the site
            [weakSelf.siteCache cacheSite:site member:YES pending:NO favorite:site.isFavorite];
            completionBlock(site, nil);
        }
    }];
    
    return request;
    
    
}

- (AlfrescoRequest *)joinModeratedSite:(AlfrescoSite *)site
                       completionBlock:(AlfrescoSiteCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:site argumentName:@"site"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    NSString *requestString = [kAlfrescoLegacyJoinModeratedSiteAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId
                                                                                                withString:site.identifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    NSData *jsonData = [self jsonDataForJoiningModeratedSite:self.session.personIdentifier comment:nil];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    __weak typeof(self) weakSelf = self;
    [self.session.networkProvider executeRequestWithURL:url session:self.session requestBody:jsonData method:kAlfrescoHTTPPost alfrescoRequest:request completionBlock:^(NSData *data, NSError *error){
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *jsonError = nil;
            AlfrescoLegacyAPIJoinSiteRequest *joinRequest = [weakSelf singleJoinRequestFromJSONData:data error:&jsonError];
            if (joinRequest)
            {
                [weakSelf.joinRequests addObject:joinRequest];
                [weakSelf.siteCache cacheSite:site member:NO pending:YES favorite:site.isFavorite];
                completionBlock(site, nil);
            }
            else
            {
                completionBlock(nil, jsonError);
            }
        }
    }];
    
    return request;
    
}

// NOTE: Ideally these methods should be in a common base class as it is identical to the implementation in AlfrescoPublicAPISiteService.m

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
    AlfrescoDocumentFolderService *docFolderSvc = [[AlfrescoDocumentFolderService alloc] initWithSession:self.session];
    __weak typeof(self) weakSelf = self;
    
    return [docFolderSvc retrieveChildrenInFolder:self.session.rootFolder completionBlock:^(NSArray *children, NSError *error) {
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
