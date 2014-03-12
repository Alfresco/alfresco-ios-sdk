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

#import "AlfrescoObjectConverter.h"

@interface AlfrescoWorkflowObjectConverter : AlfrescoObjectConverter

// process definitions
- (NSArray *)workflowDefinitionsFromLegacyJSONData:(NSData *)jsonData conversionError:(NSError **)error;
- (NSArray *)workflowDefinitionsFromPublicJSONData:(NSData *)jsonData conversionError:(NSError **)error;

// processes
- (NSArray *)workflowProcessesFromLegacyJSONData:(NSData *)jsonData conversionError:(NSError **)error;
- (NSArray *)workflowProcessesFromPublicJSONData:(NSData *)jsonData conversionError:(NSError **)error;

// tasks
- (NSArray *)workflowTasksFromLegacyJSONData:(NSData *)jsonData conversionError:(NSError **)error;
- (NSArray *)workflowTasksFromLegacyJSONData:(NSData *)jsonData inState:(NSString *)state conversionError:(NSError **)error;
- (NSArray *)workflowTasksFromPublicJSONData:(NSData *)jsonData conversionError:(NSError **)error;

// variables
- (NSArray *)workflowVariablesFromArray:(NSArray *)variables;
- (NSArray *)workflowVariablesFromPublicJSONData:(NSData *)jsonData conversionError:(NSError **)error;
- (NSArray *)workflowVariablesFromLegacyProperties:(NSDictionary *)properties;

// attachment identifiers
- (NSString *)attachmentContainerNodeRefFromLegacyJSONData:(NSData *)jsonData conversionError:(NSError **)error;
- (NSArray *)attachmentIdentifiersFromLegacyJSONData:(NSData *)jsonData conversionError:(NSError **)error;
- (NSArray *)attachmentIdentifiersFromPublicJSONData:(NSData *)jsonData conversionError:(NSError **)error;

@end
