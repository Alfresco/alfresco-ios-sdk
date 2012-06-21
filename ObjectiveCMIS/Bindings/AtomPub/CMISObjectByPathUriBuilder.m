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

#import "CMISObjectByPathUriBuilder.h"
#import "CMISEnums.h"

@interface CMISObjectByPathUriBuilder ()

@property (nonatomic, strong) NSString *templateUrl;

@end


@implementation CMISObjectByPathUriBuilder

@synthesize templateUrl = _templateUrl;
@synthesize path = _path;
@synthesize filter = _filter;
@synthesize includeAllowableActions = _includeAllowableActions;
@synthesize includePolicyIds = _includePolicyIds;
@synthesize includeRelationships = _includeRelationships;
@synthesize includeACL = _includeACL;
@synthesize renditionFilter = _renditionFilter;

- (id)initWithTemplateUrl:(NSString *)templateUrl
{
    self = [super init];
    if (self)
    {
        self.templateUrl = templateUrl;
    }
    return self;
}

- (NSURL *)buildUrl
{
    NSString *urlString = [self.templateUrl stringByReplacingOccurrencesOfString:@"{path}" withString:self.path];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{filter}" withString:(self.filter != nil ? self.filter : @"")];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{includeAllowableActions}" withString:(self.includeAllowableActions ? @"true" : @"false")];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{includePolicyIds}" withString:(self.includePolicyIds ? @"true" : @"false")];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{includeRelationships}" withString:[CMISEnums stringForIncludeRelationShip:self.includeRelationships]];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{includeACL}" withString:(self.includeACL ? @"true" : @"false")];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{renditionFilter}" withString:(self.renditionFilter != nil ? self.renditionFilter : @"")];

    return [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
}


@end