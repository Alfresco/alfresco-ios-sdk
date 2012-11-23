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

#import "AlfrescoCloudSession.h"
#import "CMISSession.h"
#import "CMISRepositoryService.h"
#import "CMISRepositoryInfo.h"
#import "AlfrescoObjectConverter.h"
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoBasicAuthenticationProvider.h"
#import "AlfrescoErrors.h"
#import "AlfrescoCloudNetwork.h"
#import "AlfrescoHTTPUtils.h"
#import "AlfrescoISO8601DateFormatter.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoOAuthData.h"
#import "AlfrescoOAuthAuthenticationProvider.h"
#import "CMISPassThroughAuthenticationProvider.h"
#import "AlfrescoCMISObjectConverter.h"
#import <objc/runtime.h>


@interface AlfrescoCloudSession ()

- (id)initWithParameters:(NSDictionary *)parameters;

- (void)authenticateWithEmailAddress:(NSString *)emailAddress
                            password:(NSString *)password
                     completionBlock:(AlfrescoSessionCompletionBlock)completionBlock;

- (void)authenticateWithEmailAddress:(NSString *)emailAddress
                            password:(NSString *)password
                             network:(NSString *)network
                     completionBlock:(AlfrescoSessionCompletionBlock)completionBlock;

- (void)authenticateWithOAuthData:(AlfrescoOAuthData *)oauthData
                  completionBlock:(AlfrescoSessionCompletionBlock)completionBlock;

- (void)authenticateWithOAuthData:(AlfrescoOAuthData *)oauthData
                          network:(NSString *)network
                  completionBlock:(AlfrescoSessionCompletionBlock)completionBlock;

- (NSArray *)networkArrayFromJSONData:(NSData *)data error:(NSError **)outError;

- (AlfrescoCloudNetwork *)networkFromJSON:(NSDictionary *)networkDictionary;

- (id)authProviderToBeUsed;

- (AlfrescoArrayCompletionBlock)repositoriesWithParameters:(CMISSessionParameters *)parameters completionBlock:(AlfrescoSessionCompletionBlock)completionBlock;

@property (nonatomic, strong, readwrite) NSURL *baseUrl;
@property (nonatomic, strong, readwrite) NSURL *baseURLWithoutNetwork;
@property (nonatomic, strong) NSURL *cmisUrl;
@property (nonatomic, strong, readwrite) NSMutableDictionary *sessionData;
@property (nonatomic, strong, readwrite) NSString *personIdentifier;
@property (nonatomic, strong, readwrite) AlfrescoRepositoryInfo *repositoryInfo;
@property (nonatomic, strong, readwrite) AlfrescoFolder *rootFolder;
@property (nonatomic, strong, readwrite) NSString *emailAddress;
@property (nonatomic, strong, readwrite) NSString *password;
@property (nonatomic, strong)           AlfrescoISO8601DateFormatter *dateFormatter;
@property (nonatomic, strong, readwrite) AlfrescoListingContext *defaultListingContext;
@property (nonatomic, strong, readwrite) NSString * apiKey;
@property BOOL isUsingBaseAuthenticationProvider;
@end


@implementation AlfrescoCloudSession
@synthesize baseUrl = _baseUrl;
@synthesize baseURLWithoutNetwork = _baseURLWithoutNetwork;
@synthesize cmisUrl = _cmisUrl;
@synthesize sessionData = _sessionData;
@synthesize personIdentifier = _personIdentifier;
@synthesize repositoryInfo = _repositoryInfo;
@synthesize rootFolder = _rootFolder;
@synthesize emailAddress = _emailAddress;
@synthesize password = _password;
@synthesize dateFormatter = _dateFormatter;
@synthesize defaultListingContext = _defaultListingContext;
@synthesize oauthData = _oauthData;
@synthesize apiKey = _apiKey;
@synthesize isUsingBaseAuthenticationProvider = _isUsingBaseAuthenticationProvider;

#pragma mark - Public methods

+ (void)connectWithOAuthData:(AlfrescoOAuthData *)oauthData
             completionBlock:(AlfrescoSessionCompletionBlock)completionBlock
{
    AlfrescoCloudSession *sessionInstance = [[AlfrescoCloudSession alloc] initWithParameters:nil];
    if (nil != sessionInstance)
    {
        [sessionInstance authenticateWithOAuthData:oauthData
                                   completionBlock:completionBlock];
    }
}

