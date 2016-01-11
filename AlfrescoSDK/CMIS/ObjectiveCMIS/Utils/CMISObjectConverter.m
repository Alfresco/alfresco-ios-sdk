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

#import "CMISObjectConverter.h"
#import "CMISDocument.h"
#import "CMISFolder.h"
#import "CMISTypeDefinition.h"
#import "CMISErrors.h"
#import "CMISPropertyDefinition.h"
#import "CMISSession.h"
#import "CMISDateUtil.h"
#import "CMISConstants.h"
#import "CMISDictionaryUtil.h"

@interface CMISObjectConverter ()
@property (nonatomic, weak) CMISSession *session;
@end

@implementation CMISObjectConverter


- (id)initWithSession:(CMISSession *)session
{
    self = [super init];
    if (self) {
        self.session = session;
    }
    
    return self;
}

- (void)convertObject:(CMISObjectData *)objectData completionBlock:(void (^)(CMISObject *object, NSError *error))completionBlock
{
    CMISObject *object = nil;
    
    if (objectData.baseType == CMISBaseTypeDocument) {
        object = [[CMISDocument alloc] initWithObjectData:objectData session:self.session];
    } else if (objectData.baseType == CMISBaseTypeFolder) {
        object = [[CMISFolder alloc] initWithObjectData:objectData session:self.session];
    }
    
    [object fetchTypeDefinitionWithCompletionBlock:^(NSError *error) {
        completionBlock(object, error);
    }];
}


- (void)internalConvertObject:(NSArray *)objectDatas position:(NSInteger)position completionBlock:(void (^)(NSMutableArray *objects, NSError *error))completionBlock
{
    [self convertObject:[objectDatas objectAtIndex:position]
        completionBlock:^(CMISObject *object, NSError *error) {
            if(error){
                completionBlock(nil, error);
            } else {
                if (position == 0) {
                    NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity:objectDatas.count];
                    [objects addObject:object];
                    completionBlock(objects, error);
                } else {
                    [self internalConvertObject:objectDatas position:(position - 1) completionBlock:^(NSMutableArray *objects, NSError *error) {
                        [objects addObject:object];
                        completionBlock(objects, error);
                    }];
                }
            }
        }];
}


- (void)convertObjects:(NSArray *)objectDatas completionBlock:(void (^)(NSArray *objects, NSError *error))completionBlock
{
    if (objectDatas.count > 0) {
        [self internalConvertObject:objectDatas
                           position:(objectDatas.count - 1) // start recursion with last item
                    completionBlock:^(NSMutableArray *objects, NSError *error) {
                        completionBlock(objects, error);
                    }];
    } else {
        completionBlock([[NSArray alloc] init], nil);
    }
}


- (void)convertProperties:(NSDictionary *)properties 
          forObjectTypeId:(NSString *)objectTypeId 
          completionBlock:(void (^)(CMISProperties *convertedProperties, NSError *error))completionBlock
{
    [self internalNormalConvertProperties:properties objectTypeId:objectTypeId completionBlock:completionBlock];
}


- (void)internalNormalConvertProperties:(NSDictionary *)properties
                         typeDefinition:(CMISTypeDefinition *)typeDefinition
                        completionBlock:(void (^)(CMISProperties *convertedProperties, NSError *error))completionBlock
{
    NSArray *typeDefinitions = nil;
    if (typeDefinition) {
        typeDefinitions = [NSArray arrayWithObject:typeDefinition];
    }
    [self internalNormalConvertProperties:properties typeDefinitions:typeDefinitions completionBlock:completionBlock];
}

