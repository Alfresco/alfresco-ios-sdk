/*
 ******************************************************************************
 * Copyright (C) 2005-2016 Alfresco Software Limited.
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
#import "AlfrescoWorkflowInternalConstants.h"

extern NSString * const kAlfrescoClassVersion;

extern NSString * const kAlfrescoISO8601DateStringFormat;

extern NSString * const kAlfrescoCMISPropertyTypeInt;
extern NSString * const kAlfrescoCMISPropertyTypeBoolean;
extern NSString * const kAlfrescoCMISPropertyTypeDatetime;
extern NSString * const kAlfrescoCMISPropertyTypeDecimal;
extern NSString * const kAlfrescoCMISPropertyTypeId;
extern NSString * const kAlfrescoCMISNetworkProvider;
extern NSString * const kAlfrescoCMISModelPrefix;
extern NSString * const kAlfrescoCMISFolderTypePrefix;
extern NSString * const kAlfrescoCMISDocumentTypePrefix;
extern NSString * const kAlfrescoCMISAspectPrefix;
extern NSString * const kAlfrescoCMISNamespace;
extern NSString * const kAlfrescoCMISSetAspects;
extern NSString * const kAlfrescoCMISAspectsToAdd;
extern NSString * const kAlfrescoCMISMandatoryAspects;
extern NSUInteger const kAlfrescoCMISUploadBufferChunkSize;

extern NSString * const kAlfrescoContentModelPrefix;
extern NSString * const kAlfrescoSystemModelPrefix;
extern NSString * const kAlfrescoSystemModelAspectLocalized;

extern NSString * const kAlfrescoRepositoryName;
extern NSString * const kAlfrescoRepositoryNamePattern;
extern NSString * const kAlfrescoRepositoryEdition;
extern NSString * const kAlfrescoRepositoryEditionCommunity;
extern NSString * const kAlfrescoRepositoryEditionEnterprise;
extern NSString * const kAlfrescoRepositoryEditionCloud;
extern NSString * const kAlfrescoRepositoryEditionUnknown;
extern NSString * const kAlfrescoRepositoryIdentifier;
extern NSString * const kAlfrescoRepositorySummary;
extern NSString * const kAlfrescoRepositoryVersion;
extern NSString * const kAlfrescoRepositoryMajorVersion;
extern NSString * const kAlfrescoRepositoryMinorVersion;
extern NSString * const kAlfrescoRepositoryMaintenanceVersion;
extern NSString * const kAlfrescoRepositoryBuildNumber;
extern NSString * const kAlfrescoRepositoryCapabilities;

extern NSString * const kAlfrescoSiteId;
extern NSString * const kAlfrescoSiteGUID;
extern NSString * const kAlfrescoInviteId;
extern NSString * const kAlfrescoNodeRef;
extern NSString * const kAlfrescoPersonId;
extern NSString * const kAlfrescoCommentId;
extern NSString * const kAlfrescoRenditionId;
extern NSString * const kAlfrescoNodeRefURL;
extern NSString * const kAlfrescoNode;
extern NSString * const kAlfrescoDefaultMimeType;
extern NSString * const kAlfrescoAspects;
extern NSString * const kAlfrescoAppliedAspects;
extern NSString * const kAlfrescoAspectProperties;
extern NSString * const kAlfrescoAspectPropertyDefinitionId;
extern NSString * const kAlfrescoPagingRequest;
extern NSString * const kAlfrescoSkipCountRequest;
extern NSString * const kAlfrescoMaxItemsRequest;
extern NSString * const kAlfrescoClientID;
extern NSString * const kAlfrescoClientSecret;
extern NSString * const kAlfrescoCode;
extern NSString * const kAlfrescoRedirectURI;
extern NSString * const kAlfrescoRefreshID;
extern NSString * const kAlfrescoMe;
extern NSString * const kAlfrescoModerated;
extern NSString * const kAlfrescoSiteConsumer;
extern NSString * const kAlfrescoMaxItems;
extern NSString * const kAlfrescoSkipCount;
extern NSString * const kAlfrescoSearchFilter;
extern NSString * const kAlfrescoReverseComments;

extern NSString * const kAlfrescoSessionKeyCmisSession;
extern NSString * const kAlfrescoSessionCloudURL;
extern NSString * const kAlfrescoSessionCloudBasicAuth;
extern NSString * const kAlfrescoOAuthRequestDenyAction;
extern NSString * const kAlfrescoSessionUsername;
extern NSString * const kAlfrescoSessionPassword;
extern NSString * const kAlfrescoSessionCacheSites;
extern NSString * const kAlfrescoSessionCacheFavorites;
extern NSString * const kAlfrescoSessionCacheDefinitionType;
extern NSString * const kAlfrescoSessionCacheDefinitionAspect;
extern NSString * const kAlfrescoSessionAlternatePersonIdentifier;
extern NSTimeInterval const kAlfrescoSessionExpirationTimeIntervalCheck;

extern NSString * const kAlfrescoSiteIsFavorite;
extern NSString * const kAlfrescoSiteIsMember;
extern NSString * const kAlfrescoSiteIsPendingMember;

extern NSString * const kAlfrescoAuthenticationProviderObjectKey;

extern NSString *const kAlfrescoJSONAccessToken;
extern NSString *const kAlfrescoJSONRefreshToken;
extern NSString *const kAlfrescoJSONTokenType;
extern NSString *const kAlfrescoJSONExpiresIn;
extern NSString *const kAlfrescoJSONScope;
extern NSString *const kAlfrescoJSONError;
extern NSString *const kAlfrescoJSONErrorDescription;
extern NSString *const kAlfrescoOAuthClientID;
extern NSString *const kAlfrescoOAuthClientSecret;
extern NSString *const kAlfrescoOAuthGrantType;
extern NSString *const kAlfrescoOAuthRedirectURI;
extern NSString *const kAlfrescoOAuthCode;
extern NSString *const kAlfrescoOAuthAuthorize;
extern NSString *const kAlfrescoOAuthToken;
extern NSString *const kAlfrescoOAuthScope;
extern NSString *const kAlfrescoOAuthResponseType;
extern NSString *const kAlfrescoOAuthGrantTypeRefresh;
extern NSString *const kAlfrescoOAuthRefreshToken;

extern NSString * const kAlfrescoLegacyAPIPath;
extern NSString * const kAlfrescoLegacyCMISPath;
extern NSString * const kAlfrescoLegacyCMISAtomPath;
extern NSString * const kAlfrescoLegacyAPINodeRefPrefix;
extern NSString * const kAlfrescoLegacyActivityAPI;
extern NSString * const kAlfrescoLegacyActivityForSiteAPI;
extern NSString * const kAlfrescoLegacyRatingsAPI;
extern NSString * const kAlfrescoLegacyRatingsLikingSchemeAPI;
extern NSString * const kAlfrescoLegacyRatingsCount;
extern NSString * const kAlfrescoLegacyLikesSchemeRatings;
extern NSString * const kAlfrescoLegacySiteAPI;
extern NSString * const kAlfrescoLegacySiteSearchAPI;
extern NSString * const kAlfrescoLegacySiteForPersonAPI;
extern NSString * const kAlfrescoLegacyFavoriteSiteForPersonAPI;
extern NSString * const kAlfrescoLegacySitesShortnameAPI;
extern NSString * const kAlfrescoLegacySiteDoclibAPI;
extern NSString * const kAlfrescoLegacyFavoriteSites;
extern NSString * const kAlfrescoLegacyCommentsAPI;
extern NSString * const kAlfrescoLegacyCommentForNodeAPI;
extern NSString * const kAlfrescoLegacyTagsAPI;
extern NSString * const kAlfrescoLegacyTagsForNodeAPI;
extern NSString * const kAlfrescoLegacyPersonAPI;
extern NSString * const kAlfrescoLegacyPersonSearchAPI;
extern NSString * const kAlfrescoLegacyAvatarForPersonAPI;
extern NSString * const kAlfrescoLegacyMetadataExtractionAPI;
extern NSString * const kAlfrescoLegacyThumbnailCreationAPI;
extern NSString * const kAlfrescoLegacyThumbnailRenditionAPI;
extern NSString * const kAlfrescoLegacyPreferencesAPI;
extern NSString * const kAlfrescoLegacyJoinPublicSiteAPI;
extern NSString * const kAlfrescoLegacyJoinModeratedSiteAPI;
extern NSString * const kAlfrescoLegacyPendingJoinRequestsAPI;
extern NSString * const kAlfrescoLegacyCancelJoinRequestsAPI;
extern NSString * const kAlfrescoLegacyLeaveSiteAPI;
extern NSString * const kAlfrescoLegacySiteMembershipFilter;
extern NSString * const kAlfrescoLegacyFavoriteDocumentsAPI;
extern NSString * const kAlfrescoLegacyFavoriteFoldersAPI;
extern NSString * const kAlfrescoLegacyFavoriteDocuments;
extern NSString * const kAlfrescoLegacyFavoriteFolders;

extern NSString * const kAlfrescoPublicAPIPath;
extern NSString * const kAlfrescoPublicAPICMISAtomPath;
extern NSString * const kAlfrescoPublicAPICMISBrowserPath;
extern NSString * const kAlfrescoPublicAPISite;
extern NSString * const kAlfrescoPublicAPISiteForPerson;
extern NSString * const kAlfrescoPublicAPIFavoriteSiteForPerson;
extern NSString * const kAlfrescoPublicAPISiteForShortname;
extern NSString * const kAlfrescoPublicAPISiteContainers;
extern NSString * const kAlfrescoPublicAPIActivities;
extern NSString * const kAlfrescoPublicAPIActivitiesForSite;
extern NSString * const kAlfrescoPublicAPIRatings;
extern NSString * const kAlfrescoPublicAPILikesRatingScheme;
extern NSString * const kAlfrescoPublicAPIComments;
extern NSString * const kAlfrescoPublicAPICommentForNode;
extern NSString * const kAlfrescoPublicAPITags;
extern NSString * const kAlfrescoPublicAPITagsForNode;
extern NSString * const kAlfrescoPublicAPIPerson;
extern NSString * const kAlfrescoPublicAPIPersonSearch;
extern NSString * const kAlfrescoPublicAPIAddFavoriteSite;
extern NSString * const kAlfrescoPublicAPIRemoveFavoriteSite;
extern NSString * const kAlfrescoPublicAPIJoinSite;
extern NSString * const kAlfrescoPublicAPICancelJoinRequests;
extern NSString * const kAlfrescoPublicAPILeaveSite;
extern NSString * const kAlfrescoPublicAPIPagingParameters;
extern NSString * const kAlfrescoPublicAPISiteMembers;
extern NSString * const kAlfrescoPublicAPIFavoriteDocuments;
extern NSString * const kAlfrescoPublicAPIFavoriteFolders;
extern NSString * const kAlfrescoPublicAPIFavoritesAll;
extern NSString * const kAlfrescoPublicAPIFavorite;
extern NSString * const kAlfrescoPublicAPIAddFavorite;
extern NSString * const kAlfrescoLegacyServerAPI;

extern NSString * const kAlfrescoDocumentLibrary;

extern NSString * const kAlfrescoCloudURL;
extern NSString * const kAlfrescoCloudDefaultRedirectURI;
extern NSString * const kAlfrescoCloudAPIPath;
extern NSString * const kAlfrescoCloudCMISPath;
extern NSString * const kAlfrescoCloudCMIS11AtomPath;
extern NSString * const kAlfrescoCloudAPIRateLimitExceeded;
extern NSString * const kAlfrescoCloudAPIQuery;
extern NSString * const kAlfrescoHomeNetworkType;

extern NSString * const kAlfrescoPublicAPIJSONList;
extern NSString * const kAlfrescoPublicAPIJSONPagination;
extern NSString * const kAlfrescoPublicAPIJSONCount;
extern NSString * const kAlfrescoPublicAPIJSONHasMoreItems;
extern NSString * const kAlfrescoPublicAPIJSONTotalItems;
extern NSString * const kAlfrescoPublicAPIJSONSkipCount;
extern NSString * const kAlfrescoPublicAPIJSONMaxItems;
extern NSString * const kAlfrescoPublicAPIJSONEntries;
extern NSString * const kAlfrescoPublicAPIJSONEntry;
extern NSString * const kAlfrescoJSONIdentifier;
extern NSString * const kAlfrescoJSONStatusCode;
extern NSString * const kAlfrescoJSONActivityPostDate;
extern NSString * const kAlfrescoJSONActivityPostUserID;
extern NSString * const kAlfrescoJSONActivityPostPersonID;
extern NSString * const kAlfrescoJSONActivitySiteNetwork;
extern NSString * const kAlfrescoJSONActivityType;
extern NSString * const kAlfrescoJSONActivitySummary;
extern NSString * const kAlfrescoJSONActivityDataNodeRef;
extern NSString * const kAlfrescoJSONActivityDataObjectId;
extern NSString * const kAlfrescoJSONActivityDataPage;
extern NSString * const kAlfrescoJSONRating;
extern NSString * const kAlfrescoJSONRatingScheme;
extern NSString * const kAlfrescoJSONLikesRatingScheme;
extern NSString * const kAlfrescoJSONDescription;
extern NSString * const kAlfrescoJSONTitle;
extern NSString * const kAlfrescoJSONShortname;
extern NSString * const kAlfrescoJSONVisibility;
extern NSString * const kAlfrescoJSONVisibilityPUBLIC;
extern NSString * const kAlfrescoJSONVisibilityPRIVATE;
extern NSString * const kAlfrescoJSONVisibilityMODERATED;
extern NSString * const kAlfrescoJSONContainers;
extern NSString * const kAlfrescoJSONNodeRef;
extern NSString * const kAlfrescoJSONNode;
extern NSString * const kAlfrescoJSONSiteID;
extern NSString * const kAlfrescoJSONLikes;
extern NSString * const kAlfrescoJSONMyRating;
extern NSString * const kAlfrescoJSONAggregate;
extern NSString * const kAlfrescoJSONNumberOfRatings;
extern NSString * const kAlfrescoJSONHomeNetwork;
extern NSString * const kAlfrescoJSONIsEnabled;
extern NSString * const kAlfrescoJSONNetwork;
extern NSString * const kAlfrescoJSONPaidNetwork;
extern NSString * const kAlfrescoJSONCreationTime;
extern NSString * const kAlfrescoJSONSubscriptionLevel;
extern NSString * const kAlfrescoJSONName;
extern NSString * const kAlfrescoJSONItems;
extern NSString * const kAlfrescoJSONItem;
extern NSString * const kAlfrescoJSONCreatedOn;
extern NSString * const kAlfrescoJSONCreatedOnISO;
extern NSString * const kAlfrescoJSONAuthorUserName;
extern NSString * const kAlfrescoJSONAuthor;
extern NSString * const kAlfrescoJSONUsername;
extern NSString * const kAlfrescoJSONModifiedOn;
extern NSString * const kAlfrescoJSONModifiedOnISO;
extern NSString * const kAlfrescoJSONContent;
extern NSString * const kAlfrescoJSONIsUpdated;
extern NSString * const kAlfrescoJSONPermissionsEdit;
extern NSString * const kAlfrescoJSONPermissionsDelete;
extern NSString * const kAlfrescoJSONPermissions;
extern NSString * const kAlfrescoJSONEdit;
extern NSString * const kAlfrescoJSONDelete;
extern NSString * const kAlfrescoJSONCreatedAt;
extern NSString * const kAlfrescoJSONCreatedBy;
extern NSString * const kAlfrescoJSONCreator;
extern NSString * const kAlfrescoJSONAvatar;
extern NSString * const kAlfrescoJSONAuthority;
extern NSString * const kAlfrescoJSONModifiedAt;
extern NSString * const kAlfrescoJSONEdited;
extern NSString * const kAlfrescoJSONCanEdit;
extern NSString * const kAlfrescoJSONCanDelete;
extern NSString * const kAlfrescoJSONEnable;
extern NSString * const kAlfrescoJSONTag;
extern NSString * const kAlfrescoJSONUserName;
extern NSString * const kAlfrescoJSONFirstName;
extern NSString * const kAlfrescoJSONFullName;
extern NSString * const kAlfrescoJSONLastName;
extern NSString * const kAlfrescoJSONActionedUponNode;
extern NSString * const kAlfrescoJSONExtractMetadata;
extern NSString * const kAlfrescoJSONActionDefinitionName;
extern NSString * const kAlfrescoJSONThumbnailName;
extern NSString * const kAlfrescoJSONSite;
extern NSString * const kAlfrescoJSONPostedAt;
extern NSString * const kAlfrescoJSONAvatarId;
extern NSString * const kAlfrescoJSONJobTitle;
extern NSString * const kAlfrescoPublicAPIJSONJobTitle;
extern NSString * const kAlfrescoJSONLocation;
extern NSString * const kAlfrescoJSONTelephoneNumber;
extern NSString * const kAlfrescoJSONMobileNumber;
extern NSString * const kAlfrescoJSONSkypeId;
extern NSString * const kAlfrescoJSONGoogleId;
extern NSString * const kAlfrescoJSONInstantMessageId;
extern NSString * const kAlfrescoJSONSkype;
extern NSString * const kAlfrescoJSONGoogle;
extern NSString * const kAlfrescoJSONInstantMessage;
extern NSString * const kAlfrescoJSONStatus;
extern NSString * const kAlfrescoJSONStatusTime;
extern NSString * const kAlfrescoJSONEmail;
extern NSString * const kAlfrescoJSONCompany;
extern NSString * const kAlfrescoJSONCompanyAddressLine1;
extern NSString * const kAlfrescoJSONCompanyAddressLine2;
extern NSString * const kAlfrescoJSONCompanyAddressLine3;
extern NSString * const kAlfrescoJSONCompanyFullAddress;
extern NSString * const kAlfrescoJSONCompanyPostcode;
extern NSString * const kAlfrescoJSONCompanyFaxNumber;
extern NSString * const kAlfrescoJSONCompanyName;
extern NSString * const kAlfrescoJSONCompanyTelephone;
extern NSString * const kAlfrescoJSONCompanyEmail;
extern NSString * const kAlfrescoJSONAddressLine1;
extern NSString * const kAlfrescoJSONPostcode;
extern NSString * const kAlfrescoJSONFaxNumber;
extern NSString * const kAlfrescoJSONPersonDescription;
extern NSString * const kAlfrescoJSONAddressLine1;
extern NSString * const kAlfrescoJSONAddressLine2;
extern NSString * const kAlfrescoJSONAddressLine3;


extern NSString * const kAlfrescoJSONOrg;
extern NSString * const kAlfrescoJSONAlfresco;
extern NSString * const kAlfrescoJSONShare;
extern NSString * const kAlfrescoJSONSites;
extern NSString * const kAlfrescoJSONFavorites;
extern NSString * const kAlfrescoJSONGUID;
extern NSString * const kAlfrescoJSONTarget;
extern NSString * const kAlfrescoJSONPerson;
extern NSString * const kAlfrescoJSONPeople;
extern NSString * const kAlfrescoJSONRole;
extern NSString * const kAlfrescoJSONInvitationType;
extern NSString * const kAlfrescoJSONInviteeUsername;
extern NSString * const kAlfrescoJSONInviteeComments;
extern NSString * const kAlfrescoJSONInviteeRolename;
extern NSString * const kAlfrescoJSONInviteId;
extern NSString * const kAlfrescoJSONData;
extern NSString * const kAlfrescoJSONResourceName;
extern NSString * const kAlfrescoJSONMessage;
extern NSString * const kAlfrescoJSONFile;
extern NSString * const kAlfrescoJSONFolder;

extern NSString * const kAlfrescoLegacyJSONMaxItems;
extern NSString * const kAlfrescoLegacyJSONSkipCount;
extern NSString * const kAlfrescoLegacyJSONTotal;
extern NSString * const kAlfrescoLegacyJSONHasMoreItems;

extern NSString * const kAlfrescoNodeAspects;
extern NSString * const kAlfrescoNodeProperties;
extern NSString * const kAlfrescoPropertyType;
extern NSString * const kAlfrescoPropertyValue;
extern NSString * const kAlfrescoPropertyIsMultiValued;

extern NSString * const kAlfrescoHTTPDelete;
extern NSString * const kAlfrescoHTTPGet;
extern NSString * const kAlfrescoHTTPPost;
extern NSString * const kAlfrescoHTTPPut;

extern NSString * const kAlfrescoFileManagerClass;

extern NSString * const kAlfrescoPersonPropertyFirstName;
extern NSString * const kAlfrescoPersonPropertyLastName;
extern NSString * const kAlfrescoPersonPropertyJobTitle;
extern NSString * const kAlfrescoPersonPropertyLocation;
extern NSString * const kAlfrescoPersonPropertyDescription;
extern NSString * const kAlfrescoPersonPropertyTelephoneNumber;
extern NSString * const kAlfrescoPersonPropertyMobileNumber;
extern NSString * const kAlfrescoPersonPropertyEmail;
extern NSString * const kAlfrescoPersonPropertySkypeId;
extern NSString * const kAlfrescoPersonPropertyInstantMessageId;
extern NSString * const kAlfrescoPersonPropertyGoogleId;
extern NSString * const kAlfrescoPersonPropertyStatus;
extern NSString * const kAlfrescoPersonPropertyStatusTime;
extern NSString * const kAlfrescoPersonPropertyCompanyName;
extern NSString * const kAlfrescoPersonPropertyCompanyAddressLine1;
extern NSString * const kAlfrescoPersonPropertyCompanyAddressLine2;
extern NSString * const kAlfrescoPersonPropertyCompanyAddressLine3;
extern NSString * const kAlfrescoPersonPropertyCompanyPostcode;
extern NSString * const kAlfrescoPersonPropertyCompanyTelephoneNumber;
extern NSString * const kAlfrescoPersonPropertyCompanyFaxNumber;
extern NSString * const kAlfrescoPersonPropertyCompanyEmail;

extern NSString * const kAlfrescoDefaultBackgroundNetworkSessionId;
extern NSString * const kAlfrescoDefaultBackgroundNetworkSessionSharedContainerId;

/**---------------------------------------------------------------------------------------
 * @name Cloud Connection Status
 --------------------------------------------------------------------------------------- */
typedef NS_ENUM(NSInteger, AlfrescoCloudConnectionStatus)
{
    AlfrescoCloudConnectionStatusInactive = 0,
    AlfrescoCloudConnectionStatusActive,
    AlfrescoCloudConnectionStatusGotAuthCode
};

/**---------------------------------------------------------------------------------------
* @name Payload Token Keys Constants
--------------------------------------------------------------------------------------- */

extern NSString * const kAlfrescoPayloadToken;
extern NSString * const kAlfrescoPayloadTokenUsername;
