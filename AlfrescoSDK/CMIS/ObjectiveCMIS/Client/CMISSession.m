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

#import "CMISSession.h"
#import "CMISConstants.h"
#import "CMISObjectConverter.h"
#import "CMISStandardAuthenticationProvider.h"
#import "CMISBindingFactory.h"
#import "CMISObjectList.h"
#import "CMISQueryResult.h"
#import "CMISErrors.h"
#import "CMISOperationContext.h"
#import "CMISRequest.h"
#import "CMISPagedResult.h"
#import "CMISTypeDefinition.h"
#import "CMISDefaultNetworkProvider.h"
#import "CMISLog.h"

@interface CMISSession ()
@property (nonatomic, strong, readwrite) CMISObjectConverter *objectConverter;
@property (nonatomic, assign, readwrite, getter = isAuthenticated) BOOL authenticated;
@property (nonatomic, strong, readwrite) id<CMISBinding> binding;
@property (nonatomic, strong, readwrite) CMISRepositoryInfo *repositoryInfo;
@property (nonatomic, strong, readwrite) NSMutableDictionary *typeCache;
// Returns a CMISSession using the given session parameters.
- (id)initWithSessionParameters:(CMISSessionParameters *)sessionParameters;

// Authenticates using the CMISSessionParameters and returns if the authentication was successful
- (CMISRequest*)authenticateWithCompletionBlock:(void (^)(CMISSession *session, NSError * error))completionBlock;
@end

@interface CMISSession (PrivateMethods)
- (BOOL)authenticateAndReturnError:(NSError **)error;
@end

@implementation CMISSession

#pragma mark -
#pragma mark Setup

+ (CMISRequest*)arrayOfRepositories:(CMISSessionParameters *)sessionParameters completionBlock:(void (^)(NSArray *repositories, NSError *error))completionBlock
{
    CMISSession *session = [[CMISSession alloc] initWithSessionParameters:sessionParameters];
    
    // TODO: validate session parameters?
    
    // return list of repositories
    return [session.binding.repositoryService retrieveRepositoriesWithCompletionBlock:completionBlock];
}

+ (CMISRequest*)connectWithSessionParameters:(CMISSessionParameters *)sessionParameters
                     completionBlock:(void (^)(CMISSession *session, NSError * error))completionBlock
{
    CMISSession *session = [[CMISSession alloc] initWithSessionParameters:sessionParameters];
    if (session) {
        return [session authenticateWithCompletionBlock:completionBlock];
    } else {
        completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument
                                             detailedDescription:@"Not enough session parameters to connect"]);
        return nil;
    }
}

#pragma internal authentication methods

- (id)initWithSessionParameters:(CMISSessionParameters *)sessionParameters
{
    self = [super init];
    if (self) {
        self.sessionParameters = sessionParameters;
        self.authenticated = NO;
    
        // setup authentication provider if not present
        if (self.sessionParameters.authenticationProvider == nil) {
            NSString *username = self.sessionParameters.username;
            NSString *password = self.sessionParameters.password;
            if (username == nil || password == nil) {
                CMISLogError(@"No username or password provided for standard authentication provider");
                return nil;
            }
            
            self.sessionParameters.authenticationProvider = [[CMISStandardAuthenticationProvider alloc] initWithUsername:username
                                                                                                                password:password];
        }

        if (self.sessionParameters.networkProvider == nil) {
            self.sessionParameters.networkProvider = [[CMISDefaultNetworkProvider alloc] init];
        }
        
        // create the binding the session will use
        CMISBindingFactory *bindingFactory = [[CMISBindingFactory alloc] init];
        self.binding = [bindingFactory bindingWithParameters:sessionParameters];

        id objectConverterClassValue = [self.sessionParameters objectForKey:kCMISSessionParameterObjectConverterClassName];
        if (objectConverterClassValue != nil && [objectConverterClassValue isKindOfClass:[NSString class]]) {
            NSString *objectConverterClassName = (NSString *)objectConverterClassValue;
            CMISLogDebug(@"Using a custom object converter class: %@", objectConverterClassName);
            self.objectConverter = [[NSClassFromString(objectConverterClassName) alloc] initWithSession:self];
        } else { //default
            self.objectConverter = [[CMISObjectConverter alloc] initWithSession:self];
        }
        
        self.typeCache = [[NSMutableDictionary alloc] init]; //TODO this typeCache should be replaced by a binding specific type definition cache
    
        // TODO: setup locale
        // TODO: setup default session parameters
        // TODO: setup caches
    }
    
    return self;
}

