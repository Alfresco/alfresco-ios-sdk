/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is the Alfresco Mobile App.
 *
 * The Initial Developer of the Original Code is Zia Consulting, Inc.
 * Portions created by the Initial Developer are Copyright (C) 2011-2012
 * the Initial Developer. All Rights Reserved.
 *
 *
 * ***** END LICENSE BLOCK ***** */

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
#import "CMISISO8601DateFormatter.h"
#import "AlfrescoCMISFolder.h"
#import "CMISDateUtil.h"
#import "AlfrescoErrors.h"
#import "AlfrescoConstants.h"

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

- (CMISObject *)convertObject:(CMISObjectData *)objectData
{
    CMISObject *object = nil;

    if (objectData.baseType == CMISBaseTypeDocument)
    {
        object = [[AlfrescoCMISDocument alloc] initWithObjectData:objectData withSession:self.session];
    }
    else if (objectData.baseType == CMISBaseTypeFolder)
    {
        object = [[AlfrescoCMISFolder alloc] initWithObjectData:objectData withSession:self.session];
    }

    return object;
}




- (void)convertProperties:(NSDictionary *)properties forObjectTypeId:(NSString *)objectTypeId completionBlock:(void (^)(CMISProperties *, NSError *))completionBlock
{
//    log(@"<<<<<< convertProperties forObjectTypeId %@ >>>>>>>>>>>>> ", objectTypeId);
    [AlfrescoErrors assertArgumentNotNil:properties argumentName:@"properties"];
    NSObject *objectTypeIdValue = [properties objectForKey:kCMISPropertyObjectTypeId];
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
        completionBlock( nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument withDetailedDescription:@"Type property must be set"]);
        return;
    }
