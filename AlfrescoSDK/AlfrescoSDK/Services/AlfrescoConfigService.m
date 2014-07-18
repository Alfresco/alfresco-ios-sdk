/*
 ******************************************************************************
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
 *****************************************************************************
 */

#import "AlfrescoConfigService.h"
#import "AlfrescoErrors.h"
#import "AlfrescoPropertyConstants.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoProfileConfig.h"

NSString * const kAlfrescoConfigServiceParameterApplicationId = @"org.alfresco.mobile.config.application.id";
NSString * const kAlfrescoConfigServiceParameterProfileId = @"org.alfresco.mobile.config.profile.id";
NSString * const kAlfrescoConfigServiceParameterLocalFile = @"org.alfresco.mobile.config.local.file";

@interface AlfrescoConfigService ()
@property (nonatomic, strong) id<AlfrescoSession> session;
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, assign) BOOL isCacheBuilt;
@property (nonatomic, assign) BOOL isCacheBuilding;
@property (nonatomic, strong) NSString *applicationId;
@property (nonatomic, strong) NSURL *localFileURL;

// cached configuration
@property (nonatomic, strong) AlfrescoConfigInfo *configInfo;
@property (nonatomic, strong) AlfrescoRepositoryConfig *repository;
@property (nonatomic, strong) AlfrescoProfileConfig *defaultProfile;
@property (nonatomic, strong) NSDictionary *profiles;
@property (nonatomic, strong) NSArray *features;
@end

@implementation AlfrescoConfigService

#pragma mark - Initialization methods

- (instancetype)initWithSession:(id<AlfrescoSession>)session
{
    // we can't do much without a session so just return nil
    if (session == nil)
    {
        return nil;
    }
    
    self = [super init];
    if (nil != self)
    {
        self.session = session;
        self.isCacheBuilt = NO;
        self.isCacheBuilding = NO;
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)parameters
{
    self = [super init];
    if (nil != self)
    {
        self.parameters = parameters;
        self.isCacheBuilt = NO;
        self.isCacheBuilding = NO;
    }
    
    return self;
}

- (void)clear
{
    self.isCacheBuilt = NO;
}

- (AlfrescoRequest *)initializeInternalStateWithCompletionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    if (!self.isCacheBuilding)
    {
        self.isCacheBuilding = YES;
        
        if (self.session != nil)
        {
            // pull parameters from session
            self.applicationId = [self.session objectForParameter:kAlfrescoConfigServiceParameterApplicationId];
            
            // TODO: use the document folder service to retrieve the content from DD.
            return nil;
        }
        else
        {
            // pull parameters from dictionary
            self.applicationId = self.parameters[kAlfrescoConfigServiceParameterApplicationId];
            NSURL *localFile = self.parameters[kAlfrescoConfigServiceParameterLocalFile];
            
            // process the JSON data from the local file
            [self processJSONData:[NSData dataWithContentsOfFile:localFile.path]
                  completionBlock:completionBlock];
            
            return nil;
        }
    }
    else
    {
        // TODO: handle concurrent requestss, for now fail so we explicitly highlight concurrency issues
        completionBlock(NO, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeConfigInitializationFailed
                                                                        reason:@"Request to initialize config whilst cache is being built"]);
        return nil;
    }
}

- (void)processJSONData:(NSData *)data completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    if (data != nil)
    {
        // parse the JSON
        NSError *error = nil;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (jsonDictionary != nil)
        {
            // build internal state
            [self parseConfigInfo:jsonDictionary];
            [self parseRepository:jsonDictionary];
            [self parseProfiles:jsonDictionary];
            [self parseFeatures:jsonDictionary];
            
            // set status flags and call completion block
            self.isCacheBuilt = YES;
            self.isCacheBuilding = NO;
            completionBlock(YES, nil);
        }
        else
        {
            self.isCacheBuilding = NO;
            completionBlock(NO, [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing]);
        }
    }
    else
    {
        self.isCacheBuilding = NO;
        completionBlock(NO, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData]);
    }
}

