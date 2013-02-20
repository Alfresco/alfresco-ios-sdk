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
#import "AlfrescoURLUtils.h"
#import "AlfrescoPagingUtils.h"
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoBasicAuthenticationProvider.h"
#import "AlfrescoDocumentFolderService.h"
#import "AlfrescoSortingUtils.h"
#import "AlfrescoNetworkProvider.h"

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
    
//    __weak AlfrescoOnPremiseSiteService *weakSelf = self;
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoOnPremiseSiteAPI];
    [self.session.networkProvider executeRequestWithURL:url session:self.session completionBlock:^(NSData *data, NSError *error){
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *siteArray = [self siteArrayFromJSONData:data error:&conversionError];
            NSArray *sortedArray = [AlfrescoSortingUtils sortedArrayForArray:siteArray sortKey:self.defaultSortKey ascending:YES];
            completionBlock(sortedArray, conversionError);
        }
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
    
    
//    __weak AlfrescoOnPremiseSiteService *weakSelf = self;
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoOnPremiseSiteAPI];
    [self.session.networkProvider executeRequestWithURL:url session:self.session completionBlock:^(NSData *data, NSError *error){
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *siteArray = [self siteArrayFromJSONData:data error:&conversionError];
            NSArray *sortedArray = [AlfrescoSortingUtils sortedArrayForArray:siteArray sortKey:self.defaultSortKey ascending:YES];
            AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedArray listingContext:listingContext];
            completionBlock(pagingResult, conversionError);
        }
    }];
}

- (void)retrieveSitesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
//    __weak AlfrescoOnPremiseSiteService *weakSelf = self;
    NSString *siteString = [kAlfrescoOnPremiseSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:siteString];
    [self.session.networkProvider executeRequestWithURL:url session:self.session completionBlock:^(NSData *data, NSError *error){
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *siteArray = [self siteArrayFromJSONData:data error:&conversionError];
            NSArray *sortedSiteArray = [AlfrescoSortingUtils sortedArrayForArray:siteArray sortKey:self.defaultSortKey ascending:YES];
            completionBlock(sortedSiteArray, conversionError);
        }
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
    
//    __weak AlfrescoOnPremiseSiteService *weakSelf = self;
    NSString *personString = [kAlfrescoOnPremiseSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:personString];
    [self.session.networkProvider executeRequestWithURL:url session:self.session completionBlock:^(NSData *data, NSError *error){
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *siteArray = [self siteArrayFromJSONData:data error:&conversionError];
            NSArray *sortedSiteArray = [AlfrescoSortingUtils sortedArrayForArray:siteArray sortKey:self.defaultSortKey ascending:YES];
            AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedSiteArray listingContext:listingContext];
            completionBlock(pagingResult, conversionError);
        }
    }];
}


- (void)retrieveFavoriteSitesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
//    __weak AlfrescoOnPremiseSiteService *weakSelf = self;
    NSString *favRequestString = [kAlfrescoOnPremiseFavoriteSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
    NSString *allRequestString = [kAlfrescoOnPremiseSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];

    NSURL *allSitesURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.baseApiUrl, allRequestString]];
    NSURL *favouriteSitesURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.baseApiUrl, favRequestString]];
    [self.session.networkProvider executeRequestWithURL:allSitesURL session:self.session completionBlock:^(NSData *data, NSError *allSitesError){
        if (nil == data)
        {
            completionBlock(nil, allSitesError);
        }
        else
        {
            [self.session.networkProvider executeRequestWithURL:favouriteSitesURL session:self.session completionBlock:^(NSData *favData, NSError *favError){
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
                        NSMutableArray *sites = [NSMutableArray array];
                        for (AlfrescoSite *site in allSitesArray)
                        {
                            if ([favSitesArray containsObject:site.shortName])
                            {
                                [sites addObject:site];
                            }
                        }
                        NSArray *sortedSites = [AlfrescoSortingUtils sortedArrayForArray:sites sortKey:self.defaultSortKey ascending:YES];
                        completionBlock(sortedSites, nil);
                    }
                }
            }];
        }
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
    
//    __weak AlfrescoOnPremiseSiteService *weakSelf = self;
    NSString *favRequestString = [kAlfrescoOnPremiseFavoriteSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
    NSString *allRequestString = [kAlfrescoOnPremiseSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
    NSURL *allSitesURL = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:allRequestString];
    NSURL *favouriteSitesURL = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:favRequestString];
    
    [self.session.networkProvider executeRequestWithURL:allSitesURL session:self.session completionBlock:^(NSData *data, NSError *allSitesError){
        if (nil == data)
        {
            completionBlock(nil, allSitesError);
        }
        else
        {
            [self.session.networkProvider executeRequestWithURL:favouriteSitesURL session:self.session completionBlock:^(NSData *favData, NSError *favError){
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
                        NSMutableArray *sites = [NSMutableArray array];
                        for (AlfrescoSite *site in allSitesArray)
                        {
                            if ([favSitesArray containsObject:site.shortName])
                            {
                                [sites addObject:site];
                            }
                        }
                        NSArray *sortedSites = [AlfrescoSortingUtils sortedArrayForArray:sites sortKey:self.defaultSortKey ascending:YES];
                        AlfrescoPagingResult *pagedResults = [AlfrescoPagingUtils pagedResultFromArray:sortedSites listingContext:listingContext];
                        
                        completionBlock(pagedResults, nil);
                    }
                }
            }];
        }
    }];
}

- (void)retrieveSiteWithShortName:(NSString *)siteShortName
                  completionBlock:(AlfrescoSiteCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:siteShortName argumentName:@"siteShortName"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
//    __weak AlfrescoOnPremiseSiteService *weakSelf = self;
    NSString *requestString = [kAlfrescoOnPremiseSitesShortnameAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:siteShortName];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    [self.session.networkProvider executeRequestWithURL:url session:self.session completionBlock:^(NSData *data, NSError *error){
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
}


- (void)retrieveDocumentLibraryFolderForSite:(NSString *)siteShortName
                             completionBlock:(AlfrescoFolderCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:siteShortName argumentName:@"siteShortName"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    __block AlfrescoDocumentFolderService *docService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.session];
    NSString *requestString = [kAlfrescoOnPremiseSiteDoclibAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:siteShortName];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:[self.session.baseUrl absoluteString] extensionURL:requestString];
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",
//                                       self.session.baseUrl, requestString]];
    [self.session.networkProvider executeRequestWithURL:url session:self.session completionBlock:^(NSData *data, NSError *error){
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
