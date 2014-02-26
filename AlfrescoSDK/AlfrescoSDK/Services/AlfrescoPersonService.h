/*
 ******************************************************************************
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
 *****************************************************************************
 */

#import "AlfrescoConstants.h"
#import "AlfrescoSession.h"
#import "AlfrescoPerson.h"
#import "AlfrescoRequest.h"
/** The AlfrescoPersonService to obtain details about registered users.
 
 Author: Gavin Cornwell (Alfresco), Tijs Rademakers (Alfresco), Peter Schmidt (Alfresco)
 */

@interface AlfrescoPersonService : NSObject
/**---------------------------------------------------------------------------------------
 * @name Initialisation methods
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
- (AlfrescoRequest *)retrievePersonWithIdentifier:(NSString *)identifier completionBlock:(AlfrescoPersonCompletionBlock)completionBlock;

/** Gets the person with given identifier
 
 @param person - AlfrescoPerson object for which the avatar is being retrieved.
 @param completionBlock - contains the AlfrescoContentFile object with a pointer to the avatar image if successful, or nil if not.
 */
- (AlfrescoRequest *)retrieveAvatarForPerson:(AlfrescoPerson *)person completionBlock:(AlfrescoContentFileCompletionBlock)completionBlock;

/**---------------------------------------------------------------------------------------
 * @name Search Person methods
 *  ---------------------------------------------------------------------------------------
 */
/** Returns a list of site members that respect the provided keywords.
 
 @param keywords - space delimited list of keywords that needs to be applied to search query.
 @param completionBlock - contains Array of person objects that respect the filter if successful, or nil if not.
 */
- (AlfrescoRequest *)searchWithKeywords:(NSString *)keywords
                        completionBlock:(AlfrescoArrayCompletionBlock)completionBlock;

/** Returns a paged list of site members that respect the provided keywords.
 
 @param keywords -  space delimited list of keywords that needs to be applied to search query.
 @param listingContext - The listing context with a paging definition that's used to search for people.
 @param completionBlock - contains Array of person objects that respect the filter if successful, or nil if not.
 */
- (AlfrescoRequest *)searchWithKeywords:(NSString *)keywords
                         listingContext:(AlfrescoListingContext *)listingContext
                        completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock;

/** Retrieve the latest (and complete) properties for person.
 
 @param The person which is to be refreshed with its latest properties
 @param completionBlock The block that's called with person's complete properties.
 */
- (AlfrescoRequest *)refreshPerson:(AlfrescoPerson *)person
                   completionBlock:(AlfrescoPersonCompletionBlock)completionBlock;

@end
