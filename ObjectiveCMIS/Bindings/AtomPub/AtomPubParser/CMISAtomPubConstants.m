//
//  CMISAtomPubConstants.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 11/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAtomPubConstants.h"

NSString * const kCMISAtomEntryLink = @"link";
NSString * const kCMISAtomEntryRel = @"rel";
NSString * const kCMISAtomEntryHref = @"href";
NSString * const kCMISAtomEntryType = @"type";
NSString * const kCMISAtomEntryObject = @"object";
NSString * const kCMISAtomEntryObjectId = @"cmis:objectId";
NSString * const kCMISAtomEntryProperties = @"properties";
NSString * const kCMISAtomEntryPropertyId = @"propertyId";
NSString * const kCMISAtomEntryPropertyString = @"propertyString";
NSString * const kCMISAtomEntryPropertyDateTime = @"propertyDateTime";
NSString * const kCMISAtomEntryPropertyDefId = @"propertyDefinitionId";
NSString * const kCMISAtomEntryDisplayName = @"displayName";
NSString * const kCMISAtomEntryQueryName = @"queryName";
NSString * const kCMISAtomEntryValue = @"value";
NSString * const kCMISAtomEntryBaseTypeId = @"cmis:baseTypeId";
NSString * const kCMISAtomEntryAllowableActions = @"allowableActions";

// Namespaces
NSString * const kCMISNamespaceCmis = @"http://docs.oasis-open.org/ns/cmis/core/200908/";
NSString * const kCMISNamespaceCmisRestAtom = @"http://docs.oasis-open.org/ns/cmis/restatom/200908/";
NSString * const kCMISNamespaceAtom = @"http://www.w3.org/2005/Atom";
NSString * const kCMISNamespaceApp = @"http://www.w3.org/2007/app";

// Media Types
NSString * const kCMISMediaTypeService = @"application/atomsvc+xml";
NSString * const kCMISMediaTypeFeed = @"application/atom+xml;type=feed";
NSString * const kCMISMediaTypeEntry = @"application/atom+xml;type=entry";
NSString * const kCMISMediaTypeChildren = @"application/atom+xml;type=feed";
NSString * const kCMISMediaTypeDescendants = @"application/cmistree+xml";
NSString * const kCMISMediaTypeQuery = @"application/cmisquery+xml";
NSString * const kCMISMediaTypeAllowableAction  = @"application/cmisallowableactions+xml";
NSString * const kCMISMediaTypeAcl = @"application/cmisacl+xml";
NSString * const kCMISMediaTypeCmisAtom = @"application/cmisatom+xml";
NSString * const kCMISMediaTypeOctetStream = @"application/octet-stream";
