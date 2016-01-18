/*******************************************************************************
 * Copyright (C) 2005-2013 Alfresco Software Limited.
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

#import "AlfrescoCMISToAlfrescoObjectConverter.h"
#import "CMISDocument.h"
#import "CMISSession.h"
#import "CMISQueryResult.h"
#import "AlfrescoCMISObjectConverter.h"
#import "CMISConstants.h"
#import "AlfrescoProperty.h"
#import <objc/runtime.h>
#import "AlfrescoInternalConstants.h"
#import "AlfrescoCloudSession.h"
#import "AlfrescoCMISFolder.h"
#import "AlfrescoCMISDocument.h"
#import "AlfrescoNodeTypeDefinition.h"
#import "AlfrescoPropertyConstants.h"
#import "CMISPropertyDefinition.h"

static NSString * const kAlfrescoCMISEmptyString = @"(null)";

@implementation NSMutableDictionary (AlfrescoCMISToAlfrescoObjectConverter)

- (void)alf_setValueIfNotEmpty:(NSString *)value forKey:(NSString *)key
{
    if (value && key && ![value isEqualToString:kAlfrescoCMISEmptyString])
    {
        self[key] = value;
    }
}

@end


@interface AlfrescoCMISToAlfrescoObjectConverter ()
@property (nonatomic, assign) BOOL isCloud;
@property (nonatomic, strong)id<AlfrescoSession>session;
@end

@implementation AlfrescoCMISToAlfrescoObjectConverter

- (id)initWithSession:(id<AlfrescoSession>)session
{
    if (self = [super init])
    {
        self.session = session;
        self.isCloud = [self.session isKindOfClass:[AlfrescoCloudSession class]];
    }
    
    return self;
}

- (AlfrescoFolder *)folderFromCMISFolder:(CMISFolder *)cmisFolder
                              properties:(NSMutableDictionary *)properties
{
    if (nil == properties)
    {
        properties = [NSMutableDictionary dictionary];
    }

    NSString *objectType = cmisFolder.objectType;
    if (![objectType isEqualToString:kAlfrescoCMISEmptyString])
    {
        NSString *alfrescoObjectType = [objectType stringByReplacingOccurrencesOfString:kCMISPropertyObjectTypeIdValueFolder withString:kAlfrescoModelTypeFolder];
        properties[kCMISPropertyObjectTypeId] = [self propertyValueWithoutPrecursor:alfrescoObjectType];
    }

    [properties alf_setValueIfNotEmpty:cmisFolder.identifier forKey:kCMISPropertyObjectId];
    [properties alf_setValueIfNotEmpty:cmisFolder.name forKey:kCMISPropertyName];
    [properties alf_setValueIfNotEmpty:cmisFolder.createdBy forKey:kCMISPropertyCreatedBy];
    [properties alf_setValueIfNotEmpty:cmisFolder.lastModifiedBy forKey:kCMISPropertyModifiedBy];
    
    properties[kCMISPropertyCreationDate] = cmisFolder.creationDate;
    properties[kCMISPropertyModificationDate] = cmisFolder.lastModificationDate;

    return [[AlfrescoFolder alloc] initWithProperties:properties];
}

- (AlfrescoDocument *)documentFromCMISDocument:(CMISDocument *)cmisDocument
                                    properties:(NSMutableDictionary *)properties
{
    if (nil == properties)
    {
        properties = [NSMutableDictionary dictionary];
    }

    NSString *objectType = cmisDocument.objectType;
    if (![objectType isEqualToString:kAlfrescoCMISEmptyString])
    {
        NSString *alfrescoObjectType = [objectType stringByReplacingOccurrencesOfString:kCMISPropertyObjectTypeIdValueDocument withString:kAlfrescoModelTypeContent];
        properties[kCMISPropertyObjectTypeId] = [self propertyValueWithoutPrecursor:alfrescoObjectType];
    }

    [properties alf_setValueIfNotEmpty:cmisDocument.identifier forKey:kCMISPropertyObjectId];
    [properties alf_setValueIfNotEmpty:cmisDocument.name forKey:kCMISPropertyName];
    [properties alf_setValueIfNotEmpty:cmisDocument.createdBy forKey:kCMISPropertyCreatedBy];
    [properties alf_setValueIfNotEmpty:cmisDocument.lastModifiedBy forKey:kCMISPropertyModifiedBy];
    [properties alf_setValueIfNotEmpty:cmisDocument.versionLabel forKey:kCMISPropertyVersionLabel];
    [properties alf_setValueIfNotEmpty:cmisDocument.contentStreamMediaType forKey:kCMISPropertyContentStreamMediaType];

    properties[kCMISPropertyCreationDate] = cmisDocument.creationDate;
    properties[kCMISPropertyModificationDate] = cmisDocument.lastModificationDate;
    properties[kCMISPropertyContentStreamLength] = @(cmisDocument.contentStreamLength);
    properties[kCMISPropertyIsLatestVersion] = @(cmisDocument.isLatestVersion);
    
    return [[AlfrescoDocument alloc] initWithProperties:properties];
}

- (AlfrescoNode *)nodeFromCMISObject:(CMISObject *)cmisObject
{
    NSMutableDictionary *propertyDictionary = [NSMutableDictionary dictionary];
    CMISProperties *properties = cmisObject.properties;
    NSArray *propertyArray = [properties propertyList];
    NSMutableDictionary *alfPropertiesDict = [NSMutableDictionary dictionary];

    for (CMISPropertyData *propData in propertyArray)
    {
        NSMutableDictionary *propertyDictionary = [NSMutableDictionary dictionary];
        NSString *propertyStringType = propData.identifier;
        NSNumber *propTypeIndex = @([self typeForCMISPropertyTypeString:propertyStringType]);
        propertyDictionary[kAlfrescoPropertyType] = propTypeIndex;
        if (propData.values != nil)
        {
            id value = nil;
            
            if (propData.values.count > 1)
            {
                propertyDictionary[kAlfrescoPropertyIsMultiValued] = @YES;
                value = propData.values;
            }
            else 
            {
                propertyDictionary[kAlfrescoPropertyIsMultiValued] = @NO;
                value = propData.firstValue;
            }

            if (value != nil)
            {
                propertyDictionary[kAlfrescoPropertyValue] = value;
                AlfrescoProperty *alfProperty = [[AlfrescoProperty alloc] initWithProperties:propertyDictionary];
                alfPropertiesDict[propData.identifier] = alfProperty;
            }
        }
    }
    
    [propertyDictionary setValue:alfPropertiesDict forKey:kAlfrescoNodeProperties];
    
    AlfrescoNode *node = nil;
    if ([cmisObject isKindOfClass:[CMISFolder class]])
    {
        if ([cmisObject isKindOfClass:[AlfrescoCMISFolder class]])
        {
            AlfrescoCMISFolder *folder = (AlfrescoCMISFolder *)cmisObject;
            NSMutableArray *strippedAspectTypes = [NSMutableArray array];
            for (NSString * type in folder.aspectTypes)
            {
                NSString *correctedString = [self propertyValueWithoutPrecursor:type];
                [strippedAspectTypes addObject:correctedString];
            }
            propertyDictionary[kAlfrescoNodeAspects] = strippedAspectTypes;
            
            [propertyDictionary alf_setValueIfNotEmpty:[folder.properties propertyValueForId:kAlfrescoModelPropertyTitle] forKey:kAlfrescoModelPropertyTitle];
            [propertyDictionary alf_setValueIfNotEmpty:[folder.properties propertyValueForId:kAlfrescoModelPropertyDescription] forKey:kAlfrescoModelPropertyDescription];
        }
        
        node = [self folderFromCMISFolder:(CMISFolder *)cmisObject properties:propertyDictionary];
    }
    else if ([cmisObject isKindOfClass:[CMISDocument class]])
    {
        if ([cmisObject isKindOfClass:[AlfrescoCMISDocument class]])
        {
            AlfrescoCMISDocument *document = (AlfrescoCMISDocument *)cmisObject;
            NSMutableArray *strippedAspectTypes = [NSMutableArray array];
            for (NSString * type in document.aspectTypes)
            {
                NSString *correctedString = [self propertyValueWithoutPrecursor:type];
                [strippedAspectTypes addObject:correctedString];
            }
            propertyDictionary[kAlfrescoNodeAspects] = strippedAspectTypes;

            [propertyDictionary alf_setValueIfNotEmpty:[document.properties propertyValueForId:kAlfrescoModelPropertyTitle] forKey:kAlfrescoModelPropertyTitle];
            [propertyDictionary alf_setValueIfNotEmpty:[document.properties propertyValueForId:kAlfrescoModelPropertyDescription] forKey:kAlfrescoModelPropertyDescription];
        }
        
        node = [self documentFromCMISDocument:(CMISDocument *)cmisObject properties:propertyDictionary];
    }
    
    if (nil != node)
    {
        CMISAllowableActions *allowableActions = cmisObject.allowableActions;
        NSSet *actionSet = [allowableActions allowableActionTypesSet];
        
        AlfrescoPermissions *permissions = [[AlfrescoPermissions alloc] initWithPermissions:actionSet];
        objc_setAssociatedObject(node, &kAlfrescoPermissionsObjectKey, permissions, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return node;
}

- (AlfrescoNode *)nodeFromCMISObjectData:(CMISObjectData *)cmisObjectData
{
    CMISSession *cmisSession = [self.session objectForParameter:kAlfrescoSessionKeyCmisSession];
    CMISObject *cmisObject = [cmisSession.objectConverter convertObjectInternal:cmisObjectData];
    return [self nodeFromCMISObject:cmisObject];
}

- (AlfrescoNode *)nodeFromCMISQueryResult:(CMISQueryResult *)cmisQueryResult
{
    CMISSession *cmisSession = [self.session objectForParameter:kAlfrescoSessionKeyCmisSession];
    CMISObjectData *data = [[CMISObjectData alloc] init];
    data.identifier = [[cmisQueryResult propertyForId:kCMISPropertyObjectId] firstValue];
    data.properties = cmisQueryResult.properties;
    data.allowableActions = cmisQueryResult.allowableActions;
    
    // determine the base type of the object
    data.baseType = CMISBaseTypeDocument;
    NSString *baseTypeId = [[cmisQueryResult propertyForId:kCMISPropertyBaseTypeId] firstValue];
    if ([baseTypeId isEqualToString:kCMISPropertyObjectTypeIdValueFolder])
    {
        data.baseType = CMISBaseTypeFolder;
    }
    
    CMISObject *cmisObject = [cmisSession.objectConverter convertObjectInternal:data];
    return [self nodeFromCMISObject:cmisObject];
}

- (AlfrescoDocumentTypeDefinition *)documentTypeDefinitionFromCMISTypeDefinition:(CMISTypeDefinition *)cmisTypeDefinition
{
    return (AlfrescoDocumentTypeDefinition *)[self modelDefinitionFromCMISTypeDefinition:cmisTypeDefinition];
}

- (AlfrescoFolderTypeDefinition *)folderTypeDefinitionFromCMISTypeDefinition:(CMISTypeDefinition *)cmisTypeDefinition
{
    return (AlfrescoFolderTypeDefinition *)[self modelDefinitionFromCMISTypeDefinition:cmisTypeDefinition];
}

- (AlfrescoAspectDefinition *)aspectDefinitionFromCMISTypeDefinition:(CMISTypeDefinition *)cmisTypeDefinition
{
    return (AlfrescoAspectDefinition *)[self modelDefinitionFromCMISTypeDefinition:cmisTypeDefinition];
}

- (AlfrescoTaskTypeDefinition *)taskTypeDefinitionFromCMISTypeDefinition:(CMISTypeDefinition *)cmisTypeDefinition
{
    return (AlfrescoTaskTypeDefinition *)[self modelDefinitionFromCMISTypeDefinition:cmisTypeDefinition];
}

#pragma mark internal methods

- (AlfrescoPropertyType)typeForCMISPropertyTypeString:(NSString *)type
{
    if ([[type lowercaseString] hasSuffix:kAlfrescoCMISPropertyTypeInt])
    {
        return AlfrescoPropertyTypeInteger;
    }
    else if ([[type lowercaseString] hasSuffix:kAlfrescoCMISPropertyTypeBoolean])
    {
        return AlfrescoPropertyTypeBoolean;
    }
    else if ([[type lowercaseString] hasSuffix:kAlfrescoCMISPropertyTypeDatetime])
    {
        return AlfrescoPropertyTypeDateTime;
    }
    else if ([[type lowercaseString] hasSuffix:kAlfrescoCMISPropertyTypeDecimal])
    {
        return AlfrescoPropertyTypeDecimal;
    }
    else if ([[type lowercaseString] hasSuffix:kAlfrescoCMISPropertyTypeId])
    {
        return AlfrescoPropertyTypeId;
    }
    return AlfrescoPropertyTypeString;
}

- (AlfrescoPropertyType)typeForCMISPropertyType:(CMISPropertyType)type
{
    if (type == CMISPropertyTypeInteger)
    {
        return AlfrescoPropertyTypeInteger;
    }
    else if (type == CMISPropertyTypeBoolean)
    {
        return AlfrescoPropertyTypeBoolean;
    }
    else if (type == CMISPropertyTypeDateTime)
    {
        return AlfrescoPropertyTypeDateTime;
    }
    else if (type == CMISPropertyTypeDecimal)
    {
        return AlfrescoPropertyTypeDecimal;
    }
    else if (type == CMISPropertyTypeId)
    {
        return AlfrescoPropertyTypeId;
    }
    return AlfrescoPropertyTypeString;
}

- (NSString *)propertyValueWithoutPrecursor:(NSString *)value
{
    if ([value hasPrefix:kAlfrescoCMISAspectPrefix])
    {
        return [value stringByReplacingOccurrencesOfString:kAlfrescoCMISAspectPrefix withString:@""];
    }
    else if([value hasPrefix:kAlfrescoCMISDocumentTypePrefix])
    {
        return [value stringByReplacingOccurrencesOfString:kAlfrescoCMISDocumentTypePrefix withString:@""];
    }
    else if ([value hasPrefix:kAlfrescoCMISFolderTypePrefix])
    {
        return [value stringByReplacingOccurrencesOfString:kAlfrescoCMISFolderTypePrefix withString:@""];
    }
    return value;
}

- (AlfrescoModelDefinition *)modelDefinitionFromCMISTypeDefinition:(CMISTypeDefinition *)cmisTypeDefinition
{
    // build dictionary to create an AlfrescoNodeTypeDefinition instance
    NSMutableDictionary *modelDefinitionProperties = [NSMutableDictionary dictionary];
    if (cmisTypeDefinition.displayName != nil)
    {
        modelDefinitionProperties[kAlfrescoModelDefinitionPropertyTitle] = cmisTypeDefinition.displayName;
    }
    if (cmisTypeDefinition.summary != nil)
    {
        modelDefinitionProperties[kAlfrescoModelDefinitionPropertySummary] = cmisTypeDefinition.summary;
    }
    
    // build dictionary of property definitions
    NSMutableDictionary *propertyDefinitions = [NSMutableDictionary dictionary];
    for (NSString *cmisPropertyName in [cmisTypeDefinition.propertyDefinitions allKeys])
    {
        CMISPropertyDefinition *cmisPropertyDefinition = [cmisTypeDefinition propertyDefinitionForId:cmisPropertyName];
        
        // convert and store the property definition
        propertyDefinitions[cmisPropertyDefinition.identifier] = [self propertyDefinitionFromCMISPropertyDefinition:cmisPropertyDefinition];
    }
    
    // store property definitions
    modelDefinitionProperties[kAlfrescoModelDefinitionPropertyPropertyDefinitions] = propertyDefinitions;
    
    // store any mandatory aspects defined for the type
    if (cmisTypeDefinition.extensions != nil && cmisTypeDefinition.extensions.count == 1)
    {
        // check the extension data is for mandatory aspects
        CMISExtensionElement *mandatoryAspectsData = cmisTypeDefinition.extensions[0];
        if ([mandatoryAspectsData.name isEqualToString:kAlfrescoCMISMandatoryAspects] &&
            [mandatoryAspectsData.namespaceUri isEqualToString:kAlfrescoCMISNamespace])
        {
            // iterate around the children to get individual aspect entries.
            NSMutableArray *mandatoryAspects = [NSMutableArray arrayWithCapacity:mandatoryAspectsData.children.count];
            for (CMISExtensionElement *mandatoryAspectData in mandatoryAspectsData.children)
            {
                [mandatoryAspects addObject:[self propertyValueWithoutPrecursor:mandatoryAspectData.value]];
            }
            
            // set the mandatory aspects array
            modelDefinitionProperties[kAlfrescoNodeTypeDefinitionPropertyMandatoryAspects] = mandatoryAspects;
        }
    }
    
    // determine which subclass instance to create depending on the baseId
    AlfrescoModelDefinition *modelDefinition = nil;
    if (cmisTypeDefinition.baseTypeId == CMISBaseTypeDocument)
    {
        if ([cmisTypeDefinition.identifier isEqualToString:kCMISPropertyObjectTypeIdValueDocument])
        {
            modelDefinitionProperties[kAlfrescoModelDefinitionPropertyName] = kAlfrescoModelTypeContent;
        }
        else
        {
            modelDefinitionProperties[kAlfrescoModelDefinitionPropertyName] = [self propertyValueWithoutPrecursor:cmisTypeDefinition.identifier];
        }
        
        if (cmisTypeDefinition.parentTypeId != nil)
        {
            if ([cmisTypeDefinition.parentTypeId isEqualToString:kCMISPropertyObjectTypeIdValueDocument])
            {
                modelDefinitionProperties[kAlfrescoModelDefinitionPropertyParent] = kAlfrescoModelTypeContent;
            }
            else
            {
                modelDefinitionProperties[kAlfrescoModelDefinitionPropertyParent] = [self propertyValueWithoutPrecursor:cmisTypeDefinition.parentTypeId];
            }
        }
        
        modelDefinition = [[AlfrescoDocumentTypeDefinition alloc] initWithDictionary:modelDefinitionProperties];
    }
    else if (cmisTypeDefinition.baseTypeId == CMISBaseTypeFolder)
    {
        if ([cmisTypeDefinition.identifier isEqualToString:kCMISPropertyObjectTypeIdValueFolder])
        {
            modelDefinitionProperties[kAlfrescoModelDefinitionPropertyName] = kAlfrescoModelTypeFolder;
        }
        else
        {
            modelDefinitionProperties[kAlfrescoModelDefinitionPropertyName] = [self propertyValueWithoutPrecursor:cmisTypeDefinition.identifier];
        }
        
        if (cmisTypeDefinition.parentTypeId != nil)
        {
            if ([cmisTypeDefinition.parentTypeId isEqualToString:kCMISPropertyObjectTypeIdValueFolder])
            {
                modelDefinitionProperties[kAlfrescoModelDefinitionPropertyParent] = kAlfrescoModelTypeFolder;
            }
            else
            {
                modelDefinitionProperties[kAlfrescoModelDefinitionPropertyParent] = [self propertyValueWithoutPrecursor:cmisTypeDefinition.parentTypeId];
            }
        }
        
        modelDefinition = [[AlfrescoFolderTypeDefinition alloc] initWithDictionary:modelDefinitionProperties];
    }
    else
    {
        // if it's not a document or folder, presume it's an aspect
        modelDefinitionProperties[kAlfrescoModelDefinitionPropertyName] = [self propertyValueWithoutPrecursor:cmisTypeDefinition.identifier];
        
        // TODO: Determine if an aspect has a parent, for now, presume it doesn't
        
        modelDefinition = [[AlfrescoAspectDefinition alloc] initWithDictionary:modelDefinitionProperties];
    }
    
    return modelDefinition;
}

- (AlfrescoPropertyDefinition *)propertyDefinitionFromCMISPropertyDefinition:(CMISPropertyDefinition *)cmisPropertyDefinition
{
    // build dictionary to create an AlfrescoPropertyDefinition instance
    // setup basic properties
    NSMutableDictionary *propertyDefinitonProperties = [NSMutableDictionary dictionary];
    propertyDefinitonProperties[kAlfrescoPropertyDefinitionPropertyName] = cmisPropertyDefinition.identifier;
    if (cmisPropertyDefinition.displayName != nil)
    {
        propertyDefinitonProperties[kAlfrescoPropertyDefinitionPropertyTitle] = cmisPropertyDefinition.displayName;
    }
    if (cmisPropertyDefinition.summary != nil)
    {
        propertyDefinitonProperties[kAlfrescoPropertyDefinitionPropertySummary] = cmisPropertyDefinition.summary;
    }
    
    // determine property type
    AlfrescoPropertyType propertyType = [self typeForCMISPropertyType:cmisPropertyDefinition.propertyType];
    propertyDefinitonProperties[kAlfrescoPropertyDefinitionPropertyType] = @(propertyType);
    
    // setup flag properties
    propertyDefinitonProperties[kAlfrescoPropertyDefinitionPropertyIsRequired] = @(cmisPropertyDefinition.isRequired);
    
    if (cmisPropertyDefinition.updatability == CMISUpdatabilityReadWrite)
    {
        propertyDefinitonProperties[kAlfrescoPropertyDefinitionPropertyIsReadOnly] = @(NO);
    }
    else if (cmisPropertyDefinition.updatability == CMISUpdatabilityReadOnly)
    {
        propertyDefinitonProperties[kAlfrescoPropertyDefinitionPropertyIsReadOnly] = @(YES);
    }
    
    if (cmisPropertyDefinition.cardinality == CMISCardinalitySingle)
    {
        propertyDefinitonProperties[kAlfrescoPropertyDefinitionPropertyIsMultiValued] = @(NO);
        
        // for single value properties store the first default value
        if (cmisPropertyDefinition.defaultValues != nil && cmisPropertyDefinition.defaultValues.count > 0)
        {
            propertyDefinitonProperties[kAlfrescoPropertyDefinitionPropertyDefaultValue] = cmisPropertyDefinition.defaultValues[0];
        }
    }
    else if (cmisPropertyDefinition.cardinality == CMISCardinalityMulti)
    {
        propertyDefinitonProperties[kAlfrescoPropertyDefinitionPropertyIsMultiValued] = @(YES);
        
        if (cmisPropertyDefinition.defaultValues != nil)
        {
            propertyDefinitonProperties[kAlfrescoPropertyDefinitionPropertyDefaultValue] = cmisPropertyDefinition.defaultValues;
        }
    }
    
    // setup allowable values
    if (cmisPropertyDefinition.choices != nil && cmisPropertyDefinition.choices.count > 0)
    {
        // generate an array of dictionaries representing the choices
        NSMutableArray *allowableValues = [NSMutableArray array];
        
        for (CMISPropertyChoice *choice in cmisPropertyDefinition.choices)
        {
            NSDictionary *allowableValue = @{choice.displayName: choice.value};
            [allowableValues addObject:allowableValue];
        }
        
        propertyDefinitonProperties[kAlfrescoPropertyDefinitionPropertyAllowableValues] = allowableValues;
    }
    
    // create AlfrescoPropertyDefinition instance
    return [[AlfrescoPropertyDefinition alloc] initWithDictionary:propertyDefinitonProperties];
}

@end
