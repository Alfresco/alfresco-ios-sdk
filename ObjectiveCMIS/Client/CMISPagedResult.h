//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Wrapper class for the results of fetching a new page using the block below.
 */
@interface CMISFetchNextPageBlockResult : NSObject

@property (nonatomic, strong) NSArray *resultArray;
@property BOOL hasMoreItems;
@property NSInteger numItems;

@end

typedef CMISFetchNextPageBlockResult * (^CMISFetchNextPageBlock)(int skipCount, int maxItems, NSError ** error);

/**
 * The result of executing an operation which has potentially more results than returned in once.
 */
@interface CMISPagedResult : NSObject

@property (nonatomic, strong, readonly) NSArray *resultArray;
@property (readonly) BOOL hasMoreItems;
@property (readonly) NSInteger numItems;

+ (CMISPagedResult *)pagedResultUsingFetchBlock:(CMISFetchNextPageBlock)fetchNextPageBlock
                                   andLimitToMaxItems:(NSInteger)maxItems
                                   andStartFromSkipCount:(NSInteger)skipCount
                                   error:(NSError **)error;

- (CMISPagedResult *)fetchNextPageAndReturnError:(NSError **)error;


@end