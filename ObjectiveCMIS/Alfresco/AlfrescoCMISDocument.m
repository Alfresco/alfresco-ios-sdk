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
// AlfrescoCMISDocument 
//
#import "AlfrescoCMISDocument.h"
#import "CMISSession.h"
#import "CMISConstants.h"
#import "CMISAtomPubConstants.h"
#import "CMISAtomParserUtil.h"

#define ALFRESCO_EXTENSION_ASPECTS @"aspects"
#define ALFRESCO_EXTENSION_APPLIED_ASPECTS @"appliedAspects"
#define ALFRESCO_EXTENSION_PROPERTIES @"properties"
#define ALFRESCO_EXTENSION_PROPERTY_VALUE @"value"

@interface AlfrescoCMISDocument ()

@property (nonatomic, strong, readwrite) NSString *objectType;

@end


@implementation AlfrescoCMISDocument

- (id)initWithObjectData:(CMISObjectData *)objectData withSession:(CMISSession *)session
{
    self = [super initWithObjectData:objectData withSession:session];
    if (self)
    {
        NSArray *alfrescoExtensions = [self extensionsForExtensionLevel:CMISExtensionLevelProperties];
        self.aspectTypes = [[NSMutableArray alloc] init];

        // We'll gather all the properties, and expose them as conveniently on the document
        NSMutableArray *propertyExtensionRootElements = [[NSMutableArray alloc] init];

        // Find all Alfresco aspects in the extensions
        if (alfrescoExtensions != nil && alfrescoExtensions.count > 0)
        {
            for (CMISExtensionElement *extensionElement in alfrescoExtensions)
            {
                if ([extensionElement.name isEqualToString:ALFRESCO_EXTENSION_ASPECTS])
                {
                    for (CMISExtensionElement *childExtensionElement in extensionElement.children)
                    {
                        if ([childExtensionElement.name isEqualToString:ALFRESCO_EXTENSION_APPLIED_ASPECTS])
                        {
                            [self.aspectTypes addObject:childExtensionElement.value];
                        }
                        else if ([childExtensionElement.name isEqualToString:ALFRESCO_EXTENSION_PROPERTIES])
                        {
                            [propertyExtensionRootElements addObject:childExtensionElement];
                        }
                    }
                }
            }
        }

        // Update object type id with the aspects
        if (self.aspectTypes.count > 0)
        {
            NSMutableString *objectTypeIdBuilder = [[NSMutableString alloc] init];
            [objectTypeIdBuilder appendString:@"cmis:document"];

            for (NSString *aspectTye in self.aspectTypes)
            {
                [objectTypeIdBuilder appendFormat:@", %@", aspectTye];
            }
        }

        // Convert all extended properties to 'real' properties
        for (CMISExtensionElement *propertyRootExtensionElement in propertyExtensionRootElements)
        {
            for (CMISExtensionElement *propertyExtension in propertyRootExtensionElement.children)
            {
                CMISPropertyData *propertyData = [[CMISPropertyData alloc] init];
                propertyData.identifier = [propertyExtension.attributes objectForKey:kCMISAtomEntryPropertyDefId];
                propertyData.displayName = [propertyExtension.attributes objectForKey:kCMISAtomEntryDisplayName];
                propertyData.queryName = [propertyExtension.attributes objectForKey:kCMISAtomEntryQueryName];
                propertyData.type = [CMISAtomParserUtil atomPubTypeToInternalType:propertyExtension.name];

                CMISExtensionElement *valueExtensionElement = [propertyExtension.children objectAtIndex:0];
                if (valueExtensionElement.value)
                {
                    propertyData.values = [CMISAtomParserUtil parsePropertyValue:valueExtensionElement.value withPropertyType:propertyExtension.name];
                }

                [self.properties addProperty:propertyData];
            }
        }


    }
    return self;
}

- (CMISObject *)updateProperties:(NSDictionary *)properties error:(NSError **)error
{
    // We need to 'prepare' the properties first to include all aspects
    NSMutableDictionary *aspectAwareProperties = nil;
    if (properties != nil)
    {
        aspectAwareProperties = [[NSMutableDictionary alloc] initWithDictionary:properties];

        NSMutableString *objectTypeIdBuilder = [[NSMutableString alloc] init];
        [objectTypeIdBuilder appendString:self.objectType];
        for (NSString *aspectTypeId in self.aspectTypes)
        {
            [objectTypeIdBuilder appendFormat:@", %@", aspectTypeId];
        }

        [aspectAwareProperties setValue:objectTypeIdBuilder forKey:kCMISPropertyObjectTypeId];
    }

    return [super updateProperties:aspectAwareProperties error:error];
}

- (BOOL)hasAspect:(NSString *)aspectTypeId
{
    for (NSString *aspect in self.aspectTypes)
    {
        if ([aspect isEqualToString:aspectTypeId])
        {
            return YES;
        }
    }
    return NO;
}


@end