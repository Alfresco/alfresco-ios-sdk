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

#import "CMISObjectData.h"
#import "CMISRenditionData.h"

@implementation CMISObjectData

@synthesize identifier = _identifier;
@synthesize baseType = _baseType;
@synthesize properties = _properties;
@synthesize linkRelations = _linkRelations;
@synthesize contentUrl = _contentUrl;
@synthesize allowableActions = _allowableActions;
@synthesize renditions = _renditions;

@end