- (void)internalNormalConvertProperties:(NSDictionary *)properties
                         typeDefinitions:(NSArray *)typeDefinitions
                        completionBlock:(void (^)(CMISProperties *convertedProperties, NSError *error))completionBlock
{
    CMISProperties *convertedProperties = [[CMISProperties alloc] init];
    for (NSString *propertyId in properties) {
        id propertyValue = [properties objectForKey:propertyId];
        // If the value is already a CMISPropertyData, we don't need to do anything
        if ([propertyValue isKindOfClass:[CMISPropertyData class]]) {
            [convertedProperties addProperty:(CMISPropertyData *)propertyValue];
        } else {
            // Convert to CMISPropertyData based on the string
            CMISPropertyDefinition *propertyDefinition = [self propertyDefinitionFromTypeDefinitions:typeDefinitions propertyId:propertyId];
            
            if (propertyDefinition == nil) {
                NSError *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument
                                                 detailedDescription:[NSString stringWithFormat:@"Invalid property '%@' for this object type", propertyId]];
                completionBlock(nil, error);
                return;
            }
            
            Class expectedType = nil;
            BOOL validType = YES;
            
            if (propertyValue == [NSNull null]) {
                [convertedProperties addProperty:[CMISPropertyData createPropertyForId:propertyId arrayValue:nil type:propertyDefinition.propertyType]];
            } else {
                switch (propertyDefinition.propertyType) {
                    case(CMISPropertyTypeString): {
                        expectedType = [NSString class];
                        if ([propertyValue isKindOfClass:expectedType]) {
                            [convertedProperties addProperty:[CMISPropertyData createPropertyForId:propertyId stringValue:propertyValue]];
                        } else if ([propertyValue isKindOfClass:[NSArray class]]) {
                            for (id propertyValueItemValue in propertyValue) {
                                if (![propertyValueItemValue isKindOfClass:expectedType]) {
                                    validType = NO;
                                    break;
                                }
                            }
                            if (validType) {
                                [convertedProperties addProperty:[CMISPropertyData createPropertyForId:propertyId arrayValue:propertyValue type:propertyDefinition.propertyType]];
                            }
                        } else {
                            validType = NO;
                        }
                        break;
                    }
                    case(CMISPropertyTypeBoolean): {
                        expectedType = [NSNumber class];
                        if ([propertyValue isKindOfClass:expectedType]) {
                            BOOL boolValue = ((NSNumber *) propertyValue).boolValue;
                            [convertedProperties addProperty:[CMISPropertyData createPropertyForId:propertyId boolValue:boolValue]];
                        } else if ([propertyValue isKindOfClass:[NSArray class]]) {
                            for (id propertyValueItemValue in propertyValue) {
                                if (![propertyValueItemValue isKindOfClass:expectedType]) {
                                    validType = NO;
                                    break;
                                }
                            }
                            if (validType) {
                                [convertedProperties addProperty:[CMISPropertyData createPropertyForId:propertyId arrayValue:propertyValue type:propertyDefinition.propertyType]];
                            }
                        } else {
                            validType = NO;
                        }
                        break;
                    }
                    case(CMISPropertyTypeInteger): {
                        expectedType = [NSNumber class];
                        if ([propertyValue isKindOfClass:expectedType]) {
                            NSInteger intValue = ((NSNumber *) propertyValue).integerValue;
                            [convertedProperties addProperty:[CMISPropertyData createPropertyForId:propertyId integerValue:intValue]];
                        } else if ([propertyValue isKindOfClass:[NSArray class]]) {
                            for (id propertyValueItemValue in propertyValue) {
                                if (![propertyValueItemValue isKindOfClass:expectedType]) {
                                    validType = NO;
                                    break;
                                }
                            }
                            if (validType) {
                                [convertedProperties addProperty:[CMISPropertyData createPropertyForId:propertyId arrayValue:propertyValue type:propertyDefinition.propertyType]];
                            }
                        } else {
                            validType = NO;
                        }
                        break;
                    }
                    case(CMISPropertyTypeDecimal): {
                        expectedType = [NSNumber class];
                        if ([propertyValue isKindOfClass:expectedType]) {
                            [convertedProperties addProperty:[CMISPropertyData createPropertyForId:propertyId decimalValue:propertyValue]];
                        } else if ([propertyValue isKindOfClass:[NSArray class]]) {
                            for (id propertyValueItemValue in propertyValue) {
                                if (![propertyValueItemValue isKindOfClass:expectedType]) {
                                    validType = NO;
                                    break;
                                }
                            }
                            if (validType) {
                                [convertedProperties addProperty:[CMISPropertyData createPropertyForId:propertyId arrayValue:propertyValue type:propertyDefinition.propertyType]];
                            }
                        } else {
                            validType = NO;
                        }
                        break;
                    }
                    case(CMISPropertyTypeId): {
                        expectedType = [NSString class];
                        if ([propertyValue isKindOfClass:expectedType]) {
                            [convertedProperties addProperty:[CMISPropertyData createPropertyForId:propertyId idValue:propertyValue]];
                        } else if ([propertyValue isKindOfClass:[NSArray class]]) {
                            for (id propertyValueItemValue in propertyValue) {
                                if (![propertyValueItemValue isKindOfClass:expectedType]) {
                                    validType = NO;
                                    break;
                                }
                            }
                            if (validType) {
                                [convertedProperties addProperty:[CMISPropertyData createPropertyForId:propertyId arrayValue:propertyValue type:propertyDefinition.propertyType]];
                            }
                        } else {
                            validType = NO;
                        }
                        break;
                    }
                    case(CMISPropertyTypeDateTime): {
                        if ([propertyValue isKindOfClass:[NSString class]]) {
                            propertyValue = [CMISDateUtil dateFromString:propertyValue];
                        }
                        expectedType = [NSDate class];
                        if ([propertyValue isKindOfClass:expectedType]) {
                            [convertedProperties addProperty:[CMISPropertyData createPropertyForId:propertyId dateTimeValue:propertyValue]];
                        } else if ([propertyValue isKindOfClass:[NSArray class]]) {
                            for (__strong id propertyValueItemValue in propertyValue) {
                                if ([propertyValueItemValue isKindOfClass:[NSString class]]) {
                                    propertyValueItemValue = [CMISDateUtil dateFromString:propertyValueItemValue];
                                }
                                if (![propertyValueItemValue isKindOfClass:expectedType]) {
                                    validType = NO;
                                    break;
                                }
                            }
                            if (validType) {
                                [convertedProperties addProperty:[CMISPropertyData createPropertyForId:propertyId arrayValue:propertyValue type:propertyDefinition.propertyType]];
                            }
                        } else {
                            validType = NO;
                        }
                        break;
                    }
                    case(CMISPropertyTypeUri): {
                        if ([propertyValue isKindOfClass:[NSString class]]) {
                            propertyValue = [NSURL URLWithString:propertyValue];
                        }
                        expectedType = [NSURL class];
                        if ([propertyValue isKindOfClass:expectedType]) {
                            [convertedProperties addProperty:[CMISPropertyData createPropertyForId:propertyId uriValue:propertyValue]];
                        } else if ([propertyValue isKindOfClass:[NSArray class]]) {
                            for (__strong id propertyValueItemValue in propertyValue) {
                                if ([propertyValueItemValue isKindOfClass:[NSString class]]) {
                                    propertyValueItemValue = [NSURL URLWithString:propertyValueItemValue];
                                }
                                if (![propertyValueItemValue isKindOfClass:expectedType]) {
                                    validType = NO;
                                    break;
                                }
                            }
                            if (validType) {
                                [convertedProperties addProperty:[CMISPropertyData createPropertyForId:propertyId arrayValue:propertyValue type:propertyDefinition.propertyType]];
                            }
                        } else {
                            validType = NO;
                        }
                        break;
                    }
                    case(CMISPropertyTypeHtml): {
                        expectedType = [NSString class];
                        if ([propertyValue isKindOfClass:expectedType]) {
                            [convertedProperties addProperty:[CMISPropertyData createPropertyForId:propertyId htmlValue:propertyValue]];
                        } else if ([propertyValue isKindOfClass:[NSArray class]]) {
                            for (id propertyValueItemValue in propertyValue) {
                                if (![propertyValueItemValue isKindOfClass:expectedType]) {
                                    validType = NO;
                                    break;
                                }
                            }
                            if (validType) {
                                [convertedProperties addProperty:[CMISPropertyData createPropertyForId:propertyId arrayValue:propertyValue type:propertyDefinition.propertyType]];
                            }
                        } else {
                            validType = NO;
                        }
                        break;
                    }
                    default: {
                        NSError *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument
                                                     detailedDescription:[NSString stringWithFormat:@"Unsupported: cannot convert property type %li", (long)propertyDefinition.propertyType]];
                        completionBlock(nil, error);
                        return;
                    }
                }
            }
            
            if (!validType) {
                NSError *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument
                                             detailedDescription:[NSString stringWithFormat:@"Property value for %@ should be of type '%@'", propertyId, expectedType]];
                completionBlock(nil, error);
                return;
            }
        }
    }
    
    completionBlock(convertedProperties, nil);
}

