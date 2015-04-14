/*
 ******************************************************************************
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
 *****************************************************************************
 */


#import <Foundation/Foundation.h>
#import "AlfrescoPagingResult.h"
#import "AlfrescoListingContext.h"
#import "AlfrescoContentFile.h"
#import "AlfrescoPermissions.h"
#import "AlfrescoPerson.h"
#import "AlfrescoSite.h"
#import "AlfrescoNode.h"
#import "AlfrescoDocument.h"
#import "AlfrescoComment.h"
#import "AlfrescoOAuthData.h"
#import "AlfrescoWorkflowProcessDefinition.h"
#import "AlfrescoWorkflowProcess.h"
#import "AlfrescoWorkflowTask.h"
#import "AlfrescoDocumentTypeDefinition.h"
#import "AlfrescoFolderTypeDefinition.h"
#import "AlfrescoTaskTypeDefinition.h"
#import "AlfrescoAspectDefinition.h"

@protocol AlfrescoSession;
/** The AlfrescoConstants used in the SDK.
 Author: Gavin Cornwell (Alfresco), Tijs Rademakers (Alfresco), Peter Schmidt (Alfresco)
 */

/**---------------------------------------------------------------------------------------
 * @name SDK Version constants
 --------------------------------------------------------------------------------------- */
extern NSString * const kAlfrescoSDKVersion;

/**---------------------------------------------------------------------------------------
 * @name Block definitions
 --------------------------------------------------------------------------------------- */
typedef void (^AlfrescoArrayCompletionBlock)(NSArray *array, NSError *error);
typedef void (^AlfrescoBOOLCompletionBlock)(BOOL succeeded, NSError *error);
typedef void (^AlfrescoNumberCompletionBlock)(NSNumber *count, NSError *error);
typedef void (^AlfrescoDataCompletionBlock)(NSData *data, NSError *error);
typedef void (^AlfrescoFolderCompletionBlock)(AlfrescoFolder *folder, NSError *error);
typedef void (^AlfrescoNodeCompletionBlock)(AlfrescoNode *node, NSError *error);
typedef void (^AlfrescoDocumentCompletionBlock)(AlfrescoDocument *document, NSError *error);
typedef void (^AlfrescoPagingResultCompletionBlock)(AlfrescoPagingResult *pagingResult, NSError *error);
typedef void (^AlfrescoProgressBlock)(unsigned long long bytesTransferred, unsigned long long bytesTotal);
typedef void (^AlfrescoContentFileCompletionBlock)(AlfrescoContentFile *contentFile, NSError *error);
typedef void (^AlfrescoPermissionsCompletionBlock)(AlfrescoPermissions *permissions, NSError *error);
typedef void (^AlfrescoPersonCompletionBlock)(AlfrescoPerson *person, NSError *error);
typedef void (^AlfrescoSiteCompletionBlock)(AlfrescoSite *site, NSError *error);
typedef void (^AlfrescoSessionCompletionBlock)(id<AlfrescoSession> session, NSError *error);
typedef void (^AlfrescoCommentCompletionBlock)(AlfrescoComment *comment, NSError *error);
typedef void (^AlfrescoLikedCompletionBlock)(BOOL succeeded, BOOL isLiked, NSError *error);
typedef void (^AlfrescoOAuthCompletionBlock)(AlfrescoOAuthData * oauthData, NSError *error);
typedef void (^AlfrescoMemberCompletionBlock)(BOOL succeeded, BOOL isMember, NSError *error);
typedef void (^AlfrescoFavoritedCompletionBlock)(BOOL succeeded, BOOL isFavorited, NSError *error);
typedef void (^AlfrescoProcessDefinitionCompletionBlock)(AlfrescoWorkflowProcessDefinition *processDefinition, NSError *error);
typedef void (^AlfrescoProcessCompletionBlock)(AlfrescoWorkflowProcess *process, NSError *error);
typedef void (^AlfrescoTaskCompletionBlock)(AlfrescoWorkflowTask *task, NSError *error);
typedef void (^AlfrescoDictionaryCompletionBlock)(NSDictionary *dictionary, NSError *error);
typedef void (^AlfrescoDocumentTypeDefinitionCompletionBlock)(AlfrescoDocumentTypeDefinition *typeDefinition, NSError *error);
typedef void (^AlfrescoFolderTypeDefinitionCompletionBlock)(AlfrescoFolderTypeDefinition *typeDefinition, NSError *error);
typedef void (^AlfrescoTaskTypeDefinitionCompletionBlock)(AlfrescoTaskTypeDefinition *typeDefinition, NSError *error);
typedef void (^AlfrescoAspectDefinitionCompletionBlock)(AlfrescoAspectDefinition *aspectDefinition, NSError *error);

