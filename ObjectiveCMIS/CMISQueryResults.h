//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISEnums.h"

@class CMISObjectList;
@protocol CMISBinding;
@class CMISQueryResult;
@class CMISSession;
@class CMISOperationContext;


@interface CMISQueryResults : NSObject

@property (nonatomic, strong, readonly) NSArray *resultArray;
@property (readonly) BOOL hasMoreItems;
@property (readonly) NSInteger numItems;

- (id)initWithNrOfItems:(NSInteger)numItems andHasMoreItems:(BOOL)hasMoreItems
                                              forQueryWithStatement:(NSString *)statement
                                              andSearchAllVersions:(BOOL)searchAllVersions
                                              andWithOperationContext:(CMISOperationContext *)context
                                              andWithSession:(CMISSession *)session;

- (void)addQueryResult:(CMISQueryResult *)queryResult;

- (CMISQueryResults *)fetchNextPageAndReturnError:(NSError **)error;

@end