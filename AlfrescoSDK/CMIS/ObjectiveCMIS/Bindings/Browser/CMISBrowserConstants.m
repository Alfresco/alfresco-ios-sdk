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

#import "CMISBrowserConstants.h"

static NSSet *_objectKeys;
static NSSet *_repositoryInfoKeys;
static NSSet *_typeKeys;
static NSSet *_propertyKeys;
static NSSet *_propertyTypeKeys;
static NSSet *_renditionKeys;
static NSSet *_objectListKeys;
static NSSet *_queryResultListKeys;
static NSSet *_aclKeys;
static NSSet *_aceKeys;
static NSSet *_principalKeys;

@implementation CMISBrowserConstants

// Session keys
NSString * const kCMISBrowserBindingSessionKeyRepositoryUrl = @"cmis_session_key_browser_repo_url";
NSString * const kCMISBrowserBindingSessionKeyRootFolderUrl = @"cmis_session_key_browser_root_folder_url";

// JSON properties
NSString * const kCMISBrowserJSONRepositoryId = @"repositoryId";
NSString * const kCMISBrowserJSONRepositoryName = @"repositoryName";
NSString * const kCMISBrowserJSONRepositoryDescription = @"repositoryDescription";
NSString * const kCMISBrowserJSONVendorName = @"vendorName";
NSString * const kCMISBrowserJSONProductName = @"productName";
NSString * const kCMISBrowserJSONProductVersion = @"productVersion";
NSString * const kCMISBrowserJSONRootFolderId = @"rootFolderId";
NSString * const kCMISBrowserJSONCapabilities = @"capabilities";
NSString * const kCMISBrowserJSONCMISVersionSupported = @"cmisVersionSupported";
NSString * const kCMISBrowserJSONPrincipalIdAnonymous = @"principalIdAnonymous";
NSString * const kCMISBrowserJSONPrincipalIdAnyone = @"principalIdAnyone";
NSString * const kCMISBrowserJSONRepositoryUrl = @"repositoryUrl";
NSString * const kCMISBrowserJSONRootFolderUrl = @"rootFolderUrl";
NSString * const kCMISBrowserJSONId = @"id";
NSString * const kCMISBrowserJSONLocalName = @"localName";
NSString * const kCMISBrowserJSONLocalNamespace = @"localNamespace";
NSString * const kCMISBrowserJSONDisplayName = @"displayName";
NSString * const kCMISBrowserJSONQueryName = @"queryName";
NSString * const kCMISBrowserJSONDescription = @"description";
NSString * const kCMISBrowserJSONBaseId = @"baseId";
NSString * const kCMISBrowserJSONParentId = @"parentId";
NSString * const kCMISBrowserJSONCreateable = @"creatable";
NSString * const kCMISBrowserJSONFileable = @"fileable";
NSString * const kCMISBrowserJSONQueryable = @"queryable";
NSString * const kCMISBrowserJSONVersionable = @"versionable"; // document
NSString * const kCMISBrowserJSONContentStreamAllowed = @"contentStreamAllowed"; // document
NSString * const kCMISBrowserJSONAllowedSourceTypes = @"allowedSourceTypes"; // relationship
NSString * const kCMISBrowserJSONAllowedTargetTypes = @"allowedTargetTypes"; // relationship
NSString * const kCMISBrowserJSONFullTextIndexed = @"fulltextIndexed";
NSString * const kCMISBrowserJSONIncludedInSuperTypeQuery = @"includedInSupertypeQuery";
NSString * const kCMISBrowserJSONControllablePolicy = @"controllablePolicy";
NSString * const kCMISBrowserJSONControllableAcl = @"controllableACL";
NSString * const kCMISBrowserJSONPropertyDefinitions = @"propertyDefinitions";
NSString * const kCMISBrowserJSONTypeMutability = @"typeMutability";
NSString * const kCMISBrowserJSONPropertyType = @"propertyType";
NSString * const kCMISBrowserJSONCardinality = @"cardinality";
NSString * const kCMISBrowserJSONValue = @"value";
NSString * const kCMISBrowserJSONDatatype = @"type";
NSString * const kCMISBrowserJSONUpdateability = @"updatability";
NSString * const kCMISBrowserJSONInherited = @"inherited";
NSString * const kCMISBrowserJSONRequired = @"required";
NSString * const kCMISBrowserJSONOrderable = @"orderable";
NSString * const kCMISBrowserJSONOpenChoice = @"openChoice";
NSString * const kCMISBrowserJSONChoice = @"choice";
NSString * const kCMISBrowserJSONDefaultValue = @"defaultValue";
NSString * const kCMISBrowserJSONProperties = @"properties";
NSString * const kCMISBrowserJSONSuccinctProperties = @"succinctProperties";
NSString * const kCMISBrowserJSONPropertiesExtension = @"propertiesExtension";
NSString * const kCMISBrowserJSONAllowableActions = @"allowableActions";
NSString * const kCMISBrowserJSONRelationships = @"relationships";
NSString * const kCMISBrowserJSONChangeEventInfo = @"changeEventInfo";
NSString * const kCMISBrowserJSONAcl = @"acl";
NSString * const kCMISBrowserJSONAces = @"aces";
NSString * const kCMISBrowserJSONExactAcl = @"exactACL";
NSString * const kCMISBrowserJSONIsExact = @"isExact";
NSString * const kCMISBrowserJSONPolicyIds = @"policyIds";
NSString * const kCMISBrowserJSONPolicyIdsIds = @"ids";
NSString * const kCMISBrowserJSONRenditions = @"renditions";
NSString * const kCMISBrowserJSONObjects = @"objects";
NSString * const kCMISBrowserJSONResults = @"results";
NSString * const kCMISBrowserJSONObject = @"object";
NSString * const kCMISBrowserJSONHasMoreItems = @"hasMoreItems";
NSString * const kCMISBrowserJSONNumberItems = @"numItems";
NSString * const kCMISBrowserJSONChangeLogToken = @"changeLogToken";
NSString * const kCMISBrowserJSONThinClientUri = @"thinClientURI";
NSString * const kCMISBrowserJSONChangesIncomplete = @"changesIncomplete";
NSString * const kCMISBrowserJSONChangesOnType = @"changesOnType";
NSString * const kCMISBrowserJSONLatestChangeLogToken = @"latestChangeLogToken";
NSString * const kCMISBrowserJSONAclCapabilities = @"aclCapabilities";
NSString * const kCMISBrowserJSONExtendedFeatures = @"extendedFeatures";
NSString * const kCMISBrowserJSONMaxLength = @"maxLength";
NSString * const kCMISBrowserJSONMinValue = @"minValue";
NSString * const kCMISBrowserJSONMaxValue = @"maxValue";
NSString * const kCMISBrowserJSONPrecision = @"precision";
NSString * const kCMISBrowserJSONResolution = @"resolution";
NSString * const kCMISBrowserJSONFailedToDeleteId = @"ids";
NSString * const kCMISBrowserJSONAcePrincipal = @"principal";
NSString * const kCMISBrowserJSONAcePrincipalId = @"principalId";
NSString * const kCMISBrowserJSONAcePermissions = @"permissions";
NSString * const kCMISBrowserJSONAceIsDirect = @"isDirect";


