//
//  CMISEnums.h
//  HybridApp
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
