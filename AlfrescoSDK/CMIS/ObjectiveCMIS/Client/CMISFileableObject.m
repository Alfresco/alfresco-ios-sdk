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

#import "CMISFileableObject.h"
#import "CMISObjectConverter.h"
#import "CMISOperationContext.h"
#import "CMISSession.h"

@implementation CMISFileableObject


- (CMISRequest*)retrieveParentsWithCompletionBlock:(void (^)(NSArray *parentFolders, NSError *error))completionBlock
{
    return [self retrieveParentsWithOperationContext:[CMISOperationContext defaultOperationContext] completionBlock:completionBlock];
}

- (CMISRequest*)retrieveParentsWithOperationContext:(CMISOperationContext *)operationContext
                            completionBlock:(void (^)(NSArray *parentFolders, NSError *error))completionBlock
{
    return [self.binding.navigationService retrieveParentsForObject:self.identifier
                                                      filter:operationContext.filterString
                                               relationships:operationContext.relationships
                                             renditionFilter:operationContext.renditionFilterString
                                     includeAllowableActions:operationContext.includeAllowableActions
                                  includeRelativePathSegment:operationContext.includePathSegments
                                             completionBlock:^(NSArray *parentObjectDataArray, NSError *error) {
                                                 [self.session.objectConverter convertObjects:parentObjectDataArray
                                                                              completionBlock:^(NSArray *objects, NSError *error) {
                                                                                  completionBlock(objects, error);
                                                                              }];
                                             }];
}

- (CMISRequest *)moveFromFolderWithId:(NSString *)sourceFolderId
                       toFolderWithId:(NSString *)targetFolderId
                      completionBlock:(void (^)(CMISObject *, NSError *))completionBlock
{
    return [self.binding.objectService moveObject:self.identifier
                                       fromFolder:sourceFolderId
                                         toFolder:targetFolderId
                                  completionBlock:^(CMISObjectData *objectData, NSError *error) {
                                      
                                      [self.session.objectConverter convertObject:objectData completionBlock:completionBlock];
                                  }];
}


@end