+ (void)connectWithOAuthData:(AlfrescoOAuthData *)oauthData
                  parameters:(NSDictionary *)parameters
             completionBlock:(AlfrescoSessionCompletionBlock)completionBlock
{
    AlfrescoCloudSession *sessionInstance = [[AlfrescoCloudSession alloc] initWithParameters:parameters];
    if (nil != sessionInstance)
    {
        BOOL useBasicConnect = NO;
        NSString * username = nil;
        NSString * password = nil;
        if (nil != parameters)
        {
            if ([[parameters allKeys] containsObject:kAlfrescoSessionCloudBasicAuth])
            {
                useBasicConnect = [[parameters valueForKey:kAlfrescoSessionCloudBasicAuth] boolValue];
            }
            if (useBasicConnect)
            {
                username = [parameters valueForKey:kAlfrescoSessionUsername];
                password = [parameters valueForKey:kAlfrescoSessionPassword];
            }
        }
        if (useBasicConnect)
        {
            [sessionInstance authenticateWithEmailAddress:username
                                                 password:password
                                          completionBlock:completionBlock];
        }
        else
        {
            [sessionInstance authenticateWithOAuthData:oauthData
                                       completionBlock:completionBlock];
        }
    }
}

+ (void)connectWithOAuthData:(AlfrescoOAuthData *)oauthData
            networkIdentifer:(NSString *)networkIdentifer
             completionBlock:(AlfrescoSessionCompletionBlock)completionBlock
{
    AlfrescoCloudSession *sessionInstance = [[AlfrescoCloudSession alloc] initWithParameters:nil];
    if (nil != sessionInstance)
    {
        [sessionInstance authenticateWithOAuthData:oauthData
                                           network:networkIdentifer
                                   completionBlock:completionBlock];
    }
}

+ (void)connectWithOAuthData:(AlfrescoOAuthData *)oauthData
            networkIdentifer:(NSString *)networkIdentifer
                  parameters:(NSDictionary *)parameters
             completionBlock:(AlfrescoSessionCompletionBlock)completionBlock
{
    AlfrescoCloudSession *sessionInstance = [[AlfrescoCloudSession alloc] initWithParameters:parameters];
    if (nil != sessionInstance)
    {
        BOOL useBasicConnect = NO;
        NSString * username = nil;
        NSString * password = nil;
        if (nil != parameters)
        {
            if ([[parameters allKeys] containsObject:kAlfrescoSessionCloudBasicAuth])
            {
                useBasicConnect = [[parameters valueForKey:kAlfrescoSessionCloudBasicAuth] boolValue];
            }
            if (useBasicConnect)
            {
                username = [parameters valueForKey:kAlfrescoSessionUsername];
                password = [parameters valueForKey:kAlfrescoSessionPassword];
            }
        }
        if (useBasicConnect)
        {
            [sessionInstance authenticateWithEmailAddress:username
                                                 password:password
                                                  network:networkIdentifer
                                          completionBlock:completionBlock];
        }
        else
        {
            [sessionInstance authenticateWithOAuthData:oauthData
                                               network:networkIdentifer
                                       completionBlock:completionBlock];
        }
    }
}

- (void)retrieveNetworksWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    __weak AlfrescoCloudSession *weakSelf = self;
    id<AlfrescoAuthenticationProvider> authProvider = [self authProviderToBeUsed];
    [self setObject:authProvider forParameter:kAlfrescoAuthenticationProviderObjectKey];
    [AlfrescoHTTPUtils executeRequestWithURL:self.baseURLWithoutNetwork session:self completionBlock:^(NSData *data, NSError *error){
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *networks = [weakSelf networkArrayFromJSONData:data error:&conversionError];
            completionBlock(networks, conversionError);
        }
        
    }];

}

