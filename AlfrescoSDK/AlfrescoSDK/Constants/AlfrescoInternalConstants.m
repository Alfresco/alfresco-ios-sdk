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

#import "AlfrescoInternalConstants.h"


/**
 Class Version constants
 */
NSString * const kAlfrescoClassVersion = @"alfresco.classVersion";

NSString * const kAlfrescoISO8601DateStringFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ";

/**
 CMIS constants
 */
NSString * const kAlfrescoCMISPropertyTypeInt = @"int";
NSString * const kAlfrescoCMISPropertyTypeBoolean = @"boolean";
NSString * const kAlfrescoCMISPropertyTypeDatetime = @"datetime";
NSString * const kAlfrescoCMISPropertyTypeDecimal = @"decimal";
NSString * const kAlfrescoCMISPropertyTypeId = @"id";
NSString * const kAlfrescoCMISNetworkProvider = @"org.alfresco.mobile.internal.session.cmis.networkprovider";
NSString * const kAlfrescoCMISModelPrefix = @"cmis:";
NSString * const kAlfrescoCMISFolderTypePrefix = @"F:";
NSString * const kAlfrescoCMISDocumentTypePrefix = @"D:";
NSString * const kAlfrescoCMISAspectPrefix = @"P:";

/**
 Content Model constants
 */
NSString * const kAlfrescoContentModelPrefix = @"cm:";
NSString * const kAlfrescoSystemModelPrefix = @"sys:";
NSString * const kAlfrescoSystemModelAspectLocalized = @"sys:localized";

/**
 Property name constants
 */
NSString * const kAlfrescoRepositoryName = @"name";
NSString * const kAlfrescoRepositoryNamePattern = @"Alfresco Repository (%@)";
NSString * const kAlfrescoRepositoryEdition = @"edition";
NSString * const kAlfrescoRepositoryEditionCommunity = @"Community";
NSString * const kAlfrescoRepositoryEditionEnterprise = @"Enterprise";
NSString * const kAlfrescoRepositoryEditionCloud = @"Alfresco in the Cloud";
NSString * const kAlfrescoRepositoryEditionUnknown = @"Unknown";
NSString * const kAlfrescoRepositoryIdentifier = @"identifier";
NSString * const kAlfrescoRepositorySummary = @"summary";
NSString * const kAlfrescoRepositoryVersion = @"version";
NSString * const kAlfrescoRepositoryMajorVersion = @"majorVersion";
NSString * const kAlfrescoRepositoryMinorVersion = @"minorVersion";
NSString * const kAlfrescoRepositoryMaintenanceVersion = @"maintenanceVersion";
NSString * const kAlfrescoRepositoryBuildNumber = @"buildNumber";
NSString * const kAlfrescoRepositoryCapabilities = @"capabilities";

/**
 Parametrised strings to be used in API
 */
NSString * const kAlfrescoSiteId = @"{siteID}";
NSString * const kAlfrescoSiteGUID = @"{siteGUID}";
NSString * const kAlfrescoInviteId = @"{inviteID}";
NSString * const kAlfrescoNodeRef = @"{nodeRef}";
NSString * const kAlfrescoPersonId = @"{personID}";
NSString * const kAlfrescoCommentId = @"{commentID}";
NSString * const kAlfrescoRenditionId = @"{renditionID}";
NSString * const kAlfrescoSkipCountRequest = @"{skipCount}";
NSString * const kAlfrescoMaxItemsRequest = @"{maxItems}";
NSString * const kAlfrescoNodeRefURL = @"workspace://SpacesStore/{nodeRef}";
NSString * const kAlfrescoNode = @"node";
NSString * const kAlfrescoDefaultMimeType = @"application/octet-stream";
NSString * const kAlfrescoAspects = @"aspects";
NSString * const kAlfrescoAppliedAspects = @"appliedAspects";
NSString * const kAlfrescoAspectProperties = @"properties";
NSString * const kAlfrescoAspectPropertyDefinitionId = @"propertyDefinitionId";
NSString * const kAlfrescoPagingRequest = @"?skipCount={skipCount}&maxItems={maxItems}";
NSString * const kAlfrescoClientID = @"{clientID}";
NSString * const kAlfrescoClientSecret = @"{clientSecret}";
NSString * const kAlfrescoCode = @"{code}";
NSString * const kAlfrescoRedirectURI = @"{redirectURI}";
NSString * const kAlfrescoRefreshID = @"{refreshID}";
NSString * const kAlfrescoMe = @"-me-";
NSString * const kAlfrescoModerated = @"MODERATED";
NSString * const kAlfrescoSiteConsumer = @"SiteConsumer";
NSString * const kAlfrescoMaxItems = @"{maxItems}";
NSString * const kAlfrescoSkipCount = @"{skipCount}";
NSString * const kAlfrescoSearchFilter = @"{filter}";
NSString * const kAlfrescoReverseComments = @"reverse";

