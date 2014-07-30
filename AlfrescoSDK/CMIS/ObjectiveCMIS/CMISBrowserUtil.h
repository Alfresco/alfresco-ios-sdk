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
#import "CMISTypeDefinition.h"
#import "CMISObjectData.h"
#import "CMISObjectList.h"
#import "CMISBindingSession.h"
#import "CMISBrowserTypeCache.h"

@interface CMISBrowserUtil : NSObject

/**
 Returns a dictionary of CMISRepositoryInfo objects keyed by the repository identifer, parsed from the given JSON data.
 */
+ (NSDictionary *)repositoryInfoDictionaryFromJSONData:(NSData *)jsonData bindingSession:(CMISBindingSession *)bindingSession error:(NSError **)outError;

/**
 Returns a CMISTypeDefinition object parsed from the given JSON data.
 */
+ (CMISTypeDefinition *)typeDefinitionFromJSONData:(NSData *)jsonData error:(NSError **)outError;

/**
 Returns a CMISObjectData object parsed from the given JSON data.
 */
+ (void)objectDataFromJSONData:(NSData *)jsonData typeCache:(CMISBrowserTypeCache *)typeCache completionBlock:(void(^)(CMISObjectData *objectData, NSError *error))completionBlock;

/**
 Returns a CMISObjectList object parsed from the given JSON data.
 */
+ (void)objectListFromJSONData:(NSData *)jsonData typeCache:(CMISBrowserTypeCache *)typeCache isQueryResult:(BOOL)isQueryResult completionBlock:(void(^)(CMISObjectList *objectList, NSError *error))completionBlock;

/**
 Returns an array of CMISRenditionData objects, parsed from the given JSON data.
 */
+ (NSArray *)renditionsFromJSONData:(NSData *)jsonData error:(NSError **)outError;

/**
 Returns an array of NSString objects that failed to be deleted, parsed from the given JSON data.
 */
+ (NSArray *)failedToDeleteObjectsFromJSONData:(NSData *)jsonData error:(NSError **)outError;

/**
 Returns all object parents as an array of CMISObjectData objects, parsed from the given JSON data.
 */
+ (void)objectParents:(NSData *)jsonData typeCache:(CMISBrowserTypeCache *)typeCache completionBlock:(void(^)(NSArray *objectParents, NSError *error))completionBlock;

@end
