//
//  CMISFolder.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 21/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

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


