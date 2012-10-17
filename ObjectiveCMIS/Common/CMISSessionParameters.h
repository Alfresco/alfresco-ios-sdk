/*
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "CMISEnums.h"
#import "CMISBinding.h"
#import "CMISAuthenticationProvider.h"


// Session param keys

/**
 * Key for setting the class that is responsible for converting all kinds of CMIS objects.
 * This value of this class can be a Class instance or a NSString instance.
 * In the latter case, the string will be used to construct the class using NSClassFromString().
 */
extern NSString * const kCMISSessionParameterObjectConverterClassName;

/**
 * Key for setting the size of the cache of links.
 * Value should be an NSNumber, indicating the amount of objects whose links will be cached.
 */
extern NSString * const kCMISSessionParameterLinkCacheSize;

/**
 * Key for setting the size of the type definition cache. Default is 50.
 * Value should be an NSNumber, indicating the amount of type definitions whose links will be cached.
 */
extern NSString * const kCMISSessionParameterTypeDefinitionCacheSize;



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
