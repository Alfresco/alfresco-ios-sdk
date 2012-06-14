//
//  CMISSession.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 10/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISSession.h"
#import "CMISConstants.h"
#import "CMISObjectConverter.h"
#import "CMISStandardAuthenticationProvider.h"
#import "CMISBindingFactory.h"
#import "CMISObjectList.h"
#import "CMISQueryResult.h"
#import "CMISErrors.h"
#import "CMISOperationContext.h"
#import "CMISPagedResult.h"
#import "CMISTypeDefinition.h"

@interface CMISSession ()
@property (nonatomic, strong) CMISSessionParameters *sessionParameters;
@property (nonatomic, strong) CMISObjectConverter *objectConverter;
@property (nonatomic, assign, readwrite) BOOL isAuthenticated;
@property (nonatomic, strong, readwrite) id<CMISBinding> binding;
@property (nonatomic, strong, readwrite) CMISRepositoryInfo *repositoryInfo;
@end

@interface CMISSession (PrivateMethods)
- (BOOL)authenticateAndReturnError:(NSError **)error;
@end

@implementation CMISSession

@synthesize isAuthenticated = _isAuthenticated;
@synthesize binding = _binding;
@synthesize repositoryInfo = _repositoryInfo;
@synthesize sessionParameters = _sessionParameters;
@synthesize objectConverter = _objectConverter;

#pragma mark -
#pragma mark Setup

+ (NSArray *)arrayOfRepositories:(CMISSessionParameters *)sessionParameters error:(NSError **)error
{
    CMISSession *session = [[CMISSession alloc] initWithSessionParameters:sessionParameters];
    
    // TODO: validate session parameters?
    
    // return list of repositories
    return [session.binding.repositoryService retrieveRepositoriesAndReturnError:error];
}

- (id)initWithSessionParameters:(CMISSessionParameters *)sessionParameters
{
    self = [super init];
    if (self)
    {
        self.sessionParameters = sessionParameters;
        self.isAuthenticated = NO;
    
        // setup authentication provider delegate (if not present)
        if (self.sessionParameters.authenticationProvider == nil)
        {
            // TODO: Do we need to cache the instance in the session parameters?
            self.sessionParameters.authenticationProvider = [[CMISStandardAuthenticationProvider alloc] 
                                                             initWithUsername:self.sessionParameters.username 
                                                             andPassword:self.sessionParameters.password];
        }

        // create the binding the session will use
        CMISBindingFactory *bindingFactory = [[CMISBindingFactory alloc] init];
        self.binding = [bindingFactory bindingWithParameters:sessionParameters];

        self.objectConverter = [[CMISObjectConverter alloc] initWithSession:self];
    
        // TODO: setup locale
        // TODO: setup default session parameters
        // TODO: setup caches
    }
    
    return self;
}

- (BOOL)authenticateAndReturnError:(NSError **)error
{
    // TODO: validate session parameters, extract the checks below?
    
    // check repository id is present
    if (self.sessionParameters.repositoryId == nil)
    {
        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument withDetailedDescription:nil];
        log(@"Error: %@",[*error description]);
        return NO;
    }
    
    // check if we have enough authentication credentials
    NSString *username = self.sessionParameters.username;
    NSString *password = self.sessionParameters.password;
    if (self.sessionParameters.authenticationProvider == nil && username == nil && password == nil)
    {
        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeUnauthorized withDetailedDescription:nil];
        log(@"Error: %@",[*error description]);
        return NO;
    }
    
    // TODO: use authentication provider to make sure we have enough credentials, it may need to make
    //       another call to get a ticket or do handshake i.e. NTLM.
    
    // retrieve the repository info, if the repository id is provided
    if (self.sessionParameters.repositoryId != nil)
    {
        // get repository info
        self.repositoryInfo = [self.binding.repositoryService retrieveRepositoryInfoForId:self.sessionParameters.repositoryId error:error];
        
        
        if (self.repositoryInfo == nil || (*error != nil))
        {
            log(@"Error because repositoryInfo is nil: %@",[*error description]);
            return NO;
        }
    }
    
    // no errors have occurred so set authenticated flag and return success flag
    self.isAuthenticated = YES;
    return YES;
}

#pragma mark CMIS operations

- (CMISFolder *)retrieveRootFolderAndReturnError:(NSError **)error
{
    return [self retrieveFolderWithOperationContext:[CMISOperationContext defaultOperationContext] withError:error];
}

- (CMISFolder *)retrieveFolderWithOperationContext:(CMISOperationContext *)operationContext withError:(NSError **)error
{
    NSString *rootFolderId = self.repositoryInfo.rootFolderId;
    CMISObject *rootFolder = [self retrieveObject:rootFolderId withOperationContext:operationContext error:error];

    if (rootFolder != nil && ![rootFolder isKindOfClass:[CMISFolder class]])
    {
        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeRuntime withDetailedDescription:@"Root folder object is not a folder!"];
        return nil;
    }
    return (CMISFolder *) rootFolder;
}