/**
 Session data key constants
 */
NSString * const kAlfrescoSessionKeyCmisSession = @"alfresco_session_key_cmis_session";
NSString * const kAlfrescoSessionCloudURL = @"org.alfresco.mobile.internal.session.cloud.url";
NSString * const kAlfrescoSessionCloudBasicAuth = @"org.alfresco.mobile.internal.session.cloud.basic";
NSString * const kAlfrescoSessionUsername = @"org.alfresco.mobile.internal.session.username";
NSString * const kAlfrescoSessionPassword = @"org.alfresco.mobile.internal.session.password";
NSString * const kAlfrescoSessionCacheSites = @"org.alfresco.mobile.internal.cache.sites";
NSString * const kAlfrescoSessionCacheFavorites = @"org.alfresco.mobile.internal.cache.favorites";
// Temporary for ACE-1445
NSString * const kAlfrescoSessionAlternatePersonIdentifier = @"org.alfresco.mobile.internal.session.personIdentifier";

NSString * const kAlfrescoSiteIsFavorite = @"isFavorite";
NSString * const kAlfrescoSiteIsMember = @"isMember";
NSString * const kAlfrescoSiteIsPendingMember = @"isPendingMember";

/**
 Associated object key constants
 */
NSString * const kAlfrescoAuthenticationProviderObjectKey = @"AuthenticationProviderObjectKey";

/**
 OAuth Constants
 */
NSString *const kAlfrescoJSONAccessToken = @"access_token";
NSString *const kAlfrescoJSONRefreshToken = @"refresh_token";
NSString *const kAlfrescoJSONTokenType = @"token_type";
NSString *const kAlfrescoJSONExpiresIn = @"expires_in";
NSString *const kAlfrescoJSONScope = @"scope";
NSString *const kAlfrescoJSONError = @"error";
NSString *const kAlfrescoJSONErrorDescription = @"error_description";
NSString *const kAlfrescoOAuthClientID = @"client_id={clientID}";
NSString *const kAlfrescoOAuthClientSecret = @"client_secret={clientSecret}";
NSString *const kAlfrescoOAuthGrantType = @"grant_type=authorization_code";
NSString *const kAlfrescoOAuthRedirectURI = @"redirect_uri={redirectURI}";
NSString *const kAlfrescoOAuthCode = @"code={code}";
NSString *const kAlfrescoOAuthAuthorize = @"/auth/oauth/versions/2/authorize";
NSString *const kAlfrescoOAuthToken = @"/auth/oauth/versions/2/token";
NSString *const kAlfrescoOAuthScope = @"scope=pub_api";
NSString *const kAlfrescoOAuthResponseType = @"response_type=code";
NSString *const kAlfrescoOAuthGrantTypeRefresh = @"grant_type=refresh_token";
NSString *const kAlfrescoOAuthRefreshToken = @"refresh_token={refreshID}";


/**
 On Premise constants      
 */
