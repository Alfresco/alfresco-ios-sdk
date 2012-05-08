//
// Alfresco Focus
//
// Created by Joram Barrez
//


#import "CMISAtomEntryWriter.h"
#import "CMISBase64Encoder.h"
#import "CMISConstants.h"
#import "FileUtil.h"

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
                "<title>%@</title>"
                "<cmisra:content>"
                    "<cmisra:mediatype>%@</cmisra:mediatype>"
                    "<cmisra:base64>",
            [self.cmisProperties objectForKey:kCMISPropertyName], self.mimeType];

    // Write it already to the file
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd'T'HH-mm-ss-Z'"];
    NSString *resultFilePath = [NSString stringWithFormat:@"%@-%@",
                      [self.cmisProperties objectForKey:kCMISPropertyName], [formatter stringFromDate:[NSDate date]]];
    [[NSFileManager defaultManager] createFileAtPath:resultFilePath contents:[atomEntryXmlStart dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];

    // Generate the base64 representation of the content
    [CMISBase64Encoder encodeContentOfFile:self.contentFilePath andAppendToFile:resultFilePath];

    // Add the last part of the xml
    NSString *atomEntryXmlEnd = @"</cmisra:base64></cmisra:content></entry>";
   [FileUtil appendToFileAtPath:resultFilePath data:[atomEntryXmlEnd dataUsingEncoding:NSUTF8StringEncoding]];


    return resultFilePath;
}

@end