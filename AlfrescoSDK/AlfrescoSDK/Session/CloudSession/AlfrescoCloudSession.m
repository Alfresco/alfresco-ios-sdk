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

- (NSArray *) parseNetworkArrayWithData:(NSData *)data error:(NSError **)outError;

- (AlfrescoCloudNetwork *)networkFromJSON:(NSDictionary *)networkDictionary;

@property (nonatomic, strong, readwrite) NSURL *baseUrl;
@property (nonatomic, strong) NSURL *cmisUrl;
@property (nonatomic, strong, readwrite) NSMutableDictionary *sessionData;
@property (nonatomic, strong, readwrite) NSString *personIdentifier;
@property (nonatomic, strong, readwrite) AlfrescoRepositoryInfo *repositoryInfo;
@property (nonatomic, strong, readwrite) AlfrescoFolder *rootFolder;
@property (nonatomic, strong, readwrite) NSString *emailAddress;
@property (nonatomic, strong, readwrite) NSString *password;
@property (nonatomic, strong)           AlfrescoISO8601DateFormatter *dateFormatter;
@property (nonatomic, strong, readwrite) AlfrescoCloudNetwork *network;
@property (nonatomic, strong, readwrite) AlfrescoListingContext *defaultListingContext;
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
@synthesize network = _network;
@synthesize defaultListingContext = _defaultListingContext;

#pragma public methods

+ (void)signupWithEmailAddress:(NSString *)emailAddress
                     firstName:(NSString *)firstName
                      lastName:(NSString *)lastName
                      password:(NSString *)password
                        apiKey:(NSString *)apiKey
               completionBlock:(AlfrescoCloudSignupRequestCompletionBlock)completionBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",kAlfrescoTestCloudURL, kAlfrescoCloudBindingService, kAlfrescoCloudSignupURL]];
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue addOperationWithBlock:^(){
        NSError *operationQueueError = nil;
        
        NSMutableDictionary *jsonInputDict = [NSMutableDictionary dictionary];
        [jsonInputDict setValue:emailAddress forKey:kAlfrescoJSONEmail];
        [jsonInputDict setValue:firstName forKey:kAlfrescoJSONSignupFirstName];
        [jsonInputDict setValue:lastName forKey:kAlfrescoJSONSignupLastName];
        [jsonInputDict setValue:password forKey:kAlfrescoJSONPassword];
        [jsonInputDict setValue:kAlfrescoJSONIOSSource forKey:kAlfrescoJSONSource];
        
        NSData *jsonInputData = [NSJSONSerialization dataWithJSONObject:jsonInputDict options:kNilOptions error:&operationQueueError];
        if (nil == jsonInputData)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
                completionBlock(nil, operationQueueError);
            }];
        }
        else
        {
            NSData *jsonOutputData = [AlfrescoHTTPUtils executeRequestWithURL:url data:jsonInputData httpMethod:@"POST" error:&operationQueueError];
            if (nil == jsonOutputData)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
                    completionBlock(nil, operationQueueError);
                }];
            }
            else
            {
                AlfrescoCloudSignupRequest *signupRequest = nil;
                id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonOutputData options:kNilOptions error:&operationQueueError];
                if (nil != jsonObject)
                {
                    if ([jsonObject isKindOfClass:[NSDictionary class]])
                    {
                        id registrationObject = [jsonObject valueForKey:kAlfrescoJSONRegistration];
                        if ([registrationObject isKindOfClass:[NSDictionary class]])
                        {
                            signupRequest = [[AlfrescoCloudSignupRequest alloc] init];
                            signupRequest.apiKey = [registrationObject valueForKey:kAlfrescoJSONAPIKey];
                            signupRequest.identifier = [registrationObject valueForKey:kAlfrescoJSONIdentifier];
                            signupRequest.emailAddress = [registrationObject valueForKey:kAlfrescoJSONEmail];
                            NSString *dateString = [registrationObject valueForKey:kAlfrescoJSONRegistrationTime];
                            AlfrescoISO8601DateFormatter *dateFormatter = [[AlfrescoISO8601DateFormatter alloc] init];
                            signupRequest.registeredAt = [dateFormatter dateFromString:dateString];
                        }
                        else
                        {
                            operationQueueError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeUnknown withDetailedDescription:@"Incorrect JSON data returned from server. Expected registration Object to be of type NSDictionary"];
                        }
                    }
                    else
                    {
                        operationQueueError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeUnknown withDetailedDescription:@"Incorrect JSON data returned from server. Expected top level Object to be of type NSDictionary"];                        
                    }
                }
                [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
                    completionBlock(signupRequest, operationQueueError);
                }];
                
            }
        
        }
        
    }];
}

+ (void)isAccountVerifiedForSignupRequest:(AlfrescoCloudSignupRequest *)signupRequest
                          completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@/%@?key=%@",kAlfrescoTestCloudURL, kAlfrescoCloudBindingService, kAlfrescoCloudSignupURL, signupRequest.identifier, signupRequest.apiKey];
    NSURL *url = [NSURL URLWithString:urlString];
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue addOperationWithBlock:^() {
        NSError *operationQueueError = nil;
        NSData *jsonOutputData = [AlfrescoHTTPUtils executeRequestWithURL:url data:nil httpMethod:@"GET" error:&operationQueueError];
        id jsonDict = [NSJSONSerialization JSONObjectWithData:jsonOutputData options:kNilOptions error:&operationQueueError];
        BOOL success = NO;
        if (nil != jsonDict)
        {
            if ([jsonDict isKindOfClass:[NSDictionary class]])
            {
                NSNumber *isRegisteredValue = [jsonDict valueForKey:kAlfrescoJSONIsRegistered];
                success = [isRegisteredValue boolValue];
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
            completionBlock(success, operationQueueError);
        }];
    }];
}

