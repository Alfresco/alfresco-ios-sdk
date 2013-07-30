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

#import "AlfrescoOnPremiseDocumentFolderService.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoErrors.h"
#import "AlfrescoURLUtils.h"
#import "AlfrescoFavoritesCache.h"
#import "AlfrescoSortingUtils.h"
#import "AlfrescoLog.h"
#import "AlfrescoPagingUtils.h"
#import "AlfrescoSearchService.h"

@interface AlfrescoOnPremiseDocumentFolderService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, strong, readwrite) AlfrescoFavoritesCache *favoritesCache;
@property (nonatomic, strong, readwrite) NSString *defaultSortKey;
@end

@implementation AlfrescoOnPremiseDocumentFolderService

- (id)initWithSession:(id<AlfrescoSession>)session
{
    if (self = [super initWithSession:session])
    {
        self.session = session;
        self.baseApiUrl = [[self.session.baseUrl absoluteString] stringByAppendingString:kAlfrescoOnPremiseAPIPath];
        self.defaultSortKey = kAlfrescoSortByTitle;
    }
    return self;
}

- (AlfrescoRequest *)retrieveRenditionOfNode:(AlfrescoNode *)node
                               renditionName:(NSString *)renditionName
                             completionBlock:(AlfrescoContentFileCompletionBlock)completionBlock
{
    
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:renditionName argumentName:@"renditionName"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSURL *url = [self renditionURLForNode:node renditionName:renditionName];
    AlfrescoRequest *alfrescoRequest = [[AlfrescoRequest alloc] init];
    
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:alfrescoRequest completionBlock:^(NSData *responseData, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            AlfrescoContentFile *thumbnail = [[AlfrescoContentFile alloc] initWithData:responseData mimeType:@"application/octet-stream"];
            completionBlock(thumbnail, nil);
        }
    }];
    return alfrescoRequest;
}

- (AlfrescoRequest *)retrieveRenditionOfNode:(AlfrescoNode *)node
                               renditionName:(NSString *)renditionName
                                outputStream:(NSOutputStream *)outputStream
                             completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:renditionName argumentName:@"renditionName"];
    [AlfrescoErrors assertArgumentNotNil:outputStream argumentName:@"outputStream"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSURL *url = [self renditionURLForNode:node renditionName:renditionName];
    AlfrescoRequest *alfrescoRequest = [[AlfrescoRequest alloc] init];
    
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:alfrescoRequest outputStream:outputStream completionBlock:^(NSData *responseData, NSError *error) {
        if (error)
        {
            completionBlock(NO, error);
        }
        else
        {
            completionBlock(YES, nil);
        }
    }];
    return alfrescoRequest;
}

- (AlfrescoRequest *)favoriteDocumentsWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSArray *favouriteDocuments = [self.favoritesCache favoriteDocuments];
    if (0 < favouriteDocuments.count)
    {
        NSArray *sortedFavoriteDocuments = [AlfrescoSortingUtils sortedArrayForArray:favouriteDocuments sortKey:self.defaultSortKey ascending:YES];
        if ([AlfrescoLog sharedInstance].logLevel == AlfrescoLogLevelDebug)
        {
            AlfrescoLogDebug(@"returning cached favorite documents %d", sortedFavoriteDocuments.count);
        }
        completionBlock(sortedFavoriteDocuments, nil);
        return nil;
    }
    AlfrescoRequest *request = [self favoritesForType:AlfrescoFavoriteDocument listingContext:nil arrayCompletionBlock:completionBlock pagingCompletionBlock:nil];
    return request;
}

- (AlfrescoRequest *)favoriteDocumentsWithListingContext:(AlfrescoListingContext *)listingContext
                                         completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    NSArray *favouriteDocuments = [self.favoritesCache favoriteDocuments];
    if (0 < favouriteDocuments.count)
    {
        NSArray *sortedFavoriteDocuments = [AlfrescoSortingUtils sortedArrayForArray:favouriteDocuments sortKey:self.defaultSortKey ascending:YES];
        if ([AlfrescoLog sharedInstance].logLevel == AlfrescoLogLevelDebug)
        {
            AlfrescoLogDebug(@"returning cached favorite documents %d", sortedFavoriteDocuments.count);
        }
        AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedFavoriteDocuments listingContext:listingContext];
        completionBlock(pagingResult, nil);
        return nil;
    }
    AlfrescoRequest *request = [self favoritesForType:AlfrescoFavoriteDocument listingContext:listingContext arrayCompletionBlock:nil pagingCompletionBlock:completionBlock];
    return request;
}