// JSON enum values
NSString * const kCMISBrowserJSONPropertyTypeValueString = @"string";
NSString * const kCMISBrowserJSONPropertyTypeValueId = @"id";
NSString * const kCMISBrowserJSONPropertyTypeValueInteger = @"integer";
NSString * const kCMISBrowserJSONPropertyTypeValueDecimal = @"decimal";
NSString * const kCMISBrowserJSONPropertyTypeValueBoolean = @"boolean";
NSString * const kCMISBrowserJSONPropertyTypeValueDateTime = @"datetime";
NSString * const kCMISBrowserJSONPropertyTypeValueHtml = @"html";
NSString * const kCMISBrowserJSONPropertyTypeValueUri = @"uri";

NSString * const kCMISBrowserJSONCardinalityValueSingle = @"single";
NSString * const kCMISBrowserJSONCardinalityValueMultiple = @"multi";

NSString * const kCMISBrowserJSONUpdateabilityValueReadOnly = @"readonly";
NSString * const kCMISBrowserJSONUpdateabilityValueReadWrite = @"readwrite";
NSString * const kCMISBrowserJSONUpdateabilityValueOnCreate = @"oncreate";
NSString * const kCMISBrowserJSONUpdateabilityValueWhenCheckedOut = @"whencheckedout";

