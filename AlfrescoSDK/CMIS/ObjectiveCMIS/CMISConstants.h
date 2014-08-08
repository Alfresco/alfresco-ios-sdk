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

#import <Foundation/Foundation.h>

@interface CMISConstants : NSObject

// Version
extern NSString * const kCMISLibraryVersion;

// Properties
extern NSString * const kCMISPropertyObjectId;
extern NSString * const kCMISPropertyName;
extern NSString * const kCMISPropertyPath;
extern NSString * const kCMISPropertyCreatedBy;
extern NSString * const kCMISPropertyCreationDate;
extern NSString * const kCMISPropertyModifiedBy;
extern NSString * const kCMISPropertyModificationDate;
extern NSString * const kCMISPropertyContentStreamId;
extern NSString * const kCMISPropertyContentStreamFileName;
extern NSString * const kCMISPropertyContentStreamLength;
extern NSString * const kCMISPropertyContentStreamMediaType;
extern NSString * const kCMISPropertyObjectTypeId;
extern NSString * const kCMISPropertyVersionSeriesId;
extern NSString * const kCMISPropertyVersionLabel;
extern NSString * const kCMISPropertyIsLatestVersion;
extern NSString * const kCMISPropertyIsMajorVersion;
extern NSString * const kCMISPropertyIsLatestMajorVersion;
extern NSString * const kCMISPropertyChangeToken;
extern NSString * const kCMISPropertyBaseTypeId;
extern NSString * const kCMISPropertyCheckinComment;
extern NSString * const kCMISPropertySecondaryObjectTypeIds;
extern NSString * const kCMISPropertyDescription;

// Property values
extern NSString * const kCMISPropertyObjectTypeIdValueDocument;
extern NSString * const kCMISPropertyObjectTypeIdValueFolder;
extern NSString * const kCMISPropertyObjectTypeIdValueRelationship;
extern NSString * const kCMISPropertyObjectTypeIdValuePolicy;
extern NSString * const kCMISPropertyObjectTypeIdValueItem;
extern NSString * const kCMISPropertyObjectTypeIdValueSecondary;

// Session cache keys
extern NSString * const kCMISSessionKeyWorkspaces;

// Repository capability keys
extern NSString * const kCMISRepositoryCapabilityACL;
extern NSString * const kCMISRepositoryAllVersionsSearchable;
extern NSString * const kCMISRepositoryCapabilityChanges;
extern NSString * const kCMISRepositoryCapabilityContentStreamUpdatability;
extern NSString * const kCMISRepositoryCapabilityJoin;
extern NSString * const kCMISRepositoryCapabilityQuery;
extern NSString * const kCMISRepositoryCapabilityRenditions;
extern NSString * const kCMISRepositoryCapabilityPWCSearchable;
extern NSString * const kCMISRepositoryCapabilityPWCUpdatable;
extern NSString * const kCMISRepositoryCapabilityGetDescendants;
extern NSString * const kCMISRepositoryCapabilityGetFolderTree;
extern NSString * const kCMISRepositoryCapabilityOrderBy;
extern NSString * const kCMISRepositoryCapabilityMultifiling;
extern NSString * const kCMISRepositoryCapabilityUnfiling;
extern NSString * const kCMISRepositoryCapabilityVersionSpecificFiling;
extern NSString * const kCMISRepositoryCapabilityPropertyTypes;
extern NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributes;

// Repository capability new type settable attributes keys
extern NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributesId;
extern NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributesLocalName;
extern NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributesLocalNamespace;
extern NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributesDisplayName;
extern NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributesQueryName;
extern NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributesDescription;
extern NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributesCreateable;
extern NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributesFileable;
extern NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributesQueryable;
extern NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributesFullTextIndexed;
extern NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributesIncludedInSuperTypeQuery;
extern NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributesControllablePolicy;
extern NSString * const kCMISRepositoryCapabilityNewTypeSettableAttributesControllableAcl;

// Repository capability createable property types key
extern NSString * const kCMISRepositoryCapabilityCreateablePropertyTypesCanCreate;

// URL parameters
extern NSString * const kCMISParameterChangeToken;
extern NSString * const kCMISParameterOverwriteFlag;
extern NSString * const kCMISParameterIncludeAllowableActions;
extern NSString * const kCMISParameterFilter;
extern NSString * const kCMISParameterMaxItems;
extern NSString * const kCMISParameterObjectId;
extern NSString * const kCMISParameterOrderBy;
extern NSString * const kCMISParameterIncludePathSegment;
extern NSString * const kCMISParameterIncludeRelationships;
extern NSString * const kCMISParameterIncludePolicyIds;
extern NSString * const kCMISParameterIncludeAcl;
extern NSString * const kCMISParameterRenditionFilter;
extern NSString * const kCMISParameterSkipCount;
extern NSString * const kCMISParameterStreamId;
extern NSString * const kCMISParameterAllVersions;
extern NSString * const kCMISParameterContinueOnFailure;
extern NSString * const kCMISParameterUnfileObjects;
extern NSString * const kCMISParameterVersioningState;
extern NSString * const kCMISParameterRelativePathSegment;
extern NSString * const kCMISParameterMajor;
extern NSString * const kCMISParameterCheckin;
extern NSString * const kCMISParameterCheckinComment;
extern NSString * const kCMISParameterSourceFolderId;
extern NSString * const kCMISParameterTargetFolderId;
extern NSString * const kCMISParameterReturnVersion;
extern NSString * const kCMISParameterTypeId;
extern NSString * const kCMISParameterStatement;
extern NSString * const kCMISParameterSearchAllVersions;

// Parameter Values
extern NSString * const kCMISParameterValueTrue;
extern NSString * const kCMISParameterValueFalse;
extern NSString * const kCMISParameterValueReturnValueThis;
extern NSString * const kCMISParameterValueReturnValueLatest;
extern NSString * const kCMISParameterValueReturnValueLatestMajor;

// Common Media Types
extern NSString * const kCMISMediaTypeOctetStream;

//ContentStreamAllowed enum values
extern NSString * const kCMISContentStreamAllowedValueRequired;
extern NSString * const kCMISContentStreamAllowedValueAllowed;
extern NSString * const kCMISContentStreamAllowedValueNotAllowed;

+ (NSSet *)repositoryCapabilityKeys;
+ (NSSet *)repositoryCapabilityNewTypeSettableAttributesKeys;
+ (NSSet *)repositoryCapabilityCreateablePropertyTypesKeys;

@end
