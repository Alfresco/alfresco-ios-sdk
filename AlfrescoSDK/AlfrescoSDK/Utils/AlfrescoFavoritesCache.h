//
//  AlfrescoFavoritesCache.h
//  AlfrescoSDK
//
//  Created by Mohamad Saeedi on 29/07/2013.
//
//

#import <Foundation/Foundation.h>
#import "AlfrescoSession.h"

typedef enum
{
    AlfrescoFavoriteDocument = 0,
    AlfrescoFavoriteFolder,
    AlfrescoFavoriteNode,
    
} AlfrescoFavoriteType;

@interface AlfrescoFavoritesCache : NSObject

@property (nonatomic, assign, readonly) BOOL hasMoreFavoriteDocuments;
@property (nonatomic, assign, readonly) BOOL hasMoreFavoriteFolders;
@property (nonatomic, assign, readonly) NSInteger totalFavorites;

/**
 initialiser
 */
+ (id)favoritesCacheForSession:(id<AlfrescoSession>)session;

/**
 clears all entries in the cache
 */
- (void)clear;

/**
 returns favourites
 */
- (NSArray *)allFavorites;
- (NSArray *)favoriteDocuments;
- (NSArray *)favoriteFolders;

- (void)addFavorite:(AlfrescoNode *)node;
- (void)addFavorites:(NSArray *)nodes type:(AlfrescoFavoriteType)type;

- (void)removeFavorite:(AlfrescoNode *)node;

- (void)addFavorites:(NSArray *)nodes type:(AlfrescoFavoriteType)type hasMoreFavorites:(BOOL)hasMoreFavorites totalFavorites:(NSInteger)totalFavorites;

- (AlfrescoNode *)objectWithIdentifier:(NSString *)identifier;

@end
