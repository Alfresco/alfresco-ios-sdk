//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISUpdateObjectAtomEntryWriter.h"
#import "CMISProperties.h"
#import "CMISConstants.h"


@implementation CMISUpdateObjectAtomEntryWriter

@synthesize properties = _properties;

- (NSString *)generateAtomEntryXml
{
    NSMutableString *xml = [[NSMutableString alloc] init];

//    [xml appendFormat:
//           @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
//            "<entry xmlns=\"http://www.w3.org/2005/Atom\" xmlns:cmis=\"http://docs.oasis-open.org/ns/cmis/core/200908/\" xmlns:cmisra=\"http://docs.oasis-open.org/ns/cmis/restatom/200908/\"  >"
//                "<id>urn:uuid:00000000-0000-0000-0000-00000000000</id>"
//                "<title>%@</title>"
//                "<cmisra:object>"
//                  "<cmis:properties>",
//            [self.properties propertyForId:kCMISPropertyName]];
//
//    // TODO: support for multi valued properties
//    for (id propertyKey in self.properties.properties)
//    {
//        id propertyValue = [[self.properties.properties objectForKey:propertyKey] firstValue];
//        if ([propertyValue class] == [NSString class])
//        {
//            [xml appendFormat:@"<cmis:propertyString propertyDefinitionId=\"cmis:name\"><cmis:value>%@</cmis:value>""</cmis:propertyString>", propertyValue];
//        }
//
//    }
//
//
//
//    // Add properties
//    NSString *atomEntryPropertiesXml = [NSString stringWithFormat:@""
//            "<cmis:propertyId propertyDefinitionId=\"cmis:objectTypeId\">""<cmis:value>%@</cmis:value>""</cmis:propertyId>"
//
//         "</cmis:properties>"
//     "</cmisra:object></entry>", [self.cmisProperties objectForKey:kCMISPropertyObjectTypeId], [self.cmisProperties objectForKey:kCMISPropertyName]];

    return xml;
}


@end