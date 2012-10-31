/*******************************************************************************
 * Copyright (C) 2005-2012 Alfresco Software Limited.
 * 
 * This file is part of the Alfresco Mobile SDK.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *  
 *  http://www.apache.org/licenses/LICENSE-2.0
 * 
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ******************************************************************************/

#import "AlfrescoRepositorySession.h"
#import "AlfrescoInternalConstants.h"
#import "CMISSession.h"
#import "CMISRepositoryService.h"
#import "CMISRepositoryInfo.h"
#import "AlfrescoObjectConverter.h"
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoBasicAuthenticationProvider.h"
#import "AlfrescoErrors.h"
#import "AlfrescoCMISObjectConverter.h"
#import <objc/runtime.h>


@interface AlfrescoRepositorySession ()
@property (nonatomic, strong, readwrite) NSURL *baseUrl;
@property (nonatomic, strong, readwrite) NSMutableDictionary *sessionData;
@property (nonatomic, strong, readwrite) NSString *personIdentifier;

@property (nonatomic, strong, readwrite) AlfrescoRepositoryInfo *repositoryInfo;
@property (nonatomic, strong, readwrite) AlfrescoFolder *rootFolder;
@property (nonatomic, strong, readwrite) AlfrescoListingContext *defaultListingContext;
- (id)initWithUrl:(NSURL *)url parameters:(NSDictionary *)parameters;
- (void)authenticateWithUsername:(NSString *)username
                     andPassword:(NSString *)password
                 completionBlock:(AlfrescoSessionCompletionBlock)completionBlock;
- (void)establishCMISSession:(CMISSession *)session username:(NSString *)username password:(NSString *)password;

+ (NSNumber *)majorVersionFromString:(NSString *)versionString;
@end

@implementation AlfrescoRepositorySession

@synthesize personIdentifier = _personIdentifier;
@synthesize repositoryInfo = _repositoryInfo;
@synthesize baseUrl = _baseUrl;
@synthesize sessionData = _sessionData;
@synthesize rootFolder = _rootFolder;
@synthesize defaultListingContext = _defaultListingContext;

+ (void)connectWithUrl:(NSURL *)url
              username:(NSString *)username
              password:(NSString *)password
       completionBlock:(AlfrescoSessionCompletionBlock)completionBlock
{
    AlfrescoRepositorySession *sessionInstance = [[AlfrescoRepositorySession alloc] initWithUrl:url parameters:nil];
    if (sessionInstance)
    {
        [sessionInstance authenticateWithUsername:username andPassword:password completionBlock:completionBlock];
    }
}

+ (void)connectWithUrl:(NSURL *)url
              username:(NSString *)username
              password:(NSString *)password
            parameters:(NSDictionary *)parameters
       completionBlock:(AlfrescoSessionCompletionBlock)completionBlock
{
    AlfrescoRepositorySession *sessionInstance = [[AlfrescoRepositorySession alloc] initWithUrl:url parameters:parameters];
    if (sessionInstance) 
    {
        [sessionInstance authenticateWithUsername:username andPassword:password completionBlock:completionBlock];
    }
}

/**
 OnPremise services have a dedicated thumbnail rendition API, which we need to enable here.
 */

- (id)initWithUrl:(NSURL *)url parameters:(NSDictionary *)parameters
{
    if (self = [super init])
    {
        self.baseUrl = url;
        if (nil != parameters)
        {
            self.sessionData = [NSMutableDictionary dictionaryWithDictionary:parameters];
        }
        else
        {
            self.sessionData = [NSMutableDictionary dictionaryWithCapacity:8];
        }
        if ([[parameters allKeys] containsObject:kAlfrescoMetadataExtraction])
        {
            [self setObject:[parameters valueForKey:kAlfrescoMetadataExtraction] forParameter:kAlfrescoMetadataExtraction];
        }
        else
        {
            [self setObject:[NSNumber numberWithBool:NO] forParameter:kAlfrescoMetadataExtraction];
        }
        
        if ([[parameters allKeys] containsObject:kAlfrescoThumbnailCreation])
        {
            [self setObject:[parameters valueForKey:kAlfrescoThumbnailCreation] forParameter:kAlfrescoThumbnailCreation];
        }
        else
        {
            [self setObject:[NSNumber numberWithBool:NO] forParameter:kAlfrescoThumbnailCreation];
        }
        // setup defaults
        self.defaultListingContext = [[AlfrescoListingContext alloc] init];        
    }
    
    return self;
}

