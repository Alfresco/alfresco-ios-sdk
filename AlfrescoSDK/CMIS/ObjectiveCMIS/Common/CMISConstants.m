/*
  Licensed to the Apache Software Foundation (ASF) under one
  or more contributor license agreements.  See the NOTICE file
  distributed with this work for additional information
  regarding copyright ownership.  The ASF licenses this file
  to you under the Apache License, Version 2.0 (the
  "License"); you may not use this file except in compliance
  with the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an
  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  KIND, either express or implied.  See the License for the
  specific language governing permissions and limitations
  under the License.
 */

#import "CMISConstants.h"

static NSSet *_repositoryCapabilityKeys;
static NSSet *_repositoryCapabilityNewTypeSettableAttributesKeys;
static NSSet *_repositoryCapabilityCreateablePropertyTypesKeys;

@implementation CMISConstants

// Library version constant - defined in ObjectiveCMIS.xcconfig
#if !defined(OBJECTIVECMIS_VERSION)
#warning Missing ObjectiveCMIS.xcconfig entries. Ensure the project configuration settings are correct.
#define OBJECTIVECMIS_VERSION @"Unknown"
#endif
NSString * const kCMISLibraryVersion = OBJECTIVECMIS_VERSION;

// Properties

NSString * const kCMISPropertyObjectId = @"cmis:objectId";
NSString * const kCMISPropertyName = @"cmis:name";
NSString * const kCMISPropertyPath = @"cmis:path";
NSString * const kCMISPropertyCreatedBy = @"cmis:createdBy";
NSString * const kCMISPropertyCreationDate = @"cmis:creationDate";
NSString * const kCMISPropertyModifiedBy = @"cmis:lastModifiedBy";
NSString * const kCMISPropertyModificationDate = @"cmis:lastModificationDate";
NSString * const kCMISPropertyContentStreamId = @"cmis:contentStreamId";
NSString * const kCMISPropertyContentStreamFileName = @"cmis:contentStreamFileName";
NSString * const kCMISPropertyContentStreamLength = @"cmis:contentStreamLength";
NSString * const kCMISPropertyContentStreamMediaType = @"cmis:contentStreamMimeType";
NSString * const kCMISPropertyContentStreamHash = @"cmis:contentStreamHash";
NSString * const kCMISPropertyObjectTypeId = @"cmis:objectTypeId";
NSString * const kCMISPropertyVersionSeriesId = @"cmis:versionSeriesId";
NSString * const kCMISPropertyVersionSeriesCheckedOutBy = @"cmis:versionSeriesCheckedOutBy";
NSString * const kCMISPropertyVersionSeriesCheckedOutId= @"cmis:versionSeriesCheckedOutId";
NSString * const kCMISPropertyVersionLabel = @"cmis:versionLabel";
NSString * const kCMISPropertyIsLatestVersion = @"cmis:isLatestVersion";
NSString * const kCMISPropertyIsMajorVersion = @"cmis:isMajorVersion";
NSString * const kCMISPropertyIsLatestMajorVersion = @"cmis:isLatestMajorVersion";
NSString * const kCMISPropertyChangeToken = @"cmis:changeToken";
NSString * const kCMISPropertyBaseTypeId = @"cmis:baseTypeId";
NSString * const kCMISPropertyCheckinComment = @"cmis:checkinComment";
NSString * const kCMISPropertySecondaryObjectTypeIds = @"cmis:secondaryObjectTypeIds";
NSString * const kCMISPropertyDescription = @"cmis:description";

// Property values

NSString * const kCMISPropertyObjectTypeIdValueDocument = @"cmis:document";
NSString * const kCMISPropertyObjectTypeIdValueFolder = @"cmis:folder";
NSString * const kCMISPropertyObjectTypeIdValueRelationship = @"cmis:relationship";
NSString * const kCMISPropertyObjectTypeIdValuePolicy = @"cmis:policy";
NSString * const kCMISPropertyObjectTypeIdValueItem = @"cmis:item";
NSString * const kCMISPropertyObjectTypeIdValueSecondary = @"cmis:secondary";

// Session cache keys

NSString * const kCMISSessionKeyWorkspaces = @"cmis_session_key_workspaces";

