/*******************************************************************************
 * Copyright (C) 2005-2012 Alfresco Software Limited.
 * 
 * This file is part of the Alfresco Mobile SDK.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *  
 *  http://www.apache.org/licenses/LICENSE-2.0
 * 
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import "AlfrescoSession.h"
#import "AlfrescoDocument.h"
#import "AlfrescoSite.h"
#import "AlfrescoActivityEntry.h"
#import "AlfrescoComment.h"
#import "AlfrescoPerson.h"
@class CMISSession, CMISFolder, CMISDocument, CMISObject, CMISObjectData, CMISQueryResult;

@interface AlfrescoObjectConverter : NSObject

/** Initialises the instance using the given Alfresco session object.
 @param session
*/
- (id)initWithSession:(id<AlfrescoSession>)session;

/** Returns an Alfresco repository info object from the given CMIS session object.
 @param cmisSession
 @return AlfrescoRepositoryInfo if successful or nil otherwise
*/
- (AlfrescoRepositoryInfo *)repositoryInfoFromCMISSession:(CMISSession *)cmisSession;

/** Converts the given CMIS object into an Alfresco node object.
 @param cmisObject
 @return AlfrescoNode if successful or nil otherwise
 */
- (AlfrescoNode *)nodeFromCMISObject:(CMISObject *)cmisObject;

/** Converts the given CMIS object data into an Alfresco node object.
 @param cmisObjectData
 @return AlfrescoNode if successful or nil otherwise
 */
- (AlfrescoNode *)nodeFromCMISObjectData:(CMISObjectData *)cmisObjectData;

/** Converts the given CMIS query result into an Alfresco document object.
 @param cmisQueryResult
 @return AlfrescoDocument if successful or nil otherwise
 */
- (AlfrescoDocument *)documentFromCMISQueryResult:(CMISQueryResult *)cmisQueryResult;

/**
 parses JSON data set based on latest public API. It searches for JSON elements "entries" and returns 
 the list as NSArray
 @param data the raw JSON data
 @param outError
 @return NSArray containing the objects in the JSON "entries" array - or nil if an error occurred while parsing.
 */
+ (NSArray *)arrayJSONEntriesFromListData:(NSData *)data error:(NSError **)outError;

/**
 parses JSON data set based on latest public API. It searches for JSON elements "entry" and returns
 the data as NSDictionary. "entry" is an element in the JSON "entries" array - or it may be a single JSON entity
 in a JSON response.
 @param data the raw JSON data
 @param outError
 @return NSDictionary containing the objects in the JSON "entry" array - or nil if an error occurred while parsing.
 */
+ (NSDictionary *)dictionaryJSONEntryFromListData:(NSData *)data error:(NSError **)outError;

/**
 converts the noderef ID containing a version string (e.g. ";1.0" ) into a node ref without the version id.
 Some older repositories require the CMIS node ref to be without the version string.
 @param originalIdentifier
 @return NSString - the id without the version string
 */
+ (NSString *)nodeRefWithoutVersionID:(NSString *)originalIdentifier;

@end
