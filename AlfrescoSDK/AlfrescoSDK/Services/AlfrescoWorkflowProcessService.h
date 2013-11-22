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

/** AlfrescoWorkflowProcessService
 
 Author: Tauseef Mughal (Alfresco)
 */

#import <Foundation/Foundation.h>
#import "AlfrescoRequest.h"
#import "AlfrescoConstants.h"

@class AlfrescoWorkflowProcessDefinition;

@interface AlfrescoWorkflowProcessService : NSObject

/**---------------------------------------------------------------------------------------
 * @name Initialialisation methods
 *  ---------------------------------------------------------------------------------------
 */

/** Initialises with a public or old API implementation
 
 @param session the AlfrescoSession to initialise the site service with
 */
- (id)initWithSession:(id<AlfrescoSession>)session;

/**---------------------------------------------------------------------------------------
 * @name Retrieval methods for the Alfresco Workflow Process Service
 *  ---------------------------------------------------------------------------------------
 */

/**
 Retrieves a list of all processes.
 
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveAllProcessesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock;

/**
 Retrieves a paged result of processes in accordance to a listing context.
 
 @param listingContext The listing context with a paging definition that's used to retrieve the processes
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveProcessesWithListingContext:(AlfrescoListingContext *)listingContext completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock;

/**
 Retrieves an array of processes that are in a given state.
 
 Valid states can be found in AlfrescoConstants.h.
 
 @param state State of the processes to retrieve
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveProcessesInState:(NSString *)state completionBlock:(AlfrescoArrayCompletionBlock)completionBlock;

/**
 Retrieves a paged result of the of processes that are in a given state in accordance to the listing context provided.
 
 Valid states can be found in AlfrescoConstants.h.
 
 @param state State of the process to retrieve
 @param listingContext The listing context with a paging definition that's used to retrieve the processes
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveProcessesInState:(NSString *)state listingContext:(AlfrescoListingContext *)listingContext completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock;

/**
 Retrieves a process for a given process identifier.
 
 @param processID The process identifier of the process to retrieve
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveProcessWithIdentifier:(NSString *)processID completionBlock:(AlfrescoProcessCompletionBlock)completionBlock;

/**
 Retrieves any variables on a given any given process.
 
 @param process The process for which you would like to retrieve the variables for
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveVariablesForProcess:(AlfrescoWorkflowProcess *)process completionBlock:(AlfrescoProcessCompletionBlock)completionBlock;

/**
 Retrieves an array of all tasks that the user is able to see. Tasks are returned if created by the user, or if the user is involved in the task.
 
 @param process The process for which task(s) should be retrieved
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveAllTasksForProcess:(AlfrescoWorkflowProcess *)process completionBlock:(AlfrescoArrayCompletionBlock)completionBlock;

/**
 Retrieves an array of all tasks that the user is able to see which are in a specific state. Tasks are returned if created by the user, or if the user is involved in the task.
 
 @param process The process for which task(s) should be retrieved
 @param state State of that task(s) to retrieve
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveTasksForProcess:(AlfrescoWorkflowProcess *)process inState:(NSString *)status completionBlock:(AlfrescoArrayCompletionBlock)completionBlock;

/**
 Retrieves an array of AlfrescoNode's attached to a given task.
 
 @param task The task for which attachements should be retrieved
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveAttachmentsForTask:(AlfrescoWorkflowTask *)task completionBlock:(AlfrescoArrayCompletionBlock)completionBlock;

/**
 Retrieves an image of the given process. An image is only returned if the user has started the process or is involved in any of the tasks.
 
 @param process The process for which an image should be retrieved
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveProcessImage:(AlfrescoWorkflowProcess *)process completionBlock:(AlfrescoContentFileCompletionBlock)completionBlock;

/**
 Retrieves an image of the provided process written to a given outputstream. An image is only returned if the user has started the process or is involved in any of the tasks.
 
 @param process The process for which an image should be retrieved
 @param outputStream The stream to which the image will be written
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveProcessImage:(AlfrescoWorkflowProcess *)process outputStream:(NSOutputStream *)outputStream completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock;

/**---------------------------------------------------------------------------------------
 * @name Add methods for the Alfresco Workflow Process Service
 *  ---------------------------------------------------------------------------------------
 */

/**
 Creates and returns a process for a gievn process definition.
 
 @param processDefinition The process definition the process should be modeled on
 @param assignees (optional) An array of AlfrescoPerson's to assign to the task. If this is left blank, the process will be assigned to the creator
 @param variables (optional) A dictionary of process variables to add at the start of the process
 @param attachments (optional) An array of AlfrescoNode's to add to the process
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)startProcessForProcessDefinition:(AlfrescoWorkflowProcessDefinition *)processDefinition assignees:(NSArray *)assignees variables:(NSDictionary *)variables attachments:(NSArray *)attachmentNodes completionBlock:(AlfrescoProcessCompletionBlock)completionBlock;

/**
 Adds an attachment to the provided process.
 
 @param node The attachment to be added to the process
 @param process The process for which you would like to add an attachment
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)addAttachment:(AlfrescoNode *)node toProcess:(AlfrescoWorkflowTask *)process completionBlock:(AlfrescoProcessCompletionBlock)completionBlock;

/**---------------------------------------------------------------------------------------
 * @name Update methods for the Alfresco Workflow Process Service
 *  ---------------------------------------------------------------------------------------
 */

/**
 Updates the variables provided on the given process. Variables that are not currently present will be added to the process.
 
 @param variables A dictionary of process variables to add or update to the process
 @param process The process to which variables should be added/updated
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)updateVariables:(NSDictionary *)variables forProcess:(AlfrescoWorkflowProcess *)process completionBlock:(AlfrescoProcessCompletionBlock)completionBlock;

/**---------------------------------------------------------------------------------------
 * @name Removal methods for the Alfresco Workflow Process Service
 *  ---------------------------------------------------------------------------------------
 */

/**
 Deletes a process.
 
 @param process The process to delete
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)deleteProcess:(AlfrescoWorkflowProcess *)process completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock;

/**
 Removes the list of variables provided on a given process.
 
 @param variablesKeys The keys of the variables you wish to remove
 @param process The process for which you would like to remove the variables
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)removeVariables:(NSArray *)variablesKeys forProcess:(AlfrescoWorkflowProcess *)process completionBlock:(AlfrescoProcessCompletionBlock)completionBlock;

/**
 Removes an attachement from a given process.
 
 @param node The node you wish to remove from the process
 @param task The task for which you would like to remove the attachment
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)removeAttachment:(AlfrescoNode *)node fromTask:(AlfrescoWorkflowTask *)task completionBlock:(AlfrescoProcessCompletionBlock)completionBlock;

@end
