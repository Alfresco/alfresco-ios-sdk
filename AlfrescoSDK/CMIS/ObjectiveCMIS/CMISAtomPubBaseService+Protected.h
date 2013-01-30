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
#import "CMISAtomPubBaseService.h"
#import "CMISObjectByIdUriBuilder.h"

@class CMISObjectData;

@interface CMISAtomPubBaseService (Protected)

- (void)fetchRepositoryInfoWithCompletionBlock:(void (^)(NSError *error))completionBlock;

- (void)retrieveCMISWorkspacesWithCompletionBlock:(void (^)(NSArray *workspaces, NSError *error))completionBlock;

/** Convenience method with all the defaults for the retrieval parameters */
- (void)retrieveObjectInternal:(NSString *)objectId completionBlock:(void (^)(CMISObjectData *objectData, NSError *error))completionBlock;

/** Full-blown object retrieval version */
- (void)retrieveObjectInternal:(NSString *)objectId
                         withReturnVersion:(CMISReturnVersion)cmisReturnVersion
                                withFilter:(NSString *)filter
                   andIncludeRelationShips:(CMISIncludeRelationship)includeRelationship
                       andIncludePolicyIds:(BOOL)includePolicyIds
                        andRenditionFilder:(NSString *)renditionFilter
                             andIncludeACL:(BOOL)includeACL
                andIncludeAllowableActions:(BOOL)includeAllowableActions
               completionBlock:(void (^)(CMISObjectData *objectData, NSError *error))completionBlock;

- (void)retrieveObjectByPathInternal:(NSString *)path
                          withFilter:(NSString *)filter
             andIncludeRelationShips:(CMISIncludeRelationship)includeRelationship
                 andIncludePolicyIds:(BOOL)includePolicyIds
                  andRenditionFilder:(NSString *)renditionFilter
                       andIncludeACL:(BOOL)includeACL
          andIncludeAllowableActions:(BOOL)includeAllowableActions
                     completionBlock:(void (^)(CMISObjectData *objectData, NSError *error))completionBlock;

- (void)retrieveFromCache:(NSString *)cacheKey
          completionBlock:(void (^)(id object, NSError *error))completionBlock;

- (void)loadLinkForObjectId:(NSString *)objectId
                andRelation:(NSString *)rel
            completionBlock:(void (^)(NSString *link, NSError *error))completionBlock;

- (void)loadLinkForObjectId:(NSString *)objectId
                andRelation:(NSString *)rel
                    andType:(NSString *)type
            completionBlock:(void (^)(NSString *link, NSError *error))completionBlock;

@end
