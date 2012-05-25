//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISEnums.h"


@interface CMISOperationContext : NSObject

@property (nonatomic, strong) NSString *filterString;
@property BOOL isIncludeAllowableActions;
@property BOOL isIncluseACLs;
@property CMISIncludeRelationship includeRelationShips;
@property BOOL isIncludePolicies;
@property (nonatomic, strong) NSString *renditionFilterString;
@property NSInteger maxItemsPerPage;
@property NSInteger skipCount;

+ (CMISOperationContext *)defaultOperationContext;

@end