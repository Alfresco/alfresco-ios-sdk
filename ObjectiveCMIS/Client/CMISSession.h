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
@protocol CMISSessionAuthenticationDelegate;

@interface CMISSession : NSObject

@property (nonatomic, assign, readonly) BOOL isAuthenticated;
@property (nonatomic, strong, readonly) id<CMISBindingDelegate> binding;

// NOTE: None of these properties should be used until the session is authenticated, until that point they will be nil
@property (nonatomic, strong, readonly) CMISFolder *rootFolder;
@property (nonatomic, strong, readonly) CMISRepositoryInfo *repositoryInfo;

// *** setup ***

// returns an array of CMISRepositoryInfo objects representing the repositories available at the endpoint.
+ (NSArray *)arrayOfRepositories:(CMISSessionParameters *)sessionParameters error:(NSError **)error;

// Returns a CMISSession using the given session parameters.
+ (CMISSession *)sessionWithParameters:(CMISSessionParameters *)sessionParameters;

// Authenticates the session
// TODO: Is this ok? (follows NSURLConnection initWithRequest:delegate) or should
//       there be a separate delegate property for the object as a whole?
//       OR should we combine this with the sessionWithParameters method?
//       i.e. sessionWithParameters:authenticationDelegate?
- (void)authenticateWithDelegate:(id<CMISSessionAuthenticationDelegate>)delegate;

// *** object retrieval ***

- (CMISObject *)retrieveObject:(CMISObjectId *)objectId error:(NSError **)error;

@end


@protocol CMISSessionAuthenticationDelegate <NSObject>

// Sent when authentication of the session is successful
- (void)didAuthenticateSession:(CMISSession *)session;

// Sent when authentication of the session failed
- (void)session:(CMISSession *)session didFailToAuthenticateWithError:(NSError *)error;

@end
