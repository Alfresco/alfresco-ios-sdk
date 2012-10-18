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

#import <Foundation/Foundation.h>
#import "CMISSessionParameters.h"
#import "CMISRepositoryInfo.h"
#import "CMISBinding.h"
#import "CMISFolder.h"

@class CMISOperationContext;
@class CMISPagedResult;
@class CMISTypeDefinition;
@class CMISObjectConverter;

@interface CMISSession : NSObject

// Flag to indicate whether the session has been authenticated.
@property (nonatomic, assign, readonly) BOOL isAuthenticated;

// The binding object being used for the session.
@property (nonatomic, strong, readonly) id<CMISBinding> binding;

// The parameters used to create this session.
@property (nonatomic, strong) CMISSessionParameters *sessionParameters;

// Information about the repository the session is connected to, will be nil until the session is authenticated.
@property (nonatomic, strong, readonly) CMISRepositoryInfo *repositoryInfo;

// A converter for all kinds of CMIS objects.
@property (nonatomic, strong, readonly) CMISObjectConverter *objectConverter;

#pragma mark Setup and Repository discovery

// returns an array of CMISRepositoryInfo objects representing the repositories available at the endpoint.
+ (NSArray *)arrayOfRepositories:(CMISSessionParameters *)sessionParameters
                           error:(NSError **)error;

// Returns a CMISSession using the given session parameters.
- (id)initWithSessionParameters:(CMISSessionParameters *)sessionParameters;

// Authenticates using the CMISSessionParameters and returns if the authentication was succesful
- (BOOL)authenticateAndReturnError:(NSError **)error;

#pragma mark CMIS operations

/**
 * Retrieves the root folder for the repository.
 */
- (CMISFolder *)retrieveRootFolderAndReturnError:(NSError **)error;

/**
 * Retrieves the root folder for the repository using the provided operation context.
 */
- (CMISFolder *)retrieveFolderWithOperationContext:(CMISOperationContext *)operationContext
                                         withError:(NSError **)error;

/**
  * Retrieves the object with the given identifier.
  */
- (CMISObject *)retrieveObject:(NSString *)objectId error:(NSError **)error;

/**
  * Retrieves the object with the given identifier, using the provided operation context.
  */
- (CMISObject *)retrieveObject:(NSString *)objectId
          withOperationContext:(CMISOperationContext *)operationContext
                         error:(NSError **)error;

/**
  * Retrieves the object for the given path.
  */
- (CMISObject *)retrieveObjectByPath:(NSString *)path
                               error:(NSError **)error;

/**
 * Retrieves the object for the given path, using the provided operation context.
 */
- (CMISObject *)retrieveObjectByPath:(NSString *)path
                withOperationContext:(CMISOperationContext *)operationContext
                               error:(NSError **)error;

/**
 * Retrieves the definition for the given type.
 */
- (CMISTypeDefinition *)retrieveTypeDefinition:(NSString *)typeId
                                          error:(NSError **)error;

/**
 * Retrieves all objects matching the given cmis query.
 *
 * @return An array of CMISQueryResult objects.
 */
- (CMISPagedResult *)query:(NSString *)statement
         searchAllVersions:(BOOL)searchAllVersion
                     error:(NSError **)error;

/**
 * Retrieves all objects matching the given cmis query, as CMISQueryResult objects.
 * and using the parameters provided in the operation context.
 *
 * @return An array of CMISQueryResult objects.
 */
- (CMISPagedResult *)query:(NSString *)statement
         searchAllVersions:(BOOL)searchAllVersion
          operationContext:(CMISOperationContext *)operationContext
                     error:(NSError **)error;

/**
 * Queries for a specific type of objects.
 * Returns a paged result set, containing CMISObject instances.
 */
- (CMISPagedResult *)queryObjectsWithTypeid:(NSString *)typeId
                            withWhereClause:(NSString *)whereClause
                          searchAllVersions:(BOOL)searchAllVersion
                           operationContext:(CMISOperationContext *)operationContext
                                      error:(NSError **)error;
/**
 * Creates a folder in the provided folder.
 */
- (NSString *)createFolder:(NSDictionary *)properties
                  inFolder:(NSString *)folderObjectId
                     error:(NSError **)error;

/**
 * Downloads the content of object with the provided object id to the given path.
 */
- (void)downloadContentOfCMISObject:(NSString *)objectId
                             toFile:(NSString *)filePath
                    completionBlock:(CMISVoidCompletionBlock)completionBlock
                       failureBlock:(CMISErrorFailureBlock)failureBlock
                      progressBlock:(CMISProgressBlock)progressBlock;

/**
 * Creates a cmis document using the content from the file path.
 */
- (void)createDocumentFromFilePath:(NSString *)filePath
                      withMimeType:(NSString *)mimeType
                    withProperties:(NSDictionary *)properties
                          inFolder:(NSString *)folderObjectId
                   completionBlock:(CMISStringCompletionBlock)completionBlock  // The returned id is the object id of the newly created document
                      failureBlock:(CMISErrorFailureBlock)failureBlock
                     progressBlock:(CMISProgressBlock)progressBlock;
@end