-(CMISPropertyDefinition*)propertyDefinitionFromTypeDefinitions:(NSArray *)typeDefinitions propertyId:(NSString*)propertyId
{
    for (CMISTypeDefinition* typeDefinition in typeDefinitions) {
        CMISPropertyDefinition *propertyDefinition = [typeDefinition propertyDefinitionForId:propertyId];
        
        if (propertyDefinition) {
            return propertyDefinition;
        }
    }
    return nil;
}


- (void)internalNormalConvertProperties:(NSDictionary *)properties
                           objectTypeId:(NSString *)objectTypeId
                        completionBlock:(void (^)(CMISProperties *convertedProperties, NSError *error))completionBlock

{
    // Validate params
    if (!properties) {
        completionBlock(nil, nil);
        return;
    }

    BOOL onlyPropertyData = YES;
    for (id propertyValue in properties.objectEnumerator) {
        if (![propertyValue isKindOfClass:[CMISPropertyData class]]) {
            if ([propertyValue isKindOfClass:[NSArray class]]) {
                for (id propertyValueItemValue in propertyValue) {
                    if (![propertyValueItemValue isKindOfClass:[CMISPropertyData class]]) {
                        onlyPropertyData = NO;
                        break;
                    }
                }
            } else {
                onlyPropertyData = NO;
            }
            break;
        }
    }
    
    // Convert properties
    if (onlyPropertyData) {
        [self internalNormalConvertProperties:properties
                               typeDefinition:nil // not needed because all properties are of type CMISPropertyData
                              completionBlock:completionBlock];
        
    } else {
        
        //get secondary object type definitions - if available
        NSString *propertyId = kCMISPropertySecondaryObjectTypeIds;
        id secondaryObjectTypeIds = [properties valueForKey:propertyId];
        if(secondaryObjectTypeIds) {
            Class expectedType = nil;
            BOOL validType = YES;
            
            //verify types
            expectedType = [NSArray class];
            if([secondaryObjectTypeIds isKindOfClass:expectedType]){
                expectedType = [NSString class];
                for (id secondaryObjectTypeId in secondaryObjectTypeIds) {
                    propertyId = secondaryObjectTypeId;
                    if(![secondaryObjectTypeId isKindOfClass:expectedType]){
                        validType = NO;
                        break;
                    }
                }
            } else {
                validType = NO;
            }
            
            if (!validType) {
                NSError *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument
                                                 detailedDescription:[NSString stringWithFormat:@"Property value for %@ should be of type '%@'", propertyId, expectedType]];
                completionBlock(nil, error);
                return;
            }
            
            NSMutableArray *objectTypeIds = [NSMutableArray arrayWithObject:objectTypeId];
            [objectTypeIds addObjectsFromArray:secondaryObjectTypeIds];
            [self retrieveTypeDefinitions:objectTypeIds
                          completionBlock:^(NSArray *typeDefinitions, NSError *error) {
                              if (error) {
                                  completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeRuntime]);
                              } else {
                                  [self internalNormalConvertProperties:properties
                                                         typeDefinitions:typeDefinitions
                                                        completionBlock:completionBlock];
                              }
            }];
        } else {
            [self.session retrieveTypeDefinition:objectTypeId
                                 completionBlock:^(CMISTypeDefinition *typeDefinition, NSError *error) {
                                     if (error) {
                                         completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeRuntime]);
                                     } else {
                                         [self internalNormalConvertProperties:properties
                                                                typeDefinition:typeDefinition
                                                               completionBlock:completionBlock];
                                     }
                                 }];
        }
    }
}

