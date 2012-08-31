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

#import "AlfrescoCloudSiteService.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoBasicAuthenticationProvider.h"
#import "AlfrescoErrors.h"
#import "AlfrescoHTTPUtils.h"
#import "AlfrescoSortingUtils.h"
#import "AlfrescoPagingUtils.h"
#import "AlfrescoDocumentFolderService.h"
#import <objc/runtime.h>


@interface AlfrescoCloudSiteService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, strong, readwrite) NSOperationQueue *operationQueue;
@property (nonatomic, weak, readwrite) id<AlfrescoAuthenticationProvider> authenticationProvider;
@property (nonatomic, strong, readwrite) NSArray *supportedSortKeys;
@property (nonatomic, strong, readwrite) NSString *defaultSortKey;
- (NSArray *) parseSiteArrayWithData:(NSData *)data error:(NSError **)outError;
- (NSArray *) parseSpecifiedSiteArrayWithData:(NSData *)data error:(NSError **)outError;
- (AlfrescoSite *) parseSiteWithData:(NSData *)data error:(NSError **)outError;
- (NSDictionary *)parseFolderIdWithData:(NSData *)data error:(NSError **)outError;
- (AlfrescoSite *)siteFromJSON:(NSDictionary *)siteDict;

@end

@implementation AlfrescoCloudSiteService
@synthesize baseApiUrl = _baseApiUrl;
@synthesize session = _session;
@synthesize operationQueue = _operationQueue;
@synthesize authenticationProvider = _authenticationProvider;
@synthesize supportedSortKeys = _supportedSortKeys;
@synthesize defaultSortKey = _defaultSortKey;
- (id)initWithSession:(id<AlfrescoSession>)session
{
    if (self = [super init])
    {
        self.session = session;
        self.baseApiUrl = [[self.session.baseUrl absoluteString] stringByAppendingString:kAlfrescoCloudAPIPath];
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 2;
        id authenticationObject = objc_getAssociatedObject(self.session, &kAlfrescoAuthenticationProviderObjectKey);
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

- (AlfrescoSite *)siteFromJSON:(NSDictionary *)siteDict
{
    AlfrescoSite *alfSite = [[AlfrescoSite alloc] init];
    
    alfSite.shortName = [siteDict valueForKey:kAlfrescoJSONIdentifier];
    alfSite.summary = [siteDict valueForKey:kAlfrescoJSONDescription];
    alfSite.title = [siteDict valueForKey:kAlfrescoJSONTitle];
    NSString *visibility = [siteDict valueForKey:kAlfrescoJSONVisibility];
    if ([visibility isEqualToString:kAlfrescoJSONVisibilityPUBLIC])
    {
        alfSite.visibility = AlfrescoSiteVisibilityPublic;
    }
    else if ([visibility isEqualToString:kAlfrescoJSONVisibilityPRIVATE])
    {
        alfSite.visibility = AlfrescoSiteVisibilityPrivate;
    }
    else if ([visibility isEqualToString:kAlfrescoJSONVisibilityMODERATED])
    {
        alfSite.visibility = AlfrescoSiteVisibilityModerated;
    }
    
    return alfSite;
}

- (void)retrieveAllSitesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    NSAssert(nil != completionBlock, @"RetrieveAllSitesWithCompletionBlock: the completion block must not be nil");
    NSAssert(nil != self.authenticationProvider, @"RetrieveAllSitesWithCompletionBlock: the service must have a valid authentication provider");
    
    __weak AlfrescoCloudSiteService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *error = nil;
        NSData *data = [AlfrescoHTTPUtils executeRequest:kAlfrescoCloudSiteAPI
                                         baseUrlAsString:weakSelf.baseApiUrl
                                  authenticationProvider:weakSelf.authenticationProvider
                                                   error:&error];

        __block NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        
        
        NSArray *sortedSiteArray = nil;
        if(nil != data)
        {
            NSArray *siteArray = [weakSelf parseSiteArrayWithData:data error:&error];
            if (nil != siteArray)
            {
                sortedSiteArray = [AlfrescoSortingUtils sortedArrayForArray:siteArray sortKey:self.defaultSortKey ascending:YES];
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            log(@"JSON data %@", jsonString);
            completionBlock(sortedSiteArray, error);
        }];
    }];
}

