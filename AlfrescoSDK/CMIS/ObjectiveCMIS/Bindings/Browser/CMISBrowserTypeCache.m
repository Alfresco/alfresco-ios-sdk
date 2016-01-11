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

#import "CMISBrowserTypeCache.h"
#import "CMISTypeDefinition.h"
#import "CMISBrowserBaseService+Protected.h"
#import "CMISRequest.h"
#import "CMISTypeDefinitionCache.h"
#import "CMISBindingSession.h"

@interface CMISBrowserTypeCache ()

@property (nonatomic, weak) NSString * repositoryId;
@property (nonatomic, weak) CMISBrowserBaseService * service;

@end

@implementation CMISBrowserTypeCache


-(id)initWithRepositoryId:(NSString *)repositoryId bindingService:(CMISBrowserBaseService *)service
{
    self = [super init];
    if (self) {
        _repositoryId = repositoryId;
        _service = service;
    }
    return self;
}

- (CMISRequest *)typeDefinition:(NSString *)typeId
                       completionBlock:(void (^)(CMISTypeDefinition *typeDefinition, NSError *error))completionBlock
{
    CMISTypeDefinitionCache *cache = _service.bindingSession.typeDefinitionCache;
    CMISRequest *request = nil;
    CMISTypeDefinition *typeDefinition = [cache typeDefinitionForTypeId:typeId repositoryId:self.repositoryId];
    if (!typeDefinition) { // Retrieve type definition from server
        request = [[CMISRequest alloc] init];
        [_service retrieveTypeDefinitionInternal:typeId cmisRequest:request completionBlock:^(CMISTypeDefinition *typeDefinition, NSError *error){
            if (error) {
                completionBlock(nil, error);
            } else {
                if (typeDefinition) { // Store type definition in cache
                    [cache addTypeDefinition:typeDefinition repositoryId:self.repositoryId];
                }
                
                completionBlock(typeDefinition, nil);
            }
        }];
    } else { // Type definition from cache
        completionBlock(typeDefinition, nil);
    }
    
    return request;
}

@end
