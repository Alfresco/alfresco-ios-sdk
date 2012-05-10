//
//  AlfrescoBase64Encoder.m
//  RemoteAPI
//
//  Created by Tijs Rademakers on 02/05/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISBase64Encoder.h"
#import "FileUtil.h"

static char *alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation CMISBase64Encoder

+(NSString *)stringByEncodingText:(NSData *)plainText
{
    NSString *result = [[NSString alloc] initWithData:[self dataByEncodingText:plainText] encoding:NSASCIIStringEncoding];
    return result;
}

+ (NSData *)dataByEncodingText:(NSData *)plainText
{
    uint encodedLength = (4 * (([plainText length] / 3) + (1 - (3 - ([plainText length] % 3)) / 3))) + 1;
    char *outputBuffer = malloc(encodedLength);
    unsigned char *inputBuffer = (unsigned char *) [plainText bytes];

    NSInteger i;
    NSInteger j = 0;
    int remain;

    for (i = 0; i < [plainText length]; i += 3)
    {
        remain = [plainText length] - i;

        outputBuffer[j++] = alphabet[(inputBuffer[i] & 0xFC) >> 2];
        outputBuffer[j++] = alphabet[((inputBuffer[i] & 0x03) << 4) |
                ((remain > 1) ? ((inputBuffer[i + 1] & 0xF0) >> 4) : 0)];

        if (remain > 1)
            outputBuffer[j++] = alphabet[((inputBuffer[i + 1] & 0x0F) << 2)
                    | ((remain > 2) ? ((inputBuffer[i + 2] & 0xC0) >> 6) : 0)];
        else
            outputBuffer[j++] = '=';

        if (remain > 2)
            outputBuffer[j++] = alphabet[inputBuffer[i + 2] & 0x3F];
        else
            outputBuffer[j++] = '=';
    }

    outputBuffer[j] = 0;

    NSData *result = [NSData dataWithBytes:outputBuffer length:j];
    free(outputBuffer);

    return result;
}


+ (void)encodeContentOfFile:(NSString *)sourceFilePath andAppendToFile:(NSString *)destinationFilePath
{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:sourceFilePath];
    if (fileHandle)
    {
        // Get the total file length
        [fileHandle seekToEndOfFile];
        unsigned long long fileLength = [fileHandle offsetInFile];

        // Set file offset to start of file
        unsigned long long currentOffset = 0ULL;

        // Read the data and append it to the file
        while (currentOffset < fileLength)
        {
            @autoreleasepool
            {
                [fileHandle seekToFileOffset:currentOffset];
                NSData *chunkOfData = [fileHandle readDataOfLength:32768]; // 32 kb, note that the base64 encoding will alloc this twice at a given point, so don't make it too high
                [FileUtil appendToFileAtPath:destinationFilePath data:[self dataByEncodingText:chunkOfData]];
                currentOffset += chunkOfData.length;
            }
        }

        // Release the file handle
        [fileHandle closeFile];
    }
    else
    {
        log(@"Could not create a file handle for %@", sourceFilePath);
    }
}

@end
