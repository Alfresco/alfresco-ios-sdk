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

#import "CMISBrowserUtil.h"
#import "CMISConstants.h"
#import "CMISBrowserConstants.h"
#import "CMISRepositoryInfo.h"
#import "CMISPropertyDefinition.h"
#import "CMISRenditionData.h"
#import "CMISDocumentTypeDefinition.h"
#import "CMISFolderTypeDefinition.h"
#import "CMISRelationshipTypeDefinition.h"
#import "CMISItemTypeDefinition.h"
#import "CMISSecondaryTypeDefinition.h"
#import "CMISErrors.h"
#import "CMISDictionaryUtil.h"
#import "CMISRepositoryCapabilities.h"
#import "CMISObjectConverter.h"
#import "CMISAcl.h"
#import "CMISAce.h"
#import "CMISPrincipal.h"
#import "CMISAllowableActions.h"

NSString * const kCMISBrowserMinValueAlfrescoJSONProperty = @"\"minValue\":0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000049,";
NSString * const kCMISBrowserMinValueECMJSONProperty = @"\"minValue\":-179769313486231570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,";

NSString * const kCMISBrowserMaxValueAlfrescoJSONProperty = @"\"maxValue\":179769313486231570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,";
NSString * const kCMISBrowserMaxValueECMJSONProperty = @"\"maxValue\":179769313486231570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,";

@interface NSObject (CMISUtil)

+ (void)performBlock:(void (^)(void))block;

@end

@implementation NSObject (CMISUtil)

+ (void)performBlock:(void (^)(void))block
{
    [NSObject performSelector:@selector(executeBlock:) onThread:[NSThread currentThread] withObject:block waitUntilDone:NO];
}

+ (void)executeBlock:(void (^)(void))block {
    block();
}

@end

@implementation CMISBrowserUtil

+ (NSDictionary *)repositoryInfoDictionaryFromJSONData:(NSData *)jsonData bindingSession:(CMISBindingSession *)bindingSession error:(NSError **)outError
{
    // TODO: error handling i.e. if jsonData is nil, also handle outError being nil
    
    // parse the JSON response
    NSError *serialisationError = nil;
    id jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&serialisationError];
    
    NSMutableDictionary *repositories = nil;
    if (!serialisationError) {
        repositories = [NSMutableDictionary dictionary];
        
        // parse the json into CMISRepositoryInfo objects and store in self.repositories
        NSArray *repos = [jsonDictionary allValues];
        for (NSDictionary *repo in repos) {
            CMISRepositoryInfo *repoInfo = [CMISRepositoryInfo new];
            repoInfo.identifier = [repo cmis_objectForKeyNotNull:kCMISBrowserJSONRepositoryId];
            repoInfo.name = [repo cmis_objectForKeyNotNull:kCMISBrowserJSONRepositoryName];
            repoInfo.summary = [repo cmis_objectForKeyNotNull:kCMISBrowserJSONRepositoryDescription];
            repoInfo.vendorName = [repo cmis_objectForKeyNotNull:kCMISBrowserJSONVendorName];
            repoInfo.productName = [repo cmis_objectForKeyNotNull:kCMISBrowserJSONProductName];
            repoInfo.productVersion = [repo cmis_objectForKeyNotNull:kCMISBrowserJSONProductVersion];
            repoInfo.rootFolderId = [repo cmis_objectForKeyNotNull:kCMISBrowserJSONRootFolderId];
            NSString *repositoryUrl = [repo cmis_objectForKeyNotNull:kCMISBrowserJSONRepositoryUrl];
            NSString *rootFolderUrl = [repo cmis_objectForKeyNotNull:kCMISBrowserJSONRootFolderUrl];
            
            repoInfo.repositoryCapabilities = [CMISBrowserUtil convertRepositoryCapabilities:[repo cmis_objectForKeyNotNull:kCMISBrowserJSONCapabilities]];
            //TOOD aclCapabilities
            repoInfo.latestChangeLogToken = [repo cmis_objectForKeyNotNull:kCMISBrowserJSONLatestChangeLogToken];
            
            repoInfo.cmisVersionSupported = [repo cmis_objectForKeyNotNull:kCMISBrowserJSONCMISVersionSupported];
            repoInfo.thinClientUri = [repo cmis_objectForKeyNotNull:kCMISBrowserJSONThinClientUri];

            //TODO repoInfo.changesIncomplete = [repo cmis_objectForKeyNotNull:kCMISBrowserJSONChangesIncomplete);
            //TODO changesOnType

            repoInfo.principalIdAnonymous = [repo cmis_objectForKeyNotNull:kCMISBrowserJSONPrincipalIdAnonymous];
            repoInfo.principalIdAnyone = [repo cmis_objectForKeyNotNull:kCMISBrowserJSONPrincipalIdAnyone];
            
            //handle extensions
            repoInfo.extensions = [CMISObjectConverter convertExtensions:repo cmisKeys:[CMISBrowserConstants repositoryInfoKeys]];
            
            // store the repo and root folder URLs in the session (when the repoId matches)
            if ([repoInfo.identifier isEqualToString:bindingSession.repositoryId]) {
                [bindingSession setObject:rootFolderUrl forKey:kCMISBrowserBindingSessionKeyRootFolderUrl];
                [bindingSession setObject:repositoryUrl forKey:kCMISBrowserBindingSessionKeyRepositoryUrl];
            }
            
            [repositories setObject:repoInfo forKey:repoInfo.identifier];
        }
    } else {
        if (outError != NULL) *outError = [CMISErrors cmisError:serialisationError cmisErrorCode:kCMISErrorCodeRuntime];
        return nil;
    }

    return repositories;
}

