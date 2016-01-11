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

#import "CMISAtomPubObjectByIdUriBuilder.h"

@interface CMISAtomPubObjectByIdUriBuilder ()

@property (nonatomic, strong) NSString *templateUrl;

@end

@implementation CMISAtomPubObjectByIdUriBuilder


- (id)initWithTemplateUrl:(NSString *)templateUrl
{
    self = [super init];
    if (self) {
        self.templateUrl = templateUrl;

        // Defaults
        self.includeAllowableActions = YES;
        self.relationships = CMISIncludeRelationshipNone;
        self.returnVersion = NOT_PROVIDED;
    }
    return self;
}

- (NSURL *)buildUrl
{
    // make sure we have an objectId, without one there's little point in generating the URL!
    assert(self.objectId);
    
    NSString *urlString = [self.templateUrl stringByReplacingOccurrencesOfString:@"{id}" withString:self.objectId];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{filter}" withString:(self.filter != nil ? self.filter : @"")];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{includeAllowableActions}" withString:(self.includeAllowableActions ? @"true" : @"false")];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{includePolicyIds}" withString:(self.includePolicyIds ? @"true" : @"false")];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{includeACL}" withString:(self.includeACL ? @"true" : @"false")];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{renditionFilter}" withString:(self.renditionFilter != nil ? self.renditionFilter : @"")];
    
    NSString *includeRelationShipParam = [CMISEnums stringForIncludeRelationShip:self.relationships];
    if (includeRelationShipParam == nil) {
        includeRelationShipParam = [CMISEnums stringForIncludeRelationShip:CMISIncludeRelationshipNone];
    }
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{includeRelationships}" withString:includeRelationShipParam];

    if (self.returnVersion != NOT_PROVIDED) {
        NSString *returnVersionParam = nil;
        if (self.returnVersion == THIS) {
            returnVersionParam = @"this";
        } else if (self.returnVersion == LATEST) {
            returnVersionParam = @"latest";
        } else {
            returnVersionParam = @"latestmajor";
        }

        urlString = [NSString stringWithFormat:@"%@&returnVersion=%@", urlString, returnVersionParam];
    }

    return [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

@end