- (void)setOauthData:(AlfrescoOAuthData *)oauthData
{
    if (_oauthData == oauthData)
    {
        return;
    }
    if (nil != _oauthData)
    {
        _oauthData = nil;
    }
    _oauthData = oauthData;

    if (nil != _oauthData)
    {
        id<AlfrescoAuthenticationProvider> authProvider = [self authProviderToBeUsed];
        [self setObject:authProvider forParameter:kAlfrescoAuthenticationProviderObjectKey];
    }
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

#pragma mark - Private methods

- (id)authProviderToBeUsed
{
    if (self.isUsingBaseAuthenticationProvider)
    {
        return [[AlfrescoBasicAuthenticationProvider alloc] initWithUsername:self.emailAddress andPassword:self.password];
    }
    else
    {
        return [[AlfrescoOAuthAuthenticationProvider alloc] initWithOAuthData:self.oauthData];
    }
}

- (void)authenticateWithOAuthData:(AlfrescoOAuthData *)oauthData
                  completionBlock:(AlfrescoSessionCompletionBlock)completionBlock
{
    self.isUsingBaseAuthenticationProvider = NO;
    NSString *baseURL = kAlfrescoCloudURL;
    if ([[self.sessionData allKeys] containsObject:kAlfrescoSessionCloudURL])
    {
        baseURL = [self.sessionData valueForKey:kAlfrescoSessionCloudURL];
        log(@"overriding Cloud URL with: %@", baseURL);
    }
    self.baseUrl = [NSURL URLWithString:baseURL];
    self.baseURLWithoutNetwork = [NSURL URLWithString:baseURL];
    self.oauthData = oauthData;
    [self retrieveNetworksWithCompletionBlock:^(NSArray *networks, NSError *error){
        if (nil == networks)
        {
            log(@"*** authenticateWithOAuthData returns with network array == NIL");
            completionBlock(nil, error);
        }
        else
        {
            log(@"*** authenticateWithOAuthData we have %d networks",networks.count);
            __block AlfrescoCloudNetwork *homeNetwork = nil;
            for (AlfrescoCloudNetwork *network in networks)
            {
                if (network.isHomeNetwork)
                {
                    log(@"found home network %@",network.identifier);
                    homeNetwork = network;
                    break;
                }
            }
            if (nil == homeNetwork)
            {
                completionBlock(nil, error);
            }
            else
            {
                log(@"*** authenticateWithOAuthData found home network with id %@", homeNetwork.identifier);
                [self authenticateWithOAuthData:oauthData
                                        network:homeNetwork.identifier
                                completionBlock:completionBlock];
            }
            
        }
    }];
    
}


- (void)authenticateWithOAuthData:(AlfrescoOAuthData *)oauthData
                          network:(NSString *)network
                  completionBlock:(AlfrescoSessionCompletionBlock)completionBlock
{
    self.isUsingBaseAuthenticationProvider = NO;
    log(@"*** ENTERING authenticateWithOAuthData with specified home network");
    NSString *baseURL = kAlfrescoCloudURL;
    if ([[self.sessionData allKeys] containsObject:kAlfrescoSessionCloudURL])
    {
        baseURL = [self.sessionData valueForKey:kAlfrescoSessionCloudURL];
        log(@"overriding Cloud URL with: %@", baseURL);
    }
    self.baseUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",baseURL,network]];
    self.baseURLWithoutNetwork = [NSURL URLWithString:baseURL];
    self.oauthData = oauthData;
    self.personIdentifier = kAlfrescoMe;
    CMISSessionParameters *params = [[CMISSessionParameters alloc] initWithBindingType:CMISBindingTypeAtomPub];
    NSString *cmisUrl = [[self.baseUrl absoluteString] stringByAppendingString:kAlfrescoCloudCMISPath];
    self.cmisUrl = [NSURL URLWithString:cmisUrl];
    params.atomPubUrl = self.cmisUrl;
    log(@"*** authenticateWithOAuthData setting authentication providers");
    id<AlfrescoAuthenticationProvider> authProvider = [self authProviderToBeUsed];
    [self setObject:authProvider forParameter:kAlfrescoAuthenticationProviderObjectKey];
    CMISPassThroughAuthenticationProvider *passthroughAuthProvider = [[CMISPassThroughAuthenticationProvider alloc] initWithAlfrescoAuthenticationProvider:authProvider];
    params.authenticationProvider = passthroughAuthProvider;
    
    AlfrescoArrayCompletionBlock repositoryCompletionBlock = [self repositoriesWithParameters:params completionBlock:completionBlock];
    [CMISSession arrayOfRepositories:params completionBlock:repositoryCompletionBlock];
}

- (AlfrescoArrayCompletionBlock)repositoriesWithParameters:(CMISSessionParameters *)parameters completionBlock:(AlfrescoSessionCompletionBlock)completionBlock
{
    AlfrescoArrayCompletionBlock arrayCompletionBlock = ^void(NSArray *repositories, NSError *error){
        if (nil == repositories)
        {
            if(completionBlock)
            {
                completionBlock(nil, error);
            }
        }
        else if( 0 == repositories.count)
        {
            error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeNoRepositoryFound];
            if(completionBlock)
            {
                completionBlock(nil, error);
            }
            
        }
        else
        {
            CMISRepositoryInfo *repoInfo = [repositories objectAtIndex:0];
            parameters.repositoryId = repoInfo.identifier;
            [parameters setObject:NSStringFromClass([AlfrescoCMISObjectConverter class]) forKey:kCMISSessionParameterObjectConverterClassName];
            [CMISSession connectWithSessionParameters:parameters completionBlock:^(CMISSession *cmisSession, NSError *error){
                if (nil == cmisSession)
                {
                    if(completionBlock)
                    {
                        completionBlock(nil, error);
                    }
                }
                else
                {
                    AlfrescoObjectConverter *objectConverter = [[AlfrescoObjectConverter alloc] initWithSession:self];
                    self.repositoryInfo = [objectConverter repositoryInfoFromCMISSession:cmisSession];
                    [cmisSession retrieveRootFolderWithCompletionBlock:^(CMISFolder *rootFolder, NSError *error){
                        if (nil == rootFolder)
                        {
                            if(completionBlock)
                            {
                                completionBlock(nil, error);
                            }
                        }
                        else
                        {
                            self.rootFolder = (AlfrescoFolder *)[objectConverter nodeFromCMISObject:rootFolder];
                            if(completionBlock)
                            {
                                completionBlock(self, nil);
                            }
                        }
                    }];
                    
                }
            }];
            
        }
    };
    return arrayCompletionBlock;
}



