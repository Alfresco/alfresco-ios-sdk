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

@interface AlfrescoPermissions ()
@property (nonatomic, assign, readwrite) BOOL canEdit;
@property (nonatomic, assign, readwrite) BOOL canDelete;
@property (nonatomic, assign, readwrite) BOOL canAddChildren;
@property (nonatomic, assign, readwrite) BOOL canComment;

@end

@implementation AlfrescoPermissions
@synthesize canEdit = _canEdit;
@synthesize canDelete = _canDelete;
@synthesize canAddChildren = _canAddChildren;
@synthesize canComment = _canComment;

- (id)init
{
    self = [super init];
    if (self) 
    {
        self.canEdit = NO;
        self.canDelete = NO;
        self.canAddChildren = NO;
        self.canComment = NO;
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


@end
