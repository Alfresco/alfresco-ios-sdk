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

#import "CMISWorkspace.h"
#import "CMISRepositoryInfo.h"
#import "CMISSessionParameters.h"
#import "CMISAtomCollection.h"

@implementation CMISWorkspace

@synthesize sessionParameters = _sessionParameters;
@synthesize repositoryInfo = _repositoryInfo;

@synthesize collections = _collections;
@synthesize linkRelations = _linkRelations;

@synthesize objectByIdUriTemplate = _objectByIdUriTemplate;
@synthesize queryUriTemplate = _queryUriTemplate;
@synthesize typeByIdUriTemplate = _typeByIdUriTemplate;
@synthesize objectByPathUriTemplate = _objectByPathUriTemplate;

- (NSString *)collectionHrefForCollectionType:(NSString *)collectionType
{
    if (self.collections != nil)
    {
        for (CMISAtomCollection *collection in self.collections)
        {
            if ([collection.type isEqualToString:collectionType])
            {
                return collection.href;
            }
        }
    }
    return nil;
}

@end