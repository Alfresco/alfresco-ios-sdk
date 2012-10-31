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

@class CMISObjectList;

@protocol CMISDiscoveryService <NSObject>

/**
* (optional) Integer maxItems: This is the maximum number of items to return in a response.
*                              The repository MUST NOT exceed this maximum. Default is repository-specific.
(optional) Integer skipCount: This is the number of potential results that the repository MUST skip/page over
                              before returning any results. Defaults to 0.
*/
// TODO: add all params which are required by spec
- (void)query:(NSString *)statement searchAllVersions:(BOOL)searchAllVersions
                                 includeRelationShips:(CMISIncludeRelationship)includeRelationships
                                      renditionFilter:(NSString *)renditionFilter
                              includeAllowableActions:(BOOL)includeAllowableActions
                                             maxItems:(NSNumber *)maxItems
                                            skipCount:(NSNumber *)skipCount
                                      completionBlock:(void (^)(CMISObjectList *objectList, NSError *error))completionBlock;

@end
