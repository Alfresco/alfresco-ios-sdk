//
//  CMISSession.h
//  HybridApp
//
//  Created by Cornwell Gavin on 10/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISSessionParameters.h"
#import "CMISRepositoryInfo.h"
#import "CMISBinding.h"
#import "CMISFolder.h"

@interface CMISSession : NSObject

// Flag to indicate whether the session has been authenticated.
@property (nonatomic, assign, readonly) BOOL isAuthenticated;

// The binding object being used for the session.
@property (nonatomic, strong, readonly) id<CMISBinding> binding;

// The root folder of the repository the session is connected to, will be nil until the session is authenticated.
@property (nonatomic, strong, readonly) CMISFolder *rootFolder;

// Information about the repository the session is connected to, will be nil until the session is authenticated.
@property (nonatomic, strong, readonly) CMISRepositoryInfo *repositoryInfo;

// *** setup ***

// returns an array of CMISRepositoryInfo objects representing the repositories available at the endpoint.
+ (NSArray *)arrayOfRepositories:(CMISSessionParameters *)sessionParameters error:(NSError **)error;

// Returns a CMISSession using the given session parameters.
- (id)initWithSessionParameters:(CMISSessionParameters *)sessionParameters;

// Authenticates using the CMISSessionParameters and returns if the authentication was succesful
- (BOOL)authenticateAndReturnError:(NSError **)error;

// *** object retrieval ***

// Retrieves the object with the given identifier
- (CMISObject *)retrieveObject:(NSString *)objectId error:(NSError **)error;

@end
