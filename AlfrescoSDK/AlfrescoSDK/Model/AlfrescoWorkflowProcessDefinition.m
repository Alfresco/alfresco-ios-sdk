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

/** The AlfrescoWorkflowProcessDefinition model object
 
 Author: Tauseef Mughal (Alfresco)
 */

#import "AlfrescoWorkflowProcessDefinition.h"
#import "AlfrescoInternalConstants.h"

static NSInteger kWorkflowProcessDefinitionModelVersion = 1;

@interface AlfrescoWorkflowProcessDefinition ()

@property (nonatomic, strong, readwrite) NSString *identifier;
@property (nonatomic, strong, readwrite) NSString *key;
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSString *processDescription;
@property (nonatomic, strong, readwrite) NSNumber *version;

@end

@implementation AlfrescoWorkflowProcessDefinition

- (id)initWithProperties:(NSDictionary *)properties
{
    self = [super init];
    if (self)
    {
        [self setupProperties:properties];
    }
    return self;
}

#pragma mark - Private Functions

- (void)setupProperties:(NSDictionary *)properties
{
    NSDictionary *entry = properties[kAlfrescoWorkflowPublicJSONEntry];
    
    // if the entry object is present the data has come from the public API
    if (entry != nil)
    {
        self.identifier = entry[kAlfrescoWorkflowPublicJSONIdentifier];
        self.key = entry[kAlfrescoWorkflowPublicJSONKey];
        self.name = entry[kAlfrescoWorkflowPublicJSONTitle];
        self.processDescription = entry[kAlfrescoWorkflowPublicJSONDescription];
        self.version = entry[kAlfrescoWorkflowPublicJSONVersion];
    }
    else
    {
        self.identifier = properties[kAlfrescoJSONIdentifier];
        self.key = properties[kAlfrescoWorkflowLegacyJSONName];
        self.name = properties[kAlfrescoWorkflowLegacyJSONTitle];
        self.processDescription = properties[kAlfrescoWorkflowLegacyJSONDescription];
        self.version = properties[kAlfrescoWorkflowPublicJSONVersion];
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:kWorkflowProcessDefinitionModelVersion forKey:NSStringFromClass([self class])];
    [aCoder encodeObject:self.identifier forKey:kAlfrescoWorkflowPublicJSONIdentifier];
    [aCoder encodeObject:self.key forKey:kAlfrescoWorkflowPublicJSONKey];
    [aCoder encodeObject:self.name forKey:kAlfrescoWorkflowPublicJSONTitle];
    [aCoder encodeObject:self.processDescription forKey:kAlfrescoWorkflowPublicJSONDescription];
    [aCoder encodeObject:self.version forKey:kAlfrescoWorkflowPublicJSONVersion];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        //        NSInteger version = [aDecoder decodeIntegerForKey:NSStringFromClass([self class])];
        self.identifier = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONIdentifier];
        self.key = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONKey];
        self.name = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONTitle];
        self.processDescription = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONDescription];
        self.version = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONVersion];
    }
    return self;
}

@end
