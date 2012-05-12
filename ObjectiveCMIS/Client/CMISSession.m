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
#import "CMISDocument.h"

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
    if (self = [super init])
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

        self.objectConverter = [[CMISObjectConverter alloc] initWithCMISBinding:self.binding];
    
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
        // TODO: populate NSError object appropriately
        *error = [[NSError alloc] init];
        return NO;
    }
    
    // check we have enough authentication credentials
    NSString *username = self.sessionParameters.username;
    NSString *password = self.sessionParameters.password;
    if (self.sessionParameters.authenticationProvider == nil && username == nil && password == nil)
    {
        // TODO: populate NSError object appropriately
        *error = [[NSError alloc] init];
        return NO;
    }
    
    // TODO: use authentication provider to make sure we have enough credentials, it may need to make
    //       another call to get a ticket or do handshake i.e. NTLM.
    
    // retrieve the repository info, if the repository id is provided
    if (self.sessionParameters.repositoryId != nil)
    {
        // get repository info
        self.repositoryInfo = [self.binding.repositoryService repositoryInfoForId:self.sessionParameters.repositoryId error:error];
        
        // TODO: capture any error and return
        
        if (self.repositoryInfo == nil)
        {
            return NO;
        }
        
        // get root folder info
        CMISObject *obj = [self retrieveObject:self.repositoryInfo.rootFolderId error:error];
        
        if (obj == nil)
        {
            return NO;
        }
        
        if ([obj isKindOfClass:[CMISFolder class]])
        {
            self.rootFolder = (CMISFolder *)obj;
        } else {
            NSLog(@"Warning: rootFolderId %@ did not point to a folder", self.repositoryInfo.rootFolderId);
        }
    }
    
    // no errors have occurred so set authenticated flag and return success flag
    self.isAuthenticated = YES;
    return YES;
}

#pragma mark CMIS operations

- (CMISObject *)retrieveObject:(NSString *)objectId error:(NSError **)error
{
    // TODO: cache the object
    
    CMISObjectData *objectData = [self.binding.objectService retrieveObject:objectId error:error];
    CMISObject *obj = [self.objectConverter convertObject:objectData];
    
    return obj;
}

- (NSString *)createFolder:(NSDictionary *)properties inFolder:(NSString *)folderObjectId error:(NSError **)error
{
    return [self.binding.objectService createFolderInParentFolder:folderObjectId withProperties:properties error:error];
}

- (void)downloadContentOfCMISObject:(NSString *)objectId toFile:(NSString *)filePath completionBlock:(CMISContentRetrievalCompletionBlock)completionBlock failureBlock:(CMISContentRetrievalFailureBlock)failureBlock
{
    [self.binding.objectService downloadContentOfCMISObject:objectId toFile:filePath completionBlock:completionBlock failureBlock:failureBlock];
}

- (NSString *)createDocumentFromFilePath:(NSString *)filePath withMimeType:(NSString *)mimeType withProperties:(NSDictionary *)properties inFolder:(NSString *)folderObjectId error:(NSError **)error
{
    return [self.binding.objectService createDocumentFromFilePath:filePath withMimeType:mimeType withProperties:properties inFolder:folderObjectId error:error];
}


@end
