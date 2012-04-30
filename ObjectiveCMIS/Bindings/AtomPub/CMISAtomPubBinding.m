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
#import "CMISWorkspace.h"
#import "ASIHTTPRequest.h"
#import "CMISServiceDocumentParser.h"

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

- (NSArray *)retrieveCMISWorkspacesFromServiceEndpoint;

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

- (id)initWithSessionParameters:(CMISSessionParameters *)sessionParameters
{
    self = [super init];
    if (self)
    {
        _sessionParameters = sessionParameters;

        NSArray *cmisWorkspaces = [self retrieveCMISWorkspacesFromServiceEndpoint];

        _authenticationProvider = self.sessionParameters.authenticationProvider;
        _repositoryService = [[CMISAtomPubRepositoryService alloc] initWithSessionParameters:sessionParameters andWithCMISWorkspaces:cmisWorkspaces];
        _objectService = [[CMISAtomPubObjectService alloc] initWithSessionParameters:sessionParameters andWithCMISWorkspaces:cmisWorkspaces];
        _navigationService = [[CMISAtomPubNavigationService alloc] initWithSessionParameters:sessionParameters andWithCMISWorkspaces:cmisWorkspaces];
    }
    
    return self;
}

- (NSArray *)retrieveCMISWorkspacesFromServiceEndpoint
{
    // Request the service document
    log(@"GET: %@", [self.sessionParameters.atomPubUrl absoluteString]);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:self.sessionParameters.atomPubUrl]; // TODO: Replace ASIHTTPRequest with standard NSURLConnection

    // add authentication to request
    // TODO: deal with authentication providers that require headers or query string params to be added
    [request setUsername:self.sessionParameters.authenticationProvider.username];
    [request setPassword:self.sessionParameters.authenticationProvider.password];

    // send the request
    [request startSynchronous];

    NSError *error = [request error];
    if (error)
    {
        log(@"Http error while retrieving cmis service document : %@", [error description]);
    }
    else
    {
        // Parse the cmis service document
        NSData *data = [request responseData];
        if (data != nil)
        {
            CMISServiceDocumentParser *parser = [[CMISServiceDocumentParser alloc] initWithData:data];
            if ([parser parseAndReturnError:&error])
            {
                return parser.workspaces;
            } else {
                log(@"Error while parsing service document: %@", error.description);
            }
        }
    }

    // TODO: discuss if OK to raise exception here?
    if (error)
    {
        [NSException raise:@"" format:@"Could not parse CMIS service doument: %@", error.description];
    } else {
        [NSException raise:@"" format:@"Could not parse CMIS service doument: not a HTTP nor a xml parsing related error"];
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
