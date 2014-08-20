/*
 ******************************************************************************
 * Copyright (C) 2005-2014 Alfresco Software Limited.
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
 *****************************************************************************
 */

//
// AlfrescoCMISObjectConverter 
//
#import "AlfrescoCMISObjectConverter.h"
#import "CMISConstants.h"
#import "CMISErrors.h"
#import "CMISSession.h"
#import "CMISTypeDefinition.h"
#import "CMISPropertyDefinition.h"
#import "AlfrescoCMISDocument.h"
#import "AlfrescoCMISFolder.h"
#import "CMISDateUtil.h"
#import "AlfrescoErrors.h"
#import "AlfrescoConstants.h"
#import "AlfrescoInternalConstants.h"
#import "CMISAtomPubConstants.h"

@interface AlfrescoCMISObjectConverter ()
- (void)retrieveAspectTypeDefinitionsFromObjectID:(NSString *)objectID completionBlock:(AlfrescoArrayCompletionBlock)completionBlock;
- (CMISTypeDefinition *)mainTypeFromArray:(NSArray *)typeArray;
- (NSArray *)aspectTypesFromTypeArray:(NSArray *)typeArray;
@property (nonatomic, weak) CMISSession *session;

@end


@implementation AlfrescoCMISObjectConverter

- (id)initWithSession:(CMISSession *)session
{
    self = [super init];
    if (self)
    {
        self.session = session;
    }
    return self;
}

- (CMISObject *)convertObjectInternal:(CMISObjectData *)objectData
{
    CMISObject *object = nil;

    if (objectData.baseType == CMISBaseTypeDocument)
    {
        object = [[AlfrescoCMISDocument alloc] initWithObjectData:objectData session:self.session];
    }
    else if (objectData.baseType == CMISBaseTypeFolder)
    {
        object = [[AlfrescoCMISFolder alloc] initWithObjectData:objectData session:self.session];
    }

    return object;
}

- (void)convertObject:(CMISObjectData *)objectData completionBlock:(void (^)(CMISObject *, NSError *))completionBlock
{
    if (completionBlock)
    {
        completionBlock([self convertObjectInternal:objectData], nil);
    }
}