/**---------------------------------------------------------------------------------------
 * @name Session parameters
 --------------------------------------------------------------------------------------- */
extern NSString * const kAlfrescoMetadataExtraction;
extern NSString * const kAlfrescoThumbnailCreation;
extern NSString * const kAlfrescoCheckNetworkReachability;
extern NSString * const kAlfrescoRequestTimeout;
extern NSString * const kAlfrescoUseBackgroundNetworkSession;
extern NSString * const kAlfrescoBackgroundNetworkSessionId;
extern NSString * const kAlfrescoBackgroundNetworkSessionSharedContainerId;

/**---------------------------------------------------------------------------------------
 * @name thumbnail constant
 --------------------------------------------------------------------------------------- */
extern NSString * const kAlfrescoThumbnailRendition;

/**---------------------------------------------------------------------------------------
 * @name sorting properties
 --------------------------------------------------------------------------------------- */
extern NSString * const kAlfrescoSortByTitle;
extern NSString * const kAlfrescoSortByShortname;
extern NSString * const kAlfrescoSortByCreatedAt;
extern NSString * const kAlfrescoSortByModifiedAt;
extern NSString * const kAlfrescoSortByName;
extern NSString * const kAlfrescoSortByDescription;

/**---------------------------------------------------------------------------------------
 * @name filter properties
 --------------------------------------------------------------------------------------- */
extern NSString * const kAlfrescoFilterByWorkflowStatus;
extern NSString * const kAlfrescoFilterValueWorkflowStatusActive;
extern NSString * const kAlfrescoFilterValueWorkflowStatusCompleted;
extern NSString * const kAlfrescoFilterValueWorkflowStatusAny;

extern NSString * const kAlfrescoFilterByWorkflowDueDate;
extern NSString * const kAlfrescoFilterValueWorkflowDueDateToday;
extern NSString * const kAlfrescoFilterValueWorkflowDueDateTomorrow;
extern NSString * const kAlfrescoFilterValueWorkflowDueDate7Days;
extern NSString * const kAlfrescoFilterValueWorkflowDueDateOverdue;
extern NSString * const kAlfrescoFilterValueWorkflowDueDateNone;

extern NSString * const kAlfrescoFilterByWorkflowPriority;
extern NSString * const kAlfrescoFilterValueWorkflowPriorityLow;
extern NSString * const kAlfrescoFilterValueWorkflowPriorityMedium;
extern NSString * const kAlfrescoFilterValueWorkflowPriorityHigh;

extern NSString * const kAlfrescoFilterByWorkflowAssignee;
extern NSString * const kAlfrescoFilterValueWorkflowAssigneeMe;
extern NSString * const kAlfrescoFilterValueWorkflowAssigneeUnasssigned;
extern NSString * const kAlfrescoFilterValueWorkflowAssigneeAll;

extern NSString * const kAlfrescoFilterBySiteVisibility;
extern NSString * const kAlfrescoFilterValueSiteVisibilityPublic;
extern NSString * const kAlfrescoFilterValueSiteVisibilityModerated;
extern NSString * const kAlfrescoFilterValueSiteVisibilityPrivate;

