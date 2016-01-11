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
#import "CMISBinding.h"
#import "CMISAuthenticationProvider.h"
#import "CMISNetworkProvider.h"
#import "CMISTypeDefinitionCache.h"


// Session param keys

/**
 * Key for setting the class that is responsible for converting all kinds of CMIS objects.
 * This value of this class can be a Class instance or a NSString instance.
 * In the latter case, the string will be used to construct the class using NSClassFromString().
 */
extern NSString * const kCMISSessionParameterObjectConverterClassName;

/**
 * Key for setting the value of the cache of links.
 * Value should be an NSNumber, indicating the amount of objects whose links will be cached.
 */
extern NSString * const kCMISSessionParameterLinkCacheSize;

/**
 * Key for setting the value of the cache of type definitions.
 * Value should be an NSNumber, indicating the amount of type defintions will be cached.
 */
extern NSString * const kCMISSessionParameterTypeDefinitionCacheSize;

/**
 * Key for setting whether cookies should be added to requests. 
 * Value should be a boolean flag, default is YES.
 */
extern NSString * const kCMISSessionParameterSendCookies;

/**
 * Key for setting whether network reachability checks should be made
 * before making a newtork call. Default is YES.
 */
extern NSString * const kCMISSessionParameterCheckNetworkReachability;

/**
 * Key for setting the timeout interval (in seconds) for a network request, default is 60.
 */
extern NSString * const kCMISSessionParameterRequestTimeout;

/**
 * Key for setting whether a background session should be used for network calls,
 * default is NO.
 * This will cause downloads and uploads to occur in a separate process.
 */
extern NSString * const kCMISSessionParameterUseBackgroundNetworkSession;

/**
 * Key for setting the identifier to use for the background session, ignored unless
 * kCMISSessionParameterUseBackgroundNetworkSession is set to YES.
 * If not set, background sessions will use an identifier of "ObjectiveCMIS".
 */
extern NSString * const kCMISSessionParameterBackgroundNetworkSessionId;

/**
 * Key for setting the shared container identifier used by the background network session.
 * If not set, an identifier of "ObjectiveCMISContainer" will be used.
 */
extern NSString * const kCMISSessionParameterBackgroundNetworkSessionSharedContainerId;


@interface CMISSessionParameters : NSObject

// Repository connection

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *repositoryId;
@property (nonatomic, strong) NSURL *atomPubUrl;
@property (nonatomic, strong) NSURL *browserUrl;

@property (nonatomic, assign, readonly) CMISBindingType bindingType;

// Authentication

@property (nonatomic, strong) id<CMISAuthenticationProvider> authenticationProvider;

// Network I/O
@property (nonatomic, strong) id<CMISNetworkProvider> networkProvider;

// Type definitions cache
@property (nonatomic, strong) CMISTypeDefinitionCache *typeDefinitionCache;

/** init with binding type
 */
- (id)initWithBindingType:(CMISBindingType)bindingType;

/// Object storage methods
- (NSArray *)allKeys;

- (id)objectForKey:(id)key;

- (id)objectForKey:(id)key defaultValue:(id)defaultValue;

- (void)setObject:(id)object forKey:(id)key;

- (void)addEntriesFromDictionary:(NSDictionary *)dictionary;

- (void)removeKey:(id)key;

@end