- (void)retrieveAllSitesWithListingContext:(AlfrescoListingContext *)listingContext
                           completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    NSAssert(nil != completionBlock, @"RetrieveAllSitesWithCompletionBlock: the completion block must not be nil");
    NSAssert(nil != listingContext, @"RetrieveAllSitesWithCompletionBlock: the listingContext must not be nil");
    NSAssert(nil != self.authenticationProvider, @"RetrieveAllSitesWithCompletionBlock: the service must have a valid authentication provider");
    
    
    __weak AlfrescoCloudSiteService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *error = nil;
        
        // pos parameter is not working, so paging is done in-memory
        NSData *data = [AlfrescoHTTPUtils executeRequest:kAlfrescoCloudSiteAPI
                                         baseUrlAsString:weakSelf.baseApiUrl
                                  authenticationProvider:weakSelf.authenticationProvider
                                                   error:&error];
        NSArray *siteArray = nil;
        AlfrescoPagingResult *pagingResult = nil;
        if(nil != data)
        {
            siteArray = [weakSelf parseSiteArrayWithData:data error:&error];
            if (nil != siteArray)
            {
                NSArray *sortedSiteArray = [AlfrescoSortingUtils sortedArrayForArray:siteArray sortKey:listingContext.sortProperty supportedKeys:self.supportedSortKeys defaultKey:self.defaultSortKey ascending:listingContext.sortAscending];
                pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedSiteArray listingContext:listingContext];
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(pagingResult, error);
        }];
    }];
}

- (void)retrieveSitesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    NSAssert(nil != completionBlock, @"RetrieveAllSitesWithCompletionBlock: the completion block must not be nil");
    NSAssert(nil != self.authenticationProvider, @"RetrieveAllSitesWithCompletionBlock: the service must have a valid authentication provider");
    
    __weak AlfrescoCloudSiteService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *requestString = [kAlfrescoCloudSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:weakSelf.session.personIdentifier];
        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                         baseUrlAsString:weakSelf.baseApiUrl
                                  authenticationProvider:weakSelf.authenticationProvider
                                                   error:&operationQueueError];
        
        NSArray *sortedSiteArray = nil;
        if(nil != data)
        {
            NSArray *siteArray = [weakSelf parseSpecifiedSiteArrayWithData:data error:&operationQueueError];
            if (nil != siteArray)
            {
                sortedSiteArray = [AlfrescoSortingUtils sortedArrayForArray:siteArray sortKey:self.defaultSortKey ascending:YES];
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(sortedSiteArray, operationQueueError);
        }];
    }];
}

- (void)retrieveSitesWithListingContext:(AlfrescoListingContext *)listingContext
                        completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    NSAssert(nil != completionBlock, @"RetrieveAllSitesWithCompletionBlock: the completion block must not be nil");
    NSAssert(nil != listingContext, @"RetrieveAllSitesWithCompletionBlock: the listingContext must not be nil");
    NSAssert(nil != self.authenticationProvider, @"RetrieveAllSitesWithCompletionBlock: the service must have a valid authentication provider");
    
    __weak AlfrescoCloudSiteService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        
        // pos parameter is not working, so paging is done in-memory
        NSString *requestString = [kAlfrescoCloudSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:weakSelf.session.personIdentifier];
        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                         baseUrlAsString:weakSelf.baseApiUrl
                                  authenticationProvider:weakSelf.authenticationProvider
                                                   error:&operationQueueError];
        
        NSArray *siteArray = nil;
        AlfrescoPagingResult *pagingResult = nil;
        if(nil != data)
        {
            siteArray = [weakSelf parseSpecifiedSiteArrayWithData:data error:&operationQueueError];
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
}

- (void)retrieveFavoriteSitesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    NSAssert(nil != completionBlock, @"RetrieveAllSitesWithCompletionBlock: the completion block must not be nil");
    NSAssert(nil != self.authenticationProvider, @"RetrieveAllSitesWithCompletionBlock: the service must have a valid authentication provider");
    
    __weak AlfrescoCloudSiteService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *requestString = [kAlfrescoCloudFavoriteSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:weakSelf.session.personIdentifier];        
        NSData *favoriteSitesdata = [AlfrescoHTTPUtils executeRequest:requestString
                                                      baseUrlAsString:weakSelf.baseApiUrl
                                               authenticationProvider:weakSelf.authenticationProvider
                                                                error:&operationQueueError];
                
        NSArray *sortedSiteArray = nil;
        NSArray *favoriteSitesArray = nil;
        if (nil != favoriteSitesdata)
        {
            favoriteSitesArray = [weakSelf parseSiteArrayWithData:favoriteSitesdata error:&operationQueueError];
        }
        if (nil != favoriteSitesArray)
        {
            sortedSiteArray = [AlfrescoSortingUtils sortedArrayForArray:favoriteSitesArray sortKey:self.defaultSortKey ascending:YES];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(sortedSiteArray, operationQueueError);
        }];
        
    }];
}

