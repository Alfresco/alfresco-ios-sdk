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


#import "CMISAtomEntryWriter.h"
#import "CMISBase64Encoder.h"
#import "CMISConstants.h"
#import "CMISFileUtil.h"
#import "CMISProperties.h"
#import "CMISDateUtil.h"
#import "CMISLog.h"


@implementation NSString (XMLEntities)

- (NSString*)stringByAddingXMLEntities {
    if ([self rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"&<>\"'"] options:NSLiteralSearch].location != NSNotFound) {
        NSMutableString *mutableString = [self mutableCopy];

        [mutableString replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:NSMakeRange(0, mutableString.length)];
        [mutableString replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSLiteralSearch range:NSMakeRange(0, mutableString.length)];
        [mutableString replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSLiteralSearch range:NSMakeRange(0, mutableString.length)];
        [mutableString replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, mutableString.length)];
        [mutableString replaceOccurrencesOfString:@"'" withString:@"&apos;" options:NSLiteralSearch range:NSMakeRange(0, mutableString.length)];
    
        return mutableString;
        
    } else {
        return self;
    }
}

@end

@interface CMISAtomEntryWriter ()

@property (nonatomic, strong) NSMutableString *internalXml;
@property (nonatomic, strong) NSString *internalFilePath;
@property (nonatomic, strong) NSString *internalFileNameProperty;
- (NSString *)xmlExtensionElements:(NSArray *)extensionElements;
@end

@implementation CMISAtomEntryWriter

// Exposed properties
@synthesize contentFilePath = _contentFilePath;
@synthesize inputStream = _inputStream;
@synthesize mimeType = _mimeType;
@synthesize cmisProperties = _cmisProperties;
@synthesize generateXmlInMemory = _generateXmlInMemory;

// Internal properties
@synthesize internalXml = _internalXml;
@synthesize internalFilePath = _internalFilePath;
@synthesize internalFileNameProperty = _internalFileNameProperty;

- (NSString *)xmlStartElement
{
    NSString *startElement = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                            "<entry xmlns=\"http://www.w3.org/2005/Atom\" xmlns:cmis=\"http://docs.oasis-open.org/ns/cmis/core/200908/\" xmlns:cmisra=\"http://docs.oasis-open.org/ns/cmis/restatom/200908/\"  >"
                            "<id>urn:uuid:00000000-0000-0000-0000-00000000000</id>";
    self.internalFileNameProperty = [self.cmisProperties propertyValueForId:kCMISPropertyName];
    
    // Determine format of title element depending on nil status of namePropertyValue
    if (nil != self.internalFileNameProperty)
    {
        startElement = [startElement stringByAppendingFormat:@"<title>%@</title>", [self.internalFileNameProperty stringByAddingXMLEntities]];
    }
    else
    {
        startElement = [startElement stringByAppendingString:@"<title/>"];
    }
    return startElement;
}

- (NSString *)xmlContentStartElement
{
    return [NSString stringWithFormat:@"<cmisra:content>""<chemistry:filename xmlns:chemistry=\"http://chemistry.apache.org/\">%@</chemistry:filename><cmisra:mediatype>%@</cmisra:mediatype>""<cmisra:base64>", [self.internalFileNameProperty stringByAddingXMLEntities], self.mimeType]; // set <chemistry:filename> to write name also in (readonly) filename property of repository
    
}

- (NSString *)xmlContentEndElement
{
    return @"</cmisra:base64></cmisra:content>";
}

