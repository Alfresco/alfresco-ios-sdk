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

#import "AlfrescoPermissions.h"
#import "CMISEnums.h"
#import "AlfrescoInternalConstants.h"
@interface AlfrescoPermissions ()
@property (nonatomic, assign, readwrite) BOOL canEdit;
@property (nonatomic, assign, readwrite) BOOL canDelete;
@property (nonatomic, assign, readwrite) BOOL canAddChildren;
@property (nonatomic, assign, readwrite) BOOL canComment;
@property (nonatomic, assign, readwrite) NSUInteger modelClassVersion;

@end

@implementation AlfrescoPermissions

- (id)init
{
    self = [super init];
    if (self) 
    {
        self.canEdit = NO;
        self.canDelete = NO;
        self.canAddChildren = NO;
        self.canComment = NO;
        self.modelClassVersion = kAlfrescoPermissionsModelVersion;
    }
    return self;
}


- (id)initWithPermissions:(NSSet *)permissionsSet
{
    self = [self init];
    if (self) 
    {
        self.canEdit = [permissionsSet containsObject:[NSNumber numberWithInt:CMISActionCanUpdateProperties]];
        self.canDelete = [permissionsSet containsObject:[NSNumber numberWithInt:CMISActionCanDeleteObject]];
        self.canAddChildren = [permissionsSet containsObject:[NSNumber numberWithInt:CMISActionCanAddObjectToFolder]] || 
                                [permissionsSet containsObject:[NSNumber numberWithInt:CMISActionCanCreateDocument]] || 
                                [permissionsSet containsObject:[NSNumber numberWithInt:CMISActionCanCreateFolder]];
        self.canComment = self.canEdit;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:self.canAddChildren forKey:@"canAddChildren"];
    [aCoder encodeBool:self.canComment forKey:@"canComment"];
    [aCoder encodeBool:self.canDelete forKey:@"canDelete"];
    [aCoder encodeBool:self.canEdit forKey:@"canEdit"];
    [aCoder encodeInteger:self.modelClassVersion forKey:kAlfrescoModelClassVersion];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (nil != self)
    {
        self.canEdit = [aDecoder decodeBoolForKey:@"canEdit"];
        self.canDelete = [aDecoder decodeBoolForKey:@"canDelete"];
        self.canComment = [aDecoder decodeBoolForKey:@"canComment"];
        self.canAddChildren = [aDecoder decodeBoolForKey:@"canAddChildren"];
        self.modelClassVersion = [aDecoder decodeIntForKey:kAlfrescoModelClassVersion];
    }
    return self;
}



@end
