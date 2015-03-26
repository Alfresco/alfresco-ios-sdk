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
NSString * const kAlfrescoCheckNetworkReachability = @"org.alfresco.mobile.features.checknetworkreachability";
NSString * const kAlfrescoRequestTimeout = @"org.alfresco.mobile.features.requesttimeout";
NSString * const kAlfrescoUseBackgroundNetworkSession = @"org.alfresco.mobile.features.usebackgroundnetworksession";
NSString * const kAlfrescoBackgroundNetworkSessionId = @"org.alfresco.mobile.features.networksessionid";
NSString * const kAlfrescoBackgroundNetworkSessionSharedContainerId = @"org.alfresco.mobile.features.networksessionsharedcontainerid";
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
NSString * const kAlfrescoFilterByWorkflowStatus = @"workflowStatus";
NSString * const kAlfrescoFilterValueWorkflowStatusActive = @"active";
NSString * const kAlfrescoFilterValueWorkflowStatusCompleted = @"completed";
NSString * const kAlfrescoFilterValueWorkflowStatusAny = @"any";

NSString * const kAlfrescoFilterByWorkflowDueDate = @"workflowDueDate";
NSString * const kAlfrescoFilterValueWorkflowDueDateToday = @"today";
NSString * const kAlfrescoFilterValueWorkflowDueDateTomorrow = @"tomorrow";
NSString * const kAlfrescoFilterValueWorkflowDueDate7Days = @"week";
NSString * const kAlfrescoFilterValueWorkflowDueDateOverdue = @"overdue";
NSString * const kAlfrescoFilterValueWorkflowDueDateNone = @"none";

NSString * const kAlfrescoFilterByWorkflowPriority = @"workflowPriority";
NSString * const kAlfrescoFilterValueWorkflowPriorityLow = @"low";
NSString * const kAlfrescoFilterValueWorkflowPriorityMedium = @"medium";
NSString * const kAlfrescoFilterValueWorkflowPriorityHigh = @"high";

NSString * const kAlfrescoFilterByWorkflowAssignee = @"workflowAssignee";
NSString * const kAlfrescoFilterValueWorkflowAssigneeMe = @"me";
NSString * const kAlfrescoFilterValueWorkflowAssigneeUnasssigned = @"unassigned";
NSString * const kAlfrescoFilterValueWorkflowAssigneeAll = @"all";

NSString * const kAlfrescoFilterBySiteVisibility = @"siteVisibility";
NSString * const kAlfrescoFilterValueSiteVisibilityPublic = @"public";
NSString * const kAlfrescoFilterValueSiteVisibilityModerated = @"moderated";
NSString * const kAlfrescoFilterValueSiteVisibilityPrivate = @"private";