+ (CMISTypeDefinition *)typeDefinitionFromJSONData:(NSData *)jsonData error:(NSError **)outError
{
    // TODO: error handling i.e. if jsonData is nil, also handle outError being nil
    
    // parse the JSON response
    NSError *serialisationError = nil;
    id jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&serialisationError];
    
    // HACK: An Apple bug can cause deserialisation to fail if very small or very large numbers are used.
    // This is usually caused when the web service providing the JSON has used a MIN or MAX value for the data type.
    // If an error occurred attempt to remove the offending data and re-try the deserialisation.
    if (serialisationError)
    {
        // convert to string
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        // remove the minValue and maxValue properties as they are effectively indicating any reasonable value is valid
        jsonString = [jsonString stringByReplacingOccurrencesOfString:kCMISBrowserMinValueAlfrescoJSONProperty withString:@""];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:kCMISBrowserMinValueECMJSONProperty withString:@""];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:kCMISBrowserMaxValueAlfrescoJSONProperty withString:@""];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:kCMISBrowserMaxValueECMJSONProperty withString:@""];
        
        // re-try and JSON parse
        serialisationError = nil;
        jsonDictionary = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&serialisationError];
    }
    
    CMISTypeDefinition *typeDef = nil;
    if (!serialisationError) {
        //TODO check for valid baseTypeId (cmis:document, cmis:folder, cmis:relationship, cmis:policy, [cmis:item, cmis:secondary])
        CMISBaseType baseType = [CMISEnums enumForBaseId:[jsonDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONBaseId]];
        switch (baseType) {
            case CMISBaseTypeDocument: {
                typeDef = [CMISDocumentTypeDefinition new];
                ((CMISDocumentTypeDefinition*)typeDef).contentStreamAllowed = [CMISEnums enumForContentStreamAllowed:
                                                                               [jsonDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONContentStreamAllowed]];
                ((CMISDocumentTypeDefinition*)typeDef).versionable = [jsonDictionary cmis_boolForKey:kCMISBrowserJSONVersionable];
                break;
            }
            case CMISBaseTypeFolder:
                typeDef = [CMISFolderTypeDefinition new];
                break;
                
            case CMISBaseTypeRelationship: {
                typeDef = [CMISRelationshipTypeDefinition new];
                
                id allowedSourceTypes = [jsonDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONAllowedSourceTypes];
                if ([allowedSourceTypes isKindOfClass:NSArray.class]){
                    NSMutableArray *types = [[NSMutableArray alloc] init];
                    for (id type in allowedSourceTypes) {
                        if (type){
                            [types addObject:type];
                        }
                    }
                    ((CMISRelationshipTypeDefinition*)typeDef).allowedSourceTypes = types;
                }
                
                id allowedTargetTypes = [jsonDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONAllowedTargetTypes];
                if ([allowedTargetTypes isKindOfClass:NSArray.class]){
                    NSMutableArray *types = [[NSMutableArray alloc] init];
                    for (id type in allowedTargetTypes) {
                        if (type){
                            [types addObject:type];
                        }
                    }
                    ((CMISRelationshipTypeDefinition*)typeDef).allowedTargetTypes = types;
                }
                break;
            }
            case CMISBaseTypeItem:
                typeDef = [CMISItemTypeDefinition new];
                break;
            case CMISBaseTypeSecondary:
                typeDef = [CMISSecondaryTypeDefinition new];
                break;
            default:
                if (outError != NULL) *outError = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument detailedDescription:[NSString stringWithFormat:@"Type '%@' does not match a base type!", [jsonDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONBaseId]]];
                return nil;
        }

        typeDef.baseTypeId = baseType;
        typeDef.summary = [jsonDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONDescription];
        typeDef.displayName = [jsonDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONDisplayName];
        typeDef.identifier = [jsonDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONId];
        typeDef.controllablePolicy = [jsonDictionary cmis_boolForKey:kCMISBrowserJSONControllablePolicy];
        typeDef.controllableAcl = [jsonDictionary cmis_boolForKey:kCMISBrowserJSONControllableAcl];
        typeDef.creatable = [jsonDictionary cmis_boolForKey:kCMISBrowserJSONCreateable];
        typeDef.fileable = [jsonDictionary cmis_boolForKey:kCMISBrowserJSONFileable];
        typeDef.fullTextIndexed = [jsonDictionary cmis_boolForKey:kCMISBrowserJSONFullTextIndexed];
        typeDef.includedInSupertypeQuery = [jsonDictionary cmis_boolForKey:kCMISBrowserJSONIncludedInSuperTypeQuery];
        typeDef.queryable = [jsonDictionary cmis_boolForKey:kCMISBrowserJSONQueryable];
        typeDef.localName = [jsonDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONLocalName];
        typeDef.localNamespace = [jsonDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONLocalNamespace];
        typeDef.parentTypeId = [jsonDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONParentId];
        typeDef.queryName = [jsonDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONQueryName];
        
        //TODO type mutability
        
        NSDictionary *propertyDefinitions = [jsonDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONPropertyDefinitions];
        for (NSDictionary *propertyDefDictionary in [propertyDefinitions allValues]) {
            [typeDef addPropertyDefinition:[CMISBrowserUtil convertPropertyDefinition:propertyDefDictionary]];
        }
        
        // handle extensions
        typeDef.extensions = [CMISObjectConverter convertExtensions:jsonDictionary cmisKeys:[CMISBrowserConstants typeKeys]];
    } else {
        if (outError != NULL) *outError = [CMISErrors cmisError:serialisationError cmisErrorCode:kCMISErrorCodeRuntime];
        return nil;
    }
    
    return typeDef;
}

