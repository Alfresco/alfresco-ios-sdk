//
// ObjectiveCMIS
//
// Created by Joram Barrez
//


#import "CMISAtomPubVersioningService.h"
#import "CMISAtomPubBaseService+Protected.h"
#import "CMISAtomPubConstants.h"
#import "CMISHttpUtil.h"
#import "CMISAtomFeedParser.h"
#import "CMISObjectConverter.h"


@implementation CMISAtomPubVersioningService

- (CMISObjectData *)retrieveObjectOfLatestVersion:(NSString *)objectId error:(NSError **)error
{
    // Validate params
    if (!objectId)
    {
        *error = [[NSError alloc] init]; // TODO: proper error init
        log(@"Must provide an objectId when retrieving all versions");
    }


    CMISObjectByIdUriBuilder *objectByIdUriBuilder = [self retrieveFromCache:kCMISBindingSessionKeyObjectByIdUriBuilder error:error];
    objectByIdUriBuilder.objectId = objectId;
    objectByIdUriBuilder.returnVersion = LATEST;
    NSURL *objectIdUrl = [objectByIdUriBuilder buildUrl];


    NSData *data = [self executeRequest:objectIdUrl error:error];
    if (data != nil)
    {
        CMISAtomEntryParser *parser = [[CMISAtomEntryParser alloc] initWithData:data];
        if ([parser parseAndReturnError:error])
        {
            return parser.objectData;
        }
    }

    return nil;
}

- (NSArray *)retrieveAllVersions:(NSString *)objectId error:(NSError **)error
{
    // Validate params
    if (!objectId)
    {
        *error = [[NSError alloc] init]; // TODO: proper error init
        log(@"Must provide an objectId when retrieving all versions");
    }

    // Fetch version history link
    CMISObjectData *objectData = [self retrieveObjectInternal:objectId error:error];
    if (*error == nil)
    {
        NSString *versionHistoryLink = [objectData.linkRelations linkHrefForRel:kCMISLinkVersionHistory];
        //[objectData.links objectForKey:kCMISLinkVersionHistory];
        NSData *data = [HttpUtil invokeGETSynchronous:[NSURL URLWithString:versionHistoryLink] withSession:self.session error:error];
        if (*error == nil)
        {
            CMISAtomFeedParser *feedParser = [[CMISAtomFeedParser alloc] initWithData:data];
            if ([feedParser parseAndReturnError:error])
            {
                return feedParser.entries;
            }
        }
    }

    return nil;
}

@end