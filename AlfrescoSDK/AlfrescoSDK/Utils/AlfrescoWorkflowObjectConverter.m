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

/** AlfrescoWorkflowObjectConverter
 
 Author: Tauseef Mughal (Alfresco)
 */

#import "AlfrescoWorkflowObjectConverter.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoSession.h"
#import "AlfrescoErrors.h"
#import "AlfrescoWorkflowProcessDefinition.h"
#import "AlfrescoLog.h"
#import "AlfrescoWorkflowVariable.h"

@implementation AlfrescoWorkflowObjectConverter

- (NSArray *)workflowDefinitionsFromLegacyJSONData:(NSData *)jsonData session:(id<AlfrescoSession>)session conversionError:(NSError **)error
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
                    [workflowDefinitions addObject:[[AlfrescoWorkflowProcessDefinition alloc] initWithProperties:entryDictionary session:session]];
                }
            }
            else if ([processDataResponseObject isKindOfClass:[NSDictionary class]])
            {
                [workflowDefinitions addObject:[[AlfrescoWorkflowProcessDefinition alloc] initWithProperties:processDataResponseObject session:session]];
            }
            return workflowDefinitions;
        }
    }];
}

- (NSArray *)workflowDefinitionsFromPublicJSONData:(NSData *)jsonData session:(id<AlfrescoSession>)session conversionError:(NSError **)error
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
                [workflowDefinitions addObject:[[AlfrescoWorkflowProcessDefinition alloc] initWithProperties:entryDictionary session:session]];
            }
            
            return workflowDefinitions;
        }
    }];
}

- (NSArray *)workflowProcessesFromLegacyJSONData:(NSData *)jsonData session:(id<AlfrescoSession>)session conversionError:(NSError **)error
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
                    [workflowProcesses addObject:[[AlfrescoWorkflowProcess alloc] initWithProperties:entryDictionary session:session]];
                }
            }
            else if ([processDataResponseObject isKindOfClass:[NSDictionary class]])
            {
                [workflowProcesses addObject:[[AlfrescoWorkflowProcess alloc] initWithProperties:processDataResponseObject session:session]];
            }
            
            return workflowProcesses;
        }
    }];
}

- (NSArray *)workflowProcessesFromPublicJSONData:(NSData *)jsonData session:(id<AlfrescoSession>)session conversionError:(NSError **)error
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
                    [workflowProcesses addObject:[[AlfrescoWorkflowProcess alloc] initWithProperties:entryDictionary session:session]];
                }
            }
            else
            {
                [workflowProcesses addObject:[[AlfrescoWorkflowProcess alloc] initWithProperties:jsonObject session:session]];
            }
            
            return workflowProcesses;
        }
    }];
}

- (NSArray *)workflowTasksFromLegacyJSONData:(NSData *)jsonData session:(id<AlfrescoSession>)session conversionError:(NSError **)error
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
                [workflowTasks addObject:[[AlfrescoWorkflowTask alloc] initWithProperties:entryDictionary session:session]];
            }
            return workflowTasks;
        }
    }];
}

- (NSArray *)workflowTasksFromPublicJSONData:(NSData *)jsonData session:(id<AlfrescoSession>)session conversionError:(NSError **)error
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
                [workflowTasks addObject:[[AlfrescoWorkflowTask alloc] initWithProperties:entryDictionary session:session]];
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
                    NSDictionary *taskProperties = [processDictionary objectForKey:kAlfrescoWorkflowLegacyJSONProperties];
                    containerRef = [taskProperties objectForKey:kAlfrescoWorkflowLegacyJSONBPMPackageContainer];
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
                NSArray *itemsArray = [[jsonResponseDictionary valueForKey:kAlfrescoWorkflowLegacyJSONData] valueForKey:kAlfrescoJSONItems];
                
                if (itemsArray)
                {
                    for (NSDictionary *item in itemsArray)
                    {
                        NSString *nodeIdentifier = [item objectForKey:kAlfrescoJSONNodeRef];
                        if (nodeIdentifier)
                        {
                            [nodeRefIdentifiers addObject:nodeIdentifier];
                        }
                    }
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
                NSDictionary *entryDictionary = [attachmentDictionary objectForKey:kAlfrescoWorkflowPublicJSONEntry];
                NSString *nodeIdentifier = [entryDictionary objectForKey:kAlfrescoWorkflowPublicJSONIdentifier];
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
