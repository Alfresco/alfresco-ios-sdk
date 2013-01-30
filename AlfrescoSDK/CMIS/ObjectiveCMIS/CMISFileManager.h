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

@interface CMISFileManager : NSObject

+(id)defaultManager;


-(id)initWithClassName:(NSString *)className;

/**
 Call this function to get the temporary directory for the app
 */
- (NSString *)temporaryDirectory;

/*
 Call this to create a file with data passed in at a given location
 @param path  The full path where the file is to be created
 @param data  The content of the file
 @param error Error, will be nil if ok.
 @returns bool - True if the file was created successfully
 */
- (BOOL)createFileAtPath:(NSString *)path contents:(NSData *)data error:(NSError **)error;

/*
 Call this to remove an item at a given path
 @param path The full file path of the item to be removed
 @param error The error. Will be nil, if successful
 @returns bool - True if the file/folder was removed successfully
 */
- (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error;

/*
 Call this to return the attributes of a given item at a path
 @param path The full file path
 @param error The error, will be nil if successful
 @returns dictionary - dictionary containing fileSize, isFolder and lastModifiedDate
 */
- (NSDictionary *)attributesOfItemAtPath:(NSString *)path error:(NSError **)error;

/*
 Call this to append data to the file at a given path
 @param filePath The full file path
 @param data the content to append the file with
 */
- (void)appendToFileAtPath:(NSString *)filePath data:(NSData *)data;

/*
 Call this to retrieve the internal filePath from a file name
 @param fileName The file name
 @returns string - the filePath in relation to a given fileName
 */
- (NSString *)internalFilePathFromName:(NSString *)fileName;

/*
 @param filePath The full file path for which an input stream will be created
 @return input stream object for given file path. May be a customised extension to NSInputStream
 */
- (id)inputStreamWithFileAtPath:(NSString *)filePath;

/*
 @param inputStream The input stream from which the data will be taken for encoding
 @param filePath The file path to which the encoded data will be appended
 */
- (void)encodeContentFromInputStream:(NSInputStream *)inputStream andAppendToFile:(NSString *)filePath;

@end
