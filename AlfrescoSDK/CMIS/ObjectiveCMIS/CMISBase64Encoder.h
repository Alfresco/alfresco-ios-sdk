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

#import <Foundation/Foundation.h>
#import "CMISFileUtil.h"

@interface CMISBase64Encoder : NSObject 

+ (NSString *)stringByEncodingText:(NSData *)plainText;

+ (NSData *)dataByEncodingText:(NSData *)plainText;

+ (NSString *)encodeContentOfFile:(NSString *)sourceFilePath;

+ (void)encodeContentOfFile:(NSString *)sourceFilePath andAppendToFile:(NSString *)destinationFilePath;

+ (NSString *)encodeContentFromInputStream:(id)inputStream;

/*
 @param inputStream The input stream from which the data will be taken for encoding
 @param filePath The file path to which the encoded data will be appended
 */
+ (void)encodeContentFromInputStream:(NSInputStream *)inputStream andAppendToFile:(NSString *)filePath;

@end
