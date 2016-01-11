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

#import "CMISQueryAtomEntryWriter.h"


@implementation CMISQueryAtomEntryWriter



- (id)init
{
    self = [super init];
    if (self) {
        self.relationships = CMISIncludeRelationshipNone;
    }
    return self;
}


- (NSString *)generateAtomEntryXML
{
    NSMutableString *xml = [[NSMutableString alloc] init];
    [xml appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"
        "<cmis:query xmlns:cmis=\"http://docs.oasis-open.org/ns/cmis/core/200908/\" "
                    "xmlns:cmism=\"http://docs.oasis-open.org/ns/cmis/messaging/200908/\" "
                    "xmlns:atom=\"http://www.w3.org/2005/Atom\" "
                    "xmlns:app=\"http://www.w3.org/2007/app\" "
                    "xmlns:cmisra=\"http://docs.oasis-open.org/ns/cmis/restatom/200908/\">"];

    [xml appendFormat:@"<cmis:statement>%@</cmis:statement>", self.statement];
    [xml appendFormat:@"<cmis:searchAllVersions>%@</cmis:searchAllVersions>", self.searchAllVersions ? @"true" : @"false"];

    [xml appendFormat:@"<cmis:includeAllowableActions>%@</cmis:includeAllowableActions>", self.includeAllowableActions ? @"true" : @"false"];
    [xml appendFormat:@"<cmis:includeRelationships>%@</cmis:includeRelationships>", [CMISEnums stringForIncludeRelationShip:self.relationships]];
    [xml appendFormat:@"<cmis:renditionFilter>%@</cmis:renditionFilter>", self.renditionFilter != nil ? self.renditionFilter : @"*"];

    if (self.maxItems != nil) {
        [xml appendFormat:@"<cmis:maxItems>%d</cmis:maxItems>", self.maxItems.intValue];
    }

    if (self.skipCount != nil) {
        [xml appendFormat:@"<cmis:skipCount>%d</cmis:skipCount>", self.skipCount.intValue];
    }
    [xml appendString:@"</cmis:query>"];

    return xml;
}

@end