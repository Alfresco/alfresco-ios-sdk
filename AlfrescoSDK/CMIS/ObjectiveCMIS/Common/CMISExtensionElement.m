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

#import "CMISExtensionElement.h"

@interface CMISExtensionElement ()

@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSString *namespaceUri;
@property (nonatomic, strong, readwrite) NSString *value;
@property (nonatomic, strong, readwrite) NSDictionary *attributes;
@property (nonatomic, strong, readwrite) NSArray *children;

/// Designated Initializer.  This initializer is private since we do not want the user to use one of the two public init methods defined in the header
- (id)initWithName:(NSString *)name namespaceUri:(NSString *)namespaceUri;

@end

@implementation CMISExtensionElement

#pragma mark -
#pragma mark Initializers

- (id)initWithName:(NSString *)name namespaceUri:(NSString *)namespaceUri
{
    self = [super init];
    if (self) {
        self.name = name;
        self.namespaceUri = namespaceUri;
    }
    return self;
}

- (id)initNodeWithName:(NSString *)name namespaceUri:(NSString *)namespaceUri attributes:(NSDictionary *)attributesDict children:(NSArray *)children
{
    self = [self initWithName:name namespaceUri:namespaceUri];
    if (self) {
        self.value = nil;
        self.attributes = attributesDict;
        self.children = children;
    }
    return self;
}

- (id)initLeafWithName:(NSString *)name namespaceUri:(NSString *)namespaceUri attributes:(NSDictionary *)attributesDict value:(NSString *)value
{
    self = [self initWithName:name namespaceUri:namespaceUri];
    if (self) {
        self.value = value;
        self.attributes = attributesDict;
        self.children = nil;
    }
    return self;
}

#pragma mark - 
#pragma mark NSObject Overrides

- (NSString *)description
{
    return [NSString stringWithFormat:@"CMISExtensionElement: %@%@ %@: %@", 
            (self.namespaceUri ? ([NSString stringWithFormat:@"{%@}", self.namespaceUri]) : @""), 
            self.name, 
            (([self.attributes count] > 0) ? self.attributes : @"{}"), 
            ((self.children.count == 0)  ? self.value : self.children)];
}


@end
