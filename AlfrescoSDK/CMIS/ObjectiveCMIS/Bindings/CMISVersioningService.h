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
#import "CMISEnums.h"

@class CMISCollection;
@class CMISObject;
@class CMISObjectData;
@class CMISProperties;
@class CMISRequest;

@protocol CMISVersioningService <NSObject>

/**
 * Get a the latest Document object in the Version Series.
 * @param objectId
 * @param major
 * @param filter
 * @param includeRelationships
 * @param includePolicyIds
 * @param renditionFilter
 * @param includeACL
 * @param includeAllowableActions
 * @param completionBlock returns object data if found or nil otherwise
 */
- (CMISRequest*)retrieveObjectOfLatestVersion:(NSString *)objectId
                                major:(BOOL)major
                               filter:(NSString *)filter
                        relationships:(CMISIncludeRelationship)relationships
                     includePolicyIds:(BOOL)includePolicyIds
                      renditionFilter:(NSString *)renditionFilter
                           includeACL:(BOOL)includeACL
              includeAllowableActions:(BOOL)includeAllowableActions
                      completionBlock:(void (^)(CMISObjectData *objectData, NSError *error))completionBlock;

/**
 * Returns the list of all Document Object in the given version series, sorted by creationDate descending (ie youngest first)
 * @param objectId
 * @param filter
 * @param includeAllowableActions
 * @param completionBlock returns array of all versioned objects or nil otherwise
 */
- (CMISRequest*)retrieveAllVersions:(NSString *)objectId
                             filter:(NSString *)filter
            includeAllowableActions:(BOOL)includeAllowableActions
                    completionBlock:(void (^)(NSArray *objects, NSError *error))completionBlock;

/**
 * Create a private working copy of a document given an object identifier.
 *
 * @param objectId
 * @param completionBlock returns PWC object data or nil
 */
- (CMISRequest*)checkOut:(NSString *)objectId
         completionBlock:(void (^)(CMISObjectData *objectData, NSError *error))completionBlock;

/**
 * Reverses the effect of a check-out.
 *
 * @param objectId
 * @param completionBlock returns object data or nil
 */
- (CMISRequest*)cancelCheckOut:(NSString *)objectId
               completionBlock:(void (^)(BOOL checkOutCancelled, NSError *error))completionBlock;

/**
 * Checks-in the private working copy (PWC) document from the given path.
 *
 * @param objectId the identifier for the PWC
 * @param asMajorVersion indicator if the new version should become a major (YES) or minor (NO) version
 * @param filePath (optional) Path to the file containing the content to be uploaded
 * @param mimeType (optional) Mime type of the content to be uploaded
 * @param properties (optional) the property values that must be applied to the checked-in document object
 * @param checkinComment (optional) a version comment
 * @param completionBlock returns object data or nil
 * @param progressBlock periodic file upload status
 */
- (CMISRequest*)checkIn:(NSString *)objectId
         asMajorVersion:(BOOL)asMajorVersion
               filePath:(NSString *)filePath
               mimeType:(NSString *)mimeType
             properties:(CMISProperties *)properties
         checkinComment:(NSString *)checkinComment
        completionBlock:(void (^)(CMISObjectData *objectData, NSError *error))completionBlock
          progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock;

/**
 * Checks-in the private working copy (PWC) document from the given an input stream.
 *
 * @param objectId the identifier for the PWC
 * @param asMajorVersion indicator if the new version should become a major (YES) or minor (NO) version
 * @param inputStream (optional) Input stream containing the content to be uploaded
 * @param bytesExpected The size of content to be uploaded (must be provided if an inputStream is given)
 * @param mimeType (optional) Mime type of the content to be uploaded
 * @param properties (optional) the property values that must be applied to the checked-in document object
 * @param checkinComment (optional) a version comment
 * @param completionBlock returns object data or nil
 * @param progressBlock periodic file upload status
 */
- (CMISRequest*)checkIn:(NSString *)objectId
         asMajorVersion:(BOOL)asMajorVersion
            inputStream:(NSInputStream *)inputStream
          bytesExpected:(unsigned long long)bytesExpected
               mimeType:(NSString *)mimeType
             properties:(CMISProperties *)properties
         checkinComment:(NSString *)checkinComment
        completionBlock:(void (^)(CMISObjectData *objectData, NSError *error))completionBlock
          progressBlock:(void (^)(unsigned long long bytesUploaded, unsigned long long bytesTotal))progressBlock;

@end
