/*
 ******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
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

#import "AlfrescoWorkflowInternalConstants.h"

/**
 Workflow Constants
 */
NSString * const kAlfrescoProcessDefinitionID = @"{processDefinitionId}";
NSString * const kAlfrescoProcessID = @"{processId}";
NSString * const kAlfrescoTaskID = @"{taskId}";
NSString * const kAlfrescoItemID = @"{itemId}";

// Base URLs
NSString * const kAlfrescoPublicAPIWorkflowBaseURL = @"/api/-default-/public/workflow/versions/1";
NSString * const kAlfrescoCloudWorkflowBaseURL = @"/public/workflow/versions/1";

// Workflow/Process Definitions
NSString * const kAlfrescoLegacyAPIWorkflowProcessDefinition = @"workflow-definitions";
NSString * const kAlfrescoLegacyAPIWorkflowSingleProcessDefinition = @"workflow-definitions/{processDefinitionId}";
NSString * const kAlfrescoPublicAPIWorkflowProcessDefinition = @"process-definitions";
NSString * const kAlfrescoPublicAPIWorkflowSingleProcessDefinition = @"process-definitions/{processDefinitionId}";
NSString * const kAlfrescoPublicAPIWorkflowProcessDefinitionFormModel = @"process-definitions/{processDefinitionId}/start-form-model";

// Workflows Instances/Processes
NSString * const kAlfrescoLegacyAPIWorkflowInstances = @"workflow-instances";
NSString * const kAlfrescoLegacyAPIWorkflowSingleInstance = @"workflow-instances/{processId}";
NSString * const kAlfrescoLegacyAPIWorkflowTasksForInstance = @"workflow-instances/{processId}?includeTasks=true";
NSString * const kAlfrescoLegacyAPIWorkflowProcessDiagram = @"workflow-instances/{processId}/diagram";
NSString * const kAlfrescoLegacyAPIWorkflowFormProcessor = @"workflow/{processDefinitionId}/formprocessor";
NSString * const kAlfrescoPublicAPIWorkflowProcesses = @"processes";
NSString * const kAlfrescoPublicAPIWorkflowSingleProcess = @"processes/{processId}";
NSString * const kAlfrescoPublicAPIWorkflowTasksForProcess = @"processes/{processId}/tasks";
NSString * const kAlfrescoPublicAPIWorkflowAttachmentsForProcess = @"processes/{processId}/items";
NSString * const kAlfrescoPublicAPIWorkflowProcessImage = @"processes/{processId}/image";
NSString * const kAlfrescoPublicAPIWorkflowVariables = @"processes/{processId}/variables";

// Workflows/Processes - Parameters
NSString * const kAlfrescoLegacyAPIWorkflowProcessInitiator = @"initiator";

NSString * const kAlfrescoLegacyAPIWorkflowProcessState = @"state";
NSString * const kAlfrescoLegacyAPIWorkflowStatusActive = @"active";
NSString * const kAlfrescoLegacyAPIWorkflowStatusCompleted = @"completed";
NSString * const kAlfrescoLegacyAPIWorkflowStatusInProgress = @"in_progress";
NSString * const kAlfrescoPublicAPIWorkflowProcessIncludeVariables = @"includeVariables";
NSString * const kAlfrescoPublicAPIWorkflowProcessStartUserID = @"startUserId";

// Tasks
NSString * const kAlfrescoLegacyAPIWorkflowTasks = @"task-instances";
NSString * const kAlfrescoLegacyAPIWorkflowSingleTask = @"task-instances/{taskId}";
NSString * const kAlfrescoLegacyAPIWorkflowTaskAttachments = @"formdefinitions";
NSString * const kAlfrescoLegacyAPIWorkflowTaskFormProcessor = @"task/{taskId}/formprocessor";
NSString * const kAlfrescoPublicAPIWorkflowTasks = @"tasks";
NSString * const kAlfrescoPublicAPIWorkflowSingleTask = @"tasks/{taskId}";
NSString * const kAlfrescoPublicAPIWorkflowTaskVariables = @"tasks/{taskId}/variables";
NSString * const kAlfrescoPublicAPIWorkflowTaskAttachments = @"tasks/{taskId}/items";
NSString * const kAlfrescoPublicAPIWorkflowTaskSingleAttachment = @"tasks/{taskId}/items/{itemId}";

