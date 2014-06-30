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
// workflow
typedef void (^AlfrescoProcessDefinitionCompletionBlock)(AlfrescoWorkflowProcessDefinition *processDefinition, NSError *error);
typedef void (^AlfrescoProcessCompletionBlock)(AlfrescoWorkflowProcess *process, NSError *error);
typedef void (^AlfrescoTaskCompletionBlock)(AlfrescoWorkflowTask *task, NSError *error);
typedef void (^AlfrescoDictionaryCompletionBlock)(NSDictionary *dictionary, NSError *error);


/**---------------------------------------------------------------------------------------
 * @name Session parameters
 --------------------------------------------------------------------------------------- */
extern NSString * const kAlfrescoMetadataExtraction;
extern NSString * const kAlfrescoThumbnailCreation;

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

/**---------------------------------------------------------------------------------------
 * @name capability constants
 --------------------------------------------------------------------------------------- */
extern NSString * const kAlfrescoCapabilityLike;
extern NSString * const kAlfrescoCapabilityCommentsCount;
extern NSString * const kAlfrescoCapabilityPublicAPI;
extern NSString * const kAlfrescoCapabilityActivitiWorkflowEngine;
extern NSString * const kAlfrescoCapabilityJBPMWorkflowEngine;

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
extern NSString * const kAlfrescoWorkflowVariableProcessPriority;
extern NSString * const kAlfrescoWorkflowVariableProcessDueDate;
extern NSString * const kAlfrescoWorkflowVariableProcessSendEmailNotifications;
extern NSString * const kAlfrescoWorkflowVariableProcessApprovalRate;
extern NSString * const kAlfrescoWorkflowVariableTaskTransition;
extern NSString * const kAlfrescoWorkflowVariableTaskComment;
extern NSString * const kAlfrescoWorkflowVariableTaskStatus;
extern NSString * const kAlfrescoWorkflowVariableTaskReviewOutcome;

extern NSString * const kAlfrescoWorkflowTaskTransitionApprove;
extern NSString * const kAlfrescoWorkflowTaskTransitionReject;
