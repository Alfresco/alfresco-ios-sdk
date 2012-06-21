/*
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
 */

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