//JSON selectors
NSString * const kCMISBrowserJSONSSelectorLastResult = @"lastResult";
NSString * const kCMISBrowserJSONSelectorRepositoryInfo = @"repositoryInfo";
NSString * const kCMISBrowserJSONSelectorTypeChildren = @"typeChildren";
NSString * const kCMISBrowserJSONSelectorTypeDescendants = @"typeDescendants";
NSString * const kCMISBrowserJSONSelectorTypeDefinition = @"typeDefinition";
NSString * const kCMISBrowserJSONSelectorContent = @"content";
NSString * const kCMISBrowserJSONSelectorObject = @"object";
NSString * const kCMISBrowserJSONSelectorProperties = @"properties";
NSString * const kCMISBrowserJSONSelectorAllowableActions = @"allowableActions";
NSString * const kCMISBrowserJSONSelectorRenditions = @"renditions";
NSString * const kCMISBrowserJSONSelectorChildren = @"children";
NSString * const kCMISBrowserJSONSelectorDescendants = @"descendants";
NSString * const kCMISBrowserJSONSelectorParents = @"parents";
NSString * const kCMISBrowserJSONSelectorParent = @"parent";
NSString * const kCMISBrowserJSONSelectorFolderTree = @"folder";
NSString * const kCMISBrowserJSONSelectorQuery = @"query";
NSString * const kCMISBrowserJSONSelectorVersions = @"versions";
NSString * const kCMISBrowserJSONSelectorRelationships = @"relationships";
NSString * const kCMISBrowserJSONSelectorCheckedout = @"checkedout";
NSString * const kCMISBrowserJSONSelectorPolicies = @"policies";
NSString * const kCMISBrowserJSONSelectorAcl = @"acl";
NSString * const kCMISBrowserJSONSelectorContentChanges = @"contentChanges";

//JSON rendition properties
NSString * const kCMISBrowserJSONRenditionStreamId = @"streamId";
NSString * const kCMISBrowserJSONRenditionMimeType = @"mimeType";
NSString * const kCMISBrowserJSONRenditionLength = @"length";
NSString * const kCMISBrowserJSONRenditionKind = @"kind";
NSString * const kCMISBrowserJSONRenditionTitle = @"title";
NSString * const kCMISBrowserJSONRenditionHeight = @"height";
NSString * const kCMISBrowserJSONRenditionWidth = @"width";
NSString * const kCMISBrowserJSONRenditionDocumentId = @"renditionDocumentId";

// JSON specific parameters
NSString * const kCMISBrowserJSONParameterSelector = @"cmisselector";
NSString * const kCMISBrowserJSONParameterSuccinct = @"succinct";

// Browser binding control
NSString * const kCMISBrowserJSONControlCmisAction = @"cmisaction";
NSString * const kCMISBrowserJSONControlPropertyId = @"propertyId";
NSString * const kCMISBrowserJSONControlPropertyValue = @"propertyValue";


