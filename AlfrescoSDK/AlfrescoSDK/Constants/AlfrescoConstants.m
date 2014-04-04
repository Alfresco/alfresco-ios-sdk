/*******************************************************************************
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
 ******************************************************************************/

#import "AlfrescoConstants.h"

/**
 SDK Version constants - defined in AlfrescoSDK.xcconfig
 */
#if !defined(ALFRESCO_SDK_VERSION)
    #warning Missing AlfrescoSDK.xcconfig entries. Ensure the project configuration settings are correct.
    #define ALFRESCO_SDK_VERSION @"Unknown"
#endif
NSString * const kAlfrescoSDKVersion = ALFRESCO_SDK_VERSION;

/**
 Session parameter constants
 */
NSString * const kAlfrescoMetadataExtraction = @"org.alfresco.mobile.features.extractmetadata";
NSString * const kAlfrescoThumbnailCreation = @"org.alfresco.mobile.features.generatethumbnails";
NSString * const kAlfrescoAllowUntrustedSSLCertificate = @"org.alfresco.mobile.features.allowuntrustedsslcertificate";
NSString * const kAlfrescoConnectUsingClientSSLCertificate = @"org.alfresco.mobile.features.connectusingclientsslcertificate";
NSString * const kAlfrescoClientCertificateCredentials = @"org.alfresco.mobile.features.clientcertificatecredentials";

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
 Filtering constants
 */
NSString * const kAlfrescoFilterByWorkflowState = @"state";
NSString * const kAlfrescoFilterValueWorkflowStateActive = @"active";
NSString * const kAlfrescoFilterValueWorkflowStateCompleted = @"completed";

/**
 Capabilities constants
 */
NSString * const kAlfrescoCapabilityLike = @"CapabilityLike";
NSString * const kAlfrescoCapabilityCommentsCount = @"CapabilityCommentsCount";
NSString * const kAlfrescoCapabilityPublicAPI = @"CapabilityPublicAPI";
NSString * const kAlfrescoCapabilityActivitiWorkflowEngine = @"CapabilityActivitiWorkflowEngine";
NSString * const kAlfrescoCapabilityJBPMWorkflowEngine = @"CapabilityJBPMWorkflowEngine";

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
 Model Constants
 */
NSString * const kAlfrescoContentModelTypeContent = @"cm:content";
NSString * const kAlfrescoContentModelTypeFolder = @"cm:folder";

NSString * const kAlfrescoContentModelAspectTitled = @"cm:titled";
NSString * const kAlfrescoContentModelAspectAuthor = @"cm:author";
NSString * const kAlfrescoContentModelAspectGeographic = @"cm:geographic";
NSString * const kAlfrescoContentModelAspectExif = @"exif:exif";
NSString * const kAlfrescoContentModelAspectAudio = @"audio:audio";

NSString * const kAlfrescoContentModelPropertyName = @"cm:name";
NSString * const kAlfrescoContentModelPropertyTitle = @"cm:title";
NSString * const kAlfrescoContentModelPropertyDescription = @"cm:description";
NSString * const kAlfrescoContentModelPropertyAuthor = @"cm:author";
NSString * const kAlfrescoContentModelPropertyLatitude = @"cm:latitude";
NSString * const kAlfrescoContentModelPropertyLongitude = @"cm:longitude";
NSString * const kAlfrescoContentModelPropertyDateTimeOriginal = @"exif:dateTimeOriginal";
NSString * const kAlfrescoContentModelPropertyPixelXDimension = @"exif:pixelXDimension";
NSString * const kAlfrescoContentModelPropertyPixelYDimension = @"exif:pixelYDimension";
NSString * const kAlfrescoContentModelPropertyExposureTime = @"exif:exposureTime";
NSString * const kAlfrescoContentModelPropertyFNumber = @"exif:fNumber";
NSString * const kAlfrescoContentModelPropertyFlash = @"exif:flash";
NSString * const kAlfrescoContentModelPropertyFocalLength = @"exif:focalLength";
NSString * const kAlfrescoContentModelPropertyISOSpeedRating = @"exif:isoSpeedRatings";
NSString * const kAlfrescoContentModelPropertyManufacturer = @"exif:manufacturer";
NSString * const kAlfrescoContentModelPropertyModel = @"exif:model";
NSString * const kAlfrescoContentModelPropertySoftware = @"exif:software";
NSString * const kAlfrescoContentModelPropertyOrientation = @"exif:orientation";
NSString * const kAlfrescoContentModelPropertyXResolution = @"exif:xResolution";
NSString * const kAlfrescoContentModelPropertyYResolution = @"exif:yResolution";
NSString * const kAlfrescoContentModelPropertyResolutionUnit = @"exif:resolutionUnit";
NSString * const kAlfrescoContentModelPropertyAlbum = @"audio:album";
NSString * const kAlfrescoContentModelPropertyArtist = @"audio:artist";
NSString * const kAlfrescoContentModelPropertyComposer = @"audio:composer";
NSString * const kAlfrescoContentModelPropertyEngineer = @"audio:engineer";
NSString * const kAlfrescoContentModelPropertyGenre = @"audio:genre";
NSString * const kAlfrescoContentModelPropertyTrackNumber = @"audio:trackNumber";
NSString * const kAlfrescoContentModelPropertyReleaseDate = @"audio:releaseDate";
NSString * const kAlfrescoContentModelPropertySampleRate = @"audio:sampleRate";
NSString * const kAlfrescoContentModelPropertySampleType = @"audio:sampleType";
NSString * const kAlfrescoContentModelPropertyChannelType = @"audio:channelType";
NSString * const kAlfrescoContentModelPropertyCompressor = @"audio:compressor";

/**
 Workflow Task Constants
 */
NSString * const kAlfrescoWorkflowTaskComment = @"org.alfresco.mobile.task.comment";
NSString * const kAlfrescoWorkflowTaskReviewOutcome = @"org.alfresco.mobile.task.reviewoutcome";

NSString * const kAlfrescoWorkflowTaskTransitionApprove = @"Approve";
NSString * const kAlfrescoWorkflowTaskTransitionReject = @"Reject";

NSString * const kAlfrescoWorkflowProcessDescription = @"org.alfresco.mobile.process.create.description";
NSString * const kAlfrescoWorkflowProcessPriority = @"org.alfresco.mobile.process.create.priority";
NSString * const kAlfrescoWorkflowProcessSendEmailNotification = @"org.alfresco.mobile.process.create.sendemailnotification";
NSString * const kAlfrescoWorkflowProcessDueDate = @"org.alfresco.mobile.process.create.duedate";
NSString * const kAlfrescoWorkflowProcessApprovalRate = @"org.alfresco.mobile.process.create.approvalrate";
