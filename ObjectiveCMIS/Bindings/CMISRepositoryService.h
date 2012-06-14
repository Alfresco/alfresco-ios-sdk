//
//  CMISRepositoryService.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 20/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISRepositoryInfo.h"

@class CMISTypeDefinition;

@protocol CMISRepositoryService <NSObject>

/**
* Returns an array of CMISRepositoryInfo objects representing the repositories available at the endpoint.
*/
- (NSArray *)retrieveRepositoriesAndReturnError:(NSError **)outError;

/**
* Returns the repository info for the repository with the given id
*/
- (CMISRepositoryInfo *)retrieveRepositoryInfoForId:(NSString *)repositoryId error:(NSError **)outError;

- (CMISTypeDefinition *)retrieveTypeDefinition:(NSString *)typeId error:(NSError **)outError;

@end
