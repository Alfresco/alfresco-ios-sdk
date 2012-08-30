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

#import "AlfrescoNode.h"
#import "AlfrescoProperty.h"
#import "CMISObject.h"

NSString * const kAlfrescoPermissionsObjectKey = @"AlfrescoPermissionsObjectKey";

@implementation AlfrescoNode

@synthesize identifier = _identifier;
@synthesize name = _name;
@synthesize title = _title;
@synthesize summary = _summary;
@synthesize type = _type;
@synthesize createdBy = _createdBy;
@synthesize createdAt = _createdAt;
@synthesize modifiedBy = _modifiedBy;
@synthesize modifiedAt = _modifiedAt;
@synthesize properties = _properties;
@synthesize aspects = _aspects;
@synthesize isFolder = _isFolder;
@synthesize isDocument = _isDocument;

- (id)initWithCMISObject:(CMISObject *)objectData
{
    if (self = [super init]) 
    {
        self.identifier = objectData.identifier;
        self.name = objectData.name;
        self.createdBy = objectData.createdBy;
        self.createdAt = objectData.creationDate;
    }
    
    return self;
}

- (id)propertyValueWithName:(NSString *)propertyName
{
    AlfrescoProperty *property = [self.properties objectForKey:propertyName];
    id value;
    if(property != nil)
    {
        value = property.value;
    }
    return value;
}

- (BOOL)hasAspectWithName:(NSString *)aspectName
{ 
    return [self.aspects containsObject:aspectName];
}

@end

