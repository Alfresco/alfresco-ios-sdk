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
extern NSString * const kAlfrescoCloudWorkflowBaseURL;

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
extern NSString * const kAlfrescoPublicAPIWorkflowAttachmentsForProcess;
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
extern NSString * const kAlfrescoLegacyAPIWorkflowItemKind;
extern NSString * const kAlfrescoLegacyAPIWorkflowItemTypeTask;
extern NSString * const kAlfrescoLegacyAPIWorkflowItemID;
extern NSString * const kAlfrescoLegacyAPIWorkflowFields;
extern NSString * const kAlfrescoLegacyAPIWorkflowPackageItems;

// Person nodeRef
extern NSString * const kAlfrescoLegacyAPIPersonNodeRef;

extern NSString * const kAlfrescoWorkflowJBPMEnginePrefix;
extern NSString * const kAlfrescoWorkflowActivitiEnginePrefix;
extern NSString * const kAlfrescoWorkflowNodeRefPrefix;

// JSON
extern NSString * const kAlfrescoWorkflowPublicJSONEntry;
extern NSString * const kAlfrescoWorkflowPublicJSONIdentifier;
extern NSString * const kAlfrescoWorkflowPublicJSONKey;
extern NSString * const kAlfrescoWorkflowPublicJSONName;
extern NSString * const kAlfrescoWorkflowPublicJSONTitle;
extern NSString * const kAlfrescoWorkflowPublicJSONDescription;
extern NSString * const kAlfrescoWorkflowPublicJSONVersion;
extern NSString * const kAlfrescoWorkflowPublicJSONList;
extern NSString * const kAlfrescoWorkflowPublicJSONEntries;
extern NSString * const kAlfrescoWorkflowPublicJSONHasMoreItems;
extern NSString * const kAlfrescoWorkflowPublicJSONTotalItems;
extern NSString * const kAlfrescoWorkflowLegacyJSONMaxItems;
extern NSString * const kAlfrescoWorkflowLegacyJSONPagination;
extern NSString * const kAlfrescoWorkflowLegacyJSONTotalItems;

extern NSString * const kAlfrescoWorkflowPublicJSONProcessID;
extern NSString * const kAlfrescoWorkflowPublicJSONProcessDefinitionID;
extern NSString * const kAlfrescoWorkflowPublicJSONProcessDefinitionKey;
extern NSString * const kAlfrescoWorkflowPublicJSONStartedAt;
extern NSString * const kAlfrescoWorkflowPublicJSONEndedAt;
extern NSString * const kAlfrescoWorkflowPublicJSONDueAt;
extern NSString * const kAlfrescoWorkflowPublicJSONPriority;
extern NSString * const kAlfrescoWorkflowPublicJSONAssignee;
extern NSString * const kAlfrescoWorkflowPublicJSONProcessVariables;
extern NSString * const kAlfrescoWorkflowPublicJSONVariables;
extern NSString * const kAlfrescoWorkflowPublicJSONStartUserID;

extern NSString * const kAlfrescoWorkflowLegacyJSONProperties;
extern NSString * const kAlfrescoWorkflowLegacyJSONWorkflowInstance;
extern NSString * const kAlfrescoWorkflowLegacyJSONData;
extern NSString * const kAlfrescoWorkflowLegacyJSONBPMTaskID;
extern NSString * const kAlfrescoWorkflowLegacyJSONIdentifier;
extern NSString * const kAlfrescoWorkflowLegacyJSONName;
extern NSString * const kAlfrescoWorkflowLegacyJSONTitle;
extern NSString * const kAlfrescoWorkflowLegacyJSONMessage;
extern NSString * const kAlfrescoWorkflowLegacyJSONBPMStartedAt;
extern NSString * const kAlfrescoWorkflowLegacyJSONBPMEndedAt;
extern NSString * const kAlfrescoWorkflowLegacyJSONBPMDueAt;
extern NSString * const kAlfrescoWorkflowLegacyJSONBPMPriority;
extern NSString * const kAlfrescoWorkflowLegacyJSONBPMDescription;
extern NSString * const kAlfrescoWorkflowLegacyJSONBPMAssignee;
extern NSString * const kAlfrescoWorkflowLegacyJSONBPMPackageContainer;

extern NSString * const kAlfrescoWorkflowLegacyJSONOwner;

extern NSString * const kAlfrescoWorkflowPublicBPMJSONProcessTitle;
extern NSString * const kAlfrescoWorkflowPublicBPMJSONProcessDescription;
extern NSString * const kAlfrescoWorkflowPublicBPMJSONProcessPriority;
extern NSString * const kAlfrescoWorkflowPublicBPMJSONProcessAssignee;
extern NSString * const kAlfrescoWorkflowPublicBPMJSONProcessAssignees;
extern NSString * const kAlfrescoWorkflowPublicBPMJSONProcessSendEmailNotification;
extern NSString * const kAlfrescoWorkflowPublicBPMJSONProcessDueDate;
extern NSString * const kAlfrescoWorkflowPublicBPMJSONProcessApprovalRate;

extern NSString * const kAlfrescoWorkflowLegacyJSONBPMProcessDescription;
extern NSString * const kAlfrescoWorkflowLegacyJSONLegacyProcessPriority;
extern NSString * const kAlfrescoWorkflowLegacyJSONBPMProcessAssignee;
extern NSString * const kAlfrescoWorkflowLegacyJSONBPMProcessAssignees;
extern NSString * const kAlfrescoWorkflowLegacyJSONBPMProcessSendEmailNotification;
extern NSString * const kAlfrescoWorkflowLegacyJSONBPMProcessDueDate;
extern NSString * const kAlfrescoWorkflowLegacyJSONBPMProcessAttachments;
extern NSString * const kAlfrescoWorkflowLegacyJSONBPMProcessAttachmentsAdd;
extern NSString * const kAlfrescoWorkflowLegacyJSONBPMProcessAttachmentsRemove;
extern NSString * const kAlfrescoWorkflowLegacyJSONBPMProcessApprovalRate;

extern NSString * const kAlfrescoWorkflowLegacyJSONBPMTransition;
extern NSString * const kAlfrescoWorkflowLegacyJSONBPMStatus;
extern NSString * const kAlfrescoWorkflowLegacyJSONBPMReviewOutcome;
extern NSString * const kAlfrescoWorkflowLegacyJSONBPMComment;
extern NSString * const kAlfrescoWorkflowLegacyJSONNext;
extern NSString * const kAlfrescoWorkflowLegacyJSONCompleted;
extern NSString * const kAlfrescoWorkflowLegacyJSONItemValue;

extern NSString * const kAlfrescoWorkflowLegacyJSONProcessDefinitionID;
extern NSString * const kAlfrescoWorkflowLegacyJSONStartedAt;
extern NSString * const kAlfrescoWorkflowLegacyJSONEndedAt;
extern NSString * const kAlfrescoWorkflowLegacyJSONDueAt;
extern NSString * const kAlfrescoWorkflowLegacyJSONPriority;
extern NSString * const kAlfrescoWorkflowLegacyJSONDescription;
extern NSString * const kAlfrescoWorkflowLegacyJSONInitiator;
extern NSString * const kAlfrescoWorkflowLegacyJSONFormData;

extern NSString * const kAlfrescoWorkflowPublicJSONVariableName;
extern NSString * const kAlfrescoWorkflowPublicJSONVariableType;
extern NSString * const kAlfrescoWorkflowPublicJSONVariableValue;

extern NSString * const kAlfrescoWorkflowEngineType;
extern NSString * const kAlfrescoWorkflowUsingPublicAPI;
