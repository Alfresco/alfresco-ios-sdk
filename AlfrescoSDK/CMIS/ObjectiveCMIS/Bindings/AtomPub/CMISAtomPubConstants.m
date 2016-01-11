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

#import "CMISAtomPubConstants.h"

// Session keys
NSString * const kCMISAtomBindingSessionKeyObjectByIdUriBuilder = @"cmis_session_key_atom_objectbyid_uri_builder";
NSString * const kCMISAtomBindingSessionKeyObjectByPathUriBuilder = @"cmis_session_key_atom_objectbypath_uri_builder";
NSString * const kCMISAtomBindingSessionKeyChildrenByIdUriBuilder = @"cmis_session_key_atom_childrenbyid_uri_builder";
NSString * const kCMISAtomBindingSessionKeyTypeByIdUriBuilder = @"cmis_session_key_atom_type_by_id_uri_builder";
NSString * const kCMISAtomBindingSessionKeyQueryUri = @"cmis_session_key_atom_query_uri";
NSString * const kCMISAtomBindingSessionKeyQueryCollection = @"cmis_session_key_atom_query_collection";
NSString * const kCMISAtomBindingSessionKeyCheckedoutCollection = @"cmis_session_key_atom_checkedout_collection";
NSString * const kCMISAtomBindingSessionKeyLinkCache = @"cmis_session_key_atom_link_cache";

// Feed
NSString * const kCMISAtomFeedNumItems = @"numItems";

// Entry
NSString * const kCMISAtomEntry = @"entry";
NSString * const kCMISAtomEntryLink = @"link";
NSString * const kCMISAtomEntryRel = @"rel";
NSString * const kCMISAtomEntryHref = @"href";
NSString * const kCMISAtomEntryType = @"type";
NSString * const kCMISAtomEntryObject = @"object";
NSString * const kCMISAtomEntryProperties = @"properties";
NSString * const kCMISAtomEntryPropertyId = @"propertyId";
NSString * const kCMISAtomEntryPropertyString = @"propertyString";
NSString * const kCMISAtomEntryPropertyInteger = @"propertyInteger";
NSString * const kCMISAtomEntryPropertyDecimal = @"propertyDecimal";
NSString * const kCMISAtomEntryPropertyDateTime = @"propertyDateTime";
NSString * const kCMISAtomEntryPropertyBoolean = @"propertyBoolean";
NSString * const kCMISAtomEntryPropertyUri = @"propertyUri";
NSString * const kCMISAtomEntryPropertyHtml = @"propertyHtml";
NSString * const kCMISAtomEntryPropertyDefId = @"propertyDefinitionId";
NSString * const kCMISAtomEntryDisplayName = @"displayName";
NSString * const kCMISAtomEntryQueryName = @"queryName";
NSString * const kCMISAtomEntryValue = @"value";
NSString * const kCMISAtomEntryValueTrue = @"true";
NSString * const kCMISAtomEntryContent = @"content";
NSString * const kCMISAtomEntrySrc = @"src";
NSString * const kCMISAtomEntryAllowableActions = @"allowableActions";
NSString * const kCMISAtomEntryAcl = @"acl";
NSString * const kCMISAtomEntryExactACL = @"exactACL";
NSString * const kCMISAtomEntryPermission = @"permission";
NSString * const kCMISAtomEntryPrincipal = @"principal";
NSString * const kCMISAtomEntryPrincipalId = @"principalId";
NSString * const kCMISAtomEntryDirect = @"direct";

// Collections
NSString * const kCMISAtomCollectionQuery = @"query";
NSString * const kCMISAtomCollectionCheckedout = @"checkedout";

// Media Types
NSString * const kCMISMediaTypeFeed = @"application/atom+xml;type=feed";
NSString * const kCMISMediaTypeEntry = @"application/atom+xml;type=entry";
NSString * const kCMISMediaTypeChildren = @"application/atom+xml;type=feed";
NSString * const kCMISMediaTypeDescendants = @"application/cmistree+xml";
NSString * const kCMISMediaTypeQuery = @"application/cmisquery+xml";

// Links
NSString * const kCMISLinkRelationDown = @"down";
NSString * const kCMISLinkRelationUp = @"up";
NSString * const kCMISLinkRelationSelf = @"self";
NSString * const kCMISLinkRelationFolderTree = @"http://docs.oasis-open.org/ns/cmis/link/200908/foldertree";
NSString * const kCMISLinkVersionHistory = @"version-history";
NSString * const kCMISLinkEditMedia = @"edit-media";
NSString * const kCMISLinkRelationNext = @"next";
NSString * const kCMISLinkRelationWorkingCopy = @"working-copy";

// Namespaces
NSString * const kCMISNamespaceCmis = @"http://docs.oasis-open.org/ns/cmis/core/200908/";
NSString * const kCMISNamespaceCmisRestAtom = @"http://docs.oasis-open.org/ns/cmis/restatom/200908/";
NSString * const kCMISNamespaceAtom = @"http://www.w3.org/2005/Atom";
NSString * const kCMISNamespaceApp = @"http://www.w3.org/2007/app";

// App Element Names
NSString * const kCMISAppWorkspace = @"workspace";
NSString * const kCMISAppCollection = @"collection";
NSString * const kCMISAppAccept = @"accept";

// Atom Element Names
NSString * const kCMISAtomTitle = @"title";
NSString * const kCMISAtomLink = @"link";

