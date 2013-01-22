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
#import "AlfrescoNSHTTPRequest.h"

@interface AlfrescoRepositorySession ()
@property (nonatomic, strong, readwrite) NSURL *baseUrl;
@property (nonatomic, strong, readwrite) NSMutableDictionary *sessionData;
@property (nonatomic, strong, readwrite) NSString *personIdentifier;

@property (nonatomic, strong, readwrite) AlfrescoRepositoryInfo *repositoryInfo;
@property (nonatomic, strong, readwrite) AlfrescoFolder *rootFolder;
@property (nonatomic, strong, readwrite) AlfrescoListingContext *defaultListingContext;
@property (nonatomic, strong, readwrite) Class networkProvider;
- (id)initWithUrl:(NSURL *)url parameters:(NSDictionary *)parameters;
- (void)authenticateWithUsername:(NSString *)username
                     andPassword:(NSString *)password
                 completionBlock:(AlfrescoSessionCompletionBlock)completionBlock;
- (void)establishCMISSession:(CMISSession *)session username:(NSString *)username password:(NSString *)password;
- (BOOL)validateCustomNetworkProperty:(id)objectFromParameters;

+ (NSNumber *)majorVersionFromString:(NSString *)versionString;
@end

@implementation AlfrescoRepositorySession

@synthesize personIdentifier = _personIdentifier;
@synthesize repositoryInfo = _repositoryInfo;
@synthesize baseUrl = _baseUrl;
@synthesize sessionData = _sessionData;
@synthesize rootFolder = _rootFolder;
@synthesize defaultListingContext = _defaultListingContext;
@synthesize networkProvider = _networkProvider;

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
        
        self.networkProvider = [AlfrescoNSHTTPRequest class];
        if ([[parameters allKeys] containsObject:kAlfrescoCustomNetworkProviderClass])
        {
            id networkObject = [parameters objectForKey:kAlfrescoCustomNetworkProviderClass];
            if ([self validateCustomNetworkProperty:networkObject])
            {
                Class customNetworkProvider = NSClassFromString((NSString *)networkObject);
                self.networkProvider = customNetworkProvider;
            }
            else
            {
                @throw([NSException exceptionWithName:@"Error with custom network provider"
                                               reason:@"The custom network provider must be a string representation of the network class and must conform to the AlfrescoHTTPRequest protocol"
                                             userInfo:nil]);
            }
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
    __block CMISSessionParameters *v3params = [[CMISSessionParameters alloc] initWithBindingType:CMISBindingTypeAtomPub];
    v3params.username = username;
    v3params.password = password;
    v3params.atomPubUrl = [NSURL URLWithString:cmisUrl];
    
    NSString *v4cmisUrl = [[self.baseUrl absoluteString] stringByAppendingString:kAlfrescoOnPremise4_xCMISPath];
    __block CMISSessionParameters *v4params = [[CMISSessionParameters alloc] initWithBindingType:CMISBindingTypeAtomPub];
    v4params.username = username;
    v4params.password = password;
    v4params.atomPubUrl = [NSURL URLWithString:v4cmisUrl];
    
    log(@"**** authenticateWithUsername OnPremise ****");

    [CMISSession arrayOfRepositories:v3params completionBlock:^(NSArray *repositories, NSError *error){
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
            
            v3params.repositoryId = repoInfo.identifier;
            [v3params setObject:NSStringFromClass([AlfrescoCMISObjectConverter class]) forKey:kCMISSessionParameterObjectConverterClassName];

            v4params.repositoryId = repoInfo.identifier;
            [v4params setObject:NSStringFromClass([AlfrescoCMISObjectConverter class]) forKey:kCMISSessionParameterObjectConverterClassName];
            
            void (^rootFolderCompletionBlock)(CMISFolder *folder, NSError *error) = ^void(CMISFolder *rootFolder, NSError *error){
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
                    log(@"**** authenticateWithUsername OnPremise sessionv3CompletionBlock SESSION IS NIL. We failed ****");
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
                    }
                    
                }
            };
            
            [CMISSession connectWithSessionParameters:v3params completionBlock:sessionv3CompletionBlock];
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

- (BOOL)validateCustomNetworkProperty:(id)objectFromParameters
{
    BOOL customClassIsValid = NO;
    if (![objectFromParameters isKindOfClass:[NSString class]])
    {
        return customClassIsValid;
    }
    
    Class networkProviderClass = NSClassFromString((NSString *)objectFromParameters);
    
    if (!networkProviderClass)
    {
        return customClassIsValid;
    }
    
    if (![networkProviderClass conformsToProtocol:@protocol(AlfrescoHTTPRequest)])
    {
        return customClassIsValid;
    }
    
    return customClassIsValid = YES;
}

+ (NSNumber *)majorVersionFromString:(NSString *)versionString
{
    NSArray *versionArray = [versionString componentsSeparatedByString:@"."];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *majorVersionNumber = [formatter numberFromString:[versionArray objectAtIndex:0]];
    return majorVersionNumber;
}


@end
