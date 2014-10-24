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

/** AlfrescoWorkflowObjectConverter
 
 Author: Tauseef Mughal (Alfresco)
 */

#import "AlfrescoWorkflowObjectConverter.h"
#import "AlfrescoConstants.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoLog.h"
#import "AlfrescoProperty.h"
#import "AlfrescoWorkflowProcessDefinition.h"
#import "AlfrescoWorkflowProcess.h"
#import "AlfrescoWorkflowTask.h"
#import "AlfrescoWorkflowInternalConstants.h"
#import "CMISDateUtil.h"

@implementation AlfrescoWorkflowObjectConverter

- (NSArray *)workflowDefinitionsFromLegacyJSONData:(NSData *)jsonData conversionError:(NSError **)error
{
    return [[self class] parseJSONData:jsonData notFoundErrorCode:kAlfrescoErrorCodeWorkflowNoProcessDefinitionFound parseBlock:^id(id jsonObject, NSError *parseError) {
        if (parseError)
        {
            *error = parseError;
            return nil;
        }
        else
        {
            NSMutableArray *workflowDefinitions = [NSMutableArray array];
            id processDataResponseObject = [jsonObject valueForKey:kAlfrescoWorkflowLegacyJSONData];
            
            if ([processDataResponseObject isKindOfClass:[NSArray class]])
            {
                for (NSDictionary *entryDictionary in processDataResponseObject)
                {
                    [workflowDefinitions addObject:[[AlfrescoWorkflowProcessDefinition alloc] initWithProperties:entryDictionary]];
                }
            }
            else if ([processDataResponseObject isKindOfClass:[NSDictionary class]])
            {
                [workflowDefinitions addObject:[[AlfrescoWorkflowProcessDefinition alloc] initWithProperties:processDataResponseObject]];
            }
            return workflowDefinitions;
        }
    }];
}

- (NSArray *)workflowDefinitionsFromPublicJSONData:(NSData *)jsonData conversionError:(NSError **)error
{
    return [[self class] parseJSONData:jsonData notFoundErrorCode:kAlfrescoErrorCodeWorkflowNoProcessDefinitionFound parseBlock:^id(id jsonObject, NSError *parseError) {
        if (parseError)
        {
            *error = parseError;
            return nil;
        }
        else
        {
            NSMutableArray *workflowDefinitions = [NSMutableArray array];
            NSDictionary *listDictionary = [jsonObject valueForKey:kAlfrescoWorkflowPublicJSONList];
            NSArray *processArray = [listDictionary valueForKey:kAlfrescoWorkflowPublicJSONEntries];
            for (NSDictionary *entryDictionary in processArray)
            {
                [workflowDefinitions addObject:[[AlfrescoWorkflowProcessDefinition alloc] initWithProperties:entryDictionary]];
            }
            
            return workflowDefinitions;
        }
    }];
}

- (NSArray *)workflowProcessesFromLegacyJSONData:(NSData *)jsonData conversionError:(NSError **)error
{
    return [[self class] parseJSONData:jsonData notFoundErrorCode:kAlfrescoErrorCodeWorkflowNoProcessFound parseBlock:^id(id jsonObject, NSError *parseError) {
        if (parseError)
        {
            *error = parseError;
            return nil;
        }
        else
        {
            NSMutableArray *workflowProcesses = [NSMutableArray array];
            id processDataResponseObject = [jsonObject valueForKey:kAlfrescoWorkflowLegacyJSONData];
            
            if ([processDataResponseObject isKindOfClass:[NSArray class]])
            {
                for (NSDictionary *entryDictionary in processDataResponseObject)
                {
                    [workflowProcesses addObject:[[AlfrescoWorkflowProcess alloc] initWithProperties:entryDictionary]];
                }
            }
            else if ([processDataResponseObject isKindOfClass:[NSDictionary class]])
            {
                [workflowProcesses addObject:[[AlfrescoWorkflowProcess alloc] initWithProperties:processDataResponseObject]];
            }
            
            return workflowProcesses;
        }
    }];
}

