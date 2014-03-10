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
#import "AlfrescoInternalConstants.h"
#import "AlfrescoLog.h"
#import "AlfrescoWorkflowProcessDefinition.h"
#import "AlfrescoWorkflowProcess.h"
#import "AlfrescoWorkflowTask.h"
#import "AlfrescoWorkflowVariable.h"

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

- (NSArray *)workflowVariablesFromLegacyProperties:(NSDictionary *)properties
{
    NSMutableArray *variables = [NSMutableArray array];
    
    NSArray *excludeKeys = @[kAlfrescoWorkflowLegacyJSONProcessDefinitionID,
                             kAlfrescoWorkflowLegacyJSONDiagramURL,
                             kAlfrescoWorkflowLegacyJSONStartInstance,
                             kAlfrescoWorkflowLegacyJSONDefinition];
    
    for (NSString *key in properties.allKeys)
    {
        if (properties[key] != [NSNull null] && ![excludeKeys containsObject:key])
        {
            NSString *name = key;
            id value = properties[key];
            NSString *type = NSStringFromClass([value class]);
            
            // get the username for the initiator dictionary
            if ([key isEqualToString:kAlfrescoWorkflowLegacyJSONInitiator])
            {
                value = (properties[kAlfrescoWorkflowLegacyJSONInitiator])[kAlfrescoWorkflowLegacyJSONUsername];
                type = NSStringFromClass([value class]);
            }
            
            // mimic the public api response. This will be changed with MOBSDK-674, which will use AlfrescoProperty instead.
            NSDictionary *variableDictionary = @{@"name" : name, @"type" : type, @"value" : value};
            AlfrescoWorkflowVariable *variable = [[AlfrescoWorkflowVariable alloc] initWithProperties:variableDictionary];
            [variables addObject:variable];
        }
    }
    return variables;
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

- (NSArray *)workflowVariablesFromArray:(NSArray *)variables
{
    NSMutableArray *variableArray = nil;
    if (variables)
    {
        variableArray = [NSMutableArray arrayWithCapacity:variables.count];
    }
    
    for (NSDictionary *variableProperties in variables)
    {
        AlfrescoWorkflowVariable *variable = [[AlfrescoWorkflowVariable alloc] initWithProperties:variableProperties];
        [variableArray addObject:variable];
    }
    return variableArray;
}

- (NSArray *)workflowVariablesFromPublicJSONData:(NSData *)jsonData conversionError:(NSError **)error
{
    return [[self class] parseJSONData:jsonData notFoundErrorCode:kAlfrescoErrorCodeJSONParsing parseBlock:^id(id jsonObject, NSError *parseError) {
        if (parseError)
        {
            *error = parseError;
            return nil;
        }
        else
        {
            NSMutableArray *workflowVariables = [NSMutableArray array];
            NSDictionary *listDictionary = jsonObject[kAlfrescoWorkflowPublicJSONList];
            NSArray *rawVariablesArray = listDictionary[kAlfrescoWorkflowPublicJSONEntries];
            for (NSDictionary *entry in rawVariablesArray)
            {
                NSDictionary *variableProperties = entry[kAlfrescoWorkflowPublicJSONEntry];
                [workflowVariables addObject:[[AlfrescoWorkflowVariable alloc] initWithProperties:variableProperties]];
            }
            return workflowVariables;
        }
    }];
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

@end
