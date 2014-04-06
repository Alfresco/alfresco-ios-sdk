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

/** The AlfrescoWorkflowTask model object
 
 Author: Tauseef Mughal (Alfresco)
 */

#import "AlfrescoWorkflowTask.h"
#import "AlfrescoInternalConstants.h"

static NSInteger kWorkflowTaskModelVersion = 1;

@interface AlfrescoWorkflowTask ()

@property (nonatomic, strong, readwrite) NSDateFormatter *dateFormatter;
@property (nonatomic, strong, readwrite) NSString *identifier;
@property (nonatomic, strong, readwrite) NSString *processIdentifier;
@property (nonatomic, strong, readwrite) NSString *processDefinitionIdentifier;
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSDate *startedAt;
@property (nonatomic, strong, readwrite) NSDate *endedAt;
@property (nonatomic, strong, readwrite) NSDate *dueAt;
@property (nonatomic, strong, readwrite) NSString *summary;
@property (nonatomic, strong, readwrite) NSNumber *priority;
@property (nonatomic, strong, readwrite) NSString *assigneeIdentifier;

@end

@implementation AlfrescoWorkflowTask

- (id)initWithProperties:(NSDictionary *)properties
{
    self = [super init];
    if (self)
    {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:kAlfrescoISO8601DateStringFormat];
        [self setupProperties:properties];
    }
    return self;
}

- (void)setupProperties:(NSDictionary *)properties
{
    NSDictionary *entry = properties[kAlfrescoWorkflowPublicJSONEntry];
    
    // if the entry object is present the data has come from the public API
    if (entry != nil)
    {
        self.identifier = entry[kAlfrescoWorkflowPublicJSONIdentifier];
        self.processIdentifier = entry[kAlfrescoWorkflowPublicJSONProcessID];
        self.processDefinitionIdentifier = entry[kAlfrescoWorkflowPublicJSONProcessDefinitionID];
        self.name = entry[kAlfrescoWorkflowPublicJSONDescription];
        self.startedAt = [self.dateFormatter dateFromString:entry[kAlfrescoWorkflowPublicJSONStartedAt]];
        self.endedAt = [self.dateFormatter dateFromString:entry[kAlfrescoWorkflowPublicJSONEndedAt]];
        self.dueAt = [self.dateFormatter dateFromString:entry[kAlfrescoWorkflowPublicJSONDueAt]];
        self.summary = entry[kAlfrescoWorkflowPublicJSONName];
        self.priority = entry[kAlfrescoWorkflowPublicJSONPriority];
        self.assigneeIdentifier = entry[kAlfrescoWorkflowPublicJSONAssignee];
    }
    else
    {
        NSDictionary *taskProperties = properties[kAlfrescoWorkflowLegacyJSONProperties];
        NSDictionary *workflowInstance = properties[kAlfrescoWorkflowLegacyJSONWorkflowInstance];
        
        self.identifier = properties[kAlfrescoWorkflowLegacyJSONIdentifier];
        self.processIdentifier = workflowInstance[kAlfrescoWorkflowLegacyJSONIdentifier];
        self.processDefinitionIdentifier = workflowInstance[kAlfrescoWorkflowLegacyJSONName];
        self.name = taskProperties[kAlfrescoWorkflowLegacyJSONBPMDescription];
        if (taskProperties[kAlfrescoWorkflowLegacyJSONBPMStartedAt] != [NSNull null])
        {
            self.startedAt = [self.dateFormatter dateFromString:taskProperties[kAlfrescoWorkflowLegacyJSONBPMStartedAt]];
        }
        if (taskProperties[kAlfrescoWorkflowLegacyJSONBPMEndedAt] != [NSNull null])
        {
            self.endedAt = [self.dateFormatter dateFromString:taskProperties[kAlfrescoWorkflowLegacyJSONBPMEndedAt]];
        }
        if (taskProperties[kAlfrescoWorkflowLegacyJSONBPMDueAt] != [NSNull null])
        {
            self.dueAt = [self.dateFormatter dateFromString:taskProperties[kAlfrescoWorkflowLegacyJSONBPMDueAt]];
        }
        self.summary = taskProperties[kAlfrescoWorkflowLegacyJSONName];
        self.priority = taskProperties[kAlfrescoWorkflowLegacyJSONBPMPriority];
        if (taskProperties[kAlfrescoWorkflowLegacyJSONOwner] != [NSNull null])
        {
            self.assigneeIdentifier = taskProperties[kAlfrescoWorkflowLegacyJSONOwner];
        }
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:kWorkflowTaskModelVersion forKey:NSStringFromClass([self class])];
    [aCoder encodeObject:self.identifier forKey:kAlfrescoWorkflowPublicJSONIdentifier];
    [aCoder encodeObject:self.processIdentifier forKey:kAlfrescoWorkflowPublicJSONProcessID];
    [aCoder encodeObject:self.processDefinitionIdentifier forKey:kAlfrescoWorkflowPublicJSONProcessDefinitionID];
    [aCoder encodeObject:self.name forKey:kAlfrescoWorkflowPublicJSONDescription];
    [aCoder encodeObject:self.startedAt forKey:kAlfrescoWorkflowPublicJSONStartedAt];
    [aCoder encodeObject:self.endedAt forKey:kAlfrescoWorkflowPublicJSONEndedAt];
    [aCoder encodeObject:self.dueAt forKey:kAlfrescoWorkflowPublicJSONDueAt];
    [aCoder encodeObject:self.summary forKey:kAlfrescoWorkflowPublicJSONName];
    [aCoder encodeObject:self.priority forKey:kAlfrescoWorkflowPublicJSONPriority];
    [aCoder encodeObject:self.assigneeIdentifier forKey:kAlfrescoWorkflowPublicJSONAssignee];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        //        NSInteger version = [aDecoder decodeIntegerForKey:NSStringFromClass([self class])];
        self.identifier = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONIdentifier];
        self.processIdentifier = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONProcessID];
        self.processDefinitionIdentifier = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONProcessDefinitionID];
        self.name = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONDescription];
        self.startedAt = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONStartedAt];
        self.endedAt = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONEndedAt];
        self.dueAt = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONDueAt];
        self.summary = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONName];
        self.priority = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONPriority];
        self.assigneeIdentifier = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONAssignee];
    }
    return self;
}

@end