//    log(@"<<<<<< convertProperties forObjectTypeId %@  and objectTypeIdString %@ >>>>>>>>>>>>> ", objectTypeId, objectTypeIdString);
    
    [self retrieveAspectTypeDefinitionsFromObjectID:objectTypeIdString completionBlock:^(NSArray *returnedTypes, NSError *error){
        if (0 == returnedTypes.count)
        {
            completionBlock(nil, [CMISErrors cmisError:error withCMISErrorCode:kCMISErrorCodeRuntime]);
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
            
            BOOL success = NO;
            // Loop over all provided properties and put them in the right dictionary
            for (NSString *propertyId in properties)
            {
                id propertyValue = [properties objectForKey:propertyId];
//                log(@"<<<<<< convertProperties PropertyId %@ and property value is %@ >>>>>>>>>>>>> ", propertyId, propertyValue);
                
                if ([propertyId isEqualToString:kCMISPropertyObjectTypeId])
                {
//                    log(@"<<<<<< convertProperties PropertyId '%@' is of type ObjectTypeId and we should be setting it to the value objectTypeId='%@' property value='%@' >>>>>>>>>>>>> ", propertyId, objectTypeId, propertyValue);
                    [typeProperties setValue:propertyValue forKey:kCMISPropertyObjectTypeId];
                }
                else if ([mainTypeDefinition propertyDefinitionForId:propertyId])
                {
                    [typeProperties setObject:propertyValue forKey:propertyId];
                }
                else
                {
                    [aspectProperties setObject:propertyValue forKey:propertyId];
                    
                    // Find matching property definition
                    BOOL matchingPropertyDefinitionFound = NO;
                    uint index = 0;
                    while (!matchingPropertyDefinitionFound && index < aspectTypes.count)
                    {
                        CMISTypeDefinition *aspectType = [aspectTypes objectAtIndex:index];
                        if (aspectType.propertyDefinitions != nil)
                        {
                            CMISPropertyDefinition *aspectPropertyDefinition = [aspectType propertyDefinitionForId:propertyId];
                            if (aspectPropertyDefinition != nil)
                            {
                                [aspectPropertyDefinitions setObject:aspectPropertyDefinition forKey:propertyId];
                                matchingPropertyDefinitionFound = YES;
                            }
                        }
                        index++;
                    }
                    success = matchingPropertyDefinitionFound;
                    // If no match was found, throw an exception
                    if (!matchingPropertyDefinitionFound)
                    {
                        NSError *typeError = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument
                                                         withDetailedDescription:[NSString stringWithFormat:@"Property '%@' is neither an object type property nor an aspect property", propertyId]];
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
                CMISExtensionElement *extensionElement = [[CMISExtensionElement alloc] initLeafWithName:@"aspectsToAdd"
                                                                                           namespaceUri:@"http://www.alfresco.org" attributes:nil value:aspectType.id];
                [alfrescoExtensions addObject:extensionElement];
            }
            
            // Convert the aspect properties
            if (aspectProperties.count > 0)
            {
                NSMutableArray *propertyExtensions = [NSMutableArray array];
                
                for (NSString *propertyId in aspectProperties)
                {
                    CMISPropertyDefinition *aspectPropertyDefinition = [aspectPropertyDefinitions objectForKey:propertyId];
                    if (aspectPropertyDefinition == nil)
                    {
                        NSError *typeError = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument
                                                         withDetailedDescription:[NSString stringWithFormat:@"Unknown aspect property: %@", propertyId]];
                        completionBlock(nil, typeError);
                        return;
                    }
                    
                    
                    NSString *name = nil;
                    switch (aspectPropertyDefinition.propertyType)
                    {
                        case CMISPropertyTypeBoolean:
                            name = @"propertyBoolean";
                            break;
                        case CMISPropertyTypeDateTime:
                            name = @"propertyDateTime";
                            break;
                        case CMISPropertyTypeInteger:
                            name = @"propertyInteger";
                            break;
                        case CMISPropertyTypeDecimal:
                            name = @"propertyDecimal";
                            break;
                        case CMISPropertyTypeId:
                            name = @"propertyId";
                            break;
                        case CMISPropertyTypeHtml:
                            name = @"propertyHtml";
                            break;
                        case CMISPropertyTypeUri:
                            name = @"propertyUri";
                            break;
                        default:
                            name = @"propertyString";
                            break;
                    }
                    
                    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
                    [attributes setObject:aspectPropertyDefinition.id forKey:@"propertyDefinitionId"];
                    
                    NSMutableArray *propertyValues = [NSMutableArray array];
                    id value = [aspectProperties objectForKey:propertyId];
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
                        
                        CMISExtensionElement *valueExtensionElement = [[CMISExtensionElement alloc] initLeafWithName:@"value"
                                                                                                        namespaceUri:@"http://docs.oasis-open.org/ns/cmis/core/200908/" attributes:nil value:stringValue];
                        [propertyValues addObject:valueExtensionElement];
                    }
                    
                    
                    CMISExtensionElement *aspectPropertyExtensionElement = [[CMISExtensionElement alloc] initNodeWithName:name
                                                                                                             namespaceUri:@"http://docs.oasis-open.org/ns/cmis/core/200908/" attributes:attributes children:propertyValues];
                    [propertyExtensions addObject:aspectPropertyExtensionElement];
                }
                
                [alfrescoExtensions addObject: [[CMISExtensionElement alloc] initNodeWithName:@"properties"
                                                                                 namespaceUri:@"http://www.alfresco.org" attributes:nil children:propertyExtensions]];
            }
            // Cmis doesn't understand aspects, so we must replace the objectTypeId if needed
            if ([typeProperties objectForKey:kCMISPropertyObjectTypeId] != nil)
            {
//                log(@"<<<<<< the mainTypeDefinition is %@  and we are setting it for key: %@  >>>>>>>>>>>>> ", mainTypeDefinition.id, kCMISPropertyObjectTypeId);
                [typeProperties setValue:mainTypeDefinition.id forKey:kCMISPropertyObjectTypeId];
            }
            else
            {
//                log(@"<<<<<<   we couldn't find the type definition %@ in the dictionary >>>>>>>>>>>>> ",kCMISPropertyObjectTypeId);
            }
            [super convertProperties:typeProperties forObjectTypeId:mainTypeDefinition.id completionBlock:^(CMISProperties *result, NSError *error){
                if (nil == result)
                {
                    completionBlock(nil, error);
                }
                else
                {
                    if (alfrescoExtensions.count > 0)
                    {
                        result.extensions = [NSArray arrayWithObject:[[CMISExtensionElement alloc] initNodeWithName:@"setAspects"
                                                                                                       namespaceUri:@"http://www.alfresco.org" attributes:nil children:alfrescoExtensions]];
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
        if ([type.id hasPrefix:@"cmis:"])
        {
            typeDefinition = type;
            break;
        }
    }
    if (nil == typeDefinition)
    {
        typeDefinition = [typeArray objectAtIndex:0];
    }
    return typeDefinition;
}

- (NSArray *)aspectTypesFromTypeArray:(NSArray *)typeArray
{
    NSMutableArray *aspects = [NSMutableArray array];
    for (CMISTypeDefinition * type in typeArray)
    {
        if (![type.id hasPrefix:@"cmis:"])
        {
            [aspects addObject:type];
        }
    }    
    return aspects;
}



- (void)retrieveAspectTypeDefinitionsFromObjectID:(NSString *)objectID completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    NSArray *components = [objectID componentsSeparatedByString:@","];
//    log(@"<<<<<< retrieveAspectTypeDefinitionsFromObjectID objectID is %@", objectID);
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
//                log(@"<<<<<< retrieveAspectTypeDefinitionsFromObjectID objectID is %@ and returned type definition is %@", objectID, typeDefinition.id);
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
//                        log(@"<<<<<< retrieveAspectTypeDefinitionsFromObjectID objectID is %@ and returned type definition is %@", objectID, typeDefinition.id);
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


/*
- (CMISProperties *)convertProperties:(NSDictionary *)properties forObjectTypeId:(NSString *)objectTypeId error:(NSError **)error
{
    // A direct port of the Alfresco extensions code ... definitely not going to win a beauty contest ...

    // I decided to keep all logic in one method to implement it fast. So keep in mind when ripping it out that you will need to do
    // some SERIOUS refactoring, by splitting into several methods and util classes (eg to create the extension elements)

    // Check input
    if (properties == nil)
    {
        return nil;
    }

    // Get object and aspect types
    NSObject *objectTypeIdValue = [properties objectForKey:kCMISPropertyObjectTypeId];
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


    if (objectTypeIdString == nil)
    {
        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument withDetailedDescription:@"Type property must be set"];
        return nil;
    }

    // Get type definitions
    CMISTypeDefinition *mainTypeDefinition = nil;
    NSMutableArray *aspectTypes = [[NSMutableArray alloc] init];

    // Check if there are actually aspects/
    // If so, split them and fetch the type definition for each of them
    if ([objectTypeIdString rangeOfString:@","].location == NSNotFound)
    {
        NSError *internalError = nil;
        mainTypeDefinition = [self.session.binding.repositoryService retrieveTypeDefinition:objectTypeIdString error:&internalError];

        if (internalError != nil)
        {
            *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeInvalidArgument];
            return nil;
        }
    }
    else
    {
        NSArray *typeIds = [objectTypeIdString componentsSeparatedByString:@","];
        NSString *typeDefinitionString = [typeIds objectAtIndex:0];

        // Main type
        NSError *internalError = nil;
        mainTypeDefinition = [self.session.binding.repositoryService retrieveTypeDefinition:
                [typeDefinitionString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] error:&internalError];

        if (internalError != nil)
        {
            *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeInvalidArgument];
            return nil;
        }

        // Aspects
        for (int i=1; i < typeIds.count; i++)
        {
            NSString *aspectTypeDefinitionString = [typeIds objectAtIndex:i];
            CMISTypeDefinition *aspectTypeDefinition = [self.session.binding.repositoryService retrieveTypeDefinition:
                   [aspectTypeDefinitionString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] error:&internalError];

            if (internalError != nil)
            {
                *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeInvalidArgument];
                return nil;
            }

            [aspectTypes addObject:aspectTypeDefinition];
        }
    }

    // Split type properties from aspect properties
    NSMutableDictionary *typeProperties = [NSMutableDictionary dictionary];
    NSMutableDictionary *aspectProperties = [NSMutableDictionary dictionary];
    NSMutableDictionary *aspectPropertyDefinitions = [NSMutableDictionary dictionary];

    // Loop over all provided properties and put them in the right dictionary
    for (NSString *propertyId in properties)
    {
        id propertyValue = [properties objectForKey:propertyId];

        if ([propertyId isEqualToString:kCMISPropertyObjectTypeId])
        {
            if (objectTypeId == nil)
            {
                [typeProperties setValue:propertyValue forKey:kCMISPropertyObjectTypeId];
            }
        }
        else if ([mainTypeDefinition propertyDefinitionForId:propertyId])
        {
            [typeProperties setObject:propertyValue forKey:propertyId];
        }
        else
        {
            [aspectProperties setObject:propertyValue forKey:propertyId];

            // Find matching property definition
            BOOL matchingPropertyDefinitionFound = NO;
            uint index = 0;
            while (!matchingPropertyDefinitionFound && index < aspectTypes.count)
            {
                CMISTypeDefinition *aspectType = [aspectTypes objectAtIndex:index];
                if (aspectType.propertyDefinitions != nil)
                {
                    CMISPropertyDefinition *aspectPropertyDefinition = [aspectType propertyDefinitionForId:propertyId];
                    if (aspectPropertyDefinition != nil)
                    {
                        [aspectPropertyDefinitions setObject:aspectPropertyDefinition forKey:propertyId];
                       matchingPropertyDefinitionFound = YES;
                    }
                }
                index++;
            }

            // If no match was found, throw an exception
            if (!matchingPropertyDefinitionFound)
            {
                *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument
                    withDetailedDescription:[NSString stringWithFormat:@"Property '%@' is neither an object type property nor an aspect property", propertyId]];
                return nil;
            }
        }
    }

    // Create an array to hold all converted stuff
    NSMutableArray *alfrescoExtensions = [NSMutableArray array];

    // Convert the aspect types stuff to CMIS extensions
    for (CMISTypeDefinition *aspectType in aspectTypes)
    {
        CMISExtensionElement *extensionElement = [[CMISExtensionElement alloc] initLeafWithName:@"aspectsToAdd"
            namespaceUri:@"http://www.alfresco.org" attributes:nil value:aspectType.id];
        [alfrescoExtensions addObject:extensionElement];
    }

    // Convert the aspect properties
    if (aspectProperties.count > 0)
    {
        NSMutableArray *propertyExtensions = [NSMutableArray array];

        for (NSString *propertyId in aspectProperties)
        {
            CMISPropertyDefinition *aspectPropertyDefinition = [aspectPropertyDefinitions objectForKey:propertyId];
            if (aspectPropertyDefinition == nil)
            {
                *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument
                                   withDetailedDescription:[NSString stringWithFormat:@"Unknown aspect property: %@",propertyId]];
                return nil;
            }


            NSString *name = nil;
            switch (aspectPropertyDefinition.propertyType)
            {
                case CMISPropertyTypeBoolean:
                    name = @"propertyBoolean";
                    break;
                case CMISPropertyTypeDateTime:
                    name = @"propertyDateTime";
                    break;
                case CMISPropertyTypeInteger:
                    name = @"propertyInteger";
                    break;
                case CMISPropertyTypeDecimal:
                    name = @"propertyDecimal";
                    break;
                case CMISPropertyTypeId:
                    name = @"propertyId";
                    break;
                case CMISPropertyTypeHtml:
                    name = @"propertyHtml";
                    break;
                case CMISPropertyTypeUri:
                    name = @"propertyUri";
                    break;
                default:
                    name = @"propertyString";
            }

            NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
            [attributes setObject:aspectPropertyDefinition.id forKey:@"propertyDefinitionId"];

            NSMutableArray *propertyValues = [NSMutableArray array];
            id value = [aspectProperties objectForKey:propertyId];
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
                    }
                }

                CMISExtensionElement *valueExtensionElement = [[CMISExtensionElement alloc] initLeafWithName:@"value"
                    namespaceUri:@"http://docs.oasis-open.org/ns/cmis/core/200908/" attributes:nil value:stringValue];
                [propertyValues addObject:valueExtensionElement];
            }


            CMISExtensionElement *aspectPropertyExtensionElement = [[CMISExtensionElement alloc] initNodeWithName:name
                           namespaceUri:@"http://docs.oasis-open.org/ns/cmis/core/200908/" attributes:attributes children:propertyValues];
            [propertyExtensions addObject:aspectPropertyExtensionElement];
        }

        [alfrescoExtensions addObject: [[CMISExtensionElement alloc] initNodeWithName:@"properties"
                                          namespaceUri:@"http://www.alfresco.org" attributes:nil children:propertyExtensions]];
    }

    // Cmis doesn't understand aspects, so we must replace the objectTypeId if needed
    if ([typeProperties objectForKey:kCMISPropertyObjectTypeId] != nil)
    {
        [typeProperties setValue:mainTypeDefinition.id forKey:kCMISPropertyObjectTypeId];
    }

    // Convert regular type properties
    CMISProperties *result = [super convertProperties:typeProperties forObjectTypeId:mainTypeDefinition.id error:error];
    if (alfrescoExtensions.count > 0)
    {
        result.extensions = [NSArray arrayWithObject:[[CMISExtensionElement alloc] initNodeWithName:@"setAspects"
                                 namespaceUri:@"http://www.alfresco.org" attributes:nil children:alfrescoExtensions]];
    }

    return result;
}
 */

#pragma mark Helper methods

- (NSString *)stringFromDate:(NSDate *)date
{
    return [[CMISDateUtil defaultDateFormatter] stringFromDate:date];
}


@end