NSString * const kAlfrescoFilterByActivityType = @"activityType";
NSString * const kAlfrescoFilterValueActivityTypeSiteUserJoined = @"org.alfresco.site.user-joined";
NSString * const kAlfrescoFilterValueActivityTypeSiteUserLeft = @"org.alfresco.site.user-left";
NSString * const kAlfrescoFilterValueActivityTypeSiteUserRoleChanged = @"org.alfresco.site.user-role-changed";
NSString * const kAlfrescoFilterValueActivityTypeSiteUserLiked = @"org.alfresco.site.liked";
NSString * const kAlfrescoFilterValueActivityTypeSiteGroupAdded = @"org.alfresco.site.group-added";
NSString * const kAlfrescoFilterValueActivityTypeSiteGroupRemoved = @"org.alfresco.site.group-removed";
NSString * const kAlfrescoFilterValueActivityTypeSiteGroupRoleChanged = @"org.alfresco.site.group-role-changed";
NSString * const kAlfrescoFilterValueActivityTypeFileCreated = @"org.alfresco.documentlibrary.file-created";
NSString * const kAlfrescoFilterValueActivityTypeFileAdded = @"org.alfresco.documentlibrary.file-added";
NSString * const kAlfrescoFilterValueActivityTypeFileUpdated = @"org.alfresco.documentlibrary.file-updated";
NSString * const kAlfrescoFilterValueActivityTypeFileDeleted = @"org.alfresco.documentlibrary.file-deleted";
NSString * const kAlfrescoFilterValueActivityTypeFilePreviewed = @"org.alfresco.documentlibrary.file-previewed";
NSString * const kAlfrescoFilterValueActivityTypeFileDownloaded = @"org.alfresco.documentlibrary.file-downloaded";
NSString * const kAlfrescoFilterValueActivityTypeFileGoogleDocsCheckout = @"org.alfresco.documentlibrary.google-docs-checkout";
NSString * const kAlfrescoFilterValueActivityTypeFileGoogleDocsCheckin = @"org.alfresco.documentlibrary.google-docs-checkin";
NSString * const kAlfrescoFilterValueActivityTypeFileInlineEdit = @"org.alfresco.documentlibrary.inline-edit";
NSString * const kAlfrescoFilterValueActivityTypeFileLiked = @"org.alfresco.documentlibrary.file-liked";
NSString * const kAlfrescoFilterValueActivityTypeFilesAdded = @"org.alfresco.documentlibrary.files-added";
NSString * const kAlfrescoFilterValueActivityTypeFilesUpdated = @"org.alfresco.documentlibrary.files-updated";
NSString * const kAlfrescoFilterValueActivityTypeFilesDeleted = @"org.alfresco.documentlibrary.files-deleted";
NSString * const kAlfrescoFilterValueActivityTypeFolderAdded = @"org.alfresco.documentlibrary.folder-added";
NSString * const kAlfrescoFilterValueActivityTypeFolderDeleted = @"org.alfresco.documentlibrary.folder-deleted";
NSString * const kAlfrescoFilterValueActivityTypeFolderLiked = @"org.alfresco.documentlibrary.folder-liked";
NSString * const kAlfrescoFilterValueActivityTypeFoldersAdded = @"org.alfresco.documentlibrary.folders-added";
NSString * const kAlfrescoFilterValueActivityTypeFoldersDeleted = @"org.alfresco.documentlibrary.folders-deleted";
NSString * const kAlfrescoFilterValueActivityTypeLinkCreated = @"org.alfresco.links.link-created";
NSString * const kAlfrescoFilterValueActivityTypeLinkUpdated = @"org.alfresco.links.link-updated";
NSString * const kAlfrescoFilterValueActivityTypeLinkDeleted = @"org.alfresco.links.link-deleted";
NSString * const kAlfrescoFilterValueActivityTypeCommentCreated = @"org.alfresco.comments.comment-created";
NSString * const kAlfrescoFilterValueActivityTypeCommentUpdated = @"org.alfresco.comments.comment-updated";
NSString * const kAlfrescoFilterValueActivityTypeCommentDeleted = @"org.alfresco.comments.comment-deleted";
NSString * const kAlfrescoFilterValueActivityTypeBlogPostCreated = @"org.alfresco.blog.post-created";
NSString * const kAlfrescoFilterValueActivityTypeBlogPostUpdated = @"org.alfresco.blog.post-updated";
NSString * const kAlfrescoFilterValueActivityTypeBlogPostDeleted = @"org.alfresco.blog.post-deleted";
NSString * const kAlfrescoFilterValueActivityTypeDiscussionPostCreated = @"org.alfresco.discussions.post-created";
NSString * const kAlfrescoFilterValueActivityTypeDiscussionPostUpdated = @"org.alfresco.discussions.post-updated";
NSString * const kAlfrescoFilterValueActivityTypeDiscussionPostDeleted = @"org.alfresco.discussions.post-deleted";
NSString * const kAlfrescoFilterValueActivityTypeDiscussionReplyCreated = @"org.alfresco.discussions.reply-created";
NSString * const kAlfrescoFilterValueActivityTypeDiscussionReplyUpdated = @"org.alfresco.discussions.reply-updated";
NSString * const kAlfrescoFilterValueActivityTypeCalendarEventCreated = @"org.alfresco.calendar.event-created";
NSString * const kAlfrescoFilterValueActivityTypeCalendarEventUpdated = @"org.alfresco.calendar.event-updated";
NSString * const kAlfrescoFilterValueActivityTypeCalendarEventDeleted = @"org.alfresco.calendar.event-deleted";
NSString * const kAlfrescoFilterValueActivityTypeWikiPageCreated = @"org.alfresco.wiki.page-created";
NSString * const kAlfrescoFilterValueActivityTypeWikiPageUpdated = @"org.alfresco.wiki.page-updated";
NSString * const kAlfrescoFilterValueActivityTypeWikiPageDeleted = @"org.alfresco.wiki.page-deleted";
NSString * const kAlfrescoFilterValueActivityTypeDataListCreated = @"org.alfresco.datalists.list-created";
NSString * const kAlfrescoFilterValueActivityTypeDataListUpdated = @"org.alfresco.datalists.list-updated";
NSString * const kAlfrescoFilterValueActivityTypeDataListDeleted = @"org.alfresco.datalists.list-deleted";
NSString * const kAlfrescoFilterValueActivityTypeFollowed = @"org.alfresco.subscriptions.followed";
NSString * const kAlfrescoFilterValueActivityTypeSubscribed = @"org.alfresco.subscriptions.subscribed";
NSString * const kAlfrescoFilterValueActivityTypeProfileStatusChanged = @"org.alfresco.profile.status-changed";