NSString * const kAlfrescoLegacyAPIPath = @"/service/api/";
NSString * const kAlfrescoLegacyCMISPath = @"/service/cmis";
NSString * const kAlfrescoLegacyCMISAtomPath = @"/cmisatom";
NSString * const kAlfrescoLegacyAPINodeRefPrefix = @"workspace://SpacesStore/";
NSString * const kAlfrescoLegacyActivityAPI = @"activities/feed/user?format=json";
NSString * const kAlfrescoLegacyActivityForSiteAPI = @"activities/feed/site/{siteID}?format=json";
NSString * const kAlfrescoLegacyRatingsAPI = @"node/{nodeRef}/ratings";
NSString * const kAlfrescoLegacyRatingsLikingSchemeAPI = @"node/{nodeRef}/ratings/likesRatingScheme";
NSString * const kAlfrescoLegacyRatingsCount = @"data.nodeStatistics.likesRatingScheme.ratingsCount";
NSString * const kAlfrescoLegacyLikesSchemeRatings = @"data.ratings.likesRatingScheme.rating";
NSString * const kAlfrescoLegacySiteAPI = @"sites?format=json";
NSString * const kAlfrescoLegacySiteForPersonAPI = @"people/{personID}/sites";
NSString * const kAlfrescoLegacyFavoriteSiteForPersonAPI = @"people/{personID}/preferences?pf=org.alfresco.share.sites";
NSString * const kAlfrescoLegacySitesShortnameAPI = @"sites/{siteID}";
NSString * const kAlfrescoLegacySiteDoclibAPI = @"service/slingshot/doclib/containers/{siteID}";
NSString * const kAlfrescoLegacyFavoriteSites = @"org.alfresco.share.sites.favourites";
NSString * const kAlfrescoLegacyCommentsAPI = @"node/{nodeRef}/comments";
NSString * const kAlfrescoLegacyCommentForNodeAPI = @"comment/node/{commentID}";
NSString * const kAlfrescoLegacyTagsAPI = @"tags/workspace/SpacesStore";
NSString * const kAlfrescoLegacyTagsForNodeAPI = @"node/{nodeRef}/tags";
NSString * const kAlfrescoLegacyPersonAPI = @"people/{personID}";
NSString * const kAlfrescoLegacyPersonSearchAPI = @"people?filter={filter}";
NSString * const kAlfrescoLegacyAvatarForPersonAPI = @"/service/slingshot/profile/avatar/{personID}";
NSString * const kAlfrescoLegacyMetadataExtractionAPI = @"/service/api/actionQueue";
NSString * const kAlfrescoLegacyThumbnailCreationAPI = @"/node/{nodeRef}/content/thumbnails?as=true";
NSString * const kAlfrescoLegacyThumbnailRenditionAPI = @"node/{nodeRef}/content/thumbnails/{renditionID}?c=queue";
NSString * const kAlfrescoLegacyServerAPI = @"server";

NSString * const kAlfrescoLegacyPreferencesAPI = @"people/{personID}/preferences";
NSString * const kAlfrescoLegacyJoinPublicSiteAPI = @"sites/{siteID}/memberships";
NSString * const kAlfrescoLegacyJoinModeratedSiteAPI = @"sites/{siteID}/invitations";
NSString * const kAlfrescoLegacyPendingJoinRequestsAPI = @"invitations?inviteeUserName={personID}";
NSString * const kAlfrescoLegacyCancelJoinRequestsAPI = @"sites/{siteID}/invitations/{inviteID}";
NSString * const kAlfrescoLegacyLeaveSiteAPI = @"sites/{siteID}/memberships/{personID}";
NSString * const kAlfrescoLegacySiteMembershipFilter = @"?nf={filter}&authorityType=USER";

NSString * const kAlfrescoLegacyFavoriteDocuments = @"org.alfresco.share.documents.favourites";
NSString * const kAlfrescoLegacyFavoriteFolders = @"org.alfresco.share.folders.favourites";
NSString * const kAlfrescoLegacyFavoriteDocumentsAPI = @"/people/{personID}/preferences?pf=org.alfresco.share.documents.favourites";
NSString * const kAlfrescoLegacyFavoriteFoldersAPI = @"/people/{personID}/preferences?pf=org.alfresco.share.folders.favourites";
/**
 Public API constants
 */
