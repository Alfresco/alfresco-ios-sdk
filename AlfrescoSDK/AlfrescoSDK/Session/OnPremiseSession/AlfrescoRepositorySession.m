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
#import <objc/runtime.h>

static NSString * const kAlfrescoCMISPath = @"/service/cmis";

@interface AlfrescoRepositorySession ()
- (id)initWithUrl:(NSURL *)url parameters:(NSDictionary *)parameters;
- (void)authenticateWithUsername:(NSString *)username
                     andPassword:(NSString *)password
                 completionBlock:(AlfrescoSessionCompletionBlock)completionBlock;

@property (nonatomic, strong, readwrite) NSURL *baseUrl;
@property (nonatomic, strong) NSURL *cmisUrl;
@property (nonatomic, strong, readwrite) NSMutableDictionary *sessionData;
@property (nonatomic, strong, readwrite) NSString *personIdentifier;

@property (nonatomic, strong, readwrite) AlfrescoRepositoryInfo *repositoryInfo;
@property (nonatomic, strong, readwrite) AlfrescoFolder *rootFolder;
@property (nonatomic, strong, readwrite) AlfrescoListingContext *defaultListingContext;
@end

@implementation AlfrescoRepositorySession

@synthesize personIdentifier = _personIdentifier;
@synthesize repositoryInfo = _repositoryInfo;
@synthesize baseUrl = _baseUrl;
@synthesize cmisUrl = _cmisUrl;
@synthesize sessionData = _sessionData;
@synthesize rootFolder = _rootFolder;
@synthesize defaultListingContext = _defaultListingContext;

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

- (void)disconnect
{
    CMISSession *cmisSession = [self.sessionData objectForKey:kAlfrescoSessionKeyCmisSession];
    [cmisSession.binding clearAllCaches];
    
}

/**
 OnPremise services have a dedicated thumbnail rendition API, which we need to enable here.
 */

- (id)initWithUrl:(NSURL *)url parameters:(NSDictionary *)parameters
{
    if (self = [super init])
    {
        self.baseUrl = url;
        self.sessionData = [NSMutableDictionary dictionaryWithCapacity:1];
        if (nil != parameters)
        {
            [self addParametersFromDictionary:parameters];
        }
        
        // setup defaults
        [self setObject:[NSNumber numberWithBool:YES] forParameter:kAlfrescoThumbnailRenditionFromAPI];
        self.defaultListingContext = [[AlfrescoListingContext alloc] init];
        
        // generate the CMIS URL
        NSString *cmisUrl = [[self.baseUrl absoluteString] stringByAppendingString:kAlfrescoCMISPath];
        self.cmisUrl = [NSURL URLWithString:cmisUrl];
    }
    
    return self;
}

- (void)authenticateWithUsername:(NSString *)username
                     andPassword:(NSString *)password
                 completionBlock:(AlfrescoSessionCompletionBlock)completionBlock
{
    CMISSessionParameters *params = [[CMISSessionParameters alloc] initWithBindingType:CMISBindingTypeAtomPub];
    params.username = username;
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
            CMISRepositoryInfo *repoInfo = [repositories objectAtIndex:0];
            
            params.repositoryId = repoInfo.identifier;
            
            // enable Alfresco mode in CMIS Session
            [params setObject:kCMISAlfrescoMode forKey:kCMISSessionParameterMode];
            
            // create the session using the paramters
            CMISSession *cmisSession = [[CMISSession alloc] initWithSessionParameters:params];
            [self.sessionData setObject:cmisSession forKey:kAlfrescoSessionKeyCmisSession];
            
            id<AlfrescoAuthenticationProvider> authProvider = [[AlfrescoBasicAuthenticationProvider alloc] initWithUsername:username andPassword:password];
            objc_setAssociatedObject(self, &kAlfrescoAuthenticationProviderObjectKey, authProvider, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            
            BOOL authenticated = [cmisSession authenticateAndReturnError:&error];
            if (authenticated == YES)
            {
                self.personIdentifier = username;
                AlfrescoObjectConverter *objectConverter = [[AlfrescoObjectConverter alloc] initWithSession:self];
                self.repositoryInfo = [objectConverter repositoryInfoFromCMISSession:cmisSession];
                
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
