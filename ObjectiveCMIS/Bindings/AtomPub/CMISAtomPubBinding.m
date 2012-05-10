//
//  CMISAtomPubBinding.m
//  HybridApp
//
//  Created by Cornwell Gavin on 15/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAtomPubBinding.h"
#import "CMISBindingSession.h"
#import "CMISAtomPubRepositoryService.h"
#import "CMISAtomPubObjectService.h"
#import "CMISAtomPubNavigationService.h"
#import "CMISAtomPubVersioningService.h"

@interface CMISAtomPubBinding ()

@property (nonatomic, strong) CMISBindingSession *session;
@property (nonatomic, strong, readwrite) id<CMISAclService> aclService;
@property (nonatomic, strong, readwrite) id<CMISDiscoveryService> discoveryService;
@property (nonatomic, strong, readwrite) id<CMISMultiFilingService> multiFilingService;
@property (nonatomic, strong, readwrite) id<CMISObjectService> objectService;
@property (nonatomic, strong, readwrite) id<CMISPolicyService> policyService;
@property (nonatomic, strong, readwrite) id<CMISRelationshipService> relationshipService;
@property (nonatomic, strong, readwrite) id<CMISRepositoryService> repositoryService;
@property (nonatomic, strong, readwrite) id<CMISNavigationService> navigationService;
@property (nonatomic, strong, readwrite) id<CMISVersioningService> versioningService;

@end

@implementation CMISAtomPubBinding

@synthesize session = _session;
@synthesize aclService = _aclService;
@synthesize discoveryService = _discoveryService;
@synthesize multiFilingService = _multiFilingService;
@synthesize objectService = _objectService;
@synthesize policyService = _policyService;
@synthesize relationshipService = _relationshipService;
@synthesize repositoryService = _repositoryService;
@synthesize navigationService = _navigationService;
@synthesize versioningService = _versioningService;

- (id)initWithSessionParameters:(CMISSessionParameters *)sessionParameters
{
    self = [super init];
    if (self)
    {
        self.session = [[CMISBindingSession alloc] initWithSessionParameters:sessionParameters];
        
        self.repositoryService = [[CMISAtomPubRepositoryService alloc] initWithBindingSession:self.session];
        self.objectService = [[CMISAtomPubObjectService alloc] initWithBindingSession:self.session];
        self.navigationService = [[CMISAtomPubNavigationService alloc] initWithBindingSession:self.session];
        self.versioningService = [[CMISAtomPubVersioningService alloc] initWithBindingSession:self.session];
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
