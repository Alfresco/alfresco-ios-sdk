//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISPagedResult.h"
#import "CMISErrors.h"

/**
 * Implementation of the wrapper class for the returned results
 */
@implementation CMISFetchNextPageBlockResult

@synthesize resultArray = _resultArray;
@synthesize hasMoreItems = _hasMoreItems;
@synthesize numItems = _numItems;

@end

/**
 * Private interface for CMISPagedResult
 */
@interface CMISPagedResult ()

@property (nonatomic, strong, readwrite) NSArray *resultArray;
@property (readwrite) BOOL hasMoreItems;
@property (readwrite) NSInteger numItems;
@property (readwrite) NSInteger maxItems;
@property (readwrite) NSInteger skipCount;

@property (nonatomic, strong) CMISFetchNextPageBlock fetchNextPageBlock;

@end

/**
 * The implementation of the result when fetching a new page.
 */
@implementation CMISPagedResult

@synthesize resultArray = _resultArray;
@synthesize hasMoreItems = _hasMoreItems;
@synthesize numItems = _numItems;
@synthesize fetchNextPageBlock = _fetchNextPageBlock;
@synthesize maxItems = _maxItems;
@synthesize skipCount = _skipCount;


/** Internal init */
- (id)initWithResultArray:(NSArray *)resultArray
             retrievedUsingFetchBlock:(CMISFetchNextPageBlock)fetchNextPageBlock
             andNumItems:(NSInteger)numItems andHasMoreItems:(BOOL)hasMoreItems
             andMaxItems:(NSInteger)maxItems andSkipCount:(NSInteger)skipCount;
{
    self = [super init];
    if (self)
    {
        self.resultArray = resultArray;
        self.fetchNextPageBlock = fetchNextPageBlock;
        self.hasMoreItems = hasMoreItems;
        self.numItems = numItems;
        self.maxItems = maxItems;
        self.skipCount = skipCount;
    }
    return self;
}

+ (CMISPagedResult *)pagedResultUsingFetchBlock:(CMISFetchNextPageBlock)fetchNextPageBlock
                      andLimitToMaxItems:(NSInteger)maxItems andStartFromSkipCount:(NSInteger)skipCount error:(NSError **)error
{
    // Fetch the first requested page
    NSError *internalError = nil;
    CMISFetchNextPageBlockResult *blockResult = fetchNextPageBlock(skipCount, maxItems, &internalError);

    if (internalError != nil)
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeRuntime];
        return nil;
    }

    // Populate a CMISPagedResult with the results of that fetch
    return [[CMISPagedResult alloc] initWithResultArray:blockResult.resultArray
                      retrievedUsingFetchBlock:fetchNextPageBlock
                      andNumItems:blockResult.numItems
                      andHasMoreItems:blockResult.hasMoreItems
                      andMaxItems:maxItems
                      andSkipCount:skipCount];
}

- (CMISPagedResult *)fetchNextPageAndReturnError:(NSError **)error
{
    return [CMISPagedResult pagedResultUsingFetchBlock:self.fetchNextPageBlock
                                    andLimitToMaxItems:self.maxItems
                                    andStartFromSkipCount:(self.skipCount + self.resultArray.count)
                                    error:error];
}

@end