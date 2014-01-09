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

#import <Foundation/Foundation.h>

/**
 Workflow Constants
 */
extern NSString * const kAlfrescoProcessDefinitionID;
extern NSString * const kAlfrescoProcessID;
extern NSString * const kAlfrescoTaskID;
extern NSString * const kAlfrescoItemID;

extern NSString * const kAlfrescoWorkflowReviewAndApprove;

// Base URLs
extern NSString * const kAlfrescoLegacyAPIWorkflowBaseURL;
extern NSString * const kAlfrescoPublicAPIWorkflowBaseURL;

// Workflow/Process Definitions
extern NSString * const kAlfrescoLegacyAPIWorkflowProcessDefinition;
extern NSString * const kAlfrescoLegacyAPIWorkflowSingleProcessDefinition;
extern NSString * const kAlfrescoPublicAPIWorkflowProcessDefinition;
extern NSString * const kAlfrescoPublicAPIWorkflowSingleProcessDefinition;
extern NSString * const kAlfrescoPublicAPIWorkflowProcessDefinitionFormModel;

// Workflows Instances/Processes
extern NSString * const kAlfrescoLegacyAPIWorkflowInstances;
extern NSString * const kAlfrescoLegacyAPIWorkflowSingleInstance;
extern NSString * const kAlfrescoLegacyAPIWorkflowTasksForInstance;
extern NSString * const kAlfrescoLegacyAPIWorkflowProcessDiagram;
extern NSString * const kAlfrescoLegacyAPIWorkflowFormProcessor;
extern NSString * const kAlfrescoPublicAPIWorkflowProcesses;
extern NSString * const kAlfrescoPublicAPIWorkflowSingleProcess;
extern NSString * const kAlfrescoPublicAPIWorkflowTasksForProcess;
extern NSString * const kAlfrescoPublicAPIWorkflowProcessImage;

// Workflows/Processes - Parameters
extern NSString * const kAlfrescoWorkflowProcessStatus;
extern NSString * const kAlfrescoLegacyAPIWorkflowStatusInProgress;
extern NSString * const kAlfrescoLegacyAPIWorkflowStatusCompleted;
extern NSString * const kAlfrescoPublicAPIWorkflowProcessWhereParameter;
extern NSString * const kAlfrescoPublicAPIWorkflowProcessStatusAny;
extern NSString * const kAlfrescoPublicAPIWorkflowProcessStatusActive;
extern NSString * const kAlfrescoPublicAPIWorkflowProcessStatusCompleted;
extern NSString * const kAlfrescoPublicAPIWorkflowProcessIncludeVariables;

// Tasks
extern NSString * const kAlfrescoLegacyAPIWorkflowTasks;
extern NSString * const kAlfrescoLegacyAPIWorkflowSingleTask;
extern NSString * const kAlfrescoLegacyAPIWorkflowTaskAttachments;
extern NSString * const kAlfrescoLegacyAPIWorkflowTaskFormProcessor;
extern NSString * const kAlfrescoPublicAPIWorkflowTasks;
extern NSString * const kAlfrescoPublicAPIWorkflowSingleTask;
extern NSString * const kAlfrescoPublicAPIWorkflowTaskAttachments;
extern NSString * const kAlfrescoPublicAPIWorkflowTaskSingleAttachment;

// Tasks - Parameters
extern NSString * const kAlfrescoWorkflowTaskSelectParameter;
extern NSString * const kAlfrescoWorkflowTaskState;
extern NSString * const kAlfrescoPublicAPIWorkflowTaskAssignee;
extern NSString * const kAlfrescoPublicAPIWorkflowTaskStateCompleted;
extern NSString * const kAlfrescoPublicAPIWorkflowTaskStateClaimed;
extern NSString * const kAlfrescoPublicAPIWorkflowTaskStateUnclaimed;
extern NSString * const kAlfrescoPublicAPIWorkflowTaskStateResolved;

// Person nodeRef
extern NSString * const kAlfrescoLegacyAPIPersonNodeRef;

extern NSString * const kAlfrescoWorkflowJBPMEnginePrefix;
extern NSString * const kAlfrescoWorkflowActivitiEnginePrefix;
extern NSString * const kAlfrescoWorkflowNodeRefPrefix;

// JSON
extern NSString * const kAlfrescoPublicJSONEntry;
extern NSString * const kAlfrescoPublicJSONIdentifier;
extern NSString * const kAlfrescoPublicJSONName;
extern NSString * const kAlfrescoPublicJSONDescription;
extern NSString * const kAlfrescoPublicJSONVersion;
extern NSString * const kAlfrescoPublicJSONList;
extern NSString * const kAlfrescoPublicJSONEntries;
extern NSString * const kAlfrescoPublicJSONHasMoreItems;
extern NSString * const kAlfrescoPublicJSONTotalItems;
extern NSString * const kAlfrescoLegacyJSONPagination;
extern NSString * const kAlfrescoLegacyJSONTotalItems;

