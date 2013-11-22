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

/** AlfrescoWorkflowProcessDefinitionService
 
 Author: Tauseef Mughal (Alfresco)
 */

#import <Foundation/Foundation.h>
#import "AlfrescoConstants.h"
#import "AlfrescoRequest.h"

@interface AlfrescoWorkflowProcessDefinitionService : NSObject

/**---------------------------------------------------------------------------------------
 * @name Initialialisation methods
 *  ---------------------------------------------------------------------------------------
 */

/**
 Initialises with a public or old API implementation
 
 @param session the AlfrescoSession to initialise the site service with
 */
- (id)initWithSession:(id<AlfrescoSession>)session;

/**---------------------------------------------------------------------------------------
 * @name Retrieval methods for the Alfresco Workflow Process Service
 *  ---------------------------------------------------------------------------------------
 */

/**
 Retrieves a list of all process definitions.
 
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveAllProcessDefinitionsWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock;

/**
 Retrieves a paged result of all process defintions in accordance to a listing context.
 
 @param listingContext The listing context with a paging definition that's used to retrieve process definitions
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveProcessDefinitionsWithListingContext:(AlfrescoListingContext *)listingContext completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock;

/**
 Retrieves a process definition for a specific process identifier.
 
 @param processDefinitionId The process definition identifier for the process definition to be retrieved
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveProcessDefinitionWithIdentifier:(NSString *)processDefinitionId completionBlock:(AlfrescoProcessDefinitionCompletionBlock)completionBlock;

/**
 Retrieves the form model for a specific process definition identifier.
 
 @param processIdentifier The process identifier for which the form model should be retrieved
 @param completionBlock The block that's called with the operation completes
 */
- (AlfrescoRequest *)retrieveFormModelForProcess:(NSString *)processDefinitionId completionBlock:(AlfrescoDictionaryCompletionBlock)completionBlock;

@end
