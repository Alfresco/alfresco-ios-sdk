//
//  CMISSession.h
//  ObjectiveCMIS
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

// *** CMIS operations ***

/**
  * Retrieves the object with the given identifier.
  */
- (CMISObject *)retrieveObject:(NSString *)objectId error:(NSError **)error;

/**
  * Retrieves the object for the given path.
  */
- (CMISObject *)retrieveObjectByPath:(NSString *)path error:(NSError **)error;

/**
 * Retrieves all objects matching the given cmis query.
 *
 * @return An array of CMISQueryResult objects.
 */
- (NSArray *)query:(NSString *)statement searchAllVersions:(BOOL)searchAllVersion error:(NSError * *)error;

- (NSString *)createFolder:(CMISProperties *)properties inFolder:(NSString *)folderObjectId error:(NSError **)error;

- (void)downloadContentOfCMISObject:(NSString *)objectId toFile:(NSString *)filePath
                                                      completionBlock:(CMISContentRetrievalCompletionBlock)completionBlock
                                                      failureBlock:(CMISContentRetrievalFailureBlock)failureBlock;

- (NSString *)createDocumentFromFilePath:(NSString *)filePath withMimeType:(NSString *)mimeType
                                                              withProperties:(CMISProperties *)properties
                                                              inFolder:(NSString *)folderObjectId
                                                              error:(NSError * *)error;

@end
