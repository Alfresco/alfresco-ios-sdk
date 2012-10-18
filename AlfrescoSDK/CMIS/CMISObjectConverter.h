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
#import "CMISObject.h"
#import "CMISObjectData.h"
#import "CMISCollection.h"

@class CMISSession;

@interface CMISObjectConverter : NSObject

/**
 * Initializes an instance of this class.
 */
- (id)initWithSession:(CMISSession *)session;

/**
 * Converts data received by the server to a CmisObject (document, folder, etc.)
 */
- (CMISObject *)convertObject:(CMISObjectData *)objectData;

/**
 * Convenience method that converts a list of objects at once.
 */
- (CMISCollection *)convertObjects:(NSArray *)objects;

/**
 * Converts the given dictionary of properties, where the key is the property id and the value
 * can be a CMISPropertyData or a regular string.
 */
- (CMISProperties *)convertProperties:(NSDictionary *)properties forObjectTypeId:(NSString *)objectTypeId error:(NSError **)error;

@end
