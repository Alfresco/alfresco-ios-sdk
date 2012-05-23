//
//  CMISEnums.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 22/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

// Binding type
typedef enum 
{
    CMISBindingTypeAtomPub,
    CMISBindingTypeCustom
} CMISBindingType;

// Base type
typedef enum
{
    CMISBaseTypeDocument,
    CMISBaseTypeFolder,
    CMISBaseTypeRelationship,
    CMISBaseTypePolicy
} CMISBaseType;

// Property types
typedef enum
{
    CMISPropertyTypeBoolean,
    CMISPropertyTypeId,
    CMISPropertyTypeInteger,
    CMISPropertyTypeDateTime,
    CMISPropertyTypeDecimal,
    CMISPropertyTypeHtml,
    CMISPropertyTypeString,
    CMISPropertyTypeUri
} CMISPropertyType;

// Property cardinality options
typedef enum
{
    CMISCardinalitySingle,
    CMISCardinalityMulti
} CMISCardinality;

// Property updatability options
typedef enum
{
    CMISUpdatabilityReadOnly,
    CMISUpdatabilityReadWrite,
    CMISUpdatabilityWhenCheckedOut,
    CMISUpdatabilityOnCreate
} CMISUpdatability;

// Allowable action type
typedef enum
{
    CMISActionCanDeleteObject,
    CMISActionCanUpdateProperties,
    CMISActionCanGetProperties,
    CMISActionCanGetObjectRelationships,
    CMISActionCanGetObjectParents,
    CMISActionCanGetFolderParent,
    CMISActionCanGetFolderTree,
    CMISActionCanGetDescendants,
    CMISActionCanMoveObject,
    CMISActionCanDeleteContentStream,
    CMISActionCanCheckOut,
    CMISActionCanCancelCheckOut,
    CMISActionCanCheckIn,
    CMISActionCanSetContentStream,
    CMISActionCanGetAllVersions,
    CMISActionCanAddObjectToFolder,
    CMISActionCanRemoveObjectFromFolder,
    CMISActionCanGetContentStream,
    CMISActionCanApplyPolicy,
    CMISActionCanGetAppliedPolicies,
    CMISActionCanRemovePolicy,
    CMISActionCanGetChildren,
    CMISActionCanCreateDocument,
    CMISActionCanCreateFolder,
    CMISActionCanCreateRelationship,
    CMISActionCanDeleteTree,
    CMISActionCanGetRenditions,
    CMISActionCanGetACL,
    CMISActionCanApplyACL
} CMISActionType;

// AllowableAction String Array, the objects defined MUST be in the same order as those in enum CMISActionType
#define CMISAllowableActionsArray @"canDeleteObject", @"canUpdateProperties", @"canGetProperties", \
    @"canGetObjectRelationships", @"canGetObjectParents", @"canGetFolderParent", @"canGetFolderTree", \
    @"canGetDescendants", @"canMoveObject", @"canDeleteContentStream", @"canCheckOut", \
    @"canCancelCheckOut",  @"canCheckIn", @"canSetContentStream", @"canGetAllVersions", \
    @"canAddObjectToFolder", @"canRemoveObjectFromFolder", @"canGetContentStream", @"canApplyPolicy", \
    @"canGetAppliedPolicies", @"canRemovePolicy", @"canGetChildren", @"canCreateDocument", @"canCreateFolder", \
    @"canCreateRelationship", @"canDeleteTree", @"canGetRenditions", @"canGetACL", @"canApplyACL", nil

// Extension Levels
typedef enum
{
    CMISExtensionLevelProperties
    // TODO expose the remaining extensions as they are implemented
    // CMISExtensionLevelObject, CMISExtensionLevelAllowableActions, CMISExtensionLevelAcl, CMISExtensionLevelPolicies, CMISExtensionLevelChangeEvent

} CMISExtensionLevel;
