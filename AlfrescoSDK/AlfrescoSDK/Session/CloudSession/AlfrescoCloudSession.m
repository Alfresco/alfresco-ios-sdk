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
#import <objc/runtime.h>


@interface AlfrescoCloudSession ()
- (id)initWithParameters:(NSDictionary *)parameters;

- (void)authenticateWithEmailAddress:(NSString *)emailAddress
                            password:(NSString *)password
                              apiKey:(NSString *)apiKey
                     completionBlock:(AlfrescoSessionCompletionBlock)completionBlock;

- (void)authenticateWithEmailAddress:(NSString *)emailAddress
                            password:(NSString *)password
                              apiKey:(NSString *)key
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

@property (nonatomic, strong, readwrite) NSURL *baseUrl;
@property (nonatomic, strong) NSURL *cmisUrl;
@property (nonatomic, strong, readwrite) NSMutableDictionary *sessionData;
@property (nonatomic, strong, readwrite) NSString *personIdentifier;
@property (nonatomic, strong, readwrite) AlfrescoRepositoryInfo *repositoryInfo;
@property (nonatomic, strong, readwrite) AlfrescoFolder *rootFolder;
@property (nonatomic, strong, readwrite) NSString *emailAddress;
@property (nonatomic, strong, readwrite) NSString *password;
@property (nonatomic, strong)           AlfrescoISO8601DateFormatter *dateFormatter;
//@property (nonatomic, strong, readwrite) AlfrescoCloudNetwork *network;
@property (nonatomic, strong, readwrite) AlfrescoListingContext *defaultListingContext;
@property (nonatomic, strong, readwrite) NSString * apiKey;
@property BOOL isUsingBaseAuthenticationProvider;
@end


@implementation AlfrescoCloudSession
@synthesize baseUrl = _baseUrl;
@synthesize cmisUrl = _cmisUrl;
@synthesize sessionData = _sessionData;
@synthesize personIdentifier = _personIdentifier;
@synthesize repositoryInfo = _repositoryInfo;
@synthesize rootFolder = _rootFolder;
@synthesize emailAddress = _emailAddress;
@synthesize password = _password;
@synthesize dateFormatter = _dateFormatter;
//@synthesize network = _network;
@synthesize defaultListingContext = _defaultListingContext;
@synthesize oauthData = _oauthData;
@synthesize apiKey = _apiKey;
@synthesize isUsingBaseAuthenticationProvider = _isUsingBaseAuthenticationProvider;
#pragma public methods


+ (void)connectWithEmailAddress:(NSString *)emailAddress
                       password:(NSString *)password
                         apiKey:(NSString *)apiKey
                     parameters:(NSDictionary *)parameters
                completionBlock:(AlfrescoSessionCompletionBlock)completionBlock
{
    AlfrescoCloudSession *sessionInstance = [[AlfrescoCloudSession alloc] initWithParameters:parameters];
    if (nil != sessionInstance)
    {
        [sessionInstance authenticateWithEmailAddress:emailAddress password:password apiKey:apiKey completionBlock:completionBlock];
    }
}


+ (void)connectWithEmailAddress:(NSString *)emailAddress
                       password:(NSString *)password
                         apiKey:(NSString *)apiKey
               networkIdentifer:(NSString *)networkIdentifer
                     parameters:(NSDictionary *)parameters
                completionBlock:(AlfrescoSessionCompletionBlock)completionBlock
{
    AlfrescoCloudSession *sessionInstance = [[AlfrescoCloudSession alloc] initWithParameters:parameters];
    if (nil != sessionInstance)
    {
        [sessionInstance authenticateWithEmailAddress:emailAddress password:password apiKey:apiKey network:networkIdentifer completionBlock:completionBlock];
    }
    
}

+ (void)connectWithOAuthData:(AlfrescoOAuthData *)oauthData
                  parameters:(NSDictionary *)parameters
             completionBlock:(AlfrescoSessionCompletionBlock)completionBlock
{
    AlfrescoCloudSession *sessionInstance = [[AlfrescoCloudSession alloc] initWithParameters:parameters];
    if (nil != sessionInstance)
    {
        [sessionInstance authenticateWithOAuthData:oauthData completionBlock:completionBlock];
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
        [sessionInstance authenticateWithOAuthData:oauthData
                                           network:networkIdentifer
                                   completionBlock:completionBlock];
    }    
}





