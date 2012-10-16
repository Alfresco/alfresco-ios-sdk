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

#import "CMISSessionParameters.h"

NSString * const kCMISSessionParameterLinkCacheSize =@"session_param_cache_size_links";

NSString * const kCMISSessionParameterObjectConverterClassName = @"session_param_object_converter_class";

@interface CMISSessionParameters ()
@property (nonatomic, assign, readwrite) CMISBindingType bindingType;
@property (nonatomic, strong, readwrite) NSMutableDictionary *sessionData;
@end

@implementation CMISSessionParameters

@synthesize username = _username;
@synthesize password = _password;
@synthesize repositoryId = _repositoryId;
@synthesize bindingType = _bindingType;
@synthesize atomPubUrl = _atomPubUrl;
@synthesize authenticationProvider = _authenticationProvider;
@synthesize sessionData = _sessionData;

- (id)init
{
    return [self initWithBindingType:CMISBindingTypeAtomPub];
}

- (id)initWithBindingType:(CMISBindingType)bindingType
{
    self = [super init];
    if (self)
    {
        self.sessionData = [[NSMutableDictionary alloc] init];
        self.bindingType = bindingType;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"bindingType: %d, username: %@, password: %@, atomPubUrl: %@",
            self.bindingType, self.username, self.password, self.atomPubUrl];
}

- (NSArray *)allKeys
{
    return [self.sessionData allKeys];
}

- (id)objectForKey:(id)key
{
    return [self.sessionData objectForKey:key];
}

- (id)objectForKey:(id)key withDefaultValue:(id)defaultValue
{
    NSObject *value = [self.sessionData objectForKey:key];
    return value != nil ? value : defaultValue;
}

- (void)setObject:(id)object forKey:(id)key
{
    [self.sessionData setObject:object forKey:key];
}

- (void)addEntriesFromDictionary:(NSDictionary *)dictionary
{
    [self.sessionData addEntriesFromDictionary:dictionary];
}

- (void)removeKey:(id)key
{
    [self.sessionData removeObjectForKey:key];
}


@end