NSString * const kAlfrescoPublicAPICMISAtomPath = @"/api/-default-/public/cmis/versions/1.0/atom";
NSString * const kAlfrescoPublicAPICMISBrowserPath = @"/api/-default-/public/cmis/versions/1.1/browser";
NSString * const kAlfrescoPublicAPIPath  = @"/api/-default-/public/alfresco/versions/1/";
NSString * const kAlfrescoPublicAPISite = @"sites";
NSString * const kAlfrescoPublicAPISiteForPerson = @"people/{personID}/sites";
NSString * const kAlfrescoPublicAPIFavoriteSiteForPerson = @"people/{personID}/favorite-sites";
NSString * const kAlfrescoPublicAPISiteForShortname = @"sites/{siteID}";
NSString * const kAlfrescoPublicAPISiteContainers = @"sites/{siteID}/containers";
NSString * const kAlfrescoPublicAPIActivities = @"people/{personID}/activities";
NSString * const kAlfrescoPublicAPIActivitiesForSite = @"people/{personID}/activities?siteId={siteID}";
NSString * const kAlfrescoPublicAPIRatings = @"nodes/{nodeRef}/ratings";
NSString * const kAlfrescoPublicAPILikesRatingScheme = @"node/{nodeRef}/ratings/likesRatingScheme";
NSString * const kAlfrescoPublicAPIComments = @"nodes/{nodeRef}/comments";
NSString * const kAlfrescoPublicAPICommentForNode = @"nodes/{nodeRef}/comments/{commentID}";
NSString * const kAlfrescoPublicAPITags = @"tags";
NSString * const kAlfrescoPublicAPITagsForNode = @"nodes/{nodeRef}/tags";
NSString * const kAlfrescoPublicAPIPerson = @"people/{personID}";
NSString * const kAlfrescoPublicAPIPersonSearch = @"people?filter={filter}";

NSString * const kAlfrescoPublicAPIAddFavoriteSite = @"people/-me-/favorites";
NSString * const kAlfrescoPublicAPIRemoveFavoriteSite = @"people/-me-/favorites/{siteGUID}";
NSString * const kAlfrescoPublicAPIJoinSite = @"people/-me-/site-membership-requests";
NSString * const kAlfrescoPublicAPICancelJoinRequests = @"people/-me-/site-membership-requests/{siteID}";
NSString * const kAlfrescoPublicAPILeaveSite = @"sites/{siteID}/members/{personID}";
NSString * const kAlfrescoPublicAPIPagingParameters = @"maxItems={maxItems}&skipCount={skipCount}";
NSString * const kAlfrescoPublicAPISiteMembers = @"sites/{siteID}/members";

NSString * const kAlfrescoPublicAPIFavoriteDocuments = @"people/{personID}/favorites?where=(EXISTS(target/file))";
NSString * const kAlfrescoPublicAPIFavoriteFolders = @"people/{personID}/favorites?where=(EXISTS(target/folder))";
NSString * const kAlfrescoPublicAPIFavoritesAll = @"people/{personID}/favorites?where=(EXISTS(target/file) OR EXISTS(target/folder))";
NSString * const kAlfrescoPublicAPIFavorite = @"people/{personID}/favorites/{nodeRef}";
NSString * const kAlfrescoPublicAPIAddFavorite = @"people/-me-/favorites";

NSString * const kAlfrescoDocumentLibrary = @"documentLibrary";

/**
 Cloud constants     
 */
NSString * const kAlfrescoCloudURL = @"https://api.alfresco.com";
NSString * const kAlfrescoCloudDefaultRedirectURI = @"http://www.alfresco.com/mobile-auth-callback.html";
NSString * const kAlfrescoCloudCMISPath = @"/public/cmis/versions/1.0/atom";
NSString * const kAlfrescoCloudAPIPath  = @"/public/alfresco/versions/1/";
NSString * const kAlfrescoCloudAPIRateLimitExceeded = @"API plan limit exceeded";
NSString * const kAlfrescoHomeNetworkType = @"homeNetwork";

/**
 JSON Constants
 */