+ (void)objectDataFromJSONData:(NSData *)jsonData typeCache:(CMISBrowserTypeCache *)typeCache completionBlock:(void(^)(CMISObjectData *objectData, NSError *error))completionBlock
{
    // TODO: error handling i.e. if jsonData is nil, also handle outError being nil

    // parse the JSON response
    NSError *serialisationError = nil;
    id jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&serialisationError];
    
    if (!serialisationError) {
        // parse the json into a CMISObjectData object
        [CMISBrowserUtil convertObject:jsonDictionary typeCache:typeCache completionBlock:^(CMISObjectData *objectData, NSError *error) {
            completionBlock(objectData, error);
        }];
    } else {
        completionBlock(nil, [CMISErrors cmisError:serialisationError cmisErrorCode:kCMISErrorCodeRuntime]);
    }
}

+ (void)objectListFromJSONData:(NSData *)jsonData typeCache:(CMISBrowserTypeCache *)typeCache isQueryResult:(BOOL)isQueryResult completionBlock:(void(^)(CMISObjectList *objectList, NSError *error))completionBlock
{
    // TODO: error handling i.e. if jsonData is nil, also handle outError being nil
    
    // parse the JSON response
    NSError *serialisationError = nil;
    id jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&serialisationError];
    
    CMISObjectList *objectList = nil;
    if (!serialisationError) {
        // parse the json into a CMISObjectList object
        objectList = [CMISObjectList new];
        
        // parse the objects
        NSArray *objectsArray;
        if ([jsonDictionary isKindOfClass:NSArray.class]){
            objectsArray = jsonDictionary;
            
            objectList.hasMoreItems = NO;
            objectList.numItems = (int)objectsArray.count;
        } else { // is NSDictionary
            if (isQueryResult) {
                objectsArray = [jsonDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONResults];
            } else {
                objectsArray = [jsonDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONObjects];
            }
            // retrieve the paging data
            objectList.hasMoreItems = [jsonDictionary cmis_boolForKey:kCMISBrowserJSONHasMoreItems];
            objectList.numItems = [jsonDictionary cmis_intForKey:kCMISBrowserJSONNumberItems];
        }
        
        [CMISBrowserUtil convertObjects:objectsArray typeCache:typeCache completionBlock:^(NSArray *objects, NSError *error) {
            if (error){
                completionBlock(nil, error);
            } else {
                // pass objects to list
                objectList.objects = objects;
                
                // handle extension data
                if([jsonDictionary isKindOfClass:NSDictionary.class]) {
                    if (isQueryResult) {
                        objectList.extensions = [CMISObjectConverter convertExtensions:jsonDictionary cmisKeys:[CMISBrowserConstants queryResultListKeys]];
                    } else {
                        objectList.extensions = [CMISObjectConverter convertExtensions:jsonDictionary cmisKeys:[CMISBrowserConstants objectListKeys]];
                    }
                }
                completionBlock(objectList, nil);
            }
        }];
    } else {
        completionBlock(nil, [CMISErrors cmisError:serialisationError cmisErrorCode:kCMISErrorCodeRuntime]);
    }
}

+ (NSArray *)renditionsFromJSONData:(NSData *)jsonData error:(NSError **)outError
{
    // TODO: error handling i.e. if jsonData is nil, also handle outError being nil
    
    // parse the JSON response
    NSError *serialisationError = nil;
    id jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&serialisationError];
    
    NSArray *renditions = nil;
    if (!serialisationError) {
        // parse the json into a CMISObjectData object
        renditions = [CMISBrowserUtil renditionsFromArray:jsonDictionary];
    } else {
        if (outError != NULL) *outError = [CMISErrors cmisError:serialisationError cmisErrorCode:kCMISErrorCodeRuntime];
        return nil;
    }
    
    return renditions;
}

+ (NSArray *)failedToDeleteObjectsFromJSONData:(NSData *)jsonData error:(NSError **)outError
{
    // TODO: error handling i.e. if jsonData is nil, also handle outError being nil
    
    // parse the JSON response
    NSError *serialisationError = nil;
    id jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&serialisationError];
    
    if (!serialisationError) {
        NSMutableArray *ids = [[NSMutableArray alloc] init];
        NSArray *jsonIds = [jsonDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONFailedToDeleteId];
        
        if (jsonIds) {
            for (NSObject *obj in jsonIds) {
                [ids addObject:obj.description]; //obj can't be nil as it came out of an array
            }
        }
        
        return ids;
    } else {
        if (outError != NULL) *outError = [CMISErrors cmisError:serialisationError cmisErrorCode:kCMISErrorCodeRuntime];
        return nil;
    }
}

+ (void)objectParents:(NSData *)jsonData typeCache:(CMISBrowserTypeCache *)typeCache completionBlock:(void(^)(NSArray *objectParents, NSError *error))completionBlock
{
    // TODO: error handling i.e. if jsonData is nil, also handle outError being nil
    
    // parse the JSON response
    NSError *serialisationError = nil;
    id jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&serialisationError];
    
    if (!serialisationError) {
        [self convertObjects:jsonDictionary typeCache:typeCache completionBlock:completionBlock];
    } else {
        completionBlock(nil, [CMISErrors cmisError:serialisationError cmisErrorCode:kCMISErrorCodeRuntime]);
        return;
    }
}

#pragma mark -
#pragma mark Private helper methods

