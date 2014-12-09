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
#import "AlfrescoSession.h"

@interface AlfrescoModelDefinitionService : NSObject

/** Initialises with a standard Cloud or OnPremise session.
 
 @param session the AlfrescoSession to initialise the model definition service with.
 */
- (id)initWithSession:(id<AlfrescoSession>)session;

/** Retrieves the definition of the given document type.
 
 @param type The name of the type to be retrieved, for example "cm:content".
 @param completionBlock The block that's called with the definition of the type.
 */
- (AlfrescoRequest *)retrieveDefinitionForDocumentType:(NSString *)type
                                       completionBlock:(AlfrescoDocumentTypeDefinitionCompletionBlock)completionBlock;

/** Retrieves the definition of the given document. The definition of any properties defined by aspects applied
    to the document will also be included in the returned type definition.
 
 @param document The document to retrieve the type definition for.
 @param completionBlock The block that's called with the definition of the type.
 */
- (AlfrescoRequest *)retrieveDefinitionForDocument:(AlfrescoDocument *)document
                                   completionBlock:(AlfrescoDocumentTypeDefinitionCompletionBlock)completionBlock;

/** Retrieves the definition of the given folder type.
 
 @param type The name of the type to be retrieved, for example "cm:folder".
 @param completionBlock The block that's called with the definition of the type.
 */
- (AlfrescoRequest *)retrieveDefinitionForFolderType:(NSString *)type
                                     completionBlock:(AlfrescoFolderTypeDefinitionCompletionBlock)completionBlock;

/** Retrieves the definition of the given folder. The definition of any properties defined by aspects applied
 to the folder will also be included in the returned type definition.
 
 @param folder The folder to retrieve the type definition for.
 @param completionBlock The block that's called with the definition of the type.
 */
- (AlfrescoRequest *)retrieveDefinitionForFolder:(AlfrescoFolder *)folder
                                 completionBlock:(AlfrescoFolderTypeDefinitionCompletionBlock)completionBlock;

/** Retrieves the definition of the given aspect.
 
 @param aspect The name of the aspect to be retrieved, for example "exif:exif".
 @param completionBlock The block that's called with the definition of the aspect.
 */
- (AlfrescoRequest *)retrieveDefinitionForAspect:(NSString *)aspect
                                 completionBlock:(AlfrescoAspectDefinitionCompletionBlock)completionBlock;

/** Retrieves the definition of the given task type.
 
 @param type The name of the type to be retrieved, for example "bpm:task".
 @param completionBlock The block that's called with the definition of the type.
 */
- (AlfrescoRequest *)retrieveDefinitionForTaskType:(NSString *)type
                                   completionBlock:(AlfrescoTaskTypeDefinitionCompletionBlock)completionBlock;

/** Retrieves the definition of the given task.
 
 @param task The task to retrieve the type definition for.
 @param completionBlock The block that's called with the definition of the type.
 */
- (AlfrescoRequest *)retrieveDefinitionForTask:(AlfrescoWorkflowTask *)task
                               completionBlock:(AlfrescoTaskTypeDefinitionCompletionBlock)completionBlock;

/**
 Clears any cached state the service has.
 */
- (void)clear;

@end
