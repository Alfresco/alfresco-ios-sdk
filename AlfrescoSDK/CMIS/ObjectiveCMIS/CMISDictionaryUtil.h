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


@interface NSDictionary (CMISDictionaryUtils)

///returns the object or nil if value is NSNull for given key
- (id)cmis_objectForKeyNotNull:(id)aKey;

///convenient method; returns BOOL value or NO if value is NSNull for given key
- (BOOL)cmis_boolForKey:(id)aKey;

///convenient method; returns int value or 0 if value is NSNull for given key
- (int)cmis_intForKey:(id)aKey;

@end


@interface CMISDictionaryUtil : NSObject

+ (NSDictionary *)userInfoDictionaryForErrorWithDescription:(NSString *)description
                                                     reason:(NSString *)reason
                                            underlyingError:(NSError *)error;

@end
