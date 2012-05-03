//
//  CMISSession.m
//  HybridApp
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
@property (nonatomic, strong) id<CMISSessionAuthenticationDelegate> authenticationDelegate;
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
@synthesize authenticationDelegate = _authenticationDelegate;

#pragma mark -
#pragma mark Setup

+ (NSArray *)arrayOfRepositories:(CMISSessionParameters *)sessionParameters error:(NSError **)error
{
    CMISSession *session = [CMISSession sessionWithParameters:sessionParameters];

    if (*error) {
        log(@"Error while creating session : %@", [*error description]);
        return nil;
    }
    
    // TODO: validate session parameters?
    
    // return list of repositories
    return [session.binding.repositoryService arrayOfRepositoriesAndReturnError:error];
}

+ (CMISSession *)sessionWithParameters:(CMISSessionParameters *)sessionParameters
{
    CMISSession *session = [[CMISSession alloc] init];
    session.sessionParameters = sessionParameters;
    session.isAuthenticated = NO;
    
    // setup authentication provider delegate (if not present)
    if (sessionParameters.authenticationProvider == nil)
    {
        // TODO: Do we need to cache the instance in the session parameters?
        sessionParameters.authenticationProvider = [[CMISStandardAuthenticationProvider alloc] 
                                                    initWithUsername:sessionParameters.username 
                                                    andPassword:sessionParameters.password];
    }

    // create the binding the session will use
    CMISBindingFactory *bindingFactory = [[CMISBindingFactory alloc] init];
    session.binding = [bindingFactory bindingWithParameters:sessionParameters];

    session.objectConverter = [[CMISObjectConverter alloc] initWithCMISBinding:session.binding];
    
    // TODO: setup locale
    // TODO: setup default session parameters
    // TODO: setup caches
    
    return session;
}

- (void)authenticateWithDelegate:(id<CMISSessionAuthenticationDelegate>)delegate
{
    // TODO: Use an NSOperationQueue to call the authenticateAndReturnError method
    //       on a background thread
    if ([self authenticateAndReturnError:nil])
    {
        self.isAuthenticated = YES;
    }
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
        CMISObjectId *objectId = [[CMISObjectId alloc] initWithString:self.repositoryInfo.rootFolderId];
        CMISObject *obj = [self retrieveObject:objectId error:error];
        
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

#pragma mark Object retrieval

- (CMISObject *)retrieveObject:(CMISObjectId *)objectId error:(NSError **)error
{
    // TODO: cache the object
    
    CMISObjectData *objectData = [self.binding.objectService retrieveObject:objectId.identifier error:error];
    CMISObject *obj = [self.objectConverter convertObject:objectData];
    
    return obj;
}

@end