// Repository capability keys
NSString * const kCMISRepositoryCapabilityACL = @"capabilityACL";
NSString * const kCMISRepositoryAllVersionsSearchable = @"capabilityAllVersionsSearchable";
NSString * const kCMISRepositoryCapabilityChanges = @"capabilityChanges";
NSString * const kCMISRepositoryCapabilityContentStreamUpdatability = @"capabilityContentStreamUpdatability";
NSString * const kCMISRepositoryCapabilityJoin = @"capabilityJoin";
NSString * const kCMISRepositoryCapabilityQuery = @"capabilityQuery";
NSString * const kCMISRepositoryCapabilityRenditions = @"capabilityRenditions";
NSString * const kCMISRepositoryCapabilityPWCSearchable = @"capabilityPWCSearchable";
NSString * const kCMISRepositoryCapabilityPWCUpdatable = @"capabilityPWCUpdatable";
NSString * const kCMISRepositoryCapabilityGetDescendants = @"capabilityGetDescendants";
NSString * const kCMISRepositoryCapabilityGetFolderTree = @"capabilityGetFolderTree";
NSString * const kCMISRepositoryCapabilityOrderBy = @"capabilityOrderBy";
NSString * const kCMISRepositoryCapabilityMultifiling = @"capabilityMultifiling";
NSString * const kCMISRepositoryCapabilityUnfiling = @"capabilityUnfiling";
NSString * const kCMISRepositoryCapabilityVersionSpecificFiling = @"capabilityVersionSpecificFiling";
NSString * const kCMISRepositoryCapabilityPropertyTypes = @"capabilityCreatablePropertyTypes";
NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributes = @"capabilityNewTypeSettableAttributes";

// Repository capability new type settable attributes keys
NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributesId = @"id";
NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributesLocalName = @"localName";
NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributesLocalNamespace = @"localNamespace";
NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributesDisplayName = @"displayName";
NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributesQueryName = @"queryName";
NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributesDescription = @"description";
NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributesCreateable = @"creatable";
NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributesFileable = @"fileable";
NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributesQueryable = @"queryable";
NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributesFullTextIndexed = @"fulltextIndexed";
NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributesIncludedInSuperTypeQuery = @"includedInSupertypeQuery";
NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributesControllablePolicy = @"controllablePolicy";
NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributesControllableAcl = @"controllableACL";

// Repository capability createable property types key
NSString * const kCMISRepositoryCapabilityCreateablePropertyTypesCanCreate = @"canCreate";

// Parameters
NSString * const kCMISParameterChangeToken = @"changeToken";
NSString * const kCMISParameterOverwriteFlag = @"overwriteFlag";
NSString * const kCMISParameterIncludeAllowableActions = @"includeAllowableActions";
NSString * const kCMISParameterFilter = @"filter";
NSString * const kCMISParameterMaxItems = @"maxItems";
NSString * const kCMISParameterObjectId = @"objectId";
NSString * const kCMISParameterFolderId = @"folderId";
NSString * const kCMISParameterOrderBy = @"orderBy";
NSString * const kCMISParameterIncludePathSegment = @"includePathSegment";
NSString * const kCMISParameterIncludeRelationships = @"includeRelationships";
NSString * const kCMISParameterIncludePolicyIds = @"includePolicyIds";
NSString * const kCMISParameterIncludeAcl = @"includeACL";
NSString * const kCMISParameterRenditionFilter = @"renditionFilter";
NSString * const kCMISParameterSkipCount = @"skipCount";
NSString * const kCMISParameterStreamId = @"streamId";
NSString * const kCMISParameterAllVersions = @"allVersions";
NSString * const kCMISParameterContinueOnFailure= @"continueOnFailure";
NSString * const kCMISParameterUnfileObjects = @"unfileObjects";
NSString * const kCMISParameterVersioningState = @"versioningState";
NSString * const kCMISParameterRelativePathSegment = @"includeRelativePathSegment";
NSString * const kCMISParameterMajor = @"major";
NSString * const kCMISParameterCheckin = @"checkin";
NSString * const kCMISParameterCheckinComment = @"checkinComment";
NSString * const kCMISParameterSourceFolderId = @"sourceFolderId";
NSString * const kCMISParameterTargetFolderId = @"targetFolderId";
NSString * const kCMISParameterReturnVersion = @"returnVersion";
NSString * const kCMISParameterTypeId = @"typeId";
NSString * const kCMISParameterStatement = @"statement";
NSString * const kCMISParameterSearchAllVersions = @"searchAllVersions";

