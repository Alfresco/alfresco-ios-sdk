/*******************************************************************************
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
 ******************************************************************************/

#import "AlfrescoCloudSiteService.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoBasicAuthenticationProvider.h"
#import "AlfrescoErrors.h"
#import "AlfrescoURLUtils.h"
#import "AlfrescoSortingUtils.h"
#import "AlfrescoPagingUtils.h"
#import "AlfrescoDocumentFolderService.h"
#import "AlfrescoNetworkProvider.h"
#import "AlfrescoLog.h"
#import "AlfrescoSiteCache.h"
#import <objc/runtime.h>


@interface AlfrescoCloudSiteService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, weak, readwrite) id<AlfrescoAuthenticationProvider> authenticationProvider;
@property (nonatomic, strong, readwrite) NSArray *supportedSortKeys;
@property (nonatomic, strong, readwrite) NSString *defaultSortKey;
@property (nonatomic, strong, readwrite) AlfrescoSiteCache *siteCache;
- (NSArray *) siteArrayWithData:(NSData *)data error:(NSError **)outError;
- (NSArray *) specifiedSiteArrayFromJSONData:(NSData *)data error:(NSError **)outError;
- (AlfrescoSite *) alfrescoSiteFromJSONData:(NSData *)data error:(NSError **)outError;
- (NSDictionary *) dictionaryFromJSONData:(NSData *)data error:(NSError **)outError;

@end

@implementation AlfrescoCloudSiteService

- (id)initWithSession:(id<AlfrescoSession>)session
{
    if (self = [super init])
    {
        self.session = session;
        self.baseApiUrl = [[self.session.baseUrl absoluteString] stringByAppendingString:kAlfrescoCloudAPIPath];
        id authenticationObject = [session objectForParameter:kAlfrescoAuthenticationProviderObjectKey];
        self.authenticationProvider = nil;
        if ([authenticationObject isKindOfClass:[AlfrescoBasicAuthenticationProvider class]])
        {
            self.authenticationProvider = (AlfrescoBasicAuthenticationProvider *)authenticationObject;
        }
        self.defaultSortKey = kAlfrescoSortByTitle;
        self.supportedSortKeys = [NSArray arrayWithObjects:kAlfrescoSortByTitle, kAlfrescoSortByShortname, nil];
        NSString *siteCacheKey = [NSString stringWithFormat:@"%@%@",kAlfrescoSessionInternalCache,NSStringFromClass([AlfrescoSiteCache class])];
        id cachedObj = [self.session objectForParameter:siteCacheKey];
        if (cachedObj)
        {
            self.siteCache = (AlfrescoSiteCache *)cachedObj;
        }
        else
        {
            AlfrescoSiteCache *cache = [AlfrescoSiteCache siteCacheForSession:session];
            [self.session setObject:cache forParameter:siteCacheKey];
            self.siteCache = cache;
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
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    NSArray *allSites = [self.siteCache allSites];
    if (0 < allSites.count && !self.siteCache.hasMoreSites)
    {
        NSArray *sortedSites = [AlfrescoSortingUtils sortedArrayForArray:allSites sortKey:self.defaultSortKey ascending:YES];
        completionBlock(sortedSites, nil);
        return nil;        
    }
    AlfrescoRequest *request = [self retrieveSitesForType:AlfrescoSiteAll completionBlock:completionBlock];
    return request;
}

- (AlfrescoRequest *)retrieveAllSitesWithListingContext:(AlfrescoListingContext *)listingContext
                           completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    NSArray *allSites = [self.siteCache allSites];
    if (0 < allSites.count && !self.siteCache.hasMoreSites)
    {
        NSArray *sortedSites = [AlfrescoSortingUtils sortedArrayForArray:allSites sortKey:self.defaultSortKey ascending:YES];
        AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedSites listingContext:listingContext];
        completionBlock(pagingResult, nil);
        return nil;
    }
    AlfrescoRequest *request = [self retrieveSitesForType:AlfrescoSiteAll listingContext:listingContext
                                          completionBlock:completionBlock];
    return request;
}

