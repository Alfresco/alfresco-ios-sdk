/*
 ******************************************************************************
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
 *****************************************************************************
 */

#import "AlfrescoLegacyAPIDocumentFolderService.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoErrors.h"
#import "AlfrescoURLUtils.h"
#import "AlfrescoFavoritesCache.h"
#import "AlfrescoSortingUtils.h"
#import "AlfrescoLog.h"
#import "AlfrescoPagingUtils.h"
#import "AlfrescoSearchService.h"

@interface AlfrescoLegacyAPIDocumentFolderService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, strong, readwrite) AlfrescoFavoritesCache *favoritesCache;
@property (nonatomic, strong, readwrite) NSString *defaultSortKey;
@end

@implementation AlfrescoLegacyAPIDocumentFolderService

- (id)initWithSession:(id<AlfrescoSession>)session
{
    if (self = [super initWithSession:session])
    {
        self.baseApiUrl = [[self.session.baseUrl absoluteString] stringByAppendingString:kAlfrescoLegacyAPIPath];
        
        // setup favorites cache
        id cachedObj = [self.session objectForParameter:kAlfrescoSessionCacheFavorites];
        if (cachedObj)
        {
            AlfrescoLogDebug(@"Found an existing FavoritesCache in session");
            self.favoritesCache = (AlfrescoFavoritesCache *)cachedObj;
        }
        else
        {
            self.favoritesCache = [AlfrescoFavoritesCache new];
            [self.session setObject:self.favoritesCache forParameter:kAlfrescoSessionCacheFavorites];
            AlfrescoLogDebug(@"Created new FavoritesCache object");
        }
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

- (AlfrescoRequest *)retrieveFavoriteDocumentsWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:-1];
    return [self retrieveFavoriteDocumentsWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
        completionBlock(pagingResult.objects, error);
    }];
}

- (AlfrescoRequest *)retrieveFavoriteDocumentsWithListingContext:(AlfrescoListingContext *)listingContext
                                                 completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    AlfrescoRequest *request = nil;
    if (!self.favoritesCache.isCacheBuilt)
    {
        __weak typeof(self) weakSelf = self;
        request = [self.favoritesCache buildCacheWithDelegate:self completionBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                NSArray *sortedFavoriteDocuments = [AlfrescoSortingUtils sortedArrayForArray:weakSelf.favoritesCache.favoriteDocuments
                                                                                     sortKey:self.defaultSortKey ascending:YES];
                AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedFavoriteDocuments
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
        AlfrescoLogDebug(@"Cache hit: returning favorite documents from cache");
        AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:self.favoritesCache.favoriteDocuments
                                                                        listingContext:listingContext];
        completionBlock(pagingResult, nil);
    }
    
    return request;
}

- (AlfrescoRequest *)retrieveFavoriteFoldersWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:-1];
    return [self retrieveFavoriteFoldersWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
        completionBlock(pagingResult.objects, error);
    }];
}

- (AlfrescoRequest *)retrieveFavoriteFoldersWithListingContext:(AlfrescoListingContext *)listingContext
                                               completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    AlfrescoRequest *request = nil;
    if (!self.favoritesCache.isCacheBuilt)
    {
        __weak typeof(self) weakSelf = self;
        request = [self.favoritesCache buildCacheWithDelegate:self completionBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                NSArray *sortedFavoriteFolders = [AlfrescoSortingUtils sortedArrayForArray:weakSelf.favoritesCache.favoriteFolders
                                                                                   sortKey:self.defaultSortKey ascending:YES];
                AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedFavoriteFolders
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
        AlfrescoLogDebug(@"Cache hit: returning favorite folders from cache");
        AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:self.favoritesCache.favoriteFolders
                                                                        listingContext:listingContext];
        completionBlock(pagingResult, nil);
    }
    
    return request;
}

- (AlfrescoRequest *)retrieveFavoriteNodesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:-1];
    return [self retrieveFavoriteNodesWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
        completionBlock(pagingResult.objects, error);
    }];
}

- (AlfrescoRequest *)retrieveFavoriteNodesWithListingContext:(AlfrescoListingContext *)listingContext
                                             completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    AlfrescoRequest *request = nil;
    if (!self.favoritesCache.isCacheBuilt)
    {
        __weak typeof(self) weakSelf = self;
        request = [self.favoritesCache buildCacheWithDelegate:self completionBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                NSArray *sortedFavoriteNodes = [AlfrescoSortingUtils sortedArrayForArray:weakSelf.favoritesCache.favoriteNodes
                                                                                 sortKey:self.defaultSortKey ascending:YES];
                AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedFavoriteNodes
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
        AlfrescoLogDebug(@"Cache hit: returning favorite nodes from cache");
        AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:self.favoritesCache.favoriteNodes
                                                                        listingContext:listingContext];
        completionBlock(pagingResult, nil);
    }
    
    return request;
}

