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
#import "CMISObjectByIdUriBuilder.h"

@interface CMISObjectByIdUriBuilder ()

@property (nonatomic, strong) NSString *templateUrl;

@end

@implementation CMISObjectByIdUriBuilder

@synthesize templateUrl = _templateUrl;
@synthesize objectId = _objectId;
@synthesize filter = _filter;
@synthesize includeAllowableActions = _includeAllowableActions;
@synthesize includePolicyIds = _includePolicyIds;
@synthesize includeRelationships = _includeRelationships;
@synthesize includeACL = _includeACL;
@synthesize renditionFilter = _renditionFilter;
@synthesize returnVersion = _returnVersion;

- (id)initWithTemplateUrl:(NSString *)templateUrl
{
    self = [super init];
    if (self)
    {
        self.templateUrl = templateUrl;

        // Defaults
        self.includeAllowableActions = YES;
        self.includeRelationships = CMISIncludeRelationshipNone;
        self.returnVersion = NOT_PROVIDED;
    }
    return self;
}

- (NSURL *)buildUrl
{
    NSString *urlString = [self.templateUrl stringByReplacingOccurrencesOfString:@"{id}" withString:self.objectId];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{filter}" withString:(self.filter != nil ? self.filter : @"")];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{includeAllowableActions}" withString:(self.includeAllowableActions ? @"true" : @"false")];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{includePolicyIds}" withString:(self.includePolicyIds ? @"true" : @"false")];

    NSString *includeRelationShipParam = [CMISEnums stringForIncludeRelationShip:self.includeRelationships];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{includeRelationships}" withString:includeRelationShipParam];


    urlString = [urlString stringByReplacingOccurrencesOfString:@"{includeACL}" withString:(self.includeACL ? @"true" : @"false")];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{renditionFilter}" withString:(self.renditionFilter != nil ? self.renditionFilter : @"")];

    if (self.returnVersion != NOT_PROVIDED)
    {
        NSString *returnVersionParam = nil;
        if (self.returnVersion == THIS)
        {
            returnVersionParam = @"this";
        }
        else if (self.returnVersion == LATEST)
        {
            returnVersionParam = @"latest";
        }
        else
        {
            returnVersionParam = @"latestmajor";
        }

        urlString = [NSString stringWithFormat:@"%@&returnVersion=%@", urlString, returnVersionParam];
    }

    return [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
}

@end