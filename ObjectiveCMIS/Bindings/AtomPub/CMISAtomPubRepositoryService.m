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

#import "CMISAtomPubRepositoryService.h"
#import "CMISAtomPubBaseService+Protected.h"
#import "CMISWorkspace.h"
#import "CMISErrors.h"
#import "CMISTypeByIdUriBuilder.h"
#import "CMISHttpUtil.h"
#import "CMISTypeDefinitionAtomEntryParser.h"

#define DEFAULT_TYPE_DEFINITION_CACHE_SIZE 50

@interface CMISAtomPubRepositoryService ()

@property (nonatomic, strong) NSMutableDictionary *repositories;
@property (nonatomic, strong) NSCache *typeDefinitionCache;

@end

@implementation CMISAtomPubRepositoryService

@synthesize repositories = _repositories;

- (id)initWithBindingSession:(CMISBindingSession *)session
{
    self = [super initWithBindingSession:session];
    if (self)
    {
        [self createTypeDefinitionCache:session];
    }
    return self;
}

- (void)createTypeDefinitionCache:(CMISBindingSession *)session
{
    self.typeDefinitionCache = [[NSCache alloc] init];

    id cacheSize = [session objectForKey:kCMISSessionParameterTypeDefinitionCacheSize];
    if (cacheSize != nil)
    {
        if ([cacheSize isKindOfClass:[NSNumber class]])
        {
            self.typeDefinitionCache.countLimit = [(NSNumber *) cacheSize unsignedIntValue];
        }
        else
        {
            log(@"Invalid object set for %@ session parameter. Ignoring and using default instead", kCMISSessionParameterTypeDefinitionCacheSize);
        }
    }

    if (self.typeDefinitionCache.countLimit <= 0)
    {
        self.typeDefinitionCache.countLimit = DEFAULT_TYPE_DEFINITION_CACHE_SIZE;
    }
}


- (NSArray *)retrieveRepositoriesAndReturnError:(NSError **)outError
{
    NSError *internalError = nil;
    [self internalRetrieveRepositoriesAndReturnError:&internalError];
    if (internalError) {
        *outError = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeObjectNotFound];
    }
    return [self.repositories allValues];
}

- (CMISRepositoryInfo *)retrieveRepositoryInfoForId:(NSString *)repositoryId error:(NSError **)outError
{
    NSError *internalError = nil;
    [self internalRetrieveRepositoriesAndReturnError:&internalError];
    if (internalError) {
        *outError = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeInvalidArgument];
    }
    return [self.repositories objectForKey:repositoryId];
}

- (void)internalRetrieveRepositoriesAndReturnError:(NSError **)error
{
    self.repositories = [NSMutableDictionary dictionary];
    NSArray *cmisWorkSpaces = [self retrieveCMISWorkspacesAndReturnError:error];
    if (cmisWorkSpaces != nil)
    {
        for (CMISWorkspace *workspace in cmisWorkSpaces)
        {
            [self.repositories setObject:workspace.repositoryInfo forKey:workspace.repositoryInfo.identifier];
        }
    }
}

- (CMISTypeDefinition *)retrieveTypeDefinition:(NSString *)typeId error:(NSError **)outError
{
    if (typeId == nil)
    {
        log(@"Parameter typeId is required");
        *outError = [[NSError alloc] init]; // TODO: proper error init
        return nil;
    }

    // First, check cache
    if ([self.typeDefinitionCache objectForKey:typeId] != nil)
    {
        return [self.typeDefinitionCache objectForKey:typeId];
    }

    // Otherwise fetch type definition
    CMISTypeByIdUriBuilder *typeByIdUriBuilder = [self.bindingSession objectForKey:kCMISBindingSessionKeyTypeByIdUriBuilder];
    typeByIdUriBuilder.id = typeId;

    HTTPResponse *response = [HttpUtil invokeGETSynchronous:[typeByIdUriBuilder buildUrl] withSession:self.bindingSession error:outError];

    if (response.data != nil)
    {
        CMISTypeDefinitionAtomEntryParser *parser = [[CMISTypeDefinitionAtomEntryParser alloc] initWithData:response.data];
        if ([parser parseAndReturnError:outError])
        {
            CMISTypeDefinition *typeDefinition = parser.typeDefinition;

            // Store it in the cache for future reference
            [self.typeDefinitionCache setObject:typeDefinition forKey:typeId];

            return typeDefinition;
        }
    }

    return nil;

}

@end
