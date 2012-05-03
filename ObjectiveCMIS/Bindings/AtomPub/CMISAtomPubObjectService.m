//
//  CMISAtomPubObjectService.m
//
//  Created by Cornwell Gavin on 17/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAtomPubObjectService.h"
#import "CMISAtomEntryParser.h"
#import "CMISWorkspace.h"
#import "CMISObjectByIdUriBuilder.h"
#import "CMISConstants.h"

@implementation CMISAtomPubObjectService

- (CMISObjectData *)retrieveObject:(NSString *)objectId error:(NSError **)error
{
    // build URL to get object data
    NSArray *cmisWorkSpaces = [self retrieveCMISWorkspacesWithError:error];

    // TODO: discuss what to do with multiple workspaces. Is this even possible?
    NSString *urlTemplate = [(CMISWorkspace *)[cmisWorkSpaces objectAtIndex:0] objectByIdUriTemplate];
    CMISObjectByIdUriBuilder *objectByIdUriBuilder = [[CMISObjectByIdUriBuilder alloc] initWithTemplateUrl:urlTemplate];
    objectByIdUriBuilder.objectId = objectId;
    NSURL *objectIdUrl = [objectByIdUriBuilder buildUrl];

    // Execute actual call
    CMISObjectData *objectData = nil;
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

- (void)writeContentOfCMISObject:(NSString *)objectId toFile:(NSString *)filePath withError:(NSError * *)error
{
    CMISObjectData *objectData = [self retrieveObject:objectId error:error];

    if (*error == nil)
    {
        // TODO: must be done more efficient, now the whole file is stored in memory!
        NSData *data = [self executeRequest:objectData.contentUrl error:error];
        if (data != nil && *error == nil)
        {
            [data writeToFile:filePath atomically:YES];
        } else
        {
            log(@"Could not fetch data for object id %@ : %@", objectId, [*error description]);
        }

    } else
    {
        log(@"Error while retrieving CMIS object for object id %@ : %@", objectId, [*error description]);
    }
}


@end
