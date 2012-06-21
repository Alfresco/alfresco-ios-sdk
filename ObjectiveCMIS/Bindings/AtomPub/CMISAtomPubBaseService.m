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

#import "CMISAtomPubBaseService.h"
#import "CMISAtomPubBaseService+Protected.h"
#import "CMISHttpUtil.h"
#import "CMISServiceDocumentParser.h"
#import "CMISConstants.h"
#import "CMISAtomEntryParser.h"
#import "CMISWorkspace.h"
#import "CMISErrors.h"
#import "CMISObjectByPathUriBuilder.h"
#import "CMISTypeByIdUriBuilder.h"
#import "CMISLinkCache.h"

@interface CMISAtomPubBaseService ()

@property (nonatomic, strong, readwrite) CMISBindingSession *bindingSession;
@property (nonatomic, strong, readwrite) NSURL *atomPubUrl;

@end

@implementation CMISAtomPubBaseService

@synthesize bindingSession = _bindingSession;
@synthesize atomPubUrl = _atomPubUrl;

- (id)initWithBindingSession:(CMISBindingSession *)session
{
    self = [super init];
    if (self)
    {
        self.bindingSession = session;
        
        // pull out and cache all the useful objects for this binding
        self.atomPubUrl = [session objectForKey:kCMISBindingSessionKeyAtomPubUrl];
    }
    return self;
}


#pragma mark -
#pragma mark Protected methods

- (id)retrieveFromCache:(NSString *)cacheKey error:(NSError * *)error
{
    id object = [self.bindingSession objectForKey:cacheKey];

    if (!object)
    {
         // if object is nil, first populate cache
        [self fetchRepositoryInfoAndReturnError:error];
        object = [self.bindingSession objectForKey:cacheKey];
    }

    if (!object && !*error)
    {
        // TODO: proper error initialisation
        *error = [[NSError alloc] init];
        log(@"Could not get object from cache with key '%@'", cacheKey);
    }

    return object;
}

- (void)fetchRepositoryInfoAndReturnError:(NSError * *)error
{
    NSArray *cmisWorkSpaces = [self retrieveCMISWorkspacesAndReturnError:error];

    if (!*error)
    {
        BOOL repositoryFound = NO;
        uint index = 0;
        while (!repositoryFound && index < cmisWorkSpaces.count)
        {
            CMISWorkspace *workspace = [cmisWorkSpaces objectAtIndex:index];
            if ([workspace.repositoryInfo.identifier isEqualToString:self.bindingSession.repositoryId])
            {
                repositoryFound = YES;

                // Cache collections
               [self.bindingSession setObject:[workspace collectionHrefForCollectionType:kCMISAtomCollectionQuery] forKey:kCMISBindingSessionKeyQueryCollection];


                // Cache uri's and uri templates
                CMISObjectByIdUriBuilder *objectByIdUriBuilder = [[CMISObjectByIdUriBuilder alloc] initWithTemplateUrl:workspace.objectByIdUriTemplate];
                [self.bindingSession setObject:objectByIdUriBuilder forKey:kCMISBindingSessionKeyObjectByIdUriBuilder];

                CMISObjectByPathUriBuilder *objectByPathUriBuilder = [[CMISObjectByPathUriBuilder alloc] initWithTemplateUrl:workspace.objectByPathUriTemplate];
                [self.bindingSession setObject:objectByPathUriBuilder forKey:kCMISBindingSessionKeyObjectByPathUriBuilder];

                CMISTypeByIdUriBuilder *typeByIdUriBuilder = [[CMISTypeByIdUriBuilder alloc] initWithTemplateUrl:workspace.typeByIdUriTemplate];
                [self.bindingSession setObject:typeByIdUriBuilder forKey:kCMISBindingSessionKeyTypeByIdUriBuilder];

                [self.bindingSession setObject:workspace.queryUriTemplate forKey:kCMISBindingSessionKeyQueryUri];
            }
            else {
                index++;
           }
        }

        if (!repositoryFound)
        {
            log(@"No matching repository found for repository id %@", self.bindingSession.repositoryId);
            // TODO: populate error properly
            NSString *detailedDescription = [NSString stringWithFormat:@"No matching repository found for repository id %@", self.bindingSession.repositoryId];
            *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeNoRepositoryFound withDetailedDescription:detailedDescription];
        }
    }
}

- (NSArray *)retrieveCMISWorkspacesAndReturnError:(NSError * *)error
{
    if ([self.bindingSession objectForKey:kCMISSessionKeyWorkspaces] == nil)
    {
        NSData *data = [HttpUtil invokeGETSynchronous:self.atomPubUrl withSession:self.bindingSession error:error].data;

        // Uncomment to see the service document
//        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        log(@"Service document: %@", dataString);

        // Parse the cmis service document
        if (data != nil && (!error || error == NULL || *error == nil))
        {
            CMISServiceDocumentParser *parser = [[CMISServiceDocumentParser alloc] initWithData:data];
            if ([parser parseAndReturnError:error])
            {
                [self.bindingSession setObject:parser.workspaces forKey:kCMISSessionKeyWorkspaces];
            } 
            else
            {
                log(@"Error while parsing service document: %@", [*error description]);
            }
        }
    }

    return (NSArray *) [self.bindingSession objectForKey:kCMISSessionKeyWorkspaces];
}

- (CMISObjectData *)retrieveObjectInternal:(NSString *)objectId error:(NSError **)error
{
    return [self retrieveObjectInternal:objectId withReturnVersion:LATEST withFilter:@"" andIncludeRelationShips:CMISIncludeRelationshipNone
                    andIncludePolicyIds:NO andRenditionFilder:nil andIncludeACL:NO
                    andIncludeAllowableActions:YES error:error];
}

