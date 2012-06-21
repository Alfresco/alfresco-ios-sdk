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
#import "CMISSessionParameters.h"
#import "CMISAuthenticationProvider.h"

extern NSString * const kCMISBindingSessionKeyAtomPubUrl;
extern NSString * const kCMISBindingSessionKeyObjectByIdUriBuilder;
extern NSString * const kCMISBindingSessionKeyObjectByPathUriBuilder;
extern NSString * const kCMISBindingSessionKeyTypeByIdUriBuilder;
extern NSString * const kCMISBindingSessionKeyQueryUri;

extern NSString * const kCMISBindingSessionKeyQueryCollection;

extern NSString * const kCMISBindingSessionKeyLinkCache;

@interface CMISBindingSession : NSObject

@property (nonatomic, strong, readonly) NSString *username;
@property (nonatomic, strong, readonly) NSString *repositoryId;
@property (nonatomic, strong, readonly) id<CMISAuthenticationProvider> authenticationProvider;

- (id)initWithSessionParameters:(CMISSessionParameters *)sessionParameters;

// Object storage methods
- (NSArray *)allKeys;
- (id)objectForKey:(id)key;
- (id)objectForKey:(id)key withDefaultValue:(id)defaultValue;
- (void)setObject:(id)object forKey:(id)key;
- (void)addEntriesFromDictionary:(NSDictionary *)dictionary;
- (void)removeKey:(id)key;

@end