+ (void)convertObject:(NSDictionary *)dictionary typeCache:(CMISBrowserTypeCache *)typeCache completionBlock:(void(^)(CMISObjectData *objectData, NSError *error))completionBlock
{
    if (!dictionary) {
        completionBlock(nil, nil);
    }
    
    CMISObjectData *objectData = [CMISObjectData new];
    
    BOOL hasSuccinctProperties = YES;
    NSDictionary *propertiesJson = [dictionary cmis_objectForKeyNotNull:kCMISBrowserJSONSuccinctProperties];
    if(!propertiesJson){
        hasSuccinctProperties = NO;
        propertiesJson = [dictionary cmis_objectForKeyNotNull:kCMISBrowserJSONProperties];
    }
    
    
    id identifier = [propertiesJson cmis_objectForKeyNotNull:kCMISPropertyObjectId];
    if ([identifier isKindOfClass:NSDictionary.class]){
        objectData.identifier = [identifier cmis_objectForKeyNotNull:kCMISBrowserJSONValue];
    } else {
        objectData.identifier = identifier;
    }
    
    // determine the object type
    id baseType = [propertiesJson cmis_objectForKeyNotNull:kCMISPropertyBaseTypeId];
    if([baseType isKindOfClass:NSDictionary.class]) {
        baseType = [baseType cmis_objectForKeyNotNull:kCMISBrowserJSONValue];
    }
    
    // TODO other base types
    if ([baseType isEqualToString:kCMISPropertyObjectTypeIdValueDocument]) {
        objectData.baseType = CMISBaseTypeDocument;
    } else if ([baseType isEqualToString:kCMISPropertyObjectTypeIdValueFolder]) {
        objectData.baseType = CMISBaseTypeFolder;
    }
    
    BOOL isExactAcl = [dictionary cmis_boolForKey:kCMISBrowserJSONIsExact];
    objectData.acl = [CMISBrowserUtil convertAcl:[dictionary cmis_objectForKeyNotNull:kCMISBrowserJSONAcl] isExactAcl:isExactAcl];
    
    objectData.allowableActions = [CMISBrowserUtil convertAllowableActions:[dictionary cmis_objectForKeyNotNull:kCMISBrowserJSONAllowableActions]];
    
    objectData.isExactAcl = isExactAcl;

    // TODO set policyIds
    
    NSDictionary *propertiesExtension = [dictionary cmis_objectForKeyNotNull:kCMISBrowserJSONPropertiesExtension];
    
    void (^continueWithObjectConversion)(CMISProperties*, NSError*) = ^(CMISProperties *properties, NSError *error) {
        if (error){
            completionBlock(nil, error);
        } else {
            objectData.properties = properties;
            
            // relationships
            NSArray *relationshipsJson = [dictionary cmis_objectForKeyNotNull:kCMISBrowserJSONRelationships];
            [CMISBrowserUtil convertObjects:relationshipsJson typeCache:typeCache completionBlock:^(NSArray *objects, NSError *error) {
                if (error){
                    completionBlock(nil, error);
                } else {
                    objectData.relationships = objects;
                    
                    //renditions
                    NSArray *renditionsJson = [dictionary cmis_objectForKeyNotNull:kCMISBrowserJSONRenditions];
                    objectData.renditions = [self renditionsFromArray:renditionsJson];
                    
                    // handle extensions
                    objectData.extensions = [CMISObjectConverter convertExtensions:dictionary cmisKeys:[CMISBrowserConstants objectKeys]];
                    
                    completionBlock(objectData, nil);
                }
            }];
        }
    };
    
    if(hasSuccinctProperties) {
        [CMISBrowserUtil convertSuccinctProperties:propertiesJson propertiesExtension:propertiesExtension typeCache:typeCache completionBlock:^(CMISProperties *properties, NSError *error) {
            continueWithObjectConversion(properties, error);
        }];
    } else {
        NSError *error = nil;
        CMISProperties *properties = [CMISBrowserUtil convertProperties:propertiesJson propertiesExtension:propertiesExtension error:&error];
        continueWithObjectConversion(properties, error);
    }

}

+ (void)convertObjects:(NSArray *)objectsArray position:(NSInteger)position convertedObjects:(NSMutableArray *)convertedObjects typeCache:(CMISBrowserTypeCache *)typeCache completionBlock:(void(^)(NSArray* objects, NSError *error))completionBlock
{
    NSDictionary *dictionary = [objectsArray objectAtIndex:position];
    NSDictionary *objectDictionary = [dictionary cmis_objectForKeyNotNull:kCMISBrowserJSONObject];
    if (!objectDictionary) {
        objectDictionary = dictionary;
    }

    if(![objectDictionary isKindOfClass:NSDictionary.class]){
        completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument detailedDescription:[NSString stringWithFormat:@"expected a dictionary but was %@", objectDictionary.class]]);
    }
    [CMISBrowserUtil convertObject:objectDictionary typeCache:typeCache completionBlock:^(CMISObjectData *objectData, NSError *error) {
        if (error){
            completionBlock(nil, error);
        } else {
            if (position == 0) {
                [convertedObjects addObject:objectData];
                completionBlock(convertedObjects, nil);
            } else {
                // TODO check if there is a better way on how to avoid a large call stack
                // We need to do this workaround or else we would end up with a very large call stack
                [CMISBrowserUtil performBlock:^{
                    [self convertObjects:objectsArray
                                position:(position -1)
                        convertedObjects:convertedObjects
                               typeCache:typeCache
                         completionBlock:^(NSArray *objects, NSError *error) {
                             if (error){
                                 completionBlock(nil, error);
                             } else {
                                 [convertedObjects addObject:objectData];
                                 completionBlock(objects, nil);
                             }
                         }];
                }];
            }
        }
    }];

}

+ (void)convertObjects:(NSArray *)objectsArray typeCache:(CMISBrowserTypeCache *)typeCache completionBlock:(void(^)(NSArray* objects, NSError *error))completionBlock
{
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:objectsArray.count];
    if (objectsArray.count > 0) {
        [CMISBrowserUtil convertObjects:objectsArray
                               position:(objectsArray.count - 1) // start recursion with last item
                       convertedObjects:objects
                                 typeCache:typeCache
                           completionBlock:^(NSArray *objects, NSError *error) {
                               completionBlock(objects, error);
                           }];
    } else {
        completionBlock([NSArray array], nil);
    }
}

