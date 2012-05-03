//
//  CMISAtomPubNavigationService.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 10/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAtomPubNavigationService.h"
#import "CMISAtomFeedParser.h"
#import "CMISConstants.h"

@implementation CMISAtomPubNavigationService

- (NSArray *)retrieveChildren:(NSString *)objectId error:(NSError **)error
{
    // Get Object for objectId
    id<CMISBinding> binding = (id<CMISBinding>) [self.sessionParameters objectForKey:kCMISSessionKeyBinding];
    CMISObjectData *cmisObjectData = [binding.objectService retrieveObject:objectId error:error];
    NSString *downLink = [cmisObjectData.links objectForKey:@"down"];

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
