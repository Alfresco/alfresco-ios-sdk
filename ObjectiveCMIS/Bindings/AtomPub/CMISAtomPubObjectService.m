//
//  CMISAtomPubObjectService.m
//
//  Created by Cornwell Gavin on 17/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAtomPubObjectService.h"
#import "CMISAtomPubBaseService+Protected.h"
#import "HttpUtil.h"
#import "CMISAtomEntryWriter.h"
#import "CMISAtomEntryParser.h"

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

- (NSString *)createDocumentFromFilePath:(NSString *)filePath withProperties:(NSDictionary *)properties inFolder:(NSString *)folderObjectId error:(NSError **)error
{
    CMISObjectData *folderData = [self retrieveObjectInternal:folderObjectId error:error];

    if (!*error)
    {
        NSString *downLink = [folderData.links objectForKey:@"down"];
        if (downLink)
        {
            NSURL *downUrl = [NSURL URLWithString:downLink];

            CMISAtomEntryWriter *atomEntryWriter = [[CMISAtomEntryWriter alloc] init];
            atomEntryWriter.filePath = filePath;
            atomEntryWriter.cmisProperties = properties;
            NSData *atomEntry = [atomEntryWriter generateAtomEntry];

            NSData *response = [HttpUtil invokePOST:downUrl
                                         withSession:self.session
                                         body:atomEntry
                                         headers:[NSDictionary dictionaryWithObject:@"application/atom+xml;type=entry" forKey:@"Content-type"]
                                         error:error];

            if (!*error)
            {
                CMISAtomEntryParser *atomEntryParser = [[CMISAtomEntryParser alloc] initWithData:response];
                [atomEntryParser parseAndReturnError:error];
                return atomEntryParser.objectData.identifier;
            }
        }
        else
        {
            log(@"Could not retrieve 'down' link for folder with object id %@", folderObjectId);
        }
    }
    return nil;
}

- (BOOL)deleteObject:(NSString *)objectId allVersions:(BOOL)allVersions error:(NSError * *)error
{
    CMISObjectData *objectData = [self retrieveObjectInternal:objectId error:error];
    if (!*error)
    {
        NSString *selfLink = [objectData.links objectForKey:@"self"];
        if (selfLink)
        {
            NSURL *selfUrl = [NSURL URLWithString:selfLink];
            [HttpUtil invokeDELETE:selfUrl withSession:self.session error:error];

            if (!*error)
            {
                return YES;
            }
        }
        else
        {
            log(@"Could not retrieve 'self' link for object with object id %@", objectId);
        }
    }
    return NO;
}


@end
