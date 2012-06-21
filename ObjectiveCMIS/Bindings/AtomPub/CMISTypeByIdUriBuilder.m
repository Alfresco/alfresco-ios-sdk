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

#import "CMISTypeByIdUriBuilder.h"

@interface CMISTypeByIdUriBuilder ()

@property (nonatomic, strong) NSString *templateUrl;

@end


@implementation CMISTypeByIdUriBuilder

@synthesize id = _id;
@synthesize templateUrl = _templateUrl;

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
    return [NSURL URLWithString:[self.templateUrl stringByReplacingOccurrencesOfString:@"{id}" withString:self.id]];
}


@end