- (void)retrieveTypeDefinitions:(NSArray *)objectTypeIds position:(NSInteger)position completionBlock:(void (^)(NSMutableArray *typeDefinitions, NSError *error))completionBlock
{
    [self.session retrieveTypeDefinition:[objectTypeIds objectAtIndex:position]
                         completionBlock:^(CMISTypeDefinition *typeDefinition, NSError *error) {
            if(error){
                completionBlock(nil, error);
            } else {
                if (position == 0) {
                    NSMutableArray *typeDefinitions = [[NSMutableArray alloc] initWithCapacity:objectTypeIds.count];
                    [typeDefinitions addObject:typeDefinition];
                    completionBlock(typeDefinitions, error);
                } else {
                    [self retrieveTypeDefinitions:objectTypeIds position:(position - 1) completionBlock:^(NSMutableArray *typeDefinitions, NSError *error) {
                        [typeDefinitions addObject:typeDefinition];
                        completionBlock(typeDefinitions, error);
                    }];
                }
            }
        }];
}

- (void)retrieveTypeDefinitions:(NSArray *)objectTypeIds completionBlock:(void (^)(NSArray *typeDefinitions, NSError *error))completionBlock
{
    if (objectTypeIds.count > 0) {
        [self retrieveTypeDefinitions:objectTypeIds
                           position:(objectTypeIds.count - 1) // start recursion with last item
                    completionBlock:^(NSMutableArray *typeDefinitions, NSError *error) {
                        completionBlock(typeDefinitions, error);
                    }];
    } else {
        completionBlock([[NSArray alloc] init], nil);
    }
}

