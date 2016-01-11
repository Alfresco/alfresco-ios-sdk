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

// Session keys
extern NSString * const kCMISAtomBindingSessionKeyObjectByIdUriBuilder;
extern NSString * const kCMISAtomBindingSessionKeyObjectByPathUriBuilder;
extern NSString * const kCMISAtomBindingSessionKeyChildrenByIdUriBuilder;
extern NSString * const kCMISAtomBindingSessionKeyTypeByIdUriBuilder;
extern NSString * const kCMISAtomBindingSessionKeyQueryUri;
extern NSString * const kCMISAtomBindingSessionKeyQueryCollection;
extern NSString * const kCMISAtomBindingSessionKeyCheckedoutCollection;
extern NSString * const kCMISAtomBindingSessionKeyLinkCache;

// Feed
extern NSString * const kCMISAtomFeedNumItems;

// Entry
extern NSString * const kCMISAtomEntry;
extern NSString * const kCMISAtomEntryLink;
extern NSString * const kCMISAtomEntryRel;
extern NSString * const kCMISAtomEntryHref;
extern NSString * const kCMISAtomEntryType;
extern NSString * const kCMISAtomEntryObject;
extern NSString * const kCMISAtomEntryProperties;
extern NSString * const kCMISAtomEntryPropertyId;
extern NSString * const kCMISAtomEntryPropertyString;
extern NSString * const kCMISAtomEntryPropertyInteger;
extern NSString * const kCMISAtomEntryPropertyDecimal;
extern NSString * const kCMISAtomEntryPropertyDateTime;
extern NSString * const kCMISAtomEntryPropertyBoolean;
extern NSString * const kCMISAtomEntryPropertyUri;
extern NSString * const kCMISAtomEntryPropertyHtml;
extern NSString * const kCMISAtomEntryPropertyDefId;
extern NSString * const kCMISAtomEntryDisplayName;
extern NSString * const kCMISAtomEntryQueryName;
extern NSString * const kCMISAtomEntryValue;
extern NSString * const kCMISAtomEntryValueTrue;
extern NSString * const kCMISAtomEntryContent;
extern NSString * const kCMISAtomEntrySrc;
extern NSString * const kCMISAtomEntryAllowableActions;
extern NSString * const kCMISAtomEntryAcl;
extern NSString * const kCMISAtomEntryExactACL;
extern NSString * const kCMISAtomEntryPermission;
extern NSString * const kCMISAtomEntryPrincipal;
extern NSString * const kCMISAtomEntryPrincipalId;
extern NSString * const kCMISAtomEntryDirect;

// Collections
extern NSString * const kCMISAtomCollectionQuery;
extern NSString * const kCMISAtomCollectionCheckedout;

// Media Types
extern NSString * const kCMISMediaTypeFeed;
extern NSString * const kCMISMediaTypeEntry;
extern NSString * const kCMISMediaTypeChildren;
extern NSString * const kCMISMediaTypeDescendants;
extern NSString * const kCMISMediaTypeQuery;

// Links
extern NSString * const kCMISLinkRelationDown;
extern NSString * const kCMISLinkRelationUp;
extern NSString * const kCMISLinkRelationSelf;
extern NSString * const kCMISLinkRelationFolderTree;
extern NSString * const kCMISLinkVersionHistory;
extern NSString * const kCMISLinkEditMedia;
extern NSString * const kCMISLinkRelationNext;
extern NSString * const kCMISLinkRelationWorkingCopy;

// Namespaces
extern NSString * const kCMISNamespaceCmis;
extern NSString * const kCMISNamespaceCmisRestAtom;
extern NSString * const kCMISNamespaceAtom;
extern NSString * const kCMISNamespaceApp;

// App Element Names
extern NSString * const kCMISAppWorkspace;
extern NSString * const kCMISAppCollection;
extern NSString * const kCMISAppAccept;

// Atom Element Names
extern NSString * const kCMISAtomTitle;
extern NSString * const kCMISAtomLink;

// CMIS RestAtom Element Names
extern NSString * const kCMISRestAtomRepositoryInfo;
extern NSString * const kCMISRestAtomCollectionType;
extern NSString * const kCMISRestAtomUritemplate;
extern NSString * const kCMISRestAtomMediaType;
extern NSString * const kCMISRestAtomType;
extern NSString * const kCMISRestAtomTemplate;

