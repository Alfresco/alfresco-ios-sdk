/*******************************************************************************
 * Copyright (C) 2005-2012 Alfresco Software Limited.
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
#import "AlfrescoHTTPUtils.h"
#import "AlfrescoPagingUtils.h"
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoBasicAuthenticationProvider.h"
#import "AlfrescoDocumentFolderService.h"
#import "AlfrescoSortingUtils.h"

@interface AlfrescoOnPremiseSiteService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, strong, readwrite) AlfrescoObjectConverter *objectConverter;
@property (nonatomic, weak, readwrite) id<AlfrescoAuthenticationProvider> authenticationProvider;
@property (nonatomic, strong, readwrite) NSArray *supportedSortKeys;
@property (nonatomic, strong, readwrite) NSString *defaultSortKey;
- (NSArray *) siteArrayFromJSONData:(NSData *)data error:(NSError **)outError;
- (AlfrescoSite *) alfrescoSiteFromJSONData:(NSData *)data error:(NSError **)outError;
- (NSArray *) favoriteSitesArrayFromJSONData:(NSData *)data error:(NSError **)outError;
@end

@implementation AlfrescoOnPremiseSiteService
@synthesize baseApiUrl = _baseApiUrl;
@synthesize session = _session;
@synthesize objectConverter = _objectConverter;
@synthesize authenticationProvider = _authenticationProvider;
@synthesize defaultSortKey = _defaultSortKey;
@synthesize supportedSortKeys = _supportedSortKeys;

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
    }
    return self;
}


- (void)retrieveAllSitesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    __weak AlfrescoOnPremiseSiteService *weakSelf = self;
    NSURL *url = [AlfrescoHTTPUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoOnPremiseSiteAPI];
    [AlfrescoHTTPUtils executeRequestWithURL:url session:self.session completionBlock:^(NSData *data, NSError *error){
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *siteArray = [weakSelf siteArrayFromJSONData:data error:&conversionError];
            NSArray *sortedArray = [AlfrescoSortingUtils sortedArrayForArray:siteArray sortKey:self.defaultSortKey ascending:YES];
            completionBlock(sortedArray, conversionError);
        }
    }];
    /*
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *error = nil;
        NSData *data = [AlfrescoHTTPUtils executeRequest:kAlfrescoOnPremiseSiteAPI
                                         baseUrlAsString:weakSelf.baseApiUrl
                                                 session:weakSelf.session
                                                   error:&error];
        
        __block NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        
        NSArray *sortedSiteArray = nil;
        if(nil != data)
        {
            NSArray *siteArray = [weakSelf siteArrayFromJSONData:data error:&error];
            sortedSiteArray = [AlfrescoSortingUtils sortedArrayForArray:siteArray sortKey:self.defaultSortKey ascending:YES];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            log(@"JSON data %@", jsonString);
            
            completionBlock(sortedSiteArray, error);
        }];
    }];
     */
}

- (void)retrieveAllSitesWithListingContext:(AlfrescoListingContext *)listingContext
                           completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    
    __weak AlfrescoOnPremiseSiteService *weakSelf = self;
    NSURL *url = [AlfrescoHTTPUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoOnPremiseSiteAPI];
    [AlfrescoHTTPUtils executeRequestWithURL:url session:self.session completionBlock:^(NSData *data, NSError *error){
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *siteArray = [weakSelf siteArrayFromJSONData:data error:&conversionError];
            NSArray *sortedArray = [AlfrescoSortingUtils sortedArrayForArray:siteArray sortKey:self.defaultSortKey ascending:YES];
            AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedArray listingContext:listingContext];
            completionBlock(pagingResult, conversionError);
        }
    }];
    /*
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *error = nil;
        
        NSData *data = [AlfrescoHTTPUtils executeRequest:kAlfrescoOnPremiseSiteAPI
                                         baseUrlAsString:weakSelf.baseApiUrl
                                                 session:weakSelf.session
                                                   error:&error];
        NSArray *siteArray = nil;
        AlfrescoPagingResult *pagingResult = nil;
        if(nil != data)
        {
            siteArray = [weakSelf siteArrayFromJSONData:data error:&error];
            if (nil != siteArray)
            {
                NSArray *sortedSiteArray = [AlfrescoSortingUtils sortedArrayForArray:siteArray
                                                                             sortKey:listingContext.sortProperty
                                                                       supportedKeys:self.supportedSortKeys
                                                                          defaultKey:self.defaultSortKey
                                                                           ascending:listingContext.sortAscending];
                pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedSiteArray listingContext:listingContext];
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(pagingResult, error);
        }];
    }];
     */
}

