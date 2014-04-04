/*******************************************************************************
 * Copyright (C) 2005-2014 Alfresco Software Limited.
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
#import "CMISStandardUntrustedSSLAuthenticationProvider.h"
#import "AlfrescoCMISToAlfrescoObjectConverter.h"
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoBasicAuthenticationProvider.h"
#import "AlfrescoCMISObjectConverter.h"
#import "AlfrescoDefaultNetworkProvider.h"
#import "AlfrescoLog.h"
#import <objc/runtime.h>
#import "AlfrescoURLUtils.h"
#import "AlfrescoRepositoryInfoBuilder.h"

@interface AlfrescoRepositorySession ()
@property (nonatomic, strong, readwrite) NSURL *baseUrl;
@property (nonatomic, strong, readwrite) NSMutableDictionary *sessionData;
@property (nonatomic, strong, readwrite) NSMutableDictionary *sessionCache;
@property (nonatomic, strong, readwrite) NSString *personIdentifier;

@property (nonatomic, strong, readwrite) AlfrescoRepositoryInfo *repositoryInfo;
@property (nonatomic, strong, readwrite) AlfrescoRepositoryInfoBuilder *repositoryInfoBuilder;
@property (nonatomic, strong, readwrite) AlfrescoFolder *rootFolder;
@property (nonatomic, strong, readwrite) AlfrescoListingContext *defaultListingContext;
@property (nonatomic, strong, readwrite) id<AlfrescoNetworkProvider> networkProvider;
@property (nonatomic, strong, readwrite) NSArray *unremovableSessionKeys;

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
    [AlfrescoErrors assertArgumentNotNil:url argumentName:@"url"];
    [AlfrescoErrors assertArgumentNotNil:username argumentName:@"username"];
    [AlfrescoErrors assertArgumentNotNil:password argumentName:@"password"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
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
    [AlfrescoErrors assertArgumentNotNil:url argumentName:@"url"];
    [AlfrescoErrors assertArgumentNotNil:username argumentName:@"username"];
    [AlfrescoErrors assertArgumentNotNil:password argumentName:@"password"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
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
            [self setObject:@NO forParameter:kAlfrescoMetadataExtraction];
        }
        
        if ([[parameters allKeys] containsObject:kAlfrescoThumbnailCreation])
        {
            [self setObject:[parameters valueForKey:kAlfrescoThumbnailCreation] forParameter:kAlfrescoThumbnailCreation];
        }
        else
        {
            [self setObject:@NO forParameter:kAlfrescoThumbnailCreation];
        }
        
        if ([[parameters allKeys] containsObject:kAlfrescoCMISNetworkProvider])
        {
            id customCMISNetworkProvider = parameters[kAlfrescoCMISNetworkProvider];
            [self setObject:customCMISNetworkProvider forParameter:kAlfrescoCMISNetworkProvider];
        }

        if ([[parameters allKeys] containsObject:kAlfrescoAllowUntrustedSSLCertificate])
        {
            (self.sessionData)[kAlfrescoAllowUntrustedSSLCertificate] = [parameters valueForKey:kAlfrescoAllowUntrustedSSLCertificate];
        }
        
        if ([[parameters allKeys] containsObject:kAlfrescoConnectUsingClientSSLCertificate])
        {
            (self.sessionData)[kAlfrescoConnectUsingClientSSLCertificate] = [parameters valueForKey:kAlfrescoConnectUsingClientSSLCertificate];
        }
        
        id customAlfrescoNetworkProvider = parameters[kAlfrescoNetworkProvider];
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
        else
        {
            self.networkProvider = [[AlfrescoDefaultNetworkProvider alloc] init];
        }
        
        self.unremovableSessionKeys = @[kAlfrescoSessionKeyCmisSession, kAlfrescoAuthenticationProviderObjectKey];
        
        // setup defaults
        self.defaultListingContext = [[AlfrescoListingContext alloc] init];
        self.repositoryInfoBuilder = [[AlfrescoRepositoryInfoBuilder alloc] init];
        self.repositoryInfoBuilder.isCloud = NO;
    }
    
    return self;
}

- (AlfrescoRequest *)authenticateWithUsername:(NSString *)username
                                  andPassword:(NSString *)password
                              completionBlock:(AlfrescoSessionCompletionBlock)completionBlock
{
    BOOL useCustomBinding = NO;
    NSString *cmisUrl = [[self.baseUrl absoluteString] stringByAppendingString:kAlfrescoOnPremiseCMISPath];
    NSString *customBindingURL = (self.sessionData)[kAlfrescoCMISBindingURL];
    if (customBindingURL)
    {
        NSString *binding = ([customBindingURL hasPrefix:@"/"]) ? customBindingURL : [NSString stringWithFormat:@"/%@",customBindingURL];
        cmisUrl = [[self.baseUrl absoluteString] stringByAppendingString:binding];
        useCustomBinding = YES;
    }
    __block CMISSessionParameters *v3params = [[CMISSessionParameters alloc] initWithBindingType:CMISBindingTypeAtomPub];
    v3params.username = username;
    v3params.password = password;
    v3params.atomPubUrl = [NSURL URLWithString:cmisUrl];
    
    NSString *v4cmisUrl = [[self.baseUrl absoluteString] stringByAppendingString:kAlfrescoOnPremise4_xCMISPath];
    __block CMISSessionParameters *v4params = [[CMISSessionParameters alloc] initWithBindingType:CMISBindingTypeAtomPub];
    v4params.username = username;
    v4params.password = password;
    v4params.atomPubUrl = [NSURL URLWithString:v4cmisUrl];
    
    NSString *publicAPIcmisUrl = [[self.baseUrl absoluteString] stringByAppendingString:kAlfrescoPublicAPICMISPath];
    __block CMISSessionParameters *publicAPIparams = [[CMISSessionParameters alloc] initWithBindingType:CMISBindingTypeAtomPub];
    publicAPIparams.username = username;
    publicAPIparams.password = password;
    publicAPIparams.atomPubUrl = [NSURL URLWithString:publicAPIcmisUrl];
    
    if ((self.sessionData)[kAlfrescoCMISNetworkProvider])
    {
        id customCMISNetworkProvider = (self.sessionData)[kAlfrescoCMISNetworkProvider];
        BOOL conformsToCMISNetworkProvider = [customCMISNetworkProvider conformsToProtocol:@protocol(CMISNetworkProvider)];
        
        if (conformsToCMISNetworkProvider)
        {
            v3params.networkProvider = (id<CMISNetworkProvider>)customCMISNetworkProvider;
            v4params.networkProvider = (id<CMISNetworkProvider>)customCMISNetworkProvider;
            publicAPIparams.networkProvider = (id<CMISNetworkProvider>)customCMISNetworkProvider;
        }
        else
        {
            @throw([NSException exceptionWithName:@"Error with custom CMIS network provider"
                                           reason:@"The custom network provider must be an object that conforms to the CMISNetworkProvider protocol"
                                         userInfo:nil]);
        }
    }

    BOOL allowUntrustedSSLCertificate = [(self.sessionData)[kAlfrescoAllowUntrustedSSLCertificate] boolValue];
    BOOL connectUsingSSLCertificate = [(self.sessionData)[kAlfrescoConnectUsingClientSSLCertificate] boolValue];
    
    if (connectUsingSSLCertificate)
    {
        // if client certificates are required, certificate credentials need to be setup for auth provider
        NSURLCredential *credential = (self.sessionData)[kAlfrescoClientCertificateCredentials];
        CMISStandardAuthenticationProvider *authProvider = [[CMISStandardAuthenticationProvider alloc] initWithUsername:username password:password];
        authProvider.credential = credential;
        v3params.authenticationProvider = (id<CMISAuthenticationProvider>)authProvider;
        v4params.authenticationProvider = (id<CMISAuthenticationProvider>)authProvider;
        publicAPIparams.authenticationProvider = (id<CMISAuthenticationProvider>)authProvider;
    }
    else if (allowUntrustedSSLCertificate)
    {
        // If connections are allowed for untrusted SSL certificates, we need a custom CMISAuthenticationProvider: CMISStandardUntrustedSSLAuthenticationProvider
        CMISStandardUntrustedSSLAuthenticationProvider *authProvider = [[CMISStandardUntrustedSSLAuthenticationProvider alloc] initWithUsername:username password:password];
        v3params.authenticationProvider = (id<CMISAuthenticationProvider>)authProvider;
        v4params.authenticationProvider = (id<CMISAuthenticationProvider>)authProvider;
        publicAPIparams.authenticationProvider = (id<CMISAuthenticationProvider>)authProvider;
    }

    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    request.httpRequest = [CMISSession arrayOfRepositories:v3params completionBlock:^(NSArray *repositories, NSError *error) {
        if (nil == repositories)
        {
            completionBlock(nil, error);
        }
        else if (repositories.count == 0)
        {
            error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeNoRepositoryFound];
            completionBlock(nil, error);
        }
        else
        {
            CMISRepositoryInfo *repoInfo = repositories[0];
            AlfrescoLogDebug(@"found repository with ID: %@", repoInfo.identifier);
            
            v3params.repositoryId = repoInfo.identifier;
            [v3params setObject:NSStringFromClass([AlfrescoCMISObjectConverter class]) forKey:kCMISSessionParameterObjectConverterClassName];

            v4params.repositoryId = repoInfo.identifier;
            [v4params setObject:NSStringFromClass([AlfrescoCMISObjectConverter class]) forKey:kCMISSessionParameterObjectConverterClassName];

            publicAPIparams.repositoryId = @"-default-";
            [publicAPIparams setObject:NSStringFromClass([AlfrescoCMISObjectConverter class]) forKey:kCMISSessionParameterObjectConverterClassName];

            __block NSString *v3RepositoryProductName = nil;
            
            void (^workflowDefinitionsCompletionBlock)(NSError *error) = ^(NSError *error) {
                NSString *workflowDefinitionString = [kAlfrescoLegacyAPIWorkflowBaseURL stringByAppendingString:kAlfrescoLegacyAPIWorkflowProcessDefinition];
                NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseUrl.absoluteString extensionURL:workflowDefinitionString];
                [self.networkProvider executeRequestWithURL:url session:self alfrescoRequest:request completionBlock:^(NSData *data, NSError *workflowError) {
                    if (error)
                    {
                        AlfrescoLogError(@"Could not determine whether to use JBPM");
                        completionBlock(nil, workflowError);
                    }
                    else
                    {
                        // store the retrieved workflow definition data
                        self.repositoryInfoBuilder.workflowDefinitionData = data;
                        
                        // build the repositoryInfo object
                        self.repositoryInfo = [self.repositoryInfoBuilder repositoryInfoFromCurrentState];
                        self.repositoryInfoBuilder = nil;
                        
                        // call the original completion block
                        completionBlock(self, workflowError);
                    }
                }];
            };
            
            void (^rootFolderCompletionBlock)(CMISFolder *folder, NSError *error) = ^void(CMISFolder *rootFolder, NSError *error) {
                if (nil == rootFolder)
                {
                    AlfrescoLogError(@"repository root folder is nil");
                    completionBlock(nil, error);
                }
                else
                {
                    AlfrescoCMISToAlfrescoObjectConverter *objectConverter = [[AlfrescoCMISToAlfrescoObjectConverter alloc] initWithSession:self];
                    self.rootFolder = (AlfrescoFolder *)[objectConverter nodeFromCMISObject:rootFolder];
                    workflowDefinitionsCompletionBlock(error);
                }
            };
            
            void (^sessionv4CompletionBlock)(CMISSession *session, NSError *error) = ^void(CMISSession *v4Session, NSError *error) {
                if (nil == v4Session)
                {
                    AlfrescoLogError(@"failed to create v4 session");
                    completionBlock(nil, error);
                }
                else
                {
                    v4Session.repositoryInfo.productName = v3RepositoryProductName;
                    [self establishCMISSession:v4Session username:username password:password];
                    request.httpRequest = [v4Session retrieveRootFolderWithCompletionBlock:rootFolderCompletionBlock];
                }
            };

            void (^sessionPublicAPICompletionBlock)(CMISSession *session, NSError *error) = ^void(CMISSession *publicAPISession, NSError *error) {
                if (nil == publicAPISession)
                {
                    AlfrescoLogError(@"failed to create PublicAPI session");
                    completionBlock(nil, error);
                }
                else
                {
                    publicAPISession.repositoryInfo.productName = v3RepositoryProductName;
                    [self establishCMISSession:publicAPISession username:username password:password];
                    request.httpRequest = [publicAPISession retrieveRootFolderWithCompletionBlock:rootFolderCompletionBlock];
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

                    // Workaround for MNT-6405: Malformed cmis:productName in some v4 instances
                    v3RepositoryProductName = v3Session.repositoryInfo.productName;
                    
                    NSString *version = v3Session.repositoryInfo.productVersion;
                    NSArray *versionArray = [version componentsSeparatedByString:@"."];
                    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                    int majorVersion = [[formatter numberFromString:versionArray[0]] intValue];
                    int minorVersion = [[formatter numberFromString:versionArray[1]] intValue];
                    AlfrescoLogDebug(@"session connected with user %@, repo version is %@", username, version);

                    if (majorVersion >= 4 && !useCustomBinding)
                    {
                        // We'll intercept the v4 request completion to be able to fallback to v3
                        void (^v4sessionInterceptCompletionBlock)(CMISSession *session, NSError *error) = ^void(CMISSession *session, NSError *error) {
                            if (nil == session)
                            {
                                AlfrescoLogWarning(@"v4 session unexpectedly failed to connect; falling back to v3 endpoint");
                                // v4 session unexpectedly didn't work - fall back to v3 session
                                [self establishCMISSession:v3Session username:username password:password];
                                request.httpRequest = [v3Session retrieveRootFolderWithCompletionBlock:rootFolderCompletionBlock];
                            }
                            else
                            {
                                sessionv4CompletionBlock(session, error);
                            }
                        };

                        // PublicAPI is potentially viable for version 4.2 and newer
                        if ((majorVersion == 4 && minorVersion >= 2) || (majorVersion > 4))
                        {
                            // Try to create a PublicAPI-based session
                            void (^publicAPISessionInterceptCompletionBlock)(CMISSession *session, NSError *error) = ^void(CMISSession *session, NSError *error) {
                                if (nil == session)
                                {
                                    // Didn't work - attempt to create a v4 session
                                    AlfrescoLogDebug(@"couldn't create a PublicAPI session; falling back to v4 endpoint");
                                    request.httpRequest = [CMISSession connectWithSessionParameters:v4params completionBlock:v4sessionInterceptCompletionBlock];
                                }
                                else
                                {
                                    sessionPublicAPICompletionBlock(session, error);
                                }
                            };
                            request.httpRequest = [CMISSession connectWithSessionParameters:publicAPIparams completionBlock:publicAPISessionInterceptCompletionBlock];
                        }
                        else
                        {
                            request.httpRequest = [CMISSession connectWithSessionParameters:v4params completionBlock:v4sessionInterceptCompletionBlock];
                        }
                    }
                    else
                    {
                        [self establishCMISSession:v3Session username:username password:password];
                        request.httpRequest = [v3Session retrieveRootFolderWithCompletionBlock:rootFolderCompletionBlock];
                    }
                }
            };
            
            // Kick everything off by connecting to the v3 CMIS endpoint (webscript impl.)
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
    self.repositoryInfoBuilder.cmisSession = session;
}

- (NSArray *)allParameterKeys
{
    return [self.sessionData allKeys];
}

- (id)objectForParameter:(id)key
{
    if ([key hasPrefix:kAlfrescoSessionInternalCache])
    {
        return (self.sessionCache)[key];
    }
    return (self.sessionData)[key];
}

- (void)setObject:(id)object forParameter:(id)key
{
    if ([key hasPrefix:kAlfrescoSessionInternalCache])
    {
        (self.sessionCache)[key] = object;
    }
    else if ([self.unremovableSessionKeys containsObject:key] && ![[self allParameterKeys] containsObject:key])
    {
        (self.sessionData)[key] = object;
    }
    else
    {
        (self.sessionData)[key] = object;
    }
}

- (void)addParametersFromDictionary:(NSDictionary *)dictionary
{
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([self.unremovableSessionKeys containsObject:key] && ![[self allParameterKeys] containsObject:key])
        {
            (self.sessionData)[key] = obj;
        }
        else
        {
            (self.sessionData)[key] = obj;
        }
    }];
}

- (void)removeParameter:(id)key
{
    if ([key hasPrefix:kAlfrescoSessionInternalCache])
    {
        id cached = (self.sessionCache)[key];
        if ([cached respondsToSelector:@selector(clear)])
        {
            [cached clear];
        }
        [self.sessionCache removeObjectForKey:key];
    }
    else if (![self.unremovableSessionKeys containsObject:key])
    {
        [self.sessionData removeObjectForKey:key];
    }
}

- (void)clear
{
    [self.sessionCache enumerateKeysAndObjectsUsingBlock:^(NSString *cacheName, id cacheObj, BOOL *stop){
        if ([cacheObj respondsToSelector:@selector(clear)])
        {
            [cacheObj clear];
        }
    }];
    [self.sessionCache removeAllObjects];
}

+ (NSNumber *)majorVersionFromString:(NSString *)versionString
{
    NSArray *versionArray = [versionString componentsSeparatedByString:@"."];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *majorVersionNumber = [formatter numberFromString:versionArray[0]];
    return majorVersionNumber;
}


@end