- (AlfrescoRequest *)retrieveSitesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSArray *memberSites = [self.siteCache memberSites];
    if (0 < memberSites.count && !self.siteCache.hasMoreMemberSites)
    {
        NSArray *sortedSites = [AlfrescoSortingUtils sortedArrayForArray:memberSites sortKey:self.defaultSortKey ascending:YES];
        completionBlock(sortedSites, nil);
        return nil;
    }
    AlfrescoRequest *request = [self retrieveSitesForType:AlfrescoSiteMember completionBlock:completionBlock];
    return request;
}

- (AlfrescoRequest *)retrieveSitesWithListingContext:(AlfrescoListingContext *)listingContext
                                     completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    NSArray *memberSites = [self.siteCache memberSites];
    if (0 < memberSites.count && !self.siteCache.hasMoreMemberSites)
    {
        NSArray *sortedSites = [AlfrescoSortingUtils sortedArrayForArray:memberSites sortKey:self.defaultSortKey ascending:YES];
        AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedSites listingContext:listingContext];
        completionBlock(pagingResult, nil);
        return nil;
    }
    AlfrescoRequest *request = [self retrieveSitesForType:AlfrescoSiteMember listingContext:listingContext completionBlock:completionBlock];
    return request;
}

- (AlfrescoRequest *)retrieveFavoriteSitesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSArray *favoriteSites = [self.siteCache favoriteSites];
    if (0 < favoriteSites.count && !self.siteCache.hasMoreFavoriteSites)
    {
        NSArray *sortedSites = [AlfrescoSortingUtils sortedArrayForArray:favoriteSites sortKey:self.defaultSortKey ascending:YES];
        completionBlock(sortedSites, nil);
        return nil;
    }
    AlfrescoRequest *request = [self retrieveSitesForType:AlfrescoSiteFavorite completionBlock:completionBlock];
    return request;
}

- (AlfrescoRequest *)retrieveFavoriteSitesWithListingContext:(AlfrescoListingContext *)listingContext
                                             completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    NSArray *favoriteSites = [self.siteCache favoriteSites];
    if (0 < favoriteSites.count && !self.siteCache.hasMoreFavoriteSites)
    {
        NSArray *sortedSites = [AlfrescoSortingUtils sortedArrayForArray:favoriteSites sortKey:self.defaultSortKey ascending:YES];
        AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedSites listingContext:listingContext];
        completionBlock(pagingResult, nil);
        return nil;
    }
    AlfrescoRequest *request = [self retrieveSitesForType:AlfrescoSiteFavorite listingContext:listingContext completionBlock:completionBlock];
    return request;
}

- (AlfrescoRequest *)retrieveSiteWithShortName:(NSString *)siteShortName
                               completionBlock:(AlfrescoSiteCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:siteShortName argumentName:@"siteShortName"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *requestString = [kAlfrescoCloudSiteForShortnameAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:siteShortName];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
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
            AlfrescoSite *site = [self alfrescoSiteFromJSONData:data error:&conversionError];
            completionBlock(site, conversionError);
            
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveDocumentLibraryFolderForSite:(NSString *)siteShortName
                                          completionBlock:(AlfrescoFolderCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:siteShortName argumentName:@"siteShortName"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    
    NSString *requestString = [kAlfrescoCloudSiteContainersAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:siteShortName];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    __block AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
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
            NSDictionary *folderDict = [self dictionaryFromJSONData:data error:&conversionError];
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
                    AlfrescoDocumentFolderService *docService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.session];
                    request = [docService retrieveNodeWithIdentifier:folderId completionBlock:^(AlfrescoNode *node, NSError *nodeError){
                        if (nil == node)
                        {
                            completionBlock(nil, nodeError);
                        }
                        else
                        {
                            completionBlock((AlfrescoFolder *)node, nil);
                        }
                    }];
                    
                }
                
            }
            
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrievePendingSitesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    NSArray *pendingSiteRequests = [self.siteCache pendingMemberSites];
    if (0 < pendingSiteRequests.count)
    {
        completionBlock(pendingSiteRequests, nil);
        return nil;
    }
    AlfrescoRequest *request = [self retrieveSitesForType:AlfrescoSitePendingMember completionBlock:completionBlock];
    return request;
}


