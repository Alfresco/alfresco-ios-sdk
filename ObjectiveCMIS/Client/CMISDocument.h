//
//  CMISDocument.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 29/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

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
