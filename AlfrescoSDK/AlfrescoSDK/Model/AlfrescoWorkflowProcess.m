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

/** The AlfrescoWorkflowProcess model object
 
 Author: Tauseef Mughal (Alfresco)
 */

#import "AlfrescoWorkflowProcess.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoSession.h"
#import "AlfrescoWorkflowUtils.h"
#import "AlfrescoWorkflowObjectConverter.h"
#import "AlfrescoWorkflowVariable.h"

static NSInteger kWorkflowProcessModelVersion = 1;

@interface AlfrescoWorkflowProcess ()

@property (nonatomic, weak, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSDateFormatter *dateFormatter;
@property (nonatomic, strong, readwrite) NSString *identifier;
@property (nonatomic, strong, readwrite) NSString *processDefinitionIdentifier;
@property (nonatomic, strong, readwrite) NSString *processDefinitionKey;
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSDate *startedAt;
@property (nonatomic, strong, readwrite) NSDate *endedAt;
@property (nonatomic, strong, readwrite) NSDate *dueAt;
@property (nonatomic, strong, readwrite) NSNumber *priority;
@property (nonatomic, strong, readwrite) NSString *processDescription;
@property (nonatomic, strong, readwrite) NSString *initiatorUsername;
@property (nonatomic, strong, readwrite) NSArray *variables;

@end

@implementation AlfrescoWorkflowProcess

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

#pragma mark - Private Functions

- (void)setupProperties:(NSDictionary *)properties
{
    if (self.session.workflowInfo.publicAPI)
    {
        NSDictionary *entry = properties[kAlfrescoWorkflowPublicJSONEntry];
        
        AlfrescoWorkflowObjectConverter *objectConverter = [[AlfrescoWorkflowObjectConverter alloc] init];
        NSArray *rawVariables = entry[kAlfrescoWorkflowPublicJSONProcessVariables];
        NSArray *convertedVariables = [objectConverter workflowVariablesFromArray:rawVariables];
        
        self.identifier = entry[kAlfrescoWorkflowPublicJSONIdentifier];
        self.processDefinitionIdentifier = entry[kAlfrescoWorkflowPublicJSONProcessDefinitionID];
        self.processDefinitionKey = entry[kAlfrescoWorkflowPublicJSONProcessDefinitionKey];
        if (convertedVariables)
        {
            NSInteger indexOfTitleVariableObject = [[convertedVariables valueForKey:@"name"] indexOfObject:kAlfrescoWorkflowPublicBPMJSONProcessTitle];
            AlfrescoWorkflowVariable *titleVariable = convertedVariables[indexOfTitleVariableObject];
            if (titleVariable.value != [NSNull null])
            {
                self.name = (NSString *)titleVariable.value;
            }
        }
        self.startedAt = [self.dateFormatter dateFromString:entry[kAlfrescoWorkflowPublicJSONStartedAt]];
        self.endedAt = [self.dateFormatter dateFromString:entry[kAlfrescoWorkflowPublicJSONEndedAt]];
        self.dueAt = [self.dateFormatter dateFromString:entry[kAlfrescoWorkflowPublicJSONDueAt]];
        self.processDescription = entry[kAlfrescoWorkflowPublicJSONDescription];
        self.priority = entry[kAlfrescoWorkflowPublicJSONPriority];
        self.initiatorUsername = entry[kAlfrescoWorkflowPublicJSONStartUserID];
        self.variables = convertedVariables;
    }
    else
    {
        NSString *workflowEnginePrefix = [AlfrescoWorkflowUtils prefixForActivitiEngineType:self.session.workflowInfo.workflowEngine];
        self.identifier = [properties[kAlfrescoWorkflowPublicJSONIdentifier] stringByReplacingOccurrencesOfString:workflowEnginePrefix withString:@""];
        self.processDefinitionIdentifier = [[properties[kAlfrescoWorkflowLegacyJSONProcessDefinitionID] lastPathComponent] stringByReplacingOccurrencesOfString:workflowEnginePrefix withString:@""];
        self.processDefinitionKey = [properties[kAlfrescoWorkflowLegacyJSONName] stringByReplacingOccurrencesOfString:workflowEnginePrefix withString:@""];
        if (properties[kAlfrescoWorkflowLegacyJSONMessage] != [NSNull null])
        {
            self.name = properties[kAlfrescoWorkflowLegacyJSONMessage];
        }
        if (properties[kAlfrescoWorkflowLegacyJSONStartedAt] != [NSNull null])
        {
            self.startedAt = [self.dateFormatter dateFromString:properties[kAlfrescoWorkflowLegacyJSONStartedAt]];
        }
        if (properties[kAlfrescoWorkflowLegacyJSONEndedAt] != [NSNull null])
        {
            self.endedAt = [self.dateFormatter dateFromString:properties[kAlfrescoWorkflowLegacyJSONEndedAt]];
        }
        if (properties[kAlfrescoWorkflowLegacyJSONDueAt] != [NSNull null])
        {
            self.dueAt = [self.dateFormatter dateFromString:properties[kAlfrescoWorkflowLegacyJSONDueAt]];
        }
        self.processDescription = properties[kAlfrescoWorkflowLegacyJSONDescription];
        self.priority = properties[kAlfrescoWorkflowLegacyJSONPriority];
        NSDictionary *initiatorDictionary = properties[kAlfrescoWorkflowLegacyJSONInitiator];
        self.initiatorUsername = initiatorDictionary[kAlfrescoJSONUserName];
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:kWorkflowProcessModelVersion forKey:NSStringFromClass([self class])];
    [aCoder encodeObject:self.identifier forKey:kAlfrescoWorkflowPublicJSONIdentifier];
    [aCoder encodeObject:self.processDefinitionIdentifier forKey:kAlfrescoWorkflowPublicJSONProcessDefinitionID];
    [aCoder encodeObject:self.processDefinitionKey forKey:kAlfrescoWorkflowPublicJSONProcessDefinitionKey];
    [aCoder encodeObject:self.name forKey:kAlfrescoWorkflowPublicBPMJSONProcessTitle];
    [aCoder encodeObject:self.startedAt forKey:kAlfrescoWorkflowPublicJSONStartedAt];
    [aCoder encodeObject:self.endedAt forKey:kAlfrescoWorkflowPublicJSONEndedAt];
    [aCoder encodeObject:self.dueAt forKey:kAlfrescoWorkflowPublicJSONDueAt];
    [aCoder encodeObject:self.processDescription forKey:kAlfrescoWorkflowPublicJSONDescription];
    [aCoder encodeObject:self.priority forKey:kAlfrescoWorkflowPublicJSONPriority];
    [aCoder encodeObject:self.initiatorUsername forKey:kAlfrescoWorkflowPublicJSONStartUserID];
    [aCoder encodeObject:self.variables forKey:kAlfrescoWorkflowPublicJSONProcessVariables];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        //        NSInteger version = [aDecoder decodeIntegerForKey:NSStringFromClass([self class])];
        self.identifier = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONIdentifier];
        self.processDefinitionIdentifier = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONProcessDefinitionID];
        self.processDefinitionKey = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONProcessDefinitionKey];
        self.name = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicBPMJSONProcessTitle];
        self.startedAt = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONStartedAt];
        self.endedAt = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONEndedAt];
        self.dueAt = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONDueAt];
        self.processDescription = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONDescription];
        self.priority = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONPriority];
        self.initiatorUsername = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONStartUserID];
        self.variables = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONProcessVariables];
    }
    return self;
}

@end