- (CMISRequest*)authenticateWithCompletionBlock:(void (^)(CMISSession *session, NSError * error))completionBlock
{
    // TODO: validate session parameters, extract the checks below?
    
    // check repository id is present
    if (self.sessionParameters.repositoryId == nil) {
        NSError *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument
                                         detailedDescription:@"Must provide repository id"];
        CMISLogError(@"Error: %@", error.description);
        completionBlock(nil, error);
        return nil;
    }
    
    if (self.sessionParameters.authenticationProvider == nil) {
        NSError *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeUnauthorized detailedDescription:@"Must provide authentication provider"];
        CMISLogError(@"Error: %@", error.description);
        completionBlock(nil, error);
        return nil;
    }
    
    // TODO: use authentication provider to make sure we have enough credentials, it may need to make another call to get a ticket or do handshake i.e. NTLM.
    
    // get repository info
    return [self.binding.repositoryService retrieveRepositoryInfoForId:self.sessionParameters.repositoryId completionBlock:^(CMISRepositoryInfo *repositoryInfo, NSError *error) {
        self.repositoryInfo = repositoryInfo;
        if (self.repositoryInfo == nil) {
            if (error) {
                completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeNoRepositoryFound]);
            } else {
                completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeNoRepositoryFound
                                                     detailedDescription:[NSString stringWithFormat:@"Invalid repository id provided: %@", self.sessionParameters.repositoryId]]);
            }
        } else {
            // no errors have occurred so set authenticated flag and return success flag
            self.authenticated = YES;
            completionBlock(self, nil);
        }
    }];
}


#pragma mark CMIS operations

- (CMISRequest*)retrieveRootFolderWithCompletionBlock:(void (^)(CMISFolder *folder, NSError *error))completionBlock
{
    return [self retrieveFolderWithOperationContext:[CMISOperationContext defaultOperationContext] completionBlock:completionBlock];
}

- (CMISRequest*)retrieveFolderWithOperationContext:(CMISOperationContext *)operationContext completionBlock:(void (^)(CMISFolder *folder, NSError *error))completionBlock
{
    NSString *rootFolderId = self.repositoryInfo.rootFolderId;
    return [self retrieveObject:rootFolderId operationContext:operationContext completionBlock:^(CMISObject *rootFolder, NSError *error) {
        if (rootFolder != nil && ![rootFolder isKindOfClass:[CMISFolder class]]) {
            completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeRuntime detailedDescription:@"Root folder object is not a folder!"]);
        } else {
            completionBlock((CMISFolder *)rootFolder, error);
        }
    }];
}

- (CMISRequest*)retrieveCheckedOutDocumentsWithCompletionBlock:(void (^)(CMISPagedResult *result, NSError *error))completionBlock
{
    return [self retrieveCheckedOutDocumentsWithOperationContext:[CMISOperationContext defaultOperationContext] completionBlock:completionBlock];
}

