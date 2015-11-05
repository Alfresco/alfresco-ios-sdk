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

#import "AlfrescoPublicAPIDocumentFolderService.h"
#import "AlfrescoErrors.h"
#import "CMISOperationContext.h"
#import "CMISSession.h"
#import "AlfrescoCMISUtil.h"
#import "CMISDocument.h"
#import "CMISRendition.h"
#import "AlfrescoLog.h"
#import "AlfrescoFileManager.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoFavoritesCache.h"
#import "AlfrescoSortingUtils.h"
#import "AlfrescoURLUtils.h"
#import "AlfrescoObjectConverter.h"
#import "AlfrescoPagingUtils.h"

static const double kFavoritesRequestRateLimit = 0.1; // seconds between requests

@interface AlfrescoPublicAPIDocumentFolderService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) CMISSession *cmisSession;
@property (nonatomic, strong, readwrite) AlfrescoFavoritesCache *favoritesCache;
@property (nonatomic, strong, readwrite) NSString *defaultSortKey;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@end

@implementation AlfrescoPublicAPIDocumentFolderService

- (id)initWithSession:(id<AlfrescoSession>)session
{
    if (self = [super initWithSession:session])
    {
        self.baseApiUrl = [[self.session.baseUrl absoluteString] stringByAppendingString:kAlfrescoPublicAPIPath];
        
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
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    CMISOperationContext *operationContext = [CMISOperationContext defaultOperationContext];
    operationContext.renditionFilterString = @"*";
    request.httpRequest = [self.cmisSession retrieveObject:node.identifier operationContext:operationContext completionBlock:^(CMISObject *cmisObject, NSError *error) {
        if (nil == cmisObject)
        {
            NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:error];
            completionBlock(nil, alfrescoError);
        }
        else if([cmisObject isKindOfClass:[CMISFolder class]])
        {
            NSError *wrongTypeError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderNoThumbnail];
            completionBlock(nil, wrongTypeError);
        }
        else
        {
            NSError *renditionsError = nil;
            CMISDocument *document = (CMISDocument *)cmisObject;
            NSArray *renditions = document.renditions;
            if (!renditions || renditions.count == 0)
            {
                renditionsError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderNoThumbnail];
                completionBlock(nil, renditionsError);
            }
            else
            {
                CMISRendition *thumbnailRendition = nil;
                for (CMISRendition *rendition in renditions)
                {
                    if ([rendition.title isEqualToString:renditionName])
                    {
                        thumbnailRendition = rendition;
                        break;
                    }
                }
                
                if (!thumbnailRendition)
                {
                    // Couldn't find the requested renditionName
                    renditionsError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderNoThumbnail];
                    completionBlock(nil, renditionsError);
                }
                else
                {
                    AlfrescoLogDebug(@"Found %d renditions, thumbnail documentId is %@", renditions.count, thumbnailRendition.renditionDocumentId);
                    NSString *tmpFileExtension = [thumbnailRendition.mimeType isEqualToString:@"image/png"] ? @"png" : @"jpg";
                    NSString *tmpFileName = [[[AlfrescoFileManager sharedManager] temporaryDirectory] stringByAppendingFormat:@"%@.%@", node.name, tmpFileExtension];
                    request.httpRequest = [thumbnailRendition downloadRenditionContentToFile:tmpFileName completionBlock:^(NSError *downloadError) {
                        if (downloadError)
                        {
                            NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:downloadError];
                            completionBlock(nil, alfrescoError);
                        }
                        else
                        {
                            AlfrescoContentFile *contentFile = [[AlfrescoContentFile alloc] initWithUrl:[NSURL fileURLWithPath:tmpFileName] mimeType:@"image/png"];
                            completionBlock(contentFile, nil);
                        }
                    } progressBlock:^(unsigned long long bytesDownloaded, unsigned long long bytesTotal) {
                        AlfrescoLogTrace(@"Download progress, transferred %llu bytes of %llu", bytesDownloaded, bytesTotal);
                    }];
                }
            }
        }
    }];
    return request;
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
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    CMISOperationContext *operationContext = [CMISOperationContext defaultOperationContext];
    operationContext.renditionFilterString = @"*";
    request.httpRequest = [self.cmisSession retrieveObject:node.identifier operationContext:operationContext completionBlock:^(CMISObject *cmisObject, NSError *error) {
        if (nil == cmisObject)
        {
            NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:error];
            completionBlock(NO, alfrescoError);
        }
        else if([cmisObject isKindOfClass:[CMISFolder class]])
        {
            NSError *wrongTypeError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderNoThumbnail];
            completionBlock(NO, wrongTypeError);
        }
        else
        {
            NSError *renditionsError = nil;
            CMISDocument *document = (CMISDocument *)cmisObject;
            NSArray *renditions = document.renditions;
            if (!renditions || renditions.count == 0)
            {
                renditionsError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderNoThumbnail];
                completionBlock(NO, renditionsError);
            }
            else
            {
                CMISRendition *thumbnailRendition = nil;
                for (CMISRendition *rendition in renditions)
                {
                    if ([rendition.title isEqualToString:renditionName])
                    {
                        thumbnailRendition = rendition;
                        break;
                    }
                }
                
                if (!thumbnailRendition)
                {
                    // Couldn't find the requested renditionName
                    renditionsError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderNoThumbnail];
                    completionBlock(NO, renditionsError);
                }
                else
                {
                    AlfrescoLogDebug(@"Found %d renditions, thumbnail documentId is %@", renditions.count, thumbnailRendition.renditionDocumentId);
                    request.httpRequest = [thumbnailRendition downloadRenditionContentToOutputStream:outputStream completionBlock:^(NSError *downloadError) {
                        if (downloadError)
                        {
                            NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:downloadError];
                            completionBlock(NO, alfrescoError);
                        }
                        else
                        {
                            completionBlock(YES, nil);
                        }
                    } progressBlock:^(unsigned long long bytesDownloaded, unsigned long long bytesTotal) {
                        AlfrescoLogTrace(@"Download progress, transferred %llu bytes of %llu", bytesDownloaded, bytesTotal);
                    }];
                }
            }
        }
    }];
    return request;
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

