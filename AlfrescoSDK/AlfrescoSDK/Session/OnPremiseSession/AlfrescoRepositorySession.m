/*******************************************************************************
 * Copyright (C) 2005-2013 Alfresco Software Limited.
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
#import "AlfrescoDefaultNetworkProvider.h"
#import "AlfrescoLog.h"
#import "CMISLog.h"
#import "AlfrescoCache.h"
#import <objc/runtime.h>

@interface AlfrescoRepositorySession ()
@property (nonatomic, strong, readwrite) NSURL *baseUrl;
@property (nonatomic, strong, readwrite) NSMutableDictionary *sessionData;
@property (nonatomic, strong, readwrite) NSMutableDictionary *sessionCache;
@property (nonatomic, strong, readwrite) NSString *personIdentifier;

@property (nonatomic, strong, readwrite) AlfrescoRepositoryInfo *repositoryInfo;
@property (nonatomic, strong, readwrite) AlfrescoFolder *rootFolder;
@property (nonatomic, strong, readwrite) AlfrescoListingContext *defaultListingContext;
@property (nonatomic, strong, readwrite) id<AlfrescoNetworkProvider> networkProvider;
- (id)initWithUrl:(NSURL *)url parameters:(NSDictionary *)parameters;
- (AlfrescoRequest *)authenticateWithUsername:(NSString *)username
                                  andPassword:(NSString *)password
                              completionBlock:(AlfrescoSessionCompletionBlock)completionBlock;
- (void)establishCMISSession:(CMISSession *)session username:(NSString *)username password:(NSString *)password;

+ (NSNumber *)majorVersionFromString:(NSString *)versionString;
@end

@implementation AlfrescoRepositorySession


+ (AlfrescoRequest *)connectWithUrl:(NSURL *)url
                           username:(NSString *)username
                           password:(NSString *)password
                    completionBlock:(AlfrescoSessionCompletionBlock)completionBlock
{
    AlfrescoRepositorySession *sessionInstance = [[AlfrescoRepositorySession alloc] initWithUrl:url parameters:nil];
    if (sessionInstance)
    {
        return [sessionInstance authenticateWithUsername:username andPassword:password completionBlock:completionBlock];
    }
    return nil;
}

+ (AlfrescoRequest *)connectWithUrl:(NSURL *)url
                           username:(NSString *)username
                           password:(NSString *)password
                         parameters:(NSDictionary *)parameters
                    completionBlock:(AlfrescoSessionCompletionBlock)completionBlock
{
    AlfrescoRepositorySession *sessionInstance = [[AlfrescoRepositorySession alloc] initWithUrl:url parameters:parameters];
    if (sessionInstance) 
    {
        return [sessionInstance authenticateWithUsername:username andPassword:password completionBlock:completionBlock];
    }
    return nil;
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
        
        if ([[parameters allKeys] containsObject:kAlfrescoCMISNetworkProvider])
        {
            id customCMISNetworkProvider = [parameters objectForKey:kAlfrescoCMISNetworkProvider];
            [self setObject:customCMISNetworkProvider forParameter:kAlfrescoCMISNetworkProvider];
        }
        
        self.networkProvider = [[AlfrescoDefaultNetworkProvider alloc] init];
        id customAlfrescoNetworkProvider = [parameters objectForKey:kAlfrescoNetworkProvider];
        if (customAlfrescoNetworkProvider)
        {
            BOOL conformsToAlfrescoNetworkProvider = [customAlfrescoNetworkProvider conformsToProtocol:@protocol(AlfrescoNetworkProvider)];
            
            if (conformsToAlfrescoNetworkProvider)
            {
                self.networkProvider = (id<AlfrescoNetworkProvider>)customAlfrescoNetworkProvider;
            }
            else
            {
                @throw([NSException exceptionWithName:@"Error with custom network provider"
                                               reason:@"The custom network provider must be an object that conforms to the AlfrescoNetworkProvider protocol"
                                             userInfo:nil]);
            }
        }
        
        // setup defaults
        self.defaultListingContext = [[AlfrescoListingContext alloc] init];
    }
    
    return self;
}

- (AlfrescoRequest *)authenticateWithUsername:(NSString *)username
                                  andPassword:(NSString *)password
                              completionBlock:(AlfrescoSessionCompletionBlock)completionBlock
{
    NSString *cmisUrl = [[self.baseUrl absoluteString] stringByAppendingString:kAlfrescoOnPremiseCMISPath];
    __block CMISSessionParameters *v3params = [[CMISSessionParameters alloc] initWithBindingType:CMISBindingTypeAtomPub];
    v3params.username = username;
    v3params.password = password;
    v3params.atomPubUrl = [NSURL URLWithString:cmisUrl];
    
    NSString *v4cmisUrl = [[self.baseUrl absoluteString] stringByAppendingString:kAlfrescoOnPremise4_xCMISPath];
    __block CMISSessionParameters *v4params = [[CMISSessionParameters alloc] initWithBindingType:CMISBindingTypeAtomPub];
    v4params.username = username;
    v4params.password = password;
    v4params.atomPubUrl = [NSURL URLWithString:v4cmisUrl];
    if ([self.sessionData objectForKey:kAlfrescoCMISNetworkProvider])
    {
        id customCMISNetworkProvider = [self.sessionData objectForKey:kAlfrescoCMISNetworkProvider];
        BOOL conformsToCMISNetworkProvider = [customCMISNetworkProvider conformsToProtocol:@protocol(CMISNetworkProvider)];
        
        if (conformsToCMISNetworkProvider)
        {
            v3params.networkProvider = (id<CMISNetworkProvider>)customCMISNetworkProvider;
            v4params.networkProvider = (id<CMISNetworkProvider>)customCMISNetworkProvider;
        }
        else
        {
            @throw([NSException exceptionWithName:@"Error with custom CMIS network provider"
                                           reason:@"The custom network provider must be an object that conforms to the CMISNetworkProvider protocol"
                                         userInfo:nil]);
        }
    }

    __block AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    request.httpRequest = [CMISSession arrayOfRepositories:v3params completionBlock:^(NSArray *repositories, NSError *error){
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
            AlfrescoLogDebug(@"found repository with ID: %@", repoInfo.identifier);
            
            v3params.repositoryId = repoInfo.identifier;
            [v3params setObject:NSStringFromClass([AlfrescoCMISObjectConverter class]) forKey:kCMISSessionParameterObjectConverterClassName];

            v4params.repositoryId = repoInfo.identifier;
            [v4params setObject:NSStringFromClass([AlfrescoCMISObjectConverter class]) forKey:kCMISSessionParameterObjectConverterClassName];
            
            void (^rootFolderCompletionBlock)(CMISFolder *folder, NSError *error) = ^void(CMISFolder *rootFolder, NSError *error){
                if (nil == rootFolder)
                {
                    AlfrescoLogError(@"repository root folder is nil");
                    completionBlock(nil, error);
                }
                else
                {
                    AlfrescoObjectConverter *objectConverter = [[AlfrescoObjectConverter alloc] initWithSession:self];
                    self.rootFolder = (AlfrescoFolder *)[objectConverter nodeFromCMISObject:rootFolder];
                    completionBlock(self, error);
                }
            };
            
            void (^sessionv4CompletionBlock)(CMISSession *session, NSError *error) = ^void( CMISSession *v4Session, NSError *error ){
                if (nil == v4Session)
                {
                    AlfrescoLogError(@"failed to create v4 session");
                    completionBlock(nil, error);
                }
                else
                {
                    [self establishCMISSession:v4Session username:username password:password];
                    request.httpRequest = [v4Session retrieveRootFolderWithCompletionBlock:rootFolderCompletionBlock];
                }
            };
            
            void (^sessionv3CompletionBlock)(CMISSession *session, NSError *error) = ^void( CMISSession *v3Session, NSError *error){
                if (nil == v3Session)
                {
                    AlfrescoLogError(@"failed to create v3 session");
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
                    AlfrescoLogDebug(@"session connected with user %@, repo version is %@", username, version);
                    if ([majorVersionNumber intValue] >= 4)
                    {
                        request.httpRequest = [CMISSession connectWithSessionParameters:v4params completionBlock:sessionv4CompletionBlock];
                    }
                    else
                    {
                        [self establishCMISSession:v3Session username:username password:password];
                        request.httpRequest = [v3Session retrieveRootFolderWithCompletionBlock:rootFolderCompletionBlock];
                    }
                    
                }
            };
            
            request.httpRequest = [CMISSession connectWithSessionParameters:v3params completionBlock:sessionv3CompletionBlock];
        }
    }];
    return request;
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

- (void)setObject:(id)object forCacheKey:(id)cacheKey
{
    if ([object conformsToProtocol:@protocol(AlfrescoCache)] && [cacheKey hasPrefix:kAlfrescoSessionInternalCache])
    {
        [self.sessionCache setObject:object forKey:cacheKey];
    }
}

- (void)removeFromCache:(id)cacheKey
{
    id cacheObject = [self.sessionCache objectForKey:cacheKey];
    if ([cacheObject respondsToSelector:@selector(clear)])
    {
        [cacheObject clear];
    }
    [self.sessionCache removeObjectForKey:cacheKey];
}


- (void)clear
{
    NSArray *allCaches = [self.sessionCache allKeys];
    if (0 == allCaches.count)
    {
        return;
    }
    for (NSString *key in allCaches)
    {
        id cacheObj = [self.sessionCache objectForKey:key];
        if ([cacheObj respondsToSelector:@selector(clear)])
        {
            [cacheObj clear];
        }
    }
    [self.sessionCache removeAllObjects];
}



+ (NSNumber *)majorVersionFromString:(NSString *)versionString
{
    NSArray *versionArray = [versionString componentsSeparatedByString:@"."];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *majorVersionNumber = [formatter numberFromString:[versionArray objectAtIndex:0]];
    return majorVersionNumber;
}


@end