- (CMISRequest*)retrieveCheckedOutDocumentsWithOperationContext:(CMISOperationContext *)operationContext
                                                completionBlock:(void (^)(CMISPagedResult *result, NSError *error))completionBlock
{
    CMISRequest *request = [[CMISRequest alloc] init];
    CMISFetchNextPageBlock fetchNextPageBlock = ^(int skipCount, int maxItems, CMISFetchNextPageBlockCompletionBlock pageBlockCompletionBlock)
    {
        // Fetch results through navigationService
        CMISRequest * checkedoutRequest = [self.binding.navigationService retrieveCheckedOutDocumentsInFolder:nil
                                                                                 orderBy:operationContext.orderBy
                                                                                  filter:operationContext.filterString
                                                                           relationships:operationContext.relationships
                                                                         renditionFilter:operationContext.renditionFilterString
                                                                 includeAllowableActions:operationContext.includeAllowableActions
                                                                               skipCount:[NSNumber numberWithInt:skipCount]
                                                                                maxItems:[NSNumber numberWithInt:maxItems]
                                                                         completionBlock:^(CMISObjectList *objectList, NSError *error) {
                                                                             if (error) {
                                                                                 pageBlockCompletionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeConnection]);
                                                                             } else {
                                                                                 CMISFetchNextPageBlockResult *result = [[CMISFetchNextPageBlockResult alloc] init];
                                                                                 result.hasMoreItems = objectList.hasMoreItems;
                                                                                 result.numItems = objectList.numItems;
                                                                                 
                                                                                 [self.objectConverter convertObjects:objectList.objects
                                                                                                      completionBlock:^(NSArray *objects, NSError *error) {
                                                                                                          result.resultArray = objects;
                                                                                                          pageBlockCompletionBlock(result, error);
                                                                                                      }];
                                                                             }
                                                                         }];
        
        // set the underlying request object on the object returned to the original caller
        request.httpRequest = checkedoutRequest.httpRequest;
    };
    
    [CMISPagedResult pagedResultUsingFetchBlock:fetchNextPageBlock
                                limitToMaxItems:operationContext.maxItemsPerPage
                             startFromSkipCount:operationContext.skipCount
                                completionBlock:^(CMISPagedResult *result, NSError *error) {
                                    if (error) {
                                        completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeRuntime]);
                                    } else {
                                        completionBlock(result, nil);
                                    }
                                }];
    return request;
}

- (CMISRequest*)retrieveObject:(NSString *)objectId completionBlock:(void (^)(CMISObject *object, NSError *error))completionBlock
{
    return [self retrieveObject:objectId operationContext:[CMISOperationContext defaultOperationContext] completionBlock:completionBlock];
}

- (CMISRequest*)retrieveObject:(NSString *)objectId
      operationContext:(CMISOperationContext *)operationContext
       completionBlock:(void (^)(CMISObject *object, NSError *error))completionBlock
{
    if (objectId == nil) {
        completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument detailedDescription:@"Must provide object id"]);
        return nil;
    }

    // TODO: cache the object

    return [self.binding.objectService retrieveObject:objectId
                                               filter:operationContext.filterString
                                        relationships:operationContext.relationships
                                     includePolicyIds:operationContext.includePolicies
                                      renditionFilter:operationContext.renditionFilterString
                                           includeACL:operationContext.includeACLs
                              includeAllowableActions:operationContext.includeAllowableActions
                                      completionBlock:^(CMISObjectData *objectData, NSError *error) {
                                            if (error) {
                                                completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeObjectNotFound]);
                                            } else {
                                                CMISObject *object = nil;
                                                if (objectData) {
                                                    [self.objectConverter convertObject:objectData
                                                                        completionBlock:^(CMISObject *object, NSError *error) {
                                                                            completionBlock(object, error);
                                                    }];
                                                } else {
                                                    completionBlock(object, nil);
                                                }
                                            }
                                        }];
}

- (CMISRequest*)retrieveObjectByPath:(NSString *)path completionBlock:(void (^)(CMISObject *object, NSError *error))completionBlock
{
    return [self retrieveObjectByPath:path operationContext:[CMISOperationContext defaultOperationContext] completionBlock:completionBlock];
}

- (CMISRequest*)retrieveObjectByPath:(NSString *)path
            operationContext:(CMISOperationContext *)operationContext
             completionBlock:(void (^)(CMISObject *object, NSError *error))completionBlock
{
    return [self.binding.objectService retrieveObjectByPath:path
                                              filter:operationContext.filterString
                                       relationships:operationContext.relationships
                                    includePolicyIds:operationContext.includePolicies
                                     renditionFilter:operationContext.renditionFilterString
                                          includeACL:operationContext.includeACLs
                             includeAllowableActions:operationContext.includeAllowableActions
                                     completionBlock:^(CMISObjectData *objectData, NSError *error) {
                                        if (objectData != nil && error == nil) {
                                            [self.objectConverter convertObject:objectData
                                                                completionBlock:^(CMISObject *object, NSError *error) {
                                                                    completionBlock(object, error);
                                                                }];
                                         } else {
                                             if (error == nil) {
                                                 error = [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeObjectNotFound]; 
                                             }
                                             completionBlock(nil, error);
                                         }
                                     }];
}