+ (NSArray *)convertExtensions:(NSDictionary *)source cmisKeys:(NSSet *)cmisKeys
{
    if (!source) {
        return nil;
    }
    
    NSMutableArray *extensions = nil; // array of CMISExtensionElement's
    
    for (NSString *key in source.keyEnumerator) {
        if ([cmisKeys containsObject:key]) {
            continue;
        }
        
        if (!extensions) {
            extensions = [[NSMutableArray alloc] init];
        }
        
        id value = [source cmis_objectForKeyNotNull:key];
        if ([value isKindOfClass:NSDictionary.class]) {
            [extensions addObject:[[CMISExtensionElement alloc] initNodeWithName:key namespaceUri:nil attributes:nil children:[CMISObjectConverter convertExtension:value]]];
        } else if ([value isKindOfClass:NSArray.class]) {
            [extensions addObjectsFromArray:[CMISObjectConverter convertExtension: key fromArray:value]];
        } else {
            [extensions addObject:[[CMISExtensionElement alloc] initLeafWithName:key namespaceUri:nil attributes:nil value:value]];
        }
    }
    return extensions;
}

+ (NSArray *)convertExtension:(NSDictionary *)dictionary
{
    if (!dictionary) {
        return nil;
    }
    
    NSMutableArray *extensions = [[NSMutableArray alloc] init]; // array of CMISExtensionElement's
    
    for (NSString *key in dictionary.keyEnumerator) {
        id value = [dictionary cmis_objectForKeyNotNull:key];
        if ([value isKindOfClass:NSDictionary.class]) {
            [extensions addObject:[[CMISExtensionElement alloc] initNodeWithName:key namespaceUri:nil attributes:nil children:[CMISObjectConverter convertExtension:value]]];
        } else if ([value isKindOfClass:NSArray.class]) {
            [extensions addObjectsFromArray:[CMISObjectConverter convertExtension: key fromArray:value]];
        } else {
            [extensions addObject:[[CMISExtensionElement alloc] initLeafWithName:key namespaceUri:nil attributes:nil value:value]];
        }
    }
    
    return extensions;
}

+ (NSArray *)convertExtension:(NSString *)key fromArray:(NSArray *)array
{
    if (!array) {
        return nil;
    }
    
    NSMutableArray *extensions = [[NSMutableArray alloc] init]; // array of CMISExtensionElement's
    
    for (id element in array) {
        if ([element isKindOfClass:NSDictionary.class]) {
            [extensions addObject:[[CMISExtensionElement alloc] initNodeWithName:key namespaceUri:nil attributes:nil children:[CMISObjectConverter convertExtension:element]]];
        } else if ([element isKindOfClass:NSArray.class]) {
            [extensions addObjectsFromArray:[CMISObjectConverter convertExtension: key fromArray:element]];
        } else {
            [extensions addObject:[[CMISExtensionElement alloc] initLeafWithName:key namespaceUri:nil attributes:nil value:element]];
        }
    }
    
    return extensions;
}


@end
