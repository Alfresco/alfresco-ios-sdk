//
//  CMISRepositoryService.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 20/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISRepositoryInfo.h"

@protocol CMISRepositoryService <NSObject>

// Returns an array of CMISRepositoryInfo objects representing the repositories available at the endpoint.
- (NSArray *)arrayOfRepositoriesAndReturnError:(NSError **)outError;

- (CMISRepositoryInfo *)repositoryInfoForId:(NSString *)repositoryId error:(NSError **)outError;

@end