- (void)retrieveSitesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    __weak AlfrescoOnPremiseSiteService *weakSelf = self;
    NSString *siteString = [kAlfrescoOnPremiseSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
    NSURL *url = [AlfrescoHTTPUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:siteString];
    [AlfrescoHTTPUtils executeRequestWithURL:url session:self.session completionBlock:^(NSData *data, NSError *error){
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *siteArray = [weakSelf siteArrayFromJSONData:data error:&conversionError];
            NSArray *sortedSiteArray = [AlfrescoSortingUtils sortedArrayForArray:siteArray sortKey:self.defaultSortKey ascending:YES];
            completionBlock(sortedSiteArray, conversionError);
        }
    }];
    /*
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *requestString = [kAlfrescoOnPremiseSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                         baseUrlAsString:weakSelf.baseApiUrl
                                                 session:weakSelf.session
                                                   error:&operationQueueError];
        
        NSArray *sortedSiteArray = nil;
        if(nil != data)
        {
            NSArray *siteArray = [weakSelf siteArrayFromJSONData:data error:&operationQueueError];
            sortedSiteArray = [AlfrescoSortingUtils sortedArrayForArray:siteArray sortKey:self.defaultSortKey ascending:YES];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(sortedSiteArray, operationQueueError);
        }];
    }];
     */
}

- (void)retrieveSitesWithListingContext:(AlfrescoListingContext *)listingContext
                        completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    __weak AlfrescoOnPremiseSiteService *weakSelf = self;
    NSString *personString = [kAlfrescoOnPremiseSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
    NSURL *url = [AlfrescoHTTPUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:personString];
    [AlfrescoHTTPUtils executeRequestWithURL:url session:self.session completionBlock:^(NSData *data, NSError *error){
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *siteArray = [weakSelf siteArrayFromJSONData:data error:&conversionError];
            NSArray *sortedSiteArray = [AlfrescoSortingUtils sortedArrayForArray:siteArray sortKey:self.defaultSortKey ascending:YES];
            AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedSiteArray listingContext:listingContext];
            completionBlock(pagingResult, conversionError);
        }
    }];
    /*
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        
        // pos parameter is not working, so paging is done in-memory
        NSString *requestString = [kAlfrescoOnPremiseSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                         baseUrlAsString:weakSelf.baseApiUrl
                                                 session:weakSelf.session
                                                   error:&operationQueueError];
        
        NSArray *siteArray = nil;
        AlfrescoPagingResult *pagingResult = nil;
        if(nil != data)
        {
            siteArray = [weakSelf siteArrayFromJSONData:data error:&operationQueueError];
            if (nil != siteArray)
            {
                NSArray *sortedSiteArray = [AlfrescoSortingUtils sortedArrayForArray:siteArray
                                                                             sortKey:listingContext.sortProperty
                                                                       supportedKeys:self.supportedSortKeys
                                                                          defaultKey:self.defaultSortKey
                                                                           ascending:listingContext.sortAscending];
                pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedSiteArray listingContext:listingContext];
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(pagingResult, operationQueueError);
        }];
    }];
     */
}


