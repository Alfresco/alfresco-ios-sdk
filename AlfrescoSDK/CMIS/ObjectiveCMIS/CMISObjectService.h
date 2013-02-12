/*
  Licensed to the Apache Software Foundation (ASF) under one
  or more contributor license agreements.  See the NOTICE file
  distributed with this work for additional information
  regarding copyright ownership.  The ASF licenses this file
  to you under the Apache License, Version 2.0 (the
  "License"); you may not use this file except in compliance
  with the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an
  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  KIND, either express or implied.  See the License for the
  specific language governing permissions and limitations
  under the License.
 */

#import <Foundation/Foundation.h>
#import "CMISObjectData.h"

@class CMISDocument;
@class CMISStringInOutParameter;
@class CMISRequest;

@protocol CMISObjectService <NSObject>

/**
 * Retrieves the object with the given object identifier.
 * completionBlock returns objectData for object or nil if unsuccessful
 */
- (void)retrieveObject:(NSString *)objectId
                filter:(NSString *)filter
         relationShips:(CMISIncludeRelationship)includeRelationship
      includePolicyIds:(BOOL)includePolicyIds
       renditionFilder:(NSString *)renditionFilter
            includeACL:(BOOL)includeACL
    includeAllowableActions:(BOOL)includeAllowableActions
       completionBlock:(void (^)(CMISObjectData *objectData, NSError *error))completionBlock;

/**
 * Retrieves an object using its path.
 * completionBlock returns objectData for object or nil if unsuccessful
 */
- (void)retrieveObjectByPath:(NSString *)path
                      filter:(NSString *)filter
               relationShips:(CMISIncludeRelationship)includeRelationship
            includePolicyIds:(BOOL)includePolicyIds
             renditionFilder:(NSString *)renditionFilter
                  includeACL:(BOOL)includeACL
     includeAllowableActions:(BOOL)includeAllowableActions
             completionBlock:(void (^)(CMISObjectData *objectData, NSError *error))completionBlock;

/**
 * Gets the content stream for the specified Document object, or gets a rendition stream for a specified
 * rendition of a document or folder object. Downloads the content to a local file.
 * completionBlock returns objectData for object or nil if unsuccessful
 *
 */
- (CMISRequest*)downloadContentOfObject:(NSString *)objectId
                               streamId:(NSString *)streamId
                                 toFile:(NSString *)filePath
                        completionBlock:(void (^)(NSError *error))completionBlock
                          progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock;

/**
 * Gets the content stream for the specified Document object, or gets a rendition stream for a specified
 * rendition of a document or folder object. Downloads the content to an output stream.
 * completionBlock returns objectData for object or nil if unsuccessful
 *
 */
- (CMISRequest*)downloadContentOfObject:(NSString *)objectId
                               streamId:(NSString *)streamId
                         toOutputStream:(NSOutputStream *)outputStream
                        completionBlock:(void (^)(NSError *error))completionBlock
                          progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock;

/**
 * Deletes the content stream for the specified document object.
 *
 * A Repository MAY automatically create new Document versions as part of this service method.
 * Therefore, the objectId output NEED NOT be identical to the objectId input
 *
 * NOTE for atom pub binding: deleteContentStream: This does not return the new object id and change token as specified by the domain model.
 * This is not possible without introducing a new HTTP header.
 * completionBlock - returns NSError nil if successful
 */
- (void)deleteContentOfObject:(CMISStringInOutParameter *)objectIdParam
                  changeToken:(CMISStringInOutParameter *)changeTokenParam
              completionBlock:(void (^)(NSError *error))completionBlock;

/**
 * Changes the content of the given document to the content of a given file.
 *
 * Optional overwrite flag: If TRUE (default), then the Repository MUST replace the existing content stream for the
 * object (if any) with the input contentStream. If FALSE, then the Repository MUST only set the input
 * contentStream for the object if the object currently does not have a content-stream.
 *
 * NOTE for atom pub binding: This does not return the new object id and change token as specified by the domain model.
 * (This is not possible without introducing a new HTTP header).
 * completionBlock - returns NSError nil if successful
 */
- (CMISRequest*)changeContentOfObject:(CMISStringInOutParameter *)objectIdParam
                      toContentOfFile:(NSString *)filePath
                    overwriteExisting:(BOOL)overwrite
                          changeToken:(CMISStringInOutParameter *)changeTokenParam
                      completionBlock:(void (^)(NSError *error))completionBlock
                        progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock;