- (CMISRequest*)retrieveDocumentOfLatestVersion:(NSString *)objectId completionBlock:(void (^)(CMISDocument *document, NSError *error))completionBlock
{
    return [self retrieveDocumentOfLatestVersion:objectId
                                operationContext:[CMISOperationContext defaultOperationContext]
                                 completionBlock:completionBlock];
}

- (CMISRequest*)retrieveDocumentOfLatestVersion:(NSString *)objectId operationContext:(CMISOperationContext*)operationContext completionBlock:(void (^)(CMISDocument *document, NSError *error))completionBlock
{
    return [self retrieveDocumentOfLatestVersion:objectId
                                operationContext:operationContext
                                           major:NO completionBlock:completionBlock];
}

- (CMISRequest*)retrieveDocumentOfLatestVersion:(NSString *)objectId operationContext:(CMISOperationContext*)operationContext major:(BOOL)major completionBlock:(void (^)(CMISDocument *document, NSError *error))completionBlock
{
    return [self.binding.versioningService retrieveObjectOfLatestVersion:objectId
                                                                   major:major
                                                                  filter:operationContext.filterString
                                                           relationships:operationContext.relationships
                                                        includePolicyIds:operationContext.includePolicies
                                                         renditionFilter:operationContext.renditionFilterString
                                                              includeACL:operationContext.includeACLs
                                                 includeAllowableActions:operationContext.includeAllowableActions
                                                         completionBlock:^(CMISObjectData *objectData, NSError *error) {
                                                             if (objectData != nil && error == nil) {
                                                                 [self.objectConverter convertObject:objectData
                                                                                     completionBlock:^(CMISObject *object, NSError *error) {
                                                                                         completionBlock((CMISDocument*)object, error);
                                                                                     }];
                                                             } else {
                                                                 if (error == nil) {
                                                                     error = [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeObjectNotFound];
                                                                 }
                                                                 completionBlock(nil, error);
                                                             }
                                                         }];
}

- (CMISRequest*)retrieveTypeDefinition:(NSString *)typeId completionBlock:(void (^)(CMISTypeDefinition *typeDefinition, NSError *error))completionBlock
{
    id typeDefinition = [self.typeCache objectForKey:typeId];
    if (typeDefinition) {
        if (typeDefinition == [NSNull null]) {
            completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeObjectNotFound detailedDescription:nil]);
        } else {
            completionBlock(typeDefinition, nil);
        }
        return nil;
    }
    
    return [self.binding.repositoryService retrieveTypeDefinition:typeId completionBlock:^(CMISTypeDefinition *typeDefinition, NSError *error) {
        if (typeDefinition) {
            [self.typeCache setObject:typeDefinition forKey:typeId];
        } else if ([error.domain isEqualToString:kCMISErrorDomainName] && error.code == kCMISErrorCodeObjectNotFound) {
            // Negative type cache
            [self.typeCache setObject:[NSNull null] forKey:typeId];
        }
        completionBlock(typeDefinition, error);
    }];
}

- (CMISRequest*)queryStatement:(CMISQueryStatement *)queryStatement searchAllVersions:(BOOL)searchAllVersion
      completionBlock:(void (^)(CMISPagedResult *pagedResult, NSError *error))completionBlock {
        return [self query:[queryStatement queryString]
        searchAllVersions:searchAllVersion
          completionBlock:completionBlock];
}

- (CMISRequest*)queryStatement:(CMISQueryStatement *)queryStatement searchAllVersions:(BOOL)searchAllVersion
     operationContext:(CMISOperationContext *)operationContext
      completionBlock:(void (^)(CMISPagedResult *pagedResult, NSError *error))completionBlock {
        return [self query:[queryStatement queryString]
         searchAllVersions:searchAllVersion
          operationContext:operationContext
           completionBlock:completionBlock];
}

- (CMISRequest*)query:(NSString *)statement searchAllVersions:(BOOL)searchAllVersion completionBlock:(void (^)(CMISPagedResult *pagedResult, NSError *error))completionBlock
{
    return [self query:statement
     searchAllVersions:searchAllVersion
      operationContext:[CMISOperationContext defaultOperationContext]
       completionBlock:completionBlock];
}