- (void)convertProperties:(NSDictionary *)properties forObjectTypeId:(NSString *)objectTypeId completionBlock:(void (^)(CMISProperties *, NSError *))completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:properties argumentName:@"properties"];
    NSObject *objectTypeIdValue = properties[kCMISPropertyObjectTypeId];
    NSString *objectTypeIdString = nil;
    
    if ([objectTypeIdValue isKindOfClass:[NSString class]])
    {
        objectTypeIdString = (NSString *)objectTypeIdValue;
    }
    else if ([objectTypeIdValue isKindOfClass:[CMISPropertyData class]])
    {
        objectTypeIdString = [(CMISPropertyData *)objectTypeIdValue firstValue];
    }
    else if (objectTypeId)
    {
        objectTypeIdString = objectTypeId;
    }
    
    if (nil == objectTypeIdString)
    {
        completionBlock( nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument detailedDescription:@"Type property must be set"]);
        return;
    }
    
    [self retrieveAspectTypeDefinitionsFromObjectID:objectTypeIdString completionBlock:^(NSArray *returnedTypes, NSError *error){
        if (0 == returnedTypes.count)
        {
            completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeRuntime]);
            return;
        }
        else
        {
            CMISTypeDefinition *mainTypeDefinition = [self mainTypeFromArray:returnedTypes];
            NSArray *aspectTypes = [self aspectTypesFromTypeArray:returnedTypes];
            // Split type properties from aspect properties
            NSMutableDictionary *typeProperties = [NSMutableDictionary dictionary];
            NSMutableDictionary *aspectProperties = [NSMutableDictionary dictionary];
            NSMutableDictionary *aspectPropertyDefinitions = [NSMutableDictionary dictionary];
            
            // Loop over all provided properties and put them in the right dictionary
            for (NSString *propertyId in properties)
            {
                id propertyValue = properties[propertyId];
                
                if ([propertyId isEqualToString:kCMISPropertyObjectTypeId])
                {
                    [typeProperties setValue:propertyValue forKey:kCMISPropertyObjectTypeId];
                }
                else if ([mainTypeDefinition propertyDefinitionForId:propertyId])
                {
                    typeProperties[propertyId] = propertyValue;
                }
                else
                {
                    aspectProperties[propertyId] = propertyValue;
                    
                    // Find matching property definition
                    BOOL matchingPropertyDefinitionFound = NO;
                    uint index = 0;
                    while (!matchingPropertyDefinitionFound && index < aspectTypes.count)
                    {
                        CMISTypeDefinition *aspectType = aspectTypes[index];
                        if (aspectType.propertyDefinitions != nil)
                        {
                            CMISPropertyDefinition *aspectPropertyDefinition = [aspectType propertyDefinitionForId:propertyId];
                            if (aspectPropertyDefinition != nil)
                            {
                                aspectPropertyDefinitions[propertyId] = aspectPropertyDefinition;
                                matchingPropertyDefinitionFound = YES;
                            }
                        }
                        index++;
                    }
                    // If no match was found, throw an exception
                    if (!matchingPropertyDefinitionFound)
                    {
                        NSError *typeError = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument
                                                         detailedDescription:[NSString stringWithFormat:@"Property '%@' is neither an object type property nor an aspect property", propertyId]];
                        completionBlock(nil, typeError);
                        return;
                    }
                }
            }
            // Create an array to hold all converted stuff
            NSMutableArray *alfrescoExtensions = [NSMutableArray array];
            
            // Convert the aspect types stuff to CMIS extensions
            for (CMISTypeDefinition *aspectType in aspectTypes)
            {
                CMISExtensionElement *extensionElement = [[CMISExtensionElement alloc] initLeafWithName:kAlfrescoCMISAspectsToAdd
                                                                                           namespaceUri:kAlfrescoCMISNamespace
                                                                                             attributes:nil
                                                                                                  value:aspectType.identifier];
                [alfrescoExtensions addObject:extensionElement];
            }

            // Convert the aspect properties
            if (aspectProperties.count > 0)
            {
                NSMutableArray *propertyExtensions = [NSMutableArray array];
                
                for (NSString *propertyId in aspectProperties)
                {
                    CMISPropertyDefinition *aspectPropertyDefinition = aspectPropertyDefinitions[propertyId];
                    if (aspectPropertyDefinition == nil)
                    {
                        NSError *typeError = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument
                                                         detailedDescription:[NSString stringWithFormat:@"Unknown aspect property: %@", propertyId]];
                        completionBlock(nil, typeError);
                        return;
                    }
                    
                    
                    NSString *name = nil;
                    switch (aspectPropertyDefinition.propertyType)
                    {
                        case CMISPropertyTypeBoolean:
                            name = kCMISAtomEntryPropertyBoolean;
                            break;
                        case CMISPropertyTypeDateTime:
                            name = kCMISAtomEntryPropertyDateTime;
                            break;
                        case CMISPropertyTypeInteger:
                            name = kCMISAtomEntryPropertyInteger;
                            break;
                        case CMISPropertyTypeDecimal:
                            name = kCMISAtomEntryPropertyDecimal;
                            break;
                        case CMISPropertyTypeId:
                            name = kCMISAtomEntryPropertyId;
                            break;
                        case CMISPropertyTypeHtml:
                            name = kCMISAtomEntryPropertyHtml;
                            break;
                        case CMISPropertyTypeUri:
                            name = kCMISAtomEntryPropertyUri;
                            break;
                        default:
                            name = kCMISAtomEntryPropertyString;
                            break;
                    }
                    
                    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
                    attributes[kCMISAtomEntryPropertyDefId] = aspectPropertyDefinition.identifier;
                    
                    NSMutableArray *propertyValues = [NSMutableArray array];
                    id value = aspectProperties[propertyId];
                    if (value != nil)
                    {
                        NSString *stringValue = nil;
                        if ([value isKindOfClass:[NSString class]])
                        {
                            stringValue = value;
                        }
                        else if ([value isKindOfClass:[CMISPropertyData class]])
                        {
                            stringValue = ((CMISPropertyData *) value).firstValue;
                        }
                        else
                        {
                            switch (aspectPropertyDefinition.propertyType)
                            {
                                case CMISPropertyTypeBoolean:
                                    stringValue = ((NSNumber *)value).boolValue ? @"true" : @"false";
                                    break;
                                case CMISPropertyTypeDateTime:
                                    stringValue = [self stringFromDate:((NSDate *)value)];
                                    break;
                                case CMISPropertyTypeInteger:
                                    stringValue = [NSString stringWithFormat:@"%d", ((NSNumber *)value).intValue];
                                    break;
                                case CMISPropertyTypeDecimal:
                                    stringValue = [NSString stringWithFormat:@"%f", ((NSNumber *)value).floatValue];
                                    break;
                                default:
                                    stringValue = value;
                                    break;
                            }
                        }
                        
                        CMISExtensionElement *valueExtensionElement = [[CMISExtensionElement alloc] initLeafWithName:kCMISAtomEntryValue
                                                                                                        namespaceUri:kCMISNamespaceCmis
                                                                                                          attributes:nil
                                                                                                               value:stringValue];
                        [propertyValues addObject:valueExtensionElement];
                    }
                    
                    
                    CMISExtensionElement *aspectPropertyExtensionElement = [[CMISExtensionElement alloc] initNodeWithName:name
                                                                                                             namespaceUri:kCMISNamespaceCmis
                                                                                                               attributes:attributes
                                                                                                                 children:propertyValues];
                    [propertyExtensions addObject:aspectPropertyExtensionElement];
                }
                
                [alfrescoExtensions addObject: [[CMISExtensionElement alloc] initNodeWithName:kCMISCoreProperties
                                                                                 namespaceUri:kAlfrescoCMISNamespace
                                                                                   attributes:nil
                                                                                     children:propertyExtensions]];
            }
            // Cmis doesn't understand aspects, so we must replace the objectTypeId if needed
            if (typeProperties[kCMISPropertyObjectTypeId] != nil)
            {
                [typeProperties setValue:mainTypeDefinition.identifier forKey:kCMISPropertyObjectTypeId];
            }

            [super convertProperties:typeProperties forObjectTypeId:mainTypeDefinition.identifier completionBlock:^(CMISProperties *result, NSError *error){
                if (nil == result)
                {
                    completionBlock(nil, error);
                }
                else
                {
                    if (alfrescoExtensions.count > 0)
                    {
                        result.extensions = @[[[CMISExtensionElement alloc] initNodeWithName:kAlfrescoCMISSetAspects
                                                                                namespaceUri:kAlfrescoCMISNamespace
                                                                                  attributes:nil
                                                                                    children:alfrescoExtensions]];
                    }
                    completionBlock(result, nil);
                }
            }];
        }
    }];
}

