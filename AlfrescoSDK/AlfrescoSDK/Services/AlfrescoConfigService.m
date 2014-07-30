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
#import "AlfrescoLog.h"
#import "AlfrescoErrors.h"
#import "AlfrescoPropertyConstants.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoFieldConfig.h"
#import "AlfrescoFieldGroupConfig.h"
#import "AlfrescoObjectConverter.h"
#import "AlfrescoDocumentFolderService.h"

NSString * const kAlfrescoConfigServiceParameterApplicationId = @"org.alfresco.mobile.config.application.id";
NSString * const kAlfrescoConfigServiceParameterProfileId = @"org.alfresco.mobile.config.profile.id";
NSString * const kAlfrescoConfigServiceParameterLocalFile = @"org.alfresco.mobile.config.local.file";

NSString * const kAlfrescoConfigScopeContextUsername = @"org.alfresco.mobile.config.scope.context.username";
NSString * const kAlfrescoConfigScopeContextNode = @"org.alfresco.mobile.config.scope.context.node";

NSString * const kAlfrescoConfigProfileDefault = @"default";


@interface AlfrescoConfigService ()
@property (nonatomic, strong, readwrite) AlfrescoConfigScope *defaultConfigScope;

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
@property (nonatomic, strong) AlfrescoCreationConfig *creation;
@property (nonatomic, strong) NSDictionary *views;
@property (nonatomic, strong) NSMutableDictionary *viewGroups;
@property (nonatomic, strong) NSDictionary *fields;
@property (nonatomic, strong) NSMutableDictionary *fieldGroups;
@property (nonatomic, strong) NSArray *forms;
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
        self.defaultConfigScope = [[AlfrescoConfigScope alloc] initWithProfile:kAlfrescoConfigProfileDefault
                                                                       context:@{kAlfrescoConfigScopeContextUsername: session.personIdentifier}];
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
        self.defaultConfigScope = [[AlfrescoConfigScope alloc] initWithProfile:kAlfrescoConfigProfileDefault];
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
            
            // TODO: Determine if this is the correct location and if there is a "safer" way of getting the file.
            NSString *configPath = [NSString stringWithFormat:@"/Data Dictionary/Client Configuration/Mobile/%@/config.json", self.applicationId];
            
            // retrieve the configuration content
            AlfrescoDocumentFolderService *docFolderService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.session];
            AlfrescoRequest *request = nil;
            request = [docFolderService retrieveNodeWithFolderPath:configPath completionBlock:^(AlfrescoNode *configNode, NSError *retrieveNodeError) {
                if (configNode != nil)
                {
                    AlfrescoRequest *contentRequest = [docFolderService retrieveContentOfDocument:(AlfrescoDocument*)configNode completionBlock:^(AlfrescoContentFile *contentFile, NSError *retrieveContentError) {
                        if (configNode != nil)
                        {
                            [self processJSONData:[NSData dataWithContentsOfFile:contentFile.fileUrl.path]
                                  completionBlock:completionBlock];
                        }
                        else
                        {
                            completionBlock(NO, retrieveContentError);
                        }
                    } progressBlock:nil];
                    
                    request.httpRequest = contentRequest.httpRequest;
                }
                else
                {
                    completionBlock(NO, retrieveNodeError);
                }
            }];
            
            return request;
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
            [self parseRepositoryConfig:jsonDictionary];
            [self parseProfilesConfig:jsonDictionary];
            [self parseFeaturesConfig:jsonDictionary];
            [self parseCreationConfig:jsonDictionary];
            [self parseViewConfig:jsonDictionary];
            [self parseFormConfig:jsonDictionary];
            
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

- (void)parseRepositoryConfig:(NSDictionary *)json
{
    NSDictionary *repositoryJSON = json[kAlfrescoJSONRepository];
    NSDictionary *repositoryProperties = @{kAlfrescoRepositoryConfigPropertyShareURL: repositoryJSON[kAlfrescoJSONShareURL],
                                           kAlfrescoRepositoryConfigPropertyCMISURL: repositoryJSON[kAlfrescoJSONCMISURL]};
    
    self.repository = [[AlfrescoRepositoryConfig alloc] initWithDictionary:repositoryProperties];
}