- (AlfrescoRequest *)isFavorite:(AlfrescoNode *)node completionBlock:(AlfrescoFavoritedCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    __block NSNumber *favorite = nil;
    
    AlfrescoRequest *request = nil;
    if (!self.favoritesCache.isCacheBuilt)
    {
        __weak typeof(self) weakSelf = self;
        request = [self.favoritesCache buildCacheWithDelegate:self completionBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                favorite = [weakSelf.favoritesCache isNodeFavorited:node];
                if (favorite != nil)
                {
                    completionBlock(YES, [favorite boolValue], nil);
                }
                else
                {
                    // we could go back to the server here (if there was an API) but typically this method is
                    // called for every node resulting in a large number of requests so we'll presume the node
                    // is not a favorite, if it's state has changed on the server it will get picked up when
                    // the cache is rebuilt.
                    completionBlock(YES, NO, nil);
                }
            }
            else
            {
                completionBlock(NO, NO, error);
            }
        }];
    }
    else
    {
        favorite = [self.favoritesCache isNodeFavorited:node];
        if (favorite != nil)
        {
            // return cached state
            AlfrescoLogDebug(@"Cache hit: returning favorite state for %@ from cache", node.identifier);
            completionBlock(YES, [favorite boolValue], nil);
        }
        else
        {
            // we could go back to the server here (if there was an API) but typically this method is
            // called for every node resulting in a large number of requests so we'll presume the node
            // is not a favorite, if it's state has changed on the server it will get picked up when
            // the cache is rebuilt.
            completionBlock(YES, NO, nil);
        }
    }
    
    return request;
}

- (AlfrescoRequest *)addFavorite:(AlfrescoNode *)node completionBlock:(AlfrescoFavoritedCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    [self prepareRequestBodyToFavorite:YES node:node completionBlock:^(NSData *data, NSError *error) {
        
        [self updateFavoritesForNode:node favoriteData:data completionBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded)
            {
                [self.favoritesCache cacheNode:node favorite:YES];
            }
            completionBlock(succeeded, succeeded, error);
        }];
    }];
    return nil;
}

- (AlfrescoRequest *)removeFavorite:(AlfrescoNode *)node completionBlock:(AlfrescoFavoritedCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    [self prepareRequestBodyToFavorite:NO node:node completionBlock:^(NSData *data, NSError *error) {
        
        [self updateFavoritesForNode:node favoriteData:data completionBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded)
            {
                [self.favoritesCache cacheNode:node favorite:NO];
            }
            completionBlock(succeeded, !succeeded, error);
        }];
    }];
    return nil;
}

#pragma mark Special Folder Handling

- (AlfrescoRequest *)retrieveHomeFolderWithCompletionBlock:(AlfrescoFolderCompletionBlock)completionBlock
{
    // Not supported - userhome retrieval requires cmis:item support
    return nil;
}


#pragma mark AlfrescoFavortiesCacheDataDelegate methods

