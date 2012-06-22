/*
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
 */

#import "CMISAtomPubVersioningService.h"
#import "CMISAtomPubBaseService+Protected.h"
#import "CMISAtomPubConstants.h"
#import "CMISHttpUtil.h"
#import "CMISAtomFeedParser.h"
#import "CMISErrors.h"
#import "CMISURLUtil.h"

@implementation CMISAtomPubVersioningService

- (CMISObjectData *)retrieveObjectOfLatestVersion:(NSString *)objectId
                                            major:(BOOL)major
                                           filter:(NSString *)filter
                             includeRelationShips:(CMISIncludeRelationship)includeRelationships
                                 includePolicyIds:(BOOL)includePolicyIds
                                  renditionFilter:(NSString *)renditionFilter
                                       includeACL:(BOOL)includeACL
                          includeAllowableActions:(BOOL)includeAllowableActions
                                            error:(NSError **)error;
{
    return [self retrieveObjectInternal:objectId withReturnVersion:(major ? LATEST_MAJOR : LATEST)
                          withFilter:filter andIncludeRelationShips:includeRelationships
                          andIncludePolicyIds:includePolicyIds andRenditionFilder:renditionFilter
                          andIncludeACL:includeACL andIncludeAllowableActions:includeAllowableActions error:error];
}

- (NSArray *)retrieveAllVersions:(NSString *)objectId filter:(NSString *)filter
         includeAllowableActions:(BOOL)includeAllowableActions error:(NSError * *)error;
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
    NSString *versionHistoryLink = [self loadLinkForObjectId:objectId andRelation:kCMISLinkVersionHistory error:&internalError];
    if (internalError) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeObjectNotFound];
        return nil;
    }

    if (filter != nil)
    {
        versionHistoryLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterFilter withValue:filter toUrlString:versionHistoryLink];
    }
    versionHistoryLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludeAllowableActions
                                withValue:(includeAllowableActions ? @"true" : @"false") toUrlString:versionHistoryLink];

    // Execute call
    NSData *data = [HttpUtil invokeGETSynchronous:[NSURL URLWithString:versionHistoryLink] 
                                      withSession:self.bindingSession error:&internalError].data;

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