- (void)parseConfigInfo:(NSDictionary *)json
{
    NSDictionary *configInfoJSON = json[kAlfrescoJSONInfo];
    NSDictionary *configInfoProperties = @{kAlfrescoConfigInfoPropertySchemaVersion: configInfoJSON[kAlfrescoJSONSchemaVersion],
                                           kAlfrescoConfigInfoPropertyConfigVersion: configInfoJSON[kAlfrescoJSONConfigVersion]};
    
    self.configInfo = [[AlfrescoConfigInfo alloc] initWithDictionary:configInfoProperties];
}

- (void)parseRepository:(NSDictionary *)json
{
    NSDictionary *repositoryJSON = json[kAlfrescoJSONRepository];
    NSDictionary *repositoryProperties = @{kAlfrescoRepositoryConfigPropertyShareURL: repositoryJSON[kAlfrescoJSONShareURL],
                                           kAlfrescoRepositoryConfigPropertyCMISURL: repositoryJSON[kAlfrescoJSONCMISURL]};
    
    self.repository = [[AlfrescoRepositoryConfig alloc] initWithDictionary:repositoryProperties];
}

- (void)parseProfiles:(NSDictionary *)json
{
    NSDictionary *profilesJSON = json[kAlfrescoJSONProfiles];
    
    NSMutableDictionary *profilesDictionary = [NSMutableDictionary dictionary];
    
    NSArray *profileIds = [profilesJSON allKeys];
    for (NSString *profileId in profileIds)
    {
        NSDictionary *profileJSON = profilesJSON[profileId];
        
        NSMutableDictionary *profileProperties = [NSMutableDictionary dictionaryWithObject:profileId
                                                                                    forKey:kAlfrescoProfileConfigPropertyIdentifier];
  
        if (profileJSON[kAlfrescoJSONLabelId] != nil)
        {
            profileProperties[kAlfrescoProfileConfigPropertyLabel] = profileJSON[kAlfrescoJSONLabelId];
        }
        
        if (profileJSON[kAlfrescoJSONDescriptionId] != nil)
        {
            profileProperties[kAlfrescoProfileConfigPropertySummary] = profileJSON[kAlfrescoJSONDescriptionId];
        }
        
        if (profileJSON[kAlfrescoJSONRootViewId] != nil)
        {
            profileProperties[kAlfrescoProfileConfigPropertyRootViewId] = profileJSON[kAlfrescoJSONRootViewId];
        }
  
        if (profileJSON[kAlfrescoJSONDefault] != nil)
        {
            profileProperties[kAlfrescoProfileConfigPropertyIsDefault] = profileJSON[kAlfrescoJSONDefault];
        }
        
        // create and store the profile object
        AlfrescoProfileConfig *profile = [[AlfrescoProfileConfig alloc] initWithDictionary:profileProperties];
        profilesDictionary[profile.identifier] = profile;
        
        // set as the default profile, if appropriate
        if (profile.isDefault)
        {
            self.defaultProfile = profile;
        }
    }
    
    self.profiles = profilesDictionary;
}

- (void)parseFeatures:(NSDictionary *)json
{
    NSArray *featuresJSON = json[kAlfrescoJSONFeatures];
    
    NSMutableArray *featuresArray = [NSMutableArray array];
    
    for (NSDictionary *featureJSON in featuresJSON)
    {
        NSMutableDictionary *featureProperties = [NSMutableDictionary dictionary];
        
        if (featureJSON[kAlfrescoJSONIdentifier] != nil)
        {
            featureProperties[kAlfrescoFeatureConfigPropertyIdentifier] = featureJSON[kAlfrescoJSONIdentifier];
        }
        
        if (featureJSON[kAlfrescoJSONLabelId] != nil)
        {
            featureProperties[kAlfrescoFeatureConfigPropertyLabel] = featureJSON[kAlfrescoJSONLabelId];
        }
        
        if (featureJSON[kAlfrescoJSONDescriptionId] != nil)
        {
            featureProperties[kAlfrescoFeatureConfigPropertySummary] = featureJSON[kAlfrescoJSONDescriptionId];
        }
        
        // create and store the feature object
        AlfrescoFeatureConfig *feature = [[AlfrescoFeatureConfig alloc] initWithDictionary:featureProperties];
        [featuresArray addObject:feature];
    }
    
    self.features = featuresArray;
}