- (void)authenticateWithUsername:(NSString *)username
                     andPassword:(NSString *)password
                 completionBlock:(AlfrescoSessionCompletionBlock)completionBlock
{
    NSString *cmisUrl = [[self.baseUrl absoluteString] stringByAppendingString:kAlfrescoOnPremiseCMISPath];
    __block CMISSessionParameters *params = [[CMISSessionParameters alloc] initWithBindingType:CMISBindingTypeAtomPub];
    params.username = username;
    params.password = password;
    params.atomPubUrl = [NSURL URLWithString:cmisUrl];
    
    NSString *v4cmisUrl = [[self.baseUrl absoluteString] stringByAppendingString:kAlfrescoOnPremise4_xCMISPath];
    __block CMISSessionParameters *v4params = [[CMISSessionParameters alloc] initWithBindingType:CMISBindingTypeAtomPub];
    v4params.username = username;
    v4params.password = password;
    v4params.atomPubUrl = [NSURL URLWithString:v4cmisUrl];
    
    log(@"**** authenticateWithUsername OnPremise ****");

    [CMISSession arrayOfRepositories:params completionBlock:^(NSArray *repositories, NSError *error){
        if (nil == repositories)
        {
            completionBlock(nil, error);
        }
        else if( repositories.count == 0)
        {
            error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeNoRepositoryFound];
            completionBlock(nil, error);
        }
        else
        {
            CMISRepositoryInfo *repoInfo = [repositories objectAtIndex:0];
            log(@"**** authenticateWithUsername OnPremise we got ONE repository back ****");
            
            params.repositoryId = repoInfo.identifier;
            v4params.repositoryId = repoInfo.identifier;            
            [params setObject:NSStringFromClass([AlfrescoCMISObjectConverter class]) forKey:kCMISSessionParameterObjectConverterClassName];
            [v4params setObject:NSStringFromClass([AlfrescoCMISObjectConverter class]) forKey:kCMISSessionParameterObjectConverterClassName];
            
            __block void (^rootFolderCompletionBlock)(CMISFolder *folder, NSError *error) = ^void(CMISFolder *rootFolder, NSError *error){
                log(@"**** authenticateWithUsername OnPremise rootFolderCompletionBlock ****");
                if (nil == rootFolder)
                {
                    log(@"**** authenticateWithUsername OnPremise rootFolderCompletionBlock ROOT FOLDER IS NIL ****");
                    completionBlock(nil, error);
                }
                else
                {
                    log(@"**** authenticateWithUsername OnPremise rootFolderCompletionBlock ROOT FOLDER IS NOT!!!! NIL ****");
                    AlfrescoObjectConverter *objectConverter = [[AlfrescoObjectConverter alloc] initWithSession:self];
                    self.rootFolder = (AlfrescoFolder *)[objectConverter nodeFromCMISObject:rootFolder];
                    completionBlock(self, error);
                }
            };
            
            void (^sessionv4CompletionBlock)(CMISSession *session, NSError *error) = ^void( CMISSession *v4Session, NSError *error ){
                log(@"**** authenticateWithUsername OnPremise sessionv4CompletionBlock ****");
                if (nil == v4Session)
                {
                    completionBlock(nil, error);
                }
                else
                {
                    [self establishCMISSession:v4Session username:username password:password];
                    [v4Session retrieveRootFolderWithCompletionBlock:rootFolderCompletionBlock];
                }
            };
            
            void (^sessionv3CompletionBlock)(CMISSession *session, NSError *error) = ^void( CMISSession *v3Session, NSError *error){
                log(@"**** authenticateWithUsername OnPremise sessionv3CompletionBlock ****");
                if (nil == v3Session)
                {
                    log(@"**** authenticateWithUsername OnPremise sessionv3CompletionBlock SESSION IS NIL ****");
                    completionBlock(nil, error);
                }
                else
                {
                    self.personIdentifier = username;
                    AlfrescoObjectConverter *objectConverter = [[AlfrescoObjectConverter alloc] initWithSession:self];
                    self.repositoryInfo = [objectConverter repositoryInfoFromCMISSession:v3Session];
                    
                    NSString *version = self.repositoryInfo.version;
                    NSArray *versionArray = [version componentsSeparatedByString:@"."];
                    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                    NSNumber *majorVersionNumber = [formatter numberFromString:[versionArray objectAtIndex:0]];
                    log(@"**** authenticateWithUsername OnPremise sessionv3CompletionBlock SESSION IS NOT !! NIL User name is %@ and version is %@ ****", username, version);
                    if ([majorVersionNumber intValue] >= 4)
                    {
                        [CMISSession connectWithSessionParameters:v4params completionBlock:sessionv4CompletionBlock];
                    }
                    else
                    {
                        [self establishCMISSession:v3Session username:username password:password];
                        [v3Session retrieveRootFolderWithCompletionBlock:rootFolderCompletionBlock];
                        /*
                        [v3Session retrieveRootFolderWithCompletionBlock:^(CMISFolder *rootFolder, NSError *error){
                            log(@"**** authenticateWithUsername OnPremise rootFolderCompletionBlock ****");
                            if (nil == rootFolder)
                            {
                                log(@"**** authenticateWithUsername OnPremise rootFolderCompletionBlock ROOT FOLDER IS NIL ****");
                                completionBlock(nil, error);
                            }
                            else
                            {
                                log(@"**** authenticateWithUsername OnPremise rootFolderCompletionBlock ROOT FOLDER IS NOT!!!! NIL ****");
                                AlfrescoObjectConverter *objectConverter = [[AlfrescoObjectConverter alloc] initWithSession:self];
                                self.rootFolder = (AlfrescoFolder *)[objectConverter nodeFromCMISObject:rootFolder];
                                completionBlock(self, error);
                            }
                        }];
                         */
                    }
                    
                }
            };
            
            [CMISSession connectWithSessionParameters:params completionBlock:sessionv3CompletionBlock];
        }
    }];
    
}