- (NSArray *)workflowProcessesFromPublicJSONData:(NSData *)jsonData conversionError:(NSError **)error
{
    return [[self class] parseJSONData:jsonData notFoundErrorCode:kAlfrescoErrorCodeWorkflowNoProcessFound parseBlock:^id(id jsonObject, NSError *parseError) {
        if (parseError)
        {
            *error = parseError;
            return nil;
        }
        else
        {
            NSMutableArray *workflowProcesses = [NSMutableArray array];
            NSDictionary *listDictionary = [jsonObject valueForKey:kAlfrescoWorkflowPublicJSONList];
            
            if (listDictionary)
            {
                NSArray *processArray = [listDictionary valueForKey:kAlfrescoWorkflowPublicJSONEntries];
                for (NSDictionary *entryDictionary in processArray)
                {
                    [workflowProcesses addObject:[[AlfrescoWorkflowProcess alloc] initWithProperties:entryDictionary]];
                }
            }
            else
            {
                [workflowProcesses addObject:[[AlfrescoWorkflowProcess alloc] initWithProperties:jsonObject]];
            }
            
            return workflowProcesses;
        }
    }];
}

- (NSArray *)workflowTasksFromLegacyJSONData:(NSData *)jsonData conversionError:(NSError **)error
{
    return [[self class] parseJSONData:jsonData notFoundErrorCode:kAlfrescoErrorCodeWorkflowNoTaskFound parseBlock:^id(id jsonObject, NSError *parseError) {
        if (parseError)
        {
            *error = parseError;
            return nil;
        }
        else
        {
            NSMutableArray *workflowTasks = [NSMutableArray array];
            NSArray *processArray = [jsonObject valueForKey:kAlfrescoWorkflowLegacyJSONData];
            for (NSDictionary *entryDictionary in processArray)
            {
                [workflowTasks addObject:[[AlfrescoWorkflowTask alloc] initWithProperties:entryDictionary]];
            }
            return workflowTasks;
        }
    }];
}

- (NSArray *)workflowTasksFromLegacyJSONData:(NSData *)jsonData inState:(NSString *)state conversionError:(NSError **)error
{
    return [[self class] parseJSONData:jsonData notFoundErrorCode:kAlfrescoErrorCodeWorkflowNoTaskFound parseBlock:^id(id jsonObject, NSError *parseError) {
        if (parseError)
        {
            *error = parseError;
            return nil;
        }
        else
        {
            // determine filter
            BOOL shouldFilter = NO;
            NSPredicate *filterPredicate = nil;
            if ([state isEqualToString:kAlfrescoLegacyAPIWorkflowStatusInProgress])
            {
                filterPredicate = [NSPredicate predicateWithFormat:@"endedAt == nil"];
                shouldFilter = YES;
            }
            else if ([state isEqualToString:kAlfrescoLegacyAPIWorkflowStatusCompleted])
            {
                filterPredicate = [NSPredicate predicateWithFormat:@"endedAt != nil"];
                shouldFilter = YES;
            }
            
            NSMutableArray *workflowTasks = [NSMutableArray array];
            NSArray *tasksArray = (jsonObject[kAlfrescoWorkflowLegacyJSONData])[kAlfrescoWorkflowLegacyJSONTasks];
            for (NSDictionary *entryDictionary in tasksArray)
            {
                AlfrescoWorkflowTask *task = [[AlfrescoWorkflowTask alloc] initWithProperties:entryDictionary];
                [workflowTasks addObject:task];
            }
            
            if (shouldFilter)
            {
                [workflowTasks filteredArrayUsingPredicate:filterPredicate];
            }
            
            return workflowTasks;
        }
    }];
}

