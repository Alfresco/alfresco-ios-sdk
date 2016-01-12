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
#import "CMISSessionParameters.h"
#import "CMISAuthenticationProvider.h"
#import "CMISNetworkProvider.h"
#import "CMISTypeDefinitionCache.h"

// session key constants
extern NSString * const kCMISBindingSessionKeyUrl;

@interface CMISBindingSession : NSObject

@property (nonatomic, strong, readonly) NSString *username;
@property (nonatomic, strong, readonly) NSString *repositoryId;
@property (nonatomic, strong, readonly) id<CMISAuthenticationProvider> authenticationProvider;
@property (nonatomic, strong, readonly) id<CMISNetworkProvider> networkProvider;
@property (nonatomic, strong, readonly) CMISTypeDefinitionCache *typeDefinitionCache;

- (id)initWithSessionParameters:(CMISSessionParameters *)sessionParameters;

/// @name Object storage methods
- (NSArray *)allKeys;
- (id)objectForKey:(id)key;
- (id)objectForKey:(id)key defaultValue:(id)defaultValue;
- (void)setObject:(id)object forKey:(id)key;
- (void)addEntriesFromDictionary:(NSDictionary *)dictionary;
- (void)removeKey:(id)key;

@end