- (CMISRequest*)query:(NSString *)statement searchAllVersions:(BOOL)searchAllVersion
                                     operationContext:(CMISOperationContext *)operationContext
                                      completionBlock:(void (^)(CMISPagedResult *pagedResult, NSError *error))completionBlock
{
    CMISRequest *request = [[CMISRequest alloc] init];
    CMISFetchNextPageBlock fetchNextPageBlock = ^(int skipCount, int maxItems, CMISFetchNextPageBlockCompletionBlock pageBlockCompletionBlock){
        // Fetch results through discovery service
       CMISRequest *queryRequest = [self.binding.discoveryService query:statement
                                                  searchAllVersions:searchAllVersion
                                                  relationships:operationContext.relationships
                                                  renditionFilter:operationContext.renditionFilterString
                                                  includeAllowableActions:operationContext.includeAllowableActions
                                                  maxItems:[NSNumber numberWithInt:maxItems]
                                                  skipCount:[NSNumber numberWithInt:skipCount]
                                                  completionBlock:^(CMISObjectList *objectList, NSError *error) {
                                                      if (error) {
                                                          pageBlockCompletionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeRuntime]);
                                                      } else {
                                                          // Fill up return result
                                                          CMISFetchNextPageBlockResult *result = [[CMISFetchNextPageBlockResult alloc] init];
                                                          result.hasMoreItems = objectList.hasMoreItems;
                                                          result.numItems = objectList.numItems;
                                                          
                                                          NSMutableArray *resultArray = [[NSMutableArray alloc] init];
                                                          result.resultArray = resultArray;
                                                          for (CMISObjectData *objectData in objectList.objects) {
                                                              [resultArray addObject:[CMISQueryResult queryResultUsingCmisObjectData:objectData session:self]];
                                                          }
                                                          pageBlockCompletionBlock(result, nil);
                                                      }
                                                  }];
        
        // set the underlying request object on the object returned to the original caller
        request.httpRequest = queryRequest.httpRequest;
    };

    [CMISPagedResult pagedResultUsingFetchBlock:fetchNextPageBlock
                                limitToMaxItems:operationContext.maxItemsPerPage
                             startFromSkipCount:operationContext.skipCount
                                completionBlock:^(CMISPagedResult *result, NSError *error) {
                                    // Return nil and populate error in case something went wrong
                                    if (error) {
                                        completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeRuntime]);
                                    } else {
                                        completionBlock(result, nil);
                                    }
                                }];
    return request;
}

- (CMISRequest*)queryObjectsWithTypeDefinition:(CMISTypeDefinition *)typeDefinition
                           whereClause:(NSString *)whereClause
                     searchAllVersions:(BOOL)searchAllVersion
                      operationContext:(CMISOperationContext *)operationContext
                       completionBlock:(void (^)(CMISPagedResult *result, NSError *error))completionBlock
{
    // Creating the cmis query using the input params
    NSMutableString *statement = [[NSMutableString alloc] init];
    
    // Filter
    [statement appendFormat:@"SELECT %@", (operationContext.filterString != nil ? operationContext.filterString : @"*")];
    
    // Type
    [statement appendFormat:@" FROM %@", typeDefinition.queryName];
    
    // Where
    if (whereClause != nil) {
        [statement appendFormat:@" WHERE %@", whereClause];
    }
    
    // Order by
    if (operationContext.orderBy != nil) {
        [statement appendFormat:@" ORDER BY %@", operationContext.orderBy];
    }
    
    CMISRequest *request = [[CMISRequest alloc] init];
    
    // Fetch block for paged results
    CMISFetchNextPageBlock fetchNextPageBlock = ^(int skipCount, int maxItems, CMISFetchNextPageBlockCompletionBlock pageBlockCompletionBlock)
    {
        // Fetch results through discovery service
        CMISRequest *queryRequest = [self.binding.discoveryService query:statement
                                     searchAllVersions:searchAllVersion
                                         relationships:operationContext.relationships
                                       renditionFilter:operationContext.renditionFilterString
                               includeAllowableActions:operationContext.includeAllowableActions
                                              maxItems:[NSNumber numberWithInt:maxItems]
                                             skipCount:[NSNumber numberWithInt:skipCount]
                                       completionBlock:^(CMISObjectList *objectList, NSError *error) {
                                 if (error) {
                                     pageBlockCompletionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeRuntime]);
                                 } else {
                                     // Fill up return result
                                     CMISFetchNextPageBlockResult *result = [[CMISFetchNextPageBlockResult alloc] init];
                                     result.hasMoreItems = objectList.hasMoreItems;
                                     result.numItems = objectList.numItems;
                                     
                                     [self.objectConverter convertObjects:objectList.objects
                                                          completionBlock:^(NSArray *objects, NSError *error) {
                                                              result.resultArray = objects;
                                                              pageBlockCompletionBlock(result, error);
                                                          }];
                                 }
                             }];
        
        // set the underlying request object on the object returned to the original caller
        request.httpRequest = queryRequest.httpRequest;
    };
    
    [CMISPagedResult pagedResultUsingFetchBlock:fetchNextPageBlock
                                limitToMaxItems:operationContext.maxItemsPerPage
                             startFromSkipCount:operationContext.skipCount
                                completionBlock:^(CMISPagedResult *result, NSError *error) {
                                    // Return nil and populate error in case something went wrong
                                    if (error) {
                                        completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeRuntime]);
                                    } else {
                                        completionBlock(result, nil);
                                    }
                                }];
    return request;
}