extern NSString * const kAlfrescoFilterByActivityType;
extern NSString * const kAlfrescoFilterValueActivityTypeSiteUserJoined;
extern NSString * const kAlfrescoFilterValueActivityTypeSiteUserLeft;
extern NSString * const kAlfrescoFilterValueActivityTypeSiteUserRoleChanged;
extern NSString * const kAlfrescoFilterValueActivityTypeSiteUserLiked;
extern NSString * const kAlfrescoFilterValueActivityTypeSiteGroupAdded;
extern NSString * const kAlfrescoFilterValueActivityTypeSiteGroupRemoved;
extern NSString * const kAlfrescoFilterValueActivityTypeSiteGroupRoleChanged;
extern NSString * const kAlfrescoFilterValueActivityTypeFileCreated;
extern NSString * const kAlfrescoFilterValueActivityTypeFileAdded;
extern NSString * const kAlfrescoFilterValueActivityTypeFileUpdated;
extern NSString * const kAlfrescoFilterValueActivityTypeFileDeleted;
extern NSString * const kAlfrescoFilterValueActivityTypeFilePreviewed;
extern NSString * const kAlfrescoFilterValueActivityTypeFileDownloaded;
extern NSString * const kAlfrescoFilterValueActivityTypeFileGoogleDocsCheckout;
extern NSString * const kAlfrescoFilterValueActivityTypeFileGoogleDocsCheckin;
extern NSString * const kAlfrescoFilterValueActivityTypeFileInlineEdit;
extern NSString * const kAlfrescoFilterValueActivityTypeFileLiked;
extern NSString * const kAlfrescoFilterValueActivityTypeFilesAdded;
extern NSString * const kAlfrescoFilterValueActivityTypeFilesUpdated;
extern NSString * const kAlfrescoFilterValueActivityTypeFilesDeleted;
extern NSString * const kAlfrescoFilterValueActivityTypeFolderAdded;
extern NSString * const kAlfrescoFilterValueActivityTypeFolderDeleted;
extern NSString * const kAlfrescoFilterValueActivityTypeFolderLiked;
extern NSString * const kAlfrescoFilterValueActivityTypeFoldersAdded;
extern NSString * const kAlfrescoFilterValueActivityTypeFoldersDeleted;
extern NSString * const kAlfrescoFilterValueActivityTypeLinkCreated;
extern NSString * const kAlfrescoFilterValueActivityTypeLinkUpdated;
extern NSString * const kAlfrescoFilterValueActivityTypeLinkDeleted;
extern NSString * const kAlfrescoFilterValueActivityTypeCommentCreated;
extern NSString * const kAlfrescoFilterValueActivityTypeCommentUpdated;
extern NSString * const kAlfrescoFilterValueActivityTypeCommentDeleted;
extern NSString * const kAlfrescoFilterValueActivityTypeBlogPostCreated;
extern NSString * const kAlfrescoFilterValueActivityTypeBlogPostUpdated;
extern NSString * const kAlfrescoFilterValueActivityTypeBlogPostDeleted;
extern NSString * const kAlfrescoFilterValueActivityTypeDiscussionPostCreated;
extern NSString * const kAlfrescoFilterValueActivityTypeDiscussionPostUpdated;
extern NSString * const kAlfrescoFilterValueActivityTypeDiscussionPostDeleted;
extern NSString * const kAlfrescoFilterValueActivityTypeDiscussionReplyCreated;
extern NSString * const kAlfrescoFilterValueActivityTypeDiscussionReplyUpdated;
extern NSString * const kAlfrescoFilterValueActivityTypeCalendarEventCreated;
extern NSString * const kAlfrescoFilterValueActivityTypeCalendarEventUpdated;
extern NSString * const kAlfrescoFilterValueActivityTypeCalendarEventDeleted;
extern NSString * const kAlfrescoFilterValueActivityTypeWikiPageCreated;
extern NSString * const kAlfrescoFilterValueActivityTypeWikiPageUpdated;
extern NSString * const kAlfrescoFilterValueActivityTypeWikiPageDeleted;
extern NSString * const kAlfrescoFilterValueActivityTypeDataListCreated;
extern NSString * const kAlfrescoFilterValueActivityTypeDataListUpdated;
extern NSString * const kAlfrescoFilterValueActivityTypeDataListDeleted;
extern NSString * const kAlfrescoFilterValueActivityTypeFollowed;
extern NSString * const kAlfrescoFilterValueActivityTypeSubscribed;
extern NSString * const kAlfrescoFilterValueActivityTypeProfileStatusChanged;

extern NSString * const kAlfrescoFilterByActivityUser;


/**---------------------------------------------------------------------------------------
 * @name capability constants
 --------------------------------------------------------------------------------------- */
extern NSString * const kAlfrescoCapabilityLike;
extern NSString * const kAlfrescoCapabilityCommentsCount;
extern NSString * const kAlfrescoCapabilityPublicAPI;
extern NSString * const kAlfrescoCapabilityActivitiWorkflowEngine;
extern NSString * const kAlfrescoCapabilityJBPMWorkflowEngine;
extern NSString * const kAlfrescoCapabilityMyFiles;
extern NSString * const kAlfrescoCapabilitySharedFiles;

