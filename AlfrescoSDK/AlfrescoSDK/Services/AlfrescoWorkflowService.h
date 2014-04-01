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

/** AlfrescoWorkflowService
 
 Author: Tauseef Mughal (Alfresco)
 */

#import <Foundation/Foundation.h>
#import "AlfrescoConstants.h"
#import "AlfrescoRequest.h"

@interface AlfrescoWorkflowService : NSObject

/**---------------------------------------------------------------------------------------
 * @name Initialisation methods
 *  ---------------------------------------------------------------------------------------
 */

/**
 Initialises with a public or old API implementation
 
 @param session the AlfrescoSession to initialise the site service with
 */
- (id)initWithSession:(id<AlfrescoSession>)session;

/**---------------------------------------------------------------------------------------
 * @name Retrieval methods for the Alfresco Workflow Service
 *  ---------------------------------------------------------------------------------------
 */

/**
 Retrieves a list of all process definitions.
 
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveProcessDefinitionsWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock;

/**
 Retrieves a paged result of all process definitions in accordance to a listing context.
 
 @param listingContext The listing context with a paging definition that's used to retrieve process definitions
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveProcessDefinitionsWithListingContext:(AlfrescoListingContext *)listingContext
                                                  completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock;

/**
 Retrieves a process definition for a specific process identifier.
 
 @param processDefinitionId The process definition identifier for the process definition to be retrieved
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveProcessDefinitionWithIdentifier:(NSString *)processDefinitionId
                                             completionBlock:(AlfrescoProcessDefinitionCompletionBlock)completionBlock;

/**
 Retrieves a process definition for a specific process identifier.
 
 @param key The process definition key for the process definition to be retrieved
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveProcessDefinitionWithKey:(NSString *)key
                                      completionBlock:(AlfrescoProcessDefinitionCompletionBlock)completionBlock;

/**
 Retrieves a list of all processes.
 
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveProcessesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock;

/**
 Retrieves a paged result of processes in accordance to a listing context.
 The listing filter mechanism on listing context can be used to filter the processes.
 
 @param listingContext The listing context with a paging definition that's used to retrieve the processes
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveProcessesWithListingContext:(AlfrescoListingContext *)listingContext
                                         completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock;

/**
 Retrieves a process for a given process identifier.
 
 @param processID The process identifier of the process to retrieve
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveProcessWithIdentifier:(NSString *)processIdentifier
                                   completionBlock:(AlfrescoProcessCompletionBlock)completionBlock;

/**
 Retrieves an image of the given process. An image is only returned if the user has started the process or is involved in any of the tasks.
 
 @param process The process for which an image should be retrieved
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveImageForProcess:(AlfrescoWorkflowProcess *)process
                             completionBlock:(AlfrescoContentFileCompletionBlock)completionBlock;

/**
 Retrieves an image of the provided process written to a given outputstream. An image is only returned if the user has started the process or is involved in any of the tasks.
 
 @param process The process for which an image should be retrieved
 @param outputStream The stream to which the image will be written
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveImageForProcess:(AlfrescoWorkflowProcess *)process
                                outputStream:(NSOutputStream *)outputStream
                             completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock;

/**
 Retrieves an array of all tasks for the given process that the user is able to see.
 Tasks are returned if created by the user, or if the user is involved in the task.
 
 @param process The process for which task(s) should be retrieved
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveTasksForProcess:(AlfrescoWorkflowProcess *)process
                             completionBlock:(AlfrescoArrayCompletionBlock)completionBlock;

/**
 Retrieves paged results of all tasks for the given process that the user is able to see.
 The listing filter mechanism on listing context can be used to filter the tasks.
 Tasks are returned if created by the user, or if the user is involved in the task.
 
 @param process The process for which task(s) should be retrieved
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveTasksForProcess:(AlfrescoWorkflowProcess *)process
                              listingContext:(AlfrescoListingContext *)listingContext
                             completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock;

/**
 Retrieves an array of AlfrescoNode's for a specific process. If there are no attachments, nil is returned in the completion block.
 
 @param process The process for which attachment(s) should be retrieved
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveAttachmentsForProcess:(AlfrescoWorkflowProcess *)process
                             completionBlock:(AlfrescoArrayCompletionBlock)completionBlock;

/**
 Retrieves a list of all tasks the authenticated user is allowed to see.
 
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveTasksWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock;

/**
 Retrieves a paged result of the tasks the authenticated user is allowed to see.
 The listing filter mechanism on listing context can be used to filter the tasks.
 
 @param listingContext The listing context with a paging definition that's used to retrieve the tasks
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveTasksWithListingContext:(AlfrescoListingContext *)listingContext
                                     completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock;

/**
 Retrieves the task for a specific task identifier.
 
 @param taskIdentifier The task identifier for the task to retrieve
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveTaskWithIdentifier:(NSString *)taskIdentifier
                                completionBlock:(AlfrescoTaskCompletionBlock)completionBlock;

/**
 Retrieves an array of AlfrescoNode's for a specific task. If there are no attachments, nil is returned in the completion block.
 
 @param task The task for which attachments should be retrieved
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveAttachmentsForTask:(AlfrescoWorkflowTask *)task
                                completionBlock:(AlfrescoArrayCompletionBlock)completionBlock;


/**---------------------------------------------------------------------------------------
 * @name Process management methods for the Alfresco Workflow Service
 *  ---------------------------------------------------------------------------------------
 */

