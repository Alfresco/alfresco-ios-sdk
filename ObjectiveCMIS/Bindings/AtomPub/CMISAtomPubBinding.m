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
    if (self = [super init]) 
    {
        self.sessionParameters = sessionParameters;
        
        self.authenticationProvider = self.sessionParameters.authenticationProvider;
        self.repositoryService = [[CMISAtomPubRepositoryService alloc] initWithSessionParameters:self.sessionParameters];
        self.objectService = [[CMISAtomPubObjectService alloc] initWithSessionParameters:self.sessionParameters];
        self.navigationService = [[CMISAtomPubNavigationService alloc] initWithSessionParameters:self.sessionParameters];
    }
    
    return self;
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
