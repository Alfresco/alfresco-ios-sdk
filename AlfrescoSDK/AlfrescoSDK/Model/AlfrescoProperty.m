/*******************************************************************************
 * Copyright (C) 2005-2012 Alfresco Software Limited.
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
 ******************************************************************************/

#import "AlfrescoProperty.h"
#import "AlfrescoInternalConstants.h"

@interface AlfrescoProperty ()
@property (nonatomic, assign, readwrite) AlfrescoPropertyType type;
@property (nonatomic, assign, readwrite) BOOL isMultiValued;
@property (nonatomic, strong, readwrite) id value;
@end

@implementation AlfrescoProperty

@synthesize type = _type;
@synthesize isMultiValued = _isMultiValued;
@synthesize value = _value;

- (id)initWithProperties:(NSDictionary *)properties
{
    self = [super init];
    if (nil != self)
    {
        if ([[properties allKeys] containsObject:kAlfrescoPropertyType])
        {
            self.type = [[properties valueForKey:kAlfrescoPropertyType] intValue];
        }
        if ([[properties allKeys] containsObject:kAlfrescoPropertyValue])
        {
            self.value = [properties valueForKey:kAlfrescoPropertyValue];
        }
        if ([[properties allKeys] containsObject:kAlfrescoPropertyIsMultiValued])
        {
            self.isMultiValued = [[properties valueForKey:kAlfrescoPropertyIsMultiValued] boolValue];
        }
    }
    return self;
}

@end
