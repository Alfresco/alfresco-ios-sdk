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

#import <Foundation/Foundation.h>
#import "AlfrescoPagingResult.h"
#import "AlfrescoListingContext.h"
#import "AlfrescoObjectConverter.h"

@class CMISOperationContext, CMISPagedResult;

@interface AlfrescoPagingUtils : NSObject

/** Creates a CMIS operation context object based on a listing context instance.
 
 @param listingContext The listing context instance that's used to create a CMIS operation context.
 @return The newly created CMIS operation context instance.
 */
+ (CMISOperationContext *) operationContextFromListingContext:(AlfrescoListingContext *)listingContext;


/** Creates a paging result object based on a cmis paged result instance.
 
 @param cmisResult The CMIS paged result instance that's used to create an Alfresco paging result.
 @return The newly created Alfresco paging result instance.
 */
+ (AlfrescoPagingResult *) pagedResultFromArray:(CMISPagedResult *)cmisResult objectConverter:(AlfrescoObjectConverter *)converter;


/** Creates a paging result object based on a non paged array and a listing context instance.
 
 @param nonPagedArray The non-paged NSArray that's used to fill an Alfresco paging result.
 @param listingContext The listing context that's used to create the Alfresco paging result.
 @return The newly created Alfresco paging result instance.
 */
+ (AlfrescoPagingResult *) pagedResultFromArray:(NSArray *)nonPagedArray listingContext:(AlfrescoListingContext *) listingContext;

@end