- (AlfrescoRequest *)retrieveFavoriteNodeDataWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    // request the users preferences
    NSString *requestString = [kAlfrescoLegacyPreferencesAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    __weak typeof(self) weakSelf = self;
    [self.session.networkProvider executeRequestWithURL:url session:self.session method:kAlfrescoHTTPGet alfrescoRequest:request
                                        completionBlock:^(NSData *data, NSError *requestError) {
        if (data != nil)
        {
            // extract the favorite document and folder noderefs from the preferences
            NSError *conversionError = nil;
            NSDictionary *favorites = [weakSelf favoritesDictionaryFromJSONData:data error:&conversionError];
            
            if (favorites != nil)
            {
                NSMutableArray *favoriteNodes = [NSMutableArray array];
                NSArray *favoriteDocumentNodeRefs = favorites[kAlfrescoLegacyFavoriteDocuments];
                NSArray *favoriteFolderNodeRefs = favorites[kAlfrescoLegacyFavoriteFolders];
                
                if (favoriteDocumentNodeRefs.count > 0)
                {
                    // retrieve full node info for each document
                    [weakSelf performCmisQueryWithNodeRefs:favoriteDocumentNodeRefs documents:YES
                                           completionBlock:^(NSArray *documentsArray, NSError *documentsError) {
                        if (documentsArray != nil)
                        {
                            [favoriteNodes addObjectsFromArray:documentsArray];
                            
                            if (favoriteFolderNodeRefs.count > 0)
                            {
                                // retrieve full node info for each folder
                                [weakSelf performCmisQueryWithNodeRefs:favoriteFolderNodeRefs documents:NO
                                                completionBlock:^(NSArray *folderArray, NSError *folderError) {
                                    if (folderArray != nil)
                                    {
                                        [favoriteNodes addObjectsFromArray:folderArray];
                                        completionBlock(favoriteNodes, nil);
                                    }
                                    else
                                    {
                                        completionBlock(nil, folderError);
                                    }
                                }];
                            }
                            else
                            {
                                // there were only favorite documents, return them
                                completionBlock(favoriteNodes, nil);
                            }
                        }
                        else
                        {
                            completionBlock(nil, documentsError);
                        }
                    }];
                }
                else
                {
                    if (favoriteFolderNodeRefs.count > 0)
                    {
                        // retrieve full node info for each folder
                        [weakSelf performCmisQueryWithNodeRefs:favoriteFolderNodeRefs documents:NO
                                               completionBlock:^(NSArray *folderArray, NSError *folderError) {
                            if (folderArray != nil)
                            {
                                // there were only favorite folders, return them
                                [favoriteNodes addObjectsFromArray:folderArray];
                                completionBlock(favoriteNodes, nil);
                            }
                            else
                            {
                                completionBlock(nil, folderError);
                            }
                        }];
                    }
                    else
                    {
                        // no favorites at all, return empty array
                        completionBlock(@[], nil);
                    }
                }
            }
            else
            {
                completionBlock(nil, conversionError);
            }
        }
        else
        {
            completionBlock(nil, requestError);
        }
    }];
    
    return request;
}

#pragma mark Internal private methods

- (NSURL *)renditionURLForNode:(AlfrescoNode *)node renditionName:(NSString *)renditionName
{
    NSString *nodeIdentifier = [node.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"];
    nodeIdentifier = [self identifierWithoutVersionNumberForIdentifier:nodeIdentifier];
    
    NSString *requestString = [kAlfrescoLegacyThumbnailRenditionAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef withString:nodeIdentifier];
    requestString = [requestString stringByReplacingOccurrencesOfString:kAlfrescoRenditionId withString:renditionName];
    return [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
}

- (NSString *)identifierWithoutVersionNumberForIdentifier:(NSString *)identifier
{
    NSRange versionNumberRange = [identifier rangeOfString:@";"];
    if (versionNumberRange.location != NSNotFound)
    {
        return [identifier substringToIndex:versionNumberRange.location];
    }
    return identifier;
}

- (void)performCmisQueryWithNodeRefs:(NSArray *)nodeRefs documents:(BOOL)documents completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    // generate search statement
    NSString *pattern = [NSString stringWithFormat:@"(cmis:objectId='%@')", [nodeRefs componentsJoinedByString:@"' OR cmis:objectId='"]];
    NSString *nodeType = documents ? @"document" : @"folder";
    NSString *searchStatement = [NSString stringWithFormat:@"SELECT * FROM cmis:%@ WHERE %@", nodeType, pattern];
    
    // excute query
    AlfrescoSearchService *searchService = [[AlfrescoSearchService alloc] initWithSession:self.session];
    [searchService searchWithStatement:searchStatement language:AlfrescoSearchLanguageCMIS completionBlock:completionBlock];
}

- (NSDictionary *)favoritesDictionaryFromJSONData:(NSData *)data error:(NSError **)outError
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
    
    NSError *conversionError = nil;
    id preferencesObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&conversionError];
    if (conversionError)
    {
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:conversionError andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        return nil;
    }
    
    NSDictionary *preferencesDictionary = (NSDictionary *)preferencesObject;
 
    // extract list of document noderefs from preferences dictionary
    NSMutableArray *favoriteDocuments = [NSMutableArray array];
    NSString *documentNodeRefsString = [preferencesDictionary valueForKeyPath:kAlfrescoLegacyFavoriteDocuments];
    if (documentNodeRefsString.length > 0)
    {
        favoriteDocuments = [[documentNodeRefsString componentsSeparatedByString:@","] mutableCopy];
        [favoriteDocuments removeObject:@""];
    }
    
    // extract list of folder noderefs from preferences dictionary
    NSMutableArray *favoriteFolders = [NSMutableArray array];
    NSString *folderNodeRefsString = [preferencesDictionary valueForKeyPath:kAlfrescoLegacyFavoriteFolders];
    if (folderNodeRefsString.length > 0)
    {
        favoriteFolders = [[folderNodeRefsString componentsSeparatedByString:@","] mutableCopy];
        [favoriteFolders removeObject:@""];
    }
    
    // return the arrays in a dictionary
    return @{kAlfrescoLegacyFavoriteDocuments: favoriteDocuments, kAlfrescoLegacyFavoriteFolders: favoriteFolders};
}