- (AlfrescoRequest *)addFavoriteSite:(AlfrescoSite *)site
                     completionBlock:(AlfrescoSiteCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:site argumentName:@"site"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoCloudAddFavoriteSiteAPI];
    NSData *jsonData = [self jsonDataForAddingFavoriteSite:site.GUID];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url
                                                session:self.session
                                            requestBody:jsonData
                                                 method:kAlfrescoHTTPPOST
                                        alfrescoRequest:request
                                        completionBlock:^(NSData *data, NSError *error){
                                            if (nil == data)
                                            {
                                                completionBlock(nil, error);
                                            }
                                            else
                                            {
                                                [self.siteCache addFavoriteSite:site];
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
    NSString *requestString = [kAlfrescoCloudRemoveFavoriteSiteAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteGUID
                                                                                             withString:site.GUID];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
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
                                                [self.siteCache removeFavoriteSite:site];
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
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoCloudJoinSiteAPI];
    NSData *jsonData = [self jsonDataForJoiningSite:site.identifier comment:@""];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url
                                                session:self.session
                                            requestBody:jsonData
                                                 method:kAlfrescoHTTPPOST
                                        alfrescoRequest:request
                                        completionBlock:^(NSData *data, NSError *error){
                                            if (nil == data)
                                            {
                                                completionBlock(nil, error);
                                            }
                                            else
                                            {
                                                NSError *jsonError = nil;
                                                AlfrescoSite *requestedSite = [self singleJoinRequestSiteFromJSONData:data error:&jsonError];
                                                if (requestedSite)
                                                {
                                                    if (requestedSite.visibility == AlfrescoSiteVisibilityPublic)
                                                    {
                                                        [self.siteCache addMemberSite:site];
                                                        completionBlock(site, nil);
                                                    }
                                                    else
                                                    {
                                                        [self.siteCache addPendingSite:site];
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
    NSString *requestString = [kAlfrescoCloudCancelJoinRequestsAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId
                                                                                             withString:site.identifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
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
                                                [self.siteCache removePendingSite:site];
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
    NSString *requestString = [kAlfrescoCloudLeaveSiteAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId
                                                                                    withString:site.identifier];
    requestString = [requestString stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
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
                                                [self.siteCache removeMemberSite:site];
                                                completionBlock(site, error);
                                            }
                                        }];
    
    return request;
}



#pragma mark Site service internal methods

- (AlfrescoRequest *)retrieveSitesForType:(AlfrescoSiteFlags)type completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    
    __block NSArray *resultsArray = nil;
    NSURL *allSitesAPI = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoCloudSiteAPI];
    
    NSString *requestString = [kAlfrescoCloudSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId
                                                                                        withString:self.session.personIdentifier];
    NSURL *memberApi = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];

    requestString = [kAlfrescoCloudFavoriteSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId
                                                                                                withString:self.session.personIdentifier];
    NSURL *favApi = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    NSURL *pendingApi = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoCloudJoinSiteAPI];
    
    [self.session.networkProvider executeRequestWithURL:allSitesAPI session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error){
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSDictionary *pagingInfo = [AlfrescoObjectConverter paginationJSONFromData:data error:&conversionError];
            NSArray *sites = [self siteArrayWithData:data error:&conversionError];
            if (sites && pagingInfo)
            {
                NSArray *allSortedSites = [AlfrescoSortingUtils sortedArrayForArray:sites sortKey:self.defaultSortKey ascending:YES];
                [self.siteCache addSites:allSortedSites hasMoreSites:[[pagingInfo valueForKeyPath:kAlfrescoCloudJSONHasMoreItems] boolValue]];
                [self.session.networkProvider executeRequestWithURL:memberApi session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *mySitesError){
                    if (nil == data)
                    {
                        completionBlock(nil, mySitesError);
                    }
                    else
                    {
                        NSError *conversionError = nil;
                        NSArray *sites = [self specifiedSiteArrayFromJSONData:data error:&conversionError];
                        NSDictionary *sitesPagination = [AlfrescoObjectConverter paginationJSONFromData:data error:&conversionError];
                        if (sites && sitesPagination)
                        {
                            NSArray *mySortedSites = [AlfrescoSortingUtils sortedArrayForArray:sites sortKey:self.defaultSortKey ascending:YES];
                            [self.siteCache addMemberSites:mySortedSites hasMoreMemberSites:[[sitesPagination valueForKeyPath:kAlfrescoCloudJSONHasMoreItems] boolValue]];
                            [self.session.networkProvider executeRequestWithURL:favApi session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error){
                                if (nil == data)
                                {
                                    completionBlock(nil, error);
                                }
                                else
                                {
                                    NSError *conversionError = nil;
                                    NSArray *sites = [self siteArrayWithData:data error:&conversionError];
                                    NSDictionary *favPagination = [AlfrescoObjectConverter paginationJSONFromData:data error:&conversionError];
                                    if (sites && favPagination)
                                    {
                                        NSArray *favSortedSites = [AlfrescoSortingUtils sortedArrayForArray:sites sortKey:self.defaultSortKey ascending:YES];
                                        [self.siteCache addFavoriteSites:favSortedSites hasMoreFavoriteSites:[[favPagination valueForKeyPath:kAlfrescoCloudJSONHasMoreItems] boolValue]];
                                        [self.session.networkProvider executeRequestWithURL:pendingApi session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error){
                                            if (nil == data)
                                            {
                                                completionBlock(nil, error);
                                            }
                                            else
                                            {
                                                NSError *jsonError = nil;
                                                NSArray *pending = [self joinRequestSitesArrayFromJSONData:data error:&jsonError];
                                                NSDictionary *pendingPagination = [AlfrescoObjectConverter paginationJSONFromData:data error:&jsonError];
                                                if (pending && pendingPagination)
                                                {
                                                    [self.siteCache addPendingSites:pending hasMorePendingSites:[[pendingPagination valueForKeyPath:kAlfrescoCloudJSONHasMoreItems] boolValue]];
                                                    switch (type)
                                                    {
                                                        case AlfrescoSiteAll:
                                                            resultsArray = allSortedSites;
                                                            break;
                                                        case AlfrescoSiteFavorite:
                                                            resultsArray = favSortedSites;
                                                            break;
                                                        case AlfrescoSiteMember:
                                                            resultsArray = mySortedSites;
                                                            break;
                                                        case AlfrescoSitePendingMember:
                                                            resultsArray = pending;
                                                            break;
                                                    }
                                                    completionBlock(resultsArray, nil);
                                                }
                                                else
                                                {
                                                    completionBlock(nil, jsonError);
                                                }
                                            }
                                        }];
                                    }
                                    else
                                    {
                                        completionBlock(nil, conversionError);
                                    }
                                }
                            }];
                            
                        }
                        else
                        {
                            completionBlock(nil, conversionError);
                        }
                    }
                }];
            }
            else
            {
                completionBlock(nil, conversionError);
            }
        }
    }];
    
    return request;
}

