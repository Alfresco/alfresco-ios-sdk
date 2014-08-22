/*
 ******************************************************************************
 * Copyright (C) 2005-2014 Alfresco Software Limited.
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

#import "AlfrescoPropertyDefinition.h"
#import "AlfrescoPropertyConstants.h"
#import "AlfrescoConstants.h"
#import "CMISDictionaryUtil.h"
#import "CMISConstants.h"

@interface AlfrescoPropertyDefinition ()
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) NSString *summary;
@property (nonatomic, assign, readwrite) AlfrescoPropertyType type;
@property (nonatomic, assign, readwrite) BOOL isRequired;
@property (nonatomic, assign, readwrite) BOOL isReadOnly;
@property (nonatomic, assign, readwrite) BOOL isMultiValued;
@property (nonatomic, assign, readwrite) id defaultValue;
@property (nonatomic, strong, readwrite) NSArray *allowableValues;
@end

@implementation AlfrescoPropertyDefinition

- (instancetype)initWithDictionary:(NSDictionary *)properties
{
    self = [super init];
    if (nil != self)
    {
        self.name = [properties cmis_objectForKeyNotNull:kAlfrescoPropertyDefinitionPropertyName];
        self.title = [properties cmis_objectForKeyNotNull:kAlfrescoPropertyDefinitionPropertyTitle];
        self.summary = [properties cmis_objectForKeyNotNull:kAlfrescoPropertyDefinitionPropertySummary];
        self.defaultValue = [properties cmis_objectForKeyNotNull:kAlfrescoPropertyDefinitionPropertyDefaultValue];
        self.allowableValues = [properties cmis_objectForKeyNotNull:kAlfrescoPropertyDefinitionPropertyAllowableValues];
        self.type = [properties cmis_intForKey:kAlfrescoPropertyDefinitionPropertyType];
        self.isRequired = [properties cmis_boolForKey:kAlfrescoPropertyDefinitionPropertyIsRequired];
        self.isReadOnly = [properties cmis_boolForKey:kAlfrescoPropertyDefinitionPropertyIsReadOnly];
        self.isMultiValued = [properties cmis_boolForKey:kAlfrescoPropertyDefinitionPropertyIsMultiValued];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (nil != self)
    {
        self.name = [aDecoder decodeObjectForKey:kAlfrescoPropertyDefinitionPropertyName];
        self.title = [aDecoder decodeObjectForKey:kAlfrescoPropertyDefinitionPropertyTitle];
        self.summary = [aDecoder decodeObjectForKey:kAlfrescoPropertyDefinitionPropertySummary];
        self.defaultValue = [aDecoder decodeObjectForKey:kAlfrescoPropertyDefinitionPropertyDefaultValue];
        self.allowableValues = [aDecoder decodeObjectForKey:kAlfrescoPropertyDefinitionPropertyAllowableValues];
        self.type = [aDecoder decodeIntForKey:kAlfrescoPropertyDefinitionPropertyType];
        self.isRequired = [aDecoder decodeBoolForKey:kAlfrescoPropertyDefinitionPropertyIsRequired];
        self.isReadOnly = [aDecoder decodeBoolForKey:kAlfrescoPropertyDefinitionPropertyIsReadOnly];
        self.isMultiValued = [aDecoder decodeBoolForKey:kAlfrescoPropertyDefinitionPropertyIsMultiValued];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:kAlfrescoPropertyDefinitionPropertyName];
    [aCoder encodeObject:self.title forKey:kAlfrescoPropertyDefinitionPropertyTitle];
    [aCoder encodeObject:self.summary forKey:kAlfrescoPropertyDefinitionPropertySummary];
    [aCoder encodeObject:self.defaultValue forKey:kAlfrescoPropertyDefinitionPropertyDefaultValue];
    [aCoder encodeObject:self.allowableValues forKey:kAlfrescoPropertyDefinitionPropertyAllowableValues];
    [aCoder encodeInt:self.type forKey:kAlfrescoPropertyDefinitionPropertyType];
    [aCoder encodeBool:self.isRequired forKey:kAlfrescoPropertyDefinitionPropertyIsRequired];
    [aCoder encodeBool:self.isReadOnly forKey:kAlfrescoPropertyDefinitionPropertyIsReadOnly];
    [aCoder encodeBool:self.isMultiValued forKey:kAlfrescoPropertyDefinitionPropertyIsMultiValued];
}

- (BOOL)isRequired
{
    // cmis:name and cm:name should always be required but MNT-5773 caused it to be
    // false on older servers, make sure we always return YES
    if ([self.name isEqualToString:kCMISPropertyName] || [self.name isEqualToString:kAlfrescoModelPropertyName])
    {
        return YES;
    }
    else
    {
        return _isRequired;
    }
}

@end
