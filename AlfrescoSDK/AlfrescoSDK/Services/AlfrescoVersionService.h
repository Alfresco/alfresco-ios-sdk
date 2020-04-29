/*
 ******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
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
#import "AlfrescoDocument.h"
#import "AlfrescoRequest.h"
#import "AlfrescoContentStream.h"

/** The AlfrescoVersionService provides ways to get all versions of a specific document.
 
 Author: Gavin Cornwell (Alfresco), Tijs Rademakers (Alfresco), Peter Schmidt (Alfresco)
 */

@interface AlfrescoVersionService : NSObject

/**---------------------------------------------------------------------------------------
 * @name Initialisation
 *  ---------------------------------------------------------------------------------------
 */

/** Initialises with a standard Cloud or OnPremise session
 
 @param session the AlfrescoSession to initialise the site service with.
 */
- (id)initWithSession:(id<AlfrescoSession>)session;

/**---------------------------------------------------------------------------------------
 * @name Retrieval methods.
 *  ---------------------------------------------------------------------------------------
 */

/** Retrieves all versions of the given document.
 
 @param document The document for which all versions should be retrieved.
 @param completionBlock The block that's called with the retrieved versions in case the operation succeeds.
 */
- (AlfrescoRequest *)retrieveAllVersionsOfDocument:(AlfrescoDocument *)document
                      completionBlock:(AlfrescoArrayCompletionBlock)completionBlock;

/** Retrieves all versions of the given document with a listing context.
 
 @param document The document for which all versions should be retrieved.
 @param listingContext The listing context with a paging definition that's used to retrieve the versions.
 @param completionBlock The block that's called with the retrieved versions in case the operation succeeds.
 */
- (AlfrescoRequest *)retrieveAllVersionsOfDocument:(AlfrescoDocument *)document
                       listingContext:(AlfrescoListingContext *)listingContext
                      completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock;

/** Retrieves the latest version of the given document.
 
 @param document The document to get the latest of.
 @param completionBlock The block that's called with the retrieved document.
 */
- (AlfrescoRequest *)retrieveLatestVersionOfDocument:(AlfrescoDocument *)document
                                     completionBlock:(AlfrescoDocumentCompletionBlock)completionBlock;

/** Checks out the given document and returns the private working copy (pwc) document.
    The original document is locked in the repository.
 
 @param document The document to check out.
 @param completionBlock The block that's called following the checkout operation, if the checkout was successful the pwc is provided.
 */
- (AlfrescoRequest *)checkoutDocument:(AlfrescoDocument *)document
                      completionBlock:(AlfrescoDocumentCompletionBlock)completionBlock;

/** Cancels a previous checkout operation.
 
 @param document The private working copy document to cancel the checkout for.
 @param completionBlock The block that's called following the cancel checkout operation.
 */
- (AlfrescoRequest *)cancelCheckoutOfDocument:(AlfrescoDocument *)document
                              completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock;

/** Checks in the given private working copy document.
 
 @param document The private working copy document to checkin.
 @param asMajorVersion Indicates whether the new version should be created as the next major version i.e. 2.0.
 @param contentFile A file that represents the content for the new version.
 @param properties An optional set of properties to update as part of the checkin operation.
 @param comment An optional comment describing the reason for the update.
 @param completionBlock The block that's called when the checkin operation completes.
 @param progressBlock The block that's called as the new content is uploaded to the server.
 */
- (AlfrescoRequest *)checkinDocument:(AlfrescoDocument *)document
                      asMajorVersion:(BOOL)majorVersion
                         contentFile:(AlfrescoContentFile *)file
                          properties:(NSDictionary *)properties
                             comment:(NSString *)comment
                     completionBlock:(AlfrescoDocumentCompletionBlock)completionBlock
                       progressBlock:(AlfrescoProgressBlock)progressBlock;

/** Checks in the given private working copy document.
 
 @param document The private working copy document to checkin.
 @param asMajorVersion Indicates whether the new version should be created as the next major version i.e. 2.0.
 @param contentStream A stream that represents the content for the new version.
 @param properties An optional set of properties to update as part of the checkin operation.
 @param comment An optional comment describing the reason for the update.
 @param completionBlock The block that's called when the checkin operation completes.
 @param progressBlock The block that's called as the new content is uploaded to the server.
 */
- (AlfrescoRequest *)checkinDocument:(AlfrescoDocument *)document
                      asMajorVersion:(BOOL)majorVersion
                       contentStream:(AlfrescoContentStream *)contentStream
                          properties:(NSDictionary *)properties
                             comment:(NSString *)comment
                     completionBlock:(AlfrescoDocumentCompletionBlock)completionBlock
                       progressBlock:(AlfrescoProgressBlock)progressBlock;

/** Retrieves a list of documents the current has checked out.
 
 @param completionBlock The block that's called with the checked out documents.
 */
- (AlfrescoRequest *)retrieveCheckedOutDocumentsWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock;

/** Retrieves a list of documents the current has checked out.
 
 @param listingContext The listing context with a paging definition that's used to retrieve the checked out documents.
 @param completionBlock The block that's called with the checked out documents.
 */
- (AlfrescoRequest *)retrieveCheckedOutDocumentsWithListingContext:(AlfrescoListingContext *)listingContext
                                                   completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock;

@end