// CMIS-RestAtom Element Names
NSString * const kCMISRestAtomRepositoryInfo = @"repositoryInfo";
NSString * const kCMISRestAtomCollectionType = @"collectionType";
NSString * const kCMISRestAtomUritemplate = @"uritemplate";
NSString * const kCMISRestAtomMediaType = @"mediaType";
NSString * const kCMISRestAtomType = @"type";
NSString * const kCMISRestAtomTemplate = @"template";

// CMIS-Core Element Names
NSString * const kCMISCoreRepositoryId = @"repositoryId";
NSString * const kCMISCoreRepositoryName = @"repositoryName";
NSString * const kCMISCoreRepositoryDescription = @"repositoryDescription";
NSString * const kCMISCoreVendorName = @"vendorName";
NSString * const kCMISCoreProductName = @"productName";
NSString * const kCMISCoreProductVersion = @"productVersion";
NSString * const kCMISCoreRootFolderId = @"rootFolderId";
NSString * const kCMISCoreCapabilities = @"capabilities";
NSString * const _kCMISCoreCapabilityPrefix = @"capability";
NSString * const kCMISCoreAclCapability = @"aclCapability";
NSString * const kCMISCorePermissions = @"permissions";
NSString * const kCMISCorePermission = @"permission";
NSString * const kCMISCoreMapping = @"mapping";
NSString * const kCMISCoreKey = @"key";
NSString * const kCMISCoreSupportedPermissions = @"supportedPermissions";
NSString * const kCMISCorePropagation = @"propagation";
NSString * const kCMISCoreCmisVersionSupported = @"cmisVersionSupported";
NSString * const kCMISCoreChangesIncomplete = @"changesIncomplete";
NSString * const kCMISCoreChangesOnType = @"changesOnType";
NSString * const kCMISCorePrincipalAnonymous = @"principalAnonymous";
NSString * const kCMISCorePrincipalAnyone = @"principalAnyone";
NSString * const kCMISCoreId = @"id";
NSString * const kCMISCoreLocalName = @"localName";
NSString * const kCMISCoreLocalNamespace = @"localNamespace";
NSString * const kCMISCoreDisplayName = @"displayName";
NSString * const kCMISCoreQueryName = @"queryName";
NSString * const kCMISCoreDescription = @"description";
NSString * const kCMISCoreBaseId = @"baseId";
NSString * const kCMISCoreParentId = @"parentId";
NSString * const kCMISCoreCreatable = @"creatable";
NSString * const kCMISCoreFileable = @"fileable";
NSString * const kCMISCoreQueryable = @"queryable";
NSString * const kCMISCoreFullTextIndexed = @"fulltextIndexed";
NSString * const kCMISCoreIncludedInSupertypeQuery = @"includedInSupertypeQuery";
NSString * const kCMISCoreControllablePolicy = @"controllablePolicy";
NSString * const kCMISCoreControllableACL = @"controllableACL";
NSString * const kCMISCoreCardinality = @"cardinality";
NSString * const kCMISCoreUpdatability = @"updatability";
NSString * const kCMISCoreInherited = @"inherited";
NSString * const kCMISCoreRequired = @"required";
NSString * const kCMISCoreOrderable = @"orderable";
NSString * const kCMISCoreOpenChoice = @"openChoice";
NSString * const kCMISCoreChoice = @"choice";
NSString * const kCMISCoreChoiceString = @"choiceString";
NSString * const kCMISCoreDefaultValue = @"defaultValue";
NSString * const kCMISCoreVersionable = @"versionable";
NSString * const kCMISCoreContentStreamAllowed = @"contentStreamAllowed";
NSString * const kCMISCoreAllowed = @"allowed";
NSString * const kCMISCoreNotAllowed = @"notallowed";

NSString * const kCMISCorePropertyStringDefinition = @"propertyStringDefinition";
NSString * const kCMISCorePropertyIdDefinition = @"propertyIdDefinition";
NSString * const kCMISCorePropertyBooleanDefinition = @"propertyBooleanDefinition";
NSString * const kCMISCorePropertyDateTimeDefinition = @"propertyDateTimeDefinition";
NSString * const kCMISCorePropertyIntegerDefinition = @"propertyIntegerDefinition";
NSString * const kCMISCorePropertyDecimalDefinition = @"propertyDecimalDefinition";
NSString * const kCMISCoreProperties = @"properties";

NSString * const kCMISCoreRendition = @"rendition";
NSString * const kCMISCoreStreamId = @"streamId";
NSString * const kCMISCoreMimetype = @"mimetype";
NSString * const kCMISCoreLength = @"length";
NSString * const kCMISCoreKind = @"kind";
NSString * const kCMISCoreHeight = @"height";
NSString * const kCMISCoreWidth = @"width";
NSString * const kCMISCoreTitle = @"title";
NSString * const kCMISCoreRenditionDocumentId = @"renditionDocumentId";
NSString * const kCMISCoreRelationship = @"relationship";

// URI Templates
NSString * const kCMISUriTemplateObjectById = @"objectbyid";
NSString * const kCMISUriTemplateObjectByPath = @"objectbypath";
NSString * const kCMISUriTemplateTypeById = @"typebyid";
NSString * const kCMISUriTemplateQuery = @"query";

// Common Attributes
NSString * const kCMISAtomLinkAttrHref = @"href";
NSString * const kCMISAtomLinkAttrType = @"type";
NSString * const kCMISAtomLinkAttrRel = @"rel";

// Constants for HTTP request headers
NSString * const kCMISHTTPHeaderContentType = @"Content-Type";
NSString * const kCMISHTTPHeaderContentDisposition = @"Content-Disposition";
NSString * const kCMISHTTPHeaderContentDispositionAttachment = @"attachment; filename=%@";
