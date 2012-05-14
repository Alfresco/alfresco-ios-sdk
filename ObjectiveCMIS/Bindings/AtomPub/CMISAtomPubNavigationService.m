//
//  CMISAtomPubNavigationService.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 10/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAtomPubNavigationService.h"
#import "CMISAtomPubBaseService+Protected.h"
#import "CMISAtomFeedParser.h"
#import "CMISConstants.h"
#import "CMISAtomPubConstants.h"

@implementation CMISAtomPubNavigationService

- (NSArray *)retrieveChildren:(NSString *)objectId error:(NSError **)error
{
    // Get Object for objectId
    CMISObjectData *cmisObjectData = [self retrieveObjectInternal:objectId error:error];
    NSString *downLink = [cmisObjectData.linkRelations linkHrefForRel:kCMISLinkRelationDown type:kCMISMediaTypeChildren];

    // Get children for object
    NSArray *children = nil;
    NSURL *childrenUrl = [NSURL URLWithString:downLink];
    
    // execute the request
    NSData *data = [self executeRequest:childrenUrl error:error];
    if (data != nil)
    {
        CMISAtomFeedParser *parser = [[CMISAtomFeedParser alloc] initWithData:data];
        if ([parser parseAndReturnError:error])
        {
            children = parser.entries;
        }
    }

    return children;
}

@end