// CMIS Core Element Names
extern NSString * const kCMISCoreRepositoryId;
extern NSString * const kCMISCoreRepositoryName;
extern NSString * const kCMISCoreRepositoryDescription;
extern NSString * const kCMISCoreVendorName;
extern NSString * const kCMISCoreProductName;
extern NSString * const kCMISCoreProductVersion;
extern NSString * const kCMISCoreRootFolderId;
extern NSString * const kCMISCoreCapabilities;
extern NSString * const _kCMISCoreCapabilityPrefix;
extern NSString * const kCMISCoreAclCapability;
extern NSString * const kCMISCorePermissions;
extern NSString * const kCMISCorePermission;
extern NSString * const kCMISCoreMapping;
extern NSString * const kCMISCoreKey;
extern NSString * const kCMISCoreSupportedPermissions;
extern NSString * const kCMISCorePropagation;
extern NSString * const kCMISCoreCmisVersionSupported;
extern NSString * const kCMISCoreChangesIncomplete;
extern NSString * const kCMISCoreChangesOnType;
extern NSString * const kCMISCorePrincipalAnonymous;
extern NSString * const kCMISCorePrincipalAnyone;
extern NSString * const kCMISCoreId;
extern NSString * const kCMISCoreLocalName;
extern NSString * const kCMISCoreLocalNamespace;
extern NSString * const kCMISCoreDisplayName;
extern NSString * const kCMISCoreQueryName;
extern NSString * const kCMISCoreDescription;
extern NSString * const kCMISCoreBaseId;
extern NSString * const kCMISCoreParentId;
extern NSString * const kCMISCoreCreatable;
extern NSString * const kCMISCoreFileable;
extern NSString * const kCMISCoreQueryable;
extern NSString * const kCMISCoreFullTextIndexed;
extern NSString * const kCMISCoreIncludedInSupertypeQuery;
extern NSString * const kCMISCoreControllablePolicy;
extern NSString * const kCMISCoreControllableACL;
extern NSString * const kCMISCoreCardinality;
extern NSString * const kCMISCoreUpdatability;
extern NSString * const kCMISCoreInherited;
extern NSString * const kCMISCoreRequired;
extern NSString * const kCMISCoreOrderable;
extern NSString * const kCMISCoreOpenChoice;
extern NSString * const kCMISCoreChoice;
extern NSString * const kCMISCoreChoiceString;
extern NSString * const kCMISCoreDefaultValue;
extern NSString * const kCMISCoreVersionable;
extern NSString * const kCMISCoreContentStreamAllowed;
extern NSString * const kCMISCoreAllowed;
extern NSString * const kCMISCoreNotAllowed;

extern NSString * const kCMISCorePropertyStringDefinition;
extern NSString * const kCMISCorePropertyIdDefinition;
extern NSString * const kCMISCorePropertyBooleanDefinition;
extern NSString * const kCMISCorePropertyDateTimeDefinition;
extern NSString * const kCMISCorePropertyIntegerDefinition;
extern NSString * const kCMISCorePropertyDecimalDefinition;
extern NSString * const kCMISCoreProperties;

extern NSString * const kCMISCoreRendition;
extern NSString * const kCMISCoreStreamId;
extern NSString * const kCMISCoreMimetype;
extern NSString * const kCMISCoreLength;
extern NSString * const kCMISCoreKind;
extern NSString * const kCMISCoreHeight;
extern NSString * const kCMISCoreWidth;
extern NSString * const kCMISCoreTitle;
extern NSString * const kCMISCoreRenditionDocumentId;
extern NSString * const kCMISCoreRelationship;

// URI Templates
extern NSString * const kCMISUriTemplateObjectById;
extern NSString * const kCMISUriTemplateObjectByPath;
extern NSString * const kCMISUriTemplateTypeById;
extern NSString * const kCMISUriTemplateQuery;

// Common Attributes
// TODO Consolidate the common attributes or define individually for each element?
extern NSString * const kCMISAtomLinkAttrHref;
extern NSString * const kCMISAtomLinkAttrType;
extern NSString * const kCMISAtomLinkAttrRel;

// Constants for HTTP request headers
extern NSString * const kCMISHTTPHeaderContentType;
extern NSString * const kCMISHTTPHeaderContentDisposition;
extern NSString * const kCMISHTTPHeaderContentDispositionAttachment;

