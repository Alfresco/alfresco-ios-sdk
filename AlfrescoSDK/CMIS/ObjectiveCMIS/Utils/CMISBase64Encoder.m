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

#import "CMISBase64Encoder.h"
#import "CMISFileUtil.h"
#import "CMISLog.h"

static char *alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation CMISBase64Encoder

+(NSString *)stringByEncodingText:(NSData *)plainText
{
    NSString *result = [[NSString alloc] initWithData:[self dataByEncodingText:plainText] encoding:NSUTF8StringEncoding];
    return result;
}

+ (NSData *)dataByEncodingText:(NSData *)plainText
{
    NSUInteger encodedLength = (4 * (([plainText length] / 3) + (1 - (3 - ([plainText length] % 3)) / 3)));
    NSMutableData *encodedData = [[NSMutableData alloc] initWithLength:encodedLength];
    char *outputBuffer = encodedData.mutableBytes;
    unsigned char *inputBuffer = (unsigned char *) [plainText bytes];

    NSInteger i;
    NSInteger j = 0;
    NSUInteger remain;

    for (i = 0; i < [plainText length]; i += 3) {
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

    return encodedData;
}

+ (NSString *)encodeContentOfFile:(NSString *)sourceFilePath
{
    NSMutableString *result = [[NSMutableString alloc] init];

    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:sourceFilePath];
    if (fileHandle) {
        // Get the total file length
        [fileHandle seekToEndOfFile];
        unsigned long long fileLength = [fileHandle offsetInFile];

        // Set file offset to start of file
        unsigned long long currentOffset = 0ULL;

        // Read the data and append it to the file
        while (currentOffset < fileLength) {
            @autoreleasepool {
                [fileHandle seekToFileOffset:currentOffset];
                NSData *chunkOfData = [fileHandle readDataOfLength:32768];
                [result appendString:[self stringByEncodingText:chunkOfData]];
                currentOffset += chunkOfData.length;
            }
        }

        // Release the file handle
        [fileHandle closeFile];
    } else {
        CMISLogError(@"Could not create a file handle for %@", sourceFilePath);
    }

    return result;
}

+ (NSString *)encodeContentFromInputStream:(NSInputStream*)inputStream
{
    NSMutableString *result = [[NSMutableString alloc] init];

    while ([inputStream hasBytesAvailable]) {
        @autoreleasepool {
            NSMutableData *chunkOfData = [[NSMutableData alloc] initWithLength:524288]; // 512 kb
            NSInteger length = [inputStream read:chunkOfData.mutableBytes maxLength:chunkOfData.length];
            if (length > 0) {
                [chunkOfData setLength:length];
                [result appendString:[self stringByEncodingText:chunkOfData]];
            } else {
                break;
            }
        }
    }
    return result;
}


+ (void)encodeContentOfFile:(NSString *)sourceFilePath appendToFile:(NSString *)destinationFilePath
{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:sourceFilePath];
    if (fileHandle) {
        // Get the total file length
        [fileHandle seekToEndOfFile];
        unsigned long long fileLength = [fileHandle offsetInFile];

        // Set file offset to start of file
        unsigned long long currentOffset = 0ULL;

        // Read the data and append it to the file
        while (currentOffset < fileLength) {
            @autoreleasepool {
                [fileHandle seekToFileOffset:currentOffset];
                NSData *chunkOfData = [fileHandle readDataOfLength:524288]; // 512 kb
                [CMISFileUtil appendToFileAtPath:destinationFilePath data:[self dataByEncodingText:chunkOfData]];
                currentOffset += chunkOfData.length;
            }
        }

        // Release the file handle
        [fileHandle closeFile];
    } else {
        CMISLogError(@"Could not create a file handle for %@", sourceFilePath);
    }
}

+ (void)encodeContentFromInputStream:(NSInputStream*)inputStream appendToFile:(NSString *)destinationFilePath
{
    [inputStream open];
    
    while ([inputStream hasBytesAvailable]) {
        @autoreleasepool {
            NSMutableData *chunkOfData = [[NSMutableData alloc] initWithLength:524288]; // 512 kb
            NSInteger length = [inputStream read:chunkOfData.mutableBytes maxLength:chunkOfData.length];
            if (length > 0) {
                [chunkOfData setLength:length];
                NSData *encodedChunkOfData = [self dataByEncodingText:chunkOfData];
                [CMISFileUtil appendToFileAtPath:destinationFilePath data:encodedChunkOfData];
            } else {
                break;
            }
        }
    }
    
    [inputStream close];
}


@end
