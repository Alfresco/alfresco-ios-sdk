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

#import "CMISSessionParameters.h"

// Session param keys
NSString * const kCMISSessionParameterObjectConverterClassName = @"session_param_object_converter_class";
NSString * const kCMISSessionParameterLinkCacheSize = @"session_param_cache_size_links";
NSString * const kCMISSessionParameterTypeDefinitionCacheSize = @"session_param_cache_size_type_definition";
NSString * const kCMISSessionParameterSendCookies = @"session_param_send_cookies";

@interface CMISSessionParameters ()
@property (nonatomic, assign, readwrite) CMISBindingType bindingType;
@property (nonatomic, strong, readwrite) NSMutableDictionary *sessionData;
@end

@implementation CMISSessionParameters


- (id)init
{
    return [self initWithBindingType:CMISBindingTypeAtomPub];
}

- (id)initWithBindingType:(CMISBindingType)bindingType
{
    self = [super init];
    if (self) {
        self.sessionData = [[NSMutableDictionary alloc] init];
        self.bindingType = bindingType;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"bindingType: %li, username: %@, password: %@, atomPubUrl: %@",
            (long)self.bindingType, self.username, self.password, self.atomPubUrl];
}

- (NSArray *)allKeys
{
    return [self.sessionData allKeys];
}

- (id)objectForKey:(id)key
{
    return [self.sessionData objectForKey:key];
}

- (id)objectForKey:(id)key defaultValue:(id)defaultValue
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