NSString * const kAlfrescoPublicAPIJSONList = @"list";
NSString * const kAlfrescoPublicAPIJSONPagination = @"pagination";
NSString * const kAlfrescoPublicAPIJSONCount = @"count";
NSString * const kAlfrescoPublicAPIJSONHasMoreItems = @"hasMoreItems";
NSString * const kAlfrescoPublicAPIJSONTotalItems = @"totalItems";
NSString * const kAlfrescoPublicAPIJSONSkipCount = @"skipCount";
NSString * const kAlfrescoPublicAPIJSONMaxItems = @"maxItems";
NSString * const kAlfrescoPublicAPIJSONEntries = @"entries";
NSString * const kAlfrescoPublicAPIJSONEntry = @"entry";
NSString * const kAlfrescoJSONIdentifier = @"id";
NSString * const kAlfrescoJSONStatusCode = @"status.code";
NSString * const kAlfrescoJSONActivityPostDate = @"postDate";
NSString * const kAlfrescoJSONActivityPostUserID = @"postUserId";
NSString * const kAlfrescoJSONActivityPostPersonID = @"postPersonId";
NSString * const kAlfrescoJSONActivitySiteNetwork = @"siteNetwork";
NSString * const kAlfrescoJSONActivityType = @"activityType";
NSString * const kAlfrescoJSONActivitySummary = @"activitySummary";
NSString * const kAlfrescoJSONActivityDataNodeRef = @"nodeRef";
NSString * const kAlfrescoJSONActivityDataObjectId = @"objectId";
NSString * const kAlfrescoJSONActivityDataPage = @"page";
NSString * const kAlfrescoJSONRating = @"rating";
NSString * const kAlfrescoJSONRatingScheme = @"ratingScheme";
NSString * const kAlfrescoJSONLikesRatingScheme = @"likesRatingScheme";
NSString * const kAlfrescoJSONDescription = @"description";
NSString * const kAlfrescoJSONTitle = @"title";
NSString * const kAlfrescoJSONShortname = @"shortName";
NSString * const kAlfrescoJSONVisibility = @"visibility";
NSString * const kAlfrescoJSONVisibilityPUBLIC = @"PUBLIC";
NSString * const kAlfrescoJSONVisibilityPRIVATE = @"PRIVATE";
NSString * const kAlfrescoJSONVisibilityMODERATED = @"MODERATED";
NSString * const kAlfrescoJSONContainers = @"containers";
NSString * const kAlfrescoJSONNodeRef = @"nodeRef";
NSString * const kAlfrescoJSONSiteID = @"siteId";
NSString * const kAlfrescoJSONLikes = @"likes";
NSString * const kAlfrescoJSONMyRating = @"myRating";
NSString * const kAlfrescoJSONAggregate = @"aggregate";
NSString * const kAlfrescoJSONNumberOfRatings = @"numberOfRatings";
NSString * const kAlfrescoJSONHomeNetwork = @"homeNetwork";
NSString * const kAlfrescoJSONIsEnabled = @"isEnabled";
NSString * const kAlfrescoJSONNetwork = @"network";
NSString * const kAlfrescoJSONPaidNetwork = @"paidNetwork";
NSString * const kAlfrescoJSONCreationTime = @"creationDate";
NSString * const kAlfrescoJSONSubscriptionLevel = @"subscriptionLevel";
NSString * const kAlfrescoJSONName = @"name";
NSString * const kAlfrescoJSONItems = @"items";
NSString * const kAlfrescoJSONItem = @"item";
NSString * const kAlfrescoJSONAuthorUserName = @"author.username";
NSString * const kAlfrescoJSONAuthor = @"author";
NSString * const kAlfrescoJSONUsername = @"username";
NSString * const kAlfrescoJSONCreatedOn = @"createdOn";
NSString * const kAlfrescoJSONCreatedOnISO = @"createdOnISO";
NSString * const kAlfrescoJSONModifiedOn = @"modifiedOn";
NSString * const kAlfrescoJSONModifiedOnISO = @"modifiedOnISO";
NSString * const kAlfrescoJSONContent = @"content";
NSString * const kAlfrescoJSONIsUpdated = @"isUpdated";
NSString * const kAlfrescoJSONPermissionsEdit = @"permissions.edit";
NSString * const kAlfrescoJSONPermissionsDelete = @"permissions.delete";
NSString * const kAlfrescoJSONPermissions = @"permissions";
NSString * const kAlfrescoJSONEdit = @"edit";
NSString * const kAlfrescoJSONDelete = @"delete";
NSString * const kAlfrescoJSONCreatedAt = @"createdAt";
NSString * const kAlfrescoJSONCreatedBy = @"createdBy";
NSString * const kAlfrescoJSONCreator = @"creator";
NSString * const kAlfrescoJSONAvatar = @"avatar";
NSString * const kAlfrescoJSONModifiedAt = @"modifiedAt";
NSString * const kAlfrescoJSONEdited = @"edited";
NSString * const kAlfrescoJSONCanEdit = @"canEdit";
NSString * const kAlfrescoJSONCanDelete = @"canDelete";
NSString * const kAlfrescoJSONEnabled = @"enabled";
NSString * const kAlfrescoJSONTag = @"tag";
NSString * const kAlfrescoJSONUserName = @"userName";
NSString * const kAlfrescoJSONFirstName = @"firstName";
NSString * const kAlfrescoJSONLastName = @"lastName";
NSString * const kAlfrescoJSONFullName = @"fullName";
NSString * const kAlfrescoJSONActionedUponNode = @"actionedUponNode";
NSString * const kAlfrescoJSONExtractMetadata = @"extract-metadata";
NSString * const kAlfrescoJSONActionDefinitionName = @"actionDefinitionName";
NSString * const kAlfrescoJSONThumbnailName = @"thumbnailName";
NSString * const kAlfrescoJSONSite = @"site";
NSString * const kAlfrescoJSONPostedAt = @"postedAt";
NSString * const kAlfrescoJSONAvatarId = @"avatarId";
NSString * const kAlfrescoJSONAuthority = @"authority";

