//
//  CMISObjectService.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 20/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISObjectData.h"

@class CMISDocument;
@class CMISStringInOutParameter;

typedef void (^CMISContentRetrievalCompletionBlock)(void);
typedef void (^CMISContentRetrievalFailureBlock)(NSError *error);
typedef void (^CMISContentRetrievalProgressBlock)(NSInteger bytesDownloaded, NSInteger bytesTotal);

@protocol CMISObjectService <NSObject>

/**
 *Retrieves the object with the given object identifier.
 *
 */
- (CMISObjectData *)retrieveObject:(NSString *)objectId
           withFilter:(NSString *)filter
           andIncludeRelationShips:(CMISIncludeRelationship)includeRelationship
           andIncludePolicyIds:(BOOL)includePolicyIds
           andRenditionFilder:(NSString *)renditionFilter
           andIncludeACL:(BOOL)includeACL
           andIncludeAllowableActions:(BOOL)includeAllowableActions
           error:(NSError * *)error;

/**
 *Retrieves an object using its path.
 *
 */
-(CMISObjectData *)retrieveObjectByPath:(NSString *)path error:(NSError * *)error;

/**
* Downloads the content to a local file and returns the filepath.
*
* Do note that this is an ASYNCHRONOUS call, as a synchronous call would have
* bad performance/memory implications.
*/
- (void)downloadContentOfObject:(NSString *)objectId toFile:(NSString *)filePath
                                completionBlock:(CMISContentRetrievalCompletionBlock)completionBlock
                                failureBlock:(CMISContentRetrievalFailureBlock)failureBlock
                                progressBlock:(CMISContentRetrievalProgressBlock)progressBlock;

/**
 * Deletes the content stream for the specified document object.
  *
  * A Repository MAY automatically create new Document versions as part of this service method.
  * Therefore, the objectId output NEED NOT be identical to the objectId input
  *
  * NOTE for atom pub binding: deleteContentStream: This does not return the new object id and change token as specified by the domain model.
  * This is not possible without introducing a new HTTP header.
 */
- (void)deleteContentOfObject:(CMISStringInOutParameter *)objectId withChangeToken:(CMISStringInOutParameter *)changeToken error:(NSError * *)error;

/**
 * Changes the content of the given document to the content of the given file.
 *
 * Optional overwrite flag: If TRUE (default), then the Repository MUST replace the existing content stream for the
 * object (if any) with the input contentStream. If FALSE, then the Repository MUST only set the input
 * contentStream for the object if the object currently does not have a content-stream.
 *
 * NOTE for atom pub binding: This does not return the new object id and change token as specified by the domain model.
 * This is not possible without introducing a new HTTP header.
 */
- (void)changeContentOfObject:(CMISStringInOutParameter *)objectId toContentOfFile:(NSString *)filePath
              withOverwriteExisting:(BOOL)overwrite withChangeToken:(CMISStringInOutParameter *)changeToken error:(NSError * *)error;

/**
* uploads the file from the given path to the given folder.
*
* This is a synchronous call and will not return until the file is completely uploaded to the server.
*/
- (NSString *)createDocumentFromFilePath:(NSString *)filePath withMimeType:(NSString *)mimeType withProperties:(CMISProperties *)properties inFolder:(NSString *)folderObjectId error:(NSError * *)error;

/**
* Deletes the given object.
*
* The allVersions parameter is currently ignored.
*/
- (BOOL)deleteObject:(NSString *)objectId allVersions:(BOOL)allVersions error:(NSError * *)error;

/**
* Creates a new folder with given properties under the provided parent folder.
*/
- (NSString *)createFolderInParentFolder:(NSString *)folderObjectId withProperties:(CMISProperties *)properties error:(NSError * *)error;

/**
* Deletes the given folder and all of its subfolder and files
*
* Returns a list of objects which failed to be deleted.
*
* TODO: support for other parameters (see spec)
*/
- (NSArray *)deleteTree:(NSString *)folderObjectId error:(NSError * *)error;

/**
 * Updates the properties of the given object.
 */
- (void)updatePropertiesForObject:(CMISStringInOutParameter *)objectId withProperties:(CMISProperties *)properties
                  withChangeToken:(CMISStringInOutParameter *)changeToken error:(NSError **)error;

@end
