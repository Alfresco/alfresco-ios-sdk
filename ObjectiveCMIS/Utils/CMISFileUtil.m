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