//
//  CMISBinding.h
//  HybridApp
//
//  Created by Cornwell Gavin on 10/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISAclService.h"
#import "CMISDiscoveryService.h"
#import "CMISMultiFilingService.h"
#import "CMISObjectService.h"
#import "CMISPolicyService.h"
#import "CMISRelationshipService.h"
#import "CMISRepositoryService.h"
#import "CMISNavigationService.h"
#import "CMISVersioningService.h"
#import "CMISAuthenticationProvider.h"

@protocol CMISBinding <NSObject>

// The ACL service object for the binding
@property (nonatomic, strong, readonly) id<CMISAclService> aclService;

// The discovery service object for the binding
@property (nonatomic, strong, readonly) id<CMISDiscoveryService> discoveryService;

// The multi filing service object for the binding
@property (nonatomic, strong, readonly) id<CMISMultiFilingService> multiFilingService;

// The object service object for the binding
@property (nonatomic, strong, readonly) id<CMISObjectService> objectService;

// The policy service object for the binding
@property (nonatomic, strong, readonly) id<CMISPolicyService> policyService;

// The relationship service object for the binding
@property (nonatomic, strong, readonly) id<CMISRelationshipService> relationshipService;

// The repository service object for the binding
@property (nonatomic, strong, readonly) id<CMISRepositoryService> repositoryService;

// The navigation service object for the binding
@property (nonatomic, strong, readonly) id<CMISNavigationService> navigationService;

// The versioning service object for the binding
@property (nonatomic, strong, readonly) id<CMISVersioningService> versioningService;

// The authentication delegate object
@property (nonatomic, strong, readonly) id<CMISAuthenticationProvider> authenticationProvider;

- (void)close;

@optional

- (void)clearAllCaches;

- (void)clearCacheForRepositoryId:(NSString*)repositoryId;

@end
