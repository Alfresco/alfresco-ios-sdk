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

#import "CMISProperties.h"

@interface CMISProperties ()
@property (nonatomic, strong) NSMutableDictionary *internalPropertiesByIdDict;
@property (nonatomic, strong) NSMutableDictionary *internalPropertiesByQueryNameDict;
@end

@implementation CMISProperties

@synthesize internalPropertiesByIdDict = _internalPropertiesByIdDict;
@synthesize internalPropertiesByQueryNameDict = _internalPropertiesByQueryNameDict;
@synthesize propertiesDictionary = _propertiesDictionary;
@synthesize propertyList = _propertyList;


- (void)addProperty:(CMISPropertyData *)propertyData
{
    if (self.internalPropertiesByIdDict == nil)
    {
        self.internalPropertiesByIdDict = [NSMutableDictionary dictionary];
    }
    [self.internalPropertiesByIdDict setObject:propertyData forKey:propertyData.identifier];

    if (propertyData.queryName != nil)
    {
        if (self.internalPropertiesByQueryNameDict == nil)
        {
            self.internalPropertiesByQueryNameDict = [NSMutableDictionary dictionary];
        }
        [self.internalPropertiesByQueryNameDict setObject:propertyData forKey:propertyData.queryName];
    }
}

- (NSDictionary *)propertiesDictionary
{
    return [NSDictionary dictionaryWithDictionary:self.internalPropertiesByIdDict];
}

- (NSArray *)propertyList
{
    return [NSArray arrayWithArray:self.internalPropertiesByIdDict.allValues];
}

- (CMISPropertyData *)propertyForId:(NSString *)id
{
    return [self.internalPropertiesByIdDict objectForKey:id];
}

- (CMISPropertyData *)propertyForQueryName:(NSString *)queryName
{
    return [self.internalPropertiesByQueryNameDict objectForKey:queryName];
}

- (id)propertyValueForId:(NSString *)propertyId
{
    return [[self propertyForId:propertyId] firstValue];
}

- (id)propertyValueForQueryName:(NSString *)queryName
{
    return [[self propertyForQueryName:queryName] firstValue];
}

- (NSArray *)propertyMultiValueById:(NSString *)id
{
    return [[self propertyForId:id] values];
}

- (NSArray *)propertyMultiValueByQueryName:(NSString *)queryName
{
    return [[self propertyForQueryName:queryName] values];
}


@end