- (AlfrescoRequest *)isFavorite:(AlfrescoNode *)node
              	completionBlock:(AlfrescoFavoritedCompletionBlock)completionBlock
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
                    // we could go back to the server here but typically this method is called for every node
                    // resulting in a large number of requests so we'll presume the node is not a favorite,
                    // if it's state has changed on the server it will get picked up when the cache is rebuilt.
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
            // we could go back to the server here but typically this method is called for every node
            // resulting in a large number of requests so we'll presume the node is not a favorite,
            // if it's state has changed on the server it will get picked up when the cache is rebuilt.
            completionBlock(YES, NO, nil);
        }
    }
    
    return request;
}

- (AlfrescoRequest *)addFavorite:(AlfrescoNode *)node
                 completionBlock:(AlfrescoFavoritedCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoPublicAPIAddFavorite listingContext:nil];
    NSData *bodyData = [self jsonDataForAddingFavorite:node];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    
    [self.session.networkProvider executeRequestWithURL:url
                                                session:self.session
                                            requestBody:bodyData
                                                 method:kAlfrescoHTTPPost
                                        alfrescoRequest:request
                                        completionBlock:^(NSData *data, NSError *error) {
                                            if (error)
                                            {
                                                completionBlock(NO, NO, error);
                                            }
                                            else
                                            {
                                                [self.favoritesCache cacheNode:node favorite:YES];
                                                completionBlock(YES, YES, error);
                                            }
                                        }];
    return request;
}

- (AlfrescoRequest *)removeFavorite:(AlfrescoNode *)node
                    completionBlock:(AlfrescoFavoritedCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *requestString = [kAlfrescoPublicAPIFavorite stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
    NSString *nodeIdWithoutVersionNumber = [AlfrescoObjectConverter nodeRefWithoutVersionID:node.identifier];
    requestString = [requestString stringByReplacingOccurrencesOfString:kAlfrescoNodeRef withString:nodeIdWithoutVersionNumber];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString listingContext:nil];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    
    [self.session.networkProvider executeRequestWithURL:url
                                                session:self.session
                                                 method:kAlfrescoHTTPDelete
                                        alfrescoRequest:request
                                        completionBlock:^(NSData *data, NSError *error) {
                                            if (error)
                                            {
                                                completionBlock(NO, NO, error);
                                            }
                                            else
                                            {
                                                [self.favoritesCache cacheNode:node favorite:NO];
                                                completionBlock(YES, NO, error);
                                            }
                                        }];
    return request;
}

#pragma mark Special Folder Handling

- (AlfrescoRequest *)retrieveHomeFolderWithCompletionBlock:(AlfrescoFolderCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    AlfrescoRepositoryInfo *repoInfo = self.session.repositoryInfo;
    NSNumber *majorVersion = repoInfo.majorVersion;
    if ([majorVersion intValue] < 5)
    {
        // No support for cmis:item on Alfresco versions earlier than 5.0
        return nil;
    }
    
    // Construct the URL
    NSURL *queryURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self.session.baseUrl absoluteString], kAlfrescoPublicAPICMISBrowserPath]];
    
    // POST body
    NSString *queryStatement = [NSString stringWithFormat:@"SELECT cm:homeFolder FROM cm:person WHERE cm:userName = '%@'", self.session.personIdentifier];
    NSString *postBody = [NSString stringWithFormat:@"searchAllVersions=false&skipCount=0&includeAllowableActions=false&maxItems=1&cmisaction=query&includeRelationships=none&succinct=true&statement=%@", queryStatement];
    NSData *postData = [[postBody stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]] dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    __block AlfrescoRequest *alfrescoRequest = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:queryURL session:self.session requestBody:postData method:kAlfrescoHTTPPost alfrescoRequest:alfrescoRequest completionBlock:^(NSData *data, NSError *error) {
        if (data)
        {
            // Looking for results[0].succinctProperties.cm:homeFolder[0]
            NSError *error = nil;
            id object = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            if (object)
            {
                NSString *homeFolderId = object[@"results"][0][@"succinctProperties"][@"cm:homeFolder"][0];
                if (homeFolderId.length > 0)
                {
                    // We have the objectId, so now retrieve the folder itself
                    alfrescoRequest = [self retrieveNodeWithIdentifier:homeFolderId completionBlock:(AlfrescoNodeCompletionBlock)completionBlock];
                }
                else
                {
                    completionBlock(nil, error);
                }
            }
            else
            {
                completionBlock(nil, error);
            }
        }
        else
        {
            completionBlock(nil, error);
        }
    }];
    
    return alfrescoRequest;
}


