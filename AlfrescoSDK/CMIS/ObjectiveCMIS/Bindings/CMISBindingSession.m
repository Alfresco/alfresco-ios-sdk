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

#import "CMISBindingSession.h"

NSString * const kCMISBindingSessionKeyUrl = @"cmis_session_key_url";

@interface CMISBindingSession ()
@property (nonatomic, strong, readwrite) NSString *username;
@property (nonatomic, strong, readwrite) NSString *repositoryId;
@property (nonatomic, strong, readwrite) id<CMISAuthenticationProvider> authenticationProvider;
@property (nonatomic, strong, readwrite) id<CMISNetworkProvider> networkProvider;
@property (nonatomic, strong, readwrite) CMISTypeDefinitionCache *typeDefinitionCache;
@property (nonatomic, strong, readwrite) NSMutableDictionary *sessionData;
@end

@implementation CMISBindingSession


- (id)initWithSessionParameters:(CMISSessionParameters *)sessionParameters
{
    self = [super init];
    if (self) {
        self.sessionData = [[NSMutableDictionary alloc] init];
        
        // grab common data from session parameters
        self.username = sessionParameters.username;
        self.repositoryId = sessionParameters.repositoryId;
        self.authenticationProvider = sessionParameters.authenticationProvider;
        self.networkProvider = sessionParameters.networkProvider;
        
        if (sessionParameters.bindingType == CMISBindingTypeAtomPub) {
            [self.sessionData setObject:sessionParameters.atomPubUrl forKey:kCMISBindingSessionKeyUrl];
        }
        else {
            [self.sessionData setObject:sessionParameters.browserUrl forKey:kCMISBindingSessionKeyUrl];
        }
        
        // store all other data in the dictionary
        for (id key in sessionParameters.allKeys) {
            [self.sessionData setObject:[sessionParameters objectForKey:key] forKey:key];
        }
        
        //set type definition cache after other data stored in the dictionary as the cache size is retrieved from the sessionData in the init method of the CMISTypeDefinitionCache
        if(sessionParameters.typeDefinitionCache == nil) {
            self.typeDefinitionCache = [[CMISTypeDefinitionCache alloc] initWithBindingSession:self];
        } else {
            self.typeDefinitionCache = sessionParameters.typeDefinitionCache;
        }
    }
    
    return self;
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