+ (CMISProperties *)convertProperties:(NSDictionary *)propertiesJson propertiesExtension:(NSDictionary *)extJson error:(NSError **)outError
{
    if(!propertiesJson) {
        return nil;
    }
    
    CMISProperties *properties = [[CMISProperties alloc] init];
    
    for (NSString *propName in propertiesJson) {
        NSDictionary *propertyDictionary = [propertiesJson cmis_objectForKeyNotNull:propName];
        if (!propertyDictionary) {
            continue;
        }
        
        CMISPropertyType propertyType = [CMISEnums enumForPropertyType:[propertyDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONDatatype]];
        
        id propValue = [propertyDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONValue];
        NSArray *values = nil;
        if ([propValue isKindOfClass:NSArray.class]) {
            values = propValue;
        } else if (propValue) {
            values = [NSArray arrayWithObject:propValue];
        }
        
        CMISPropertyData *propertyData;
        switch (propertyType) {
            case CMISPropertyTypeString:
            case CMISPropertyTypeId:
            case CMISPropertyTypeBoolean:
            case CMISPropertyTypeInteger:
            case CMISPropertyTypeDecimal:
            case CMISPropertyTypeHtml:
            case CMISPropertyTypeUri:
                propertyData = [CMISPropertyData createPropertyForId:propName arrayValue:values type:propertyType];
                break;
            case CMISPropertyTypeDateTime: {
                NSArray *dateValues = [CMISBrowserUtil convertNumbersToDates:values];
                propertyData = [CMISPropertyData createPropertyForId:propName arrayValue:dateValues type:propertyType];
                break;
            }
            default: {
                if (outError != NULL) *outError = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument
                                                 detailedDescription:@"Unknown property type!"];
                return nil;
            }
        }
        propertyData.identifier = propName;
        propertyData.displayName = [propertyDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONDisplayName];
        propertyData.queryName = [propertyDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONQueryName];
        propertyData.localName = [propertyDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONLocalName];
        
        propertyData.extensions = [CMISObjectConverter convertExtensions:propertyDictionary cmisKeys:[CMISBrowserConstants propertyKeys]];
        
        [properties addProperty:propertyData];
    }
    
    if (extJson){
        properties.extensions = [CMISObjectConverter convertExtensions:extJson cmisKeys:[NSSet set]];
    }
    
    return properties;
}

+ (void)convertSuccinctProperties:(NSDictionary *)propertiesJson propertiesExtension:(NSDictionary *)extJson typeCache:(CMISBrowserTypeCache *)typeCache completionBlock:(void(^)(CMISProperties *properties, NSError *error))completionBlock
{
    if (!propertiesJson) {
        completionBlock(nil, nil);
    }
    
    void (^continueConvertSuccinctPropertiesAndGetSecondaryObjectTypeDefinitions)(CMISTypeDefinition*) = ^(CMISTypeDefinition *typeDef) {
        
        void (^continueConvertSuccinctPropertiesSecondaryObjectTypeDefinitions)(NSArray*) = ^(NSArray *secTypeDefs) {
            
            [self convertProperties:propertiesJson typeCache:typeCache typeDefinition:typeDef secondaryTypeDefinitions:secTypeDefs completionBlock:^(CMISProperties *properties, NSError *error){
                if(error){
                    completionBlock(nil, error);
                } else {
                    if (extJson){
                        properties.extensions = [CMISObjectConverter convertExtensions:extJson cmisKeys:[NSSet set]];
                    }
                    
                    completionBlock(properties, nil);
                }
            }];
        };
        
        // Get secondary object type definitions
        NSArray *secTypeIds = [propertiesJson cmis_objectForKeyNotNull:kCMISPropertySecondaryObjectTypeIds];
        if (secTypeIds != nil && secTypeIds.count > 0) {
            [CMISBrowserUtil retrieveTypeDefinitions:secTypeIds typeCache:typeCache completionBlock:^(NSArray *typeDefinitions, NSError *error) {
                if(error){
                    completionBlock(nil, error);
                } else {
                    continueConvertSuccinctPropertiesSecondaryObjectTypeDefinitions(typeDefinitions);
                }
            }];
        } else {
            continueConvertSuccinctPropertiesSecondaryObjectTypeDefinitions(nil);
        }
    };
    
    // Get type definition for given object type id
    CMISTypeDefinition *typeDef = nil;
    if ([[propertiesJson cmis_objectForKeyNotNull:kCMISPropertyObjectTypeId] isKindOfClass:NSString.class]){
        [typeCache typeDefinition:[propertiesJson cmis_objectForKeyNotNull:kCMISPropertyObjectTypeId] completionBlock:^(CMISTypeDefinition *typeDef, NSError *error){
            if(error){
                completionBlock(nil, error);
            } else {
                continueConvertSuccinctPropertiesAndGetSecondaryObjectTypeDefinitions(typeDef);
            }
        }];
    } else {
        continueConvertSuccinctPropertiesAndGetSecondaryObjectTypeDefinitions(typeDef);
    }
}