#pragma mark - Retrieval methods

- (AlfrescoRequest *)retrieveConfigInfoWithCompletionBlock:(AlfrescoConfigInfoCompletionBlock)completionBlock
{
    return [self initializeInternalStateWithCompletionBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            completionBlock(self.configInfo, nil);
        }
        else
        {
            completionBlock(nil, error);
        }
    }];
}

- (AlfrescoRequest *)retrieveDefaultProfileWithCompletionBlock:(AlfrescoProfileConfigCompletionBlock)completionBlock
{
    return [self initializeInternalStateWithCompletionBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            completionBlock(self.defaultProfile, nil);
        }
        else
        {
            completionBlock(nil, error);
        }
    }];
}

- (AlfrescoRequest *)retrieveProfileWithIdentifier:(NSString *)identifier
                                   completionBlock:(AlfrescoProfileConfigCompletionBlock)completionBlock
{
    return [self initializeInternalStateWithCompletionBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            AlfrescoProfileConfig *profile = self.profiles[identifier];
            if (profile != nil)
            {
                completionBlock(profile, nil);
            }
            else
            {
                completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeConfigNotFound]);
            }
        }
        else
        {
            completionBlock(nil, error);
        }
    }];
}


- (AlfrescoRequest *)retrieveProfilesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    return [self initializeInternalStateWithCompletionBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            completionBlock([self.profiles allValues], nil);
        }
        else
        {
            completionBlock(nil, error);
        }
    }];
}


- (AlfrescoRequest *)retrieveRepositoryConfigWithCompletionBlock:(AlfrescoRepositoryConfigCompletionBlock)completionBlock
{
    return [self initializeInternalStateWithCompletionBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            completionBlock(self.repository, nil);
        }
        else
        {
            completionBlock(nil, error);
        }
    }];
}


- (AlfrescoRequest *)retrieveFeatureConfigWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    return [self initializeInternalStateWithCompletionBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            completionBlock(self.features, nil);
        }
        else
        {
            completionBlock(nil, error);
        }
    }];
}


- (AlfrescoRequest *)retrieveFeatureConfigWithConfigScope:(AlfrescoConfigScope *)scope
                                          completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeConfig reason:@"Method Not Implemented"]);
    return nil;
}


- (AlfrescoRequest *)retrieveFeatureConfigWithIdentifier:(NSString *)identifier
                                         completionBlock:(AlfrescoFeatureConfigCompletionBlock)completionBlock
{
    return [self initializeInternalStateWithCompletionBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            AlfrescoFeatureConfig *requestedFeatureConfig = nil;
            for (AlfrescoFeatureConfig *featureConfig in self.features)
            {
                if ([featureConfig.identifier isEqualToString:identifier])
                {
                    requestedFeatureConfig = featureConfig;
                    break;
                }
            }
            
            if (requestedFeatureConfig != nil)
            {
                completionBlock(requestedFeatureConfig, nil);
            }
            else
            {
                completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeConfigNotFound]);
            }
        }
        else
        {
            completionBlock(nil, error);
        }
    }];
}


- (AlfrescoRequest *)retrieveFeatureConfigWithIdentifier:(NSString *)identifier
                                                   scope:(AlfrescoConfigScope *)scope
                                         completionBlock:(AlfrescoFeatureConfigCompletionBlock)completionBlock
{
    completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeConfig reason:@"Method Not Implemented"]);
    return nil;
}