- (void)parseProfilesConfig:(NSDictionary *)json
{
    NSDictionary *profilesJSON = json[kAlfrescoJSONProfiles];
    
    NSDictionary *keyMappings = @{kAlfrescoJSONLabelId: kAlfrescoBaseConfigPropertyLabel,
                                  kAlfrescoJSONDescriptionId: kAlfrescoBaseConfigPropertySummary,
                                  kAlfrescoJSONRootViewId: kAlfrescoProfileConfigPropertyRootViewId,
                                  kAlfrescoJSONDefault: kAlfrescoProfileConfigPropertyIsDefault};
    
    NSMutableDictionary *profilesDictionary = [NSMutableDictionary dictionary];
    NSArray *profileIds = [profilesJSON allKeys];
    for (NSString *profileId in profileIds)
    {
        NSDictionary *profileJSON = profilesJSON[profileId];
        
        // re-map the JSON keys to what the profile config model object expects
        NSMutableDictionary *profileProperties = [NSMutableDictionary dictionaryWithDictionary:[AlfrescoObjectConverter dictionaryFromDictionary:profileJSON withMappedKeys:keyMappings]];
        
        // add the id of the profile
        profileProperties[kAlfrescoBaseConfigPropertyIdentifier] = profileId;
        
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

- (void)parseFeaturesConfig:(NSDictionary *)json
{
    NSArray *featuresJSON = json[kAlfrescoJSONFeatures];
    
    NSDictionary *keyMappings = @{kAlfrescoJSONIdentifier: kAlfrescoBaseConfigPropertyIdentifier,
                                  kAlfrescoJSONLabelId: kAlfrescoBaseConfigPropertyLabel,
                                  kAlfrescoJSONDescriptionId: kAlfrescoBaseConfigPropertySummary};
    
    NSMutableArray *featuresArray = [NSMutableArray array];
    for (NSDictionary *featureJSON in featuresJSON)
    {
        // re-map the JSON keys to what the feature config model object expects
        NSDictionary *featureProperties = [AlfrescoObjectConverter dictionaryFromDictionary:featureJSON withMappedKeys:keyMappings];

        // create and store the feature object
        AlfrescoFeatureConfig *feature = [[AlfrescoFeatureConfig alloc] initWithDictionary:featureProperties];
        [featuresArray addObject:feature];
    }
    
    self.features = featuresArray;
}

- (void)parseCreationConfig:(NSDictionary *)json
{
    NSDictionary *creationJSON = json[kAlfrescoJSONCreation];
    
    NSDictionary *keyMappings = @{kAlfrescoJSONIdentifier: kAlfrescoBaseConfigPropertyIdentifier,
                                  kAlfrescoJSONLabelId: kAlfrescoBaseConfigPropertyLabel,
                                  kAlfrescoJSONDescriptionId: kAlfrescoBaseConfigPropertySummary,
                                  kAlfrescoJSONIconId: kAlfrescoItemConfigPropertyIconIdentifier};
    
    // parse all the options
    NSMutableDictionary *creationDictionary = [NSMutableDictionary dictionary];
    NSArray *creationIds = [creationJSON allKeys];
    for (NSString *creationId in creationIds)
    {
        NSArray *creationTypeOptionsJSON = creationJSON[creationId];
        NSMutableArray *creationTypeOptionsArray = [NSMutableArray array];
        
        for (NSDictionary *creationOptionJSON in creationTypeOptionsJSON)
        {
            // re-map the JSON keys to what the item config model object expects
            NSDictionary *creationProperties = [AlfrescoObjectConverter dictionaryFromDictionary:creationOptionJSON
                                                                                  withMappedKeys:keyMappings];
            
            // create and store the item object to represent the option
            AlfrescoItemConfig *creationOption = [[AlfrescoItemConfig alloc] initWithDictionary:creationProperties];
            [creationTypeOptionsArray addObject:creationOption];
        }
        
        creationDictionary[creationId] = creationTypeOptionsArray;
    }
    
    // generate the AlfrescoCreationConfig object using the dictionary mapper helper object
    NSMutableDictionary *creationConfigProperties = [NSMutableDictionary dictionary];
    if (creationDictionary[kAlfrescoJSONMimeTypes] != nil)
    {
        creationConfigProperties[kAlfrescoCreationConfigPropertyCreatableMimeTypes] = creationDictionary[kAlfrescoJSONMimeTypes];
    }
    if (creationDictionary[kAlfrescoJSONDocumentTypes] != nil)
    {
        creationConfigProperties[kAlfrescoCreationConfigPropertyCreatableDocumentTypes] = creationDictionary[kAlfrescoJSONDocumentTypes];
    }
    if (creationDictionary[kAlfrescoJSONFolderTypes] != nil)
    {
        creationConfigProperties[kAlfrescoCreationConfigPropertyCreatableFolderTypes] = creationDictionary[kAlfrescoJSONFolderTypes];
    }
    
    self.creation = [[AlfrescoCreationConfig alloc] initWithDictionary:creationConfigProperties];
}

- (void)parseViewConfig:(NSDictionary *)json
{
    [self parseViews:json[kAlfrescoJSONViews]];
    [self parseViewGroups:json[kAlfrescoJSONViewGroups]];
}

- (void)parseViews:(NSDictionary *)viewsJSON
{
    // key mappings for view config -> view config model object
    NSDictionary *keyMappings = @{kAlfrescoJSONIdentifier: kAlfrescoBaseConfigPropertyIdentifier,
                                  kAlfrescoJSONLabelId: kAlfrescoBaseConfigPropertyLabel,
                                  kAlfrescoJSONDescriptionId: kAlfrescoBaseConfigPropertySummary,
                                  kAlfrescoJSONIconId: kAlfrescoItemConfigPropertyIconIdentifier};
    
    NSMutableDictionary *viewsDictionary = [NSMutableDictionary dictionary];
    for (NSString *viewId in [viewsJSON allKeys])
    {
        NSDictionary *viewJSON = viewsJSON[viewId];
        
        // re-map the JSON keys to what the view config model object expects
        NSMutableDictionary *viewProperties = [NSMutableDictionary dictionaryWithDictionary:[AlfrescoObjectConverter dictionaryFromDictionary:viewJSON withMappedKeys:keyMappings]];
        
        // add the id of the profile
        viewProperties[kAlfrescoBaseConfigPropertyIdentifier] = viewId;
        
        // create and store the view object
        AlfrescoViewConfig *view = [[AlfrescoViewConfig alloc] initWithDictionary:viewProperties];
        viewsDictionary[viewId] = view;
    }
    
    self.views = viewsDictionary;
}

- (void)parseViewGroups:(NSArray *)viewGroupsJSON
{
    self.viewGroups = [NSMutableDictionary dictionary];
    
    for (NSDictionary *viewGroupJSON in viewGroupsJSON)
    {
        // recursively parse the view groups
        [self parseViewGroup:viewGroupJSON];
    }
}

- (void)parseViewGroup:(NSDictionary *)viewGroupJSON
{
    NSDictionary *keyMappings = @{kAlfrescoJSONIdentifier: kAlfrescoBaseConfigPropertyIdentifier,
                                  kAlfrescoJSONLabelId: kAlfrescoBaseConfigPropertyLabel,
                                  kAlfrescoJSONDescriptionId: kAlfrescoBaseConfigPropertySummary,
                                  kAlfrescoJSONIconId: kAlfrescoItemConfigPropertyIconIdentifier,
                                  kAlfrescoJSONFormId: kAlfrescoViewConfigPropertyFormIdentifier};
    
    // build an array of config objects representing the "items" config
    NSArray *groupItems = viewGroupJSON[kAlfrescoJSONItems];
    NSMutableArray *itemsArray = [NSMutableArray array];
    for (NSDictionary *groupItemJSON in groupItems)
    {
        NSString *itemType = groupItemJSON[kAlfrescoJSONItemType];
        if ([itemType isEqualToString:kAlfrescoJSONViewId])
        {
            NSString *viewId = groupItemJSON[kAlfrescoJSONViewId];
            [itemsArray addObject:self.views[viewId]];
        }
        else if ([itemType isEqualToString:kAlfrescoJSONView])
        {
            NSDictionary *viewJSON = groupItemJSON[kAlfrescoJSONView];
            
            NSDictionary *viewConfigProperties = [AlfrescoObjectConverter dictionaryFromDictionary:viewJSON
                                                                                    withMappedKeys:keyMappings];
            [itemsArray addObject:[[AlfrescoViewConfig alloc] initWithDictionary:viewConfigProperties]];
        }
        else if ([itemType isEqualToString:kAlfrescoJSONViewGroupId])
        {
            NSString *viewGroupId = groupItemJSON[kAlfrescoJSONViewGroupId];
//            [itemsArray addObject:viewGroupId];
            AlfrescoLogWarning(@"View group references (%@) not supported yet!!", viewGroupId);
        }
        else if ([itemType isEqualToString:kAlfrescoJSONViewGroup])
        {
            // recursively parse the inline view group
            NSDictionary *childViewGroupJSON = groupItemJSON[kAlfrescoJSONViewGroup];
            [self parseViewGroup:childViewGroupJSON];
        }
    }
    
    // create view group config object
    NSMutableDictionary *amendedViewGroupJSON = [NSMutableDictionary dictionaryWithDictionary:viewGroupJSON];
    amendedViewGroupJSON[kAlfrescoJSONItems] = itemsArray;
    
    NSDictionary *viewGroupProperties = [AlfrescoObjectConverter dictionaryFromDictionary:amendedViewGroupJSON
                                                                           withMappedKeys:keyMappings];
    AlfrescoViewGroupConfig *viewGroup = [[AlfrescoViewGroupConfig alloc] initWithDictionary:viewGroupProperties];
    
    // TODO: we need to store view groups within an array as we might have multiple view groups
    //       with the same id but differing evaluators.
    self.viewGroups[viewGroup.identifier] = viewGroup;
}

- (void)parseFormConfig:(NSDictionary *)json
{
    [self parseFields:json[kAlfrescoJSONFields]];
    [self parseFieldGroups:json[kAlfrescoJSONFieldGroups]];
    [self parseForms:json[kAlfrescoJSONForms]];
}

- (void)parseFields:(NSDictionary *)fieldsJSON
{
    // key mappings for field config -> field config model object
    NSDictionary *keyMappings = @{kAlfrescoJSONIdentifier: kAlfrescoBaseConfigPropertyIdentifier,
                                  kAlfrescoJSONLabelId: kAlfrescoBaseConfigPropertyLabel,
                                  kAlfrescoJSONDescriptionId: kAlfrescoBaseConfigPropertySummary,
                                  kAlfrescoJSONIconId: kAlfrescoItemConfigPropertyIconIdentifier,
                                  kAlfrescoJSONModelId: kAlfrescoFieldConfigPropertyModelIdentifier};
    
    NSMutableDictionary *fieldsDictionary = [NSMutableDictionary dictionary];
    for (NSString *fieldId in [fieldsJSON allKeys])
    {
        NSDictionary *fieldJSON = fieldsJSON[fieldId];
        
        // re-map the JSON keys to what the field config model object expects
        NSMutableDictionary *fieldProperties = [NSMutableDictionary dictionaryWithDictionary:[AlfrescoObjectConverter dictionaryFromDictionary:fieldJSON withMappedKeys:keyMappings]];
        
        // add the id of the field
        fieldProperties[kAlfrescoBaseConfigPropertyIdentifier] = fieldId;
        
        // create and store the field object
        AlfrescoFieldConfig *field = [[AlfrescoFieldConfig alloc] initWithDictionary:fieldProperties];
        fieldsDictionary[fieldId] = field;
    }
    
    self.fields = fieldsDictionary;
}

- (void)parseFieldGroups:(NSDictionary *)fieldGroupsJSON
{
    self.fieldGroups = [NSMutableDictionary dictionary];
    
    for (NSString *groupId in [fieldGroupsJSON allKeys])
    {
        NSDictionary *fieldGroupJSON = fieldGroupsJSON[groupId];
        self.fieldGroups[groupId] = [self parseFieldGroup:fieldGroupJSON];
    }
}

- (AlfrescoFieldGroupConfig *)parseFieldGroup:(NSDictionary *)fieldGroupJSON
{
    // key mappings for field group config -> field group config model object
    NSDictionary *keyMappings = @{kAlfrescoJSONIdentifier: kAlfrescoBaseConfigPropertyIdentifier,
                                  kAlfrescoJSONLabelId: kAlfrescoBaseConfigPropertyLabel,
                                  kAlfrescoJSONDescriptionId: kAlfrescoBaseConfigPropertySummary,
                                  kAlfrescoJSONIconId: kAlfrescoItemConfigPropertyIconIdentifier,
                                  kAlfrescoJSONModelId: kAlfrescoFieldConfigPropertyModelIdentifier};
    
    // build an array object representing the fields
    NSMutableArray *itemsArray = [NSMutableArray array];
    NSArray *itemsJSON = fieldGroupJSON[kAlfrescoJSONItems];
    for (NSDictionary *itemJSON in itemsJSON)
    {
        NSString *itemType = itemJSON[kAlfrescoJSONItemType];
        if ([itemType isEqualToString:kAlfrescoJSONFieldId])
        {
            NSString *fieldId = itemJSON[kAlfrescoJSONFieldId];
            [itemsArray addObject:self.fields[fieldId]];
        }
        else if ([itemType isEqualToString:kAlfrescoJSONField])
        {
            NSDictionary *fieldJSON = itemJSON[kAlfrescoJSONField];
            
            NSDictionary *fieldConfigProperties = [AlfrescoObjectConverter dictionaryFromDictionary:fieldJSON
                                                                                    withMappedKeys:keyMappings];
            [itemsArray addObject:[[AlfrescoFieldConfig alloc] initWithDictionary:fieldConfigProperties]];
        }
    }
    
    // build the field group object
    NSMutableDictionary *amendedFieldGroupJSON = [NSMutableDictionary dictionaryWithDictionary:fieldGroupJSON];
    amendedFieldGroupJSON[kAlfrescoJSONItems] = itemsArray;
    NSDictionary *fieldGroupProperties = [AlfrescoObjectConverter dictionaryFromDictionary:amendedFieldGroupJSON
                                                                            withMappedKeys:keyMappings];
    AlfrescoFieldGroupConfig *fieldGroup = [[AlfrescoFieldGroupConfig alloc] initWithDictionary:fieldGroupProperties];
    
    return fieldGroup;
}

- (void)parseForms:(NSArray *)formsJSON
{
    NSDictionary *keyMappings = @{kAlfrescoJSONIdentifier: kAlfrescoBaseConfigPropertyIdentifier,
                                  kAlfrescoJSONLabelId: kAlfrescoBaseConfigPropertyLabel,
                                  kAlfrescoJSONDescriptionId: kAlfrescoBaseConfigPropertySummary,
                                  kAlfrescoJSONIconId: kAlfrescoItemConfigPropertyIconIdentifier};
    
    NSMutableArray *formsArray = [NSMutableArray array];
    for (NSDictionary *formJSON in formsJSON)
    {
    
        // build an array representing the items
        NSMutableArray *itemsArray = [NSMutableArray array];
        NSArray *itemsJSON = formJSON[kAlfrescoJSONItems];
        for (NSDictionary *itemJSON in itemsJSON)
        {
            NSString *itemType = itemJSON[kAlfrescoJSONItemType];
            if ([itemType isEqualToString:kAlfrescoJSONFieldGroupId])
            {
                NSString *fieldGroupId = itemJSON[kAlfrescoJSONFieldGroupId];
                [itemsArray addObject:fieldGroupId];
            }
            else if ([itemType isEqualToString:kAlfrescoJSONField])
            {
                NSString *fieldId = itemJSON[kAlfrescoJSONFieldId];
                [itemsArray addObject:self.fields[fieldId]];
            }
            else if ([itemType isEqualToString:kAlfrescoJSONField])
            {
                NSDictionary *fieldJSON = itemJSON[kAlfrescoJSONField];
                
                NSDictionary *fieldConfigProperties = [AlfrescoObjectConverter dictionaryFromDictionary:fieldJSON
                                                                                         withMappedKeys:keyMappings];
                [itemsArray addObject:[[AlfrescoFieldConfig alloc] initWithDictionary:fieldConfigProperties]];
            }
        }
        
        // build and add the form object
        NSMutableDictionary *amendedFormJSON = [NSMutableDictionary dictionaryWithDictionary:formJSON];
        amendedFormJSON[kAlfrescoJSONItems] = itemsArray;
        NSDictionary *formProperties = [AlfrescoObjectConverter dictionaryFromDictionary:amendedFormJSON
                                                                                withMappedKeys:keyMappings];
        AlfrescoFormConfig *form = [[AlfrescoFormConfig alloc] initWithDictionary:formProperties];
        [formsArray addObject:form];
    }
    
    self.forms = formsArray;
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
    return [self retrieveFeatureConfigWithConfigScope:self.defaultConfigScope completionBlock:completionBlock];
}


- (AlfrescoRequest *)retrieveFeatureConfigWithConfigScope:(AlfrescoConfigScope *)scope
                                          completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
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


- (AlfrescoRequest *)retrieveFeatureConfigWithIdentifier:(NSString *)identifier
                                         completionBlock:(AlfrescoFeatureConfigCompletionBlock)completionBlock
{
    return [self retrieveFeatureConfigWithIdentifier:identifier scope:self.defaultConfigScope completionBlock:completionBlock];
}


- (AlfrescoRequest *)retrieveFeatureConfigWithIdentifier:(NSString *)identifier
                                                   scope:(AlfrescoConfigScope *)scope
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

- (AlfrescoRequest *)retrieveViewConfigWithIdentifier:(NSString *)identifier
                                      completionBlock:(AlfrescoViewConfigCompletionBlock)completionBlock
{
    return [self retrieveViewConfigWithIdentifier:identifier scope:self.defaultConfigScope completionBlock:completionBlock];
}

- (AlfrescoRequest *)retrieveViewConfigWithIdentifier:(NSString *)identifier
                                                scope:(AlfrescoConfigScope *)scope
                                      completionBlock:(AlfrescoViewConfigCompletionBlock)completionBlock
{
    return [self initializeInternalStateWithCompletionBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            completionBlock(self.views[identifier], nil);
        }
        else
        {
            completionBlock(nil, error);
        }
    }];
}