// Tasks - Parameters
NSString * const kAlfrescoPublicAPIWorkflowTaskSelectParameter = @"select";
NSString * const kAlfrescoPublicAPIWorkflowTaskState = @"state";
NSString * const kAlfrescoPublicAPIWorkflowTaskStateCompleted = @"completed";
NSString * const kAlfrescoPublicAPIWorkflowTaskStateClaimed = @"claimed";
NSString * const kAlfrescoPublicAPIWorkflowTaskStateUnclaimed = @"unclaimed";
NSString * const kAlfrescoPublicAPIWorkflowTaskStateResolved = @"resolved";
NSString * const kAlfrescoPublicAPIWorkflowTaskAssignee = @"assignee";
NSString * const kAlfrescoPublicAPIWorkflowTaskCandidateUser = @"candidateUser";
NSString * const kAlfrescoLegacyAPIWorkflowTaskAuthority = @"authority";
NSString * const kAlfrescoLegacyAPIWorkflowTaskPooled = @"pooledTasks";
NSString * const kAlfrescoLegacyAPIWorkflowTaskPooledFalse = @"false";
NSString * const kAlfrescoLegacyAPIWorkflowTaskPooledTrue = @"true";
NSString * const kAlfrescoLegacyAPIWorkflowItemKind = @"itemKind";
NSString * const kAlfrescoLegacyAPIWorkflowItemTypeTask = @"task";
NSString * const kAlfrescoLegacyAPIWorkflowItemID = @"itemId";
NSString * const kAlfrescoLegacyAPIWorkflowFields = @"fields";
NSString * const kAlfrescoLegacyAPIWorkflowPackageItems = @"packageItems";

// Common Public API Parameters
NSString * const kAlfrescoPublicAPIWorkflowWhere = @"where";
NSString * const kAlfrescoPublicAPIWorkflowStatus = @"status";
NSString * const kAlfrescoPublicAPIWorkflowStatusAny = @"any";
NSString * const kAlfrescoPublicAPIWorkflowStatusActive = @"active";
NSString * const kAlfrescoPublicAPIWorkflowStatusCompleted = @"completed";
NSString * const kAlfrescoPublicAPIWorkflowPriority = @"priority";
NSString * const kAlfrescoPublicAPIWorkflowDueAt = @"dueAt";

// Common Legacy API Parameters
NSString * const kAlfrescoLegacyAPIWorkflowPriority = @"priority";
NSString * const kAlfrescoLegacyAPIWorkflowDueBefore = @"dueBefore";
NSString * const kAlfrescoLegacyAPIWorkflowDueAfter = @"dueAfter";

// Person nodeRef
NSString * const kAlfrescoLegacyAPIPersonNodeRef = @"forms/picker/authority/children?selectableType=cm:person&searchTerm={personID}&size=1";

NSString * const kAlfrescoWorkflowJBPMEnginePrefix = @"jbpm$";
NSString * const kAlfrescoWorkflowActivitiEnginePrefix = @"activiti$";

// JSON
NSString * const kAlfrescoWorkflowPublicJSONEntry = @"entry";
NSString * const kAlfrescoWorkflowPublicJSONIdentifier = @"id";
NSString * const kAlfrescoWorkflowPublicJSONKey = @"key";
NSString * const kAlfrescoWorkflowPublicJSONName = @"name";
NSString * const kAlfrescoWorkflowPublicJSONTitle = @"title";
NSString * const kAlfrescoWorkflowPublicJSONDescription = @"description";
NSString * const kAlfrescoWorkflowPublicJSONVersion = @"version";
NSString * const kAlfrescoWorkflowPublicJSONList = @"list";
NSString * const kAlfrescoWorkflowPublicJSONEntries = @"entries";
NSString * const kAlfrescoWorkflowPublicJSONHasMoreItems = @"hasMoreItems";
NSString * const kAlfrescoWorkflowPublicJSONTotalItems = @"totalItems";
NSString * const kAlfrescoWorkflowLegacyJSONMaxItems = @"maxItems";
NSString * const kAlfrescoWorkflowLegacyJSONPagination = @"paging";
NSString * const kAlfrescoWorkflowLegacyJSONTotalItems = @"totalItems";

NSString * const kAlfrescoWorkflowPublicJSONProcessID = @"processId";
NSString * const kAlfrescoWorkflowPublicJSONProcessDefinitionID = @"processDefinitionId";
NSString * const kAlfrescoWorkflowPublicJSONProcessDefinitionKey = @"processDefinitionKey";
NSString * const kAlfrescoWorkflowPublicJSONStartedAt = @"startedAt";
NSString * const kAlfrescoWorkflowPublicJSONEndedAt = @"endedAt";
NSString * const kAlfrescoWorkflowPublicJSONDueAt = @"dueAt";
NSString * const kAlfrescoWorkflowPublicJSONPriority = @"priority";
NSString * const kAlfrescoWorkflowPublicJSONAssignee = @"assignee";
NSString * const kAlfrescoWorkflowPublicJSONProcessVariables = @"processVariables";
NSString * const kAlfrescoWorkflowPublicJSONVariables = @"variables";
NSString * const kAlfrescoWorkflowPublicJSONStartUserID = @"startUserId";
NSString * const kAlfrescoWorkflowPublicJSONFormResourceKey = @"formResourceKey";

