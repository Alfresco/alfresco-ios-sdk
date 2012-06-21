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

#import "CMISBindingSession.h"

NSString * const kCMISBindingSessionKeyAtomPubUrl = @"cmis_session_key_atompub_url";
NSString * const kCMISBindingSessionKeyObjectByIdUriBuilder = @"cmis_session_key_objectbyid_uri_builder";
NSString * const kCMISBindingSessionKeyObjectByPathUriBuilder = @"cmis_session_key_objectbypath_uri_builder";
NSString * const kCMISBindingSessionKeyTypeByIdUriBuilder = @"cmis_session_key_type_by_id_uri_builder";
NSString * const kCMISBindingSessionKeyQueryUri = @"cmis_session_key_query_uri";

NSString * const kCMISBindingSessionKeyQueryCollection = @"cmis_session_key_query_collection";

NSString * const kCMISBindingSessionKeyLinkCache = @"cmis_session_key_link_cache";

@interface CMISBindingSession ()
@property (nonatomic, strong, readwrite) NSString *username;
@property (nonatomic, strong, readwrite) NSString *repositoryId;
@property (nonatomic, strong, readwrite) id<CMISAuthenticationProvider> authenticationProvider;
@property (nonatomic, strong, readwrite) NSMutableDictionary *sessionData;
@end

@implementation CMISBindingSession

@synthesize username = _username;
@synthesize repositoryId = _repositoryId;
@synthesize authenticationProvider = _authenticationProvider;
@synthesize sessionData = _sessionData;

- (id)initWithSessionParameters:(CMISSessionParameters *)sessionParameters
{
    self = [super init];
    if (self)
    {
        self.sessionData = [[NSMutableDictionary alloc] init];
        
        // grab common data from session parameters
        self.username = sessionParameters.username;
        self.repositoryId = sessionParameters.repositoryId;
        self.authenticationProvider = sessionParameters.authenticationProvider;
        
        // store all other data in the dictionary
        [self.sessionData setObject:sessionParameters.atomPubUrl forKey:kCMISBindingSessionKeyAtomPubUrl];
        
        for (id key in sessionParameters.allKeys) 
        {
            [self.sessionData setObject:[sessionParameters objectForKey:key] forKey:key];
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
