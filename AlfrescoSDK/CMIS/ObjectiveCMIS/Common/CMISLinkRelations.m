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

#import "CMISLinkRelations.h"

@interface CMISLinkRelations ()
@property (nonatomic, strong, readwrite) NSSet *linkRelationSet;
@end

@implementation CMISLinkRelations


- (id)initWithLinkRelationSet:(NSSet *)linkRelationSet
{
    self = [super init];
    if (self) {
        self.linkRelationSet = linkRelationSet;
    }
    return self;
}

- (NSString *)linkHrefForRel:(NSString *)rel
{
    return [self linkHrefForRel:rel type:nil];
}

- (NSString *)linkHrefForRel:(NSString *)rel type:(NSString *)type
{
    NSArray *predicateArgsArray = nil;
    
    NSString *predicateFormat = @"(rel == %@)";
    if (type != nil && type.length > 0) {
        predicateFormat = [predicateFormat stringByAppendingString:@"&& (type == %@)"];
        predicateArgsArray = [NSArray arrayWithObjects:rel, type, nil];
    } else {
        predicateArgsArray = [NSArray arrayWithObject:rel];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat argumentArray:predicateArgsArray];
    NSSet *filteredSet = [self.linkRelationSet filteredSetUsingPredicate:predicate];
    if ([filteredSet count] == 1) {
        return [filteredSet.anyObject valueForKey:@"href"];
    }
    
    // We will only get here if the link to return is ambiguous or if no link is found for the rel/type
    
    return nil;
}

@end
