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

#import <Foundation/Foundation.h>
#import "AlfrescoProperty.h"

/**
 * AlfrescoPropertyDefinition represents the definition of a property.
 */

@interface AlfrescoPropertyDefinition : NSObject

/// The name of the property.
@property (nonatomic, strong, readonly) NSString *name;

/// The localized title of the property.
@property (nonatomic, strong, readonly) NSString *title;

/// The localized description of the property.
@property (nonatomic, strong, readonly) NSString *summary;

/// The type of the property.
@property (nonatomic, assign, readonly) AlfrescoPropertyType type;

/// Indicates whether the property requires a value to be provided.
@property (nonatomic, assign, readonly) BOOL isRequired;

/// Indicates whether the property value is read only.
@property (nonatomic, assign, readonly) BOOL isReadOnly;

/// Indicates whether the property can hold multiple values.
@property (nonatomic, assign, readonly) BOOL isMultiValued;

/// The default value of the property, this will be an array for multi valued properties.
@property (nonatomic, assign, readonly) id defaultValue;

/// An array of objects representing the values the property value can hold.
@property (nonatomic, strong, readonly) NSArray *allowableValues;


- (instancetype)initWithDictionary:(NSDictionary *)properties;

@end
