//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISOperationContext.h"


@implementation CMISOperationContext

@synthesize filterString = _filterString;
@synthesize isIncludeAllowableActions = _isIncludeAllowableActions;
@synthesize isIncluseACLs = _isIncluseACLs;
@synthesize includeRelationShips = _includeRelationShips;
@synthesize isIncludePolicies = _isIncludePolicies;
@synthesize renditionFilterString = _renditionFilterString;
@synthesize maxItemsPerPage = _maxItemsPerPage;
@synthesize skipCount = _skipCount;
@synthesize orderBy = _orderBy;
@synthesize isIncludePathSegments = _isIncludePathSegments;

+ (CMISOperationContext *)defaultOperationContext
{
    CMISOperationContext *defaultContext = [[CMISOperationContext alloc] init];
    defaultContext.filterString = nil;
    defaultContext.isIncludeAllowableActions = YES;
    defaultContext.isIncluseACLs = NO;
    defaultContext.isIncludePolicies = NO;
    defaultContext.includeRelationShips = CMISIncludeRelationshipNone;
    defaultContext.renditionFilterString = nil;
    defaultContext.orderBy = nil;
    defaultContext.isIncludePathSegments = NO;
    defaultContext.maxItemsPerPage = 100;
    defaultContext.skipCount = 0;
    return defaultContext;
}


@end