//
//  CMISFileableObject.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 21/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISFileableObject.h"
#import "CMISObjectConverter.h"
#import "CMISOperationContext.h"

@implementation CMISFileableObject

- (NSArray *)retrieveParentsAndReturnError:(NSError **)error
{
    return [self retrieveParentsWithOperationContext:[CMISOperationContext defaultOperationContext] andReturnError:error];
}

- (NSArray *)retrieveParentsWithOperationContext:(CMISOperationContext *)operationContext andReturnError:(NSError **)error
{
    NSArray *parentObjectDataArray = [self.binding.navigationService retrieveParentsForObject:self.identifier
                         withFilter:operationContext.filterString
           withIncludeRelationships:operationContext.includeRelationShips
                withRenditionFilter:operationContext.renditionFilterString
        withIncludeAllowableActions:operationContext.isIncludeAllowableActions
     withIncludeRelativePathSegment:operationContext.isIncludePathSegments
                              error:error];

    NSMutableArray *parentFolders = [NSMutableArray array];
    CMISObjectConverter *converter = [[CMISObjectConverter alloc] initWithSession:self.session];
    for (CMISObjectData *parentObjectData in parentObjectDataArray)
    {
        [parentFolders addObject:[converter convertObject:parentObjectData]];
    }

    return parentFolders;
}

@end
