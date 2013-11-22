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

/** AlfrescoWorkflowTaskService
 
 Author: Tauseef Mughal (Alfresco)
 */

#import <Foundation/Foundation.h>
#import "AlfrescoRequest.h"
#import "AlfrescoConstants.h"
#import "AlfrescoWorkflowTask.h"

@interface AlfrescoWorkflowTaskService : NSObject

/**
 Initialises with a public or old API implementation
 
 @param session the AlfrescoSession to initialise the site service with
 */
- (id)initWithSession:(id<AlfrescoSession>)session;

/**---------------------------------------------------------------------------------------
 * @name Retrieval methods for the Alfresco Workflow Task Service
 *  ---------------------------------------------------------------------------------------
 */

/**
 Retrieves a list of all tasks.
 
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveAllTasksWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock;

/**
 Retrieves a paged result of the tasks the authenticated user is allowed to see.
 
 @param listingContext The listing context with a paging definition that's used to retrieve the tasks
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveTasksWithListingContext:(AlfrescoListingContext *)listingContext completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock;

/**
 Retrieves the task for a specific task identifier.
 
 @param taskIdentifier The task identifier for the task to retrieve
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveTaskWithIdentifier:(NSString *)taskIdentifier completionBlock:(AlfrescoTaskCompletionBlock)completionBlock;

/**
 Retrieves an array of AlfrescoNode's for a specific task. If there are no attachments, nil is returned in the completion block.
 
 @param task The task for which attachements should be retrieved
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveAttachmentsForTask:(AlfrescoWorkflowTask *)task completionBlock:(AlfrescoArrayCompletionBlock)completionBlock;

/**---------------------------------------------------------------------------------------
 * @name Task assignment methods for the Alfresco Workflow Task Service
 *  ---------------------------------------------------------------------------------------
 */

/**
 Completes a given task.
 
 @param task The task that should be marked as complete
 @param properties Any properties to add to the task
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)completeTask:(AlfrescoWorkflowTask *)task properties:(NSDictionary *)properties completionBlock:(AlfrescoTaskCompletionBlock)completionBlock;

/**
 Claims the task for the authenticated user.
 
 @param task The task to be claimed by the authenticated user
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)claimTask:(AlfrescoWorkflowTask *)task completionBlock:(AlfrescoTaskCompletionBlock)completionBlock;

/**
 Unclaims a task and sets the assignee to "Unassigned".
 
 @param task The task the be unclaimed by the authenticated user
 @param properties Any properties to add to the task before completion
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)unclaimTask:(AlfrescoWorkflowTask *)task completionBlock:(AlfrescoTaskCompletionBlock)completionBlock;

/**
 Assigns the given task to an assignee.
 
 @param task The task to be assigned
 @param assignee To whom the task should be assigned
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)assignTask:(AlfrescoWorkflowTask *)task toAssignee:(AlfrescoPerson *)assignee completionBlock:(AlfrescoTaskCompletionBlock)completionBlock;

/**
 Resolves the given task and assigns it back to the owner.
 
 @param task The task which should be resolved
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)resolveTask:(AlfrescoWorkflowTask *)task completionBlock:(AlfrescoTaskCompletionBlock)completionBlock;

/**---------------------------------------------------------------------------------------
 * @name Add methods for the Alfresco Workflow Task Service
 *  ---------------------------------------------------------------------------------------
 */

/**
 Adds a single attachment to a given task.
 
 @param node The node that should be added to the task
 @param task The task which the node should be attached
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)addAttachment:(AlfrescoNode *)node toTask:(AlfrescoWorkflowTask *)task completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock;

/**
 Adds an array of attachments to a given task.
 
 @param nodeArray An array of AlfrescoNode's that should be added to the task
 @param task The task to which the nodes should be attached
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)addAttachments:(NSArray *)nodeArray toTask:(AlfrescoWorkflowTask *)task completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock;

/**---------------------------------------------------------------------------------------
 * @name Removal methods for the Alfresco Workflow Task Service
 *  ---------------------------------------------------------------------------------------
 */

/**
 Removes an attachment from a specific task.
 
 @param node The node that should be removed from the task
 @param task The task from which the node should be removed
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)removeAttachment:(AlfrescoNode *)node fromTask:(AlfrescoWorkflowTask *)task completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock;

@end