NSString * const kAlfrescoJSONJobTitle = @"jobtitle";
NSString * const kAlfrescoPublicAPIJSONJobTitle = @"jobTitle";
NSString * const kAlfrescoJSONLocation = @"location";
NSString * const kAlfrescoJSONPersonDescription = @"persondescription";
NSString * const kAlfrescoJSONTelephoneNumber = @"telephone";
NSString * const kAlfrescoJSONMobileNumber = @"mobile";
NSString * const kAlfrescoJSONSkype = @"skype";
NSString * const kAlfrescoJSONGoogle = @"googleusername";
NSString * const kAlfrescoJSONInstantMessage = @"instantmsg";
NSString * const kAlfrescoJSONSkypeId = @"skypeId";
NSString * const kAlfrescoJSONGoogleId = @"googleId";
NSString * const kAlfrescoJSONInstantMessageId = @"instantMessageId";
NSString * const kAlfrescoJSONStatus = @"userStatus";
NSString * const kAlfrescoJSONStatusTime = @"userStatusTime";
NSString * const kAlfrescoJSONEmail = @"email";
NSString * const kAlfrescoJSONCompany = @"company";

NSString * const kAlfrescoJSONCompanyAddressLine1 = @"companyaddress1";
NSString * const kAlfrescoJSONCompanyAddressLine2 = @"companyaddress2";
NSString * const kAlfrescoJSONCompanyAddressLine3 = @"companyaddress3";
NSString * const kAlfrescoJSONCompanyFullAddress = @"fullAddress";
NSString * const kAlfrescoJSONCompanyPostcode = @"companypostcode";
NSString * const kAlfrescoJSONCompanyFaxNumber = @"companyfax";
NSString * const kAlfrescoJSONCompanyName = @"organization";
NSString * const kAlfrescoJSONCompanyTelephone = @"companytelephone";
NSString * const kAlfrescoJSONCompanyEmail = @"companyemail";
NSString * const kAlfrescoJSONAddressLine1 = @"address1";
NSString * const kAlfrescoJSONAddressLine2 = @"address2";
NSString * const kAlfrescoJSONAddressLine3 = @"address3";
NSString * const kAlfrescoJSONPostcode = @"postcode";
NSString * const kAlfrescoJSONFaxNumber = @"fax";

