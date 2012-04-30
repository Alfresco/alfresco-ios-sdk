//
//  CMISAtomPubNavigationService.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 10/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAtomPubNavigationService.h"
#import "CMISAtomFeedParser.h"
#import "CMISObjectConverter.h"
#import "CMISFolder.h"

@implementation CMISAtomPubNavigationService

- (NSArray *)retrieveChildren:(NSString *)objectId error:(NSError **)error
{
    // Get Object for objectId
    CMISObjectData *cmisObjectData = [self retrieveObject:objectId error:error];

    NSString *downLink = [cmisObjectData.links objectForKey:@"down"];

    // Get children for object
    NSArray *children = nil;    
    
    // build URL to get object data

    // TODO: store links,retrieve children link and build URL for this object!?

    // TODO: hardcoded url!
//    NSString *urlTemplate = @"http://ec2-79-125-44-131.eu-west-1.compute.amazonaws.com:80/alfresco/service/cmis/s/%@/children?includeAllowableActions=false&includePolicyIds=false&includeRelationships=false&includeACL=false&renditionFilter=cmis:none&includePathSegment=false&maxItems=50";
//
//    NSString *nodeRef = [[objectId stringByReplacingOccurrencesOfString:@"://" withString:@":"]
//                         stringByReplacingOccurrencesOfString:@"/" withString:@"/i/"];
//    NSURL *childrenUrl = [NSURL URLWithString:[NSString stringWithFormat:urlTemplate, nodeRef]];

    NSURL *childrenUrl = [NSURL URLWithString:downLink];
    NSLog(@"CMISAtomPubNavigationService GET: %@", [childrenUrl absoluteString]);
    
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
