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

#import "AlfrescoWorkflowInternalConstants.h"

/**
 Workflow Constants
 */
NSString * const kAlfrescoProcessDefinitionID = @"{processDefinitionId}";
NSString * const kAlfrescoProcessID = @"{processId}";
NSString * const kAlfrescoTaskID = @"{taskId}";
NSString * const kAlfrescoItemID = @"{itemId}";

NSString * const kAlfrescoWorkflowReviewAndApprove = @"activitiReview";

// Base URLs
NSString * const kAlfrescoLegacyAPIWorkflowBaseURL = @"/service/api/";
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
NSString * const kAlfrescoLegacyAPIWorkflowTasksForInstance = @"workflow-instances/{processId}/task-instances";
NSString * const kAlfrescoLegacyAPIWorkflowProcessDiagram = @"workflow-instances/{processId}/diagram";
NSString * const kAlfrescoLegacyAPIWorkflowFormProcessor = @"workflow/{processDefinitionId}/formprocessor";
NSString * const kAlfrescoPublicAPIWorkflowProcesses = @"processes";
NSString * const kAlfrescoPublicAPIWorkflowSingleProcess = @"processes/{processId}";
NSString * const kAlfrescoPublicAPIWorkflowTasksForProcess = @"processes/{processId}/tasks";
NSString * const kAlfrescoPublicAPIWorkflowProcessImage = @"processes/{processId}/image";

// Workflows/Processes - Parameters
NSString * const kAlfrescoWorkflowProcessStatus = @"status";
NSString * const kAlfrescoLegacyAPIWorkflowStatusInProgress = @"in_progress";
NSString * const kAlfrescoLegacyAPIWorkflowStatusCompleted = @"completed";
NSString * const kAlfrescoPublicAPIWorkflowProcessStatusAny = @"any";
NSString * const kAlfrescoPublicAPIWorkflowProcessStatusActive = @"active";
NSString * const kAlfrescoPublicAPIWorkflowProcessStatusCompleted = @"completed";
NSString * const kAlfrescoPublicAPIWorkflowProcessIncludeVariables = @"includeVariables";
NSString * const kAlfrescoPublicAPIWorkflowProcessWhereParameter = @"where";

// Tasks
NSString * const kAlfrescoLegacyAPIWorkflowTasks = @"task-instances";
NSString * const kAlfrescoLegacyAPIWorkflowSingleTask = @"task-instances/{taskId}";
NSString * const kAlfrescoLegacyAPIWorkflowTaskAttachments = @"forms/picker/items";
NSString * const kAlfrescoLegacyAPIWorkflowTaskFormProcessor = @"task/{taskId}/formprocessor";
NSString * const kAlfrescoPublicAPIWorkflowTasks = @"tasks";
NSString * const kAlfrescoPublicAPIWorkflowSingleTask = @"tasks/{taskId}";
NSString * const kAlfrescoPublicAPIWorkflowTaskAttachments = @"tasks/{taskId}/items";
NSString * const kAlfrescoPublicAPIWorkflowTaskSingleAttachment = @"tasks/{taskId}/items/{itemId}";

// Tasks - Parameters
NSString * const kAlfrescoWorkflowTaskSelectParameter = @"select";
NSString * const kAlfrescoWorkflowTaskState = @"state";
NSString * const kAlfrescoPublicAPIWorkflowTaskStateCompleted = @"completed";
NSString * const kAlfrescoPublicAPIWorkflowTaskStateClaimed = @"claimed";
NSString * const kAlfrescoPublicAPIWorkflowTaskStateUnclaimed = @"unclaimed";
NSString * const kAlfrescoPublicAPIWorkflowTaskStateResolved = @"resolved";
NSString * const kAlfrescoPublicAPIWorkflowTaskAssignee = @"assignee";

// Person nodeRef
NSString * const kAlfrescoLegacyAPIPersonNodeRef = @"forms/picker/authority/children?selectableType=cm:person&searchTerm={personID}&size=1";

NSString * const kAlfrescoWorkflowJBPMEnginePrefix = @"jbpm$";
NSString * const kAlfrescoWorkflowActivitiEnginePrefix = @"activiti$";
NSString * const kAlfrescoWorkflowNodeRefPrefix = @"workspace://SpacesStore/";

// JSON
NSString * const kAlfrescoPublicJSONEntry = @"entry";
NSString * const kAlfrescoPublicJSONIdentifier = @"id";
NSString * const kAlfrescoPublicJSONName = @"name";
NSString * const kAlfrescoPublicJSONDescription = @"description";
NSString * const kAlfrescoPublicJSONVersion = @"version";
NSString * const kAlfrescoPublicJSONList = @"list";
NSString * const kAlfrescoPublicJSONEntries = @"entries";
NSString * const kAlfrescoPublicJSONHasMoreItems = @"hasMoreItems";
NSString * const kAlfrescoPublicJSONTotalItems = @"totalItems";
NSString * const kAlfrescoLegacyJSONMaxItems = @"maxItems";
NSString * const kAlfrescoLegacyJSONPagination = @"paging";
NSString * const kAlfrescoLegacyJSONTotalItems = @"totalItems";