// Parameter Values
NSString * const kCMISParameterValueTrue = @"true";
NSString * const kCMISParameterValueFalse = @"false";
NSString * const kCMISParameterValueReturnValueThis = @"this";
NSString * const kCMISParameterValueReturnValueLatest = @"latest";
NSString * const kCMISParameterValueReturnValueLatestMajor = @"latestmajor";

// Common Media Types
NSString * const kCMISMediaTypeOctetStream = @"application/octet-stream";

// ContentStreamAllowed enum values
NSString * const kCMISContentStreamAllowedValueRequired = @"required";
NSString * const kCMISContentStreamAllowedValueAllowed = @"allowed";
NSString * const kCMISContentStreamAllowedValueNotAllowed = @"notallowed";

// Background network default values
NSString * const kCMISDefaultBackgroundNetworkSessionId = @"ObjectiveCMIS";
NSString * const kCMISDefaultBackgroundNetworkSessionSharedContainerId = @"ObjectiveCMISContainer";

+ (NSSet *)repositoryCapabilityKeys
{
    if(!_repositoryCapabilityKeys) {
        _repositoryCapabilityKeys = [NSSet setWithObjects:
                                     kCMISRepositoryCapabilityContentStreamUpdatability,
                                     kCMISRepositoryCapabilityChanges,
                                     kCMISRepositoryCapabilityRenditions,
                                     kCMISRepositoryCapabilityGetDescendants,
                                     kCMISRepositoryCapabilityGetFolderTree,
                                     kCMISRepositoryCapabilityMultifiling,
                                     kCMISRepositoryCapabilityUnfiling,
                                     kCMISRepositoryCapabilityVersionSpecificFiling,
                                     kCMISRepositoryCapabilityPWCSearchable,
                                     kCMISRepositoryCapabilityPWCUpdatable,
                                     kCMISRepositoryAllVersionsSearchable,
                                     kCMISRepositoryCapabilityOrderBy,
                                     kCMISRepositoryCapabilityQuery,
                                     kCMISRepositoryCapabilityJoin,
                                     kCMISRepositoryCapabilityACL,
                                     kCMISRepositoryCapabilityPropertyTypes,
                                     kCMISRepositoryCapabilityNewTypeSettableAttributes,
                                     nil];
    }
    return _repositoryCapabilityKeys;
}

+ (NSSet *)repositoryCapabilityNewTypeSettableAttributesKeys
{
    if(!_repositoryCapabilityNewTypeSettableAttributesKeys) {
        _repositoryCapabilityNewTypeSettableAttributesKeys = [NSSet setWithObjects:
                                                              kCMISRepositoryCapabilityNewTypeSettableAttributesId,
                                                              kCMISRepositoryCapabilityNewTypeSettableAttributesLocalName,
                                                              kCMISRepositoryCapabilityNewTypeSettableAttributesLocalNamespace,
                                                              kCMISRepositoryCapabilityNewTypeSettableAttributesDisplayName,
                                                              kCMISRepositoryCapabilityNewTypeSettableAttributesQueryName,
                                                              kCMISRepositoryCapabilityNewTypeSettableAttributesDescription,
                                                              kCMISRepositoryCapabilityNewTypeSettableAttributesCreateable,
                                                              kCMISRepositoryCapabilityNewTypeSettableAttributesFileable,
                                                              kCMISRepositoryCapabilityNewTypeSettableAttributesQueryable,
                                                              kCMISRepositoryCapabilityNewTypeSettableAttributesFullTextIndexed,
                                                              kCMISRepositoryCapabilityNewTypeSettableAttributesIncludedInSuperTypeQuery,
                                                              kCMISRepositoryCapabilityNewTypeSettableAttributesControllablePolicy,
                                                              kCMISRepositoryCapabilityNewTypeSettableAttributesControllableAcl,
                                                              nil];
    }
    return _repositoryCapabilityNewTypeSettableAttributesKeys;
}

+ (NSSet *)repositoryCapabilityCreateablePropertyTypesKeys
{
    if(!_repositoryCapabilityCreateablePropertyTypesKeys) {
        _repositoryCapabilityCreateablePropertyTypesKeys = [NSSet setWithObjects:
                                                              kCMISRepositoryCapabilityCreateablePropertyTypesCanCreate,
                                                              nil];
    }
    return _repositoryCapabilityCreateablePropertyTypesKeys;
}

@end