- (void)retrieveFavoriteSitesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    __weak AlfrescoOnPremiseSiteService *weakSelf = self;
    NSString *favRequestString = [kAlfrescoOnPremiseFavoriteSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
    NSString *allRequestString = [kAlfrescoOnPremiseSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];

    NSURL *allSitesURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.baseApiUrl, allRequestString]];
    NSURL *favouriteSitesURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.baseApiUrl, favRequestString]];
    [AlfrescoHTTPUtils executeRequestWithURL:allSitesURL session:self.session completionBlock:^(NSData *data, NSError *allSitesError){
        if (nil == data)
        {
            completionBlock(nil, allSitesError);
        }
        else
        {
            [AlfrescoHTTPUtils executeRequestWithURL:favouriteSitesURL session:weakSelf.session completionBlock:^(NSData *favData, NSError *favError){
                if (nil == favData)
                {
                    completionBlock(nil, favError);
                }
                else
                {
                    NSError *conversionError = nil;
                    NSArray *allSitesArray = [weakSelf siteArrayFromJSONData:data error:&conversionError];
                    NSArray *favSitesArray = [weakSelf siteArrayFromJSONData:favData error:&conversionError];
                    if (nil == favSitesArray || nil == allSitesArray)
                    {
                        completionBlock(nil, conversionError);
                    }
                    else
                    {
                        NSMutableArray *sites = [NSMutableArray array];
                        for (AlfrescoSite *site in allSitesArray)
                        {
                            if ([favSitesArray containsObject:site.shortName])
                            {
                                [sites addObject:site];
                            }
                        }
                        NSArray *sortedSites = [AlfrescoSortingUtils sortedArrayForArray:sites sortKey:weakSelf.defaultSortKey ascending:YES];
                        completionBlock(sortedSites, nil);
                    }
                }
            }];
        }
    }];
    /*
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *favRequestString = [kAlfrescoOnPremiseFavoriteSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
        NSString *allRequestString = [kAlfrescoOnPremiseSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
        NSData *favoriteSitesdata = [AlfrescoHTTPUtils executeRequest:favRequestString
                                                      baseUrlAsString:weakSelf.baseApiUrl
                                                              session:weakSelf.session
                                                                error:&operationQueueError];
        NSData *allSitesData = [AlfrescoHTTPUtils executeRequest:allRequestString
                                                 baseUrlAsString:weakSelf.baseApiUrl
                                                         session:weakSelf.session
                                                           error:&operationQueueError];
        
        
        NSArray *sortedSiteArray = nil;
        NSArray *allSitesArray = nil;
        NSArray *favoriteSitesArray = nil;
        if(nil != allSitesData)
        {
            allSitesArray = [weakSelf siteArrayFromJSONData:allSitesData error:&operationQueueError];
        }
        if (nil != favoriteSitesdata)
        {
            favoriteSitesArray = [weakSelf favoriteSitesArrayFromJSONData:favoriteSitesdata error:&operationQueueError];
        }
        if (nil != favoriteSitesArray && nil != allSitesArray)
        {
            NSMutableArray *siteResultArray = [NSMutableArray arrayWithCapacity:[favoriteSitesArray count]];
            for (AlfrescoSite *site in allSitesArray) {
                if([favoriteSitesArray containsObject:site.shortName] == YES)
                {
                    [siteResultArray addObject:site];
                }
            }
            sortedSiteArray = [AlfrescoSortingUtils sortedArrayForArray:siteResultArray sortKey:self.defaultSortKey ascending:YES];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(sortedSiteArray, operationQueueError);
        }];
        
    }];
     */
}

