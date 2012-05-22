//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISUpdateObjectAtomEntryWriter.h"
#import "CMISProperties.h"
#import "CMISConstants.h"
#import "ISO8601DateFormatter.h"


@implementation CMISUpdateObjectAtomEntryWriter

@synthesize properties = _properties;

- (NSString *)generateAtomEntryXml
{
    NSMutableString *xml = [[NSMutableString alloc] init];

    [xml appendString:
           @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
            "<entry xmlns=\"http://www.w3.org/2005/Atom\" xmlns:cmis=\"http://docs.oasis-open.org/ns/cmis/core/200908/\" xmlns:cmisra=\"http://docs.oasis-open.org/ns/cmis/restatom/200908/\"  >"
                "<id>urn:uuid:00000000-0000-0000-0000-00000000000</id>"
                "<cmisra:object>"
                  "<cmis:properties>"];

    // TODO: support for multi valued properties
    for (id propertyKey in self.properties.propertiesDictionary)
    {
        CMISPropertyData *propertyData = [self.properties propertyForId:propertyKey];
        switch (propertyData.type)
        {
            case CMISPropertyTypeString:
            {
                [xml appendFormat:@"<cmis:propertyString propertyDefinitionId=\"%@\"><cmis:value>%@</cmis:value></cmis:propertyString>",
                                propertyData.identifier, propertyData.propertyStringValue];
                break;
            }
            case CMISPropertyTypeInteger:
            {
                [xml appendFormat:@"<cmis:propertyInteger propertyDefinitionId=\"%@\"><cmis:value>%d</cmis:value></cmis:propertyInteger>",
                                propertyData.identifier, propertyData.propertyIntegerValue.intValue];
                break;
            }
            case CMISPropertyTypeBoolean:
            {
                [xml appendFormat:@"<cmis:propertyBoolean propertyDefinitionId=\"%@\"><cmis:value>%@</cmis:value></cmis:propertyBoolean>",
                                propertyData.identifier,
                                [propertyData.propertyBooleanValue isEqualToNumber:[NSNumber numberWithBool:YES]] ? @"true" : @"false"];
                break;
            }
            case CMISPropertyTypeId:
            {
                [xml appendFormat:@"<cmis:propertyId propertyDefinitionId=\"%@\"><cmis:value>%@</cmis:value></cmis:propertyId>",
                                propertyData.identifier, propertyData.propertyStringValue];
                break;
            }
            case CMISPropertyTypeDateTime:
            {
                ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
                [xml appendFormat:@"<cmis:propertyDateTime propertyDefinitionId=\"%@\"><cmis:value>%@</cmis:value></cmis:propertyDateTime>",
                                propertyData.identifier, [dateFormatter stringFromDate:propertyData.propertyDateTimeValue]];
                break;
            }
            default:
            {
                log(@"Property type did not match: %@", propertyData.type);
                break;
            }
        }
    }

    [xml appendString:@"</cmis:properties></cmisra:object></entry>"];

    return xml;
}


@end