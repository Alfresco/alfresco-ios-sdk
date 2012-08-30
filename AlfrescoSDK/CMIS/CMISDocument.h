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

@interface CMISDocument : CMISFileableObject <NSURLConnectionDataDelegate>

@property (nonatomic, strong, readonly) NSString *contentStreamId;
@property (nonatomic, strong, readonly) NSString *contentStreamFileName;
@property (nonatomic, strong, readonly) NSString *contentStreamMediaType;
@property (readonly) NSInteger contentStreamLength;

@property (nonatomic, strong, readonly) NSString *versionLabel;
@property (readonly) BOOL isLatestVersion;
@property (readonly) BOOL isMajorVersion;
@property (readonly) BOOL isLatestMajorVersion;
@property (nonatomic, strong, readonly) NSString *versionSeriesId;

/**
* Retrieves a collection of all versions of this document.
*/
- (CMISCollection *)retrieveAllVersionsAndReturnError:(NSError **)error;

/**
* Retrieves a collection of all versions of this document.
*/
- (CMISCollection *)retrieveAllVersionsWithOperationContext:(CMISOperationContext *)operationContext andReturnError:(NSError **)error;

/**
* Retrieves the lastest version of this document.
*/
- (CMISDocument *)retrieveObjectOfLatestVersionWithMajorVersion:(BOOL)major
                                                 andReturnError:(NSError **)error;

/**
* Retrieves the lastest version of this document.
*/
- (CMISDocument *)retrieveObjectOfLatestVersionWithMajorVersion:(BOOL)major
                                           withOperationContext:(CMISOperationContext *)operationContext
                                                 andReturnError:(NSError **)error;

/**
* Downloads the content to a local file and returns the filepath.
* This is a synchronous call and will not return until the file is written to the given path.
*/
- (void)downloadContentToFile:(NSString *)filePath completionBlock:(CMISVoidCompletionBlock)completionBlock
            failureBlock:(CMISErrorFailureBlock)failureBlock progressBlock:(CMISProgressBlock)progressBlock;

/**
 * Changes the content of this document to the content of the given file.
 *
 * Optional overwrite flag: If TRUE (default), then the Repository MUST replace the existing content stream for the
 * object (if any) with the input contentStream. If FALSE, then the Repository MUST only set the input
 * contentStream for the object if the object currently does not have a content-stream.
 *
 * Note that this is an asynchronous method.
 */
- (void)changeContentToContentOfFile:(NSString *)filePath
               withOverwriteExisting:(BOOL)overwrite
                     completionBlock:(CMISVoidCompletionBlock)completionBlock
                        failureBlock:(CMISErrorFailureBlock)failureBlock
                       progressBlock:(CMISProgressBlock)progressBlock;

/**
 * Deletes the content of this document.
 */
- (void)deleteContentAndReturnError:(NSError * *)error;;

/**
* Deletes the document from the document store.
*/
- (BOOL)deleteAllVersionsAndReturnError:(NSError **)error;

@end