+(void)convertProperty:(NSString *)propName propertiesJson:(NSDictionary *)propertiesJson typeCache:(CMISBrowserTypeCache *)typeCache typeDefinition:(CMISTypeDefinition *)typeDef secondaryTypeDefinitions:(NSArray *)secTypeDefs completionBlock:(void(^)(CMISPropertyData *propertyData, NSError *error))completionBlock {
    CMISPropertyDefinition *propDef = nil;
    if (typeDef){
        propDef = typeDef.propertyDefinitions[propName];
    }
    
    if (propDef == nil && secTypeDefs != nil) {
        for (CMISTypeDefinition *secTypeDef in secTypeDefs) {
            propDef = secTypeDef.propertyDefinitions[propName];
            if (propDef){
                break;
            }
        }
    }
    
    void (^continueConvertSuccinctPropertiesTypeDefinitionDocument)(CMISPropertyDefinition*) = ^(CMISPropertyDefinition *propDef) {
        
        void (^continueConvertSuccinctPropertiesTypeDefinitionFolder)(CMISPropertyDefinition*) = ^(CMISPropertyDefinition *propDef) {
            
            id propValue = [propertiesJson cmis_objectForKeyNotNull:propName];
            NSArray *values = nil;
            if ([propValue isKindOfClass:NSArray.class]) {
                values = propValue;
            } else if (propValue) {
                values = [NSArray arrayWithObject:propValue];
            }
            
            CMISPropertyData *propertyData;
            
            if (propDef){
                
                switch (propDef.propertyType) {
                    case CMISPropertyTypeString:
                    case CMISPropertyTypeId:
                    case CMISPropertyTypeBoolean:
                    case CMISPropertyTypeInteger:
                    case CMISPropertyTypeDecimal:
                    case CMISPropertyTypeHtml:
                    case CMISPropertyTypeUri:
                        propertyData = [CMISPropertyData createPropertyForId:propName arrayValue:values type:propDef.propertyType];
                        break;
                    case CMISPropertyTypeDateTime: {
                        NSArray *dateValues = [CMISBrowserUtil convertNumbersToDates:values];
                        propertyData = [CMISPropertyData createPropertyForId:propName arrayValue:dateValues type:propDef.propertyType];
                        break;
                    }
                    default: {
                        NSError *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument
                                                         detailedDescription:@"Unknown property type!"];
                        completionBlock(nil, error);
                        return;
                    }
                }
                propertyData.identifier = propName;
                propertyData.displayName = propDef.displayName;
                propertyData.queryName = propDef.queryName;
                propertyData.localName = propDef.localName;
            } else {
                // this else block should only be reached in rare circumstances
                // it may return incorrect types
                if (values == nil) {
                    propertyData = [CMISPropertyData createPropertyForId:propName arrayValue:nil type:CMISPropertyTypeString];
                } else {
                    id firstValue = values[0];
                    if ([firstValue isKindOfClass:NSNumber.class]) {
                        propertyData = [CMISPropertyData createPropertyForId:propName arrayValue:values type:CMISPropertyTypeInteger];
                    } else {
                        propertyData = [CMISPropertyData createPropertyForId:propName arrayValue:values type:CMISPropertyTypeString];
                    }
                }
                
                propertyData.identifier = propName;
                propertyData.displayName = propName;
                propertyData.queryName = nil;
                propertyData.localName = nil;
            }
            
            completionBlock(propertyData, nil);
        };
        
        if (!propDef) { //try to find property definition on folder
            [typeCache typeDefinition:kCMISPropertyObjectTypeIdValueFolder completionBlock:^(CMISTypeDefinition *typeDefinition, NSError *error) {
                if (error){
                    completionBlock(nil, error);
                } else {
                    CMISPropertyDefinition *propertyDefinition = typeDefinition.propertyDefinitions[propName];
                    continueConvertSuccinctPropertiesTypeDefinitionFolder(propertyDefinition);
                }
            }];
        } else {
            continueConvertSuccinctPropertiesTypeDefinitionFolder(propDef);
        }
        
    };
    
    if (!propDef) { //try to find property definition on document
        [typeCache typeDefinition:kCMISPropertyObjectTypeIdValueDocument completionBlock:^(CMISTypeDefinition *typeDefinition, NSError *error) {
            if (error){
                completionBlock(nil, error);
            } else {
                CMISPropertyDefinition *propertyDefinition = typeDefinition.propertyDefinitions[propName];
                continueConvertSuccinctPropertiesTypeDefinitionDocument(propertyDefinition);
            }
        }];
    } else {
        continueConvertSuccinctPropertiesTypeDefinitionDocument(propDef);
    }
}

+ (NSArray *)convertNumbersToDates:(NSArray *)numbers
{
    if(!numbers) {
        return nil;
    }
    
    NSMutableArray *dates = [[NSMutableArray alloc] initWithCapacity:numbers.count];
    for (NSNumber *miliseconds in numbers) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[miliseconds unsignedLongLongValue] / 1000.0]; // miliseconds to seconds
        [dates addObject:date];
    }
    return dates;
}

+ (void)convertProperties:(NSArray*)propNames position:(NSInteger)position properties:(CMISProperties *)properties propertiesJson:(NSDictionary *)propertiesJson typeCache:(CMISBrowserTypeCache *)typeCache typeDefinition:(CMISTypeDefinition *)typeDef secondaryTypeDefinitions:(NSArray *)secTypeDefs completionBlock:(void (^)(CMISProperties *properties, NSError *error))completionBlock
{
    NSString *propName = [propNames objectAtIndex:position];
    
    [self convertProperty:propName
           propertiesJson:propertiesJson
                typeCache:typeCache
           typeDefinition:typeDef
 secondaryTypeDefinitions:secTypeDefs
          completionBlock:^(CMISPropertyData *propertyData, NSError *error) {
              if (error){
                  completionBlock(nil, error);
              } else {
                  if (position == 0) {
                      [properties addProperty:propertyData];
                      completionBlock(properties, nil);
                  } else {
                      // TODO check if there is a better way on how to avoid a large call stack
                      // We need to do this workaround or else we would end up with a very large call stack
                      [CMISBrowserUtil performBlock:^{
                          [self convertProperties:propNames
                                         position:(position -1)
                                       properties:properties
                                   propertiesJson:propertiesJson
                                        typeCache:typeCache
                                   typeDefinition:typeDef
                         secondaryTypeDefinitions:secTypeDefs
                                  completionBlock:^(CMISProperties *properties, NSError *error) {
                                      if (error){
                                          completionBlock(nil, error);
                                      } else {
                                          [properties addProperty:propertyData];
                                          completionBlock(properties, nil);
                                      }
                                  }];
                      }];
                  }
              }
          }];
}