NSString * const kAlfrescoWorkflowLegacyJSONProperties = @"properties";
NSString * const kAlfrescoWorkflowLegacyJSONWorkflowInstance = @"workflowInstance";
NSString * const kAlfrescoWorkflowLegacyJSONData = @"data";
NSString * const kAlfrescoWorkflowLegacyJSONBPMTaskID = @"bpm_taskId";
NSString * const kAlfrescoWorkflowLegacyJSONIdentifier = @"id";
NSString * const kAlfrescoWorkflowLegacyJSONName = @"name";
NSString * const kAlfrescoWorkflowLegacyJSONTitle = @"title";
NSString * const kAlfrescoWorkflowLegacyJSONMessage = @"message";
NSString * const kAlfrescoWorkflowLegacyJSONBPMStartedAt = @"bpm_startDate";
NSString * const kAlfrescoWorkflowLegacyJSONBPMEndedAt = @"bpm_completionDate";
NSString * const kAlfrescoWorkflowLegacyJSONBPMDueAt = @"bpm_dueDate";
NSString * const kAlfrescoWorkflowLegacyJSONBPMPriority = @"bpm_priority";
NSString * const kAlfrescoWorkflowLegacyJSONBPMDescription = @"bpm_description";
NSString * const kAlfrescoWorkflowLegacyJSONBPMAssignee = @"bpm_assignee";
NSString * const kAlfrescoWorkflowLegacyJSONBPMPackageContainer = @"bpm_package";
NSString * const kAlfrescoWorkflowLegacyJSONState = @"state";
NSString * const kAlfrescoWorkflowLegacyJSONStateCompleted = @"COMPLETED";
NSString * const kAlfrescoWorkflowLegacyJSONOwner = @"cm_owner";

NSString * const kAlfrescoWorkflowPublicBPMJSONProcessDescription = @"bpm_description";
NSString * const kAlfrescoWorkflowPublicBPMJSONProcessPriority = @"bpm_workflowPriority";
NSString * const kAlfrescoWorkflowPublicBPMJSONProcessDueDate = @"bpm_workflowDueDate";
NSString * const kAlfrescoWorkflowPublicBPMJSONProcessAssignee = @"bpm_assignee";
NSString * const kAlfrescoWorkflowPublicBPMJSONProcessAssignees = @"bpm_assignees";

NSString * const kAlfrescoWorkflowLegacyJSONBPMProcessAssignee = @"assoc_bpm_assignee_added";
NSString * const kAlfrescoWorkflowLegacyJSONBPMProcessAssignees = @"assoc_bpm_assignees_added";
NSString * const kAlfrescoWorkflowLegacyJSONBPMProcessAttachments = @"assoc_packageItems";
NSString * const kAlfrescoWorkflowLegacyJSONBPMProcessAttachmentsAdd = @"assoc_packageItems_added";
NSString * const kAlfrescoWorkflowLegacyJSONBPMProcessAttachmentsRemove = @"assoc_packageItems_removed";

NSString * const kAlfrescoWorkflowLegacyJSONBPMStatus = @"prop_bpm_status";
NSString * const kAlfrescoWorkflowLegacyJSONTransitions = @"prop_transitions";
NSString * const kAlfrescoWorkflowLegacyJSONNext = @"Next";
NSString * const kAlfrescoWorkflowLegacyJSONCompleted = @"Completed";
NSString * const kAlfrescoWorkflowLegacyJSONItemValue = @"itemValueType";

NSString * const kAlfrescoWorkflowLegacyJSONUsername = @"userName";
NSString * const kAlfrescoWorkflowLegacyJSONStartedAt = @"startDate";
NSString * const kAlfrescoWorkflowLegacyJSONEndedAt = @"endDate";
NSString * const kAlfrescoWorkflowLegacyJSONDueAt = @"dueDate";
NSString * const kAlfrescoWorkflowLegacyJSONPriority = @"priority";
NSString * const kAlfrescoWorkflowLegacyJSONDescription = @"description";
NSString * const kAlfrescoWorkflowLegacyJSONInitiator = @"initiator";
NSString * const kAlfrescoWorkflowLegacyJSONFormData = @"formData";
NSString * const kAlfrescoWorkflowLegacyJSONTasks = @"tasks";

NSString * const kAlfrescoWorkflowLegacyJSONPropertyPrefix = @"prop_";
NSString * const kAlfrescoWorkflowLegacyJSONAssociationPrefix = @"assoc_";

NSString * const kAlfrescoWorkflowPublicJSONVariableName = @"name";
NSString * const kAlfrescoWorkflowPublicJSONVariableType = @"type";
NSString * const kAlfrescoWorkflowPublicJSONVariableValue = @"value";
NSString * const kAlfrescoWorkflowPublicJSONVariableScope = @"scope";
NSString * const kAlfrescoWorkflowPublicJSONVariableScopeLocal = @"local";
NSString * const kAlfrescoWorkflowPublicJSONVariableScopeGlobal = @"global";

// Variable types
NSString * const kAlfrescoWorkflowVariableTypeString = @"d:text";
NSString * const kAlfrescoWorkflowVariableTypeInt = @"d:int";
NSString * const kAlfrescoWorkflowVariableTypeBoolean = @"d:boolean";
NSString * const kAlfrescoWorkflowVariableTypeDate = @"d:date";
NSString * const kAlfrescoWorkflowVariableTypeDateTime = @"d:datetime";


