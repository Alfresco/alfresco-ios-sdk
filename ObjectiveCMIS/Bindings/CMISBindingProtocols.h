//
//  CMISBindingProtocols.h
//  HybridApp
//
//  Created by Cornwell Gavin on 22/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISRepositoryInfo.h"
#import "CMISObjectData.h"
#import "CMISAuthenticationProvider.h"

// Service Protocols

@protocol CMISAclService <NSObject>
@end


@protocol CMISDiscoveryService <NSObject>
@end


@protocol CMISMultiFilingService <NSObject>
@end


@protocol CMISNavigationService <NSObject>

// retrieve children
- (NSArray *)retrieveChildren:(NSString *)objectId error:(NSError **)error;

@end


@protocol CMISObjectService <NSObject>

@required

// retrieves the object 
- (CMISObjectData *)retrieveObject:(NSString *)objectId error:(NSError **)error;

@end


@protocol CMISPolicyService <NSObject>
@end


@protocol CMISRelationshipService <NSObject>
@end


@protocol CMISRepositoryService <NSObject>

@required

// returns an array of CMISRepositoryInfo objects representing the repositories available at the endpoint.
- (NSArray *)arrayOfRepositories;

- (CMISRepositoryInfo *)repositoryInfoForId:(NSString *)repositoryId;

@end


@protocol CMISVersioningService <NSObject>
@end

// binding delegate protocol

@protocol CMISBindingDelegate <NSObject>

@property (nonatomic, strong, readonly) id<CMISAclService> aclService;
@property (nonatomic, strong, readonly) id<CMISAuthenticationProvider> authenticationProvider;
@property (nonatomic, strong, readonly) id<CMISDiscoveryService> discoveryService;
@property (nonatomic, strong, readonly) id<CMISMultiFilingService> multiFilingService;
@property (nonatomic, strong, readonly) id<CMISObjectService> objectService;
@property (nonatomic, strong, readonly) id<CMISPolicyService> policyService;
@property (nonatomic, strong, readonly) id<CMISRelationshipService> relationshipService;
@property (nonatomic, strong, readonly) id<CMISRepositoryService> repositoryService;
@property (nonatomic, strong, readonly) id<CMISNavigationService> navigationService;
@property (nonatomic, strong, readonly) id<CMISVersioningService> versioningService;

@required

- (void)close;

@optional

- (void)clearAllCaches;

- (void)clearRepositoryCache:(NSString*)repositoryId;

@end
