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
#import "AlfrescoListingContext.h"

@interface AlfrescoSortingUtils : NSObject

/**
 @name Sorting utilities
 */

/**
 @param array
 @param key
 @param isAscending
 @return NSArray - the sorted array based on sorting algorithm parameters
 */
+ (NSArray *)sortedArrayForArray:(NSArray *)array sortKey:(NSString *)key ascending:(BOOL)isAscending;

/**
 first this method checks whether the sort key is any of the supported ones. If yes, it will be applied in the
 sorting algorithm. If no, the default sort key will be applied.
 @param array
 @param key
 @param supportedKeys
 @param defaultKey
 @param isAscending
 @return NSArray - the sorted array based on sorting algorithm parameters
 */
+ (NSArray *)sortedArrayForArray:(NSArray *)array
                        sortKey:(NSString *)key
                  supportedKeys:(NSArray* )keys
                     defaultKey:(NSString *)defaultKey
                      ascending:(BOOL)isAscending;

/**
 @param listingContext
 @param supportedKeys
 @param defaultKey
 @param isAscending
 @return NSArray - the sorted array based on sorting algorithm parameters
 */
+ (NSString *)sortKeyFromListingContext:(AlfrescoListingContext *)listingContext supportedKeys:(NSArray *)keys defaultKey:(NSString *)defaultKey;


/**
 first this method checks whether the sort key is any of the supported ones. If yes, it will be applied in the
 sorting algorithm. If no, the default sort key will be applied.
 @param desiredKey
 @param supportedKeys
 @param defaultKey
 @return NSArray - the sorted array based on sorting algorithm parameters
 */
+ (NSString *)sortKeyForDesiredKey:(NSString *)desiredKey supportedKeys:(NSArray *)keys defaultKey:(NSString *)defaultKey;
@end
