/*
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
 */


#import "CMISAtomEntryWriter.h"
#import "CMISBase64Encoder.h"
#import "CMISConstants.h"
#import "CMISFileUtil.h"
#import "CMISProperties.h"
#import "CMISISO8601DateFormatter.h"

@interface CMISAtomEntryWriter ()

@property (nonatomic, strong) NSMutableString *internalXml;
@property (nonatomic, strong) NSString *internalFilePath;

@end

@implementation CMISAtomEntryWriter

// Exposed properties
@synthesize contentFilePath = _contentFilePath;
@synthesize mimeType = _mimeType;
@synthesize cmisProperties = _cmisProperties;
@synthesize generateXmlInMemory = _generateXmlInMemory;

// Internal properties
@synthesize internalXml = _internalXml;
@synthesize internalFilePath = _internalFilePath;


- (NSString *)generateAtomEntryXml
{
    [self addEntryStartElement];

    if (self.contentFilePath)
    {
        [self addContent];
    }

    [self addProperties];

    // Return result
    if (self.generateXmlInMemory)
    {
        return self.internalXml;
    }
    else
    {
        return self.internalFilePath;
    }
}

- (void)addEntryStartElement
{
    NSString *atomEntryXmlStart = [NSString stringWithFormat:
           @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
            "<entry xmlns=\"http://www.w3.org/2005/Atom\" xmlns:cmis=\"http://docs.oasis-open.org/ns/cmis/core/200908/\" xmlns:cmisra=\"http://docs.oasis-open.org/ns/cmis/restatom/200908/\"  >"
                "<id>urn:uuid:00000000-0000-0000-0000-00000000000</id>"
                "<title>%@</title>",
            [self.cmisProperties propertyValueForId:kCMISPropertyName]];

    [self appendStringToReturnResult:atomEntryXmlStart];
}

- (void)addContent
{
    NSString *contentXMLStart = [NSString stringWithFormat:@"<cmisra:content>""<cmisra:mediatype>%@</cmisra:mediatype>""<cmisra:base64>", self.mimeType];
    [self appendStringToReturnResult:contentXMLStart];

    // Generate the base64 representation of the content
    if (self.generateXmlInMemory)
    {
        NSString *encodedContent = [CMISBase64Encoder encodeContentOfFile:self.contentFilePath];
        [self appendToInMemoryXml:encodedContent];
    }
    else
    {
        [CMISBase64Encoder encodeContentOfFile:self.contentFilePath andAppendToFile:self.internalFilePath];
    }

    NSString *contentXMLEnd = @"</cmisra:base64></cmisra:content>";
    [self appendStringToReturnResult:contentXMLEnd];
}

