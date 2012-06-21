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

#import "CMISRepositoryInfo.h"

@implementation CMISRepositoryInfo

@synthesize identifier = _identifier;
@synthesize name = _name;
@synthesize desc = _desc;
@synthesize rootFolderId = _rootFolderId;
@synthesize cmisVersionSupported = _cmisVersionSupported;
@synthesize productName = _productName;
@synthesize productVersion = _productVersion;
@synthesize vendorName = _vendorName;
@synthesize repositoryCapabilities = _repositoryCapabilities;

- (NSString *)description
{
    return [NSString stringWithFormat:@"identifer: %@, name: %@, version: %@", 
            self.identifier, self.name, self.productVersion];
}

@end
