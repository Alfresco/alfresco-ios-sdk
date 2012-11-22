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
#import "CMISRenditionData.h"

@class CMISDocument;
@class CMISOperationContext;
@class CMISSession;


@interface CMISRendition : CMISRenditionData

- (id)initWithRenditionData:(CMISRenditionData *)renditionData andObjectId:(NSString *)objectId andSession:(CMISSession *)session;

- (void)retrieveRenditionDocumentWithCompletionBlock:(void (^)(CMISDocument *document, NSError *error))completionBlock;

- (void)retrieveRenditionDocumentWithOperationContext:(CMISOperationContext *)operationContext
                                      completionBlock:(void (^)(CMISDocument *document, NSError *error))completionBlock;

- (void)downloadRenditionContentToFile:(NSString *)filePath
                       completionBlock:(void (^)(NSError *error))completionBlock
                         progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock;

- (void)downloadRenditionContentToOutputStream:(NSOutputStream *)outputStream
                               completionBlock:(void (^)(NSError *error))completionBlock
                                 progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock;

@end