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
        *outError = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISObjectNotFoundError withCMISLocalizedDescription:kCMISObjectNotFoundErrorDescription];
    }
    return [self.repositories allValues];
}

- (CMISRepositoryInfo *)repositoryInfoForId:(NSString *)repositoryId error:(NSError **)outError
{
    NSError *internalError = nil;
    [self retrieveRepositoriesAndReturnError:&internalError];
    if (internalError) {
        *outError = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISUnauthorizedError withCMISLocalizedDescription:kCMISUnauthorizedErrorDescription];
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

@end
