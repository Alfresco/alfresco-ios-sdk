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
#import "AlfrescoConstants.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoProperty.h"
#import "AlfrescoWorkflowObjectConverter.h"

static NSInteger kWorkflowProcessModelVersion = 1;

@interface AlfrescoWorkflowProcess ()

@property (nonatomic, strong, readwrite) NSDateFormatter *dateFormatter;
@property (nonatomic, strong, readwrite) NSString *identifier;
@property (nonatomic, strong, readwrite) NSString *processDefinitionIdentifier;
@property (nonatomic, strong, readwrite) NSString *processDefinitionKey;
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSDate *startedAt;
@property (nonatomic, strong, readwrite) NSDate *endedAt;
@property (nonatomic, strong, readwrite) NSDate *dueAt;
@property (nonatomic, strong, readwrite) NSNumber *priority;
@property (nonatomic, strong, readwrite) NSString *summary;
@property (nonatomic, strong, readwrite) NSString *initiatorUsername;
@property (nonatomic, strong, readwrite) NSDictionary *variables;

@end

@implementation AlfrescoWorkflowProcess

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

#pragma mark - Private Functions

- (void)setupProperties:(NSDictionary *)properties
{
    NSDictionary *entry = properties[kAlfrescoWorkflowPublicJSONEntry];
    
    AlfrescoWorkflowObjectConverter *objectConverter = [[AlfrescoWorkflowObjectConverter alloc] init];
    
    // if the entry object is present the data has come from the public API
    if (entry != nil)
    {
        NSArray *rawVariables = entry[kAlfrescoWorkflowPublicJSONProcessVariables];
        NSDictionary *convertedVariables = [objectConverter workflowVariablesFromArray:rawVariables];
        
        self.identifier = entry[kAlfrescoWorkflowPublicJSONIdentifier];
        self.processDefinitionIdentifier = entry[kAlfrescoWorkflowPublicJSONProcessDefinitionID];
        self.processDefinitionKey = entry[kAlfrescoWorkflowPublicJSONProcessDefinitionKey];
        if (convertedVariables)
        {
            [self setPropertiesFromVariables:convertedVariables];
        }
        self.startedAt = [self.dateFormatter dateFromString:entry[kAlfrescoWorkflowPublicJSONStartedAt]];
        self.endedAt = [self.dateFormatter dateFromString:entry[kAlfrescoWorkflowPublicJSONEndedAt]];
        self.initiatorUsername = entry[kAlfrescoWorkflowPublicJSONStartUserID];
        self.variables = convertedVariables;
    }
    else
    {
        self.identifier = properties[kAlfrescoWorkflowPublicJSONIdentifier];
        self.processDefinitionIdentifier = properties[kAlfrescoWorkflowLegacyJSONName];
        self.processDefinitionKey = properties[kAlfrescoWorkflowLegacyJSONName];
        if (properties[kAlfrescoWorkflowLegacyJSONMessage] != [NSNull null])
        {
            self.summary = properties[kAlfrescoWorkflowLegacyJSONMessage];
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
        self.name = properties[kAlfrescoWorkflowLegacyJSONTitle];
        self.priority = properties[kAlfrescoWorkflowLegacyJSONPriority];
        NSDictionary *initiatorDictionary = properties[kAlfrescoWorkflowLegacyJSONInitiator];
        self.initiatorUsername = initiatorDictionary[kAlfrescoJSONUserName];
        self.variables = [objectConverter workflowVariablesFromLegacyProperties:properties];
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:kWorkflowProcessModelVersion forKey:@"AlfrescoWorkflowProcess"];
    [aCoder encodeObject:self.identifier forKey:kAlfrescoWorkflowPublicJSONIdentifier];
    [aCoder encodeObject:self.processDefinitionIdentifier forKey:kAlfrescoWorkflowPublicJSONProcessDefinitionID];
    [aCoder encodeObject:self.processDefinitionKey forKey:kAlfrescoWorkflowPublicJSONProcessDefinitionKey];
    [aCoder encodeObject:self.name forKey:kAlfrescoWorkflowPublicBPMJSONProcessDescription];
    [aCoder encodeObject:self.startedAt forKey:kAlfrescoWorkflowPublicJSONStartedAt];
    [aCoder encodeObject:self.endedAt forKey:kAlfrescoWorkflowPublicJSONEndedAt];
    [aCoder encodeObject:self.dueAt forKey:kAlfrescoWorkflowPublicJSONDueAt];
    [aCoder encodeObject:self.summary forKey:kAlfrescoWorkflowPublicJSONDescription];
    [aCoder encodeObject:self.priority forKey:kAlfrescoWorkflowPublicJSONPriority];
    [aCoder encodeObject:self.initiatorUsername forKey:kAlfrescoWorkflowPublicJSONStartUserID];
    [aCoder encodeObject:self.variables forKey:kAlfrescoWorkflowPublicJSONProcessVariables];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        //        NSInteger version = [aDecoder decodeIntegerForKey:@"AlfrescoWorkflowProcess"];
        self.identifier = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONIdentifier];
        self.processDefinitionIdentifier = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONProcessDefinitionID];
        self.processDefinitionKey = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONProcessDefinitionKey];
        self.name = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicBPMJSONProcessDescription];
        self.startedAt = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONStartedAt];
        self.endedAt = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONEndedAt];
        self.dueAt = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONDueAt];
        self.summary = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONDescription];
        self.priority = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONPriority];
        self.initiatorUsername = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONStartUserID];
        self.variables = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONProcessVariables];
    }
    return self;
}

#pragma mark - Private Functions

- (void)setVariables:(NSDictionary *)variables
{
    _variables = variables;
    
    // If on public API, set the name variable.
    // No clean way to determine public or legacy API being used. Check to see if $ symbol exists.
    if (!self.name && [self.identifier rangeOfString:@"$"].location == NSNotFound)
    {
        [self setPropertiesFromVariables:variables];
    }
}

- (void)setPropertiesFromVariables:(NSDictionary *)variables
{
    AlfrescoProperty *titleVariable = variables[kAlfrescoWorkflowPublicBPMJSONProcessDescription];
    if (titleVariable.value != [NSNull null])
    {
        self.summary = (NSString *)titleVariable.value;
    }
    
    AlfrescoProperty *priorityVariable = variables[kAlfrescoWorkflowVariableProcessPriority];
    if (priorityVariable.value != [NSNull null])
    {
        self.priority = (NSNumber *)priorityVariable.value;
    }
    
    AlfrescoProperty *dueDateVariable = variables[kAlfrescoWorkflowVariableProcessDueDate];
    if (dueDateVariable.value != [NSNull null])
    {
        self.dueAt = (NSDate *)dueDateVariable.value;
    }
}

@end