/**
This authentication method authorises the user to access the home network assigned to the account. It first searches the available networks for the user
 (using retrieveNetworksWithCompletionBlock) and from within that block proceeds to full authentication for a specific network.
 */
- (void)authenticateWithEmailAddress:(NSString *)emailAddress
                            password:(NSString *)password
                     completionBlock:(AlfrescoSessionCompletionBlock)completionBlock
{
    NSString *baseURL = kAlfrescoCloudURL;
    if ([[self.sessionData allKeys] containsObject:kAlfrescoSessionCloudURL])
    {
        baseURL = [self.sessionData valueForKey:kAlfrescoSessionCloudURL];
        log(@"overriding Cloud URL with: %@", baseURL);
    }
    self.baseUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseURL, kAlfrescoCloudPrecursor]];
    self.baseURLWithoutNetwork = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseURL, kAlfrescoCloudPrecursor]];
    log(@"**** baseURLWithoutNetwork = %@ ****", [self.baseURLWithoutNetwork absoluteString]);
    self.isUsingBaseAuthenticationProvider = YES;
    self.emailAddress = emailAddress;
    self.password = password;
    self.dateFormatter = [[AlfrescoISO8601DateFormatter alloc] init];
    __weak AlfrescoCloudSession *weakSelf = self;
    [self retrieveNetworksWithCompletionBlock:^(NSArray *networks, NSError *error){
        if (nil == networks)
        {
            log(@"*** authenticateWithUsername network returns NIL");
            completionBlock(nil, error);
        }
        else
        {
            log(@"*** authenticateWithUsername we have %d networks",networks.count);
            AlfrescoCloudNetwork *homeNetwork = nil;
            for (AlfrescoCloudNetwork *network in networks)
            {
                if (network.isHomeNetwork)
                {
                    log(@"found home network %@",network.identifier);
                    homeNetwork = network;
                    break;
                }
            }
            if (nil == homeNetwork)
            {
                completionBlock(nil, error);
            }
            else
            {
                [weakSelf authenticateWithEmailAddress:weakSelf.emailAddress
                                              password:weakSelf.password
                                               network:homeNetwork.identifier
                                       completionBlock:completionBlock];
            }
        }
    }];
    
}

/**
 This method is the full authentication implementation for a specific network, including the home network. It sets up the (CMIS) session, repository info and
 other basic parameters required in the API.
 */
- (void)authenticateWithEmailAddress:(NSString *)emailAddress
                            password:(NSString *)password
                             network:(NSString *)network
                     completionBlock:(AlfrescoSessionCompletionBlock)completionBlock
{
    NSString *baseURL = kAlfrescoCloudURL;
    if ([[self.sessionData allKeys] containsObject:kAlfrescoSessionCloudURL])
    {
        baseURL = [self.sessionData valueForKey:kAlfrescoSessionCloudURL];
        log(@"overriding Cloud URL with: %@", baseURL);
    }
    self.baseUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@", baseURL, kAlfrescoCloudPrecursor, network]];
    self.baseURLWithoutNetwork = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseURL, kAlfrescoCloudPrecursor]];
    self.isUsingBaseAuthenticationProvider = YES;
    NSString *cmisUrl = [[self.baseUrl absoluteString] stringByAppendingString:kAlfrescoCloudCMISPath];
    self.cmisUrl = [NSURL URLWithString:cmisUrl];
    self.dateFormatter = [[AlfrescoISO8601DateFormatter alloc] init];

    CMISSessionParameters *params = [[CMISSessionParameters alloc] initWithBindingType:CMISBindingTypeAtomPub];
    params.username = emailAddress;
    params.password = password;
    params.atomPubUrl = self.cmisUrl;
    AlfrescoArrayCompletionBlock repositoryCompletionBlock = [self repositoriesWithParameters:params completionBlock:completionBlock];
    [CMISSession arrayOfRepositories:params completionBlock:repositoryCompletionBlock];
}

