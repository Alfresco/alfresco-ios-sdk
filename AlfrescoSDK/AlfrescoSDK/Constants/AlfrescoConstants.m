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
/** The AlfrescoErrors error definitions for Mobile SDK.
 
 Author: Peter Schmidt (Alfresco)
 */

#import "AlfrescoConstants.h"


/**
 Session parameter constants
 */
NSString * const kAlfrescoMetadataExtraction = @"org.alfresco.mobile.features.extractmetadata";
NSString * const kAlfrescoThumbnailCreation = @"org.alfresco.mobile.features.generatethumbnails";
NSString * const kAlfrescoThumbnailRenditionFromAPI = @"org.alfresco.mobile.features.thumbnailRenditionFromAPI";

NSString * const kAlfrescoOnPremiseActivityStreamServiceExtension = @"org.alfresco.mobile.api.services.onpremise.activitystream";
NSString * const kAlfrescoOnPremiseRatingServiceExtension = @"org.alfresco.mobile.api.services.onpremise.rating";
NSString * const kAlfrescoOnPremiseSiteServiceExtension = @"org.alfresco.mobile.api.services.onpremise.site";
NSString * const kAlfrescoOnPremiseCommentServiceExtension = @"org.alfresco.mobile.api.services.onpremise.comment";
NSString * const kAlfrescoOnPremiseTaggingServiceExtension = @"org.alfresco.mobile.api.services.onpremise.tagging";
NSString * const kAlfrescoOnPremisePersonServiceExtension = @"org.alfresco.mobile.api.services.onpremise.person";

NSString * const kAlfrescoCloudActivityStreamServiceExtension = @"org.alfresco.mobile.api.services.cloud.activitystream";
NSString * const kAlfrescoCloudRatingServiceExtension = @"org.alfresco.mobile.api.services.cloud.rating";
NSString * const kAlfrescoCloudSiteServiceExtension = @"org.alfresco.mobile.api.services.cloud.site";
NSString * const kAlfrescoCloudCommentServiceExtension = @"org.alfresco.mobile.api.services.cloud.comment";
NSString * const kAlfrescoCloudTaggingServiceExtension = @"org.alfresco.mobile.api.services.cloud.tagging";
NSString * const kAlfrescoCloudPersonServiceExtension = @"org.alfresco.mobile.api.services.cloud.person";

/**
 Thumbnail constants
 */
NSString * const kAlfrescoThumbnailRendition = @"doclib";

/**
 Sorting property constants
 */
NSString * const kAlfrescoSortByTitle = @"title";
NSString * const kAlfrescoSortByShortname = @"shortName";
NSString * const kAlfrescoSortByCreatedAt = @"createdAt";
NSString * const kAlfrescoSortByModifiedAt = @"modifiedAt";
NSString * const kAlfrescoSortByName = @"name";
NSString * const kAlfrescoSortByDescription = @"description";

/**
 Capabilities constants
 */
NSString * const kAlfrescoCapabilityLike = @"CapabilityLike";
NSString * const kAlfrescoCapabilityCommentsCount = @"CapabilityCommentsCount";