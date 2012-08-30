/*******************************************************************************
 * Copyright (C) 2005-2012 Alfresco Software Limited.
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
 ******************************************************************************/

#import "AlfrescoConstants.h"
#import "AlfrescoSession.h"
#import "AlfrescoPerson.h"
/** The AlfrescoPersonService to obtain details about registered users.
 
 Author: Peter Schmidt (Alfresco)
 */

@interface AlfrescoPersonService : NSObject
/**---------------------------------------------------------------------------------------
 * @name Initialialisation methods
 *  ---------------------------------------------------------------------------------------
 */

/** Initialises with a standard Cloud or OnPremise session
 
 @param session the AlfrescoSession to initialise the site service with.
 */
- (id)initWithSession:(id<AlfrescoSession>)session;

/**---------------------------------------------------------------------------------------
 * @name Person Retrieval methods
 *  ---------------------------------------------------------------------------------------
 */
/** Gets the person with given identifier
 
 @param identifier - The person identifier to be looked up.
 @param completionBlock - contains the AlfrescoPerson object if successful, or nil if not.
 */
- (void)retrievePersonWithIdentifier:(NSString *)identifier completionBlock:(AlfrescoPersonCompletionBlock)completionBlock;

/** Gets the person with given identifier
 
 @param person - AlfrescoPerson object for which the avatar is being retrieved.
 @param completionBlock - contains the AlfrescoContentFile object with a pointer to the avatar image if successful, or nil if not.
 */
- (void)retrieveAvatarForPerson:(AlfrescoPerson *)person completionBlock:(AlfrescoContentFileCompletionBlock)completionBlock;
@end