/**
 * Changes the content of the given document to the content from a give input stream.
 *
 * Optional overwrite flag: If TRUE (default), then the Repository MUST replace the existing content stream for the
 * object (if any) with the input contentStream. If FALSE, then the Repository MUST only set the input
 * contentStream for the object if the object currently does not have a content-stream.
 *
 * NOTE for atom pub binding: This does not return the new object id and change token as specified by the domain model.
 * (This is not possible without introducing a new HTTP header).
 * completionBlock - returns NSError nil if successful
 */
- (CMISRequest*)changeContentOfObject:(CMISStringInOutParameter *)objectId
               toContentOfInputStream:(NSInputStream *)inputStream
                        bytesExpected:(unsigned long long)bytesExpected
                             filename:(NSString *)filename
                    overwriteExisting:(BOOL)overwrite
                          changeToken:(CMISStringInOutParameter *)changeToken
                      completionBlock:(void (^)(NSError *error))completionBlock
                        progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock;

/**
 * uploads the file from the given path to the given folder.
 *
 * completionBlock - returns NSError nil if successful
*/
- (CMISRequest*)createDocumentFromFilePath:(NSString *)filePath
                                  mimeType:(NSString *)mimeType
                                properties:(CMISProperties *)properties
                                  inFolder:(NSString *)folderObjectId
                           completionBlock:(void (^)(NSString *objectId, NSError *error))completionBlock
                             progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock;

/**
 * uploads the file from the given input stream to the given folder.
 *
 * completionBlock - returns NSError nil if successful
 */
- (CMISRequest*)createDocumentFromInputStream:(NSInputStream *)inputStream
                                     mimeType:(NSString *)mimeType
                                   properties:(CMISProperties *)properties
                                     inFolder:(NSString *)folderObjectId
                                bytesExpected:(unsigned long long)bytesExpected // optional
                              completionBlock:(void (^)(NSString *objectId, NSError *error))completionBlock
                                progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock;

/**
 * Deletes the given object.
 *
 * The allVersions parameter is currently ignored.
 * completionBlock returns true if successful
 */
- (void)deleteObject:(NSString *)objectId
         allVersions:(BOOL)allVersions
     completionBlock:(void (^)(BOOL objectDeleted, NSError *error))completionBlock;

/**
 * Creates a new folder with given properties under the provided parent folder.
 * completionBlock returns objectId for the newly created folder or nil if unsuccessful
 */
- (void)createFolderInParentFolder:(NSString *)folderObjectId
                        properties:(CMISProperties *)properties
                   completionBlock:(void (^)(NSString *objectId, NSError *error))completionBlock;

/**
 * Deletes the given folder and all of its subfolder and files
 *
 * Returns a list of objects which failed to be deleted.
 * completionBlock returns array of failed objects if any. NSError will be nil if successful
 *
 */
- (void)deleteTree:(NSString *)folderObjectId
        allVersion:(BOOL)allVersions
     unfileObjects:(CMISUnfileObject)unfileObjects
 continueOnFailure:(BOOL)continueOnFailure
   completionBlock:(void (^)(NSArray *failedObjects, NSError *error))completionBlock;

/**
 * Updates the properties of the given object.
 * completionBlock returns NSError nil if successful
 */
- (void)updatePropertiesForObject:(CMISStringInOutParameter *)objectIdParam
                       properties:(CMISProperties *)properties
                      changeToken:(CMISStringInOutParameter *)changeTokenParam
                  completionBlock:(void (^)(NSError *error))completionBlock;

/**
 * Gets the list of associated Renditions for the specified object.
 * Only rendition attributes are returned, not rendition stream
 *
 * Note: the paging parameters (maxItems and skipCount) are not used in the atom pub binding.
 *       Ie. the whole set is <b>always</b> returned.
 * completionBlock returns array of associated renditions or nil if unsuccessful
 */
- (void)retrieveRenditions:(NSString *)objectId
                renditionFilter:(NSString *)renditionFilter
                    maxItems:(NSNumber *)maxItems
                    skipCount:(NSNumber *)skipCount
           completionBlock:(void (^)(NSArray *renditions, NSError *error))completionBlock;

@end