- (CMISRequest*)queryObjectsWithTypeid:(NSString *)typeId
                           whereClause:(NSString *)whereClause
                     searchAllVersions:(BOOL)searchAllVersion
                      operationContext:(CMISOperationContext *)operationContext
                       completionBlock:(void (^)(CMISPagedResult *result, NSError *error))completionBlock
{
    return [self retrieveTypeDefinition:typeId
                        completionBlock:^(CMISTypeDefinition *typeDefinition, NSError *internalError) {
                            if (internalError != nil) {
                                NSError *error = [CMISErrors cmisError:internalError cmisErrorCode:kCMISErrorCodeRuntime];
                                completionBlock(nil, error);
                            } else {
                                [self queryObjectsWithTypeDefinition:typeDefinition
                                                         whereClause:whereClause
                                                   searchAllVersions:searchAllVersion
                                                    operationContext:operationContext
                                                     completionBlock:completionBlock];
                            }
                        }];
}

- (CMISRequest*)queryObjectsWithTypeid:(NSString *)typeId
                        whereStatement:(CMISQueryStatement *)whereStatement
                     searchAllVersions:(BOOL)searchAllVersion
                      operationContext:(CMISOperationContext *)operationContext
                       completionBlock:(void (^)(CMISPagedResult *result, NSError *error))completionBlock
{
    return [self retrieveTypeDefinition:typeId
                 completionBlock:^(CMISTypeDefinition *typeDefinition, NSError *internalError) {
                     if (internalError != nil) {
                         NSError *error = [CMISErrors cmisError:internalError cmisErrorCode:kCMISErrorCodeRuntime];
                         completionBlock(nil, error);
                     } else {
                         [self queryObjectsWithTypeid:typeId
                                          whereClause:[whereStatement queryString]
                                    searchAllVersions:searchAllVersion
                                     operationContext:operationContext
                                      completionBlock:completionBlock];
                     }
                 }];
}

- (CMISRequest*)createFolder:(NSDictionary *)properties
            inFolder:(NSString *)folderObjectId
     completionBlock:(void (^)(NSString *objectId, NSError *error))completionBlock
{
    CMISRequest *request = [[CMISRequest alloc] init];
    [self.objectConverter convertProperties:properties
                            forObjectTypeId:[properties objectForKey:kCMISPropertyObjectTypeId]
                            completionBlock:^(CMISProperties *convertedProperties, NSError *error) {
                               if (error) {
                                   completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeRuntime]);
                               } else {
                                  CMISRequest *createRequest = [self.binding.objectService createFolderInParentFolder:folderObjectId
                                                                               properties:convertedProperties
                                                                          completionBlock:^(NSString *objectId, NSError *error) {
                                                                              completionBlock(objectId, error);
                                                                          }];
                                   // set the underlying request object on the object returned to the original caller
                                   request.httpRequest = createRequest.httpRequest;
                               }
                           }];
    return request;
}

- (CMISRequest*)downloadContentOfCMISObject:(NSString *)objectId
                                     toFile:(NSString *)filePath
                            completionBlock:(void (^)(NSError *error))completionBlock
                              progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
{
    return [self downloadContentOfCMISObject:objectId
                                      toFile:filePath
                                      offset:nil
                                      length:nil
                             completionBlock:completionBlock
                               progressBlock:progressBlock];
}