NSString * const kAlfrescoJSONOrg = @"org";
NSString * const kAlfrescoJSONAlfresco = @"alfresco";
NSString * const kAlfrescoJSONShare = @"share";
NSString * const kAlfrescoJSONSites = @"sites";
NSString * const kAlfrescoJSONFavorites = @"favourites";
NSString * const kAlfrescoJSONGUID = @"guid";
NSString * const kAlfrescoJSONTarget = @"target";
NSString * const kAlfrescoJSONPerson = @"person";
NSString * const kAlfrescoJSONPeople = @"people";
NSString * const kAlfrescoJSONRole = @"role";
NSString * const kAlfrescoJSONInvitationType = @"invitationType";
NSString * const kAlfrescoJSONInviteeUsername = @"inviteeUserName";
NSString * const kAlfrescoJSONInviteeComments = @"inviteeComments";
NSString * const kAlfrescoJSONInviteeRolename = @"inviteeRoleName";
NSString * const kAlfrescoJSONInviteId = @"inviteId";
NSString * const kAlfrescoJSONData = @"data";
NSString * const kAlfrescoJSONResourceName = @"resourceName";
NSString * const kAlfrescoJSONMessage = @"message";
NSString * const kAlfrescoJSONFile = @"file";
NSString * const kAlfrescoJSONFolder = @"folder";

NSString * const kAlfrescoLegacyJSONMaxItems = @"pageSize";
NSString * const kAlfrescoLegacyJSONSkipCount = @"startIndex";
NSString * const kAlfrescoLegacyJSONTotal = @"total";
NSString * const kAlfrescoLegacyJSONHasMoreItems = @"legacyHasMoreItems";

NSString * const kAlfrescoNodeAspects = @"cmis.aspects";
NSString * const kAlfrescoNodeProperties = @"cmis.properties";
NSString * const kAlfrescoPropertyType = @"type";
NSString * const kAlfrescoPropertyValue = @"value";
NSString * const kAlfrescoPropertyIsMultiValued = @"isMultiValued";

NSString * const kAlfrescoHTTPDelete = @"DELETE";
NSString * const kAlfrescoHTTPGet = @"GET";
NSString * const kAlfrescoHTTPPost = @"POST";
NSString * const kAlfrescoHTTPPut = @"PUT";

NSString * const kAlfrescoFileManagerClass = @"AlfrescoFileManagerClassName";

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

NSString * const kAlfrescoJSONInfo = @"info";
NSString * const kAlfrescoJSONSchemaVersion = @"schema-version";
NSString * const kAlfrescoJSONConfigVersion = @"config-version";
NSString * const kAlfrescoJSONRepository = @"repository";
NSString * const kAlfrescoJSONShareURL = @"share-url";
NSString * const kAlfrescoJSONCMISURL = @"cmis-url";
NSString * const kAlfrescoJSONProfiles = @"profiles";
NSString * const kAlfrescoJSONDefault = @"default";
NSString * const kAlfrescoJSONLabelId = @"label-id";
NSString * const kAlfrescoJSONDescriptionId = @"description-id";
NSString * const kAlfrescoJSONRootViewId = @"root-view-id";
NSString * const kAlfrescoJSONFeatures = @"features";
NSString * const kAlfrescoJSONItemType = @"item-type";
NSString * const kAlfrescoJSONViewGroups = @"view-groups";
NSString * const kAlfrescoJSONViewGroupId = @"view-group-id";
NSString * const kAlfrescoJSONViewId = @"view-id";
NSString * const kAlfrescoJSONViews = @"views";
NSString * const kAlfrescoJSONType = @"type";
NSString * const kAlfrescoJSONCreation = @"creation";
NSString * const kAlfrescoJSONMimeTypes = @"mime-types";
NSString * const kAlfrescoJSONDocumentTypes = @"document-types";
NSString * const kAlfrescoJSONFolderTypes = @"folder-types";
NSString * const kAlfrescoJSONForms = @"forms";
NSString * const kAlfrescoJSONLayout = @"layout";
NSString * const kAlfrescoJSONFieldGroupId = @"field-group-id";
NSString * const kAlfrescoJSONFieldGroups = @"field-groups";
NSString * const kAlfrescoJSONFieldId = @"field-id";
NSString * const kAlfrescoJSONField = @"field";
NSString * const kAlfrescoJSONModelId = @"model-id";