/**
 initialise with custom settings. Settings is an optional parameter and can be nil
 For cloud the metadataextraction/thumbnail creation - available for onpremise services - is disabled.
 The init method will override any values given for both parameters
 */
- (id)initWithParameters:(NSDictionary *)parameters
{
    self = [super init];
    if (nil != self)
    {
        if (nil != parameters)
        {
            self.sessionData = [NSMutableDictionary dictionaryWithDictionary:parameters];
        }
        else
        {
            self.sessionData = [NSMutableDictionary dictionaryWithCapacity:8];
        }
        [self setObject:[NSNumber numberWithBool:NO] forParameter:kAlfrescoMetadataExtraction];
        [self setObject:[NSNumber numberWithBool:NO] forParameter:kAlfrescoThumbnailCreation];
        
        // setup defaults
        self.defaultListingContext = [[AlfrescoListingContext alloc] init];
    }
    return self;
}

/**
 Obtains an AlfrescoCloudNetwork object from a set of JSON data
 */
- (AlfrescoCloudNetwork *)networkFromJSON:(NSDictionary *)networkDictionary
{
    AlfrescoCloudNetwork *network = [[AlfrescoCloudNetwork alloc] init];
    network.identifier = [networkDictionary valueForKey:kAlfrescoJSONIdentifier];
    id homeNetworkValidateString = [networkDictionary valueForKey:kAlfrescoJSONHomeNetwork];
    if ([homeNetworkValidateString isKindOfClass:[NSNumber class]])
    {
        NSNumber *number = (NSNumber *)homeNetworkValidateString;
        network.isHomeNetwork = [number boolValue];
    }
    id paidValidationString = [networkDictionary valueForKey:kAlfrescoJSONPaidNetwork];
    if ([paidValidationString isKindOfClass:[NSNumber class]])
    {
        NSNumber *paidNumber = (NSNumber *)paidValidationString;
        network.isPaidNetwork = [paidNumber boolValue];
    }
    
    id createdAtObject = [networkDictionary valueForKey:kAlfrescoJSONCreatedAt];
    if ([createdAtObject isKindOfClass:[NSString class]])
    {
        NSString *dateString = (NSString *)createdAtObject;
        if (nil != dateString)
        {
            network.createdAt = [self.dateFormatter dateFromString:dateString];
        }
    }
                
    network.subscriptionLevel = [networkDictionary valueForKey:kAlfrescoJSONSubscriptionLevel];
    return network;
}

/**
 parses the JSON data to look for an array containing the Alfresco network details. Once found, it calls the networkFromJSON method
 to set up a AlfrescoCloudNetwork object.
 */
- (NSArray *) networkArrayFromJSONData:(NSData *)data error:(NSError **)outError
{
    if (data == nil)
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        }
        else
        {
            NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
            *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        }
        return nil;
    }
    NSError *error = nil;
    log(@"****** NETWORK JSON DATA RETURN: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    id jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (nil == jsonDictionary)
    {
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        return nil;
    }
    
    if (![jsonDictionary isKindOfClass:[NSDictionary class]])
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        }
        else
        {
            NSError *underlyingError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
            *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:underlyingError andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        }
        return nil;
    }
    
    id listObject = [jsonDictionary valueForKey:kAlfrescoCloudJSONList];
    if (![listObject isKindOfClass:[NSDictionary class]])
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        }
        else
        {
            NSError *underlyingError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
            *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:underlyingError andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        }
        return nil;
    }
    id entries = [listObject valueForKey:kAlfrescoCloudJSONEntries];
    if (![entries isKindOfClass:[NSArray class]])
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        }
        else
        {
            NSError *underlyingError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
            *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:underlyingError andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        }
        return nil;
    }
    NSArray *entriesArray = [NSArray arrayWithArray:entries];
    if (0 == entriesArray.count)
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeNoNetworkFound];
        }
        else
        {
            NSError *underlyingError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeNoNetworkFound];
            *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:underlyingError andAlfrescoErrorCode:kAlfrescoErrorCodeNoNetworkFound];
        }
        return nil;
    }
        
    NSMutableArray *resultsArray = [NSMutableArray arrayWithCapacity:entriesArray.count];
    
    for (NSDictionary *entryDict in entriesArray)
    {
        NSDictionary *individualEntry = [entryDict valueForKey:kAlfrescoCloudJSONEntry];
        [resultsArray addObject:[self networkFromJSON:individualEntry]];
    }
    return resultsArray;
    
}

@end