- (void)updateFavoritesForNode:(AlfrescoNode *)node favoriteData:(NSData *)data completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    NSString *requestString = nil;
    NSURL *url = nil;
    if (node.isDocument)
    {
        requestString = [kAlfrescoLegacyFavoriteDocumentsAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
        url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    }
    else
    {
        requestString = [kAlfrescoLegacyFavoriteFoldersAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
        url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    }
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];    
    [self.session.networkProvider executeRequestWithURL:url
                                                session:self.session
                                            requestBody:data
                                                 method:kAlfrescoHTTPPost
                                        alfrescoRequest:request
                                        completionBlock:^(NSData *data, NSError *error) {
                                            if (error)
                                            {
                                                completionBlock(NO, error);
                                            }
                                            else
                                            {
                                                completionBlock(YES, error);
                                            }
                                        }];
}

- (void)prepareRequestBodyToFavorite:(BOOL)favorite node:(AlfrescoNode *)node completionBlock:(AlfrescoDataCompletionBlock)completionBlock
{
    void (^updateFavoritesList)(NSMutableArray *, BOOL) = ^(NSMutableArray *favorites, BOOL addToFavorites)
    {
        if (addToFavorites)
        {
            if (![[favorites valueForKeyPath:@"identifier"] containsObject:node.identifier])
            {
                [favorites addObject:node];
            }
        }
        else
        {
            NSInteger nodeIndex = [[favorites valueForKeyPath:@"identifier"] indexOfObject:node.identifier];
            if (nodeIndex != NSNotFound)
            {
                [favorites removeObjectAtIndex:nodeIndex];
            }
        }
    };
    
    NSData * (^generateJsonBody)(NSMutableArray *) = ^ NSData * (NSMutableArray *favorites)
    {
        NSArray *favoriteIdentifiers = [favorites valueForKeyPath:@"identifier"];
        NSMutableArray *favoriteIdentifiersWithoutVersionNumber = [NSMutableArray array];

        for (NSString *favoriteIdentifier in favoriteIdentifiers)
        {
            [favoriteIdentifiersWithoutVersionNumber addObject:[self identifierWithoutVersionNumberForIdentifier:favoriteIdentifier]];
        }
        
        NSString *joinedFavoriteIdentifiers = [favoriteIdentifiersWithoutVersionNumber componentsJoinedByString:@","];
        NSString *favoritesAPIKey = node.isDocument ? kAlfrescoLegacyFavoriteDocuments : kAlfrescoLegacyFavoriteFolders;
        NSArray *favoriteKeyComponents = [favoritesAPIKey componentsSeparatedByString:@"."];
        NSDictionary *favoriteKeyComponentDictionaries = nil;
        NSInteger lastKeyComponentIndex = favoriteKeyComponents.count - 1;

        for (NSInteger i = lastKeyComponentIndex; i >= 0; i--)
        {
            NSString *keyComponent = favoriteKeyComponents[i];
            if ([keyComponent isEqualToString:kAlfrescoJSONFavorites])
            {
                favoriteKeyComponentDictionaries = @{keyComponent: joinedFavoriteIdentifiers};
            }
            else if (favoriteKeyComponentDictionaries)
            {
                favoriteKeyComponentDictionaries = @{keyComponent: favoriteKeyComponentDictionaries};
            }
        }
        
        return [NSJSONSerialization dataWithJSONObject:favoriteKeyComponentDictionaries options:NSJSONWritingPrettyPrinted error:nil];
    };
    
    if (node.isDocument)
    {
        [self retrieveFavoriteDocumentsWithCompletionBlock:^(NSArray *array, NSError *error) {
            if (error)
            {
                completionBlock(nil, error);
            }
            else
            {
                NSMutableArray *updatedFavoritesList = array ? [array mutableCopy] : [NSMutableArray array];
                updateFavoritesList(updatedFavoritesList, favorite);
                NSData *jsonData = generateJsonBody(updatedFavoritesList);
                completionBlock(jsonData, error);
            }
        }];
    }
    else
    {
        [self retrieveFavoriteFoldersWithCompletionBlock:^(NSArray *array, NSError *error) {
            if (error)
            {
                completionBlock(nil, error);
            }
            else
            {
                NSMutableArray *updatedFavoritesList = array ? [array mutableCopy] : [NSMutableArray array];
                updateFavoritesList(updatedFavoritesList, favorite);
                NSData *jsonData = generateJsonBody(updatedFavoritesList);
                completionBlock(jsonData, error);
            }
        }];
    }
}

@end