- (NSArray *)workflowTasksFromPublicJSONData:(NSData *)jsonData conversionError:(NSError **)error
{
    return [[self class] parseJSONData:jsonData notFoundErrorCode:kAlfrescoErrorCodeWorkflowNoTaskFound parseBlock:^id(id jsonObject, NSError *parseError) {
        if (parseError)
        {
            *error = parseError;
            return nil;
        }
        else
        {
            NSMutableArray *workflowTasks = [NSMutableArray array];
            NSDictionary *listDictionary = [jsonObject valueForKey:kAlfrescoWorkflowPublicJSONList];
            NSArray *processArray = [listDictionary valueForKey:kAlfrescoWorkflowPublicJSONEntries];
            for (NSDictionary *entryDictionary in processArray)
            {
                [workflowTasks addObject:[[AlfrescoWorkflowTask alloc] initWithProperties:entryDictionary]];
            }
            return workflowTasks;
        }
    }];
}

+ (NSString *)encodeVariableName:(NSString *)name
{
    // the workflow engine expects variable names to use underscores rather than colons
    return [name stringByReplacingOccurrencesOfString:@":" withString:@"_"];
}

+ (NSString *)decodeVariableName:(NSString *)name
{
    // variables are returned from the workflow engine with underscores replacing the colon
    // that separates the model prefix and property name. Replace just the first occurrence,
    // but NOT if it is the first character!
    
    NSString *decodedName = name;
    
    if (name)
    {
        // find first occurrence of _
        NSRange range = [name rangeOfString:@"_"];
        
        // if the string contains _ and it's not the first character replace with :
        if (range.length > 0 && range.location > 0)
        {
            decodedName = [name stringByReplacingCharactersInRange:range withString:@":"];
        }
    }
    
    return decodedName;
}

- (NSDictionary *)taskVariablesFromLegacyJSONData:(NSData *)jsonData conversionError:(NSError **)error
{
    return [[self class] parseJSONData:jsonData notFoundErrorCode:kAlfrescoErrorCodeWorkflowNoTaskFound parseBlock:^id(id jsonObject, NSError *parseError) {
        if (parseError)
        {
            *error = parseError;
            return nil;
        }
        else
        {
            NSMutableDictionary *processedVariables = [NSMutableDictionary dictionary];
            
            // retrieve the dictionary representing the properties
            NSDictionary *task = (NSDictionary *)jsonObject;
            NSString *propertiesKeyPath = [NSString stringWithFormat:@"%@.%@", kAlfrescoWorkflowLegacyJSONData, kAlfrescoWorkflowLegacyJSONProperties];
            NSDictionary *propertiesDictionary = [task valueForKeyPath:propertiesKeyPath];
            if (propertiesDictionary)
            {
                // convert the properties into AlfrescoProperty objects
                for (NSString *key in [propertiesDictionary allKeys])
                {
                    id value = propertiesDictionary[key];
                    
                    AlfrescoPropertyType propType = [self propertyTypeForVariableValue:value];
                    if (value != nil && value != [NSNull null])
                    {
                        // convert values if necessary
                        if (propType == AlfrescoPropertyTypeDate || propType == AlfrescoPropertyTypeDateTime)
                        {
                            value = [CMISDateUtil dateFromString:value];
                        }
                        
                        // construct the AlfrescoProperty object
                        NSDictionary *propertyDictionary = @{kAlfrescoPropertyType: @(propType),
                                                             kAlfrescoPropertyValue: value};
                        AlfrescoProperty *property = [[AlfrescoProperty alloc] initWithProperties:propertyDictionary];
                        
                        // store with decoded variable name
                        NSString *variableName = [AlfrescoWorkflowObjectConverter decodeVariableName:key];
                        processedVariables[variableName] = property;
                    }
                }
            }
            
            return processedVariables;
        }
    }];
}

