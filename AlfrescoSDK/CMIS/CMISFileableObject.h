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

#import "CMISObject.h"

@class CMISOperationContext;

@interface CMISFileableObject : CMISObject

/**
* Returns all the parents of this object as an array of CMISFolder objects.
*
* Will be nil for root folder and non-fileable objects.
*/
- (void)retrieveParentsWithCompletionBlock:(void (^)(NSArray *parentFolders, NSError *error))completionBlock;

/**
* Returns all the parents of this object as an array of CMISFolder objects.
*
* Will be nil for root folder and non-fileable objects.
*/
- (void)retrieveParentsWithOperationContext:(CMISOperationContext *)operationContext 
                            completionBlock:(void (^)(NSArray *parentFolders, NSError *error))completionBlock;


@end
