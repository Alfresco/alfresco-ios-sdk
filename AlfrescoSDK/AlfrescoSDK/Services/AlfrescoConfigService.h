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

#import <Foundation/Foundation.h>
#import "AlfrescoSession.h"
#import "AlfrescoActionGroupConfig.h"
#import "AlfrescoConfigInfo.h"
#import "AlfrescoConfigScope.h"
#import "AlfrescoCreationConfig.h"
#import "AlfrescoFeatureConfig.h"
#import "AlfrescoFormConfig.h"
#import "AlfrescoProfileConfig.h"
#import "AlfrescoRepositoryConfig.h"
#import "AlfrescoSearchConfig.h"
#import "AlfrescoThemeConfig.h"
#import "AlfrescoViewGroupConfig.h"
#import "AlfrescoWorkflowConfig.h"

// TODO: move to public constants file...
typedef void (^AlfrescoActionGroupConfigCompletionBlock)(AlfrescoActionGroupConfig *config, NSError *error);
typedef void (^AlfrescoConfigInfoCompletionBlock)(AlfrescoConfigInfo *configInfo, NSError *error);
typedef void (^AlfrescoCreationConfigCompletionBlock)(AlfrescoCreationConfig *config, NSError *error);
typedef void (^AlfrescoFeatureConfigCompletionBlock)(AlfrescoFeatureConfig *config, NSError *error);
typedef void (^AlfrescoFormConfigCompletionBlock)(AlfrescoFormConfig *config, NSError *error);
typedef void (^AlfrescoProfileConfigCompletionBlock)(AlfrescoProfileConfig *config, NSError *error);
typedef void (^AlfrescoRepositoryConfigCompletionBlock)(AlfrescoRepositoryConfig *config, NSError *error);
typedef void (^AlfrescoSearchConfigCompletionBlock)(AlfrescoSearchConfig *config, NSError *error);
typedef void (^AlfrescoThemeConfigCompletionBlock)(AlfrescoThemeConfig *config, NSError *error);
typedef void (^AlfrescoViewGroupConfigCompletionBlock)(AlfrescoViewGroupConfig *config, NSError *error);
typedef void (^AlfrescoWorkflowConfigCompletionBlock)(AlfrescoWorkflowConfig *config, NSError *error);

extern NSString * const kAlfrescoConfigServiceParameterApplicationId;
extern NSString * const kAlfrescoConfigServiceParameterProfileId;
extern NSString * const kAlfrescoConfigServiceParameterLocalFile;

/**
 The ConfigService retrieves JSON based configuration data either from the Data Dictionary
 in the connected repository or from a local file containing configuration data.
 */
@interface AlfrescoConfigService : NSObject

/**---------------------------------------------------------------------------------------
 * @name Initialisation methods
 *  ---------------------------------------------------------------------------------------
 */

/** Initialises with a standard Cloud or OnPremise session.
 
 @param session the AlfrescoSession to initialise the config service with.
 */
- (id)initWithSession:(id<AlfrescoSession>)session;

/** Initialises with a dictionary of parameters.
 
 @param parameters A dictionary containing the paramters to initialise with.
 */
- (id)initWithDictionary:(NSDictionary *)parameters;

/**---------------------------------------------------------------------------------------
 * @name Config retrieval methods.
 *  ---------------------------------------------------------------------------------------
 */

- (AlfrescoRequest *)retrieveConfigInfoWithCompletionBlock:(AlfrescoConfigInfoCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveDefaultProfileWithCompletionBlock:(AlfrescoProfileConfigCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveProfileWithIdentifier:(NSString *)identifier
                                   completionBlock:(AlfrescoProfileConfigCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveProfilesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveRepositoryConfigWithCompletionBlock:(AlfrescoRepositoryConfigCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveFeatureConfigWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveFeatureConfigWithConfigScope:(AlfrescoConfigScope *)scope
                                          completionBlock:(AlfrescoArrayCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveFeatureConfigWithIdentifier:(NSString *)identifier
                                         completionBlock:(AlfrescoFeatureConfigCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveFeatureConfigWithIdentifier:(NSString *)identifier
                                                   scope:(AlfrescoConfigScope *)scope
                                         completionBlock:(AlfrescoFeatureConfigCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveViewGroupConfigWithIdentifier:(NSString *)identifier
                                           completionBlock:(AlfrescoViewGroupConfigCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveViewGroupConfigWithIdentifier:(NSString *)identifier
                                                     scope:(AlfrescoConfigScope *)scope
                                           completionBlock:(AlfrescoViewGroupConfigCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveActionGroupConfigWithIdentifier:(NSString *)identifier
                                             completionBlock:(AlfrescoActionGroupConfigCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveActionGroupConfigWithIdentifier:(NSString *)identifier
                                                       scope:(AlfrescoConfigScope *)scope
                                             completionBlock:(AlfrescoActionGroupConfigCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveFormConfigWithIdentifier:(NSString *)identifier
                                      completionBlock:(AlfrescoFormConfigCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveFormConfigWithIdentifier:(NSString *)identifier
                                                scope:(AlfrescoConfigScope *)scope
                                      completionBlock:(AlfrescoFormConfigCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveWorkflowConfigWithCompletionBlock:(AlfrescoWorkflowConfigCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveWorkflowConfigWithConfigScope:(AlfrescoConfigScope *)scope
                                           completionBlock:(AlfrescoWorkflowConfigCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveCreationConfigWithCompletionBlock:(AlfrescoCreationConfigCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveCreationConfigWithConfigScope:(AlfrescoConfigScope *)scope
                                           completionBlock:(AlfrescoCreationConfigCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveSearchConfigWithCompletionBlock:(AlfrescoSearchConfigCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveSearchConfigWithConfigScope:(AlfrescoConfigScope *)scope
                                         completionBlock:(AlfrescoSearchConfigCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveThemeConfigWithCompletionBlock:(AlfrescoSearchConfigCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveThemeConfigWithConfigScope:(AlfrescoConfigScope *)scope
                                        completionBlock:(AlfrescoThemeConfigCompletionBlock)completionBlock;

/**
 Clears any cached state the service has.
 */
- (void)clear;

@end
