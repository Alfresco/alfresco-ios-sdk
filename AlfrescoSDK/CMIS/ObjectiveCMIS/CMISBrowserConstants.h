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

@interface CMISBrowserConstants : NSObject

// Session keys
extern NSString * const kCMISBrowserBindingSessionKeyRepositoryUrl;
extern NSString * const kCMISBrowserBindingSessionKeyRootFolderUrl;

// JSON properties
extern NSString * const kCMISBrowserJSONRepositoryId;
extern NSString * const kCMISBrowserJSONRepositoryName;
extern NSString * const kCMISBrowserJSONRepositoryDescription;
extern NSString * const kCMISBrowserJSONVendorName;
extern NSString * const kCMISBrowserJSONProductName;
extern NSString * const kCMISBrowserJSONProductVersion;
extern NSString * const kCMISBrowserJSONRootFolderId;
extern NSString * const kCMISBrowserJSONCapabilities;
extern NSString * const kCMISBrowserJSONCMISVersionSupported;
extern NSString * const kCMISBrowserJSONPrincipalIdAnonymous;
extern NSString * const kCMISBrowserJSONPrincipalIdAnyone;
extern NSString * const kCMISBrowserJSONRepositoryUrl;
extern NSString * const kCMISBrowserJSONRootFolderUrl;
extern NSString * const kCMISBrowserJSONId;
extern NSString * const kCMISBrowserJSONLocalName;
extern NSString * const kCMISBrowserJSONLocalNamespace;
extern NSString * const kCMISBrowserJSONDisplayName;
extern NSString * const kCMISBrowserJSONQueryName;
extern NSString * const kCMISBrowserJSONDescription;
extern NSString * const kCMISBrowserJSONBaseId;
extern NSString * const kCMISBrowserJSONParentId;
extern NSString * const kCMISBrowserJSONCreateable;
extern NSString * const kCMISBrowserJSONFileable;
extern NSString * const kCMISBrowserJSONQueryable;
extern NSString * const kCMISBrowserJSONVersionable; // document
extern NSString * const kCMISBrowserJSONContentStreamAllowed; // document
extern NSString * const kCMISBrowserJSONAllowedSourceTypes; // relationship
extern NSString * const kCMISBrowserJSONAllowedTargetTypes; // relationship
extern NSString * const kCMISBrowserJSONFullTextIndexed;
extern NSString * const kCMISBrowserJSONIncludedInSuperTypeQuery;
extern NSString * const kCMISBrowserJSONControllablePolicy;
extern NSString * const kCMISBrowserJSONControllableAcl;
extern NSString * const kCMISBrowserJSONPropertyDefinitions;
extern NSString * const kCMISBrowserJSONTypeMutability;
extern NSString * const kCMISBrowserJSONValue;
extern NSString * const kCMISBrowserJSONPropertyType;
extern NSString * const kCMISBrowserJSONCardinality;
extern NSString * const kCMISBrowserJSONDatatype;
extern NSString * const kCMISBrowserJSONUpdateability;
extern NSString * const kCMISBrowserJSONInherited;
extern NSString * const kCMISBrowserJSONRequired;
extern NSString * const kCMISBrowserJSONOrderable;
extern NSString * const kCMISBrowserJSONOpenChoice;
extern NSString * const kCMISBrowserJSONChoice;
extern NSString * const kCMISBrowserJSONDefaultValue;
extern NSString * const kCMISBrowserJSONProperties;
extern NSString * const kCMISBrowserJSONSuccinctProperties;
extern NSString * const kCMISBrowserJSONPropertiesExtension;
extern NSString * const kCMISBrowserJSONAllowableActions;
extern NSString * const kCMISBrowserJSONRelationships;
extern NSString * const kCMISBrowserJSONChangeEventInfo;
extern NSString * const kCMISBrowserJSONAcl;
extern NSString * const kCMISBrowserJSONAces;
extern NSString * const kCMISBrowserJSONExactAcl;
extern NSString * const kCMISBrowserJSONIsExact;
extern NSString * const kCMISBrowserJSONPolicyIds;
extern NSString * const kCMISBrowserJSONPolicyIdsIds;
extern NSString * const kCMISBrowserJSONRenditions;
extern NSString * const kCMISBrowserJSONObjects;
extern NSString * const kCMISBrowserJSONResults;
extern NSString * const kCMISBrowserJSONObject;
extern NSString * const kCMISBrowserJSONHasMoreItems;
extern NSString * const kCMISBrowserJSONNumberItems;
extern NSString * const kCMISBrowserJSONThinClientUri;
extern NSString * const kCMISBrowserJSONChangesIncomplete;
extern NSString * const kCMISBrowserJSONChangesOnType;
extern NSString * const kCMISBrowserJSONLatestChangeLogToken;
extern NSString * const kCMISBrowserJSONAclCapabilities;
extern NSString * const kCMISBrowserJSONExtendedFeatures;
extern NSString * const kCMISBrowserJSONMaxLength;
extern NSString * const kCMISBrowserJSONMinValue;
extern NSString * const kCMISBrowserJSONMaxValue;
extern NSString * const kCMISBrowserJSONPrecision;
extern NSString * const kCMISBrowserJSONResolution;
extern NSString * const kCMISBrowserJSONFailedToDeleteId;
extern NSString * const kCMISBrowserJSONAcePrincipal;
extern NSString * const kCMISBrowserJSONAcePrincipalId;
extern NSString * const kCMISBrowserJSONAcePermissions;
extern NSString * const kCMISBrowserJSONAceIsDirect;