/**---------------------------------------------------------------------------------------
 * @name File Attribute Constants
 --------------------------------------------------------------------------------------- */
extern NSString * const kAlfrescoFileSize;
extern NSString * const kAlfrescoFileLastModification;
extern NSString * const kAlfrescoIsFolder;

/**---------------------------------------------------------------------------------------
 * @name Custom Alfresco Network Provider
 --------------------------------------------------------------------------------------- */
extern NSString * const kAlfrescoNetworkProvider;
extern NSString * const kAlfrescoCMISBindingURL;
extern NSString * const kAlfrescoAllowUntrustedSSLCertificate;
extern NSString * const kAlfrescoConnectUsingClientSSLCertificate;
extern NSString * const kAlfrescoClientCertificateCredentials;

/**---------------------------------------------------------------------------------------
 * @name Model Constants
 --------------------------------------------------------------------------------------- */
extern NSString * const kAlfrescoModelTypeContent;
extern NSString * const kAlfrescoModelTypeFolder;

extern NSString * const kAlfrescoModelAspectTitled;
extern NSString * const kAlfrescoModelAspectAuthor;
extern NSString * const kAlfrescoModelAspectGeographic;
extern NSString * const kAlfrescoModelAspectExif;
extern NSString * const kAlfrescoModelAspectAudio;

extern NSString * const kAlfrescoModelPropertyName;
extern NSString * const kAlfrescoModelPropertyTitle;
extern NSString * const kAlfrescoModelPropertyDescription;
extern NSString * const kAlfrescoModelPropertyAuthor;
extern NSString * const kAlfrescoModelPropertyLatitude;
extern NSString * const kAlfrescoModelPropertyLongitude;

extern NSString * const kAlfrescoModelPropertyUserName;
extern NSString * const kAlfrescoModelPropertyFirstName;
extern NSString * const kAlfrescoModelPropertyLastName;
extern NSString * const kAlfrescoModelPropertyMiddleName;
extern NSString * const kAlfrescoModelPropertyEmail;
extern NSString * const kAlfrescoModelPropertyOrganization;
extern NSString * const kAlfrescoModelPropertyOrganizationId;
extern NSString * const kAlfrescoModelPropertyHomeFolder;
extern NSString * const kAlfrescoModelPropertyHomeFolderProvider;
extern NSString * const kAlfrescoModelPropertyPresenceProvider;
extern NSString * const kAlfrescoModelPropertyPresenceUserName;
extern NSString * const kAlfrescoModelPropertyJobTitle;
extern NSString * const kAlfrescoModelPropertyLocation;
extern NSString * const kAlfrescoModelPropertyPersonDescription;
extern NSString * const kAlfrescoModelPropertyTelephone;
extern NSString * const kAlfrescoModelPropertyMobile;
extern NSString * const kAlfrescoModelPropertySkype;
extern NSString * const kAlfrescoModelPropertyInstantMsg;
extern NSString * const kAlfrescoModelPropertyUserStatus;
extern NSString * const kAlfrescoModelPropertyUserStatusTime;
extern NSString * const kAlfrescoModelPropertyGoogleUserName;
extern NSString * const kAlfrescoModelPropertyEmailFeedDisabled;
extern NSString * const kAlfrescoModelPropertySubscriptionsPrivate;
extern NSString * const kAlfrescoModelPropertyCompanyAddress1;
extern NSString * const kAlfrescoModelPropertyCompanyAddress2;
extern NSString * const kAlfrescoModelPropertyCompanyAddress3;
extern NSString * const kAlfrescoModelPropertyCompanyPostCode;
extern NSString * const kAlfrescoModelPropertyCompanyTelephone;
extern NSString * const kAlfrescoModelPropertyCompanyFax;
extern NSString * const kAlfrescoModelPropertyCompanyEmail;