- (CMISObject *)retrieveObject:(NSString *)objectId error:(NSError **)error
{
    return [self retrieveObject:objectId withOperationContext:[CMISOperationContext defaultOperationContext] error:error];
}

- (CMISObject *)retrieveObject:(NSString *)objectId withOperationContext:(CMISOperationContext *)operationContext error:(NSError **)error
{
    if (objectId == nil)
    {
        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument withDetailedDescription:@"Must provide object id"];
        return nil;
    }

    // TODO: cache the object

    NSError *internalError = nil;
    CMISObjectData *objectData = [self.binding.objectService retrieveObject:objectId
                                                       withFilter:operationContext.filterString
                                                       andIncludeRelationShips:operationContext.includeRelationShips
                                                       andIncludePolicyIds:operationContext.isIncludePolicies
                                                       andRenditionFilder:operationContext.renditionFilterString
                                                       andIncludeACL:operationContext.isIncluseACLs
                                                       andIncludeAllowableActions:operationContext.isIncludeAllowableActions
                                                       error:&internalError];

    if (internalError != nil)
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeObjectNotFound];
        return nil;
    }

    if (objectData != nil)
    {
        return [self.objectConverter convertObject:objectData];
    }

    return nil;
}

- (CMISObject *)retrieveObjectByPath:(NSString *)path error:(NSError **)error
{
   return [self retrieveObjectByPath:path withOperationContext:[CMISOperationContext defaultOperationContext] error:error];
}

- (CMISObject *)retrieveObjectByPath:(NSString *)path withOperationContext:(CMISOperationContext *)operationContext error:(NSError **)error
{
    CMISObjectData *objectData = [self.binding.objectService retrieveObjectByPath:path
                                                                       withFilter:operationContext.filterString
                                                          andIncludeRelationShips:operationContext.includeRelationShips
                                                              andIncludePolicyIds:operationContext.isIncludePolicies
                                                               andRenditionFilder:operationContext.renditionFilterString
                                                                    andIncludeACL:operationContext.isIncluseACLs
                                                       andIncludeAllowableActions:operationContext.isIncludeAllowableActions
                                                                            error:error];
    if (objectData != nil && *error == nil)
    {
        return [self.objectConverter convertObject:objectData];
    }

    return nil;
}

- (CMISTypeDefinition *)retrieveTypeDefinition:(NSString *)typeId error:(NSError **)error
{
    return [self.binding.repositoryService retrieveTypeDefinition:typeId error:error];
}

- (CMISPagedResult *)query:(NSString *)statement searchAllVersions:(BOOL)searchAllVersion error:(NSError * *)error
{
    return [self query:statement searchAllVersions:searchAllVersion
                   operationContext:[CMISOperationContext defaultOperationContext] error:error];
}

- (CMISPagedResult *)query:(NSString *)statement searchAllVersions:(BOOL)searchAllVersion
        operationContext:(CMISOperationContext *)operationContext error:(NSError **)error
{

    CMISFetchNextPageBlock fetchNextPageBlock = ^CMISFetchNextPageBlockResult * (int skipCount, int maxItems, NSError ** fetchError)
    {
        // Fetch results through discovery service
        CMISObjectList *objectList = [self.binding.discoveryService query:statement
                                                  searchAllVersions:searchAllVersion
                                                  includeRelationShips:operationContext.includeRelationShips
                                                  renditionFilter:operationContext.renditionFilterString
                                                  includeAllowableActions:operationContext.isIncludeAllowableActions
                                                  maxItems:[NSNumber numberWithInt:maxItems]
                                                  skipCount:[NSNumber numberWithInt:skipCount]
                                                  error:fetchError];

        // Fill up return result
        CMISFetchNextPageBlockResult *result = [[CMISFetchNextPageBlockResult alloc] init];
        result.hasMoreItems = objectList.hasMoreItems;
        result.numItems = objectList.numItems;

        NSMutableArray *resultArray = [[NSMutableArray alloc] init];
        result.resultArray = resultArray;
        for (CMISObjectData *objectData in objectList.objects)
        {
            [resultArray addObject:[CMISQueryResult queryResultUsingCmisObjectData:objectData andWithSession:self]];
        }

        return result;
    };

    NSError *internalError = nil;
    CMISPagedResult *result = [CMISPagedResult pagedResultUsingFetchBlock:fetchNextPageBlock
                                               andLimitToMaxItems:operationContext.maxItemsPerPage
                                               andStartFromSkipCount:operationContext.skipCount
                                               error:&internalError];

    // Return nil and populate error in case something went wrong
    if (internalError != nil)
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeRuntime];
        return nil;
    }

    return result;
}

