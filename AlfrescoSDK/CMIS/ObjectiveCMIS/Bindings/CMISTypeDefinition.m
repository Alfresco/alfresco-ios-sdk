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

#import "CMISTypeDefinition.h"
#import "CMISPropertyDefinition.h"

@interface CMISTypeDefinition ()

@property (nonatomic, strong) NSMutableDictionary *internalPropertyDefinitions;

@end


@implementation CMISTypeDefinition

- (NSDictionary *)propertyDefinitions
{
    return self.internalPropertyDefinitions;
}

- (void)addPropertyDefinition:(CMISPropertyDefinition *)propertyDefinition
{
    if (self.internalPropertyDefinitions == nil) {
        self.internalPropertyDefinitions = [[NSMutableDictionary alloc] init];
    }
    [self.internalPropertyDefinitions setObject:propertyDefinition forKey:propertyDefinition.identifier];
}

- (CMISPropertyDefinition *)propertyDefinitionForId:(NSString *)propertyId
{
    return [self.internalPropertyDefinitions objectForKey:propertyId];
}

-(void)setParentTypeId:(NSString *)parentTypeId
{
    if (!parentTypeId || parentTypeId.length == 0) {
        _parentTypeId = nil;
    } else {
        _parentTypeId = parentTypeId;
    }
}

@end