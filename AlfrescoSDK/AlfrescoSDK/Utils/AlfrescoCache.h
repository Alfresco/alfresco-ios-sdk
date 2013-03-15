/*
 ******************************************************************************
 * Copyright (C) 2005-2013 Alfresco Software Limited.
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
 *****************************************************************************
 */

#import <Foundation/Foundation.h>

@protocol AlfrescoCache <NSObject>
/**
 add an array of objects to the cache
 */
- (void)addObjectsToCache:(NSArray *)objectsArray;
/**
 add a single object to the cache
 */
- (void)addToCache:(id)cacheObject;
/**
 remove a single object from the cache
 */
- (void)removeFromCache:(id)cacheObject;
/**
 empty the entire cache
 */
- (void)clear;
/**
 @return found object for identifier or nil otherwise
 */
- (id)objectWithIdentifier:(NSString *)identifier;
/**
 checks if an object is in the cache
 */
- (BOOL)isInCache:(id)object;
@end