// JSON enum values
extern NSString * const kCMISBrowserJSONPropertyTypeValueString;
extern NSString * const kCMISBrowserJSONPropertyTypeValueId;
extern NSString * const kCMISBrowserJSONPropertyTypeValueInteger;
extern NSString * const kCMISBrowserJSONPropertyTypeValueDecimal;
extern NSString * const kCMISBrowserJSONPropertyTypeValueBoolean;
extern NSString * const kCMISBrowserJSONPropertyTypeValueDateTime;
extern NSString * const kCMISBrowserJSONPropertyTypeValueHtml;
extern NSString * const kCMISBrowserJSONPropertyTypeValueUri;
extern NSString * const kCMISBrowserJSONCardinalityValueSingle;
extern NSString * const kCMISBrowserJSONCardinalityValueMultiple;
extern NSString * const kCMISBrowserJSONUpdateabilityValueReadOnly;
extern NSString * const kCMISBrowserJSONUpdateabilityValueReadWrite;
extern NSString * const kCMISBrowserJSONUpdateabilityValueOnCreate;
extern NSString * const kCMISBrowserJSONUpdateabilityValueWhenCheckedOut;

//JSON selectors
extern NSString * const kCMISBrowserJSONSSelectorLastResult;
extern NSString * const kCMISBrowserJSONSelectorRepositoryInfo;
extern NSString * const kCMISBrowserJSONSelectorTypeChildren;
extern NSString * const kCMISBrowserJSONSelectorTypeDescendants;
extern NSString * const kCMISBrowserJSONSelectorTypeDefinition;
extern NSString * const kCMISBrowserJSONSelectorContent;
extern NSString * const kCMISBrowserJSONSelectorObject;
extern NSString * const kCMISBrowserJSONSelectorProperties;
extern NSString * const kCMISBrowserJSONSelectorAllowableActions;
extern NSString * const kCMISBrowserJSONSelectorRenditions;
extern NSString * const kCMISBrowserJSONSelectorChildren;
extern NSString * const kCMISBrowserJSONSelectorDescendants;
extern NSString * const kCMISBrowserJSONSelectorParents;
extern NSString * const kCMISBrowserJSONSelectorParent;
extern NSString * const kCMISBrowserJSONSelectorFolderTree;
extern NSString * const kCMISBrowserJSONSelectorQuery;
extern NSString * const kCMISBrowserJSONSelectorVersions;
extern NSString * const kCMISBrowserJSONSelectorRelationships;
extern NSString * const kCMISBrowserJSONSelectorCheckedout;
extern NSString * const kCMISBrowserJSONSelectorPolicies;
extern NSString * const kCMISBrowserJSONSelectorAcl;
extern NSString * const kCMISBrowserJSONSelectorContentChanges;