+ (void)convertProperties:(NSDictionary *)propertiesJson typeCache:(CMISBrowserTypeCache *)typeCache typeDefinition:(CMISTypeDefinition *)typeDef secondaryTypeDefinitions:(NSArray *)secTypeDefs completionBlock:(void(^)(CMISProperties *properties, NSError *error))completionBlock
{
    // create properties
    CMISProperties *properties = [CMISProperties new];
    
    NSArray *propNames = [propertiesJson allKeys];
    if (propNames.count > 0) {
        [CMISBrowserUtil convertProperties:propNames
                                        position:(propNames.count - 1) // start recursion with last item
                                properties:properties
                            propertiesJson:propertiesJson
                                 typeCache:typeCache
                            typeDefinition:typeDef
                  secondaryTypeDefinitions:secTypeDefs
                           completionBlock:^(CMISProperties *properties, NSError *error) {
                                     completionBlock(properties, error);
                                 }];
    } else {
        completionBlock(properties, nil);
    }
}

+ (CMISRepositoryCapabilities *)convertRepositoryCapabilities:(NSDictionary *)jsonDictionary
{
    if (!jsonDictionary){
        return nil;
    }
    
    CMISRepositoryCapabilities *result = [[CMISRepositoryCapabilities alloc] init];
    for (NSString *capabilityKey in jsonDictionary) {
        id value = [jsonDictionary cmis_objectForKeyNotNull:capabilityKey];
        
        if([[CMISConstants repositoryCapabilityKeys] containsObject:capabilityKey]) {
            [result setCapability:capabilityKey value:value];
        }
    }
    
    result.extensions = [CMISObjectConverter convertExtensions:jsonDictionary cmisKeys:[CMISConstants repositoryCapabilityKeys]];
    
    return result;
}

+ (CMISAcl *)convertAcl:(NSDictionary *)jsonDictionary isExactAcl:(BOOL)isExact
{
    if (!jsonDictionary) {
        return nil;
    }
    
    CMISAcl *result = [[CMISAcl alloc] init];
    
    NSMutableArray *aces = [[NSMutableArray alloc] init];
    
    NSArray *jsonAces = [jsonDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONAces];
    if (jsonAces) {
        for (NSDictionary *entry in jsonAces) {
            CMISAce *ace = [[CMISAce alloc] init];
            
            id isDirect = [entry cmis_objectForKeyNotNull:kCMISBrowserJSONAceIsDirect];
            ace.isDirect = isDirect != nil ? [isDirect boolValue] : YES;
            
            NSArray *jsonPermissions = [entry cmis_objectForKeyNotNull:kCMISBrowserJSONAcePermissions];
            if (jsonPermissions) {
                NSMutableSet *permissions = [[NSMutableSet alloc] init];
                for (NSObject *perm in jsonPermissions) {
                    [permissions addObject:[perm description]];
                }
                ace.permissions = permissions;
            }
            
            NSDictionary *jsonPrincipal = [entry cmis_objectForKeyNotNull:kCMISBrowserJSONAcePrincipal];
            if (jsonPrincipal) {
                CMISPrincipal *principal = [[CMISPrincipal alloc] init];
                
                principal.principalId = [jsonPrincipal cmis_objectForKeyNotNull:kCMISBrowserJSONAcePrincipalId];
                
                principal.extensions = [CMISObjectConverter convertExtensions:jsonPrincipal cmisKeys:[CMISBrowserConstants principalKeys]];
                
                ace.principal = principal;
            }
            
            ace.extensions = [CMISObjectConverter convertExtensions:entry cmisKeys:[CMISBrowserConstants aceKeys]];
            
            [aces addObject:ace];
        }
    }
    
    result.aces = [aces copy];
    
    result.isExact = isExact;
    
    result.extensions = [CMISObjectConverter convertExtensions:jsonDictionary cmisKeys:[CMISBrowserConstants aclKeys]];
    
    return result;
}

+ (CMISAllowableActions *)convertAllowableActions:(NSDictionary *)jsonDictionary
{
    if (!jsonDictionary) {
        return nil;
    }
    
    NSArray *extensions = [CMISObjectConverter convertExtensions:jsonDictionary cmisKeys:[NSSet setWithObjects:CMISAllowableActionsArray]];
    CMISAllowableActions *result = [[CMISAllowableActions alloc] initWithAllowableActionsDictionary:jsonDictionary extensionElementArray:extensions];

    return result;
}

+ (void)retrieveTypeDefinitions:(NSArray *)objectTypeIds position:(NSInteger)position typeCache:(CMISBrowserTypeCache *)typeCache completionBlock:(void (^)(NSMutableArray *typeDefinitions, NSError *error))completionBlock
{
    [typeCache typeDefinition:[objectTypeIds objectAtIndex:position]
              completionBlock:^(CMISTypeDefinition *typeDefinition, NSError *error) {
                             if (error){
                                 completionBlock(nil, error);
                             } else {
                                 if (position == 0) {
                                     NSMutableArray *typeDefinitions = [[NSMutableArray alloc] initWithCapacity:objectTypeIds.count];
                                     [typeDefinitions addObject:typeDefinition];
                                     completionBlock(typeDefinitions, error);
                                 } else {
                                     [self retrieveTypeDefinitions:objectTypeIds position:(position - 1) typeCache:typeCache completionBlock:^(NSMutableArray *typeDefinitions, NSError *error) {
                                         if(error) {
                                             completionBlock(nil, error);
                                         } else {
                                             [typeDefinitions addObject:typeDefinition];
                                             completionBlock(typeDefinitions, nil);
                                         }
                                     }];
                                 }
                             }
                         }];
}

+ (void)retrieveTypeDefinitions:(NSArray *)objectTypeIds typeCache:(CMISBrowserTypeCache *)typeCache completionBlock:(void (^)(NSArray *typeDefinitions, NSError *error))completionBlock
{
    if (objectTypeIds.count > 0) {
        [CMISBrowserUtil retrieveTypeDefinitions:objectTypeIds
                                        position:(objectTypeIds.count - 1) // start recursion with last item
                                       typeCache:typeCache
                                 completionBlock:^(NSMutableArray *typeDefinitions, NSError *error) {
                                     completionBlock(typeDefinitions, error);
                                 }];
    } else {
        completionBlock([[NSArray alloc] init], nil);
    }
}

