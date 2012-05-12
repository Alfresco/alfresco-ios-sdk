//
// ObjectiveCMIS
//
// Created by Joram Barrez
//


#import "CMISFileUtil.h"


@implementation FileUtil

+ (void)appendToFileAtPath:(NSString *)filePath data:(NSData *)data
{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];

    if (fileHandle)
    {
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:data];
    }

    // Always clean up after the file is written to
    [fileHandle closeFile];
}

+ (long long)fileSizeForFileAtPath:(NSString *)filePath error:(NSError * *)outError
{
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:outError];

    if (*outError == nil)
    {
        NSNumber *fileSizeNumber = [attributes objectForKey:NSFileSize];
        return [fileSizeNumber longLongValue];
    }

    return 0LL;
}

@end