- (NSString *)xmlPropertiesElements
{
    NSMutableString *properties = [NSMutableString string];
    [properties appendString:@"<cmisra:object><cmis:properties>"];
    
    // TODO: support for multi valued properties
    for (id propertyKey in self.cmisProperties.propertiesDictionary)
    {
        CMISPropertyData *propertyData = [self.cmisProperties propertyForId:propertyKey];
        switch (propertyData.type)
        {
            case CMISPropertyTypeString:
            {
                [properties appendString:[NSString stringWithFormat:@"<cmis:propertyString propertyDefinitionId=\"%@\">",
                                          [propertyData.identifier stringByAddingXMLEntities]]];
                
                for (NSString *propertyStringValue in propertyData.values) {
                    [properties appendString:[NSString stringWithFormat:@"<cmis:value>%@</cmis:value>", [propertyStringValue stringByAddingXMLEntities]]];
                }
                [properties appendString:@"</cmis:propertyString>"];
                break;
            }
            case CMISPropertyTypeInteger:
            {
                [properties appendString:[NSString stringWithFormat:@"<cmis:propertyInteger propertyDefinitionId=\"%@\">",
                                          [propertyData.identifier stringByAddingXMLEntities]]];
                
                for (NSNumber *propertyIntegerValue in propertyData.values) {
                    [properties appendString:[NSString stringWithFormat:@"<cmis:value>%@</cmis:value>", propertyIntegerValue.stringValue]];
                }
                [properties appendString:@"</cmis:propertyInteger>"];
                break;
            }
            case CMISPropertyTypeDecimal:
            {
                [properties appendString:[NSString stringWithFormat:@"<cmis:propertyDecimal propertyDefinitionId=\"%@\">",
                                          [propertyData.identifier stringByAddingXMLEntities]]];
                
                for (NSNumber *propertyDecimalValue in propertyData.values) {
                    [properties appendString:[NSString stringWithFormat:@"<cmis:value>%@</cmis:value>", propertyDecimalValue.stringValue]];
                }
                [properties appendString:@"</cmis:propertyDecimal>"];
                break;
            }
            case CMISPropertyTypeBoolean:
            {
                [properties appendString:[NSString stringWithFormat:@"<cmis:propertyBoolean propertyDefinitionId=\"%@\">",
                                          [propertyData.identifier stringByAddingXMLEntities]]];
                
                for (NSNumber *propertyBooleanValue in propertyData.values) {
                    [properties appendString:[NSString stringWithFormat:@"<cmis:value>%@</cmis:value>",
                                              propertyBooleanValue.boolValue ? @"true" : @"false"]];
                }
                [properties appendString:@"</cmis:propertyBoolean>"];
                break;
            }
            case CMISPropertyTypeId:
            {
                [properties appendString:[NSString stringWithFormat:@"<cmis:propertyId propertyDefinitionId=\"%@\">",
                                          [propertyData.identifier stringByAddingXMLEntities]]];
                
                for (NSString *propertyIdValue in propertyData.values) {
                    [properties appendString:[NSString stringWithFormat:@"<cmis:value>%@</cmis:value>", [propertyIdValue stringByAddingXMLEntities]]];
                }
                [properties appendString:@"</cmis:propertyId>"];
                break;
            }
            case CMISPropertyTypeDateTime:
            {
                [properties appendString:[NSString stringWithFormat:@"<cmis:propertyDateTime propertyDefinitionId=\"%@\">",
                                          [propertyData.identifier stringByAddingXMLEntities]]];
                
                for (NSDate *propertyDateTimeValue in propertyData.values) {
                    [properties appendString:[NSString stringWithFormat:@"<cmis:value>%@</cmis:value>", [CMISDateUtil stringFromDate:propertyDateTimeValue]]];
                }
                [properties appendString:@"</cmis:propertyDateTime>"];
                break;
            }
            case CMISPropertyTypeUri:
            {
                [properties appendString:[NSString stringWithFormat:@"<cmis:propertyUri propertyDefinitionId=\"%@\">",
                                          [propertyData.identifier stringByAddingXMLEntities]]];
                
                for (NSURL *propertyUriValue in propertyData.values) {
                    [properties appendString:[NSString stringWithFormat:@"<cmis:value>%@</cmis:value>", [[propertyUriValue path] stringByAddingXMLEntities]]];
                }
                [properties appendString:@"</cmis:propertyUri>"];
                break;
            }
            case CMISPropertyTypeHtml:
            {
                [properties appendString:[NSString stringWithFormat:@"<cmis:propertyHtml propertyDefinitionId=\"%@\">",
                                          [propertyData.identifier stringByAddingXMLEntities]]];
                
                for (NSString *propertyHtmlValue in propertyData.values) {
                    [properties appendString:[NSString stringWithFormat:@"<cmis:value>%@</cmis:value>", [propertyHtmlValue stringByAddingXMLEntities]]];
                }
                [properties appendString:@"</cmis:propertyHtml>"];
                break;
            }
            default:
            {
                CMISLogDebug(@"Property type did not match: %d", (int)propertyData.type);
                break;
            }
        }
    }
    
    // Add extensions to properties
    if (self.cmisProperties.extensions != nil)
    {
        [properties appendString:[self xmlExtensionElements:self.cmisProperties.extensions]];
//        [self xmlExtensionElements:self.cmisProperties.extensions];
    }
    [properties appendString:@"</cmis:properties></cmisra:object></entry>"];
    
    return properties;
}