//JSON rendition properties
extern NSString * const kCMISBrowserJSONRenditionStreamId;
extern NSString * const kCMISBrowserJSONRenditionMimeType;
extern NSString * const kCMISBrowserJSONRenditionLength;
extern NSString * const kCMISBrowserJSONRenditionKind;
extern NSString * const kCMISBrowserJSONRenditionTitle;
extern NSString * const kCMISBrowserJSONRenditionHeight;
extern NSString * const kCMISBrowserJSONRenditionWidth;
extern NSString * const kCMISBrowserJSONRenditionDocumentId;

// JSON specific parameters
extern NSString * const kCMISBrowserJSONParameterSelector;
extern NSString * const kCMISBrowserJSONParameterSuccinct;

// Browser binding control
extern NSString * const kCMISBrowserJSONControlCmisAction;
extern NSString * const kCMISBrowserJSONControlPropertyId;
extern NSString * const kCMISBrowserJSONControlPropertyValue;

// Browser binding actions
extern NSString * const kCMISBrowserJSONActionCreateType;
extern NSString * const kCMISBrowserJSONActionUpdateType;
extern NSString * const kCMISBrowserJSONActionDeleteType;
extern NSString * const kCMISBrowserJSONActionCreateDocument;
extern NSString * const kCMISBrowserJSONActionCreateDocumentFromSource;
extern NSString * const kCMISBrowserJSONActionCreateFolder;
extern NSString * const kCMISBrowserJSONActionCreateRelationship;
extern NSString * const kCMISBrowserJSONActionCreatePolicy;
extern NSString * const kCMISBrowserJSONActionCreateItem;
extern NSString * const kCMISBrowserJSONActionUpdateProperties;
extern NSString * const kCMISBrowserJSONActionBulkUpdate;
extern NSString * const kCMISBrowserJSONActionDeleteContent;
extern NSString * const kCMISBrowserJSONActionSetContent;
extern NSString * const kCMISBrowserJSONActionAppendContent;
extern NSString * const kCMISBrowserJSONActionDelete;
extern NSString * const kCMISBrowserJSONActionDeleteTree;
extern NSString * const kCMISBrowserJSONActionMove;
extern NSString * const kCMISBrowserJSONActionAddObjectToFolder;
extern NSString * const kCMISBrowserJSONActionRemoveObjectFromFolder;
extern NSString * const kCMISBrowserJSONActionQuery;
extern NSString * const kCMISBrowserJSONActionCheckOut;
extern NSString * const kCMISBrowserJSONActionCancelCheckOut;
extern NSString * const kCMISBrowserJSONActionCheckIn;
extern NSString * const kCMISBrowserJSONActionApplyPolicy;
extern NSString * const kCMISBrowserJSONActionRemovePolicy;
extern NSString * const kCMISBrowserJSONActionApplyAcl;

+ (NSSet *)objectKeys;
+ (NSSet *)repositoryInfoKeys;
+ (NSSet *)typeKeys;
+ (NSSet *)propertyKeys;
+ (NSSet *)propertyTypeKeys;
+ (NSSet *)renditionKeys;
+ (NSSet *)objectListKeys;
+ (NSSet *)queryResultListKeys;
+ (NSSet *)aclKeys;
+ (NSSet *)aceKeys;
+ (NSSet *)principalKeys;

@end
