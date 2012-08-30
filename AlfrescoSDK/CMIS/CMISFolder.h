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
#import "CMISFileableObject.h"
#import "CMISCollection.h"

@class CMISDocument;
@class CMISPagedResult;
@class CMISOperationContext;

@interface CMISFolder : CMISFileableObject

@property (nonatomic, strong, readonly) NSString *path;

/**
 * Retrieves the children of this folder as a paged result.
 *
 * The returned objects will be instances of CMISObject.
 */
- (CMISPagedResult *)retrieveChildrenAndReturnError:(NSError * *)error;

/**
 * Checks if this folder is the root folder.
 */
- (BOOL)isRootFolder;

/**
 * Gets the parent folder object.
 */
- (CMISFolder *)retrieveFolderParentAndReturnError:(NSError **)error;

/**
 * Retrieves the children of this folder as a paged result using the provided operation context.
 *
 * The returned objects will be instances of CMISObject.
 */
- (CMISPagedResult *)retrieveChildrenWithOperationContext:(CMISOperationContext *)operationContext andReturnError:(NSError * *)error;

- (NSString *)createFolder:(NSDictionary *)properties error:(NSError * *)error;

- (void)createDocumentFromFilePath:(NSString *)filePath withMimeType:(NSString *)mimeType
                          withProperties:(NSDictionary *)properties
                         completionBlock:(CMISStringCompletionBlock)completionBlock // the returned string is the object id of the newly created document
                            failureBlock:(CMISErrorFailureBlock)failureBlock
                           progressBlock:(CMISProgressBlock)progressBlock;

- (NSArray *)deleteTreeWithDeleteAllVersions:(BOOL)deleteAllversions
                           withUnfileObjects:(CMISUnfileObject)unfileObjects
                       withContinueOnFailure:(BOOL)continueOnFailure
                              andReturnError:(NSError **)error;

@end


