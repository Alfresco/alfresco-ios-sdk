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

@class CMISBindingSession;

@interface CMISTypeDefinitionCache : NSObject

- (id)initWithBindingSession:(CMISBindingSession *)bindingSession;

/**
 * Adds a type definition object to the cache.
 */
- (void)addTypeDefinition:(CMISTypeDefinition *)typeDefinition repositoryId:(NSString *)repositoryId;

/**
 * Retrieves a type definition object from the cache.
 *
 * @return the type definition object or nil if the object is
 *         not in the cache
 */
- (CMISTypeDefinition *)typeDefinitionForTypeId:(NSString *)typeId repositoryId:(NSString *)repositoryId;

/**
 * Removes a type definition object from the cache.
 */
- (void)removeTypeDefinitionForTypeId:(NSString *)typeId repositoryId:(NSString *)repositoryId;

/**
 * Removes all cache entries.
 */
- (void)removeAll;

@end
