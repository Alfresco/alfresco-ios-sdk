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

#import "AlfrescoOnPremiseSiteService.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoObjectConverter.h"
#import "AlfrescoErrors.h"
#import "AlfrescoURLUtils.h"
#import "AlfrescoPagingUtils.h"
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoBasicAuthenticationProvider.h"
#import "AlfrescoDocumentFolderService.h"
#import "AlfrescoSortingUtils.h"
#import "AlfrescoNetworkProvider.h"
#import "AlfrescoLog.h"
#import "AlfrescoSiteCache.h"
#import "AlfrescoOnPremiseJoinSiteRequest.h"

@interface AlfrescoOnPremiseSiteService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, strong, readwrite) AlfrescoObjectConverter *objectConverter;
@property (nonatomic, weak, readwrite) id<AlfrescoAuthenticationProvider> authenticationProvider;
@property (nonatomic, strong, readwrite) NSArray *supportedSortKeys;
@property (nonatomic, strong, readwrite) NSString *defaultSortKey;
@property (nonatomic, strong, readwrite) AlfrescoSiteCache *siteCache;
@property (nonatomic, strong, readwrite) NSMutableArray *joinRequests;
- (NSArray *) siteArrayFromJSONData:(NSData *)data error:(NSError **)outError;
- (AlfrescoSite *) alfrescoSiteFromJSONData:(NSData *)data error:(NSError **)outError;
- (NSArray *) favoriteSitesArrayFromJSONData:(NSData *)data error:(NSError **)outError;
@end

@implementation AlfrescoOnPremiseSiteService

