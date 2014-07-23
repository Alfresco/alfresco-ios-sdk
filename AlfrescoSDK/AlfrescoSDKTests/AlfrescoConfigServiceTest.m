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

#import "AlfrescoConfigServiceTest.h"
#import "AlfrescoErrors.h"
#import "AlfrescoViewConfig.h"
#import "AlfrescoFieldConfig.h"

@implementation AlfrescoConfigServiceTest

- (NSURL *)urlForLocalConfigFile
{
    NSString *configFilePath = [[NSBundle bundleForClass:self.class] pathForResource:@"config.json" ofType:nil];
    return [NSURL URLWithString:configFilePath];
}

- (NSDictionary *)dictionaryForConfigService
{
    NSDictionary *parameters = @{kAlfrescoConfigServiceParameterApplicationId: @"com.alfresco.mobile.ios",
                                 kAlfrescoConfigServiceParameterLocalFile: [self urlForLocalConfigFile]};
    
    return parameters;
}

- (id<AlfrescoSession>)sessionForConfigService
{
    // TODO: decorate the current session with the parameters required for a config service
    
    return self.currentSession;
}

- (void)testSetupFromDictionary
{
    if (self.setUpSuccess)
    {
        self.configService = [[AlfrescoConfigService alloc] initWithDictionary:[self dictionaryForConfigService]];
        
        // retrieve basic config information
        [self.configService retrieveConfigInfoWithCompletionBlock:^(AlfrescoConfigInfo *configInfo, NSError *error) {
            if (configInfo == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [self failureMessageFromError:error];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertTrue([configInfo.schemaVersion isEqualToString:@"0.1"],
                              @"Expected schema version to be 0.1 but it was %@", configInfo.schemaVersion);
                XCTAssertTrue([configInfo.configVersion isEqualToString:@"0.1"],
                              @"Expected config version to be 0.1 but it was %@", configInfo.configVersion);
                
                self.lastTestSuccessful = YES;
                self.callbackCompleted = YES;
            }
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)disabledTestSetupFromSession
{
    if (self.setUpSuccess)
    {
        self.configService = [[AlfrescoConfigService alloc] initWithSession:[self sessionForConfigService]];
        
        // TODO: upload the test JSON file to the Data Dictionary folder (clear out old one first if present)
        
        // retrieve basic config information
        [self.configService retrieveConfigInfoWithCompletionBlock:^(AlfrescoConfigInfo *configInfo, NSError *error) {
            if (configInfo == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [self failureMessageFromError:error];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertTrue([configInfo.schemaVersion isEqualToString:@"0.1"],
                              @"Expected schema version to be 0.1 but it was %@", configInfo.schemaVersion);
                XCTAssertTrue([configInfo.configVersion isEqualToString:@"0.1"],
                              @"Expected config version to be 0.1 but it was %@", configInfo.configVersion);
                
                self.lastTestSuccessful = YES;
                self.callbackCompleted = YES;
            }
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRepositoryConfig
{
    if (self.setUpSuccess)
    {
        self.configService = [[AlfrescoConfigService alloc] initWithDictionary:[self dictionaryForConfigService]];
        
        // retrieve the repository config
        [self.configService retrieveRepositoryConfigWithCompletionBlock:^(AlfrescoRepositoryConfig *repoConfig, NSError *error) {
            if (repoConfig == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [self failureMessageFromError:error];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertTrue([[repoConfig.shareURL absoluteString] isEqualToString:@"http://ec2-176-34-173-67.eu-west-1.compute.amazonaws.com/share"] , @"Expected shareURL to be http://ec2-176-34-173-67.eu-west-1.compute.amazonaws.com/share but was %@", repoConfig.shareURL);
                
                XCTAssertTrue([[repoConfig.cmisURL absoluteString] isEqualToString:@"http://ec2-176-34-173-67.eu-west-1.compute.amazonaws.com/alfresco/cmisatom"] , @"Expected cmisURL to be http://ec2-176-34-173-67.eu-west-1.compute.amazonaws.com/alfresco/cmisatom but was %@", repoConfig.cmisURL);
                
                self.lastTestSuccessful = YES;
                self.callbackCompleted = YES;
            }
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testProfiles
{
    if (self.setUpSuccess)
    {
        self.configService = [[AlfrescoConfigService alloc] initWithDictionary:[self dictionaryForConfigService]];
        
        // start by retrieving all profiles in the config file
        [self.configService retrieveProfilesWithCompletionBlock:^(NSArray *allProfiles, NSError *allProfilesError) {
            if (allProfiles == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [self failureMessageFromError:allProfilesError];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertTrue(allProfiles.count > 0, @"Expected there to be at least one profile");
                
                // try and find the profiles we're expecting
                AlfrescoProfileConfig *defaultProfile = nil;
                AlfrescoProfileConfig *customProfile = nil;
                for (AlfrescoProfileConfig *profile in allProfiles)
                {
                    if ([profile.identifier isEqualToString:@"default"])
                    {
                        defaultProfile = profile;
                    }
                    else if ([profile.identifier isEqualToString:@"custom"])
                    {
                        customProfile = profile;
                    }
                }
                
                // make sure the 2 profiles we're expecting are present
                XCTAssertNotNil(defaultProfile, @"Expected to find a profile named default");
                XCTAssertNotNil(customProfile, @"Expected to find a profile named custom");
                
                // check the profiles have the correct properties
                XCTAssertTrue(defaultProfile.isDefault, @"Expected the default profile to be marked as default");
                XCTAssertTrue([defaultProfile.label isEqualToString:@"Default Profile"],
                              @"Expected default profile label to be 'Default Profile' but was %@", defaultProfile.label);
                XCTAssertTrue([defaultProfile.summary isEqualToString:@"Description of the Default Profile"],
                              @"Expected default profile summary to be 'Description of the Default Profile' but was %@", defaultProfile.summary);
                XCTAssertTrue([defaultProfile.rootViewId isEqualToString:@"rootNavigationMenu"],
                              @"Expected default profile rootViewId to be 'rootNavigationMenu' but was %@", defaultProfile.rootViewId);
                
                XCTAssertFalse(customProfile.isDefault, @"Expected the custom profile to not be marked as default");
                XCTAssertTrue([customProfile.label isEqualToString:@"Custom Profile"],
                              @"Expected custom profile label to be 'Custom Profile' but was %@", customProfile.label);
                XCTAssertTrue([customProfile.summary isEqualToString:@"Description of the custom Profile"],
                              @"Expected custom profile summary to be 'Description of the custom Profile' but was %@", customProfile.summary);
                XCTAssertTrue([customProfile.rootViewId isEqualToString:@"views-menu-default"],
                              @"Expected custom profile rootViewId to be 'views-menu-default' but was %@", customProfile.rootViewId);
                
                // try retrieving an individual profile
                [self.configService retrieveProfileWithIdentifier:@"custom" completionBlock:^(AlfrescoProfileConfig *profile1, NSError *singleProfileError) {
                    if (profile1 == nil)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [self failureMessageFromError:singleProfileError];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        XCTAssertTrue([profile1.identifier isEqualToString:@"custom"],
                                      @"Expected retrieved profile identifier to be 'custom' but was %@", profile1.identifier);
                        XCTAssertFalse(profile1.isDefault, @"Expected the retrieved profile to not be marked as default");
                        XCTAssertTrue([profile1.label isEqualToString:@"Custom Profile"],
                                      @"Expected retrieved profile label to be 'Custom Profile' but was %@", profile1.label);
                        XCTAssertTrue([profile1.summary isEqualToString:@"Description of the custom Profile"],
                                      @"Expected retrieved profile summary to be 'Description of the custom Profile' but was %@", profile1.summary);
                        XCTAssertTrue([profile1.rootViewId isEqualToString:@"views-menu-default"],
                                      @"Expected retrieved profile rootViewId to be 'views-menu-default' but was %@", profile1.rootViewId);
                        
                        // try retrieving the default profile
                        [self.configService retrieveDefaultProfileWithCompletionBlock:^(AlfrescoProfileConfig *profile2, NSError *defaultProfileError) {
                            if (profile2 == nil)
                            {
                                self.lastTestSuccessful = NO;
                                self.lastTestFailureMessage = [self failureMessageFromError:defaultProfileError];
                                self.callbackCompleted = YES;
                            }
                            else
                            {
                                XCTAssertTrue([profile2.identifier isEqualToString:@"default"],
                                              @"Expected retrieved profile identifier to be 'default' but was %@", profile2.identifier);
                                XCTAssertTrue(profile2.isDefault, @"Expected the retrieved profile to be marked as default");
                                XCTAssertTrue([profile2.label isEqualToString:@"Default Profile"],
                                              @"Expected retrieved profile label to be 'Default Profile' but was %@", profile2.label);
                                XCTAssertTrue([profile2.summary isEqualToString:@"Description of the Default Profile"],
                                              @"Expected retrieved profile summary to be 'Description of the Default Profile' but was %@", profile2.summary);
                                XCTAssertTrue([profile2.rootViewId isEqualToString:@"rootNavigationMenu"],
                                              @"Expected retrieved profile rootViewId to be 'rootNavigationMenu' but was %@", profile2.rootViewId);
                                
                                self.lastTestSuccessful = YES;
                                self.callbackCompleted = YES;
                            }
                        }];
                    }
                }];
            }
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testInvalidProfile
{
    if (self.setUpSuccess)
    {
        self.configService = [[AlfrescoConfigService alloc] initWithDictionary:[self dictionaryForConfigService]];
        
        // retrieve an invalid profile
        [self.configService retrieveProfileWithIdentifier:@"invalid" completionBlock:^(AlfrescoProfileConfig *config, NSError *error) {
            if (config != nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = @"Expected retrieval of invalid profile to fail";
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(error, @"Expected to recieve an error when retrieving an invalid profile");
                XCTAssertTrue(error.code == kAlfrescoErrorCodeConfigNotFound, @"Expected the error code to be 1402 but it was %ld", (long)error.code);
                
                self.lastTestSuccessful = YES;
                self.callbackCompleted = YES;
            }
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testFeatureConfig
{
    if (self.setUpSuccess)
    {
        self.configService = [[AlfrescoConfigService alloc] initWithDictionary:[self dictionaryForConfigService]];
        
        // retrieve all the feature config
        [self.configService retrieveFeatureConfigWithCompletionBlock:^(NSArray *allFeatureConfig, NSError *allFeatureConfigError) {
            if (allFeatureConfig == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [self failureMessageFromError:allFeatureConfigError];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertTrue(allFeatureConfig.count > 0, @"Expected there to be at least one feature config");
                
                // try and find the features we're expecting
                AlfrescoFeatureConfig *dataProtectionFeature = nil;
                AlfrescoFeatureConfig *storageFeature = nil;
                for (AlfrescoFeatureConfig *feature in allFeatureConfig)
                {
                    if ([feature.identifier isEqualToString:@"com.alfresco.client.feature.dataprotection"])
                    {
                        dataProtectionFeature = feature;
                    }
                    else if ([feature.identifier isEqualToString:@"com.alfresco.client.feature.storage"])
                    {
                        storageFeature = feature;
                    }
                }
                
                // make sure the 2 features we're expecting are present
                XCTAssertNotNil(dataProtectionFeature, @"Expected to find a feature named com.alfresco.client.feature.dataprotection");
                XCTAssertNotNil(storageFeature, @"Expected to find a feature named com.alfresco.client.feature.storage");
                
                // check the features have the correct properties
                XCTAssertTrue([dataProtectionFeature.label isEqualToString:@"Data Protection"],
                              @"Expected data protection feature label to be 'Data Protection' but was %@", dataProtectionFeature.label);
                XCTAssertTrue([dataProtectionFeature.summary isEqualToString:@"Enable data protection by default for all account"],
                              @"Expected data protection feature summary to be 'Enable data protection by default for all account' but was %@", dataProtectionFeature.summary);
                
                XCTAssertTrue([storageFeature.label isEqualToString:@"Storage"],
                              @"Expected data protection feature label to be 'Storage' but was %@", storageFeature.label);
                XCTAssertTrue([storageFeature.summary isEqualToString:@"Define where to store the information in general"],
                              @"Expected data protection feature summary to be 'Define where to store the information in general' but was %@", storageFeature.summary);
                
                // retrieve a feature by identifier
                [self.configService retrieveFeatureConfigWithIdentifier:@"com.alfresco.client.feature.dataprotection" completionBlock:^(AlfrescoFeatureConfig *featureConfig, NSError *featureConfigError) {
                    if (featureConfig == nil)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [self failureMessageFromError:featureConfigError];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        // check we got the right feature config
                        XCTAssertTrue([featureConfig.identifier isEqualToString:@"com.alfresco.client.feature.dataprotection"],
                                      @"Expected retrieved feature identifier to be 'com.alfresco.client.feature.dataprotection' but was %@", featureConfig.identifier);
                        XCTAssertTrue([featureConfig.label isEqualToString:@"Data Protection"],
                                      @"Expected retrieved feature label to be 'Data Protection' but was %@", featureConfig.label);
                        XCTAssertTrue([featureConfig.summary isEqualToString:@"Enable data protection by default for all account"],
                                      @"Expected retrieved feature summary to be 'Enable data protection by default for all account' but was %@", featureConfig.summary);
                        
                        self.lastTestSuccessful = YES;
                        self.callbackCompleted = YES;
                    }
                }];
            }
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testViewConfig
{
    if (self.setUpSuccess)
    {
        self.configService = [[AlfrescoConfigService alloc] initWithDictionary:[self dictionaryForConfigService]];
        
        // retrieve view config for specific view
        [self.configService retrieveViewConfigWithIdentifier:@"view-activities-default" completionBlock:^(AlfrescoViewConfig *config, NSError *error) {
            if (config == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [self failureMessageFromError:error];
                self.callbackCompleted = YES;
            }
            else
            {
                // check the view is as expected
                XCTAssertTrue([config.identifier isEqualToString:@"view-activities-default"],
                              @"Expected an identifier of 'view-activities-default' but it was %@", config.identifier);
                XCTAssertTrue([config.label isEqualToString:@"Activities"],
                              @"Expected a label of 'Activities' but it was %@", config.label);
                XCTAssertTrue([config.summary isEqualToString:@"Activities Description"],
                              @"Expected a summary of 'Activities Description' but it was %@", config.summary);
                XCTAssertTrue([config.iconIdentifier isEqualToString:@"Activities Icon"],
                              @"Expected a summary of 'Activities Icon' but it was %@", config.iconIdentifier);
                XCTAssertTrue([config.type isEqualToString:@"com.alfresco.type.activities"],
                              @"Expected a type of 'com.alfresco.type.activities' but it was %@", config.type);
                
                self.lastTestSuccessful = YES;
                self.callbackCompleted = YES;
            }
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testViewGroupConfig
{
    if (self.setUpSuccess)
    {
        self.configService = [[AlfrescoConfigService alloc] initWithDictionary:[self dictionaryForConfigService]];
        
        // retrieve view group config for specific view group
        [self.configService retrieveViewGroupConfigWithIdentifier:@"views-menu-default" completionBlock:^(AlfrescoViewGroupConfig *config, NSError *error) {
            if (config == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [self failureMessageFromError:error];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertTrue([config.identifier isEqualToString:@"views-menu-default"], @"Expected view group config identifier to be 'views-menu-default' but it was %@", config.identifier);
                XCTAssertTrue([config.label isEqualToString:@"Default Menu"],
                              @"Expected view group label of 'Default Menu' but it was %@", config.label);
                
                XCTAssertNotNil(config.items, @"Expected items property to be populated");
                XCTAssertTrue(config.items.count == 3, @"Expected there to be 3 view configurations");
                
                // make sure the first item is a view
                AlfrescoItemConfig *item1 = config.items[0];
                XCTAssertTrue([item1 isKindOfClass:[AlfrescoViewConfig class]], @"Expected the first item to be a view but it was %@", item1);
                AlfrescoViewConfig *view1 = (AlfrescoViewConfig *)item1;
                XCTAssertTrue([view1.identifier isEqualToString:@"view-activities-default"],
                              @"Expected an identifier of 'view-activities-default' but it was %@", view1.identifier);
                XCTAssertTrue([view1.label isEqualToString:@"Activities"],
                              @"Expected a label of 'Activities' but it was %@", view1.label);
                XCTAssertTrue([view1.summary isEqualToString:@"Activities Description"],
                              @"Expected a summary of 'Activities Description' but it was %@", view1.summary);
                XCTAssertTrue([view1.iconIdentifier isEqualToString:@"Activities Icon"],
                              @"Expected a summary of 'Activities Icon' but it was %@", view1.iconIdentifier);
                XCTAssertTrue([view1.type isEqualToString:@"com.alfresco.type.activities"],
                              @"Expected a type of 'com.alfresco.type.activities' but it was %@", view1.type);
                
                // make sure the second item is a view
                AlfrescoItemConfig *item2 = config.items[1];
                XCTAssertTrue([item2 isKindOfClass:[AlfrescoViewConfig class]], @"Expected the second item to be a view but it was %@", item2);
                AlfrescoViewConfig *view2 = (AlfrescoViewConfig *)item2;
                XCTAssertTrue([view2.identifier isEqualToString:@"view-repository-default"],
                              @"Expected an identifier of 'view-repository-default' but it was %@", view2.identifier);
                XCTAssertTrue([view2.type isEqualToString:@"com.alfresco.type.repository"],
                              @"Expected a type of 'com.alfresco.type.repository' but it was %@", view2.type);
                XCTAssertNil(view2.label, @"Expected label for view2 to be nil");
                XCTAssertNil(view2.summary, @"Expected summary for view2 to be nil");
                XCTAssertNil(view2.iconIdentifier, @"Expected icon identifier for view2 to be nil");
                
                // make sure the third item is a view
                AlfrescoItemConfig *item3 = config.items[2];
                XCTAssertTrue([item3 isKindOfClass:[AlfrescoViewConfig class]], @"Expected the third item to be a view but it was %@", item3);
                AlfrescoViewConfig *view3 = (AlfrescoViewConfig *)item3;
                XCTAssertNil(view3.identifier, @"Expected identifier for view3 to be nil");
                XCTAssertTrue([view3.label isEqualToString:@"Sites"],
                              @"Expected a label of 'Sites' but it was %@", view3.label);
                XCTAssertTrue([view3.summary isEqualToString:@"Sites Description"],
                              @"Expected a summary of 'Sites Description' but it was %@", view3.summary);
                XCTAssertTrue([view3.iconIdentifier isEqualToString:@"Sites Icon"],
                              @"Expected a summary of 'Sites Icon' but it was %@", view3.iconIdentifier);
                XCTAssertTrue([view3.type isEqualToString:@"com.alfresco.type.sites"],
                              @"Expected a type of 'com.alfresco.type.sites' but it was %@", view3.type);
                
                self.lastTestSuccessful = YES;
                self.callbackCompleted = YES;
            }
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testFormConfig
{
    if (self.setUpSuccess)
    {
        self.configService = [[AlfrescoConfigService alloc] initWithDictionary:[self dictionaryForConfigService]];
        
        // retrieve form config
        [self.configService retrieveFormConfigWithIdentifier:@"view-properties" completionBlock:^(AlfrescoFormConfig *config, NSError *error) {
            if (config == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [self failureMessageFromError:error];
                self.callbackCompleted = YES;
            }
            else
            {
                // check we got the right form config
                XCTAssertTrue([config.identifier isEqualToString:@"view-properties"],
                              @"Expected form config identifier to be 'view-properties' but was %@", config.identifier);
                XCTAssertTrue([config.label isEqualToString:@"view.properties.title"],
                              @"Expected form config label to be 'view.properties.title' but was %@", config.label);
                XCTAssertTrue([config.summary isEqualToString:@"view.properties.description"],
                              @"Expected form config label to be 'view.properties.description' but was %@", config.summary);
                XCTAssertTrue([config.layout isEqualToString:@"1column"],
                              @"Expected form config label to be '1column' but was %@", config.layout);
                
                // retrieve the field config
                NSArray *groups = config.items;
                XCTAssertTrue(groups.count == 2, @"Expected to find config for 2 field groups");
                
                // get the field config for the type properties group
                NSArray *typeProperties = [groups[0] items];
                XCTAssertTrue(typeProperties.count == 10,
                              @"Expected to find config for 10 fields but there was %lu", (unsigned long)typeProperties.count);
                
                AlfrescoFieldConfig *nameField = typeProperties[0];
                XCTAssertTrue([nameField.modelIdentifier isEqualToString:@"cm:name"],
                              @"Expected first field to be cm:name but was %@", nameField.identifier);
                XCTAssertTrue([nameField.label isEqualToString:@"cm_contentmodel.property.cm_name.title"],
                              @"Expected first field to have label of 'cm_contentmodel.property.cm_name.title' but was %@", nameField.label);
                
                AlfrescoFieldConfig *titleField = typeProperties[1];
                XCTAssertTrue([titleField.modelIdentifier isEqualToString:@"cm:title"],
                              @"Expected second field to be cm:title but was %@", titleField.identifier);
                XCTAssertTrue([titleField.label isEqualToString:@"cm_contentmodel.property.cm_title.title"],
                              @"Expected second field to have label of 'cm_contentmodel.property.cm_title.title' but was %@", titleField.label);
                
                AlfrescoFieldConfig *descriptionField = typeProperties[2];
                XCTAssertTrue([descriptionField.modelIdentifier isEqualToString:@"cm:description"],
                              @"Expected third field to be cm:description but was %@", descriptionField.identifier);
                XCTAssertTrue([descriptionField.label isEqualToString:@"cm_contentmodel.property.cm_description.title"],
                              @"Expected third field to have label of 'cm_contentmodel.property.cm_description.title' but was %@", descriptionField.label);
                
                AlfrescoFieldConfig *mimetypeField = typeProperties[3];
                XCTAssertTrue([mimetypeField.modelIdentifier isEqualToString:@"mimetype"],
                              @"Expected fourth field to be mimetype but was %@", mimetypeField.identifier);
                XCTAssertTrue([mimetypeField.label isEqualToString:@"cm_contentmodel.property.cm_mimetype.title"],
                              @"Expected fourth field to have label of 'cm_contentmodel.property.cm_mimetype.title' but was %@", mimetypeField.label);
                
                AlfrescoFieldConfig *authorField = typeProperties[4];
                XCTAssertTrue([authorField.modelIdentifier isEqualToString:@"cm:author"],
                              @"Expected fifth field to be cm:author but was %@", authorField.identifier);
                XCTAssertTrue([authorField.label isEqualToString:@"cm_contentmodel.property.cm_author.title"],
                              @"Expected fifth field to have label of 'cm_contentmodel.property.cm_author.title' but was %@", authorField.label);
                
                AlfrescoFieldConfig *sizeField = typeProperties[5];
                XCTAssertTrue([sizeField.modelIdentifier isEqualToString:@"size"],
                              @"Expected sixth field to be size but was %@", sizeField.modelIdentifier);
                XCTAssertTrue([sizeField.label isEqualToString:@"cm_contentmodel.property.cm_size.title"],
                              @"Expected sixth field to have label of 'cm_contentmodel.property.cm_size.title' but was %@", sizeField.label);
                
                AlfrescoFieldConfig *creatorField = typeProperties[6];
                XCTAssertTrue([creatorField.modelIdentifier isEqualToString:@"cm:creator"],
                              @"Expected seventh field to be cm:creator but was %@", creatorField.identifier);
                XCTAssertTrue([creatorField.label isEqualToString:@"cm_contentmodel.property.cm_creator.title"],
                              @"Expected seventh field to have label of 'cm_contentmodel.property.cm_creator.title' but was %@", creatorField.label);
                
                AlfrescoFieldConfig *createdField = typeProperties[7];
                XCTAssertTrue([createdField.modelIdentifier isEqualToString:@"cm:created"],
                              @"Expected eigth field to be cm:created but was %@", createdField.identifier);
                XCTAssertTrue([createdField.label isEqualToString:@"cm_contentmodel.property.cm_created.title"],
                              @"Expected eigth field to have label of 'cm_contentmodel.property.cm_created.title' but was %@", creatorField.label);
                
                AlfrescoFieldConfig *modifierField = typeProperties[8];
                XCTAssertTrue([modifierField.modelIdentifier isEqualToString:@"cm:modifier"],
                              @"Expected ninth field to be cm:modifier but was %@", modifierField.identifier);
                XCTAssertTrue([modifierField.label isEqualToString:@"cm_contentmodel.property.cm_modifier.title"],
                              @"Expected ninth field to have label of 'cm_contentmodel.property.cm_modifier.title' but was %@", modifierField.label);
                
                AlfrescoFieldConfig *modifiedField = typeProperties[9];
                XCTAssertTrue([modifiedField.modelIdentifier isEqualToString:@"cm:modified"],
                              @"Expected tenth field to be cm:modified but was %@", modifiedField.identifier);
                XCTAssertTrue([modifiedField.label isEqualToString:@"cm_contentmodel.property.cm_modified.title"],
                              @"Expected tenth field to have label of 'cm_contentmodel.property.cm_modified.title' but was %@", modifiedField.label);
                
                // get the field config for the aspect properties group
                NSArray *aspectProperties = [groups[1] items];
                XCTAssertTrue(aspectProperties.count == 2,
                              @"Expected to find config for 2 fields but there were %lu", (unsigned long)aspectProperties.count);
                
                AlfrescoFieldConfig *latitudeField = aspectProperties[0];
                XCTAssertTrue([latitudeField.modelIdentifier isEqualToString:@"cm:latitude"],
                              @"Expected first aspect field to be cm:latitude but was %@", latitudeField.identifier);
                XCTAssertTrue([latitudeField.label isEqualToString:@"cm_contentmodel.property.cm_latitude.title"],
                              @"Expected first aspect field to have label of 'cm_contentmodel.property.cm_latitude.title' but was %@", latitudeField.label);
                
                AlfrescoFieldConfig *longitudeField = aspectProperties[1];
                XCTAssertTrue([longitudeField.modelIdentifier isEqualToString:@"cm:longitude"],
                              @"Expected second aspect field to be cm:longitude but was %@", longitudeField.identifier);
                XCTAssertTrue([longitudeField.label isEqualToString:@"cm_contentmodel.property.cm_longitude.title"],
                              @"Expected second aspect field to have label of 'cm_contentmodel.property.cm_longitude.title' but was %@", longitudeField.label);
                
                self.lastTestSuccessful = YES;
                self.callbackCompleted = YES;
            }
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testCreationConfig
{
    if (self.setUpSuccess)
    {
        self.configService = [[AlfrescoConfigService alloc] initWithDictionary:[self dictionaryForConfigService]];
        
        // retrieve creation config
        [self.configService retrieveCreationConfigWithCompletionBlock:^(AlfrescoCreationConfig *config, NSError *error) {
            if (config == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [self failureMessageFromError:error];
                self.callbackCompleted = YES;
            }
            else
            {
                NSArray *documentTypes = config.creatableDocumentTypes;
                NSArray *folderTypes = config.creatableFolderTypes;
                NSArray *mimeTypes = config.creatableMimeTypes;
                
                XCTAssertNil(documentTypes, @"Expected createable document types config to be nil");
                
                XCTAssertNotNil(folderTypes, @"Expected to find createable folder types config");
                XCTAssertTrue(folderTypes.count == 1, @"Expected to find 1 configured folder type");
                AlfrescoItemConfig *folderType1 = folderTypes[0];
                XCTAssertTrue([folderType1.identifier isEqualToString:@"cm:folder"],
                              @"Expected folder type identifier to be 'cm:folder' but it was %@", folderType1.identifier);
                XCTAssertTrue([folderType1.label isEqualToString:@"Default Folder"],
                              @"Expected folder type label to be 'Default Folder' but it was %@", folderType1.label);
                XCTAssertTrue([folderType1.iconIdentifier isEqualToString:@"Default Folder Icon"],
                              @"Expected folder type label to be 'Default Folder Icon' but it was %@", folderType1.iconIdentifier);
                XCTAssertTrue([folderType1.summary isEqualToString:@"Default Description Folder"],
                              @"Expected folder type summary to be 'Default Description Folder' but it was %@", folderType1.summary);
                
                XCTAssertNotNil(mimeTypes, @"Expected to find createable mime types config");
                XCTAssertTrue(mimeTypes.count == 1, @"Expected to find 1 configured mime type");
                AlfrescoItemConfig *mimeType1 = mimeTypes[0];
                XCTAssertTrue([mimeType1.identifier isEqualToString:@"application/vnd.openxmlformats-officedocument.wordprocessingml.document"],
                              @"Expected folder type identifier to be 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' but it was %@", mimeType1.identifier);
                XCTAssertTrue([mimeType1.label isEqualToString:@"Word Document"],
                              @"Expected folder type label to be 'Word Document' but it was %@", mimeType1.label);
                XCTAssertTrue([mimeType1.iconIdentifier isEqualToString:@"Word Icon"],
                              @"Expected folder type label to be 'Word Icon' but it was %@", mimeType1.iconIdentifier);
                XCTAssertTrue([mimeType1.summary isEqualToString:@"Microsoft Office 2007 Word Document"],
                              @"Expected folder type summary to be 'Microsoft Office 2007 Word Document' but it was %@", mimeType1.summary);
                
                self.lastTestSuccessful = YES;
                self.callbackCompleted = YES;
            }
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)disabledtestActionConfig
{
    // TODO
    
    XCTFail(@"Test not implemented yet: %@", NSStringFromSelector(_cmd));
}

- (void)disabledtestActionGroupConfig
{
    // TODO
    
    XCTFail(@"Test not implemented yet: %@", NSStringFromSelector(_cmd));
}

- (void)disabledtestWorkflowConfig
{
    // TODO
    
    XCTFail(@"Test not implemented yet: %@", NSStringFromSelector(_cmd));
}

- (void)disabledtestSearchConfig
{
    // TODO
    
    XCTFail(@"Test not implemented yet: %@", NSStringFromSelector(_cmd));
}

@end
