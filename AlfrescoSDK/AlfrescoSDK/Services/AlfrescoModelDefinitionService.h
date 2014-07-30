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
#import "AlfrescoDocumentTypeDefinition.h"
#import "AlfrescoFolderTypeDefinition.h"
#import "AlfrescoTaskTypeDefinition.h"
#import "AlfrescoAspectDefinition.h"

// TODO: move to public constants file...
typedef void (^AlfrescoDocumentTypeDefinitionCompletionBlock)(AlfrescoDocumentTypeDefinition *typeDefinition, NSError *error);
typedef void (^AlfrescoFolderTypeDefinitionCompletionBlock)(AlfrescoFolderTypeDefinition *typeDefinition, NSError *error);
typedef void (^AlfrescoTaskTypeDefinitionCompletionBlock)(AlfrescoTaskTypeDefinition *typeDefinition, NSError *error);
typedef void (^AlfrescoAspectDefinitionCompletionBlock)(AlfrescoAspectDefinition *aspectDefinition, NSError *error);


@interface AlfrescoModelDefinitionService : NSObject

/**---------------------------------------------------------------------------------------
 * @name Initialisation methods
 *  ---------------------------------------------------------------------------------------
 */

/** Initialises with a standard Cloud or OnPremise session.
 
 @param session the AlfrescoSession to initialise the config service with.
 */
- (id)initWithSession:(id<AlfrescoSession>)session;

- (AlfrescoRequest *)retrieveDefinitionForDocumentType:(NSString *)type
                                       completionBlock:(AlfrescoDocumentTypeDefinitionCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveDefinitionForDocument:(AlfrescoDocument *)document
                                   completionBlock:(AlfrescoDocumentTypeDefinitionCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveDefinitionForFolderType:(NSString *)type
                                     completionBlock:(AlfrescoFolderTypeDefinitionCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveDefinitionForFolder:(AlfrescoFolder *)folder
                                 completionBlock:(AlfrescoFolderTypeDefinitionCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveDefinitionForAspect:(NSString *)aspect
                                 completionBlock:(AlfrescoAspectDefinitionCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveDefinitionForTaskType:(NSString *)type
                                   completionBlock:(AlfrescoTaskTypeDefinitionCompletionBlock)completionBlock;


- (AlfrescoRequest *)retrieveDefinitionForTask:(AlfrescoWorkflowTask *)task
                               completionBlock:(AlfrescoTaskTypeDefinitionCompletionBlock)completionBlock;

/**
 Clears any cached state the service has.
 */
- (void)clear;

@end
