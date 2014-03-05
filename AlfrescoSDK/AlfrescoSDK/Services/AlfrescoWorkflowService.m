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

#import "AlfrescoWorkflowService.h"
#import "AlfrescoPlaceholderWorkflowService.h"

@implementation AlfrescoWorkflowService

+ (id)alloc
{
    if (self == [AlfrescoWorkflowService self])
    {
        return [AlfrescoPlaceholderWorkflowService alloc];
    }
    return [super alloc];
}

- (id)initWithSession:(id<AlfrescoSession>)session
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)retrieveProcessDefinitionsWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)retrieveProcessDefinitionsWithListingContext:(AlfrescoListingContext *)listingContext
                                                  completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)retrieveProcessDefinitionWithIdentifier:(NSString *)processDefinitionId
                                             completionBlock:(AlfrescoProcessDefinitionCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)retrieveProcessesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)retrieveProcessesWithListingContext:(AlfrescoListingContext *)listingContext
                                         completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)retrieveProcessesInState:(NSString *)state
                              completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)retrieveProcessesInState:(NSString *)state
                               listingContext:(AlfrescoListingContext *)listingContext
                              completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)retrieveProcessWithIdentifier:(NSString *)processIdentifier
                                   completionBlock:(AlfrescoProcessCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)retrieveImageForProcess:(AlfrescoWorkflowProcess *)process
                             completionBlock:(AlfrescoContentFileCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)retrieveImageForProcess:(AlfrescoWorkflowProcess *)process
                                outputStream:(NSOutputStream *)outputStream
                             completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)retrieveTasksForProcess:(AlfrescoWorkflowProcess *)process
                             completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)retrieveTasksForProcess:(AlfrescoWorkflowProcess *)process
                                     inState:(NSString *)status
                             completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)retrieveAttachmentsForProcess:(AlfrescoWorkflowProcess *)process
                                   completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)retrieveTasksWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)retrieveTasksWithListingContext:(AlfrescoListingContext *)listingContext
                                     completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)retrieveTaskWithIdentifier:(NSString *)taskIdentifier
                                completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)retrieveAttachmentsForTask:(AlfrescoWorkflowTask *)task
                                completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)startProcessForProcessDefinition:(AlfrescoWorkflowProcessDefinition *)processDefinition
                                            assignees:(NSArray *)assignees
                                            variables:(NSDictionary *)variables
                                          attachments:(NSArray *)attachmentNodes
                                      completionBlock:(AlfrescoProcessCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)deleteProcess:(AlfrescoWorkflowProcess *)process
                   completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)completeTask:(AlfrescoWorkflowTask *)task
                       properties:(NSDictionary *)properties
                  completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)claimTask:(AlfrescoWorkflowTask *)task
               completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)unclaimTask:(AlfrescoWorkflowTask *)task
                 completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)reassignTask:(AlfrescoWorkflowTask *)task
                       toAssignee:(AlfrescoPerson *)assignee
                  completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)resolveTask:(AlfrescoWorkflowTask *)task
                 completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)addAttachmentToTask:(AlfrescoWorkflowTask *)task
                              attachment:(AlfrescoNode *)node
                         completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)addAttachmentsToTask:(AlfrescoWorkflowTask *)task
                              attachments:(NSArray *)nodeArray
                          completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)removeAttachmentFromTask:(AlfrescoWorkflowTask *)task
                                   attachment:(AlfrescoNode *)node
                              completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
