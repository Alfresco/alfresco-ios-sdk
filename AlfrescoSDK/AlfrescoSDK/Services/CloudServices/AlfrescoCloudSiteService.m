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
- (NSArray *) siteArrayWithData:(NSData *)data error:(NSError **)outError;
- (NSArray *) specifiedSiteArrayFromJSONData:(NSData *)data error:(NSError **)outError;
- (AlfrescoSite *) alfrescoSiteFromJSONData:(NSData *)data error:(NSError **)outError;
- (NSDictionary *) dictionaryFromJSONData:(NSData *)data error:(NSError **)outError;

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
        id authenticationObject = [session objectForParameter:kAlfrescoAuthenticationProviderObjectKey];
//        id authenticationObject = objc_getAssociatedObject(self.session, &kAlfrescoAuthenticationProviderObjectKey);
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
    
    __weak AlfrescoCloudSiteService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *error = nil;
        NSData *data = [AlfrescoHTTPUtils executeRequest:kAlfrescoCloudSiteAPI
                                         baseUrlAsString:weakSelf.baseApiUrl
                                                 session:weakSelf.session
                                                   error:&error];

        __block NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        
        
        NSArray *sortedSiteArray = nil;
        if(nil != data)
        {
            NSArray *siteArray = [weakSelf siteArrayWithData:data error:&error];
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
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    __weak AlfrescoCloudSiteService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *error = nil;
        
        // pos parameter is not working, so paging is done in-memory
        NSData *data = [AlfrescoHTTPUtils executeRequest:kAlfrescoCloudSiteAPI
                                         baseUrlAsString:weakSelf.baseApiUrl
                                                 session:weakSelf.session
                                                   error:&error];
        NSArray *siteArray = nil;
        AlfrescoPagingResult *pagingResult = nil;
        if(nil != data)
        {
            siteArray = [weakSelf siteArrayWithData:data error:&error];
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
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    __weak AlfrescoCloudSiteService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *requestString = [kAlfrescoCloudSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:weakSelf.session.personIdentifier];
        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                         baseUrlAsString:weakSelf.baseApiUrl
                                                 session:weakSelf.session
                                                   error:&operationQueueError];
        
        NSArray *sortedSiteArray = nil;
        if(nil != data)
        {
            NSArray *siteArray = [weakSelf specifiedSiteArrayFromJSONData:data error:&operationQueueError];
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
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    __weak AlfrescoCloudSiteService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        
        // pos parameter is not working, so paging is done in-memory
        NSString *requestString = [kAlfrescoCloudSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:weakSelf.session.personIdentifier];
        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                         baseUrlAsString:weakSelf.baseApiUrl
                                                 session:weakSelf.session
                                                   error:&operationQueueError];
        
        NSArray *siteArray = nil;
        AlfrescoPagingResult *pagingResult = nil;
        if(nil != data)
        {
            siteArray = [weakSelf specifiedSiteArrayFromJSONData:data error:&operationQueueError];
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
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    __weak AlfrescoCloudSiteService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *requestString = [kAlfrescoCloudFavoriteSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:weakSelf.session.personIdentifier];        
        NSData *favoriteSitesdata = [AlfrescoHTTPUtils executeRequest:requestString
                                                      baseUrlAsString:weakSelf.baseApiUrl
                                                              session:weakSelf.session
                                                                error:&operationQueueError];
                
        NSArray *sortedSiteArray = nil;
        NSArray *favoriteSitesArray = nil;
        if (nil != favoriteSitesdata)
        {
            favoriteSitesArray = [weakSelf siteArrayWithData:favoriteSitesdata error:&operationQueueError];
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
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    __weak AlfrescoCloudSiteService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        
        NSString *requestString = [kAlfrescoCloudFavoriteSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:weakSelf.session.personIdentifier];
        NSData *favoriteSitesdata = [AlfrescoHTTPUtils executeRequest:requestString
                                                      baseUrlAsString:weakSelf.baseApiUrl
                                                              session:weakSelf.session
                                                                error:&operationQueueError];
        
        AlfrescoPagingResult *pagingResult = nil;
        NSArray *favoriteSitesArray = nil;
        if (nil != favoriteSitesdata)
        {
            favoriteSitesArray = [weakSelf siteArrayWithData:favoriteSitesdata error:&operationQueueError];
        }
        if (nil != favoriteSitesArray)
        {
            NSArray *sortedSiteArray = [AlfrescoSortingUtils sortedArrayForArray:favoriteSitesArray
                                                                         sortKey:listingContext.sortProperty
                                                                   supportedKeys:self.supportedSortKeys
                                                                      defaultKey:self.defaultSortKey
                                                                       ascending:listingContext.sortAscending];
            
            pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedSiteArray listingContext:listingContext];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(pagingResult, operationQueueError);
        }];
    }];
}

- (void)retrieveSiteWithShortName:(NSString *)siteShortName
                  completionBlock:(AlfrescoSiteCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:siteShortName argumentName:@"siteShortName"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    __weak AlfrescoCloudSiteService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        
        NSString *requestString = [kAlfrescoCloudSiteForShortnameAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:siteShortName];
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
}

- (void)retrieveDocumentLibraryFolderForSite:(NSString *)siteShortName
                             completionBlock:(AlfrescoFolderCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:siteShortName argumentName:@"siteShortName"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    __weak AlfrescoCloudSiteService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *requestString = [kAlfrescoCloudSiteContainersAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:siteShortName];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.baseApiUrl, requestString]];
        NSData *data = [AlfrescoHTTPUtils executeRequestWithURL:url
                                                        session:weakSelf.session
                                                           data:nil
                                                     httpMethod:@"GET"
                                                          error:&operationQueueError];
        NSDictionary *folderDict = nil;
        
        if (nil != data)
        {
            folderDict = [weakSelf dictionaryFromJSONData:data error:&operationQueueError];
        }
        
        if (nil != folderDict)
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
                operationQueueError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completionBlock(nil, operationQueueError);
                }];
            }
            else
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
        }
        else
        {
            if( nil == operationQueueError)
            {
                operationQueueError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeSitesNoDocLib];
            }
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(nil, operationQueueError);
            }];
        }
    }];
}


#pragma mark Site service internal methods
- (NSArray *) siteArrayWithData:(NSData *)data error:(NSError **)outError
{
    log(@"JSON data: %@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    NSArray *entriesArray = [AlfrescoObjectConverter arrayJSONEntriesFromListData:data error:outError];
    if (nil != entriesArray)
    {
        NSMutableArray *resultsArray = [NSMutableArray arrayWithCapacity:entriesArray.count];
        
        for (NSDictionary *entryDict in entriesArray)
        {
            NSDictionary *individualEntry = [entryDict valueForKey:kAlfrescoCloudJSONEntry];
            [resultsArray addObject:[[AlfrescoSite alloc] initWithProperties:individualEntry]];
        }
        return resultsArray;
    }
    else
        return nil;
}


- (NSArray *) specifiedSiteArrayFromJSONData:(NSData *)data error:(NSError **)outError
{
    log(@"JSON data: %@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
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
                    NSDictionary *siteDict = (NSDictionary *)siteObj;
                    [resultsArray addObject:[[AlfrescoSite alloc] initWithProperties:siteDict]];
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
    log(@"JSON data: %@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    NSDictionary *entryDictionary = [AlfrescoObjectConverter dictionaryJSONEntryFromListData:data error:outError];
    return [[AlfrescoSite alloc] initWithProperties:entryDictionary];
}

- (NSDictionary *)dictionaryFromJSONData:(NSData *)data error:(NSError **)outError
{
    log(@"JSON data: %@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
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





@end
