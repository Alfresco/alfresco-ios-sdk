/*
 ******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Mobile SDK.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *****************************************************************************
 */

#import "AlfrescoModelDefinition.h"
#import "AlfrescoPropertyConstants.h"
#import "CMISDictionaryUtil.h"

@interface AlfrescoModelDefinition ()
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) NSString *summary;
@property (nonatomic, strong, readwrite) NSString *parent;

@property (nonatomic, strong, readwrite) NSDictionary *propertyDefinitions;
@end

@implementation AlfrescoModelDefinition

- (instancetype)initWithDictionary:(NSDictionary *)properties
{
    self = [super init];
    if (nil != self)
    {
        self.name = [properties cmis_objectForKeyNotNull:kAlfrescoModelDefinitionPropertyName];
        self.title = [properties cmis_objectForKeyNotNull:kAlfrescoModelDefinitionPropertyTitle];
        self.summary = [properties cmis_objectForKeyNotNull:kAlfrescoModelDefinitionPropertySummary];
        self.parent = [properties cmis_objectForKeyNotNull:kAlfrescoModelDefinitionPropertyParent];
        self.propertyDefinitions = [properties cmis_objectForKeyNotNull:kAlfrescoModelDefinitionPropertyPropertyDefinitions];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (nil != self)
    {
        self.name = [aDecoder decodeObjectForKey:kAlfrescoModelDefinitionPropertyName];
        self.title = [aDecoder decodeObjectForKey:kAlfrescoModelDefinitionPropertyTitle];
        self.summary = [aDecoder decodeObjectForKey:kAlfrescoModelDefinitionPropertySummary];
        self.parent = [aDecoder decodeObjectForKey:kAlfrescoModelDefinitionPropertyParent];
        self.propertyDefinitions = [aDecoder decodeObjectForKey:kAlfrescoModelDefinitionPropertyPropertyDefinitions];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:kAlfrescoModelDefinitionPropertyName];
    [aCoder encodeObject:self.title forKey:kAlfrescoModelDefinitionPropertyTitle];
    [aCoder encodeObject:self.summary forKey:kAlfrescoModelDefinitionPropertySummary];
    [aCoder encodeObject:self.parent forKey:kAlfrescoModelDefinitionPropertyParent];
    [aCoder encodeObject:self.propertyDefinitions forKey:kAlfrescoModelDefinitionPropertyPropertyDefinitions];
}

- (NSArray *)propertyNames
{
    return [self.propertyDefinitions allKeys];
}

- (AlfrescoPropertyDefinition *)propertyDefinitionForPropertyWithName:(NSString *)name
{
    return self.propertyDefinitions[name];
}

- (void)addPropertyDefinitions:(NSArray *)definitions
{
    NSMutableDictionary *updatedPropertyDefinitions = [NSMutableDictionary dictionaryWithDictionary:self.propertyDefinitions];
    
    for (AlfrescoPropertyDefinition *propertyDefinition in definitions)
    {
        if ([updatedPropertyDefinitions objectForKey:propertyDefinition.name] == nil)
        {
            updatedPropertyDefinitions[propertyDefinition.name] = propertyDefinition;
        }
    }
    
    self.propertyDefinitions = updatedPropertyDefinitions;
}

@end