- (AlfrescoRequest *)favoriteFoldersWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSArray *favouriteFolders = [self.favoritesCache favoriteFolders];
    if (0 < favouriteFolders.count)
    {
        NSArray *sortedFavoriteFolders = [AlfrescoSortingUtils sortedArrayForArray:favouriteFolders sortKey:self.defaultSortKey ascending:YES];
        if ([AlfrescoLog sharedInstance].logLevel == AlfrescoLogLevelDebug)
        {
            AlfrescoLogDebug(@"returning cached favorite folders %d", sortedFavoriteFolders.count);
        }
        completionBlock(sortedFavoriteFolders, nil);
        return nil;
    }
    AlfrescoRequest *request = [self favoritesForType:AlfrescoFavoriteFolder listingContext:nil arrayCompletionBlock:completionBlock pagingCompletionBlock:nil];
    return request;
}

- (AlfrescoRequest *)favoriteFoldersWithListingContext:(AlfrescoListingContext *)listingContext
                                       completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    NSArray *favouriteFolders = [self.favoritesCache favoriteDocuments];
    if (0 < favouriteFolders.count)
    {
        NSArray *sortedFavoriteFolders = [AlfrescoSortingUtils sortedArrayForArray:favouriteFolders sortKey:self.defaultSortKey ascending:YES];
        if ([AlfrescoLog sharedInstance].logLevel == AlfrescoLogLevelDebug)
        {
            AlfrescoLogDebug(@"returning cached favorite folders %d", sortedFavoriteFolders.count);
        }
        AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedFavoriteFolders listingContext:listingContext];
        completionBlock(pagingResult, nil);
        return nil;
    }
    AlfrescoRequest *request = [self favoritesForType:AlfrescoFavoriteFolder listingContext:listingContext arrayCompletionBlock:nil pagingCompletionBlock:completionBlock];
    return request;
}

- (AlfrescoRequest *)favoriteNodesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSMutableArray *favoriteNodes = [NSMutableArray array];
    
    [self favoriteDocumentsWithCompletionBlock:^(NSArray *favoriteDocuments, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            [favoriteNodes addObjectsFromArray:favoriteDocuments];
            
            [self favoriteFoldersWithCompletionBlock:^(NSArray *favoriteFolders, NSError *error) {
                if (!error)
                {
                    [favoriteNodes addObjectsFromArray:favoriteFolders];
                    NSArray *sortedFavoriteNodes = [AlfrescoSortingUtils sortedArrayForArray:favoriteNodes sortKey:self.defaultSortKey ascending:YES];
                    completionBlock(sortedFavoriteNodes, nil);
                }
            }];
        }
    }];
    
    return nil;
}

- (AlfrescoRequest *)favoriteNodesWithListingContext:(AlfrescoListingContext *)listingContext
                                     completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    [self favoriteNodesWithCompletionBlock:^(NSArray *array, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            AlfrescoPagingResult *paging = [AlfrescoPagingUtils pagedResultFromArray:array listingContext:listingContext];
            completionBlock(paging, nil);
        }
    }];
    
    return nil;
}

