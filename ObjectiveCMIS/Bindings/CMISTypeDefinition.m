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

#import "CMISTypeDefinition.h"
#import "CMISPropertyDefinition.h"

@interface CMISTypeDefinition ()

@property (nonatomic, strong) NSMutableDictionary *internalPropertyDefinitions;

@end


@implementation CMISTypeDefinition

@synthesize id = _id;
@synthesize localName = _localName;
@synthesize localNameSpace = _localNameSpace;
@synthesize displayName = _displayName;
@synthesize queryName = _queryName;
@synthesize description = _description;
@synthesize baseTypeId = _baseTypeId;
@synthesize isCreatable = _isCreatable;
@synthesize isFileable = _isFileable;
@synthesize isQueryable = _isQueryable;
@synthesize isFullTextIndexed = _isFullTextIndexed;
@synthesize isIncludedInSupertypeQuery = _isIncludedInSupertypeQuery;
@synthesize isControllablePolicy = _isControllablePolicy;
@synthesize isControllableAcl = _isControllableAcl;
@synthesize propertyDefinitions = _propertyDefinitions;
@synthesize internalPropertyDefinitions = _internalPropertyDefinitions;

- (NSDictionary *)propertyDefinitions
{
    return self.internalPropertyDefinitions;
}

- (void)addPropertyDefinition:(CMISPropertyDefinition *)propertyDefinition
{
    if (self.internalPropertyDefinitions == nil)
    {
        self.internalPropertyDefinitions = [[NSMutableDictionary alloc] init];
    }
    [self.internalPropertyDefinitions setObject:propertyDefinition forKey:propertyDefinition.id];
}

- (CMISPropertyDefinition *)propertyDefinitionForId:(NSString *)propertyId
{
    return [self.internalPropertyDefinitions objectForKey:propertyId];
}

@end