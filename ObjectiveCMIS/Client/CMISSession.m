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

@interface CMISSession ()
@property (nonatomic, strong) CMISSessionParameters *sessionParameters;
@property (nonatomic, strong) CMISObjectConverter *objectConverter;
@property (nonatomic, assign, readwrite) BOOL isAuthenticated;
@property (nonatomic, strong, readwrite) id<CMISBinding> binding;
@property (nonatomic, strong, readwrite) CMISFolder *rootFolder;
@property (nonatomic, strong, readwrite) CMISRepositoryInfo *repositoryInfo;
@end

@interface CMISSession (PrivateMethods)
- (BOOL)authenticateAndReturnError:(NSError **)error;
@end

@implementation CMISSession

@synthesize binding = _binding;
@synthesize rootFolder = _rootFolder;
@synthesize repositoryInfo = _repositoryInfo;
@synthesize isAuthenticated = _isAuthenticated;
@synthesize objectConverter = _objectConverter;
@synthesize sessionParameters = _sessionParameters;

#pragma mark -
#pragma mark Setup

+ (NSArray *)arrayOfRepositories:(CMISSessionParameters *)sessionParameters error:(NSError **)error
{
    CMISSession *session = [[CMISSession alloc] initWithSessionParameters:sessionParameters];
    
    // TODO: validate session parameters?
    
    // return list of repositories
    return [session.binding.repositoryService arrayOfRepositoriesAndReturnError:error];
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
        self.repositoryInfo = [self.binding.repositoryService repositoryInfoForId:self.sessionParameters.repositoryId error:error];
        
        
        if (self.repositoryInfo == nil || (*error != nil))
        {
            log(@"Error because repositoryInfo is nil: %@",[*error description]);
            return NO;
        }
        
        // get root folder info
        CMISObject *obj = [self retrieveObject:self.repositoryInfo.rootFolderId error:error];
        
        if (obj == nil || (error && error != NULL && *error != nil))
        {
            *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeNoRootFolderFound withDetailedDescription:nil];
            log(@"Error because CMISObject returns as nil: %@",[*error description]);
            return NO;
        }
        
        if ([obj isKindOfClass:[CMISFolder class]])
        {
            self.rootFolder = (CMISFolder *)obj;
        } else {
            *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeNoRootFolderFound withDetailedDescription:nil];
            log(@"Error because obj is not of kind CMISFolder: %@",[*error description]);
            return NO;
        }
    }
    
    // no errors have occurred so set authenticated flag and return success flag
    self.isAuthenticated = YES;
    return YES;
}

#pragma mark CMIS operations

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
    // TODO: cache object

    CMISObjectData *objectData = [self.binding.objectService retrieveObjectByPath:path error:error];
    if (objectData != nil && *error == nil)
    {
        return [self.objectConverter convertObject:objectData];
    }

    return nil;
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
            [resultArray addObject:[CMISQueryResult queryResultUsingCmisObjectData:objectData]];
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
                    completionBlock:(CMISContentRetrievalCompletionBlock)completionBlock
                    failureBlock:(CMISContentRetrievalFailureBlock)failureBlock
{
    [self.binding.objectService downloadContentOfObject:objectId toFile:filePath completionBlock:completionBlock failureBlock:failureBlock];
}

- (NSString *)createDocumentFromFilePath:(NSString *)filePath withMimeType:(NSString *)mimeType
                   withProperties:(NSDictionary *)properties inFolder:(NSString *)folderObjectId error:(NSError **)error
{
    NSError *internalError = nil;
    CMISObjectConverter *converter = [[CMISObjectConverter alloc] initWithSession:self];
    CMISProperties *convertedProperties = [converter convertProperties:properties forObjectTypeId:kCMISPropertyObjectTypeIdValueDocument error:&internalError];
    if (internalError != nil)
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeRuntime];
        return nil;
    }

    return [self.binding.objectService createDocumentFromFilePath:filePath withMimeType:mimeType withProperties:convertedProperties inFolder:folderObjectId error:error];
}


@end