- (void)retrieveNetworksWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    __weak AlfrescoCloudSession *weakSelf = self;
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue addOperationWithBlock:^(){
        NSError *operationQueueError = nil;
        id<AlfrescoAuthenticationProvider> authProvider = [weakSelf authProviderToBeUsed];
//        objc_setAssociatedObject(self, &kAlfrescoAuthenticationProviderObjectKey, authProvider, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self setObject:authProvider forParameter:kAlfrescoAuthenticationProviderObjectKey];
        NSData *jsonData = [AlfrescoHTTPUtils executeRequestWithURL:self.baseUrl
                                                            session:self
                                                               data:nil
                                                         httpMethod:@"GET"
                                                              error:&operationQueueError];
        if (nil == jsonData)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                log(@"***retrieveNetworksForUsername jsonData is NIL");
                completionBlock(nil, operationQueueError);
            }];
        }
        NSLog(@"After parsing jsonData");
        NSArray *networks = [weakSelf networkArrayFromJSONData:jsonData error:&operationQueueError];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(networks, operationQueueError);
        }];
    }];
}



+ (void)signUpWithUserIdentifier:(NSString *)userIdentifier
                        password:(NSString *)password
                       firstName:(NSString *)firstName
                        lastName:(NSString *)lastName
                          apiKey:(NSString *)apiKey
{
    
}

- (void)disconnect
{
    CMISSession *cmisSession = [self.sessionData objectForKey:kAlfrescoSessionKeyCmisSession];
    [cmisSession.binding clearAllCaches];
}


#pragma private methods

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
    NSString *baseURL = kAlfrescoOAuthCloudURL;
    if ([[self.sessionData allKeys] containsObject:kAlfrescoCloudTestParameter])
    {
        BOOL isTest = [[self.sessionData valueForKey:kAlfrescoCloudTestParameter] boolValue];
        if (isTest)
        {
            baseURL = kAlfrescoOAuthTestCloudURL;
        }
    }
    self.baseUrl = [NSURL URLWithString:baseURL];
    self.oauthData = oauthData;
    [self retrieveNetworksWithCompletionBlock:^(NSArray *networks, NSError *error){
        if (nil == networks)
        {
            NSLog(@"*** authenticateWithOAuthData returns with network array == NIL");
            completionBlock(nil, error);
        }
        else
        {
            NSLog(@"*** authenticateWithOAuthData we have %d networks",networks.count);
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
                NSLog(@"*** authenticateWithOAuthData found home network with id %@", homeNetwork.identifier);
                [self authenticateWithOAuthData:oauthData
                                        network:homeNetwork.identifier
                                completionBlock:completionBlock];
//                completionBlock(self, error);
            }
            
        }
    }];
    
}


