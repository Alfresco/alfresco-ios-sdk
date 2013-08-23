/*******************************************************************************
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
 ******************************************************************************/
/** The AlfrescoErrors error definitions for Mobile SDK.
 
 Author: Peter Schmidt (Alfresco)
 */

#import "AlfrescoConstants.h"

/**
 SDK Version constants
 */
NSString * const kAlfrescoSDKVersion = @"1.1.0";

/**
 Session parameter constants
 */
NSString * const kAlfrescoMetadataExtraction = @"org.alfresco.mobile.features.extractmetadata";
NSString * const kAlfrescoThumbnailCreation = @"org.alfresco.mobile.features.generatethumbnails";
NSString * const kAlfrescoAllowUntrustedSSLCertificate = @"org.alfresco.mobile.features.allowuntrustedsslcertificate";

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

/**
 File Attribute Constants
 */
NSString * const kAlfrescoFileSize = @"fileSize";
NSString * const kAlfrescoFileLastModification = @"lastModificationDate";
NSString * const kAlfrescoIsFolder = @"isFolder";

/**
 Custom Network Provider
 */
NSString * const kAlfrescoNetworkProvider = @"org.alfresco.mobile.session.networkprovider";
NSString * const kAlfrescoCMISBindingURL = @"org.alfresco.mobile.session.cmisbindingurl";

/**
 Person Profile Constants 
 */
NSString * const kAlfrescoPersonPropertyFirstName = @"firstName";
NSString * const kAlfrescoPersonPropertyLastName = @"lastName";
NSString * const kAlfrescoPersonPropertyJobTitle = @"jobTitle";
NSString * const kAlfrescoPersonPropertyLocation = @"location";
NSString * const kAlfrescoPersonPropertyDescription = @"description";
NSString * const kAlfrescoPersonPropertyTelephoneNumber = @"telephone";
NSString * const kAlfrescoPersonPropertyMobileNumber = @"mobile";
NSString * const kAlfrescoPersonPropertyEmail = @"email";
NSString * const kAlfrescoPersonPropertySkypeId = @"skypeId";
NSString * const kAlfrescoPersonPropertyInstantMessageId = @"instantmessageId";
NSString * const kAlfrescoPersonPropertyGoogleId = @"googleUsername";
NSString * const kAlfrescoPersonPropertyStatus = @"userStatus";
NSString * const kAlfrescoPersonPropertyStatusTime = @"userStatusTime";
NSString * const kAlfrescoPersonPropertyCompanyName = @"companyName";
NSString * const kAlfrescoPersonPropertyCompanyAddressLine1 = @"companyAddressLine1";
NSString * const kAlfrescoPersonPropertyCompanyAddressLine2 = @"companyAddressLine2";
NSString * const kAlfrescoPersonPropertyCompanyAddressLine3 = @"companyAddressLine3";
NSString * const kAlfrescoPersonPropertyCompanyPostcode = @"companyPostcode";
NSString * const kAlfrescoPersonPropertyCompanyTelephoneNumber = @"companyTelephoneNumber";
NSString * const kAlfrescoPersonPropertyCompanyFaxNumber = @"companyFaxNumber";
NSString * const kAlfrescoPersonPropertyCompanyEmail = @"companyEmail";
