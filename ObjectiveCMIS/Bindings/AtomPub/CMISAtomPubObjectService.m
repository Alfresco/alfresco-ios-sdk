//
//  CMISAtomPubObjectService.m
//  HybridApp
//
//  Created by Cornwell Gavin on 17/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAtomPubObjectService.h"
#import "ASIHTTPRequest.h"
#import "CMISAtomEntryParser.h"

@implementation CMISAtomPubObjectService

- (CMISObjectData *)retrieveObject:(NSString *)objectId error:(NSError **)error
{
    // TODO: create dictionary of options to send to server (op context)
    // TODO: build url from object_id template link from repository info

    CMISObjectData *objectData = nil;
    
    // build URL to get object data
    NSString *urlTemplate = @"%@/arg/n?noderef=%@&filter=&includeAllowableActions=false&includePolicyIds=false&includeRelationships=false&includeACL=false&renditionFilter=";
    NSURL *objectIdUrl = [NSURL URLWithString:[NSString stringWithFormat:urlTemplate, [self.sessionParameters.atomPubUrl absoluteString], objectId]];
    NSLog(@"CMISAtomPubObjectService GET: %@", [objectIdUrl absoluteString]);
    
    // execute the request
    NSData *data = [self executeRequest:objectIdUrl error:error];
    if (data != nil)
    {
        CMISAtomEntryParser *parser = [[CMISAtomEntryParser alloc] initWithData:data];
        if ([parser parseAndReturnError:error])
        {
            objectData = parser.objectData;
        }
    }
    
    return objectData;
}

@end