- (void)retrieveFavoriteSitesWithListingContext:(AlfrescoListingContext *)listingContext
                                completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    NSAssert(nil != completionBlock, @"RetrieveAllSitesWithCompletionBlock: the completion block must not be nil");
    NSAssert(nil != listingContext, @"RetrieveAllSitesWithCompletionBlock: the listingContext must not be nil");
    NSAssert(nil != self.authenticationProvider, @"RetrieveAllSitesWithCompletionBlock: the service must have a valid authentication provider");
    
    __weak AlfrescoCloudSiteService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        
        NSString *requestString = [kAlfrescoCloudFavoriteSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:weakSelf.session.personIdentifier];
        NSData *favoriteSitesdata = [AlfrescoHTTPUtils executeRequest:requestString
                                                      baseUrlAsString:weakSelf.baseApiUrl
                                               authenticationProvider:weakSelf.authenticationProvider
                                                                error:&operationQueueError];
        
        AlfrescoPagingResult *pagingResult = nil;
        NSArray *favoriteSitesArray = nil;
        if (nil != favoriteSitesdata)
        {
            favoriteSitesArray = [weakSelf parseSiteArrayWithData:favoriteSitesdata error:&operationQueueError];
        }
        if (nil != favoriteSitesArray)
        {
            NSArray *sortedSiteArray = [AlfrescoSortingUtils sortedArrayForArray:favoriteSitesArray
                                                                         sortKey:listingContext.sortProperty
                                                                   supportedKeys:self.supportedSortKeys
                                                                      defaultKey:self.defaultSortKey
                                                                       ascending:listingContext.sortAscending];
            
            BOOL hasMore = NO;
            if(listingContext.skipCount < favoriteSitesArray.count)
            {
                hasMore = YES;
            }
            pagingResult = [[AlfrescoPagingResult alloc] initWithArray:sortedSiteArray hasMoreItems:hasMore totalItems:favoriteSitesArray.count];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(pagingResult, operationQueueError);
        }];
    }];
}

- (void)retrieveSiteWithShortName:(NSString *)siteShortName
                  completionBlock:(AlfrescoSiteCompletionBlock)completionBlock
{
    NSAssert(nil != completionBlock, @"RetrieveAllSitesWithCompletionBlock: the completion block must not be nil");
    NSAssert(nil != siteShortName, @"RetrieveAllSitesWithCompletionBlock: the site short name must not be nil");
    NSAssert(nil != self.authenticationProvider, @"RetrieveAllSitesWithCompletionBlock: the service must have a valid authentication provider");
    
    __weak AlfrescoCloudSiteService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        
        NSString *requestString = [kAlfrescoCloudSiteForShortnameAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:siteShortName];
        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                         baseUrlAsString:weakSelf.baseApiUrl
                                  authenticationProvider:weakSelf.authenticationProvider
                                                   error:&operationQueueError];
        AlfrescoSite *site = nil;
        if(nil != data)
        {
            site = [weakSelf parseSiteWithData:data error:&operationQueueError];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(site, operationQueueError);
        }];
    }];
}

