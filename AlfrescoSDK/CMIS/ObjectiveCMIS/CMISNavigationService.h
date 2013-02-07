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

@class CMISFolder;
@class CMISObjectList;

@protocol CMISNavigationService <NSObject>

/*
 * Retrieves the children for the given object identifier.
 */
- (void)retrieveChildren:(NSString *)objectId orderBy:(NSString *)orderBy
                  filter:(NSString *)filter includeRelationShips:(CMISIncludeRelationship)includeRelationship
         renditionFilter:(NSString *)renditionFilter includeAllowableActions:(BOOL)includeAllowableActions
      includePathSegment:(BOOL)includePathSegment skipCount:(NSNumber *)skipCount
                maxItems:(NSNumber *)maxItems
         completionBlock:(void (^)(CMISObjectList *objectList, NSError *error))completionBlock;

/**
* Retrieves the parent of a given object.
* Returns a list of CMISObjectData objects
*
* TODO: OpenCMIS returns an ObjectParentData object .... is this necessary?
*/
- (void)retrieveParentsForObject:(NSString *)objectId
                      withFilter:(NSString *)filter
        withIncludeRelationships:(CMISIncludeRelationship)includeRelationship
             withRenditionFilter:(NSString *)renditionFilter
     withIncludeAllowableActions:(BOOL)includeAllowableActions
  withIncludeRelativePathSegment:(BOOL)includeRelativePathSegment
                 completionBlock:(void (^)(NSArray *parents, NSError *error))completionBlock;


@end