NSString * const kAlfrescoFilterByActivityUser = @"activityUser";

/**
 Capabilities constants
 */
NSString * const kAlfrescoCapabilityLike = @"CapabilityLike";
NSString * const kAlfrescoCapabilityCommentsCount = @"CapabilityCommentsCount";
NSString * const kAlfrescoCapabilityPublicAPI = @"CapabilityPublicAPI";
NSString * const kAlfrescoCapabilityActivitiWorkflowEngine = @"CapabilityActivitiWorkflowEngine";
NSString * const kAlfrescoCapabilityJBPMWorkflowEngine = @"CapabilityJBPMWorkflowEngine";
NSString * const kAlfrescoCapabilityMyFiles = @"CapabilityMyFiles";
NSString * const kAlfrescoCapabilitySharedFiles = @"CapabilitySharedFiles";

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
NSString * const kAlfrescoModelPropertyUserName = @"cm:userName";
NSString * const kAlfrescoModelPropertyFirstName = @"cm:firstName";
NSString * const kAlfrescoModelPropertyLastName = @"cm:lastName";
NSString * const kAlfrescoModelPropertyMiddleName = @"cm:middleName";
NSString * const kAlfrescoModelPropertyEmail = @"cm:email";
NSString * const kAlfrescoModelPropertyOrganization = @"cm:organization";
NSString * const kAlfrescoModelPropertyOrganizationId = @"cm:organizationId";
NSString * const kAlfrescoModelPropertyHomeFolder = @"cm:homeFolder";
NSString * const kAlfrescoModelPropertyHomeFolderProvider = @"cm:homeFolderProvider";
NSString * const kAlfrescoModelPropertyPresenceProvider = @"cm:presenceProvider";
NSString * const kAlfrescoModelPropertyPresenceUserName = @"cm:presenceUsername";
NSString * const kAlfrescoModelPropertyJobTitle = @"cm:jobtitle";
NSString * const kAlfrescoModelPropertyLocation = @"cm:location";
NSString * const kAlfrescoModelPropertyPersonDescription = @"cm:persondescription";
NSString * const kAlfrescoModelPropertyTelephone = @"cm:telephone";
NSString * const kAlfrescoModelPropertyMobile = @"cm:mobile";
NSString * const kAlfrescoModelPropertySkype = @"cm:skype";
NSString * const kAlfrescoModelPropertyInstantMsg = @"cm:instantmsg";
NSString * const kAlfrescoModelPropertyUserStatus = @"cm:userStatus";
NSString * const kAlfrescoModelPropertyUserStatusTime = @"cm:userStatusTime";
NSString * const kAlfrescoModelPropertyGoogleUserName = @"cm:googleusername";
NSString * const kAlfrescoModelPropertyEmailFeedDisabled = @"cm:emailFeedDisabled";
NSString * const kAlfrescoModelPropertySubscriptionsPrivate = @"cm:subscriptionsPrivate";
NSString * const kAlfrescoModelPropertyCompanyAddress1 = @"cm:companyaddress1";
NSString * const kAlfrescoModelPropertyCompanyAddress2 = @"cm:companyaddress2";
NSString * const kAlfrescoModelPropertyCompanyAddress3 = @"cm:companyaddress3";
NSString * const kAlfrescoModelPropertyCompanyPostCode = @"cm:companypostcode";
NSString * const kAlfrescoModelPropertyCompanyTelephone = @"cm:companytelephone";
NSString * const kAlfrescoModelPropertyCompanyFax = @"cm:companyfax";
NSString * const kAlfrescoModelPropertyCompanyEmail = @"cm:companyemail";

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
NSString * const kAlfrescoWorkflowVariableProcessName = @"bpm:workflowDescription";
NSString * const kAlfrescoWorkflowVariableProcessDescription = @"bpm:workflowDescription";
NSString * const kAlfrescoWorkflowVariableProcessPriority = @"bpm:workflowPriority";
NSString * const kAlfrescoWorkflowVariableProcessDueDate = @"bpm:workflowDueDate";
NSString * const kAlfrescoWorkflowVariableProcessSendEmailNotifications = @"bpm:sendEMailNotifications";
NSString * const kAlfrescoWorkflowVariableProcessApprovalRate = @"wf:requiredApprovePercent";
NSString * const kAlfrescoWorkflowVariableTaskTransition = @"transition";
NSString * const kAlfrescoWorkflowVariableTaskComment = @"bpm:comment";
NSString * const kAlfrescoWorkflowVariableTaskStatus = @"bpm:status";
NSString * const kAlfrescoWorkflowVariableTaskReviewOutcome = @"wf:reviewOutcome";
NSString * const kAlfrescoWorkflowVariableTaskInvitePendingOutcome = @"inwf:inviteOutcome";