+ (void)connectWithEmailAddress:(NSString *)emailAddress
                       password:(NSString *)password
                         apiKey:(NSString *)apiKey
                     parameters:(NSDictionary *)parameters
                completionBlock:(AlfrescoSessionCompletionBlock)completionBlock
{
    AlfrescoCloudSession *sessionInstance = [[AlfrescoCloudSession alloc] initWithParameters:parameters];
    if (sessionInstance)
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
    if (sessionInstance)
    {
        [sessionInstance authenticateWithEmailAddress:emailAddress password:password apiKey:apiKey network:networkIdentifer completionBlock:completionBlock];
    }
    
}

- (void)retrieveNetworksWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    __weak AlfrescoCloudSession *weakSelf = self;
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue addOperationWithBlock:^(){
        NSError *operationQueueError = nil;
        id<AlfrescoAuthenticationProvider> authProvider = [[AlfrescoBasicAuthenticationProvider alloc] initWithUsername:weakSelf.emailAddress andPassword:weakSelf.password];
        objc_setAssociatedObject(self, &kAlfrescoAuthenticationProviderObjectKey, authProvider, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        NSData *jsonData = [AlfrescoHTTPUtils executeRequestWithURL:self.baseUrl
                                             authenticationProvider:authProvider
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
        NSArray *networks = [weakSelf parseNetworkArrayWithData:jsonData error:&operationQueueError];
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
/**
This authentication method authorises the user to access the home network assigned to the account. It first searches the available networks for the user
 (using retrieveNetworksWithCompletionBlock) and from within that block proceeds to full authentication for a specific network.
 */
- (void)authenticateWithEmailAddress:(NSString *)emailAddress
                            password:(NSString *)password
                              apiKey:(NSString *)apiKey
                     completionBlock:(AlfrescoSessionCompletionBlock)completionBlock
{
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
                self.network = homeNetwork;
                [weakSelf authenticateWithEmailAddress:weakSelf.emailAddress
                                              password:weakSelf.password
                                                apiKey:apiKey
                                               network:weakSelf.network.identifier
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
            error = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeNoRepositoryFound withDetailedDescription:nil];
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
            AlfrescoCloudSession *session = nil;
            CMISRepositoryInfo *repoInfo = [repositories objectAtIndex:0];
            
            params.repositoryId = repoInfo.identifier;
            
            // enable Alfresco mode in CMIS Session
            [params setObject:kCMISAlfrescoMode forKey:kCMISSessionParameterMode];
            
            // create the session using the paramters
            CMISSession *cmisSession = [[CMISSession alloc] initWithSessionParameters:params];
            [self.sessionData setObject:cmisSession forKey:kAlfrescoSessionKeyCmisSession];
            
            id<AlfrescoAuthenticationProvider> authProvider = [[AlfrescoBasicAuthenticationProvider alloc] initWithUsername:emailAddress andPassword:password];
            objc_setAssociatedObject(self, &kAlfrescoAuthenticationProviderObjectKey, authProvider, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            
            BOOL authenticated = [cmisSession authenticateAndReturnError:&error];
            if (authenticated == YES)
            {
                self.personIdentifier = emailAddress;
                AlfrescoObjectConverter *objectConverter = [[AlfrescoObjectConverter alloc] initWithSession:self];
                self.repositoryInfo = [objectConverter repositoryInfoFromCMISSession:cmisSession];
                session = self;
                
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
        self.sessionData = [NSMutableDictionary dictionaryWithCapacity:1];
        if (nil != parameters)
        {
            [self addParametersFromDictionary:parameters];
        }
        
        // setup defaults
        [self setObject:[NSNumber numberWithBool:NO] forParameter:kAlfrescoMetadataExtraction];
        [self setObject:[NSNumber numberWithBool:NO] forParameter:kAlfrescoThumbnailCreation];
        [self setObject:[NSNumber numberWithBool:NO] forParameter:kAlfrescoThumbnailRenditionFromAPI];
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
    
    id networkObj = [networkDictionary valueForKey:kAlfrescoJSONNetwork];
    if ([networkObj isKindOfClass:[NSDictionary class]])
    {
        id creationTimeObject = [networkObj valueForKey:kAlfrescoJSONCreationTime];
        if ([creationTimeObject isKindOfClass:[NSString class]])
        {
            NSString *dateString = (NSString *)creationTimeObject;
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
- (NSArray *) parseNetworkArrayWithData:(NSData *)data error:(NSError **)outError
{
    if (nil == data)
    {
        *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeNetwork withDetailedDescription:@"Parse JSON shouldn't be nil"];
        return nil;
    }
    NSError *error = nil;
    id jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (nil == jsonDictionary)
    {
        *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeNetwork];
        return nil;
    }
    
    if (![jsonDictionary isKindOfClass:[NSDictionary class]])
    {
        *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeNetwork];
        return nil;
    }
    
    id listObject = [jsonDictionary valueForKey:kAlfrescoCloudJSONList];
    if (![listObject isKindOfClass:[NSDictionary class]])
    {
        *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeNetwork];
        return nil;
    }
    id entries = [listObject valueForKey:kAlfrescoCloudJSONEntries];
    if (![entries isKindOfClass:[NSArray class]])
    {
        *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeNetwork];
        return nil;
    }
    NSArray *entriesArray = [NSArray arrayWithArray:entries];
    if (0 == entriesArray.count)
    {
        *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeNetwork];
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
