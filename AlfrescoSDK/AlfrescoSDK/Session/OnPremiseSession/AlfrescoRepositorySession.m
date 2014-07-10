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
#import "AlfrescoCMISUtil.h"
#import "CMISErrors.h"

@interface AlfrescoRepositorySession ()
@property (nonatomic, strong, readwrite) NSURL *baseUrl;
@property (nonatomic, strong, readwrite) NSMutableDictionary *sessionData;
@property (nonatomic, strong, readwrite) NSString *personIdentifier;

@property (nonatomic, strong, readwrite) AlfrescoRepositoryInfo *repositoryInfo;
@property (nonatomic, strong, readwrite) AlfrescoRepositoryInfoBuilder *repositoryInfoBuilder;
@property (nonatomic, strong, readwrite) AlfrescoFolder *rootFolder;
@property (nonatomic, strong, readwrite) AlfrescoListingContext *defaultListingContext;
@property (nonatomic, strong, readwrite) id<AlfrescoNetworkProvider> networkProvider;
@property (nonatomic, strong, readwrite) NSArray *unremovableSessionKeys;
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
    // start by looking for public API CMIS Atom binding
    __block NSString *cmisUrl = [[self.baseUrl absoluteString] stringByAppendingString:kAlfrescoPublicAPICMISAtomPath];
    
    // determine if we have to use a custom binding URL
    BOOL useCustomBinding = NO;
    NSString *customBindingURL = (self.sessionData)[kAlfrescoCMISBindingURL];
    if (customBindingURL)
    {
        NSString *binding = ([customBindingURL hasPrefix:@"/"]) ? customBindingURL : [NSString stringWithFormat:@"/%@",customBindingURL];
        cmisUrl = [[self.baseUrl absoluteString] stringByAppendingString:binding];
        useCustomBinding = YES;
    }
    
    // setup CMIS session parameters
    CMISSessionParameters *cmisSessionParams = [[CMISSessionParameters alloc] initWithBindingType:CMISBindingTypeAtomPub];
    cmisSessionParams.username = username;
    cmisSessionParams.password = password;
    cmisSessionParams.atomPubUrl = [NSURL URLWithString:cmisUrl];
    
    // setup custom CMIS network provider, if necessary
    if ((self.sessionData)[kAlfrescoCMISNetworkProvider])
    {
        id customCMISNetworkProvider = (self.sessionData)[kAlfrescoCMISNetworkProvider];
        BOOL conformsToCMISNetworkProvider = [customCMISNetworkProvider conformsToProtocol:@protocol(CMISNetworkProvider)];
        
        if (conformsToCMISNetworkProvider)
        {
            cmisSessionParams.networkProvider = (id<CMISNetworkProvider>)customCMISNetworkProvider;
        }
        else
        {
            @throw([NSException exceptionWithName:@"Error with custom CMIS network provider"
                                           reason:@"The custom network provider must be an object that conforms to the CMISNetworkProvider protocol"
                                         userInfo:nil]);
        }
    }
    
    // setup SSL related features
    BOOL allowUntrustedSSLCertificate = [(self.sessionData)[kAlfrescoAllowUntrustedSSLCertificate] boolValue];
    BOOL connectUsingSSLCertificate = [(self.sessionData)[kAlfrescoConnectUsingClientSSLCertificate] boolValue];
    
    if (connectUsingSSLCertificate)
    {
        // if client certificates are required, certificate credentials need to be setup for auth provider
        NSURLCredential *credential = (self.sessionData)[kAlfrescoClientCertificateCredentials];
        CMISStandardAuthenticationProvider *authProvider = [[CMISStandardAuthenticationProvider alloc] initWithUsername:username password:password];
        authProvider.credential = credential;
        cmisSessionParams.authenticationProvider = (id<CMISAuthenticationProvider>)authProvider;
    }
    else if (allowUntrustedSSLCertificate)
    {
        // If connections are allowed for untrusted SSL certificates, we need a custom CMISAuthenticationProvider: CMISStandardUntrustedSSLAuthenticationProvider
        CMISStandardUntrustedSSLAuthenticationProvider *authProvider = [[CMISStandardUntrustedSSLAuthenticationProvider alloc] initWithUsername:username password:password];
        cmisSessionParams.authenticationProvider = (id<CMISAuthenticationProvider>)authProvider;
    }
    
    // try to get repositories
    AlfrescoRequest *request = [AlfrescoRequest new];
    AlfrescoLogDebug(@"Attempting session creation using: %@", cmisUrl);
    request.httpRequest = [CMISSession arrayOfRepositories:cmisSessionParams completionBlock:^(NSArray *repositories, NSError *error) {
        if (repositories == nil)
        {
            // check that the failure wasn't due to incorrect credentials,
            // little point carrying on with incorrect username/password!
            if (error.code == kCMISErrorCodeUnauthorized)
            {
                NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:error];
                completionBlock(nil, alfrescoError);
            }
            else
            {
                // public API failed so now try the legacy CMIS Atom API
                cmisUrl = [[self.baseUrl absoluteString] stringByAppendingString:kAlfrescoLegacyCMISAtomPath];
                AlfrescoLogDebug(@"Attempting session creation using: %@", cmisUrl);
                cmisSessionParams.atomPubUrl = [NSURL URLWithString:cmisUrl];
                request.httpRequest = [CMISSession arrayOfRepositories:cmisSessionParams completionBlock:^(NSArray *repositories, NSError *error) {
                    if (repositories == nil)
                    {
                        // legacy CMIS Atom API failed so now try the original webscript CMIS API
                        cmisUrl = [[self.baseUrl absoluteString] stringByAppendingString:kAlfrescoLegacyCMISPath];
                        AlfrescoLogDebug(@"Attempting session creation using: %@", cmisUrl);
                        cmisSessionParams.atomPubUrl = [NSURL URLWithString:cmisUrl];
                        request.httpRequest = [CMISSession arrayOfRepositories:cmisSessionParams completionBlock:^(NSArray *repositories, NSError *error) {
                            if (repositories == nil)
                            {
                                // we don't have any other entry points to try so give up and return error
                                NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:error];
                                completionBlock(nil, alfrescoError);
                            }
                            else
                            {
                                // establish the session
                                [self establishAlfrescoSessionWithSessionParameters:cmisSessionParams repositories:repositories completionBlock:completionBlock];
                            }
                        }];
                    }
                    else
                    {
                        // establish the session
                        [self establishAlfrescoSessionWithSessionParameters:cmisSessionParams repositories:repositories completionBlock:completionBlock];
                    }
                }];
            }
        }
        else
        {
            // establish the session
            [self establishAlfrescoSessionWithSessionParameters:cmisSessionParams repositories:repositories completionBlock:completionBlock];
        }
    }];
    
    return request;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (AlfrescoRequest *)establishAlfrescoSessionWithSessionParameters:(CMISSessionParameters *)cmisSessionParams
                                                      repositories:(NSArray *)repositories
                                                   completionBlock:(AlfrescoSessionCompletionBlock)completionBlock
{
    AlfrescoRequest *request = [AlfrescoRequest new];
    
    // check that we found at least one repository
    if (repositories.count == 0)
    {
        // no repositories found, no point going any further, return error
        NSError *alfrescoError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeNoRepositoryFound];
        completionBlock(nil, alfrescoError);
    }
    else
    {
        CMISRepositoryInfo *repoInfo = repositories[0];
        AlfrescoLogDebug(@"Found repository with ID: %@", repoInfo.identifier);
    
        // setup CMIS session params
        cmisSessionParams.repositoryId = repoInfo.identifier;
        [cmisSessionParams setObject:NSStringFromClass([AlfrescoCMISObjectConverter class]) forKey:kCMISSessionParameterObjectConverterClassName];
    
        // create CMIS session
        request.httpRequest = [CMISSession connectWithSessionParameters:cmisSessionParams
                                                        completionBlock:^(CMISSession *cmisSession, NSError *cmisSessionError) {
            if (cmisSession == nil)
            {
                AlfrescoLogError(@"CMIS session creation failed: %@", [cmisSessionError localizedDescription]);
                NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:cmisSessionError];
                completionBlock(nil, alfrescoError);
            }
            else
            {
                // store the CMIS session
                [self setObject:cmisSession forParameter:kAlfrescoSessionKeyCmisSession];
                self.repositoryInfoBuilder.cmisSession = cmisSession;
                
                // setup the authentication provider
                id<AlfrescoAuthenticationProvider> authProvider = [[AlfrescoBasicAuthenticationProvider alloc] initWithUsername:cmisSessionParams.username
                                                                                                                    andPassword:cmisSessionParams.password];
                [self setObject:authProvider forParameter:kAlfrescoAuthenticationProviderObjectKey];
                
                // store the current username for use by services
                self.personIdentifier = cmisSessionParams.username;
                
                // retrieve the root folder for the session
                request.httpRequest = [cmisSession retrieveRootFolderWithCompletionBlock:^(CMISFolder *rootFolder, NSError *rootFolderError) {
                    if (rootFolder == nil)
                    {
                        AlfrescoLogError(@"Root folder retrieval failed: %@", [cmisSessionError localizedDescription]);
                        NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:rootFolderError];
                        completionBlock(nil, alfrescoError);
                    }
                    else
                    {
                        AlfrescoCMISToAlfrescoObjectConverter *objectConverter = [[AlfrescoCMISToAlfrescoObjectConverter alloc] initWithSession:self];
                        self.rootFolder = (AlfrescoFolder *)[objectConverter nodeFromCMISObject:rootFolder];
                        
                        // now retrieve workflow definition data
                        NSString *workflowDefinitionString = [kAlfrescoLegacyAPIPath stringByAppendingString:kAlfrescoLegacyAPIWorkflowProcessDefinition];
                        NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseUrl.absoluteString extensionURL:workflowDefinitionString];
                        [self.networkProvider executeRequestWithURL:url session:self alfrescoRequest:request
                                                    completionBlock:^(NSData *workflowData, NSError *workflowError) {
                            if (workflowError)
                            {
                                AlfrescoLogError(@"Workflow definitions retrieval failed: %@", [workflowError localizedDescription]);
                                completionBlock(nil, workflowError);
                            }
                            else
                            {
                                // store the retrieved workflow definition data
                                self.repositoryInfoBuilder.workflowDefinitionData = workflowData;
                                
                                // build the repositoryInfo object
                                self.repositoryInfo = [self.repositoryInfoBuilder repositoryInfoFromCurrentState];
                                self.repositoryInfoBuilder = nil;
                                
                                // check the repository product name and edition are not malformed due to MNT-6405
                                if ([self.repositoryInfo.edition isEqualToString:kAlfrescoRepositoryEditionUnknown])
                                {
                                    // edition has not be been populated correctly, retrieve it from legacy "server" API
                                    NSString *serverInfoString = [kAlfrescoLegacyAPIPath stringByAppendingString:kAlfrescoLegacyServerAPI];
                                    NSURL *serverInfoUrl = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseUrl.absoluteString extensionURL:serverInfoString];
                                    [self.networkProvider executeRequestWithURL:serverInfoUrl session:self alfrescoRequest:request
                                                                completionBlock:^(NSData *serverInfoData, NSError *serverInfoError) {
                                        if (serverInfoData == nil)
                                        {
                                            AlfrescoLogError(@"Server info retrieval failed: %@", [serverInfoError localizedDescription]);
                                            completionBlock(nil, serverInfoError);
                                        }
                                        else
                                        {
                                            // extract the edition from the response
                                            NSError *parseError = nil;
                                            id serverInfoDictionary = [NSJSONSerialization JSONObjectWithData:serverInfoData options:0 error:&parseError];
                                            if (serverInfoDictionary != nil)
                                            {
                                                NSString *keyPath = [[NSString alloc] initWithFormat:@"%@.%@", kAlfrescoJSONData, kAlfrescoRepositoryEdition];
                                                NSString *edition = [serverInfoDictionary valueForKeyPath:keyPath];
                                                if (edition != nil)
                                                {
                                                    // update edition string by calling setter via performSelector
                                                    SEL setEditionSelector = sel_registerName("setEdition:");
                                                    [self.repositoryInfo performSelector:setEditionSelector withObject:edition];
                                                    
                                                    // update the product name by calling setter via performSelector
                                                    NSString *fixedProductName = [NSString stringWithFormat:kAlfrescoRepositoryNamePattern, self.repositoryInfo.edition];
                                                    SEL setNameSelector = sel_registerName("setName:");
                                                    [self.repositoryInfo performSelector:setNameSelector withObject:fixedProductName];
                                                }
                                            }
                                            
                                            // session creation is complete, call the original completion block
                                            AlfrescoLogDebug(@"Session established for user %@, repo version: %@ %@ Edition",
                                                             self.personIdentifier, self.repositoryInfo.version, self.repositoryInfo.edition);
                                            completionBlock(self, nil);
                                        }
                                    }];
                                }
                                else
                                {
                                    // session creation is complete, call the original completion block
                                    AlfrescoLogDebug(@"Session established for user %@, repo version: %@ %@ Edition",
                                                     self.personIdentifier, self.repositoryInfo.version, self.repositoryInfo.edition);
                                    completionBlock(self, nil);
                                }
                            }
                        }];
                    }
                }];
            }
        }];
    }
    
    return request;
}

#pragma clang diagnostic pop

- (NSArray *)allParameterKeys
{
    return [self.sessionData allKeys];
}

- (id)objectForParameter:(id)key
{
    return (self.sessionData)[key];
}

- (void)setObject:(id)object forParameter:(id)key
{
    (self.sessionData)[key] = object;
}

- (void)addParametersFromDictionary:(NSDictionary *)dictionary
{
    [self.sessionData addEntriesFromDictionary:dictionary];
}

- (void)removeParameter:(id)key
{
    if (![self.unremovableSessionKeys containsObject:key])
    {
        [self.sessionData removeObjectForKey:key];
    }
}

- (void)clear
{
    // call the clear method on any objects stored in the session that have the method
    [self.sessionData enumerateKeysAndObjectsUsingBlock:^(NSString *cacheName, id cacheObj, BOOL *stop){
        if ([cacheObj respondsToSelector:@selector(clear)])
        {
            [cacheObj clear];
        }
    }];
}


@end