- (NSDictionary *)variablesFromPublicJSONData:(NSData *)jsonData conversionError:(NSError **)error
{
    return [[self class] parseJSONData:jsonData notFoundErrorCode:kAlfrescoErrorCodeJSONParsing parseBlock:^id(id jsonObject, NSError *parseError) {
        if (parseError)
        {
            *error = parseError;
            return nil;
        }
        else
        {
            NSDictionary *listDictionary = jsonObject[kAlfrescoWorkflowPublicJSONList];
            NSArray *rawVariablesArray = listDictionary[kAlfrescoWorkflowPublicJSONEntries];
            NSMutableDictionary *workflowVariables = [NSMutableDictionary dictionaryWithCapacity:rawVariablesArray.count];
            for (NSDictionary *entry in rawVariablesArray)
            {
                NSDictionary *variableProperties = entry[kAlfrescoWorkflowPublicJSONEntry];
                
                NSString *name = variableProperties[kAlfrescoWorkflowPublicJSONVariableName];
                AlfrescoProperty *variable = [self propertyForDictionary:variableProperties];
                
                // decode the variable name so we return prefix:name format
                NSString *decodedName = [AlfrescoWorkflowObjectConverter decodeVariableName:name];
                
                // don't let global scoped variables replace local scoped ones
                if (workflowVariables[decodedName])
                {
                    NSString *scope = variableProperties[kAlfrescoWorkflowPublicJSONVariableScope];
                    if ([scope isEqualToString:kAlfrescoWorkflowPublicJSONVariableScopeLocal])
                    {
                        workflowVariables[decodedName] = variable;
                    }
                }
                else
                {
                    workflowVariables[decodedName] = variable;
                }
            }
            return workflowVariables;
        }
    }];
}

- (NSDictionary *)workflowVariablesFromArray:(NSArray *)variables
{
    NSMutableDictionary *variableDictionary = nil;
    if (variables)
    {
        variableDictionary = [NSMutableDictionary dictionaryWithCapacity:variables.count];
        
        for (NSDictionary *variableProperties in variables)
        {
            NSString *name = variableProperties[kAlfrescoWorkflowPublicJSONVariableName];
            AlfrescoProperty *variable = [self propertyForDictionary:variableProperties];

            // decode the variable name so we return prefix:name format
            NSString *decodedName = [AlfrescoWorkflowObjectConverter decodeVariableName:name];
            
            variableDictionary[decodedName] = variable;
        }
    }
    
    return variableDictionary;
}

