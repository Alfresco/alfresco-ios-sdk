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

#import "CMISFileableObject.h"

@class CMISOperationContext;
@class CMISRequest;

@interface CMISDocument : CMISFileableObject <NSURLConnectionDataDelegate>

@property (nonatomic, strong, readonly) NSString *contentStreamId;
@property (nonatomic, strong, readonly) NSString *contentStreamFileName;
@property (nonatomic, strong, readonly) NSString *contentStreamMediaType;
@property (readonly) unsigned long long contentStreamLength;

@property (nonatomic, strong, readonly) NSString *versionLabel;
@property (readonly) BOOL isLatestVersion;
@property (readonly) BOOL isMajorVersion;
@property (readonly) BOOL isLatestMajorVersion;
@property (nonatomic, strong, readonly) NSString *versionSeriesId;

/**
* Retrieves a collection of all versions of this document.
*/
- (void)retrieveAllVersionsWithCompletionBlock:(void (^)(CMISCollection *allVersionsOfDocument, NSError *error))completionBlock;

/**
* Retrieves a collection of all versions of this document.
*/
- (void)retrieveAllVersionsWithOperationContext:(CMISOperationContext *)operationContext completionBlock:(void (^)(CMISCollection *collection, NSError *error))completionBlock;

/**
* Retrieves the lastest version of this document.
*/
- (void)retrieveObjectOfLatestVersionWithMajorVersion:(BOOL)major completionBlock:(void (^)(CMISDocument *document, NSError *error))completionBlock;

/**
* Retrieves the lastest version of this document.
*/
- (void)retrieveObjectOfLatestVersionWithMajorVersion:(BOOL)major
                                 withOperationContext:(CMISOperationContext *)operationContext
                                      completionBlock:(void (^)(CMISDocument *document, NSError *error))completionBlock;

/**
* Downloads the content to a local file and returns the filepath.
* This is a synchronous call and will not return until the file is written to the given path.
*/
- (CMISRequest*)downloadContentToFile:(NSString *)filePath
                      completionBlock:(void (^)(NSError *error))completionBlock
                        progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock;

/**
 * Changes the content of this document to the content of the given file.
 *
 * Optional overwrite flag: If TRUE (default), then the Repository MUST replace the existing content stream for the
 * object (if any) with the input contentStream. If FALSE, then the Repository MUST only set the input
 * contentStream for the object if the object currently does not have a content-stream.
 */
- (CMISRequest*)changeContentToContentOfFile:(NSString *)filePath
                       withOverwriteExisting:(BOOL)overwrite
                             completionBlock:(void (^)(NSError *error))completionBlock
                               progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock;

/**
 * Changes the content of this document to the content of the given input stream.
 *
 * Optional overwrite flag: If TRUE (default), then the Repository MUST replace the existing content stream for the
 * object (if any) with the input contentStream. If FALSE, then the Repository MUST only set the input
 * contentStream for the object if the object currently does not have a content-stream.
 */
- (CMISRequest*)changeContentToContentOfInputStream:(NSInputStream *)inputStream
                                      bytesExpected:(unsigned long long)bytesExpected
                                       withFileName:(NSString *)filename
                              withOverwriteExisting:(BOOL)overwrite
                                    completionBlock:(void (^)(NSError *error))completionBlock
                                      progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock;

/**
 * Deletes the content of this document.
 */
- (void)deleteContentWithCompletionBlock:(void (^)(NSError *error))completionBlock;

/**
* Deletes the document from the document store.
*/
- (void)deleteAllVersionsWithCompletionBlock:(void (^)(BOOL documentDeleted, NSError *error))completionBlock;

@end
