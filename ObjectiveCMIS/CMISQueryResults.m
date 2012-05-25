//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISQueryResults.h"
#import "CMISQueryResult.h"
#import "CMISSession.h"
#import "CMISOperationContext.h"

@interface CMISQueryResults ()

@property (nonatomic, strong, readwrite) NSArray *resultArray;
@property (nonatomic, strong, readwrite) NSMutableArray *internalResultArray;
@property (readwrite) BOOL hasMoreItems;
@property (readwrite) NSInteger numItems;

// Properties used for fetching the next page
@property (nonatomic, strong) NSString *statement;
@property BOOL searchAllVersions;
@property (nonatomic, strong) CMISOperationContext *context;
@property (nonatomic, strong) CMISSession *session;

@end

@implementation CMISQueryResults

@synthesize hasMoreItems = _hasMoreItems;
@synthesize numItems = _numItems;
@synthesize resultArray = _resultArray;
@synthesize internalResultArray = _internalResultArray;
@synthesize statement = _statement;
@synthesize searchAllVersions = _searchAllVersions;
@synthesize context = _context;
@synthesize session = _session;

- (NSArray *)resultArray
{
    return self.internalResultArray;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.internalResultArray = [NSMutableArray array];
        self.numItems = 0;
        self.hasMoreItems = NO;
    }
    return self;
}

- (id)initWithNrOfItems:(NSInteger)numItems andHasMoreItems:(BOOL)hasMoreItems
                                              forQueryWithStatement:(NSString *)statement
                                              andSearchAllVersions:(BOOL)searchAllVersions
                                              andWithOperationContext:(CMISOperationContext *)context
                                              andWithSession:(CMISSession *)session
{
    self = [self init];
    if (self)
    {
        self.numItems = numItems;
        self.hasMoreItems = hasMoreItems;
        self.statement = statement;
        self.searchAllVersions = searchAllVersions;
        self.context = context;
        self.session = session;
    }
    return self;
}

- (void)addQueryResult:(CMISQueryResult *)queryResult
{
    [self.internalResultArray addObject:queryResult];
}

- (CMISQueryResults *)fetchNextPageAndReturnError:(NSError **)error
{
    if (self.hasMoreItems)
    {
        return [self.session query:self.statement searchAllVersions:self.searchAllVersions
                  operationContext:self.context error:error];

    }
    else
    {
        return [[CMISQueryResults alloc] init];
    }
}


@end