/*
 ******************************************************************************
 * Copyright (C) 2005-2013 Alfresco Software Limited.
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
#import "AlfrescoSession.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoWorkflowUtils.h"

static NSInteger kWorkflowTaskModelVersion = 1;

@interface AlfrescoWorkflowTask ()

@property (nonatomic, weak, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSDateFormatter *dateFormatter;
@property (nonatomic, strong, readwrite) NSString *identifier;
@property (nonatomic, strong, readwrite) NSString *processIdentifier;
@property (nonatomic, strong, readwrite) NSString *processDefinitionIdentifier;
@property (nonatomic, strong, readwrite) NSDate *startedAt;
@property (nonatomic, strong, readwrite) NSDate *endedAt;
@property (nonatomic, strong, readwrite) NSDate *dueAt;
@property (nonatomic, strong, readwrite) NSString *taskDescription;
@property (nonatomic, strong, readwrite) NSNumber *priority;
@property (nonatomic, strong, readwrite) NSString *assigneeIdentifier;

@end

@implementation AlfrescoWorkflowTask

- (id)initWithProperties:(NSDictionary *)properties session:(id<AlfrescoSession>)session
{
    self = [super init];
    if (self)
    {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:kAlfrescoISO8601DateStringFormat];
        self.session = session;
        [self setupProperties:properties];
    }
    return self;
}

- (void)setupProperties:(NSDictionary *)properties
{
    if (self.session.workflowInfo.publicAPI)
    {
        NSDictionary *entry = [properties objectForKey:kAlfrescoCloudJSONEntry];
        self.identifier = [entry objectForKey:kAlfrescoWorkflowPublicJSONIdentifier];
        self.processIdentifier = [entry objectForKey:kAlfrescoWorkflowPublicJSONProcessID];
        self.processDefinitionIdentifier = [entry objectForKey:kAlfrescoWorkflowPublicJSONProcessDefinitionID];
        self.startedAt = [self.dateFormatter dateFromString:[entry objectForKey:kAlfrescoWorkflowPublicJSONStartedAt]];
        self.endedAt = [self.dateFormatter dateFromString:[entry objectForKey:kAlfrescoWorkflowPublicJSONEndedAt]];
        self.dueAt = [self.dateFormatter dateFromString:[entry objectForKey:kAlfrescoWorkflowPublicJSONDueAt]];
        self.taskDescription = [entry objectForKey:kAlfrescoWorkflowPublicJSONDescription];
        self.priority = [entry objectForKey:kAlfrescoWorkflowPublicJSONPriority];
        self.assigneeIdentifier = [entry objectForKey:kAlfrescoWorkflowPublicJSONAssignee];
    }
    else
    {
        NSDictionary *taskProperties = [properties objectForKey:kAlfrescoWorkflowLegacyJSONProperties];
        NSDictionary *workflowInstance = [properties objectForKey:kAlfrescoWorkflowLegacyJSONWorkflowInstance];
        
        NSString *workflowEnginePrefix = [AlfrescoWorkflowUtils prefixForActivitiEngineType:self.session.workflowInfo.workflowEngine];
        
        if ([[taskProperties objectForKey:kAlfrescoWorkflowLegacyJSONBPMTaskID] isKindOfClass:[NSNumber class]])
        {
            self.identifier = [[taskProperties objectForKey:kAlfrescoWorkflowLegacyJSONBPMTaskID] stringValue];
        }
        else
        {
            self.identifier = [taskProperties objectForKey:kAlfrescoWorkflowLegacyJSONBPMTaskID];
        }
        self.processIdentifier = [[workflowInstance objectForKey:kAlfrescoWorkflowLegacyJSONIdentifier] stringByReplacingOccurrencesOfString:workflowEnginePrefix withString:@""];
        self.processDefinitionIdentifier = [[workflowInstance objectForKey:kAlfrescoWorkflowLegacyJSONName] stringByReplacingOccurrencesOfString:workflowEnginePrefix withString:@""];
        if ([taskProperties objectForKey:kAlfrescoWorkflowLegacyJSONBPMStartedAt] != [NSNull null])
        {
            self.startedAt = [self.dateFormatter dateFromString:[taskProperties objectForKey:kAlfrescoWorkflowLegacyJSONBPMStartedAt]];
        }
        if ([taskProperties objectForKey:kAlfrescoWorkflowLegacyJSONBPMEndedAt] != [NSNull null])
        {
            self.endedAt = [self.dateFormatter dateFromString:[taskProperties objectForKey:kAlfrescoWorkflowLegacyJSONBPMEndedAt]];
        }
        if ([taskProperties objectForKey:kAlfrescoWorkflowLegacyJSONBPMDueAt] != [NSNull null])
        {
            self.dueAt = [self.dateFormatter dateFromString:[taskProperties objectForKey:kAlfrescoWorkflowLegacyJSONBPMDueAt]];
        }
        self.taskDescription = [taskProperties objectForKey:kAlfrescoWorkflowLegacyJSONBPMDescription];
        self.priority = [taskProperties objectForKey:kAlfrescoWorkflowLegacyJSONBPMPriority];
        if ([taskProperties objectForKey:kAlfrescoWorkflowLegacyJSONOwner] != [NSNull null])
        {
            self.assigneeIdentifier = [taskProperties objectForKey:kAlfrescoWorkflowLegacyJSONOwner];
        }
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:kWorkflowTaskModelVersion forKey:NSStringFromClass([self class])];
    [aCoder encodeObject:self.identifier forKey:kAlfrescoWorkflowPublicJSONIdentifier];
    [aCoder encodeObject:self.processIdentifier forKey:kAlfrescoWorkflowPublicJSONProcessID];
    [aCoder encodeObject:self.processDefinitionIdentifier forKey:kAlfrescoWorkflowPublicJSONProcessDefinitionID];
    [aCoder encodeObject:self.startedAt forKey:kAlfrescoWorkflowPublicJSONStartedAt];
    [aCoder encodeObject:self.endedAt forKey:kAlfrescoWorkflowPublicJSONEndedAt];
    [aCoder encodeObject:self.dueAt forKey:kAlfrescoWorkflowPublicJSONDueAt];
    [aCoder encodeObject:self.taskDescription forKey:kAlfrescoWorkflowPublicJSONDescription];
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
        self.startedAt = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONStartedAt];
        self.endedAt = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONEndedAt];
        self.dueAt = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONDueAt];
        self.taskDescription = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONDescription];
        self.priority = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONPriority];
        self.assigneeIdentifier = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONAssignee];
    }
    return self;
}

@end
