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

#import "CMISTypeDefinitionCache.h"
#import "CMISBindingSession.h"
#import "CMISLog.h"

// Default type definition cache size is 100 entries
#define DEFAULT_TYPE_DEFINITION_CACHE_SIZE 100

@interface TypeDefinitionCacheKey : NSObject

@property (nonatomic, strong) NSString *repositoryId;
@property (nonatomic, strong) NSString *typeDefinitionId;

/// Designated Initializer
+ (TypeDefinitionCacheKey *) initWithTypeDefinitionId:(NSString *)typeDefinitionId repositoryId:(NSString *)repositoryId;

@end

@interface CMISTypeDefinitionCache ()  <NSCacheDelegate>

@property (nonatomic, strong) NSCache *typeDefinitionCache;

@end

@implementation CMISTypeDefinitionCache

- (id)initWithBindingSession:(CMISBindingSession *)bindingSession
{
    self = [super init];
    if (self) {
        [self setupTypeDefinitionCache:bindingSession];
        
    }
    return self;
}

- (void)setupTypeDefinitionCache:(CMISBindingSession *)bindingSession
{
    self.typeDefinitionCache = [[NSCache alloc] init];
    
    id typeDefinitionCacheSize = [bindingSession objectForKey:kCMISSessionParameterTypeDefinitionCacheSize];
    if (typeDefinitionCacheSize != nil) {
        if ([[typeDefinitionCacheSize class] isEqual:[NSNumber class]]) {
            self.typeDefinitionCache.countLimit = [(NSNumber *) typeDefinitionCacheSize unsignedIntValue];
        } else {
            CMISLogError(@"Invalid object set for %@ session parameter. Ignoring and using default instead", kCMISSessionParameterTypeDefinitionCacheSize);
        }
    }
    
    if (self.typeDefinitionCache.countLimit <= 0) {
        self.typeDefinitionCache.countLimit = DEFAULT_TYPE_DEFINITION_CACHE_SIZE;
    }
    
    // Uncomment for debugging
    // self.typeDefinitionCache.delegate = self;
}

- (void)addTypeDefinition:(CMISTypeDefinition *)typeDefinition repositoryId:(NSString *)repositoryId
{
    TypeDefinitionCacheKey *key = [TypeDefinitionCacheKey initWithTypeDefinitionId:typeDefinition.identifier repositoryId:repositoryId];
    [self.typeDefinitionCache setObject:typeDefinition forKey:key];
    
}

- (CMISTypeDefinition *)typeDefinitionForTypeId:(NSString *)typeId repositoryId:(NSString *)repositoryId
{
    TypeDefinitionCacheKey *key = [TypeDefinitionCacheKey initWithTypeDefinitionId:typeId repositoryId:repositoryId];
    return [self.typeDefinitionCache objectForKey:key];
}

- (void)removeTypeDefinitionForTypeId:(NSString *)typeId repositoryId:(NSString *)repositoryId
{
    TypeDefinitionCacheKey *key = [TypeDefinitionCacheKey initWithTypeDefinitionId:typeId repositoryId:repositoryId];
    [self.typeDefinitionCache removeObjectForKey:key];
}

- (void)removeAll
{
    [self.typeDefinitionCache removeAllObjects];
    
}

// Debugging
//- (void)cache:(NSCache *)cache willEvictObject:(id)obj
//{
//    CMISLogDebug(@"Type definition cache will evict cached type definitions for object '%@'", obj);
//}

@end

@implementation TypeDefinitionCacheKey

+ (TypeDefinitionCacheKey *)initWithTypeDefinitionId:(NSString *)typeDefinitionId repositoryId:(NSString *)repositoryId
{
    TypeDefinitionCacheKey *key = [[TypeDefinitionCacheKey alloc] init];
    
    key.typeDefinitionId = typeDefinitionId;
    key.repositoryId = repositoryId;
    
    return key;
}

-(BOOL)isEqual:(id)object{
    if(![object isKindOfClass: [TypeDefinitionCacheKey class]]){
        return NO;
    }
    TypeDefinitionCacheKey *otherKey = (TypeDefinitionCacheKey*)object;
    if(![_repositoryId isEqualToString:otherKey.repositoryId]){
        return NO;
    }
    
    if(![_typeDefinitionId isEqualToString:otherKey.typeDefinitionId]){
        return NO;
    }
    
    return YES;
}

-(NSUInteger)hash{
    return [_repositoryId hash] ^ [_typeDefinitionId hash];
}

@end