+ (NSArray *)renditionsFromArray:(NSArray *)array
{
    if (!array) {
        return nil;
    }
    NSMutableArray *renditions = [[NSMutableArray alloc] initWithCapacity:array.count];
    for(NSDictionary *renditionJson in array){
        CMISRenditionData *renditionData = [CMISRenditionData new];
        renditionData.height = [NSNumber numberWithLongLong:[[renditionJson cmis_objectForKeyNotNull:kCMISBrowserJSONRenditionHeight] longLongValue]];
        renditionData.kind = [renditionJson cmis_objectForKeyNotNull:kCMISBrowserJSONRenditionKind];
        renditionData.length = [NSNumber numberWithLongLong:[[renditionJson cmis_objectForKeyNotNull:kCMISBrowserJSONRenditionLength] longLongValue]];
        renditionData.mimeType = [renditionJson cmis_objectForKeyNotNull:kCMISBrowserJSONRenditionMimeType];
        renditionData.renditionDocumentId = [renditionJson cmis_objectForKeyNotNull:kCMISBrowserJSONRenditionDocumentId];
        renditionData.streamId = [renditionJson cmis_objectForKeyNotNull:kCMISBrowserJSONRenditionStreamId];
        renditionData.title = [renditionJson cmis_objectForKeyNotNull:kCMISBrowserJSONRenditionTitle];
        renditionData.width = [NSNumber numberWithLongLong:[[renditionJson cmis_objectForKeyNotNull:kCMISBrowserJSONRenditionWidth] longLongValue]];
        
        // handle extensions
        renditionData.extensions = [CMISObjectConverter convertExtensions:renditionJson cmisKeys:[CMISBrowserConstants renditionKeys]];
        
        [renditions addObject:renditionData];
    }
    
    return renditions;
}

+ (CMISPropertyDefinition *)convertPropertyDefinition:(NSDictionary *)propertyDictionary
{
    if (!propertyDictionary){
        return nil;
    }
    
    // create property definition and add to type definition
    CMISPropertyDefinition *propDef = [CMISPropertyDefinition new];
    propDef.identifier = [propertyDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONId];
    propDef.localName = [propertyDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONLocalName];
    propDef.localNamespace = [propertyDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONLocalNamespace];
    propDef.queryName = [propertyDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONQueryName];
    propDef.summary = [propertyDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONDescription];
    propDef.displayName = [propertyDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONDisplayName];
    propDef.inherited = [propertyDictionary cmis_boolForKey:kCMISBrowserJSONInherited];
    propDef.openChoice = [propertyDictionary cmis_boolForKey:kCMISBrowserJSONOpenChoice];
    propDef.orderable = [propertyDictionary cmis_boolForKey:kCMISBrowserJSONOrderable];
    propDef.queryable = [propertyDictionary cmis_boolForKey:kCMISBrowserJSONQueryable];
    propDef.required = [propertyDictionary cmis_boolForKey:kCMISBrowserJSONRequired];
    
    // determine property type
    propDef.propertyType = [CMISEnums enumForPropertyType:[propertyDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONPropertyType]];
    
    // determine cardinality
    NSString *cardinalityString = [propertyDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONCardinality];
    if ([cardinalityString isEqualToString:kCMISBrowserJSONCardinalityValueSingle]) {
        propDef.cardinality = CMISCardinalitySingle;
    } else if ([cardinalityString isEqualToString:kCMISBrowserJSONCardinalityValueMultiple]) {
        propDef.cardinality = CMISCardinalityMulti;
    }
    
    // determine updatability
    NSString *updatabilityString = [propertyDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONUpdateability];
    if ([updatabilityString isEqualToString:kCMISBrowserJSONUpdateabilityValueReadOnly]) {
        propDef.updatability = CMISUpdatabilityReadOnly;
    } else if ([updatabilityString isEqualToString:kCMISBrowserJSONUpdateabilityValueReadWrite]) {
        propDef.updatability = CMISUpdatabilityReadWrite;
    } else if ([updatabilityString isEqualToString:kCMISBrowserJSONUpdateabilityValueOnCreate]) {
        propDef.updatability = CMISUpdatabilityOnCreate;
    } else if ([updatabilityString isEqualToString:kCMISBrowserJSONUpdateabilityValueWhenCheckedOut]) {
        propDef.updatability = CMISUpdatabilityWhenCheckedOut;
    }
    
    // parse default value
    id defaultValueObject = propertyDictionary[kCMISBrowserJSONDefaultValue];
    if (defaultValueObject != nil)
    {
        // for single valued properties this will be actual default value,
        // for multi valued properties this will be an array
        if ([defaultValueObject isKindOfClass:[NSArray class]])
        {
            propDef.defaultValues = defaultValueObject;
        }
        else
        {
            propDef.defaultValues = @[defaultValueObject];
        }
    }
    
    // parse choices, if present
    NSArray *choicesJSON = propertyDictionary[kCMISBrowserJSONChoice];
    if (choicesJSON != nil) {
        NSMutableArray *choices = [NSMutableArray array];
        for (NSDictionary *choiceDictionary in choicesJSON) {
            CMISPropertyChoice *choice = [CMISPropertyChoice new];
            choice.displayName = [choiceDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONDisplayName];
            choice.value = [choiceDictionary cmis_objectForKeyNotNull:kCMISBrowserJSONValue];
            [choices addObject:choice];
        }
        
        propDef.choices = choices;
    }
    
    // handle extensions
    propDef.extensions = [CMISObjectConverter convertExtensions:propertyDictionary cmisKeys:[CMISBrowserConstants propertyTypeKeys]];
    
    return propDef;
}


@end