- (AlfrescoRequest *)favoritesForType:(AlfrescoFavoriteType)type
                       listingContext:(AlfrescoListingContext *)listingContext
                 arrayCompletionBlock:(AlfrescoArrayCompletionBlock)arrayCompletionBlock
                pagingCompletionBlock:(AlfrescoPagingResultCompletionBlock)pagingCompletionBlock
{
    
    NSString *requestString = nil;
    NSURL *url = nil;
    if (type == AlfrescoFavoriteDocument)
    {
        requestString = [kAlfrescoOnPremiseFavoriteDocumentsAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
        url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    }
    else if (type == AlfrescoFavoriteFolder)
    {
        requestString = [kAlfrescoOnPremiseFavoriteFoldersAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
        url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    }
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    
    [self.session.networkProvider executeRequestWithURL:url
                                                session:self.session
                                                 method:kAlfrescoHTTPGet
                                        alfrescoRequest:request
                                        completionBlock:^(NSData *data, NSError *error) {
                                            if (nil != error)
                                            {
                                                [self errorForCompletionBlocks:error arrayCompletionBlock:arrayCompletionBlock pagingCompletionBlock:pagingCompletionBlock];
                                            }
                                            else
                                            {
                                                NSError *conversionError = nil;
                                                NSArray *favorites = [self favoritesArrayFromJSONData:data forType:type error:&conversionError];
                                                
                                                if (favorites != nil)
                                                {
                                                    NSString *searchStatement = [self cmisQueryWithNodes:favorites forType:type];
                                                    AlfrescoSearchService *searchService = [[AlfrescoSearchService alloc] initWithSession:self.session];
                                                    [searchService searchWithStatement:searchStatement language:AlfrescoSearchLanguageCMIS completionBlock:^(NSArray *resultsArray, NSError *error) {
                                                        if (error)
                                                        {
                                                            [self errorForCompletionBlocks:error arrayCompletionBlock:arrayCompletionBlock pagingCompletionBlock:pagingCompletionBlock];
                                                        }      
                                                        else
                                                        {
                                                            [self.favoritesCache addFavorites:resultsArray type:type];
                                                            if (arrayCompletionBlock)
                                                            {
                                                                arrayCompletionBlock(resultsArray, nil);
                                                            }
                                                            else
                                                            {
                                                                AlfrescoPagingResult *paging = [AlfrescoPagingUtils pagedResultFromArray:resultsArray listingContext:listingContext];
                                                                pagingCompletionBlock(paging, nil);
                                                            }
                                                        }
                                                    }];
                                                }
                                                else
                                                {
                                                    [self errorForCompletionBlocks:conversionError arrayCompletionBlock:arrayCompletionBlock pagingCompletionBlock:pagingCompletionBlock];
                                                }
                                            }
                                        }];
    return request;
}

#pragma mark - private methods

- (NSURL *)renditionURLForNode:(AlfrescoNode *)node renditionName:(NSString *)renditionName
{
    NSString *nodeIdentifier = [node.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"];
    NSRange versionNumberRange = [nodeIdentifier rangeOfString:@";"];
    if (versionNumberRange.location != NSNotFound)
    {
        nodeIdentifier = [nodeIdentifier substringToIndex:versionNumberRange.location];
    }
    
    NSString *requestString = [kAlfrescoOnPremiseThumbnailRenditionAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef withString:nodeIdentifier];
    requestString = [requestString stringByReplacingOccurrencesOfString:kAlfrescoRenditionId withString:renditionName];
    return [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
}

- (NSString *)cmisQueryWithNodes:(NSArray *)nodes forType:(AlfrescoFavoriteType)type
{
    NSString *pattern = [NSString stringWithFormat:@"(cmis:objectId='%@')", [nodes componentsJoinedByString:@"' OR cmis:objectId='"]];
    NSString *nodeType = (type == AlfrescoFavoriteDocument) ? @"document" : @"folder";
    
    return [NSString stringWithFormat:@"SELECT * FROM cmis:%@ WHERE %@", nodeType, pattern];
}

- (NSArray *) favoritesArrayFromJSONData:(NSData *)data forType:(AlfrescoFavoriteType)type error:(NSError **)outError
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
    id favoritesObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if(error)
    {
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeFavorites];
        return nil;
    }
    if ([favoritesObject isKindOfClass:[NSDictionary class]] == NO)
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
    NSDictionary *favoritesDictionary = (NSDictionary *)favoritesObject;
    
    id favoriteNodesObj = nil;
    if (type == AlfrescoFavoriteDocument)
    {
        favoriteNodesObj = [favoritesDictionary valueForKeyPath:kAlfrescoOnPremiseFavoriteDocuments];
    }
    else
    {
        favoriteNodesObj = [favoritesDictionary valueForKeyPath:kAlfrescoOnPremiseFavoriteFolders];
    }
    
    return [favoriteNodesObj componentsSeparatedByString:@","];
}

- (void)errorForCompletionBlocks:(NSError *)error
            arrayCompletionBlock:(AlfrescoArrayCompletionBlock)arrayCompletionBlock
           pagingCompletionBlock:(AlfrescoPagingResultCompletionBlock)pagingCompletionBlock
{
    if (arrayCompletionBlock)
    {
        arrayCompletionBlock(nil, error);
    }
    else
    {
        pagingCompletionBlock(nil, error);
    }
}

@end
