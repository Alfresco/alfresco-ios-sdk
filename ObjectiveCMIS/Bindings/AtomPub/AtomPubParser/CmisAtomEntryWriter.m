//
// Alfresco Focus
//
// Created by Joram Barrez
//


#import "CMISAtomEntryWriter.h"
#import "CMISBase64Encoder.h"
#import "CMISConstants.h"
#import "CMISFileUtil.h"

@implementation CMISAtomEntryWriter

@synthesize contentFilePath = _contentFilePath;
@synthesize mimeType = _mimeType;
@synthesize cmisProperties = _cmisProperties;

- (NSString *)filePathToGeneratedAtomEntry
{
    // First part of XML
    NSString *atomEntryXmlStart = [NSString stringWithFormat:
           @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
            "<entry xmlns=\"http://www.w3.org/2005/Atom\" xmlns:cmis=\"http://docs.oasis-open.org/ns/cmis/core/200908/\" xmlns:cmisra=\"http://docs.oasis-open.org/ns/cmis/restatom/200908/\"  >"
                "<id>urn:uuid:00000000-0000-0000-0000-00000000000</id>"
                "<title>%@</title>",
            [self.cmisProperties objectForKey:kCMISPropertyName]];

    // Write it already to the file
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd'T'HH-mm-ss-Z'"];
    NSString *resultFilePath = [NSString stringWithFormat:@"%@-%@",
                      [self.cmisProperties objectForKey:kCMISPropertyName], [formatter stringFromDate:[NSDate date]]];
    [[NSFileManager defaultManager] createFileAtPath:resultFilePath contents:[atomEntryXmlStart dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];

    if (self.contentFilePath)
    {

        NSString *contentXMLStart = [NSString stringWithFormat:@"<cmisra:content>""<cmisra:mediatype>%@</cmisra:mediatype>""<cmisra:base64>", self.mimeType];
        [FileUtil appendToFileAtPath:resultFilePath data:[contentXMLStart dataUsingEncoding:NSUTF8StringEncoding]];

        // Generate the base64 representation of the content
        [CMISBase64Encoder encodeContentOfFile:self.contentFilePath andAppendToFile:resultFilePath];

        NSString *contentXMLEnd = @"</cmisra:base64></cmisra:content>";
        [FileUtil appendToFileAtPath:resultFilePath data:[contentXMLEnd dataUsingEncoding:NSUTF8StringEncoding]];
    }

    // Add properties
    NSString *atomEntryPropertiesXml = [NSString stringWithFormat:@"<cmisra:object><cmis:properties>"
            "<cmis:propertyId propertyDefinitionId=\"cmis:objectTypeId\">""<cmis:value>%@</cmis:value>""</cmis:propertyId>"
            "<cmis:propertyString propertyDefinitionId=\"cmis:name\"><cmis:value>%@</cmis:value>""</cmis:propertyString>"
         "</cmis:properties>"
     "</cmisra:object></entry>", [self.cmisProperties objectForKey:kCMISPropertyObjectTypeId], [self.cmisProperties objectForKey:kCMISPropertyName]];

   [FileUtil appendToFileAtPath:resultFilePath data:[atomEntryPropertiesXml dataUsingEncoding:NSUTF8StringEncoding]];


    return resultFilePath;
}

@end