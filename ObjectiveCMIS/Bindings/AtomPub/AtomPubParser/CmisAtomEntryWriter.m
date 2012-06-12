//
// ObjectiveCMIS
//
// Created by Joram Barrez
//


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
    // First part of XML
    NSString *atomEntryXmlStart = [NSString stringWithFormat:
           @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
            "<entry xmlns=\"http://www.w3.org/2005/Atom\" xmlns:cmis=\"http://docs.oasis-open.org/ns/cmis/core/200908/\" xmlns:cmisra=\"http://docs.oasis-open.org/ns/cmis/restatom/200908/\"  >"
                "<id>urn:uuid:00000000-0000-0000-0000-00000000000</id>"
                "<title>%@</title>",
            [self.cmisProperties propertyValueForId:kCMISPropertyName]];

    [self appendStringToReturnResult:atomEntryXmlStart];

    if (self.contentFilePath)
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

    // Add properties

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

    [self appendStringToReturnResult:@"</cmis:properties></cmisra:object></entry>"];

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