- (void)retrieveDocumentLibraryFolderForSite:(NSString *)siteShortName
                             completionBlock:(AlfrescoFolderCompletionBlock)completionBlock
{
    NSAssert(nil != completionBlock, @"RetrieveAllSitesWithCompletionBlock: the completion block must not be nil");
    NSAssert(nil != siteShortName, @"RetrieveAllSitesWithCompletionBlock: the site short name must not be nil");
    NSAssert(nil != self.authenticationProvider, @"RetrieveAllSitesWithCompletionBlock: the service must have a valid authentication provider");
    
    __weak AlfrescoCloudSiteService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *requestString = [kAlfrescoCloudSiteContainersAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:siteShortName];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.baseApiUrl, requestString]];
        NSData *data = [AlfrescoHTTPUtils executeRequestWithURL:url
                                         authenticationProvider:weakSelf.authenticationProvider
                                                           data:nil
                                                     httpMethod:@"GET"
                                                          error:&operationQueueError];
        NSDictionary *folderDict = nil;
        
        if (nil != data)
        {
            folderDict = [weakSelf parseFolderIdWithData:data error:&operationQueueError];
        }
        
        if (nil != folderDict)
        {
            NSString *folderId = [folderDict valueForKey:kAlfrescoJSONIdentifier];
            __block AlfrescoDocumentFolderService *docService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.session];
            [docService retrieveNodeWithIdentifier:folderId
                                   completionBlock:^(AlfrescoNode *node, NSError *error)
             {
                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                     completionBlock((AlfrescoFolder *)node, error);}];
                 docService = nil;
             }];
        }
        else
        {
            if( nil == operationQueueError)
            {
                operationQueueError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeDocumentFolder
                                                          withDetailedDescription:@"The document library was not found"];
            }
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(nil, operationQueueError);
            }];
        }
    }];
}


#pragma mark Site service internal methods
- (NSArray *) parseSiteArrayWithData:(NSData *)data error:(NSError **)outError
{

    NSLog(@"parseSiteArrayWithData with JSON data %@",data);
    NSArray *entriesArray = [AlfrescoObjectConverter parseCloudJSONEntriesFromListData:data error:outError];
    if (nil != entriesArray)
    {
        NSMutableArray *resultsArray = [NSMutableArray arrayWithCapacity:entriesArray.count];
        
        for (NSDictionary *entryDict in entriesArray)
        {
            NSDictionary *individualEntry = [entryDict valueForKey:kAlfrescoCloudJSONEntry];
            [resultsArray addObject:[self siteFromJSON:individualEntry]];
        }
        return resultsArray;
    }
    else
        return nil;
}


- (NSArray *) parseSpecifiedSiteArrayWithData:(NSData *)data error:(NSError **)outError
{
    NSLog(@"parseSpecifiedSiteArrayWithData with JSON data %@",data);
    NSArray *entriesArray = [AlfrescoObjectConverter parseCloudJSONEntriesFromListData:data error:outError];
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
                    *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeJSONParsing
                                                    withDetailedDescription:@"JSON entry doesn't contain a valid site object"];
                }
                else
                {
                    NSError *error = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeJSONParsing
                                                         withDetailedDescription:@"JSON entry doesn't contain a valid site object"];
                    *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
                    
                }
                return nil;
            }
            else
            {
                if (![siteObj isKindOfClass:[NSDictionary class]])
                {
                    if (nil == *outError)
                    {
                        *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeJSONParsing
                                                        withDetailedDescription:@"JSON site entry doesn't map to NSDictionary as it should"];
                    }
                    else
                    {
                        NSError *error = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeJSONParsing
                                                             withDetailedDescription:@"JSON site entry doesn't map to NSDictionary as it should"];
                        *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
                        
                    }
                    return nil;
                }
                else
                {
                    NSDictionary *siteDict = (NSDictionary *)siteObj;
                    [resultsArray addObject:[self siteFromJSON:siteDict]];
                }
                
            }
        }
        return resultsArray;
    }
    else
        return nil;
}



- (AlfrescoSite *) parseSiteWithData:(NSData *)data error:(NSError **)outError
{
    NSLog(@"parseSiteWithData with JSON data %@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    NSDictionary *entryDictionary = [AlfrescoObjectConverter parseCloudJSONEntryFromListData:data error:outError];
    return (AlfrescoSite *)[self siteFromJSON:entryDictionary];
}

- (NSDictionary *)parseFolderIdWithData:(NSData *)data error:(NSError **)outError
{
    
    NSLog(@"parseFolderIdWithData with JSON data %@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    NSArray *entriesArray = [AlfrescoObjectConverter parseCloudJSONEntriesFromListData:data error:outError];
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
        *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeSites
                                        withDetailedDescription:@"JSON data set should map to NSArray"];
    }
    else
    {
        NSError *error = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeSites
                                             withDetailedDescription:@"JSON data set should map to NSArray"];
        *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeSites];
    }
    return nil;
}





@end
