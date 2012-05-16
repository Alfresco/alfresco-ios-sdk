//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CMISObjectByPathUriBuilder : NSObject

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *filter;
@property BOOL includeAllowableActions;
@property BOOL includePolicyIds;
@property BOOL includeRelationships;
@property BOOL includeACL;
@property (nonatomic, strong) NSString *renditionFilter;

- (id)initWithTemplateUrl:(NSString *)templateUrl;
- (NSURL *)buildUrl;

@end