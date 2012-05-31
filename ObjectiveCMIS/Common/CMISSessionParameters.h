//
//  CMISSessionParameters.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 22/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISEnums.h"
#import "CMISBinding.h"
#import "CMISAuthenticationProvider.h"


// Session param keys

/**
 * Key for setting the value of the cache of links.
 * Value should be an NSNumber, indicating the amount of objects whose links will be cached.
 */
extern NSString * const kCMISSessionParameterLinkCacheSize;

@interface CMISSessionParameters : NSObject

// Repository connection

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *repositoryId;
@property (nonatomic, strong) NSURL *atomPubUrl;

@property (nonatomic, assign, readonly) CMISBindingType bindingType;

// Authentication

@property (nonatomic, strong) id<CMISAuthenticationProvider> authenticationProvider;

- (id)initWithBindingType:(CMISBindingType)bindingType;

// Object storage methods
- (NSArray *)allKeys;
- (id)objectForKey:(id)key;
- (id)objectForKey:(id)key withDefaultValue:(id)defaultValue;
- (void)setObject:(id)object forKey:(id)key;
- (void)addEntriesFromDictionary:(NSDictionary *)dictionary;
- (void)removeKey:(id)key;

@end