NSString * const kAlfrescoWorkflowTaskTransitionApprove = @"Approve";
NSString * const kAlfrescoWorkflowTaskTransitionAccept = @"Accept";
NSString * const kAlfrescoWorkflowTaskTransitionReject = @"Reject";

/**
 Connection Diagnostic Constants
 */
NSString *const kAlfrescoConfigurationDiagnosticDidStartEventNotification = @"ConfigurationDiagnosticDidStartEventNotification";
NSString *const kAlfrescoConfigurationDiagnosticDidEndEventNotification = @"ConfigurationDiagnosticDidEndEventNotification";

NSString * const kAlfrescoConfigurationDiagnosticDictionaryIsLoading = @"isLoading";
NSString * const kAlfrescoConfigurationDiagnosticDictionaryIsSuccess = @"isSuccess";
NSString * const kAlfrescoConfigurationDiagnosticDictionaryEventName = @"eventName";
NSString * const kAlfrescoConfigurationDiagnosticDictionaryError = @"error";

NSString * const kAlfrescoConfigurationDiagnosticReachabilityEvent = @"reachabilityEvent";
NSString * const kAlfrescoConfigurationDiagnosticServerVersionEvent = @"serverVersionEvent";
NSString * const kAlfrescoConfigurationDiagnosticRepositoriesAvailableEvent = @"repositoriesAvailableEvent";
NSString * const kAlfrescoConfigurationDiagnosticConnectRepositoryEvent = @"connectRepositoryEvent";
NSString * const kAlfrescoConfigurationDiagnosticRetrieveRootFolderEvent = @"retreiveRootFolder";