extern NSString * const kAlfrescoModelPropertyExifDateTimeOriginal;
extern NSString * const kAlfrescoModelPropertyExifPixelXDimension;
extern NSString * const kAlfrescoModelPropertyExifPixelYDimension;
extern NSString * const kAlfrescoModelPropertyExifExposureTime;
extern NSString * const kAlfrescoModelPropertyExifFNumber;
extern NSString * const kAlfrescoModelPropertyExifFlash;
extern NSString * const kAlfrescoModelPropertyExifFocalLength;
extern NSString * const kAlfrescoModelPropertyExifISOSpeedRating;
extern NSString * const kAlfrescoModelPropertyExifManufacturer;
extern NSString * const kAlfrescoModelPropertyExifModel;
extern NSString * const kAlfrescoModelPropertyExifSoftware;
extern NSString * const kAlfrescoModelPropertyExifOrientation;
extern NSString * const kAlfrescoModelPropertyExifXResolution;
extern NSString * const kAlfrescoModelPropertyExifYResolution;
extern NSString * const kAlfrescoModelPropertyExifResolutionUnit;

extern NSString * const kAlfrescoModelPropertyAudioAlbum;
extern NSString * const kAlfrescoModelPropertyAudioArtist;
extern NSString * const kAlfrescoModelPropertyAudioComposer;
extern NSString * const kAlfrescoModelPropertyAudioEngineer;
extern NSString * const kAlfrescoModelPropertyAudioGenre;
extern NSString * const kAlfrescoModelPropertyAudioTrackNumber;
extern NSString * const kAlfrescoModelPropertyAudioReleaseDate;
extern NSString * const kAlfrescoModelPropertyAudioSampleRate;
extern NSString * const kAlfrescoModelPropertyAudioSampleType;
extern NSString * const kAlfrescoModelPropertyAudioChannelType;
extern NSString * const kAlfrescoModelPropertyAudioCompressor;

/**---------------------------------------------------------------------------------------
 * @name Workflow Constants
 --------------------------------------------------------------------------------------- */
extern NSString * const kAlfrescoWorkflowVariableProcessName;
extern NSString * const kAlfrescoWorkflowVariableProcessDescription;
extern NSString * const kAlfrescoWorkflowVariableProcessPriority;
extern NSString * const kAlfrescoWorkflowVariableProcessDueDate;
extern NSString * const kAlfrescoWorkflowVariableProcessSendEmailNotifications;
extern NSString * const kAlfrescoWorkflowVariableProcessApprovalRate;
extern NSString * const kAlfrescoWorkflowVariableTaskTransition;
extern NSString * const kAlfrescoWorkflowVariableTaskComment;
extern NSString * const kAlfrescoWorkflowVariableTaskStatus;
extern NSString * const kAlfrescoWorkflowVariableTaskReviewOutcome;
extern NSString * const kAlfrescoWorkflowVariableTaskInvitePendingOutcome;

extern NSString * const kAlfrescoWorkflowTaskTransitionApprove;
extern NSString * const kAlfrescoWorkflowTaskTransitionAccept;
extern NSString * const kAlfrescoWorkflowTaskTransitionReject;

/**---------------------------------------------------------------------------------------
 * @name Connection Diagnostic Constants
 --------------------------------------------------------------------------------------- */
extern NSString * const kAlfrescoConfigurationDiagnosticDidStartEventNotification;
extern NSString * const kAlfrescoConfigurationDiagnosticDidEndEventNotification;

extern NSString * const kAlfrescoConfigurationDiagnosticDictionaryEventName;
extern NSString * const kAlfrescoConfigurationDiagnosticDictionaryError;
extern NSString * const kAlfrescoConfigurationDiagnosticDictionaryStatus;

extern NSString * const kAlfrescoConfigurationDiagnosticReachabilityEvent;
extern NSString * const kAlfrescoConfigurationDiagnosticServerVersionEvent;
extern NSString * const kAlfrescoConfigurationDiagnosticRepositoriesAvailableEvent;
extern NSString * const kAlfrescoConfigurationDiagnosticConnectRepositoryEvent;
extern NSString * const kAlfrescoConfigurationDiagnosticRetrieveRootFolderEvent;

/**---------------------------------------------------------------------------------------
 * @name Connection Diagnostic Enums
 --------------------------------------------------------------------------------------- */
typedef NS_ENUM(NSInteger, AlfrescoConnectionDiagnosticStatus)
{
    AlfrescoConnectionDiagnosticStatusLoading = 0,
    AlfrescoConnectionDiagnosticStatusSuccess,
    AlfrescoConnectionDiagnosticStatusFailure
};
