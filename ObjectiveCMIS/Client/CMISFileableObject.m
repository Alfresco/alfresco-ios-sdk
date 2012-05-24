//
//  CMISFileableObject.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 21/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISFileableObject.h"
#import "CMISObjectConverter.h"

@implementation CMISFileableObject

- (NSArray *)retrieveParentsAndReturnError:(NSError **)error
{
    NSArray *parentObjectDataArray = [self.binding.navigationService retrieveParentsForObject:self.identifier error:error];

    NSMutableArray *parentFolders = [NSMutableArray array];
    CMISObjectConverter *converter = [[CMISObjectConverter alloc] initWithSession:self.session];
    for (CMISObjectData *parentObjectData in parentObjectDataArray)
    {
        [parentFolders addObject:[converter convertObject:parentObjectData]];
    }

    return parentFolders;
}

@end
