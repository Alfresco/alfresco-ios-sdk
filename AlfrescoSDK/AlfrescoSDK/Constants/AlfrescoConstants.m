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
NSString * const kAlfrescoFilterValueWorkflowStateAny = @"any";

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
NSString * const kAlfrescoModelTypeContent = @"cm:content";
NSString * const kAlfrescoModelTypeFolder = @"cm:folder";

NSString * const kAlfrescoModelAspectTitled = @"cm:titled";
NSString * const kAlfrescoModelAspectAuthor = @"cm:author";
NSString * const kAlfrescoModelAspectGeographic = @"cm:geographic";
NSString * const kAlfrescoModelAspectExif = @"exif:exif";
NSString * const kAlfrescoModelAspectAudio = @"audio:audio";

NSString * const kAlfrescoModelPropertyName = @"cm:name";
NSString * const kAlfrescoModelPropertyTitle = @"cm:title";
NSString * const kAlfrescoModelPropertyDescription = @"cm:description";
NSString * const kAlfrescoModelPropertyAuthor = @"cm:author";
NSString * const kAlfrescoModelPropertyLatitude = @"cm:latitude";
NSString * const kAlfrescoModelPropertyLongitude = @"cm:longitude";
NSString * const kAlfrescoModelPropertyExifDateTimeOriginal = @"exif:dateTimeOriginal";
NSString * const kAlfrescoModelPropertyExifPixelXDimension = @"exif:pixelXDimension";
NSString * const kAlfrescoModelPropertyExifPixelYDimension = @"exif:pixelYDimension";
NSString * const kAlfrescoModelPropertyExifExposureTime = @"exif:exposureTime";
NSString * const kAlfrescoModelPropertyExifFNumber = @"exif:fNumber";
NSString * const kAlfrescoModelPropertyExifFlash = @"exif:flash";
NSString * const kAlfrescoModelPropertyExifFocalLength = @"exif:focalLength";
NSString * const kAlfrescoModelPropertyExifISOSpeedRating = @"exif:isoSpeedRatings";
NSString * const kAlfrescoModelPropertyExifManufacturer = @"exif:manufacturer";
NSString * const kAlfrescoModelPropertyExifModel = @"exif:model";
NSString * const kAlfrescoModelPropertyExifSoftware = @"exif:software";
NSString * const kAlfrescoModelPropertyExifOrientation = @"exif:orientation";
NSString * const kAlfrescoModelPropertyExifXResolution = @"exif:xResolution";
NSString * const kAlfrescoModelPropertyExifYResolution = @"exif:yResolution";
NSString * const kAlfrescoModelPropertyExifResolutionUnit = @"exif:resolutionUnit";
NSString * const kAlfrescoModelPropertyAudioAlbum = @"audio:album";
NSString * const kAlfrescoModelPropertyAudioArtist = @"audio:artist";
NSString * const kAlfrescoModelPropertyAudioComposer = @"audio:composer";
NSString * const kAlfrescoModelPropertyAudioEngineer = @"audio:engineer";
NSString * const kAlfrescoModelPropertyAudioGenre = @"audio:genre";
NSString * const kAlfrescoModelPropertyAudioTrackNumber = @"audio:trackNumber";
NSString * const kAlfrescoModelPropertyAudioReleaseDate = @"audio:releaseDate";
NSString * const kAlfrescoModelPropertyAudioSampleRate = @"audio:sampleRate";
NSString * const kAlfrescoModelPropertyAudioSampleType = @"audio:sampleType";
NSString * const kAlfrescoModelPropertyAudioChannelType = @"audio:channelType";
NSString * const kAlfrescoModelPropertyAudioCompressor = @"audio:compressor";

/**
 Workflow Task Constants
 */
NSString * const kAlfrescoWorkflowVariableProcessName = @"bpm_workflowDescription";
NSString * const kAlfrescoWorkflowVariableProcessPriority = @"bpm_workflowPriority";
NSString * const kAlfrescoWorkflowVariableProcessDueDate = @"bpm_workflowDueDate";
NSString * const kAlfrescoWorkflowVariableProcessSendEmailNotifications = @"bpm_sendEMailNotifications";
NSString * const kAlfrescoWorkflowVariableProcessApprovalRate = @"wf_requiredApprovePercent";
NSString * const kAlfrescoWorkflowVariableTaskTransition = @"prop_transitions";
NSString * const kAlfrescoWorkflowVariableTaskComment = @"bpm_comment";
NSString * const kAlfrescoWorkflowVariableTaskStatus = @"bpm_status";
NSString * const kAlfrescoWorkflowVariableTaskReviewOutcome = @"wf_reviewOutcome";

NSString * const kAlfrescoWorkflowTaskTransitionApprove = @"Approve";
NSString * const kAlfrescoWorkflowTaskTransitionReject = @"Reject";
