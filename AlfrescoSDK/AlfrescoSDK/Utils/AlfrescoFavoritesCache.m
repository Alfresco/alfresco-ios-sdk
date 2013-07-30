//
//  AlfrescoFavoritesCache.m
//  AlfrescoSDK
//
//  Created by Mohamad Saeedi on 29/07/2013.
//
//

#import "AlfrescoFavoritesCache.h"
#import "AlfrescoInternalConstants.h"

@interface AlfrescoFavoritesCache ()
@property (nonatomic, strong) NSMutableArray * favoritesCache;
@property (nonatomic, assign, readwrite) BOOL hasMoreFavoriteDocuments;
@property (nonatomic, assign, readwrite) BOOL hasMoreFavoriteFolders;
@property (nonatomic, assign, readwrite) NSInteger totalFavorites;
@end

@implementation AlfrescoFavoritesCache

- (id)init
{
    self = [super init];
    if (nil != self)
    {
        _favoritesCache = [NSMutableArray arrayWithCapacity:0];
        _hasMoreFavoriteDocuments = YES;
        _hasMoreFavoriteFolders = YES;
    }
    return self;
}

+ (id)favoritesCacheForSession:(id<AlfrescoSession>)session
{
    static dispatch_once_t singleDispatchToken;
    static AlfrescoFavoritesCache *cache = nil;
    dispatch_once(&singleDispatchToken, ^{
        cache = [[self alloc] init];
        if (cache)
        {
            NSString *key = [NSString stringWithFormat:@"%@%@",kAlfrescoSessionInternalCache, [AlfrescoFavoritesCache class]];
            [session setObject:cache forParameter:key];
        }
    });
    return cache;
}

- (void)clear
{
    [self.favoritesCache removeAllObjects];
}

- (NSArray *)allFavorites
{
    return self.favoritesCache;
}

- (NSArray *)favoriteDocuments
{
    NSPredicate *favoritePredicate = [NSPredicate predicateWithFormat:@"isDocument == YES"];
    return [self.favoritesCache filteredArrayUsingPredicate:favoritePredicate];
}

- (NSArray *)favoriteFolders
{
    NSPredicate *favoritePredicate = [NSPredicate predicateWithFormat:@"isFolder == YES"];
    return [self.favoritesCache filteredArrayUsingPredicate:favoritePredicate];
}

- (void)addFavorite:(AlfrescoNode *)node
{
    if (nil == node)
    {
        return;
    }
    NSUInteger foundIndex = [self.favoritesCache indexOfObject:node];
    
    if (NSNotFound == foundIndex)
    {
        [self.favoritesCache addObject:node];
    }
    else
    {
        [self.favoritesCache replaceObjectAtIndex:foundIndex withObject:node];
    }
}

- (void)addFavorites:(NSArray *)nodes type:(AlfrescoFavoriteType)type
{
    [self addFavorites:nodes type:type hasMoreFavorites:NO totalFavorites:-1];
}

- (void)removeFavorite:(AlfrescoNode *)node
{
    [self.favoritesCache removeObject:node];
}

- (void)addFavorites:(NSArray *)nodes type:(AlfrescoFavoriteType)type hasMoreFavorites:(BOOL)hasMoreFavorites totalFavorites:(NSInteger)totalFavorites
{
    if (nil == nodes)
    {
        return;
    }
    switch (type)
    {
        case AlfrescoFavoriteDocument:
            self.hasMoreFavoriteDocuments = hasMoreFavorites;
            self.totalFavorites = totalFavorites;
            break;
        case AlfrescoFavoriteFolder:
            self.hasMoreFavoriteFolders = hasMoreFavorites;
            self.totalFavorites = totalFavorites;
            break;
    }
    [nodes enumerateObjectsUsingBlock:^(AlfrescoNode *node, NSUInteger index, BOOL *stop){
        [self addFavorite:node];
    }];
}

/**
 the method returns the first entry found for the identifier.
 */
- (AlfrescoNode *)objectWithIdentifier:(NSString *)identifier
{
    if (!identifier)return nil;
    NSPredicate *idPredicate = [NSPredicate predicateWithFormat:@"identifier == %@",identifier];
    NSArray *results = [self.favoritesCache filteredArrayUsingPredicate:idPredicate];
    return (0 == results.count) ? nil : results[0];
}


@end