- (CMISPagedResult *)queryObjectsWithTypeid:(NSString *)typeId
                            withWhereClause:(NSString *)whereClause
                          searchAllVersions:(BOOL)searchAllVersion
                           operationContext:(CMISOperationContext *)operationContext
                                      error:(NSError **)error
{
    // Creating the cmis query using the input params
    NSMutableString *statement = [[NSMutableString alloc] init];

    // Filter
    [statement appendFormat:@"SELECT %@", (operationContext.filterString != nil ? operationContext.filterString : @"*")];

    // Type
    NSError *internalError = nil;
    CMISTypeDefinition *typeDefinition = [self retrieveTypeDefinition:typeId error:&internalError];
    if (internalError != nil)
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeRuntime];
        return nil;
    }
    [statement appendFormat:@" FROM %@", typeDefinition.queryName];

    // Where
    if (whereClause != nil)
    {
        [statement appendFormat:@" WHERE %@", whereClause];
    }

    // Order by
    if (operationContext.orderBy != nil)
    {
        [statement appendFormat:@" ORDER BY %@", operationContext.orderBy];
    }

    // Fetch block for paged results
    CMISFetchNextPageBlock fetchNextPageBlock = ^CMISFetchNextPageBlockResult *(int skipCount, int maxItems, NSError **fetchError)
    {
        // Fetch results through discovery service
        CMISObjectList *objectList = [self.binding.discoveryService query:statement
                                                        searchAllVersions:searchAllVersion
                                                     includeRelationShips:operationContext.includeRelationShips
                                                          renditionFilter:operationContext.renditionFilterString
                                                  includeAllowableActions:operationContext.isIncludeAllowableActions
                                                                 maxItems:[NSNumber numberWithInt:maxItems]
                                                                skipCount:[NSNumber numberWithInt:skipCount]
                                                                    error:fetchError];

        // Fill up return result
        CMISFetchNextPageBlockResult *result = [[CMISFetchNextPageBlockResult alloc] init];
        result.hasMoreItems = objectList.hasMoreItems;
        result.numItems = objectList.numItems;

        NSMutableArray *resultArray = [[NSMutableArray alloc] init];
        result.resultArray = resultArray;
        CMISObjectConverter *converter = [[CMISObjectConverter alloc] init];
        for (CMISObjectData *objectData in objectList.objects)
        {
            [resultArray addObject:[converter convertObject:objectData]];
        }

        return result;
    };

    internalError = nil;
    CMISPagedResult *result = [CMISPagedResult pagedResultUsingFetchBlock:fetchNextPageBlock
                                                       andLimitToMaxItems:operationContext.maxItemsPerPage
                                                    andStartFromSkipCount:operationContext.skipCount
                                                                    error:&internalError];

    // Return nil and populate error in case something went wrong
    if (internalError != nil)
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeRuntime];
        return nil;
    }

    return result;
}


- (NSString *)createFolder:(NSDictionary *)properties inFolder:(NSString *)folderObjectId error:(NSError **)error
{
    NSError *internalError = nil;
    CMISObjectConverter *converter = [[CMISObjectConverter alloc] initWithSession:self];
    CMISProperties *convertedProperties = [converter convertProperties:properties
                             forObjectTypeId:kCMISPropertyObjectTypeIdValueFolder error:&internalError];
    if (internalError != nil)
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeRuntime];
        return nil;
    }

    return [self.binding.objectService createFolderInParentFolder:folderObjectId withProperties:convertedProperties error:error];
}

- (void)downloadContentOfCMISObject:(NSString *)objectId toFile:(NSString *)filePath
                    completionBlock:(CMISVoidCompletionBlock)completionBlock
                    failureBlock:(CMISErrorFailureBlock)failureBlock
                    progressBlock:(CMISProgressBlock)progressBlock;
{
    [self.binding.objectService downloadContentOfObject:objectId withStreamId:nil toFile:filePath completionBlock:completionBlock
                                           failureBlock:failureBlock progressBlock:progressBlock];
}

- (void)createDocumentFromFilePath:(NSString *)filePath withMimeType:(NSString *)mimeType
                    withProperties:(NSDictionary *)properties inFolder:(NSString *)folderObjectId
                    completionBlock:(CMISStringCompletionBlock)completionBlock
                    failureBlock:(CMISErrorFailureBlock)failureBlock
                    progressBlock:(CMISProgressBlock)progressBlock
{
    NSError *internalError = nil;
    CMISObjectConverter *converter = [[CMISObjectConverter alloc] initWithSession:self];
    CMISProperties *convertedProperties = [converter convertProperties:properties forObjectTypeId:kCMISPropertyObjectTypeIdValueDocument error:&internalError];
    if (internalError != nil)
    {
        log(@"Could not convert properties: %@", [internalError description]);
        if (failureBlock)
        {
            failureBlock([CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeRuntime]);
        }
        return;
    }

    [self.binding.objectService createDocumentFromFilePath:filePath withMimeType:mimeType withProperties:convertedProperties
                    inFolder:folderObjectId completionBlock:completionBlock failureBlock:failureBlock progressBlock:progressBlock];
}


@end