- (void)retrieveFavoriteSitesWithListingContext:(AlfrescoListingContext *)listingContext
                                completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    __weak AlfrescoOnPremiseSiteService *weakSelf = self;
    NSString *favRequestString = [kAlfrescoOnPremiseFavoriteSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
    NSString *allRequestString = [kAlfrescoOnPremiseSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
    NSURL *allSitesURL = [AlfrescoHTTPUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:allRequestString];
    NSURL *favouriteSitesURL = [AlfrescoHTTPUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:favRequestString];
    
    [AlfrescoHTTPUtils executeRequestWithURL:allSitesURL session:self.session completionBlock:^(NSData *data, NSError *allSitesError){
        if (nil == data)
        {
            completionBlock(nil, allSitesError);
        }
        else
        {
            [AlfrescoHTTPUtils executeRequestWithURL:favouriteSitesURL session:weakSelf.session completionBlock:^(NSData *favData, NSError *favError){
                if (nil == favData)
                {
                    completionBlock(nil, favError);
                }
                else
                {
                    NSError *conversionError = nil;
                    NSArray *allSitesArray = [weakSelf siteArrayFromJSONData:data error:&conversionError];
                    NSArray *favSitesArray = [weakSelf siteArrayFromJSONData:favData error:&conversionError];
                    if (nil == favSitesArray || nil == allSitesArray)
                    {
                        completionBlock(nil, conversionError);
                    }
                    else
                    {
                        NSMutableArray *sites = [NSMutableArray array];
                        for (AlfrescoSite *site in allSitesArray)
                        {
                            if ([favSitesArray containsObject:site.shortName])
                            {
                                [sites addObject:site];
                            }
                        }
                        NSArray *sortedSites = [AlfrescoSortingUtils sortedArrayForArray:sites sortKey:weakSelf.defaultSortKey ascending:YES];
                        AlfrescoPagingResult *pagedResults = [AlfrescoPagingUtils pagedResultFromArray:sortedSites listingContext:listingContext];
                        
                        completionBlock(pagedResults, nil);
                    }
                }
            }];
        }
    }];
    /*
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        
        NSString *favRequestString = [kAlfrescoOnPremiseFavoriteSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
        NSString *allRequestString = [kAlfrescoOnPremiseSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
        NSData *favoriteSitesdata = [AlfrescoHTTPUtils executeRequest:favRequestString
                                                      baseUrlAsString:weakSelf.baseApiUrl
                                                              session:weakSelf.session
                                                                error:&operationQueueError];
        NSData *allSitesData = [AlfrescoHTTPUtils executeRequest:allRequestString
                                                 baseUrlAsString:weakSelf.baseApiUrl
                                                         session:weakSelf.session
                                                           error:&operationQueueError];
        
        AlfrescoPagingResult *pagingResult = nil;
        NSArray *allSitesArray = nil;
        NSArray *favoriteSitesArray = nil;
        if(nil != allSitesData)
        {
            allSitesArray = [weakSelf siteArrayFromJSONData:allSitesData error:&operationQueueError];
        }
        if (nil != favoriteSitesdata)
        {
            favoriteSitesArray = [weakSelf favoriteSitesArrayFromJSONData:favoriteSitesdata error:&operationQueueError];
        }
        if (nil != favoriteSitesArray && nil != allSitesArray)
        {
            NSMutableArray *siteResultArray = [NSMutableArray array];
            int totalItems = 0;
            int totalItemsAdded = 0;
            for (AlfrescoSite *site in allSitesArray) {
                if([favoriteSitesArray containsObject:site.shortName] == YES)
                {
                    totalItems = totalItems + 1;
                    if (listingContext.skipCount == 0 || listingContext.skipCount < totalItems)
                    {
                        totalItemsAdded = totalItemsAdded + 1;
                        if (listingContext.maxItems >= totalItemsAdded)
                        {
                            [siteResultArray addObject:site];
                        }
                    }
                }
            }
            NSArray *sortedSiteArray = [AlfrescoSortingUtils sortedArrayForArray:siteResultArray
                                                                         sortKey:listingContext.sortProperty
                                                                   supportedKeys:self.supportedSortKeys
                                                                      defaultKey:self.defaultSortKey
                                                                       ascending:listingContext.sortAscending];
            
            BOOL hasMore = NO;
            if(siteResultArray.count + listingContext.skipCount < totalItems)
            {
                hasMore = YES;
            }
            pagingResult = [[AlfrescoPagingResult alloc] initWithArray:sortedSiteArray hasMoreItems:hasMore totalItems:totalItems];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(pagingResult, operationQueueError);
        }];
    }];
     */
}

- (void)retrieveSiteWithShortName:(NSString *)siteShortName
                  completionBlock:(AlfrescoSiteCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:siteShortName argumentName:@"siteShortName"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    __weak AlfrescoOnPremiseSiteService *weakSelf = self;
    NSString *requestString = [kAlfrescoOnPremiseSitesShortnameAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:siteShortName];
    NSURL *url = [AlfrescoHTTPUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    [AlfrescoHTTPUtils executeRequestWithURL:url session:self.session completionBlock:^(NSData *data, NSError *error){
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            AlfrescoSite *site = [weakSelf alfrescoSiteFromJSONData:data error:&conversionError];
            completionBlock(site, conversionError);
        }
    }];
    /*
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *requestString = [kAlfrescoOnPremiseSitesShortnameAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:siteShortName];
        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                         baseUrlAsString:weakSelf.baseApiUrl
                                                 session:weakSelf.session
                                                   error:&operationQueueError];
        AlfrescoSite *site = nil;
        if(nil != data)
        {
            site = [weakSelf alfrescoSiteFromJSONData:data error:&operationQueueError];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(site, operationQueueError);
        }];
    }];
     */
}


- (void)retrieveDocumentLibraryFolderForSite:(NSString *)siteShortName
                             completionBlock:(AlfrescoFolderCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:siteShortName argumentName:@"siteShortName"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    __block AlfrescoDocumentFolderService *docService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.session];
    NSString *requestString = [kAlfrescoOnPremiseSiteDoclibAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:siteShortName];
    NSURL *url = [AlfrescoHTTPUtils buildURLFromBaseURLString:[self.session.baseUrl absoluteString] extensionURL:requestString];
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",
//                                       self.session.baseUrl, requestString]];
    [AlfrescoHTTPUtils executeRequestWithURL:url session:self.session completionBlock:^(NSData *data, NSError *error){
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
                    [docService retrieveNodeWithIdentifier:folderId completionBlock:^(AlfrescoNode *node, NSError *nodeError){
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
    /*
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *requestString = [kAlfrescoOnPremiseSiteDoclibAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:siteShortName];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",
                                           self.session.baseUrl, requestString]];
        NSData *data = [AlfrescoHTTPUtils executeRequestWithURL:url
                                                        session:weakSelf.session
                                                           data:nil
                                                     httpMethod:@"GET"
                                                          error:&operationQueueError];
        NSString *folderId = nil;
        if (nil != data)
        {
            id jsonContainer = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&operationQueueError];
            if (nil != jsonContainer)
            {
                NSArray *containerArray = [jsonContainer valueForKey:kAlfrescoJSONContainers];
                if ( nil != containerArray && containerArray.count > 0)
                {
                    folderId = [[containerArray objectAtIndex:0] valueForKey:kAlfrescoJSONNodeRef];
                }
            }
        }
        
        if (nil != folderId)
        {
            __block AlfrescoDocumentFolderService *docService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.session];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [docService retrieveNodeWithIdentifier:folderId
                                       completionBlock:^(AlfrescoNode *node, NSError *error)
                 {
                     completionBlock((AlfrescoFolder *)node, error);
                     docService = nil;
                 }];
            }];
        }
        else
        {
            if(nil == operationQueueError)
            {
                operationQueueError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeSitesNoDocLib];
            }
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(nil, operationQueueError);
            }];
        }
    }];
     */
}


#pragma mark Site service internal methods
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
    log(@"JSON data: %@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
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


@end