- (NSString *)xmlExtensionElements:(NSArray *)extensionElements
{
    NSMutableString *extensions = [NSMutableString string];
    for (CMISExtensionElement *extensionElement in extensionElements)
    {
        // Opening XML tag
        [extensions appendString:[NSString stringWithFormat:@"<%@ xmlns=\"%@\"", extensionElement.name, extensionElement.namespaceUri]];
        
        // Attributes
        if (extensionElement.attributes != nil)
        {
            for (NSString *attributeName in extensionElement.attributes)
            {
                [extensions appendString:[NSString stringWithFormat:@" %@=\"%@\"",
                                          [attributeName stringByAddingXMLEntities],
                                          [[extensionElement.attributes objectForKey:attributeName] stringByAddingXMLEntities]]];
            }
        }
        [extensions appendString:@">"];
        
        // Value
        if (extensionElement.value != nil)
        {
            [extensions appendString:[extensionElement.value stringByAddingXMLEntities]];
        }
        
        // Children
        if (extensionElement.children != nil && extensionElement.children.count > 0)
        {
            [extensions appendString:[self xmlExtensionElements:extensionElement.children]];
        }
        
        // Closing XML tag
        [extensions appendString:[NSString stringWithFormat:@"</%@>", extensionElement.name]];
    }
    return extensions;
}


- (NSString *)generateAtomEntryXml
{
    [self addEntryStartElement];
    
    if (self.contentFilePath || self.inputStream)
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
    [self appendStringToReturnResult:[self xmlStartElement]];
}

- (void)addContent
{
    [self appendStringToReturnResult:[self xmlContentStartElement]];

    // Generate the base64 representation of the content
    if (self.contentFilePath) {
        if (self.generateXmlInMemory) {
            NSString *encodedContent = [CMISBase64Encoder encodeContentOfFile:self.contentFilePath];
            [self appendToInMemoryXml:encodedContent];
        } else {
            [CMISBase64Encoder encodeContentOfFile:self.contentFilePath appendToFile:self.internalFilePath];
        }
    } else if (self.inputStream) {
        if (self.generateXmlInMemory)
        {
            NSString *encodedContent = [CMISBase64Encoder encodeContentFromInputStream:self.inputStream];
            [self appendToInMemoryXml:encodedContent];
        } else {
            [CMISBase64Encoder encodeContentFromInputStream:self.inputStream appendToFile:self.internalFilePath];
        }
    }

    [self appendStringToReturnResult:[self xmlContentEndElement]];
}

- (void)addProperties
{
    [self appendStringToReturnResult:[self xmlPropertiesElements]];
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
            CMISLogError(@"Error: could not create file %@", self.internalFilePath);
        }
    }
    else {
        [CMISFileUtil appendToFileAtPath:self.internalFilePath data:[string dataUsingEncoding:NSUTF8StringEncoding]];
    }

}


@end