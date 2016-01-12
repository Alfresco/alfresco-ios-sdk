/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "CMISBrowserBinding.h"
#import "CMISBindingSession.h"
#import "CMISBrowserRepositoryService.h"
#import "CMISBrowserObjectService.h"
#import "CMISBrowserNavigationService.h"
#import "CMISBrowserVersioningService.h"
#import "CMISBrowserDiscoveryService.h"

@interface CMISBrowserBinding ()

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

@implementation CMISBrowserBinding

- (id)initWithSessionParameters:(CMISSessionParameters *)sessionParameters
{
    self = [super init];
    if (self) {
        self.session = [[CMISBindingSession alloc] initWithSessionParameters:sessionParameters];
        
        self.repositoryService = [[CMISBrowserRepositoryService alloc] initWithBindingSession:self.session];
        self.objectService = [[CMISBrowserObjectService alloc] initWithBindingSession:self.session];
        self.navigationService = [[CMISBrowserNavigationService alloc] initWithBindingSession:self.session];
        self.versioningService = [[CMISBrowserVersioningService alloc] initWithBindingSession:self.session];
        self.discoveryService = [[CMISBrowserDiscoveryService alloc] initWithBindingSession:self.session];
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