- (NSString *)attachmentContainerNodeRefFromLegacyJSONData:(NSData *)jsonData conversionError:(NSError **)error
{
    return [[self class] parseJSONData:jsonData notFoundErrorCode:kAlfrescoErrorCodeJSONParsing parseBlock:^id(id jsonObject, NSError *parseError) {
        if (parseError)
        {
            *error = parseError;
            return nil;
        }
        else
        {
            NSString *containerRef = nil;
            if ([jsonObject isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *jsonResponseDictionary = (NSDictionary *)jsonObject;
                NSDictionary *processDictionary = [jsonResponseDictionary valueForKey:kAlfrescoJSONData];
                
                if (processDictionary)
                {
                    NSDictionary *taskProperties = processDictionary[kAlfrescoWorkflowLegacyJSONProperties];
                    containerRef = taskProperties[kAlfrescoWorkflowLegacyJSONBPMPackageContainer];
                }
            }
            else
            {
                AlfrescoLogDebug(@"Parsing response, should have returned a dictionary in selector - %@", NSStringFromSelector(_cmd));
            }
            return containerRef;
        }
    }];
}

- (NSArray *)attachmentIdentifiersFromLegacyJSONData:(NSData *)jsonData conversionError:(NSError **)error
{
    return [[self class] parseJSONData:jsonData notFoundErrorCode:kAlfrescoErrorCodeJSONParsing parseBlock:^id(id jsonObject, NSError *parseError) {
        if (parseError)
        {
            *error = parseError;
            return nil;
        }
        else
        {
            NSMutableArray *nodeRefIdentifiers = [NSMutableArray array];
            if ([jsonObject isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *jsonResponseDictionary = (NSDictionary *)jsonObject;
                NSString *itemIdentifiersString = [[[jsonResponseDictionary valueForKey:kAlfrescoWorkflowLegacyJSONData] valueForKey:kAlfrescoWorkflowLegacyJSONFormData] valueForKey:kAlfrescoWorkflowLegacyJSONBPMProcessAttachments];
                
                if (itemIdentifiersString.length > 0)
                {
                    NSArray *allNodeIdentifiers = [itemIdentifiersString componentsSeparatedByString:@","];
                    [nodeRefIdentifiers addObjectsFromArray:allNodeIdentifiers];
                }
            }
            else
            {
                AlfrescoLogDebug(@"Parsing response, should have returned a dictionary in selector - %@", NSStringFromSelector(_cmd));
            }
            return nodeRefIdentifiers;
        }
    }];
}

- (NSArray *)attachmentIdentifiersFromPublicJSONData:(NSData *)jsonData conversionError:(NSError **)error
{
    return [[self class] parseJSONData:jsonData notFoundErrorCode:kAlfrescoErrorCodeJSONParsing parseBlock:^id(id jsonObject, NSError *parseError) {
        if (parseError)
        {
            *error = parseError;
            return nil;
        }
        else
        {
            NSMutableArray *nodeRefIdentifiers = [NSMutableArray array];
            NSDictionary *listDictionary = [jsonObject valueForKey:kAlfrescoWorkflowPublicJSONList];
            NSArray *nodeArray = [listDictionary valueForKey:kAlfrescoWorkflowPublicJSONEntries];
            for (NSDictionary *attachmentDictionary in nodeArray)
            {
                NSDictionary *entryDictionary = attachmentDictionary[kAlfrescoWorkflowPublicJSONEntry];
                NSString *nodeIdentifier = entryDictionary[kAlfrescoWorkflowPublicJSONIdentifier];
                if (nodeIdentifier)
                {
                    [nodeRefIdentifiers addObject:nodeIdentifier];
                }
            }
            return nodeRefIdentifiers;
        }
    }];
}

#pragma mark Helper methods

- (AlfrescoProperty *)propertyForDictionary:(NSDictionary *)variableDictionary
{
    id value = variableDictionary[kAlfrescoWorkflowPublicJSONVariableValue];
    AlfrescoPropertyType propType = [self propertyTypeForVariable:variableDictionary[kAlfrescoWorkflowPublicJSONVariableType]];
    NSNumber *propTypeIndex = @(propType);

    // construct the AlfrescoProperty object
    NSMutableDictionary *propertyDictionary = [NSMutableDictionary dictionaryWithObject:propTypeIndex forKey:kAlfrescoPropertyType];
    if (value != nil && value != [NSNull null])
    {
        // convert values if necessary
        if (propType == AlfrescoPropertyTypeDate || propType == AlfrescoPropertyTypeDateTime)
        {
            value = [CMISDateUtil dateFromString:value];
        }
        
        propertyDictionary[kAlfrescoPropertyValue] = value;
    }
    
    return [[AlfrescoProperty alloc] initWithProperties:propertyDictionary];
}

- (AlfrescoPropertyType)propertyTypeForVariable:(NSString *)type
{
    if ([[type lowercaseString] isEqualToString:kAlfrescoWorkflowVariableTypeString])
    {
        return AlfrescoPropertyTypeString;
    }
    else if ([[type lowercaseString] isEqualToString:kAlfrescoWorkflowVariableTypeInt])
    {
        return AlfrescoPropertyTypeInteger;
    }
    else if ([[type lowercaseString] isEqualToString:kAlfrescoWorkflowVariableTypeBoolean])
    {
        return AlfrescoPropertyTypeBoolean;
    }
    else if ([[type lowercaseString] isEqualToString:kAlfrescoWorkflowVariableTypeDate])
    {
        return AlfrescoPropertyTypeDate;
    }
    else if ([[type lowercaseString] isEqualToString:kAlfrescoWorkflowVariableTypeDateTime])
    {
        return AlfrescoPropertyTypeDateTime;
    }
    
    // default to string
    return AlfrescoPropertyTypeString;
}

- (AlfrescoPropertyType)propertyTypeForVariableValue:(id)value
{
    if ([value isKindOfClass:[NSString class]])
    {
        return AlfrescoPropertyTypeString;
    }
    else if ([value isKindOfClass:[NSNumber class]])
    {
        return AlfrescoPropertyTypeInteger;
    }
    else if ([value isKindOfClass:[NSDate class]])
    {
        return AlfrescoPropertyTypeDateTime;
    }

    // default to string
    return AlfrescoPropertyTypeString;
}

@end