- (AlfrescoRequest *)retrieveSitesForType:(AlfrescoSiteFlags)type
                           listingContext:(AlfrescoListingContext *)listingContext
                          completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    
    __block NSArray *resultsArray = nil;
    NSURL *allSitesAPI = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoCloudSiteAPI];
    NSString *requestString = [kAlfrescoCloudSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId
                                                                                        withString:self.session.personIdentifier];
    NSURL *memberApi = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    requestString = [kAlfrescoCloudFavoriteSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId
                                                                                                withString:self.session.personIdentifier];
    NSURL *favApi = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    NSURL *pendingApi = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoCloudJoinSiteAPI];
    
    [self.session.networkProvider executeRequestWithURL:allSitesAPI session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error){
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSDictionary *pagingInfo = [AlfrescoObjectConverter paginationJSONFromData:data error:&conversionError];
            NSArray *sites = [self siteArrayWithData:data error:&conversionError];
            if (sites && pagingInfo)
            {
                NSArray *allSortedSites = [AlfrescoSortingUtils sortedArrayForArray:sites sortKey:self.defaultSortKey ascending:YES];
                [self.siteCache addSites:allSortedSites hasMoreSites:[[pagingInfo valueForKeyPath:kAlfrescoCloudJSONHasMoreItems] boolValue]];
                [self.session.networkProvider executeRequestWithURL:memberApi session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *mySitesError){
                    if (nil == data)
                    {
                        completionBlock(nil, mySitesError);
                    }
                    else
                    {
                        NSError *conversionError = nil;
                        NSArray *sites = [self specifiedSiteArrayFromJSONData:data error:&conversionError];
                        NSDictionary *sitesPagination = [AlfrescoObjectConverter paginationJSONFromData:data error:&conversionError];
                        if (sites && sitesPagination)
                        {
                            NSArray *mySortedSites = [AlfrescoSortingUtils sortedArrayForArray:sites sortKey:self.defaultSortKey ascending:YES];
                            [self.siteCache addMemberSites:mySortedSites hasMoreMemberSites:[[sitesPagination valueForKeyPath:kAlfrescoCloudJSONHasMoreItems] boolValue]];
                            [self.session.networkProvider executeRequestWithURL:favApi session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error){
                                if (nil == data)
                                {
                                    completionBlock(nil, error);
                                }
                                else
                                {
                                    NSError *conversionError = nil;
                                    NSArray *sites = [self siteArrayWithData:data error:&conversionError];
                                    NSDictionary *favPagination = [AlfrescoObjectConverter paginationJSONFromData:data error:&conversionError];
                                    if (sites && favPagination)
                                    {
                                        NSArray *favSortedSites = [AlfrescoSortingUtils sortedArrayForArray:sites sortKey:self.defaultSortKey ascending:YES];
                                        [self.siteCache addFavoriteSites:favSortedSites hasMoreFavoriteSites:[[favPagination valueForKeyPath:kAlfrescoCloudJSONHasMoreItems] boolValue]];
                                        [self.session.networkProvider executeRequestWithURL:pendingApi session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error){
                                            if (nil == data)
                                            {
                                                completionBlock(nil, error);
                                            }
                                            else
                                            {
                                                NSError *jsonError = nil;
                                                NSArray *pending = [self joinRequestSitesArrayFromJSONData:data error:&jsonError];
                                                NSDictionary *pendingPagination = [AlfrescoObjectConverter paginationJSONFromData:data error:&jsonError];
                                                if (pending && pendingPagination)
                                                {
                                                    [self.siteCache addPendingSites:pending hasMorePendingSites:[[pendingPagination valueForKeyPath:kAlfrescoCloudJSONHasMoreItems] boolValue]];
                                                    switch (type)
                                                    {
                                                        case AlfrescoSiteAll:
                                                            resultsArray = allSortedSites;
                                                            break;
                                                        case AlfrescoSiteFavorite:
                                                            resultsArray = favSortedSites;
                                                            break;
                                                        case AlfrescoSiteMember:
                                                            resultsArray = mySortedSites;
                                                            break;
                                                        case AlfrescoSitePendingMember:
                                                            resultsArray = pending;
                                                            break;
                                                    }
                                                    AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:resultsArray listingContext:listingContext];
                                                    completionBlock(pagingResult, nil);
                                                }
                                                else
                                                {
                                                    completionBlock(nil, jsonError);
                                                }
                                            }
                                        }];
                                    }
                                    else
                                    {
                                        completionBlock(nil, conversionError);
                                    }
                                }
                            }];
                            
                        }
                        else
                        {
                            completionBlock(nil, conversionError);
                        }
                    }
                }];
            }
            else
            {
                completionBlock(nil, conversionError);
            }
        }
    }];
    
    return request;
}



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
    id jsonRequestObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(error)
    {
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeSites];
        return nil;
    }
    if ([jsonRequestObj isKindOfClass:[NSDictionary class]] == NO)
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
    if (![[jsonDict allKeys] containsObject:kAlfrescoCloudJSONEntry])
    {
        NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        return nil;
    }
    AlfrescoSite *requestedSite = nil;
    id dataObj = [jsonDict objectForKey:kAlfrescoCloudJSONEntry];
    if (![dataObj isKindOfClass:[NSDictionary class]])
    {
        NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        return nil;
    }
    else
    {
        NSDictionary *entryDict = (NSDictionary *)dataObj;
        id siteObj = [entryDict objectForKey:kAlfrescoJSONSite];
        if (nil == siteObj)
        {
            NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
            *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
            return nil;
        }
        else if([siteObj isKindOfClass:[NSDictionary class]] == NO)
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
        individualSiteEntry = [entryDict valueForKey:kAlfrescoCloudJSONEntry];
        if (nil != individualSiteEntry)
        {
            id siteObj = [individualSiteEntry objectForKey:kAlfrescoJSONSite];
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

- (NSArray *) siteArrayWithData:(NSData *)data error:(NSError **)outError
{
    NSArray *entriesArray = [AlfrescoObjectConverter arrayJSONEntriesFromListData:data error:outError];
    if (nil != entriesArray)
    {
        NSMutableArray *resultsArray = [NSMutableArray arrayWithCapacity:entriesArray.count];
        
        for (NSDictionary *entryDict in entriesArray)
        {
            NSMutableDictionary *individualEntry = [NSMutableDictionary dictionaryWithDictionary:[entryDict valueForKey:kAlfrescoCloudJSONEntry]];
            AlfrescoSite *site = [[AlfrescoSite alloc] initWithProperties:individualEntry];
            [resultsArray addObject:site];
        }
        return resultsArray;
    }
    else
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
            NSDictionary *individualEntry = [entryDict valueForKey:kAlfrescoCloudJSONEntry];
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



- (AlfrescoSite *) alfrescoSiteFromJSONData:(NSData *)data error:(NSError **)outError
{
    NSDictionary *entryDictionary = [AlfrescoObjectConverter dictionaryJSONEntryFromListData:data error:outError];
    return [[AlfrescoSite alloc] initWithProperties:entryDictionary];
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
        individualFolderEntry = [entryDict valueForKey:kAlfrescoCloudJSONEntry];
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
    NSDictionary *siteId = [NSDictionary dictionaryWithObject:siteGUID forKey:kAlfrescoJSONGUID];
    NSDictionary *site = [NSDictionary dictionaryWithObject:siteId forKey:kAlfrescoJSONSite];
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObject:site forKey:kAlfrescoJSONTarget];
    NSError *error = nil;
    return [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
}

- (NSData *)jsonDataForJoiningSite:(NSString *)site comment:(NSString *)comment
{
    NSDictionary *jsonDict =  [NSDictionary dictionaryWithObjects:@[site, comment] forKeys:@[kAlfrescoJSONIdentifier, kAlfrescoJSONMessage]];
    NSError *error = nil;
    return [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
}

@end