- (void)establishCMISSession:(CMISSession *)session username:(NSString *)username password:(NSString *)password
{
    [self setObject:session forParameter:kAlfrescoSessionKeyCmisSession];
    id<AlfrescoAuthenticationProvider> authProvider = [[AlfrescoBasicAuthenticationProvider alloc] initWithUsername:username
                                                                                                        andPassword:password];
    [self setObject:authProvider forParameter:kAlfrescoAuthenticationProviderObjectKey];
    AlfrescoObjectConverter *objectConverter = [[AlfrescoObjectConverter alloc] initWithSession:self];
    self.repositoryInfo = [objectConverter repositoryInfoFromCMISSession:session];
}


/*
- (void)authenticateWithUsername:(NSString *)username
                     andPassword:(NSString *)password
                 completionBlock:(AlfrescoSessionCompletionBlock)completionBlock
{
    NSString *cmisUrl = [[self.baseUrl absoluteString] stringByAppendingString:kAlfrescoOnPremiseCMISPath];
    __block CMISSessionParameters *params = [[CMISSessionParameters alloc] initWithBindingType:CMISBindingTypeAtomPub];
    params.username = username;
    params.password = password;
    params.atomPubUrl = [NSURL URLWithString:cmisUrl];
    
    NSString *v4cmisUrl = [[self.baseUrl absoluteString] stringByAppendingString:kAlfrescoOnPremise4_xCMISPath];
    __block CMISSessionParameters *v4params = [[CMISSessionParameters alloc] initWithBindingType:CMISBindingTypeAtomPub];
    v4params.username = username;
    v4params.password = password;
    v4params.atomPubUrl = [NSURL URLWithString:v4cmisUrl];
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue addOperationWithBlock:^{
        NSError *error = nil;
        NSArray *repositories = [CMISSession arrayOfRepositories:params error:&error];
        if(error)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if(completionBlock)
                {
                    completionBlock(nil, error);
                }
            }];
        }
        else if(repositories.count == 0)
        {
            error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeNoRepositoryFound];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if(completionBlock)
                {
                    completionBlock(nil, error);
                }
            }];
        }
        else 
        {
            // we only use the first repository
            CMISRepositoryInfo *repoInfo = [repositories objectAtIndex:0];
            
            params.repositoryId = repoInfo.identifier;
            v4params.repositoryId = repoInfo.identifier;
            
            // enable Alfresco mode in CMIS Session
            [params setObject:NSStringFromClass([AlfrescoCMISObjectConverter class]) forKey:kCMISSessionParameterObjectConverterClassName];
            [v4params setObject:NSStringFromClass([AlfrescoCMISObjectConverter class]) forKey:kCMISSessionParameterObjectConverterClassName];
            
            // create the session using the paramters
            CMISSession *cmisSession = [[CMISSession alloc] initWithSessionParameters:params];
            CMISSession *v4CMISSession = [[CMISSession alloc] initWithSessionParameters:v4params];
 
            id<AlfrescoAuthenticationProvider> authProvider = [[AlfrescoBasicAuthenticationProvider alloc] initWithUsername:username
                                                                                                                andPassword:password];
            [self setObject:authProvider forParameter:kAlfrescoAuthenticationProviderObjectKey];
            
            
            BOOL authenticated = [cmisSession authenticateAndReturnError:&error];
            
            BOOL isVersion4 = NO;
            if (authenticated == YES)
            {
                self.personIdentifier = username;
                AlfrescoObjectConverter *objectConverter = [[AlfrescoObjectConverter alloc] initWithSession:self];
                self.repositoryInfo = [objectConverter repositoryInfoFromCMISSession:cmisSession];
                
                NSString *version = self.repositoryInfo.version;
                NSArray *versionArray = [version componentsSeparatedByString:@"."];
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                NSNumber *majorVersionNumber = [formatter numberFromString:[versionArray objectAtIndex:0]];

                if ([majorVersionNumber intValue] >= 4)
                {

                    [self setObject:v4CMISSession forParameter:kAlfrescoSessionKeyCmisSession];
                    [self setObject:authProvider forParameter:kAlfrescoAuthenticationProviderObjectKey];

 
                    BOOL authenticatedAgain = [v4CMISSession authenticateAndReturnError:&error];
                    if (authenticatedAgain)
                    {
                        objectConverter = [[AlfrescoObjectConverter alloc] initWithSession:self];
                        self.repositoryInfo = [objectConverter repositoryInfoFromCMISSession:v4CMISSession];                        
                    }
                    isVersion4 = YES;
                }
                else
                {
                    [self setObject:cmisSession forParameter:kAlfrescoSessionKeyCmisSession];
                }
                CMISObject *retrievedObject = nil;
                if (isVersion4)
                {
                    retrievedObject = [v4CMISSession retrieveRootFolderAndReturnError:&error];
                }
                else
                {
                    retrievedObject = [cmisSession retrieveRootFolderAndReturnError:&error];                    
                }
                if (nil != retrievedObject) {
                    if ([retrievedObject isKindOfClass:[CMISFolder class]])
                    {
                        self.rootFolder = (AlfrescoFolder *)[objectConverter nodeFromCMISObject:retrievedObject];
                    }
                }
                
                
            }
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if(completionBlock)
                {
                    completionBlock(self, error);
                }
            }];
        }
    }];
}
 */


- (NSArray *)allParameterKeys
{
    return [self.sessionData allKeys];
}

- (id)objectForParameter:(id)key
{
    return [self.sessionData objectForKey:key];
}

- (void)setObject:(id)object forParameter:(id)key
{
    [self.sessionData setObject:object forKey:key];
}

- (void)addParametersFromDictionary:(NSDictionary *)dictionary
{
    [self.sessionData addEntriesFromDictionary:dictionary];
}

- (void)removeParameter:(id)key
{
    [self.sessionData removeObjectForKey:key];
}

+ (NSNumber *)majorVersionFromString:(NSString *)versionString
{
    NSArray *versionArray = [versionString componentsSeparatedByString:@"."];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *majorVersionNumber = [formatter numberFromString:[versionArray objectAtIndex:0]];
    return majorVersionNumber;
}


@end