- (id)initWithSession:(id<AlfrescoSession>)session
{
    if (self = [super init])
    {
        self.session = session;
        self.baseApiUrl = [[self.session.baseUrl absoluteString] stringByAppendingString:kAlfrescoOnPremiseAPIPath];
        self.objectConverter = [[AlfrescoObjectConverter alloc] initWithSession:self.session];
        id authenticationObject = [session objectForParameter:kAlfrescoAuthenticationProviderObjectKey];
        self.authenticationProvider = nil;
        if ([authenticationObject isKindOfClass:[AlfrescoBasicAuthenticationProvider class]])
        {
            self.authenticationProvider = (AlfrescoBasicAuthenticationProvider *)authenticationObject;
        }
        self.defaultSortKey = kAlfrescoSortByTitle;
        self.supportedSortKeys = [NSArray arrayWithObjects:kAlfrescoSortByTitle, kAlfrescoSortByShortname, nil];
        self.joinRequests = [NSMutableArray array];
        NSString *siteCacheKey = [NSString stringWithFormat:@"%@%@",kAlfrescoSessionInternalCache,NSStringFromClass([AlfrescoSiteCache class])];
        id cachedObj = [self.session objectForParameter:siteCacheKey];
        if (cachedObj)
        {
            if ([AlfrescoLog sharedInstance].logLevel == AlfrescoLogLevelDebug)
            {
                AlfrescoLogDebug(@"we found an existing Site cache for key %@ and are using that", siteCacheKey );
            }
            self.siteCache = (AlfrescoSiteCache *)cachedObj;
        }
        else
        {
            if ([AlfrescoLog sharedInstance].logLevel == AlfrescoLogLevelDebug)
            {
                AlfrescoLogDebug(@"we found no existing Site cache for key %@ and must create it", siteCacheKey );
            }
            self.siteCache = [AlfrescoSiteCache siteCacheForSession:self.session];
            [self.session setObject:self.siteCache forParameter:siteCacheKey];
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
    
    AlfrescoRequest *request = [self retrieveSitesForType:AlfrescoSiteAll listingContext:listingContext completionBlock:completionBlock];
    /*
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoOnPremiseSiteAPI];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error){
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *siteArray = [self siteArrayFromJSONData:data error:&conversionError];
            if (siteArray)
            {
                NSArray *sortedArray = [AlfrescoSortingUtils sortedArrayForArray:siteArray sortKey:self.defaultSortKey ascending:YES];
                AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedArray listingContext:listingContext];
                completionBlock(pagingResult, nil);
            }
            else
            {
                completionBlock(nil, conversionError);
            }
            
            
        }
    }];
     */
    return request;
}

- (AlfrescoRequest *)retrieveSitesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSArray *memberSites = [self.siteCache memberSites];
    if (0 < memberSites.count)
    {
        NSArray *sortedSiteArray = [AlfrescoSortingUtils sortedArrayForArray:memberSites sortKey:self.defaultSortKey ascending:YES];
        if ([AlfrescoLog sharedInstance].logLevel == AlfrescoLogLevelDebug)
        {
            AlfrescoLogDebug(@"returning cached member sites %d", sortedSiteArray.count);
        }
        completionBlock(sortedSiteArray, nil);
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
    
    AlfrescoRequest *request = [self retrieveSitesForType:AlfrescoSiteMember listingContext:listingContext completionBlock:completionBlock];
    /*
    NSString *personString = [kAlfrescoOnPremiseSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:personString];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error){
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *siteArray = [self siteArrayFromJSONData:data error:&conversionError];
            if (siteArray)
            {
                [self.siteCache addMemberSites:siteArray];
                NSArray *sortedSiteArray = [AlfrescoSortingUtils sortedArrayForArray:siteArray sortKey:self.defaultSortKey ascending:YES];
                AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedSiteArray listingContext:listingContext];
                completionBlock(pagingResult, conversionError);
            }
            else
            {
                completionBlock(nil, conversionError);
            }
        }
    }];
     */
    return request;
}


- (AlfrescoRequest *)retrieveFavoriteSitesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    NSArray *favourites = [self.siteCache favoriteSites];
    if (0 < favourites.count)
    {
        NSArray *sortedSites = [AlfrescoSortingUtils sortedArrayForArray:favourites sortKey:self.defaultSortKey ascending:YES];
        if ([AlfrescoLog sharedInstance].logLevel == AlfrescoLogLevelDebug)
        {
            AlfrescoLogDebug(@"returning cached favorite sites %d", sortedSites.count);
        }
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
    
    AlfrescoRequest *request = [self retrieveSitesForType:AlfrescoSiteFavorite listingContext:listingContext completionBlock:completionBlock];
    /*
    NSString *favRequestString = [kAlfrescoOnPremiseFavoriteSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId
                                                                                                       withString:self.session.personIdentifier];
    NSString *allRequestString = [kAlfrescoOnPremiseSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId
                                                                                               withString:self.session.personIdentifier];
    NSURL *allSitesURL = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:allRequestString];
    NSURL *favouriteSitesURL = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:favRequestString];
    
    [self.session.networkProvider executeRequestWithURL:allSitesURL session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *allSitesError){
        if (nil == data)
        {
            completionBlock(nil, allSitesError);
        }
        else
        {
            [self.session.networkProvider executeRequestWithURL:favouriteSitesURL session:self.session alfrescoRequest:request completionBlock:^(NSData *favData, NSError *favError){
                if (nil == favData)
                {
                    completionBlock(nil, favError);
                }
                else
                {
                    NSError *conversionError = nil;
                    NSArray *allSitesArray = [self siteArrayFromJSONData:data error:&conversionError];
                    NSArray *favSitesArray = [self favoriteSitesArrayFromJSONData:favData error:&conversionError];
                    if (nil == favSitesArray || nil == allSitesArray)
                    {
                        completionBlock(nil, conversionError);
                    }
                    else
                    {
                        NSPredicate *favoritePredicate = [NSPredicate predicateWithFormat:@"shortName IN %@",favSitesArray];
                        NSArray *favoriteSites = [allSitesArray filteredArrayUsingPredicate:favoritePredicate];
                        [self.siteCache addFavoriteSites:favoriteSites];
                        NSArray *sortedSites = [AlfrescoSortingUtils sortedArrayForArray:favoriteSites sortKey:self.defaultSortKey ascending:YES];
                        AlfrescoPagingResult *pagedResults = [AlfrescoPagingUtils pagedResultFromArray:sortedSites listingContext:listingContext];
                        completionBlock(pagedResults, nil);
                    }
                }
            }];
        }
    }];
     */
    return request;
}

- (AlfrescoRequest *)retrieveSiteWithShortName:(NSString *)siteShortName
                  completionBlock:(AlfrescoSiteCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:siteShortName argumentName:@"siteShortName"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *requestString = [kAlfrescoOnPremiseSitesShortnameAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:siteShortName];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error){
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
    
    __block AlfrescoDocumentFolderService *docService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.session];
    NSString *requestString = [kAlfrescoOnPremiseSiteDoclibAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:siteShortName];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:[self.session.baseUrl absoluteString] extensionURL:requestString];
    __block AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error){
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSString *folderId = nil;
            NSError *conversionError = nil;
            id jsonContainer = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&conversionError];
            if (nil != jsonContainer)
            {
                NSArray *containerArray = [jsonContainer valueForKey:kAlfrescoJSONContainers];
                if ( nil != containerArray && containerArray.count > 0)
                {
                    folderId = [[containerArray objectAtIndex:0] valueForKey:kAlfrescoJSONNodeRef];
                }
                if (nil != folderId)
                {
                    request = [docService retrieveNodeWithIdentifier:folderId completionBlock:^(AlfrescoNode *node, NSError *nodeError){
                        completionBlock((AlfrescoFolder *)node, nodeError);
                        docService = nil;
                    }];
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
    NSString *requestString = [kAlfrescoOnPremiseAddOrRemoveFavoriteSiteAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId
                                                                                                      withString:self.session.personIdentifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    NSData *jsonData = [self jsonDataForFavoriteSites:site.shortName addFavorite:YES];
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
    
    NSString *requestString = [kAlfrescoOnPremiseAddOrRemoveFavoriteSiteAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId
                                                                                                      withString:self.session.personIdentifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    NSData *jsonData = [self jsonDataForFavoriteSites:site.shortName addFavorite:NO];
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
        NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeSitesFailedToJoinSite];
        completionBlock(nil, error);
        return nil;
    }
    
}

- (AlfrescoRequest *)joinPublicSite:(AlfrescoSite *)site completionBlock:(AlfrescoSiteCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:site argumentName:@"site"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    NSString *requestString = [kAlfrescoOnPremiseJoinPublicSiteAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId
                                                                                             withString:site.identifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    NSData *jsonData = [self jsonDataForJoiningPublicSite:self.session.personIdentifier];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session requestBody:jsonData method:kAlfrescoHTTPPOST alfrescoRequest:request completionBlock:^(NSData *data, NSError *error){
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            [self.siteCache addMemberSite:site];
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
    NSString *requestString = [kAlfrescoOnPremiseJoinModeratedSiteAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId
                                                                                                withString:site.identifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    NSData *jsonData = [self jsonDataForJoiningModeratedSite:self.session.personIdentifier comment:nil];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session requestBody:jsonData method:kAlfrescoHTTPPOST alfrescoRequest:request completionBlock:^(NSData *data, NSError *error){
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *jsonError = nil;
            AlfrescoOnPremiseJoinSiteRequest *joinRequest = [self singleJoinRequestFromJSONData:data error:&jsonError];
            if (joinRequest)
            {
                [self.joinRequests addObject:joinRequest];
                AlfrescoSite *pendingSite = [self.siteCache addPendingRequest:joinRequest];
                completionBlock(pendingSite, nil);
            }
            else
            {
                completionBlock(nil, jsonError);
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

- (AlfrescoRequest *)cancelPendingJoinRequestForSite:(AlfrescoSite *)site
                                     completionBlock:(AlfrescoSiteCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:site argumentName:@"joinSiteRequest"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSPredicate *joinPredicate = [NSPredicate predicateWithFormat:@"shortName == %@", site.identifier];
    NSArray *foundRequests = [self.joinRequests filteredArrayUsingPredicate:joinPredicate];
    if (0 == foundRequests)
    {
        NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeSitesNoSites];
        completionBlock(nil, error);
        return nil;
    }
    __block AlfrescoOnPremiseJoinSiteRequest *foundRequest = [foundRequests objectAtIndex:0];
    NSString *requestString = [kAlfrescoOnPremiseCancelJoinRequestsAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId
                                                                                                  withString:site.identifier];
    requestString = [requestString stringByReplacingOccurrencesOfString:kAlfrescoInviteId withString:foundRequest.identifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
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
            [self.siteCache removePendingSite:site];
            [self.joinRequests removeObject:foundRequest];
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
        
    NSString *requestString = [kAlfrescoOnPremiseLeaveSiteAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId
                                                                                        withString:self.session.personIdentifier];
    requestString = [requestString stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:site.identifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session method:kAlfrescoHTTPDelete alfrescoRequest:request completionBlock:^(NSData *data, NSError *error){
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            [self.siteCache removeMemberSite:site];
            completionBlock(site, nil);
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
    
    NSURL *allSitesAPI = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoOnPremiseSiteAPI];
    NSString *favRequestString = [kAlfrescoOnPremiseFavoriteSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId
                                                                                                       withString:self.session.personIdentifier];
    NSURL *favouriteSitesURL = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:favRequestString];
    NSString *siteString = [kAlfrescoOnPremiseSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
    NSURL *mySitesAPI = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:siteString];
    NSString *pendingString = [kAlfrescoOnPremisePendingJoinRequestsAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId
                                                                                                  withString:self.session.personIdentifier];
    NSURL *pendingSitesAPI = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:pendingString];
    
    [self.session.networkProvider executeRequestWithURL:allSitesAPI session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error){
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *siteArray = [self siteArrayFromJSONData:data error:&conversionError];
            if (siteArray)
            {
                NSArray *allSortedArray = [AlfrescoSortingUtils sortedArrayForArray:siteArray sortKey:self.defaultSortKey ascending:YES];
                [self.session.networkProvider executeRequestWithURL:favouriteSitesURL session:self.session alfrescoRequest:request completionBlock:^(NSData *favData, NSError *favError){
                    if(favData)
                    {
                        NSError *conversionError = nil;
                        NSArray *favSitesArray = [self favoriteSitesArrayFromJSONData:favData error:&conversionError];
                        if (nil != favSitesArray)
                        {
                            NSPredicate *favoritePredicate = [NSPredicate predicateWithFormat:@"shortName IN %@",favSitesArray];
                            NSArray *favoriteSites = [siteArray filteredArrayUsingPredicate:favoritePredicate];
                            [self.siteCache addFavoriteSites:favoriteSites];
                            [self.session.networkProvider executeRequestWithURL:mySitesAPI session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *myError){
                                if (nil == data)
                                {
                                    completionBlock(nil, myError);
                                }
                                else
                                {
                                    NSError *conversionError = nil;
                                    NSArray *mySiteArray = [self siteArrayFromJSONData:data error:&conversionError];
                                    if (mySiteArray)
                                    {
                                        NSArray *mySortedSiteArray = [AlfrescoSortingUtils sortedArrayForArray:mySiteArray sortKey:self.defaultSortKey ascending:YES];
                                        [self.siteCache addMemberSites:mySortedSiteArray];
                                        [self.session.networkProvider executeRequestWithURL:pendingSitesAPI session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *pendingError){
                                            if (nil == data)
                                            {
                                                completionBlock(nil, pendingError);
                                            }
                                            else
                                            {
                                                NSError *jsonError = nil;
                                                NSArray *requests = [self joinRequestArrayFromJSONData:data error:&jsonError];
                                                if (requests)
                                                {
                                                    [self.siteCache addPendingRequests:requests];
                                                    NSArray *pendingSites = [self.siteCache pendingMemberSites];
                                                    switch (type)
                                                    {
                                                        case AlfrescoSiteAll:
                                                            resultsArray = allSortedArray;
                                                            break;
                                                        case AlfrescoSiteFavorite:
                                                            resultsArray = favoriteSites;
                                                            break;
                                                        case AlfrescoSiteMember:
                                                            resultsArray = mySortedSiteArray;
                                                            break;
                                                        case AlfrescoSitePendingMember:
                                                            resultsArray = pendingSites;
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
                    else
                    {
                        completionBlock(nil, favError);
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
    
    NSURL *allSitesAPI = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoOnPremiseSiteAPI];
    NSString *favRequestString = [kAlfrescoOnPremiseFavoriteSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId
                                                                                                       withString:self.session.personIdentifier];
    NSURL *favouriteSitesURL = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:favRequestString];
    NSString *siteString = [kAlfrescoOnPremiseSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
    NSURL *mySitesAPI = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:siteString];
    NSString *pendingString = [kAlfrescoOnPremisePendingJoinRequestsAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId
                                                                                                  withString:self.session.personIdentifier];
    NSURL *pendingSitesAPI = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:pendingString];
    
    [self.session.networkProvider executeRequestWithURL:allSitesAPI session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error){
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *siteArray = [self siteArrayFromJSONData:data error:&conversionError];
            if (siteArray)
            {
                NSArray *allSortedArray = [AlfrescoSortingUtils sortedArrayForArray:siteArray sortKey:self.defaultSortKey ascending:YES];
                [self.session.networkProvider executeRequestWithURL:favouriteSitesURL session:self.session alfrescoRequest:request completionBlock:^(NSData *favData, NSError *favError){
                    if(favData)
                    {
                        NSError *conversionError = nil;
                        NSArray *favSitesArray = [self favoriteSitesArrayFromJSONData:favData error:&conversionError];
                        if (nil != favSitesArray)
                        {
                            NSPredicate *favoritePredicate = [NSPredicate predicateWithFormat:@"shortName IN %@",favSitesArray];
                            NSArray *favoriteSites = [siteArray filteredArrayUsingPredicate:favoritePredicate];
                            [self.siteCache addFavoriteSites:favoriteSites];
                            [self.session.networkProvider executeRequestWithURL:mySitesAPI session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *myError){
                                if (nil == data)
                                {
                                    completionBlock(nil, myError);
                                }
                                else
                                {
                                    NSError *conversionError = nil;
                                    NSArray *mySiteArray = [self siteArrayFromJSONData:data error:&conversionError];
                                    if (mySiteArray)
                                    {
                                        NSArray *mySortedSiteArray = [AlfrescoSortingUtils sortedArrayForArray:mySiteArray sortKey:self.defaultSortKey ascending:YES];
                                        [self.siteCache addMemberSites:mySortedSiteArray];
                                        [self.session.networkProvider executeRequestWithURL:pendingSitesAPI session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *pendingError){
                                            if (nil == data)
                                            {
                                                completionBlock(nil, pendingError);
                                            }
                                            else
                                            {
                                                NSError *jsonError = nil;
                                                NSArray *requests = [self joinRequestArrayFromJSONData:data error:&jsonError];
                                                if (requests)
                                                {
                                                    [self.siteCache addPendingRequests:requests];
                                                    NSArray *pendingSites = [self.siteCache pendingMemberSites];
                                                    switch (type)
                                                    {
                                                        case AlfrescoSiteAll:
                                                            resultsArray = allSortedArray;
                                                            break;
                                                        case AlfrescoSiteFavorite:
                                                            resultsArray = favoriteSites;
                                                            break;
                                                        case AlfrescoSiteMember:
                                                            resultsArray = mySortedSiteArray;
                                                            break;
                                                        case AlfrescoSitePendingMember:
                                                            resultsArray = pendingSites;
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
                    else
                    {
                        completionBlock(nil, favError);
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


- (AlfrescoOnPremiseJoinSiteRequest *)singleJoinRequestFromJSONData:(NSData *)data error:(NSError **)outError
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
    if (![[jsonDict allKeys] containsObject:kAlfrescoJSONData])
    {
        NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        return nil;
    }
    
    id dataObj = [jsonDict objectForKey:kAlfrescoJSONData];
    if (![dataObj isKindOfClass:[NSDictionary class]])
    {
        NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        return nil;
    }
    else
    {
        return [[AlfrescoOnPremiseJoinSiteRequest alloc] initWithProperties:(NSDictionary *)dataObj];
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
    if (![[jsonDict allKeys] containsObject:kAlfrescoJSONData])
    {
        NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        return nil;
    }
    
    id dataObj = [jsonDict objectForKey:kAlfrescoJSONData];
    if (![dataObj isKindOfClass:[NSArray class]])
    {
        NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        return nil;
    }
    NSMutableArray *allRequests = [NSMutableArray array];
    for (id requestObj in (NSArray *)dataObj)
    {
        [allRequests addObject:[[AlfrescoOnPremiseJoinSiteRequest alloc] initWithProperties:requestObj]];
    }
    return allRequests;    
}


- (NSArray *) siteArrayFromJSONData:(NSData *)data error:(NSError **)outError
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
    id jsonSiteArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(error)
    {
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeSites];
        return nil;
    }
    if ([jsonSiteArray isKindOfClass:[NSArray class]] == NO)
    {
        if([jsonSiteArray isKindOfClass:[NSDictionary class]] == YES && [[jsonSiteArray valueForKeyPath:@"status.code"] isEqualToNumber:[NSNumber numberWithInt:404]])
        {
            // no results found
            return [NSArray array];
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
        [resultArray addObject:[[AlfrescoSite alloc] initWithProperties:siteDict]];
    }
    return resultArray;
}

- (AlfrescoSite *) alfrescoSiteFromJSONData:(NSData *)data error:(NSError **)outError
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
    id jsonSite = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(error)
    {
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeSites];
        return nil;
    }
    if ([jsonSite isKindOfClass:[NSDictionary class]] == NO)
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
    if([[jsonSite valueForKeyPath:kAlfrescoJSONStatusCode] isEqualToNumber:[NSNumber numberWithInt:404]])
    {
        //empty/non existent site - should this happen? error message?
        return nil;
    }
    return [[AlfrescoSite alloc] initWithProperties:jsonSite];
}

- (NSArray *) favoriteSitesArrayFromJSONData:(NSData *)data error:(NSError **)outError
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
    id favoriteSitesObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(error)
    {
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeSites];
        return nil;
    }
    if ([favoriteSitesObject isKindOfClass:[NSDictionary class]] == NO)
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

    id favouriteSitesObj = [favouriteSitesDictionary valueForKeyPath:kAlfrescoOnPremiseFavoriteSites];
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
    NSDictionary *personDict = [NSDictionary dictionaryWithObject:personId forKey:kAlfrescoJSONUserName];
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjects:@[kAlfrescoSiteConsumer,personDict] forKeys:@[kAlfrescoJSONRole, kAlfrescoJSONPerson]];
    NSError *error = nil;
    return [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
}

- (NSData *)jsonDataForJoiningModeratedSite:(NSString *)personId comment:(NSString *)comment
{
    if (nil == comment)
    {
        comment = @"";
    }
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjects:@[kAlfrescoModerated, personId, comment, kAlfrescoSiteConsumer ]
                                                         forKeys:@[kAlfrescoJSONInvitationType, kAlfrescoJSONInviteeUsername, kAlfrescoJSONInviteeComments, kAlfrescoJSONInviteeRolename]];
    NSError *error = nil;
    return [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
}

- (NSData *)jsonDataForFavoriteSites:(NSString *)siteId addFavorite:(BOOL)addFavorite
{
    NSDictionary *favorite = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:addFavorite]
                                                                                            forKey:siteId] forKey:kAlfrescoJSONFavorites];
    NSDictionary *sites = [NSDictionary dictionaryWithObject:favorite forKey:kAlfrescoJSONSites];
    NSDictionary *share = [NSDictionary dictionaryWithObject:sites forKey:kAlfrescoJSONShare];
    NSDictionary *alfresco = [NSDictionary dictionaryWithObject:share forKey:kAlfrescoJSONAlfresco];
    
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObject:alfresco forKey:kAlfrescoJSONOrg];
    NSError *error = nil;
    return [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
}


@end
