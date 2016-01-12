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

#import "CMISAtomPubObjectByPathUriBuilder.h"

@interface CMISAtomPubObjectByPathUriBuilder ()

@property (nonatomic, strong) NSString *templateUrl;

@end


@implementation CMISAtomPubObjectByPathUriBuilder


- (id)initWithTemplateUrl:(NSString *)templateUrl
{
    self = [super init];
    if (self) {
        self.templateUrl = templateUrl;
    }
    return self;
}

- (NSURL *)buildUrl
{
    // make sure we have a path, without one there's little point in generating the URL!
    assert(self.path);
    
    NSString *urlString = [self.templateUrl stringByReplacingOccurrencesOfString:@"{path}" withString:self.path];
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

    return [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}


@end