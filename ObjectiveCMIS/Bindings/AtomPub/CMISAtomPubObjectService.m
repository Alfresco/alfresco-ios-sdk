//
//  CMISAtomPubObjectService.m
//
//  Created by Cornwell Gavin on 17/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAtomPubObjectService.h"
#import "CMISAtomPubBaseService+Protected.h"

@implementation CMISAtomPubObjectService

- (CMISObjectData *)retrieveObject:(NSString *)objectId error:(NSError **)error
{
    return [self retrieveObjectInternal:objectId error:error];
}

- (void)writeContentOfCMISObject:(NSString *)objectId toFile:(NSString *)filePath withError:(NSError * *)error
{
    CMISObjectData *objectData = [self retrieveObjectInternal:objectId error:error];

    if (*error == nil)
    {
        // TODO: must be done more efficient, now the whole file is stored in memory!
        NSData *data = [self executeRequest:objectData.contentUrl error:error];
        if (data != nil && *error == nil)
        {
            [data writeToFile:filePath atomically:YES];
        } 
        else
        {
            log(@"Could not fetch data from url %@ : %@", objectData.contentUrl.absoluteString, [*error description]);
        }

    } 
    else
    {
        log(@"Error while retrieving CMIS object for object id '%@' : %@", objectId, [*error description]);
    }
}


@end