- (CMISRequest*)downloadContentOfCMISObject:(NSString *)objectId
                                     toFile:(NSString *)filePath
                                     offset:(NSDecimalNumber*)offset
                                     length:(NSDecimalNumber*)length
                            completionBlock:(void (^)(NSError *error))completionBlock
                              progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
{
    return [self.binding.objectService downloadContentOfObject:objectId
                                                      streamId:nil
                                                        toFile:filePath
                                                        offset:nil
                                                        length:nil
                                               completionBlock:completionBlock
                                                 progressBlock:progressBlock];
}

- (CMISRequest*)downloadContentOfCMISObject:(NSString *)objectId
                             toOutputStream:(NSOutputStream *)outputStream
                            completionBlock:(void (^)(NSError *error))completionBlock
                              progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
{
    return [self downloadContentOfCMISObject:objectId
                              toOutputStream:outputStream
                                      offset:nil
                                      length:nil
                             completionBlock:completionBlock
                               progressBlock:progressBlock];
}

- (CMISRequest*)downloadContentOfCMISObject:(NSString *)objectId
                             toOutputStream:(NSOutputStream *)outputStream
                                     offset:(NSDecimalNumber*)offset
                                     length:(NSDecimalNumber*)length
                            completionBlock:(void (^)(NSError *error))completionBlock
                              progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
{
    return [self.binding.objectService downloadContentOfObject:objectId
                                                      streamId:nil
                                                toOutputStream:outputStream
                                                        offset:offset
                                                        length:length
                                               completionBlock:completionBlock
                                                 progressBlock:progressBlock];
}


- (CMISRequest*)createDocumentFromFilePath:(NSString *)filePath
                          mimeType:(NSString *)mimeType
                        properties:(NSDictionary *)properties inFolder:(NSString *)folderObjectId
                   completionBlock:(void (^)(NSString *objectId, NSError *error))completionBlock
                     progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock
{
    CMISRequest *request = [[CMISRequest alloc] init];
    [self.objectConverter convertProperties:properties
                            forObjectTypeId:[properties objectForKey:kCMISPropertyObjectTypeId]
                            completionBlock:^(CMISProperties *convertedProperties, NSError *error) {
        if (error) {
            CMISLogError(@"Could not convert properties: %@", error.description);
            if (completionBlock) {
                completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeRuntime]);
            }
        } else {
            CMISRequest *createRequest = [self.binding.objectService createDocumentFromFilePath:filePath
                                                                    mimeType:mimeType
                                                                  properties:convertedProperties
                                                                    inFolder:folderObjectId
                                                             completionBlock:completionBlock
                                                               progressBlock:progressBlock];
            // set the underlying request object on the object returned to the original caller
            request.httpRequest = createRequest.httpRequest;
        }
    }];
    return request;
}

- (CMISRequest*)createDocumentFromInputStream:(NSInputStream *)inputStream
                             mimeType:(NSString *)mimeType
                           properties:(NSDictionary *)properties
                             inFolder:(NSString *)folderObjectId
                        bytesExpected:(unsigned long long)bytesExpected
                      completionBlock:(void (^)(NSString *objectId, NSError *error))completionBlock
                        progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock
{
    CMISRequest *request = [[CMISRequest alloc] init];
    [self.objectConverter convertProperties:properties
                            forObjectTypeId:[properties objectForKey:kCMISPropertyObjectTypeId]
                            completionBlock:^(CMISProperties *convertedProperties, NSError *error) {
        if (error) {
            CMISLogError(@"Could not convert properties: %@", error.description);
            if (completionBlock) {
                completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeRuntime]);
            }
        } else {
            CMISRequest *createRequest = [self.binding.objectService createDocumentFromInputStream:inputStream
                                                             mimeType:mimeType
                                                           properties:convertedProperties
                                                             inFolder:folderObjectId
                                                        bytesExpected:bytesExpected
                                                      completionBlock:completionBlock
                                                        progressBlock:progressBlock];
            // set the underlying request object on the object returned to the original caller
            request.httpRequest = createRequest.httpRequest;
        }
    }];
    return request;
}

@end