- (AlfrescoRequest *)retrieveViewGroupConfigWithIdentifier:(NSString *)identifier
                                           completionBlock:(AlfrescoViewGroupConfigCompletionBlock)completionBlock
{
    return [self retrieveViewGroupConfigWithIdentifier:identifier scope:self.defaultConfigScope completionBlock:completionBlock];
}


- (AlfrescoRequest *)retrieveViewGroupConfigWithIdentifier:(NSString *)identifier
                                                     scope:(AlfrescoConfigScope *)scope
                                           completionBlock:(AlfrescoViewGroupConfigCompletionBlock)completionBlock
{
    return [self initializeInternalStateWithCompletionBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            AlfrescoViewGroupConfig *requestedViewGroupConfig = self.viewGroups[identifier];
            
            if (requestedViewGroupConfig != nil)
            {
                completionBlock(requestedViewGroupConfig, nil);
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

- (AlfrescoRequest *)retrieveActionConfigWithIdentifier:(NSString *)identifier
                                        completionBlock:(AlfrescoActionConfigCompletionBlock)completionBlock
{
    return [self retrieveActionConfigWithIdentifier:identifier scope:self.defaultConfigScope completionBlock:completionBlock];
}


- (AlfrescoRequest *)retrieveActionConfigWithIdentifier:(NSString *)identifier
                                                  scope:(AlfrescoConfigScope *)scope
                                        completionBlock:(AlfrescoActionConfigCompletionBlock)completionBlock
{
    completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeConfig reason:@"Method Not Implemented"]);
    return nil;
}

- (AlfrescoRequest *)retrieveActionGroupConfigWithIdentifier:(NSString *)identifier
                                             completionBlock:(AlfrescoActionGroupConfigCompletionBlock)completionBlock
{
    return [self retrieveActionGroupConfigWithIdentifier:identifier scope:self.defaultConfigScope completionBlock:completionBlock];
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
    return [self retrieveFormConfigWithIdentifier:identifier scope:self.defaultConfigScope completionBlock:completionBlock];
}


- (AlfrescoRequest *)retrieveFormConfigWithIdentifier:(NSString *)identifier
                                                scope:(AlfrescoConfigScope *)scope
                                      completionBlock:(AlfrescoFormConfigCompletionBlock)completionBlock
{
    return [self initializeInternalStateWithCompletionBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            AlfrescoFormConfig *requestedFormConfig = nil;
            for (AlfrescoFormConfig *formConfig in self.forms)
            {
                if ([formConfig.identifier isEqualToString:identifier])
                {
                    requestedFormConfig = formConfig;
                    break;
                }
            }
            
            if (requestedFormConfig != nil)
            {
                // the items array needs resolving as there's likely to be group references
                // which can only be resolved within the context of a node
                AlfrescoNode *node = [scope valueForKey:kAlfrescoConfigScopeContextNode];
                NSString *typeLookup = [NSString stringWithFormat:@"type:%@", node.type];
                
                // FIXME: re-build the itemsArray using the resolved groups
                NSMutableArray *resolvedItems = [NSMutableArray array];
                for (id item in requestedFormConfig.items)
                {
                    if ([item isKindOfClass:[NSString class]])
                    {
                        NSString *fieldGroupId = (NSString *)item;
                        if ([fieldGroupId isEqualToString:@"${type-properties}"])
                        {
                            AlfrescoFieldGroupConfig *config = self.fieldGroups[typeLookup];
                            if (config != nil)
                            {
                                [resolvedItems addObject:config];
                            }
                        }
                        else if ([fieldGroupId isEqualToString:@"${aspects}"])
                        {
                            for (NSString *aspectName in node.aspects)
                            {
                                NSString *aspectLookup = [NSString stringWithFormat:@"aspect:%@", aspectName];
                                AlfrescoFieldGroupConfig *config = self.fieldGroups[aspectLookup];
                                if (config != nil)
                                {
                                    [resolvedItems addObject:config];
                                }
                            }
                        }
                        else
                        {
                            AlfrescoFieldGroupConfig *config = self.fieldGroups[fieldGroupId];
                            if (config != nil)
                            {
                                [resolvedItems addObject:config];
                            }
                        }
                    }
                    else
                    {
                        [resolvedItems addObject:item];
                    }
                }
                
                // replace the items array on the config object
                SEL setItemsSelector = sel_registerName("setItems:");
                [requestedFormConfig performSelector:setItemsSelector withObject:resolvedItems];
                
                completionBlock(requestedFormConfig, nil);
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


- (AlfrescoRequest *)retrieveWorkflowConfigWithCompletionBlock:(AlfrescoWorkflowConfigCompletionBlock)completionBlock
{
    return [self retrieveWorkflowConfigWithConfigScope:self.defaultConfigScope completionBlock:completionBlock];
}


- (AlfrescoRequest *)retrieveWorkflowConfigWithConfigScope:(AlfrescoConfigScope *)scope
                                           completionBlock:(AlfrescoWorkflowConfigCompletionBlock)completionBlock
{
    completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeConfig reason:@"Method Not Implemented"]);
    return nil;
}


- (AlfrescoRequest *)retrieveCreationConfigWithCompletionBlock:(AlfrescoCreationConfigCompletionBlock)completionBlock
{
    return [self retrieveCreationConfigWithConfigScope:self.defaultConfigScope completionBlock:completionBlock];
}


- (AlfrescoRequest *)retrieveCreationConfigWithConfigScope:(AlfrescoConfigScope *)scope
                                           completionBlock:(AlfrescoCreationConfigCompletionBlock)completionBlock
{
    return [self initializeInternalStateWithCompletionBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            completionBlock(self.creation, nil);
        }
        else
        {
            completionBlock(nil, error);
        }
    }];
}


- (AlfrescoRequest *)retrieveSearchConfigWithCompletionBlock:(AlfrescoSearchConfigCompletionBlock)completionBlock
{
    return [self retrieveSearchConfigWithConfigScope:self.defaultConfigScope completionBlock:completionBlock];
}


- (AlfrescoRequest *)retrieveSearchConfigWithConfigScope:(AlfrescoConfigScope *)scope
                                         completionBlock:(AlfrescoSearchConfigCompletionBlock)completionBlock
{
    completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeConfig reason:@"Method Not Implemented"]);
    return nil;
}

@end
