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

#import "CMISDictionaryUtil.h"

@implementation NSDictionary (CMISDictionaryUtils)

- (id)cmis_objectForKeyNotNull:(id)aKey
{
    id value = self[aKey];
    return value == [NSNull null] ? nil : value;
}

- (BOOL)cmis_boolForKey:(id)aKey
{
    return [[self cmis_objectForKeyNotNull:aKey] boolValue];
}

- (int)cmis_intForKey:(id)aKey
{
    return [[self cmis_objectForKeyNotNull:aKey] intValue];
}

@end


@implementation CMISDictionaryUtil

+ (NSDictionary *)userInfoDictionaryForErrorWithDescription:(NSString *)description
                                                     reason:(NSString *)reason
                                            underlyingError:(NSError *)error
{
    NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
    
    if (description != nil) {
        errorInfo[NSLocalizedDescriptionKey] = description;
    }
    
    if (reason != nil) {
        errorInfo[NSLocalizedFailureReasonErrorKey] = reason;
    }
    
    if (error != nil) {
        
        errorInfo[NSUnderlyingErrorKey] = error;
        
        // if a description hasn't been supplied bubble up the underlying error description, if possible
        if (description == nil && error.localizedDescription != nil) {
            errorInfo[NSLocalizedDescriptionKey] = error.localizedDescription;
        }
        
        // if a reason hasn't been supplied bubble up the underlying error reason, if possible
        if (reason == nil && error.localizedFailureReason != nil) {
            errorInfo[NSLocalizedFailureReasonErrorKey] = error.localizedFailureReason;
        }
    }
    
    return errorInfo;
}

@end
