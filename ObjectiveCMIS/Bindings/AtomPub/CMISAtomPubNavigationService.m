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
#import "CMISHttpUtil.h"

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
    HTTPResponse *response = [HttpUtil invokeGETSynchronous:childrenUrl withSession:self.session error:error];
    if (response.data != nil)
    {
        CMISAtomFeedParser *parser = [[CMISAtomFeedParser alloc] initWithData:response.data];
        if ([parser parseAndReturnError:error])
        {
            children = parser.entries;
        }
    }

    return children;
}

- (NSArray *)retrieveParentsForObject:(NSString *)objectId error:(NSError **)error
{
    // Get object data
    CMISObjectData *objectData = [self retrieveObjectInternal:objectId error:error];
    if (*error == nil)
    {
        NSString *upLink = [objectData.linkRelations linkHrefForRel:kCMISLinkRelationUp];

        if (upLink != nil) // root folder does not have uplink!
        {
            NSData *response = [HttpUtil invokeGETSynchronous:[NSURL URLWithString:upLink] withSession:self.session error:error].data;
            if (*error == nil)
            {
                CMISAtomFeedParser *parser = [[CMISAtomFeedParser alloc] initWithData:response];
                if ([parser parseAndReturnError:error])
                {
                    return parser.entries;
                }
            }
        }
    }
    return [NSArray array];
}

@end
