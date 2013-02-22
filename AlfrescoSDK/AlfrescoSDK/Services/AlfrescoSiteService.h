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

#import <Foundation/Foundation.h>
#import "AlfrescoConstants.h"
#import "AlfrescoSession.h"
#import "AlfrescoSite.h"
#import "AlfrescoRequest.h"

/** The AlfrescoSiteService provides various ways to retrieve sites from an Alfresco repository.
 
 Author: Gavin Cornwell (Alfresco), Tijs Rademakers (Alfresco), Peter Schmidt (Alfresco)
 */


@interface AlfrescoSiteService : NSObject

/**---------------------------------------------------------------------------------------
 * @name Initialialisation methods
 *  ---------------------------------------------------------------------------------------
 */

/** Initialises with a standard Cloud or OnPremise session
 
 @param session the AlfrescoSession to initialise the site service with.
 */
- (id)initWithSession:(id<AlfrescoSession>)session;


/**---------------------------------------------------------------------------------------
 * @name Retrieval methods for the Alfresco Site Service
 *  ---------------------------------------------------------------------------------------
 */

/** Retrieves all the sites in the repository.
 
 @param completionBlock The block that's called with the retrieved sites in case the operation succeeds.
 */
- (AlfrescoRequest *)retrieveAllSitesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock;


/** Retrieves sites in the repository with listing context.
 
 @param listingContext The listing context with a paging definition that's used to retrieve the nodes.
 @param completionBlock The block that's called with the retrieved sites in case the operation succeeds.
 */
- (AlfrescoRequest *)retrieveAllSitesWithListingContext:(AlfrescoListingContext *)listingContext
                           completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock;

/** Retrieves all the sites for the current user of the session.
 
 @param completionBlock The block that's called with the retrieved sites in case the operation succeeds.
 */
- (AlfrescoRequest *)retrieveSitesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock;

/** Retrieves the sites for the current session user with listing context.
 
 @param listingContext The listing context with a paging definition that's used to retrieve the nodes.
 @param completionBlock The block that's called with the retrieved sites in case the operation succeeds.
 */
- (AlfrescoRequest *)retrieveSitesWithListingContext:(AlfrescoListingContext *)listingContext
                        completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock;


/** Retrieves all the favorite sites for the current session user.
 
 @param completionBlock The block that's called with the retrieved sites in case the operation succeeds.
 */
- (AlfrescoRequest *)retrieveFavoriteSitesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock;

/** Retrieves the favorite sites for the current session user with listing context.
 
 @param listingContext The listing context with a paging definition that's used to retrieve the nodes.
 @param completionBlock The block that's called with the retrieved sites in case the operation succeeds.
 */
- (AlfrescoRequest *)retrieveFavoriteSitesWithListingContext:(AlfrescoListingContext *)listingContext
                                completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock;

/** Retrieves a site with the given short name, if the site doesn’t exist nil is returned.
 
 
 @param siteShortName The short name of the site that needs to be retrieved.
 @param completionBlock The block that's called with the retrieved site in case the operation succeeds.
 @warning the method can return both a nil error object and a nil site object. This is the case when a valid
 request has been made to the server to retrieve the site, but the site has not been found. 
 */
- (AlfrescoRequest *)retrieveSiteWithShortName:(NSString *)siteShortName
                  completionBlock:(AlfrescoSiteCompletionBlock)completionBlock;

/** Retrieves the folder that represents the root of the Document Library for the site with the given short name.
 
 @param siteShortName The short name of the site for which the document library needs to be retrieved.
 @param completionBlock The block that's called with the retrieved document library folder in case the operation succeeds.
 */
- (AlfrescoRequest *)retrieveDocumentLibraryFolderForSite:(NSString *)siteShortName
                             completionBlock:(AlfrescoFolderCompletionBlock)completionBlock;



@end