#pragma mark AlfrescoFavortiesCacheDataDelegate methods

- (AlfrescoRequest *)retrieveFavoriteNodeDataWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    NSString *requestString = [kAlfrescoPublicAPIFavoritesAll stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            // retrieve complete node info for each favorite
            [self favoritesArrayWithData:data completionBlock:completionBlock];
        }
    }];
    
    return request;
}

#pragma mark Overridden methods

- (void)extractMetadataForNode:(AlfrescoNode *)node alfrescoRequest:(AlfrescoRequest *)alfrescoRequest
{
    // MOBSDK-784: We don't need to extract metadata when using the public API as it's done for us, so
    // make this a no-op.
}

- (void)generateThumbnailForNode:(AlfrescoNode *)node alfrescoRequest:(AlfrescoRequest *)alfrescoRequest
{
    // MOBSDK-784: We don't need to generate a thumbnail when using the public API as it's done for us, so
    // make this a no-op.
}

#pragma mark Internal private methods

- (void)favoritesArrayWithData:(NSData *)data completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    NSError *conversionError = nil;
    NSArray *entriesArray = [AlfrescoObjectConverter arrayJSONEntriesFromListData:data error:&conversionError];
    NSMutableArray *resultsArray = [NSMutableArray arrayWithCapacity:entriesArray.count];
    
    if (nil != entriesArray && entriesArray.count > 0)
    {
        NSArray *identifiers = [entriesArray valueForKeyPath:@"entry.targetGuid"];
        __block NSInteger total = identifiers.count;
        int delay = 0;
        
        for (NSString *identifier in identifiers)
        {
            // Rate-limit the requests
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay++ * kFavoritesRequestRateLimit * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self retrieveNodeWithIdentifier:identifier completionBlock:^(AlfrescoNode *node, NSError *error) {
                    if (!error)
                    {
                        [resultsArray addObject:node];
                    }

                    if (--total == 0)
                    {
                        completionBlock(resultsArray, nil);
                    }
                }];
            });
        }
    }
    else
    {
        completionBlock(resultsArray, conversionError);
    }
}

- (NSData *)jsonDataForAddingFavorite:(AlfrescoNode *)node
{
    NSString *nodeIdWithoutVersionNumber = [AlfrescoObjectConverter nodeRefWithoutVersionID:node.identifier];
    NSDictionary *nodeId = @{kAlfrescoJSONGUID: nodeIdWithoutVersionNumber};
    NSDictionary *fileFolder = (node.isDocument) ? @{kAlfrescoJSONFile: nodeId} : @{kAlfrescoJSONFolder: nodeId};
    NSDictionary *jsonDict = @{kAlfrescoJSONTarget: fileFolder};
    NSError *error = nil;
    return [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
}

- (AlfrescoRequest *)fetchFavoriteState:(AlfrescoNode *)node completionBlock:(AlfrescoFavoritedCompletionBlock)completionBlock
{
    NSString *requestString = [kAlfrescoPublicAPIFavorite stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
    requestString = [requestString stringByReplacingOccurrencesOfString:kAlfrescoNodeRef withString:node.identifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString listingContext:nil];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error && error.code != kAlfrescoErrorCodeHTTPResponse)
        {
            [self.favoritesCache cacheNode:node favorite:NO];
            completionBlock(NO, NO, error);
        }
        else
        {
            BOOL favorite = NO;
            if (data != nil)
            {
                // if we get a response body check the favorite is a "file" or "folder" (MOBSDK-746)
                NSError *parseError = nil;
                id jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                if (jsonDictionary != nil)
                {
                    NSString *targetKeyPath = [[NSString alloc] initWithFormat:@"%@.%@", kAlfrescoPublicAPIJSONEntry, kAlfrescoJSONTarget];
                    NSDictionary *targetDictionary = [jsonDictionary valueForKeyPath:targetKeyPath];
                    if (targetDictionary != nil)
                    {
                        // look for "file" entry first
                        NSDictionary *fileDictionary = targetDictionary[kAlfrescoJSONFile];
                        if (fileDictionary != nil)
                        {
                            // node is a favorite document
                            favorite = YES;
                        }
                        else
                        {
                            // look for the "folder" entry
                            NSDictionary *folderDictionary = targetDictionary[kAlfrescoJSONFolder];
                            if (folderDictionary != nil)
                            {
                                // node is a favorite folder
                                favorite = YES;
                            }
                        }
                    }
                }
            }
            
            [self.favoritesCache cacheNode:node favorite:favorite];
            completionBlock(YES, favorite, nil);
        }
    }];
    
    return request;
}

@end
