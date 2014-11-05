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

#import <Foundation/Foundation.h>
#import "AlfrescoPropertyDefinition.h"

/**
 * AlfrescoModelDefinition represents the definition of an item in the repository content model.
 */

@interface AlfrescoModelDefinition : NSObject <NSCoding>

/// The name of the model item.
@property (nonatomic, strong, readonly) NSString *name;

/// The localized title of the model item.
@property (nonatomic, strong, readonly) NSString *title;

/// The localized description of the model item.
@property (nonatomic, strong, readonly) NSString *summary;

/// The name of the model item's parent, nil if the model item does not have a parent.
@property (nonatomic, strong, readonly) NSString *parent;

/// An array of NSString objects representing the names of the properties defined for the model item.
@property (nonatomic, strong, readonly) NSArray *propertyNames;


- (instancetype)initWithDictionary:(NSDictionary *)properties;

/**
 * Returns the property definition for the property with the given name.
 
 @param name The name of the property definition to retrieve.
 @returns An AlfrescoPropertyDefinition object or nil if the property does not exist.
 */
- (AlfrescoPropertyDefinition *)propertyDefinitionForPropertyWithName:(NSString *)name;

@end
