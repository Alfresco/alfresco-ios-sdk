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
#import "CMISErrors.h"

@implementation CMISAtomPubVersioningService

- (CMISObjectData *)retrieveObjectOfLatestVersion:(NSString *)objectId error:(NSError **)error
{
    // Validate params
    if (!objectId)
    {
        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeObjectNotFound withDetailedDescription:nil];
        log(@"Must provide an objectId when retrieving all versions");
        return nil;
    }

    //retrieveFromCache is one of the few methods that declares CMIS errors inside
    CMISObjectByIdUriBuilder *objectByIdUriBuilder = [self retrieveFromCache:kCMISBindingSessionKeyObjectByIdUriBuilder error:error];
    if (error && error != NULL && *error != nil) {
        return nil;
    }
    objectByIdUriBuilder.objectId = objectId;
    objectByIdUriBuilder.returnVersion = LATEST;
    NSURL *objectIdUrl = [objectByIdUriBuilder buildUrl];

    NSError *internalError = nil;


    NSData *data = [HttpUtil invokeGETSynchronous:objectIdUrl withSession:self.session error:&internalError].data;
    if (internalError || data == nil) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeConnection];
        return nil;
    }
    CMISAtomEntryParser *parser = [[CMISAtomEntryParser alloc] initWithData:data];
    if (![parser parseAndReturnError:&internalError])
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeVersioning];
        return nil;
    }
    return parser.objectData;
}

- (NSArray *)retrieveAllVersions:(NSString *)objectId error:(NSError **)error
{
    // Validate params
    if (!objectId)
    {
        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeObjectNotFound withDetailedDescription:nil];
        log(@"Must provide an objectId when retrieving all versions");
        return nil;
    }

    // Fetch version history link
    NSError *internalError = nil;
    CMISObjectData *objectData = [self retrieveObjectInternal:objectId error:&internalError];
    if (internalError) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeObjectNotFound];
        return nil;
    }
    NSString *versionHistoryLink = [objectData.linkRelations linkHrefForRel:kCMISLinkVersionHistory];
    NSData *data = [HttpUtil invokeGETSynchronous:[NSURL URLWithString:versionHistoryLink] 
                                      withSession:self.session error:&internalError].data;
    if (internalError) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeConnection];
        return nil;
    }
    CMISAtomFeedParser *feedParser = [[CMISAtomFeedParser alloc] initWithData:data];
    if (![feedParser parseAndReturnError:&internalError])
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeVersioning];
        return nil;
    }
    return feedParser.entries;
}

@end