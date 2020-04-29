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

#import "AlfrescoFavoritesCache.h"
#import "AlfrescoLog.h"
#import "AlfrescoErrors.h"
#import "AlfrescoObjectConverter.h"

@interface AlfrescoFavoritesCacheEntry : NSObject
@property (nonatomic, strong) AlfrescoNode *node;
@property (nonatomic, assign) BOOL favorite;
- (instancetype)initWithNode:(AlfrescoNode *)node favorite:(BOOL)favorite;
@end

@implementation AlfrescoFavoritesCacheEntry
- (instancetype)initWithNode:(AlfrescoNode *)node favorite:(BOOL)favorite
{
    self = [super init];
    if (nil != self)
    {
        self.node = node;
        self.favorite = favorite;
    }
    return self;
}
@end

@interface AlfrescoFavoritesCache ()
@property (nonatomic, assign, readwrite) BOOL isCacheBuilt;
@property (nonatomic, strong, readwrite) NSArray *favoriteNodes;
@property (nonatomic, strong, readwrite) NSArray *favoriteDocuments;
@property (nonatomic, strong, readwrite) NSArray *favoriteFolders;
@property (nonatomic, strong) NSMutableDictionary *internalFavoritesCache;
@property (nonatomic, strong) NSMutableArray *deferredCompletionBlocks;
@end

@implementation AlfrescoFavoritesCache

- (instancetype)init
{
    self = [super init];
    if (nil != self)
    {
        self.isCacheBuilt = NO;
        self.internalFavoritesCache = [NSMutableDictionary dictionary];
        self.deferredCompletionBlocks = [NSMutableArray new];
    }
    return self;
}

/**
 clears all entries in the cache
 */
- (void)clear
{
    self.isCacheBuilt = NO;
    [self.internalFavoritesCache removeAllObjects];
}

- (AlfrescoRequest *)buildCacheWithDelegate:(id<AlfrescoFavoritesCacheDataDelegate>)delegate completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock;
{
    static BOOL isCacheBuilding = NO;
    
    if (completionBlock)
    {
        [self.deferredCompletionBlocks addObject:completionBlock];
    }
    
    if (isCacheBuilding)
    {
        AlfrescoLogDebug(@"Favorites cache building already in progress");
        return nil;
    }

    AlfrescoLogDebug(@"Building favorites cache");

    isCacheBuilding = YES;
    return [self internalBuildCacheWithDelegate:delegate completionBlock:^(BOOL succeeded, NSError *error) {
        for (AlfrescoBOOLCompletionBlock completionBlock in self.deferredCompletionBlocks)
        {
            completionBlock(succeeded, error);
        }
        [self.deferredCompletionBlocks removeAllObjects];
        isCacheBuilding = NO;
    }];
}

- (AlfrescoRequest *)internalBuildCacheWithDelegate:(id<AlfrescoFavoritesCacheDataDelegate>)delegate completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock;
{
    // request the data required to build the initial caches
    AlfrescoLogDebug(@"Requesting favorite node data from delegate");
    return [delegate retrieveFavoriteNodeDataWithCompletionBlock:^(NSArray *array, NSError *error) {
        if (array != nil)
        {
            // add each node to the cache
            for (AlfrescoNode *node in array)
            {
                [self cacheNode:node favorite:YES];
            }
            
            // let the original caller know the cache is built
            self.isCacheBuilt = YES;
            AlfrescoLogDebug(@"Favorites cache successfully built");
            if (completionBlock != NULL)
            {
                completionBlock(YES, nil);
            }
        }
        else
        {
            completionBlock(NO, error);
        }
    }];
}

- (NSArray *)favoriteNodes
{
    // get cache entries that are marked as a favorite
    NSPredicate *favoritedEntriesPredicate = [NSPredicate predicateWithFormat:@"favorite == YES"];
    NSArray *favoritedEntries =  [[self.internalFavoritesCache allValues] filteredArrayUsingPredicate:favoritedEntriesPredicate];
    
    NSMutableArray *nodes = [NSMutableArray arrayWithCapacity:favoritedEntries.count];
    for (AlfrescoFavoritesCacheEntry *entry in favoritedEntries)
    {
        [nodes addObject:entry.node];
    }
    
    return nodes;
}

- (NSArray *)favoriteDocuments
{
    // get cache entries that are documents and marked as a favorite
    NSPredicate *favoriteDocumentsPredicate = [NSPredicate predicateWithFormat:@"(favorite == YES) AND (node.isDocument == YES)"];
    NSArray *favoritedEntries =  [[self.internalFavoritesCache allValues] filteredArrayUsingPredicate:favoriteDocumentsPredicate];
    
    NSMutableArray *nodes = [NSMutableArray arrayWithCapacity:favoritedEntries.count];
    for (AlfrescoFavoritesCacheEntry *entry in favoritedEntries)
    {
        [nodes addObject:entry.node];
    }
    
    return nodes;
}

- (NSArray *)favoriteFolders
{
    // get cache entries that are folders and marked as a favorite
    NSPredicate *favoriteFoldersPredicate = [NSPredicate predicateWithFormat:@"(favorite == YES) AND (node.isFolder == YES)"];
    NSArray *favoritedEntries =  [[self.internalFavoritesCache allValues] filteredArrayUsingPredicate:favoriteFoldersPredicate];
    
    NSMutableArray *nodes = [NSMutableArray arrayWithCapacity:favoritedEntries.count];
    for (AlfrescoFavoritesCacheEntry *entry in favoritedEntries)
    {
        [nodes addObject:entry.node];
    }
    
    return nodes;
}

- (void)cacheNode:(AlfrescoNode *)node favorite:(BOOL)favorite
{
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    
    // remove the version suffix (if present) from the identifier prior to adding to cache
    NSString *cacheKey = [AlfrescoObjectConverter nodeRefWithoutVersionID:node.identifier];
    
    AlfrescoFavoritesCacheEntry *entry = self.internalFavoritesCache[cacheKey];
    if (entry != nil)
    {
        // update node and favorite state in cache entry
        entry.node = node;
        entry.favorite = favorite;
    }
    else
    {
        // create cache entry and add
        entry = [[AlfrescoFavoritesCacheEntry alloc] initWithNode:node favorite:favorite];
        self.internalFavoritesCache[cacheKey] = entry;
    }
    
    AlfrescoLogTrace(@"Cached node: %@, favorite = %@", cacheKey, favorite ? @"YES" : @"NO");
}

- (NSNumber *)isNodeFavorited:(AlfrescoNode *)node
{
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    
    NSNumber *result = nil;
    
    // remove the version suffix (if present) from the identifier prior to checking cache
    NSString *cacheKey = [AlfrescoObjectConverter nodeRefWithoutVersionID:node.identifier];
    
    AlfrescoFavoritesCacheEntry *entry = self.internalFavoritesCache[cacheKey];
    if (entry != nil)
    {
        result = [NSNumber numberWithBool:entry.favorite];
    }
    
    return result;
}

@end