- (AlfrescoRequest *)retrieveViewGroupConfigWithIdentifier:(NSString *)identifier
                                           completionBlock:(AlfrescoViewGroupConfigCompletionBlock)completionBlock
{
    completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeConfig reason:@"Method Not Implemented"]);
    return nil;
}


- (AlfrescoRequest *)retrieveViewGroupConfigWithIdentifier:(NSString *)identifier
                                                     scope:(AlfrescoConfigScope *)scope
                                           completionBlock:(AlfrescoViewGroupConfigCompletionBlock)completionBlock
{
    completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeConfig reason:@"Method Not Implemented"]);
    return nil;
}


- (AlfrescoRequest *)retrieveActionGroupConfigWithIdentifier:(NSString *)identifier
                                             completionBlock:(AlfrescoActionGroupConfigCompletionBlock)completionBlock
{
    completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeConfig reason:@"Method Not Implemented"]);
    return nil;
}


- (AlfrescoRequest *)retrieveActionGroupConfigWithIdentifier:(NSString *)identifier
                                                       scope:(AlfrescoConfigScope *)scope
                                             completionBlock:(AlfrescoActionGroupConfigCompletionBlock)completionBlock
{
    completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeConfig reason:@"Method Not Implemented"]);
    return nil;
}


- (AlfrescoRequest *)retrieveFormConfigWithIdentifier:(NSString *)identifier
                                      completionBlock:(AlfrescoFormConfigCompletionBlock)completionBlock
{
    completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeConfig reason:@"Method Not Implemented"]);
    return nil;
}


- (AlfrescoRequest *)retrieveFormConfigWithIdentifier:(NSString *)identifier
                                                scope:(AlfrescoConfigScope *)scope
                                      completionBlock:(AlfrescoFormConfigCompletionBlock)completionBlock
{
    completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeConfig reason:@"Method Not Implemented"]);
    return nil;
}


- (AlfrescoRequest *)retrieveWorkflowConfigWithCompletionBlock:(AlfrescoWorkflowConfigCompletionBlock)completionBlock
{
    completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeConfig reason:@"Method Not Implemented"]);
    return nil;
}


- (AlfrescoRequest *)retrieveWorkflowConfigWithConfigScope:(AlfrescoConfigScope *)scope
                                           completionBlock:(AlfrescoWorkflowConfigCompletionBlock)completionBlock
{
    completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeConfig reason:@"Method Not Implemented"]);
    return nil;
}


- (AlfrescoRequest *)retrieveCreationConfigWithCompletionBlock:(AlfrescoCreationConfigCompletionBlock)completionBlock
{
    completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeConfig reason:@"Method Not Implemented"]);
    return nil;
}


- (AlfrescoRequest *)retrieveCreationConfigWithConfigScope:(AlfrescoConfigScope *)scope
                                           completionBlock:(AlfrescoCreationConfigCompletionBlock)completionBlock
{
    completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeConfig reason:@"Method Not Implemented"]);
    return nil;
}


- (AlfrescoRequest *)retrieveSearchConfigWithCompletionBlock:(AlfrescoSearchConfigCompletionBlock)completionBlock
{
    completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeConfig reason:@"Method Not Implemented"]);
    return nil;
}


- (AlfrescoRequest *)retrieveSearchConfigWithConfigScope:(AlfrescoConfigScope *)scope
                                         completionBlock:(AlfrescoSearchConfigCompletionBlock)completionBlock
{
    completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeConfig reason:@"Method Not Implemented"]);
    return nil;
}


- (AlfrescoRequest *)retrieveThemeConfigWithCompletionBlock:(AlfrescoSearchConfigCompletionBlock)completionBlock
{
    completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeConfig reason:@"Method Not Implemented"]);
    return nil;
}


- (AlfrescoRequest *)retrieveThemeConfigWithConfigScope:(AlfrescoConfigScope *)scope
                                        completionBlock:(AlfrescoThemeConfigCompletionBlock)completionBlock
{
    completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeConfig reason:@"Method Not Implemented"]);
    return nil;
}

@end
