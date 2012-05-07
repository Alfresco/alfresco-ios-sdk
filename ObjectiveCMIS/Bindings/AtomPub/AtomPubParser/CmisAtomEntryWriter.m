//
// Alfresco Focus
//
// Created by Joram Barrez
//


#import "CMISAtomEntryWriter.h"
#import "CMISBase64Encoder.h"
#import "CMISConstants.h"


@implementation CMISAtomEntryWriter

@synthesize filePath = _filePath;
@synthesize cmisProperties = _cmisProperties;

- (NSData *)generateAtomEntry
{
    // TODO: discuss .... no xml writer in default sdk ... no 3th party ... ?

    NSMutableString *string = [[NSMutableString alloc] init];
    [string appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
    [string appendString:@"<entry xmlns=\"http://www.w3.org/2005/Atom\" xmlns:cmis=\"http://docs.oasis-open.org/ns/cmis/core/200908/\" xmlns:cmisra=\"http://docs.oasis-open.org/ns/cmis/restatom/200908/\"  >"];
    [string appendString:@"<id>urn:uuid:00000000-0000-0000-0000-00000000000</id>"];
    [string appendString:[NSString stringWithFormat:@"<title>%@</title>", [self.cmisProperties objectForKey:kCMISPropertyName]]];

    [string appendString:@"<cmisra:content>"];
    [string appendString:@"<cmisra:mediatype>text/plain</cmisra:mediatype>"];  // TODO: get real mimetype!
    [string appendString:[NSString stringWithFormat:@"<cmisra:base64>%@</cmisra:base64>",[self generateBase64ForFilePath]]];
    [string appendString:@"</cmisra:content>"];

    [string appendString:@"</entry>"];

    return [string dataUsingEncoding:NSASCIIStringEncoding];
}

- (NSString *)generateBase64ForFilePath
{
    NSData *fileData = [NSData dataWithContentsOfFile:self.filePath];
    return [CMISBase64Encoder encode:fileData];
}

@end