- (void)authenticateWithOAuthData:(AlfrescoOAuthData *)oauthData
                          network:(NSString *)network
                  completionBlock:(AlfrescoSessionCompletionBlock)completionBlock
{
    self.isUsingBaseAuthenticationProvider = NO;
    NSLog(@"*** ENTERING authenticateWithOAuthData with specified home network");
    NSString *baseURL = kAlfrescoOAuthCloudURL;
    if ([[self.sessionData allKeys] containsObject:kAlfrescoCloudTestParameter])
    {
        BOOL isTest = [[self.sessionData valueForKey:kAlfrescoCloudTestParameter] boolValue];
        if (isTest)
        {
            baseURL = kAlfrescoOAuthTestCloudURL;
        }
    }
    self.baseUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",baseURL,network]];
    self.oauthData = oauthData;
    self.personIdentifier = kAlfrescoMe;
    CMISSessionParameters *params = [[CMISSessionParameters alloc] initWithBindingType:CMISBindingTypeAtomPub];
    NSString *cmisUrl = [[self.baseUrl absoluteString] stringByAppendingString:kAlfrescoCloudCMISPath];
    self.cmisUrl = [NSURL URLWithString:cmisUrl];
    params.atomPubUrl = self.cmisUrl;
    NSLog(@"*** authenticateWithOAuthData setting authentication providers");
    id<AlfrescoAuthenticationProvider> authProvider = [self authProviderToBeUsed];
//    objc_setAssociatedObject(self, &kAlfrescoAuthenticationProviderObjectKey, authProvider, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setObject:authProvider forParameter:kAlfrescoAuthenticationProviderObjectKey];
    CMISPassThroughAuthenticationProvider *passthroughAuthProvider = [[CMISPassThroughAuthenticationProvider alloc] initWithAlfrescoAuthenticationProvider:authProvider];
    params.authenticationProvider = passthroughAuthProvider;
    
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
            //            AlfrescoCloudSession *session = nil;
            CMISRepositoryInfo *repoInfo = [repositories objectAtIndex:0];
            
            params.repositoryId = repoInfo.identifier;
            
            // enable Alfresco mode in CMIS Session
            [params setObject:kCMISAlfrescoMode forKey:kCMISSessionParameterMode];
            
            // create the session using the paramters
            NSLog(@"*** authenticateWithOAuthData before setting CMIS session");
            CMISSession *cmisSession = [[CMISSession alloc] initWithSessionParameters:params];
            [self.sessionData setObject:cmisSession forKey:kAlfrescoSessionKeyCmisSession];
            NSLog(@"*** authenticateWithOAuthData after setting CMIS session");
            
            
            
            BOOL authenticated = [cmisSession authenticateAndReturnError:&error];
            if (authenticated == YES)
            {
//                self.personIdentifier = emailAddress;
                AlfrescoObjectConverter *objectConverter = [[AlfrescoObjectConverter alloc] initWithSession:self];
                self.repositoryInfo = [objectConverter repositoryInfoFromCMISSession:cmisSession];
                //                session = self;
                
                CMISObject *retrievedObject = [cmisSession retrieveRootFolderAndReturnError:&error];
                log(@"*** authenticateWithOAuthData after retrieving root folder");
                if (nil != retrievedObject) {
                    if ([retrievedObject isKindOfClass:[CMISFolder class]])
                    {
                        log(@"*** authenticateWithOAuthData found root folder");
                        self.rootFolder = (AlfrescoFolder *)[objectConverter nodeFromCMISObject:retrievedObject];
                    }
                    else
                    {
                        
                        log(@"*** authenticateWithOAuthData root folder appears not be a folder at all");
                    }
                }
                else
                {
                    log(@"*** authenticateWithOAuthData error returning root folder %@ with code %d", [error localizedDescription], [error code]);
                    
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



/**
This authentication method authorises the user to access the home network assigned to the account. It first searches the available networks for the user
 (using retrieveNetworksWithCompletionBlock) and from within that block proceeds to full authentication for a specific network.
 */
- (void)authenticateWithEmailAddress:(NSString *)emailAddress
                            password:(NSString *)password
                              apiKey:(NSString *)apiKey
                     completionBlock:(AlfrescoSessionCompletionBlock)completionBlock
{
    self.isUsingBaseAuthenticationProvider = YES;
    self.baseUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kAlfrescoTestCloudURL,kAlfrescoCloudPrecursor]];
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
                                                apiKey:apiKey
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
                              apiKey:(NSString *)key
                             network:(NSString *)network
                     completionBlock:(AlfrescoSessionCompletionBlock)completionBlock
{
    self.isUsingBaseAuthenticationProvider = YES;
    self.baseUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@",kAlfrescoTestCloudURL,kAlfrescoCloudPrecursor,network]];
    NSString *cmisUrl = [[self.baseUrl absoluteString] stringByAppendingString:kAlfrescoCloudCMISPath];
    self.cmisUrl = [NSURL URLWithString:cmisUrl];
    self.dateFormatter = [[AlfrescoISO8601DateFormatter alloc] init];

    CMISSessionParameters *params = [[CMISSessionParameters alloc] initWithBindingType:CMISBindingTypeAtomPub];
    params.username = emailAddress;
    params.password = password;
    params.atomPubUrl = self.cmisUrl;
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
//            AlfrescoCloudSession *session = nil;
            CMISRepositoryInfo *repoInfo = [repositories objectAtIndex:0];
            
            params.repositoryId = repoInfo.identifier;
            
            // enable Alfresco mode in CMIS Session
            [params setObject:kCMISAlfrescoMode forKey:kCMISSessionParameterMode];
            
            // create the session using the paramters
            CMISSession *cmisSession = [[CMISSession alloc] initWithSessionParameters:params];
            [self.sessionData setObject:cmisSession forKey:kAlfrescoSessionKeyCmisSession];
            
            id<AlfrescoAuthenticationProvider> authProvider = [self authProviderToBeUsed];
//            objc_setAssociatedObject(self, &kAlfrescoAuthenticationProviderObjectKey, authProvider, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [self setObject:authProvider forParameter:kAlfrescoAuthenticationProviderObjectKey];
            
            BOOL authenticated = [cmisSession authenticateAndReturnError:&error];
            if (authenticated == YES)
            {
                self.personIdentifier = emailAddress;
                AlfrescoObjectConverter *objectConverter = [[AlfrescoObjectConverter alloc] initWithSession:self];
                self.repositoryInfo = [objectConverter repositoryInfoFromCMISSession:cmisSession];
//                session = self;
                
                CMISObject *retrievedObject = [cmisSession retrieveRootFolderAndReturnError:&error];
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
        
        // setup defaults
        [self setObject:[NSNumber numberWithBool:NO] forParameter:kAlfrescoMetadataExtraction];
        [self setObject:[NSNumber numberWithBool:NO] forParameter:kAlfrescoThumbnailCreation];
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

#pragma delegate method implementation
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


@end
