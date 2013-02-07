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

@class CMISCollection;
@class CMISObject;
@class CMISObjectData;

@protocol CMISVersioningService <NSObject>

/**
 * Get a the latest Document object in the Version Series.
 */
- (void)retrieveObjectOfLatestVersion:(NSString *)objectId
                                major:(BOOL)major
                               filter:(NSString *)filter
                 includeRelationShips:(CMISIncludeRelationship)includeRelationships
                     includePolicyIds:(BOOL)includePolicyIds
                      renditionFilter:(NSString *)renditionFilter
                           includeACL:(BOOL)includeACL
              includeAllowableActions:(BOOL)includeAllowableActions
                      completionBlock:(void (^)(CMISObjectData *objectData, NSError *error))completionBlock;

/*
 * Returns the list of all Document Object in the given version series, sorted by creationDate descending (ie youngest first)
 */
- (void)retrieveAllVersions:(NSString *)objectId
                     filter:(NSString *)filter
    includeAllowableActions:(BOOL)includeAllowableActions
            completionBlock:(void (^)(NSArray *objects, NSError *error))completionBlock;

/* deprecated
- (CMISObjectData *)retrieveObjectOfLatestVersion:(NSString *)objectId
                                            major:(BOOL)major
                                           filter:(NSString *)filter
                             includeRelationShips:(CMISIncludeRelationship)includeRelationships
                                 includePolicyIds:(BOOL)includePolicyIds
                                  renditionFilter:(NSString *)renditionFilter
                                       includeACL:(BOOL)includeACL
                          includeAllowableActions:(BOOL)includeAllowableActions
                                            error:(NSError **)error;

- (NSArray *)retrieveAllVersions:(NSString *)objectId
                          filter:(NSString *)filter
         includeAllowableActions:(BOOL)includeAllowableActions
                           error:(NSError * *)error;
 */

@end