- (void)addProperties
{
    [self appendStringToReturnResult:@"<cmisra:object><cmis:properties>"];

    // TODO: support for multi valued properties
    for (id propertyKey in self.cmisProperties.propertiesDictionary)
    {
        CMISPropertyData *propertyData = [self.cmisProperties propertyForId:propertyKey];
        switch (propertyData.type)
        {
            case CMISPropertyTypeString:
            {
                [self appendStringToReturnResult:[NSString stringWithFormat:@"<cmis:propertyString propertyDefinitionId=\"%@\"><cmis:value>%@</cmis:value></cmis:propertyString>",
                                propertyData.identifier, propertyData.propertyStringValue]];
                break;
            }
            case CMISPropertyTypeInteger:
            {
                [self appendStringToReturnResult:[NSString stringWithFormat:@"<cmis:propertyInteger propertyDefinitionId=\"%@\"><cmis:value>%d</cmis:value></cmis:propertyInteger>",
                                propertyData.identifier, propertyData.propertyIntegerValue.intValue]];
                break;
            }
            case CMISPropertyTypeBoolean:
            {
                [self appendStringToReturnResult:[NSString stringWithFormat:@"<cmis:propertyBoolean propertyDefinitionId=\"%@\"><cmis:value>%@</cmis:value></cmis:propertyBoolean>",
                                propertyData.identifier,
                                [propertyData.propertyBooleanValue isEqualToNumber:[NSNumber numberWithBool:YES]] ? @"true" : @"false"]];
                break;
            }
            case CMISPropertyTypeId:
            {
                [self appendStringToReturnResult:[NSString stringWithFormat:@"<cmis:propertyId propertyDefinitionId=\"%@\"><cmis:value>%@</cmis:value></cmis:propertyId>",
                                propertyData.identifier, propertyData.propertyIdValue]];
                break;
            }
            case CMISPropertyTypeDateTime:
            {
                CMISISO8601DateFormatter *dateFormatter = [[CMISISO8601DateFormatter alloc] init];
                [self appendStringToReturnResult:[NSString stringWithFormat:@"<cmis:propertyDateTime propertyDefinitionId=\"%@\"><cmis:value>%@</cmis:value></cmis:propertyDateTime>",
                                propertyData.identifier, [dateFormatter stringFromDate:propertyData.propertyDateTimeValue]]];
                break;
            }
            default:
            {
                log(@"Property type did not match: %@", propertyData.type);
                break;
            }
        }
    }

    // Add extensions to properties
    if (self.cmisProperties.extensions != nil)
    {
        [self addExtensionElements:self.cmisProperties.extensions];
    }

    [self appendStringToReturnResult:@"</cmis:properties></cmisra:object></entry>"];
}

- (void) addExtensionElements:(NSArray *)extensionElements
{
    for (CMISExtensionElement *extensionElement in extensionElements)
    {
        // Opening XML tag
        [self appendStringToReturnResult:[NSString stringWithFormat:@"<%@ xmlns=\"%@\"", extensionElement.name, extensionElement.namespaceUri]];

        // Attributes
        if (extensionElement.attributes != nil)
        {
            for (NSString *attributeName in extensionElement.attributes)
            {
                [self appendStringToReturnResult:[NSString stringWithFormat:@" %@=\"%@\"", attributeName, [extensionElement.attributes objectForKey:attributeName]]];
            }
        }
        [self appendStringToReturnResult:@">"];

        // Value
        if (extensionElement.value != nil)
        {
            [self appendStringToReturnResult:extensionElement.value];
        }

        // Children
        if (extensionElement.children != nil && extensionElement.children.count > 0)
        {
            [self addExtensionElements:extensionElement.children];
        }

        // Closing XML tag
        [self appendStringToReturnResult:[NSString stringWithFormat:@"</%@>", extensionElement.name]];
    }
}

#pragma mark Helper methods

- (void)appendStringToReturnResult:(NSString *)string
{
    if (self.generateXmlInMemory)
    {
        [self appendToInMemoryXml:string];
    }
    else
    {
        [self appendToFile:string];
    }
}

- (void)appendToInMemoryXml:(NSString *)string
{
    if (self.internalXml == nil)
    {
        self.internalXml = [[NSMutableString alloc] initWithString:string];
    }
    else
    {
        [self.internalXml appendString:string];
    }
}


- (void)appendToFile:(NSString *)string
{
    if (self.internalFilePath == nil)
    {
        // Store the file in the temporary folder
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH-mm-ss-Z'"];
        self.internalFilePath = [NSString stringWithFormat:@"%@/%@-%@",
                        NSTemporaryDirectory(),
                        [self.cmisProperties propertyValueForId:kCMISPropertyName],
                        [formatter stringFromDate:[NSDate date]]];

        BOOL fileCreated = [[NSFileManager defaultManager] createFileAtPath:self.internalFilePath
                                          contents:[string dataUsingEncoding:NSUTF8StringEncoding]
                attributes:nil];
        if (!fileCreated)
        {
            log(@"Error: could not create file %@", self.internalFilePath);
        }
    }
    else {
        [FileUtil appendToFileAtPath:self.internalFilePath data:[string dataUsingEncoding:NSUTF8StringEncoding]];
    }

}


@end