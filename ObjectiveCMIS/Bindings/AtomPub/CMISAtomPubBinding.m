//
//  CMISAtomPubBinding.m
//  HybridApp
//
//  Created by Cornwell Gavin on 15/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAtomPubBinding.h"
#import "CMISAtomPubRepositoryService.h"
#import "CMISAtomPubObjectService.h"
#import "CMISAtomPubNavigationService.h"
#import "CMISServiceDocumentParser.h"
#import "CMISConstants.h"
#import "HttpUtil.h"

@interface CMISAtomPubBinding ()

@property (nonatomic, strong) CMISSessionParameters *sessionParameters;
@property (nonatomic, strong, readwrite) id<CMISAclService> aclService;
@property (nonatomic, strong, readwrite) id<CMISDiscoveryService> discoveryService;
@property (nonatomic, strong, readwrite) id<CMISMultiFilingService> multiFilingService;
@property (nonatomic, strong, readwrite) id<CMISObjectService> objectService;
@property (nonatomic, strong, readwrite) id<CMISPolicyService> policyService;
@property (nonatomic, strong, readwrite) id<CMISRelationshipService> relationshipService;
@property (nonatomic, strong, readwrite) id<CMISRepositoryService> repositoryService;
@property (nonatomic, strong, readwrite) id<CMISNavigationService> navigationService;
@property (nonatomic, strong, readwrite) id<CMISVersioningService> versioningService;
@property (nonatomic, strong, readwrite) id<CMISAuthenticationProvider> authenticationProvider;

- (NSArray *)retrieveCMISWorkspacesFromServiceDocumentWithError:(NSError * *)error;

@end

@implementation CMISAtomPubBinding

@synthesize sessionParameters = _sessionParameters;
@synthesize aclService = _aclService;
@synthesize discoveryService = _discoveryService;
@synthesize multiFilingService = _multiFilingService;
@synthesize objectService = _objectService;
@synthesize policyService = _policyService;
@synthesize relationshipService = _relationshipService;
@synthesize repositoryService = _repositoryService;
@synthesize navigationService = _navigationService;
@synthesize versioningService = _versioningService;
@synthesize authenticationProvider = _authenticationProvider;

- (id)initWithSessionParameters:(CMISSessionParameters *)sessionParameters withError:(NSError * *)error
{
    self = [super init];
    if (self)
    {
        _sessionParameters = sessionParameters;

        NSArray *cmisWorkspaces = [self retrieveCMISWorkspacesFromServiceDocumentWithError:error];
        [sessionParameters setObject:cmisWorkspaces forKey:kCMISSessionKeyWorkspaces];

        _authenticationProvider = self.sessionParameters.authenticationProvider;
        _repositoryService = [[CMISAtomPubRepositoryService alloc] initWithSessionParameters:sessionParameters];
        _objectService = [[CMISAtomPubObjectService alloc] initWithSessionParameters:sessionParameters];
        _navigationService = [[CMISAtomPubNavigationService alloc] initWithSessionParameters:sessionParameters];
    }
    return self;
}

- (NSArray *)retrieveCMISWorkspacesFromServiceDocumentWithError:(NSError * *)error
{
    NSData *data = [HttpUtil invokeGET:self.sessionParameters.atomPubUrl withSession:self.sessionParameters error:error];

    // Parse the cmis service document
    if (data != nil)
    {
        CMISServiceDocumentParser *parser = [[CMISServiceDocumentParser alloc] initWithData:data];
        if ([parser parseAndReturnError:error])
        {
            return parser.workspaces;
        } else
        {
            log(@"Error while parsing service document: %@", [*error description]);
        }
    }
    return nil;
}


- (void)clearAllCaches
{
    // do nothing for now
}

- (void)clearCacheForRepositoryId:(NSString*)repositoryId
{
    // do nothing for now
}

- (void)close
{
    // do nothing for now
}

@end
