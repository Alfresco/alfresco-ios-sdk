//
//  CMISAtomPubRepositoryService.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 17/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAtomPubRepositoryService.h"
#import "CMISAtomPubBaseService+Protected.h"
#import "CMISConstants.h"
#import "CMISWorkspace.h"
#import "CMISErrors.h"
#import "CMISTypeByIdUriBuilder.h"
#import "CMISHttpUtil.h"
#import "CMISTypeDefinitionAtomEntryParser.h"

@interface CMISAtomPubRepositoryService ()
@property (nonatomic, strong) NSMutableDictionary *repositories;
@end

@interface CMISAtomPubRepositoryService (PrivateMethods)
- (void)retrieveRepositoriesAndReturnError:(NSError **)error;
@end


@implementation CMISAtomPubRepositoryService

@synthesize repositories = _repositories;

- (NSArray *)arrayOfRepositoriesAndReturnError:(NSError **)outError
{
    NSError *internalError = nil;
    [self retrieveRepositoriesAndReturnError:&internalError];
    if (internalError) {
        *outError = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeObjectNotFound];
    }
    return [self.repositories allValues];
}

- (CMISRepositoryInfo *)repositoryInfoForId:(NSString *)repositoryId error:(NSError **)outError
{
    NSError *internalError = nil;
    [self retrieveRepositoriesAndReturnError:&internalError];
    if (internalError) {
        *outError = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeUnauthorized];
    }
    return [self.repositories objectForKey:repositoryId];
}

- (void)retrieveRepositoriesAndReturnError:(NSError **)error
{
    self.repositories = [NSMutableDictionary dictionary];
    NSArray *cmisWorkSpaces = [self retrieveCMISWorkspacesAndReturnError:error];
    for (CMISWorkspace *workspace in cmisWorkSpaces)
    {
        [self.repositories setObject:workspace.repositoryInfo forKey:workspace.repositoryInfo.identifier];
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

    CMISTypeByIdUriBuilder *typeByIdUriBuilder = [self.bindingSession objectForKey:kCMISBindingSessionKeyTypeByIdUriBuilder];
    typeByIdUriBuilder.id = typeId;

    HTTPResponse *response = [HttpUtil invokeGETSynchronous:[typeByIdUriBuilder buildUrl] withSession:self.bindingSession error:outError];

    if (response.data != nil)
    {
        CMISTypeDefinitionAtomEntryParser *parser = [[CMISTypeDefinitionAtomEntryParser alloc] initWithData:response.data];
        if ([parser parseAndReturnError:outError])
        {
            return  parser.typeDefinition;
        }
    }

    return nil;

}

@end