NSString * const kAlfrescoPublicJSONProcessID = @"processId";
NSString * const kAlfrescoPublicJSONProcessDefinitionID = @"processDefinitionId";
NSString * const kAlfrescoPublicJSONProcessDefinitionKey = @"processDefinitionKey";
NSString * const kAlfrescoPublicJSONStartedAt = @"startedAt";
NSString * const kAlfrescoPublicJSONEndedAt = @"endedAt";
NSString * const kAlfrescoPublicJSONDueAt = @"dueAt";
NSString * const kAlfrescoPublicJSONPriority = @"priority";
NSString * const kAlfrescoPublicJSONAssignee = @"assignee";
NSString * const kAlfrescoPublicJSONProcessVariables = @"processVariables";
NSString * const kAlfrescoPublicJSONVariables = @"variables";
NSString * const kAlfrescoPublicJSONStartUserID = @"startUserId";

NSString * const kAlfrescoLegacyJSONProperties = @"properties";
NSString * const kAlfrescoLegacyJSONWorkflowInstance = @"workflowInstance";
NSString * const kAlfrescoLegacyJSONData = @"data";
NSString * const kAlfrescoLegacyJSONBPMTaskID = @"bpm_taskId";
NSString * const kAlfrescoLegacyJSONIdentifier = @"id";
NSString * const kAlfrescoLegacyJSONName = @"name";
NSString * const kAlfrescoLegacyJSONMessage = @"message";
NSString * const kAlfrescoLegacyJSONBPMStartedAt = @"bpm_startDate";
NSString * const kAlfrescoLegacyJSONBPMEndedAt = @"bpm_completionDate";
NSString * const kAlfrescoLegacyJSONBPMDueAt = @"bpm_dueDate";
NSString * const kAlfrescoLegacyJSONBPMPriority = @"bpm_priority";
NSString * const kAlfrescoLegacyJSONBPMDescription = @"bpm_description";
NSString * const kAlfrescoLegacyJSONBPMAssignee = @"bpm_assignee";
NSString * const kAlfrescoLegacyJSONBPMPackageContainer = @"bpm_package";

NSString * const kAlfrescoLegacyJSONOwner = @"cm_owner";

NSString * const kAlfrescoPublicBPMJSONProcessTitle = @"bpm_description";
NSString * const kAlfrescoPublicBPMJSONProcessDescription = @"bpm_workflowDescription";
NSString * const kAlfrescoPublicBPMJSONProcessPriority= @"bpm_workflowPriority";
NSString * const kAlfrescoPublicBPMJSONProcessAssignee = @"bpm_assignee";
NSString * const kAlfrescoPublicBPMJSONProcessAssignees = @"bpm_assignees";
NSString * const kAlfrescoPublicBPMJSONProcessSendEmailNotification = @"bpm_sendEMailNotifications";
NSString * const kAlfrescoPublicBPMJSONProcessDueDate = @"bpm_workflowDueDate";
NSString * const kAlfrescoPublicBPMJSONProcessApprovalRate = @"wf_requiredApprovePercent";

NSString * const kAlfrescoLegacyJSONBPMProcessDescription = @"prop_bpm_workflowDescription";
NSString * const kAlfrescoLegacyJSONLegacyProcessPriority = @"prop_bpm_workflowPriority";
NSString * const kAlfrescoLegacyJSONBPMProcessAssignee = @"assoc_bpm_assignee_added";
NSString * const kAlfrescoLegacyJSONBPMProcessAssignees = @"assoc_bpm_assignees_added";
NSString * const kAlfrescoLegacyJSONBPMProcessSendEmailNotification = @"prop_bpm_sendEMailNotifications";
NSString * const kAlfrescoLegacyJSONBPMProcessDueDate = @"prop_bpm_workflowDueDate";
NSString * const kAlfrescoLegacyJSONBPMProcessAttachmentsAdd = @"assoc_packageItems_added";
NSString * const kAlfrescoLegacyJSONBPMProcessAttachmentsRemove = @"assoc_packageItems_removed";
NSString * const kAlfrescoLegacyJSONBPMProcessApprovalRate = @"prop_wf_requiredApprovePercent";

NSString * const kAlfrescoLegacyJSONBPMTransition = @"prop_transitions";
NSString * const kAlfrescoLegacyJSONBPMStatus = @"prop_bpm_status";
NSString * const kAlfrescoLegacyJSONBPMReviewOutcome = @"prop_wf_reviewOutcome";
NSString * const kAlfrescoLegacyJSONBPMComment = @"prop_bpm_comment";
NSString * const kAlfrescoLegacyJSONNext = @"Next";
NSString * const kAlfrescoLegacyJSONCompleted = @"Completed";
NSString * const kAlfrescoLegacyJSONItemValue = @"itemValueType";

NSString * const kAlfrescoLegacyJSONProcessDefinitionID = @"definitionUrl";
NSString * const kAlfrescoLegacyJSONStartedAt = @"startDate";
NSString * const kAlfrescoLegacyJSONEndedAt = @"endDate";
NSString * const kAlfrescoLegacyJSONDueAt = @"dueDate";
NSString * const kAlfrescoLegacyJSONPriority = @"priority";
NSString * const kAlfrescoLegacyJSONDescription = @"description";
NSString * const kAlfrescoLegacyJSONInitiator = @"initiator";

NSString * const kAlfrescoPublicJSONVariableName = @"name";
NSString * const kAlfrescoPublicJSONVariableType = @"type";
NSString * const kAlfrescoPublicJSONVariableValue = @"value";

/**
 Property name constants
 */
NSString * const kAlfrescoWorkflowEngineType = @"workflowEngineType";
NSString * const kAlfrescoWorkflowUsingPublicAPI = @"workflowPublicAPI";

