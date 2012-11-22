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

@interface CMISBase64Encoder : NSObject

+ (NSString *)stringByEncodingText:(NSData *)plainText;

+ (NSData *)dataByEncodingText:(NSData *)plainText;

+ (NSString *)encodeContentOfFile:(NSString *)sourceFilePath;

+ (NSString *)encodeContentFromInputStream:(NSInputStream*)inputStream;

+ (void)encodeContentOfFile:(NSString *)sourceFilePath andAppendToFile:(NSString *)destinationFilePath;

+ (void)encodeContentFromInputStream:(NSInputStream*)inputStream andAppendToFile:(NSString *)destinationFilePath;

@end
