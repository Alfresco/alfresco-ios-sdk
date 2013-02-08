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

//used for converting properties. This can be set to a custom object converter
@property (nonatomic, strong, readonly) CMISObjectConverter *objectConverter;

// *** setup ***

// returns an array of CMISRepositoryInfo objects representing the repositories available at the endpoint.
+ (void)arrayOfRepositories:(CMISSessionParameters *)sessionParameters
            completionBlock:(void (^)(NSArray *repositories, NSError *error))completionBlock;


+ (void)connectWithSessionParameters:(CMISSessionParameters *)sessionParameters
                     completionBlock:(void (^)(CMISSession *session, NSError * error))completionBlock;

// *** CMIS operations ***

/**
 * Retrieves the root folder for the repository.
 */
- (void)retrieveRootFolderWithCompletionBlock:(void (^)(CMISFolder *folder, NSError *error))completionBlock;

/**
 * Retrieves the root folder for the repository using the provided operation context.
 */
- (void)retrieveFolderWithOperationContext:(CMISOperationContext *)operationContext
                           completionBlock:(void (^)(CMISFolder *folder, NSError *error))completionBlock;
 
/**
  * Retrieves the object with the given identifier.
  */
- (void)retrieveObject:(NSString *)objectId
       completionBlock:(void (^)(CMISObject *object, NSError *error))completionBlock;

/**
  * Retrieves the object with the given identifier, using the provided operation context.
  */
- (void)retrieveObject:(NSString *)objectId
  withOperationContext:(CMISOperationContext *)operationContext
       completionBlock:(void (^)(CMISObject *object, NSError *error))completionBlock;

/**
  * Retrieves the object for the given path.
  */
- (void)retrieveObjectByPath:(NSString *)path
             completionBlock:(void (^)(CMISObject *object, NSError *error))completionBlock;

 
/**
 * Retrieves the object for the given path, using the provided operation context.
 */
- (void)retrieveObjectByPath:(NSString *)path
        withOperationContext:(CMISOperationContext *)operationContext
             completionBlock:(void (^)(CMISObject *object, NSError *error))completionBlock;

/**
 * Retrieves the definition for the given type.
 */
- (void)retrieveTypeDefinition:(NSString *)typeId 
               completionBlock:(void (^)(CMISTypeDefinition *typeDefinition, NSError *error))completionBlock;
/**
 * Retrieves all objects matching the given cmis query.
 *
 * @return An array of CMISQueryResult objects.
 */
- (void)query:(NSString *)statement searchAllVersions:(BOOL)searchAllVersion
                                      completionBlock:(void (^)(CMISPagedResult *pagedResult, NSError *error))completionBlock;

/**
 * Retrieves all objects matching the given cmis query, as CMISQueryResult objects.
 * and using the parameters provided in the operation context.
 *
 * @return An array of CMISQueryResult objects.
 */
- (void)query:(NSString *)statement searchAllVersions:(BOOL)searchAllVersion
                                     operationContext:(CMISOperationContext *)operationContext
                                      completionBlock:(void (^)(CMISPagedResult *pagedResult, NSError *error))completionBlock;

/**
 * Queries for a specific type of objects.
 * Returns a paged result set, containing CMISObject instances.
 */
- (void)queryObjectsWithTypeid:(NSString *)typeId
               withWhereClause:(NSString *)whereClause
             searchAllVersions:(BOOL)searchAllVersion
              operationContext:(CMISOperationContext *)operationContext
               completionBlock:(void (^)(CMISPagedResult *result, NSError *error))completionBlock;


/**
 * Creates a folder in the provided folder.
 */
- (void)createFolder:(NSDictionary *)properties
            inFolder:(NSString *)folderObjectId
     completionBlock:(void (^)(NSString *objectId, NSError *error))completionBlock;


/**
 * Downloads the content of object with the provided object id to the given path.
 */
- (CMISRequest*)downloadContentOfCMISObject:(NSString *)objectId
                                     toFile:(NSString *)filePath
                            completionBlock:(void (^)(NSError *error))completionBlock
                              progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock;

/**
 * Downloads the content of object with the provided object id to the given stream.
 */
- (CMISRequest*)downloadContentOfCMISObject:(NSString *)objectId
                             toOutputStream:(NSOutputStream*)outputStream
                            completionBlock:(void (^)(NSError *error))completionBlock
                              progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock;

/**
 * Creates a cmis document using the content from the file path.
 */
- (void)createDocumentFromFilePath:(NSString *)filePath
                      withMimeType:(NSString *)mimeType
                    withProperties:(NSDictionary *)properties
                          inFolder:(NSString *)folderObjectId
                   completionBlock:(void (^)(NSString *objectId, NSError *error))completionBlock
                     progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock;

/**
 * Creates a cmis document using the content from the given stream.
 */
- (void)createDocumentFromInputStream:(NSInputStream *)inputStream
                         withMimeType:(NSString *)mimeType
                       withProperties:(NSDictionary *)properties
                             inFolder:(NSString *)folderObjectId
                        bytesExpected:(unsigned long long)bytesExpected
                      completionBlock:(void (^)(NSString *objectId, NSError *error))completionBlock
                        progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock;
@end