/**
 Creates and returns a process for a given process definition.
 
 @param processDefinition The process definition the process should be modeled on
 @param assignees (optional) An array of AlfrescoPerson's to assign to the task. If this is left blank, the process will be assigned to the creator
 @param variables (optional) A dictionary of process variables to add at the start of the process. Variable keys must be the same as those defined in the workflow model definition in the repository
 @param attachments (optional) An array of AlfrescoNode's to add to the process
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)startProcessForProcessDefinition:(AlfrescoWorkflowProcessDefinition *)processDefinition
                                            assignees:(NSArray *)assignees
                                            variables:(NSDictionary *)variables
                                          attachments:(NSArray *)attachmentNodes
                                      completionBlock:(AlfrescoProcessCompletionBlock)completionBlock;

/**
 A convenience method that creates and returns a process for a given process definition. This method takes an number of predefined variables.
 
 @param processDefinition The process definition the process should be modeled on
 @param name (optional) A descripton of the process to be created
 @param priority (optional) The priority level of the process to be created
 @param dueDate (optional) The due date of the process to be created
 @param sendEmail (optional) Whather email notifications should be sent
 @param assignees (optional) An array of AlfrescoPerson's to assign to the task. If this is left blank, the process will be assigned to the creator
 @param variables (optional) A dictionary of process variables to add at the start of the process. Variable keys must be the same as those defined in the workflow model definition in the repository
 @param attachments (optional) An array of AlfrescoNode's to add to the process
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)startProcessForProcessDefinition:(AlfrescoWorkflowProcessDefinition *)processDefinition
                                                 name:(NSString *)name
                                             priority:(NSNumber *)priority
                                              dueDate:(NSDate *)dueDate
                                sendEmailNotification:(NSNumber *)sendEmail
                                            assignees:(NSArray *)assignees
                                            variables:(NSDictionary *)variables
                                          attachments:(NSArray *)attachmentNodes
                                      completionBlock:(AlfrescoProcessCompletionBlock)completionBlock;

/**
 Deletes a process.
 
 @param process The process to delete
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)deleteProcess:(AlfrescoWorkflowProcess *)process
                   completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock;


/**---------------------------------------------------------------------------------------
 * @name Task management methods for the Alfresco Workflow Service
 *  ---------------------------------------------------------------------------------------
 */

/**
 Completes a given task.
 
 @param task The task that should be marked as complete
 @param properties Any properties to add to the task
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)completeTask:(AlfrescoWorkflowTask *)task
                       properties:(NSDictionary *)properties
                  completionBlock:(AlfrescoTaskCompletionBlock)completionBlock;

/**
 Claims the task for the authenticated user.
 
 @param task The task to be claimed by the authenticated user
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)claimTask:(AlfrescoWorkflowTask *)task
               completionBlock:(AlfrescoTaskCompletionBlock)completionBlock;

/**
 Unclaims a task and sets the assignee to "Unassigned".
 
 @param task The task the be unclaimed by the authenticated user
 @param properties Any properties to add to the task before completion
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)unclaimTask:(AlfrescoWorkflowTask *)task
                 completionBlock:(AlfrescoTaskCompletionBlock)completionBlock;

/**
 Reassigns the given task to an assignee.
 
 @param task The task to be reassigned
 @param assignee To whom the task should be assigned
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)reassignTask:(AlfrescoWorkflowTask *)task
                       toAssignee:(AlfrescoPerson *)assignee
                  completionBlock:(AlfrescoTaskCompletionBlock)completionBlock;

/**
 Resolves the given task and assigns it back to the owner.
 
 @param task The task which should be resolved
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)resolveTask:(AlfrescoWorkflowTask *)task
                 completionBlock:(AlfrescoTaskCompletionBlock)completionBlock;

/**
 Adds a single attachment to a given task.
 
 @param task The task which the node should be attached
 @param document The document that should be added to the task
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)addAttachmentToTask:(AlfrescoWorkflowTask *)task
                              attachment:(AlfrescoDocument *)document
                         completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock;

/**
 Adds an array of attachments to a given task.
 
 @param task The task to which the nodes should be attached
 @param documentArray An array of AlfrescoDocuments's that should be added to the task
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)addAttachmentsToTask:(AlfrescoWorkflowTask *)task
                              attachments:(NSArray *)documentArray
                          completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock;

/**
 Removes an attachment from a specific task.
 
 @param task The task from which the node should be removed
 @param document The document that should be removed from the task
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)removeAttachmentFromTask:(AlfrescoWorkflowTask *)task
                                   attachment:(AlfrescoDocument *)document
                              completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock;

@end