// Browser binding actions
NSString * const kCMISBrowserJSONActionCreateType = @"createType";
NSString * const kCMISBrowserJSONActionUpdateType = @"updateType";
NSString * const kCMISBrowserJSONActionDeleteType = @"deleteType";
NSString * const kCMISBrowserJSONActionCreateDocument = @"createDocument";
NSString * const kCMISBrowserJSONActionCreateDocumentFromSource = @"createDocumentFromSource";
NSString * const kCMISBrowserJSONActionCreateFolder = @"createFolder";
NSString * const kCMISBrowserJSONActionCreateRelationship = @"createRelationship";
NSString * const kCMISBrowserJSONActionCreatePolicy = @"createPolicy";
NSString * const kCMISBrowserJSONActionCreateItem = @"createItem";
NSString * const kCMISBrowserJSONActionUpdateProperties = @"update";
NSString * const kCMISBrowserJSONActionBulkUpdate = @"bulkUpdate";
NSString * const kCMISBrowserJSONActionDeleteContent = @"deleteContent";
NSString * const kCMISBrowserJSONActionSetContent = @"setContent";
NSString * const kCMISBrowserJSONActionAppendContent = @"appendContent";
NSString * const kCMISBrowserJSONActionDelete = @"delete";
NSString * const kCMISBrowserJSONActionDeleteTree = @"deleteTree";
NSString * const kCMISBrowserJSONActionMove = @"move";
NSString * const kCMISBrowserJSONActionAddObjectToFolder = @"addObjectToFolder";
NSString * const kCMISBrowserJSONActionRemoveObjectFromFolder = @"removeObjectFromFolder";
NSString * const kCMISBrowserJSONActionQuery = @"query";
NSString * const kCMISBrowserJSONActionCheckOut = @"checkOut";
NSString * const kCMISBrowserJSONActionCancelCheckOut = @"cancelCheckOut";
NSString * const kCMISBrowserJSONActionCheckIn = @"checkIn";
NSString * const kCMISBrowserJSONActionApplyPolicy = @"applyPolicy";
NSString * const kCMISBrowserJSONActionRemovePolicy = @"removePolicy";
NSString * const kCMISBrowserJSONActionApplyAcl = @"applyACL";

+ (NSSet *)objectKeys
{
    if(!_objectKeys) {
        _objectKeys = [NSSet setWithObjects:
                       kCMISBrowserJSONProperties,
                       kCMISBrowserJSONSuccinctProperties,
                       kCMISBrowserJSONAllowableActions,
                       kCMISBrowserJSONRelationships,
                       kCMISBrowserJSONChangeEventInfo,
                       kCMISBrowserJSONAcl,
                       kCMISBrowserJSONExactAcl,
                       kCMISBrowserJSONPolicyIds,
                       kCMISBrowserJSONRenditions,
                       nil];
    }
    return _objectKeys;
}

+ (NSSet *)repositoryInfoKeys
{
    if(!_repositoryInfoKeys) {
        _repositoryInfoKeys = [NSSet setWithObjects:
                               kCMISBrowserJSONRepositoryId,
                               kCMISBrowserJSONRepositoryName,
                               kCMISBrowserJSONRepositoryDescription,
                               kCMISBrowserJSONVendorName,
                               kCMISBrowserJSONProductName,
                               kCMISBrowserJSONProductVersion,
                               kCMISBrowserJSONRootFolderId,
                               kCMISBrowserJSONRepositoryUrl,
                               kCMISBrowserJSONRootFolderUrl,
                               kCMISBrowserJSONCapabilities,
                               kCMISBrowserJSONAclCapabilities,
                               kCMISBrowserJSONLatestChangeLogToken,
                               kCMISBrowserJSONCMISVersionSupported,
                               kCMISBrowserJSONThinClientUri,
                               kCMISBrowserJSONChangesIncomplete,
                               kCMISBrowserJSONChangesOnType,
                               kCMISBrowserJSONPrincipalIdAnonymous,
                               kCMISBrowserJSONPrincipalIdAnyone,
                               kCMISBrowserJSONExtendedFeatures,
                               nil];
    }
    return _repositoryInfoKeys;
}

+ (NSSet *)typeKeys
{
    if(!_typeKeys) {
        _typeKeys = [NSSet setWithObjects:
                     kCMISBrowserJSONId,
                     kCMISBrowserJSONLocalName,
                     kCMISBrowserJSONLocalNamespace,
                     kCMISBrowserJSONDisplayName,
                     kCMISBrowserJSONQueryName,
                     kCMISBrowserJSONDescription,
                     kCMISBrowserJSONBaseId,
                     kCMISBrowserJSONParentId,
                     kCMISBrowserJSONCreateable,
                     kCMISBrowserJSONFileable,
                     kCMISBrowserJSONQueryable,
                     kCMISBrowserJSONFullTextIndexed,
                     kCMISBrowserJSONIncludedInSuperTypeQuery,
                     kCMISBrowserJSONControllablePolicy,
                     kCMISBrowserJSONControllableAcl,
                     kCMISBrowserJSONPropertyDefinitions,
                     kCMISBrowserJSONVersionable,
                     kCMISBrowserJSONContentStreamAllowed,
                     kCMISBrowserJSONAllowedSourceTypes,
                     kCMISBrowserJSONAllowedTargetTypes,
                     kCMISBrowserJSONTypeMutability,
                     nil];
    }
    return _typeKeys;
}