extern NSString * const kAlfrescoPublicJSONProcessID;
extern NSString * const kAlfrescoPublicJSONProcessDefinitionID;
extern NSString * const kAlfrescoPublicJSONProcessDefinitionKey;
extern NSString * const kAlfrescoPublicJSONStartedAt;
extern NSString * const kAlfrescoPublicJSONEndedAt;
extern NSString * const kAlfrescoPublicJSONDueAt;
extern NSString * const kAlfrescoPublicJSONPriority;
extern NSString * const kAlfrescoPublicJSONAssignee;
extern NSString * const kAlfrescoPublicJSONProcessVariables;
extern NSString * const kAlfrescoPublicJSONVariables;
extern NSString * const kAlfrescoPublicJSONStartUserID;

extern NSString * const kAlfrescoLegacyJSONProperties;
extern NSString * const kAlfrescoLegacyJSONWorkflowInstance;
extern NSString * const kAlfrescoLegacyJSONData;
extern NSString * const kAlfrescoLegacyJSONBPMTaskID;
extern NSString * const kAlfrescoLegacyJSONIdentifier;
extern NSString * const kAlfrescoLegacyJSONName;
extern NSString * const kAlfrescoLegacyJSONMessage;
extern NSString * const kAlfrescoLegacyJSONBPMStartedAt;
extern NSString * const kAlfrescoLegacyJSONBPMEndedAt;
extern NSString * const kAlfrescoLegacyJSONBPMDueAt;
extern NSString * const kAlfrescoLegacyJSONBPMPriority;
extern NSString * const kAlfrescoLegacyJSONBPMDescription;
extern NSString * const kAlfrescoLegacyJSONBPMAssignee;
extern NSString * const kAlfrescoLegacyJSONBPMPackageContainer;

extern NSString * const kAlfrescoLegacyJSONOwner;

extern NSString * const kAlfrescoPublicBPMJSONProcessTitle;
extern NSString * const kAlfrescoPublicBPMJSONProcessDescription;
extern NSString * const kAlfrescoPublicBPMJSONProcessPriority;
extern NSString * const kAlfrescoPublicBPMJSONProcessAssignee;
extern NSString * const kAlfrescoPublicBPMJSONProcessAssignees;
extern NSString * const kAlfrescoPublicBPMJSONProcessSendEmailNotification;
extern NSString * const kAlfrescoPublicBPMJSONProcessDueDate;
extern NSString * const kAlfrescoPublicBPMJSONProcessApprovalRate;

extern NSString * const kAlfrescoLegacyJSONBPMProcessDescription;
extern NSString * const kAlfrescoLegacyJSONLegacyProcessPriority;
extern NSString * const kAlfrescoLegacyJSONBPMProcessAssignee;
extern NSString * const kAlfrescoLegacyJSONBPMProcessAssignees;
extern NSString * const kAlfrescoLegacyJSONBPMProcessSendEmailNotification;
extern NSString * const kAlfrescoLegacyJSONBPMProcessDueDate;
extern NSString * const kAlfrescoLegacyJSONBPMProcessAttachmentsAdd;
extern NSString * const kAlfrescoLegacyJSONBPMProcessAttachmentsRemove;
extern NSString * const kAlfrescoLegacyJSONBPMProcessApprovalRate;

extern NSString * const kAlfrescoLegacyJSONBPMTransition;
extern NSString * const kAlfrescoLegacyJSONBPMStatus;
extern NSString * const kAlfrescoLegacyJSONBPMReviewOutcome;
extern NSString * const kAlfrescoLegacyJSONBPMComment;
extern NSString * const kAlfrescoLegacyJSONNext;
extern NSString * const kAlfrescoLegacyJSONCompleted;
extern NSString * const kAlfrescoLegacyJSONItemValue;

extern NSString * const kAlfrescoLegacyJSONProcessDefinitionID;
extern NSString * const kAlfrescoLegacyJSONStartedAt;
extern NSString * const kAlfrescoLegacyJSONEndedAt;
extern NSString * const kAlfrescoLegacyJSONDueAt;
extern NSString * const kAlfrescoLegacyJSONPriority;
extern NSString * const kAlfrescoLegacyJSONDescription;
extern NSString * const kAlfrescoLegacyJSONInitiator;

extern NSString * const kAlfrescoPublicJSONVariableName;
extern NSString * const kAlfrescoPublicJSONVariableType;
extern NSString * const kAlfrescoPublicJSONVariableValue;

extern NSString * const kAlfrescoWorkflowEngineType;
extern NSString * const kAlfrescoWorkflowUsingPublicAPI;
