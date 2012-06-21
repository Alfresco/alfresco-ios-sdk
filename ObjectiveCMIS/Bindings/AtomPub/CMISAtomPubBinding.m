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

#import "CMISAtomPubBinding.h"
#import "CMISBindingSession.h"
#import "CMISAtomPubRepositoryService.h"
#import "CMISAtomPubObjectService.h"
#import "CMISAtomPubNavigationService.h"
#import "CMISAtomPubVersioningService.h"
#import "CMISAtomPubDiscoveryService.h"

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
        self.discoveryService = [[CMISAtomPubDiscoveryService alloc] initWithBindingSession:self.session];
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