- (CMISObjectData *)retrieveObjectInternal:(NSString *)objectId
                         withReturnVersion:(CMISReturnVersion)returnVersion
                                withFilter:(NSString *)filter
                   andIncludeRelationShips:(CMISIncludeRelationship)includeRelationship
                       andIncludePolicyIds:(BOOL)includePolicyIds
                        andRenditionFilder:(NSString *)renditionFilter
                             andIncludeACL:(BOOL)includeACL
                andIncludeAllowableActions:(BOOL)includeAllowableActions
                                     error:(NSError **)error
{
    CMISObjectByIdUriBuilder *objectByIdUriBuilder = [self retrieveFromCache:kCMISBindingSessionKeyObjectByIdUriBuilder error:error];
    objectByIdUriBuilder.objectId = objectId;
    objectByIdUriBuilder.filter = filter;
    objectByIdUriBuilder.includeACL = includeACL;
    objectByIdUriBuilder.includeAllowableActions = includeAllowableActions;
    objectByIdUriBuilder.includePolicyIds = includePolicyIds;
    objectByIdUriBuilder.includeRelationships = includeRelationship;
    objectByIdUriBuilder.renditionFilter = renditionFilter;
    objectByIdUriBuilder.returnVersion = returnVersion;
    NSURL *objectIdUrl = [objectByIdUriBuilder buildUrl];

    // Execute actual call
    CMISObjectData *objectData = nil;
    HTTPResponse *response = [HttpUtil invokeGETSynchronous:objectIdUrl withSession:self.bindingSession error:error];

    if (response.statusCode == 200 && response.data != nil)
    {
        CMISAtomEntryParser *parser = [[CMISAtomEntryParser alloc] initWithData:response.data];
        if ([parser parseAndReturnError:error])
        {
            objectData = parser.objectData;

            // Add links to link cache
            CMISLinkCache *linkCache = [self linkCache];
            [linkCache addLinks:objectData.linkRelations forObjectId:objectData.identifier];

            return objectData;
        }
    }

     return nil;
}

- (CMISObjectData *)retrieveObjectByPathInternal:(NSString *)path
                                      withFilter:(NSString *)filter
                         andIncludeRelationShips:(CMISIncludeRelationship)includeRelationship
                             andIncludePolicyIds:(BOOL)includePolicyIds
                              andRenditionFilder:(NSString *)renditionFilter
                                   andIncludeACL:(BOOL)includeACL
                      andIncludeAllowableActions:(BOOL)includeAllowableActions
                                           error:(NSError **)error
{
    CMISObjectByPathUriBuilder *objectByPathUriBuilder = [self retrieveFromCache:kCMISBindingSessionKeyObjectByPathUriBuilder error:error];
    objectByPathUriBuilder.path = path;
    objectByPathUriBuilder.filter = filter;
    objectByPathUriBuilder.includeACL = includeACL;
    objectByPathUriBuilder.includeAllowableActions = includeAllowableActions;
    objectByPathUriBuilder.includePolicyIds = includePolicyIds;
    objectByPathUriBuilder.includeRelationships = includeRelationship;
    objectByPathUriBuilder.renditionFilter = renditionFilter;

    // Execute actual call
    CMISObjectData *objectData = nil;
    HTTPResponse *response = [HttpUtil invokeGETSynchronous:[objectByPathUriBuilder buildUrl] withSession:self.bindingSession error:error];

    if (response.statusCode == 200 && response.data != nil)
    {
        CMISAtomEntryParser *parser = [[CMISAtomEntryParser alloc] initWithData:response.data];
        if ([parser parseAndReturnError:error])
        {
            objectData = parser.objectData;

            // Add links to link cache
            CMISLinkCache *linkCache = [self linkCache];
            [linkCache addLinks:objectData.linkRelations forObjectId:objectData.identifier];

            return objectData;
        }
    }

    return nil;
}

- (CMISLinkCache *)linkCache{
    CMISLinkCache *linkCache = [self.bindingSession objectForKey:kCMISBindingSessionKeyLinkCache];
    if (linkCache == nil)
    {
        linkCache = [[CMISLinkCache alloc] initWithBindingSession:self.bindingSession];
        [self.bindingSession setObject:linkCache forKey:kCMISBindingSessionKeyLinkCache];
    }
    return linkCache;
}

- (NSString *)loadLinkForObjectId:(NSString *)objectId andRelation:(NSString *)rel error:(NSError **)error
{
    return [self loadLinkForObjectId:objectId andRelation:rel andType:nil error:error];
}

- (NSString *)loadLinkForObjectId:(NSString *)objectId andRelation:(NSString *)rel andType:(NSString *)type error:(NSError **)error
{
    CMISLinkCache *linkCache = [self linkCache];

    // Fetch link from cache
    NSString *link = [linkCache linkForObjectId:objectId andRelation:rel andType:type];
    if (link != nil)
    {
        return link;
    }
    else
    {
        // Fetch object, which will trigger the caching of the links
        NSError *retrievalError = nil;
        [self retrieveObjectInternal:objectId error:&retrievalError];
        if (retrievalError != nil)
        {
            log(@"Could not retrieve object with id %@", objectId);
            if (error && error != NULL && *error == nil)
            {
                *error = [CMISErrors cmisError:&retrievalError withCMISErrorCode:kCMISErrorCodeObjectNotFound];
            }
            return nil;
        }
        else
        {
            link = [linkCache linkForObjectId:objectId andRelation:rel andType:type];
            if (link == nil)
            {
                *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeObjectNotFound
                                     withDetailedDescription:[NSString stringWithFormat:@"Could not find link '%@' for object with id %@", rel, objectId]];
            }
        }
    }
    return link;
}

@end