+ (NSSet *)propertyKeys
{
    if(!_propertyKeys) {
        _propertyKeys = [NSSet setWithObjects:
                         kCMISBrowserJSONId,
                         kCMISBrowserJSONLocalName,
                         kCMISBrowserJSONDisplayName,
                         kCMISBrowserJSONQueryName,
                         kCMISBrowserJSONValue,
                         kCMISBrowserJSONDatatype,
                         kCMISBrowserJSONCardinality,
                         nil];
    }
    return _propertyKeys;
}

+ (NSSet *)propertyTypeKeys
{
    if(!_propertyTypeKeys) {
        _propertyTypeKeys = [NSSet setWithObjects:
                             kCMISBrowserJSONId,
                             kCMISBrowserJSONLocalName,
                             kCMISBrowserJSONLocalNamespace,
                             kCMISBrowserJSONDisplayName,
                             kCMISBrowserJSONQueryName,
                             kCMISBrowserJSONDescription,
                             kCMISBrowserJSONPropertyType,
                             kCMISBrowserJSONCardinality,
                             kCMISBrowserJSONUpdateability,
                             kCMISBrowserJSONInherited,
                             kCMISBrowserJSONRequired,
                             kCMISBrowserJSONQueryable,
                             kCMISBrowserJSONOrderable,
                             kCMISBrowserJSONOpenChoice,
                             kCMISBrowserJSONDefaultValue,
                             kCMISBrowserJSONMaxLength,
                             kCMISBrowserJSONMinValue,
                             kCMISBrowserJSONMaxValue,
                             kCMISBrowserJSONPrecision,
                             kCMISBrowserJSONResolution,
                             kCMISBrowserJSONChoice,
                             nil];
    }
    return _propertyTypeKeys;
}

+ (NSSet *)renditionKeys
{
    if(!_renditionKeys) {
        _renditionKeys = [NSSet setWithObjects:
                          kCMISBrowserJSONRenditionStreamId,
                          kCMISBrowserJSONRenditionMimeType,
                          kCMISBrowserJSONRenditionLength,
                          kCMISBrowserJSONRenditionKind,
                          kCMISBrowserJSONRenditionTitle,
                          kCMISBrowserJSONRenditionHeight,
                          kCMISBrowserJSONRenditionWidth,
                          kCMISBrowserJSONRenditionDocumentId,
                          nil];
    }
    return _renditionKeys;
}

+ (NSSet *)objectListKeys
{
    if(!_objectListKeys) {
        _objectListKeys = [NSSet setWithObjects:
                           kCMISBrowserJSONObjects,
                           kCMISBrowserJSONHasMoreItems,
                           kCMISBrowserJSONNumberItems,
                           kCMISBrowserJSONChangeLogToken,
                           nil];
    }
    return _objectListKeys;
}

+ (NSSet *)queryResultListKeys
{
    if(!_queryResultListKeys) {
        _queryResultListKeys = [NSSet setWithObjects:
                                kCMISBrowserJSONResults,
                                kCMISBrowserJSONHasMoreItems,
                                kCMISBrowserJSONNumberItems,
                                nil];
    }
    return _queryResultListKeys;
}

+ (NSSet *)aclKeys
{
    if(!_aclKeys) {
        _aclKeys = [NSSet setWithObjects:
                    kCMISBrowserJSONAces,
                    kCMISBrowserJSONIsExact,
                    nil];
    }
    return _aclKeys;
}

+ (NSSet *)aceKeys
{
    if(!_aceKeys) {
        _aceKeys = [NSSet setWithObjects:
                    kCMISBrowserJSONAcePrincipal,
                    kCMISBrowserJSONAcePrincipalId,
                    kCMISBrowserJSONAcePermissions,
                    kCMISBrowserJSONAceIsDirect,
                    nil];
    }
    return _aceKeys;
}

+ (NSSet *)principalKeys
{
    if(!_principalKeys) {
        _principalKeys = [NSSet setWithObjects:
                          kCMISBrowserJSONAcePrincipalId,
                          nil];
    }
    return _principalKeys;
}

@end
