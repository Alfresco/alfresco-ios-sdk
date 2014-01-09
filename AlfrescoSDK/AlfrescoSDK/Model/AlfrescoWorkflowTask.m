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
        self.identifier = [entry objectForKey:kAlfrescoPublicJSONIdentifier];
        self.processIdentifier = [entry objectForKey:kAlfrescoPublicJSONProcessID];
        self.processDefinitionIdentifier = [entry objectForKey:kAlfrescoPublicJSONProcessDefinitionID];
        self.startedAt = [self.dateFormatter dateFromString:[entry objectForKey:kAlfrescoPublicJSONStartedAt]];
        self.endedAt = [self.dateFormatter dateFromString:[entry objectForKey:kAlfrescoPublicJSONEndedAt]];
        self.dueAt = [self.dateFormatter dateFromString:[entry objectForKey:kAlfrescoPublicJSONDueAt]];
        self.taskDescription = [entry objectForKey:kAlfrescoPublicJSONDescription];
        self.priority = [entry objectForKey:kAlfrescoPublicJSONPriority];
        self.assigneeIdentifier = [entry objectForKey:kAlfrescoPublicJSONAssignee];
    }
    else
    {
        NSDictionary *taskProperties = [properties objectForKey:kAlfrescoLegacyJSONProperties];
        NSDictionary *workflowInstance = [properties objectForKey:kAlfrescoLegacyJSONWorkflowInstance];
        
        NSString *workflowEnginePrefix = [AlfrescoWorkflowUtils prefixForActivitiEngineType:self.session.workflowInfo.workflowEngine];
        
        if ([[taskProperties objectForKey:kAlfrescoLegacyJSONBPMTaskID] isKindOfClass:[NSNumber class]])
        {
            self.identifier = [[taskProperties objectForKey:kAlfrescoLegacyJSONBPMTaskID] stringValue];
        }
        else
        {
            self.identifier = [taskProperties objectForKey:kAlfrescoLegacyJSONBPMTaskID];
        }
        self.processIdentifier = [[workflowInstance objectForKey:kAlfrescoLegacyJSONIdentifier] stringByReplacingOccurrencesOfString:workflowEnginePrefix withString:@""];
        self.processDefinitionIdentifier = [[workflowInstance objectForKey:kAlfrescoLegacyJSONName] stringByReplacingOccurrencesOfString:workflowEnginePrefix withString:@""];
        if ([taskProperties objectForKey:kAlfrescoLegacyJSONBPMStartedAt] != [NSNull null])
        {
            self.startedAt = [self.dateFormatter dateFromString:[taskProperties objectForKey:kAlfrescoLegacyJSONBPMStartedAt]];
        }
        if ([taskProperties objectForKey:kAlfrescoLegacyJSONBPMEndedAt] != [NSNull null])
        {
            self.endedAt = [self.dateFormatter dateFromString:[taskProperties objectForKey:kAlfrescoLegacyJSONBPMEndedAt]];
        }
        if ([taskProperties objectForKey:kAlfrescoLegacyJSONBPMDueAt] != [NSNull null])
        {
            self.dueAt = [self.dateFormatter dateFromString:[taskProperties objectForKey:kAlfrescoLegacyJSONBPMDueAt]];
        }
        self.taskDescription = [taskProperties objectForKey:kAlfrescoLegacyJSONBPMDescription];
        self.priority = [taskProperties objectForKey:kAlfrescoLegacyJSONBPMPriority];
        if ([taskProperties objectForKey:kAlfrescoLegacyJSONOwner] != [NSNull null])
        {
            self.assigneeIdentifier = [taskProperties objectForKey:kAlfrescoLegacyJSONOwner];
        }
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:kWorkflowTaskModelVersion forKey:NSStringFromClass([self class])];
    [aCoder encodeObject:self.identifier forKey:kAlfrescoPublicJSONIdentifier];
    [aCoder encodeObject:self.processIdentifier forKey:kAlfrescoPublicJSONProcessID];
    [aCoder encodeObject:self.processDefinitionIdentifier forKey:kAlfrescoPublicJSONProcessDefinitionID];
    [aCoder encodeObject:self.startedAt forKey:kAlfrescoPublicJSONStartedAt];
    [aCoder encodeObject:self.endedAt forKey:kAlfrescoPublicJSONEndedAt];
    [aCoder encodeObject:self.dueAt forKey:kAlfrescoPublicJSONDueAt];
    [aCoder encodeObject:self.taskDescription forKey:kAlfrescoPublicJSONDescription];
    [aCoder encodeObject:self.priority forKey:kAlfrescoPublicJSONPriority];
    [aCoder encodeObject:self.assigneeIdentifier forKey:kAlfrescoPublicJSONAssignee];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
//        NSInteger version = [aDecoder decodeIntegerForKey:NSStringFromClass([self class])];
        self.identifier = [aDecoder decodeObjectForKey:kAlfrescoPublicJSONIdentifier];
        self.processIdentifier = [aDecoder decodeObjectForKey:kAlfrescoPublicJSONProcessID];
        self.processDefinitionIdentifier = [aDecoder decodeObjectForKey:kAlfrescoPublicJSONProcessDefinitionID];
        self.startedAt = [aDecoder decodeObjectForKey:kAlfrescoPublicJSONStartedAt];
        self.endedAt = [aDecoder decodeObjectForKey:kAlfrescoPublicJSONEndedAt];
        self.dueAt = [aDecoder decodeObjectForKey:kAlfrescoPublicJSONDueAt];
        self.taskDescription = [aDecoder decodeObjectForKey:kAlfrescoPublicJSONDescription];
        self.priority = [aDecoder decodeObjectForKey:kAlfrescoPublicJSONPriority];
        self.assigneeIdentifier = [aDecoder decodeObjectForKey:kAlfrescoPublicJSONAssignee];
    }
    return self;
}

@end
