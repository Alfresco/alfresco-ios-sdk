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

#import <Foundation/Foundation.h>
#import "AlfrescoSession.h"

typedef NS_ENUM(NSInteger, AlfrescoFavoriteType)
{
    AlfrescoFavoriteDocument = 0,
    AlfrescoFavoriteFolder,
    AlfrescoFavoriteNode,
    
};

@protocol AlfrescoFavoritesCacheDataDelegate <NSObject>
- (AlfrescoRequest *)retrieveFavoriteNodeDataWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock;
@end

@interface AlfrescoFavoritesCache : NSObject

@property (nonatomic, assign, readonly) BOOL isCacheBuilt;
@property (nonatomic, strong, readonly) NSArray *favoriteNodes;
@property (nonatomic, strong, readonly) NSArray *favoriteDocuments;
@property (nonatomic, strong, readonly) NSArray *favoriteFolders;

/**
 initialiser.
 */
- (instancetype)initWithFavoritesCacheDataDelegate:(id<AlfrescoFavoritesCacheDataDelegate>)favoritesCacheDataDelegate;

/**
 Build the cache.
 */
- (AlfrescoRequest *)buildCacheWithCompletionBlock:(AlfrescoBOOLCompletionBlock)completionBlock;

/**
 Caches the given node with given flag. If the node already exists in the cache it's favortie state
 will be updated otherwise the node is added to the cache with the given state.
 */
- (void)cacheNode:(AlfrescoNode *)node favorite:(BOOL)favorite;

/**
 Determines whether the given node has been favorited. If the node is in the cache an NSNumber object
 is returned representing the state, if nil is returned the node is not known to the cache.
 */
- (NSNumber *)isNodeFavorited:(AlfrescoNode *)node;

/**
 clears all entries in the cache.
 */
- (void)clear;

@end