- (CMISTypeDefinition *)mainTypeFromArray:(NSArray *)typeArray
{
    CMISTypeDefinition *typeDefinition = nil;
    for (CMISTypeDefinition * type in typeArray)
    {
        if ([type.identifier hasPrefix:kAlfrescoCMISModelPrefix] ||
            [type.identifier hasPrefix:kAlfrescoCMISDocumentTypePrefix] ||
            [type.identifier hasPrefix:kAlfrescoCMISFolderTypePrefix])
        {
            typeDefinition = type;
            break;
        }
    }
    return typeDefinition;
}

- (NSArray *)aspectTypesFromTypeArray:(NSArray *)typeArray
{
    NSMutableArray *aspects = [NSMutableArray array];
    for (CMISTypeDefinition * type in typeArray)
    {
        if (![type.identifier hasPrefix:kAlfrescoCMISModelPrefix] &&
            ![type.identifier hasPrefix:kAlfrescoCMISDocumentTypePrefix] &&
            ![type.identifier hasPrefix:kAlfrescoCMISFolderTypePrefix])
        {
            [aspects addObject:type];
        }
    }    
    return aspects;
}



- (void)retrieveAspectTypeDefinitionsFromObjectID:(NSString *)objectID completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    NSArray *components = [objectID componentsSeparatedByString:@","];
    __block NSMutableArray *aspects = [NSMutableArray array];
    
    if (1 == components.count)
    {
        NSString *trimmedString = [objectID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self.session.binding.repositoryService retrieveTypeDefinition:trimmedString completionBlock:^(CMISTypeDefinition *typeDefinition, NSError *error){
            if (nil == typeDefinition)
            {
                completionBlock(nil, error);
            }
            else
            {
                [aspects addObject:typeDefinition];
                completionBlock(aspects, nil);
            }
        }];
    }
    else
    {
        __block int index = 1;
        for (NSString *type  in components)
        {
            NSString *trimmedString = [type stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (![trimmedString isEqualToString:@""])
            {
                [self.session.binding.repositoryService retrieveTypeDefinition:trimmedString completionBlock:^(CMISTypeDefinition *typeDefinition, NSError *error){
                    if (nil != typeDefinition)
                    {
                        [aspects addObject:typeDefinition];
                    }
                    if (index == components.count)
                    {
                        completionBlock(aspects , nil);
                    }
                    index = index + 1;
                }];
            }
        }
    }
    
    
}



#pragma mark Helper methods

- (NSString *)stringFromDate:(NSDate *)date
{
    return [CMISDateUtil stringFromDate:date];
}


@end