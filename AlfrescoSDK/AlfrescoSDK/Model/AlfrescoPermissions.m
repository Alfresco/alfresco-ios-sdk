/*******************************************************************************
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
 ******************************************************************************/

#import "AlfrescoPermissions.h"
#import "CMISEnums.h"

static NSInteger kPermissionsModelVersion = 1;

@interface AlfrescoPermissions ()
@property (nonatomic, assign, readwrite) BOOL canEdit;
@property (nonatomic, assign, readwrite) BOOL canDelete;
@property (nonatomic, assign, readwrite) BOOL canAddChildren;
@property (nonatomic, assign, readwrite) BOOL canComment;
@property (nonatomic, assign, readwrite) BOOL canGetContent;
@property (nonatomic, assign, readwrite) BOOL canSetContent;
@property (nonatomic, assign, readwrite) BOOL canGetProperties;
@property (nonatomic, assign, readwrite) BOOL canGetAllVersions;
@property (nonatomic, assign, readwrite) BOOL canGetChildren;
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
        self.canGetContent = NO;
        self.canSetContent = NO;
        self.canGetProperties = NO;
        self.canGetAllVersions = NO;
        self.canGetChildren = NO;
    }
    return self;
}


- (id)initWithPermissions:(NSSet *)permissionsSet
{
    self = [self init];
    if (self)
    {
        self.canEdit = [permissionsSet containsObject:@(CMISActionCanUpdateProperties)];
        self.canDelete = [permissionsSet containsObject:@(CMISActionCanDeleteObject)];
        self.canAddChildren = ([permissionsSet containsObject:@(CMISActionCanAddObjectToFolder)] ||
                               [permissionsSet containsObject:@(CMISActionCanCreateDocument)] ||
                               [permissionsSet containsObject:@(CMISActionCanCreateFolder)]);
        self.canComment = self.canEdit;
        self.canGetContent = [permissionsSet containsObject:@(CMISActionCanGetContentStream)];
        self.canSetContent = ([permissionsSet containsObject:@(CMISActionCanSetContentStream)] ||
                              [permissionsSet containsObject:@(CMISActionCanDeleteContentStream)]);
        self.canGetProperties = ([permissionsSet containsObject:@(CMISActionCanGetFolderParent)] ||
                                 [permissionsSet containsObject:@(CMISActionCanGetObjectParents)] ||
                                 [permissionsSet containsObject:@(CMISActionCanGetProperties)]);
        self.canGetAllVersions = [permissionsSet containsObject:@(CMISActionCanGetAllVersions)];
        self.canGetChildren = ([permissionsSet containsObject:@(CMISActionCanGetDescendants)] ||
                               [permissionsSet containsObject:@(CMISActionCanGetFolderTree)] ||
                               [permissionsSet containsObject:@(CMISActionCanGetChildren)]);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:kPermissionsModelVersion forKey:@"AlfrescoPermissions"];
    [aCoder encodeBool:self.canAddChildren forKey:@"canAddChildren"];
    [aCoder encodeBool:self.canComment forKey:@"canComment"];
    [aCoder encodeBool:self.canDelete forKey:@"canDelete"];
    [aCoder encodeBool:self.canEdit forKey:@"canEdit"];
    [aCoder encodeBool:self.canGetContent forKey:@"canGetContent"];
    [aCoder encodeBool:self.canSetContent forKey:@"canSetContent"];
    [aCoder encodeBool:self.canGetProperties forKey:@"canGetProperties"];
    [aCoder encodeBool:self.canGetAllVersions forKey:@"canGetAllVersions"];
    [aCoder encodeBool:self.canGetChildren forKey:@"canGetChildren"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (nil != self)
    {
        //uncomment this line if you need to check the model version
        //NSInteger version = [aDecoder decodeIntForKey:@"AlfrescoPermissions"];
        self.canEdit = [aDecoder decodeBoolForKey:@"canEdit"];
        self.canDelete = [aDecoder decodeBoolForKey:@"canDelete"];
        self.canComment = [aDecoder decodeBoolForKey:@"canComment"];
        self.canAddChildren = [aDecoder decodeBoolForKey:@"canAddChildren"];
        self.canGetContent = [aDecoder decodeBoolForKey:@"canGetContent"];
        self.canSetContent = [aDecoder decodeBoolForKey:@"canSetContent"];
        self.canGetProperties = [aDecoder decodeBoolForKey:@"canGetProperties"];
        self.canGetAllVersions = [aDecoder decodeBoolForKey:@"canGetAllVersions"];
        self.canGetChildren = [aDecoder decodeBoolForKey:@"canGetChildren"];
    }
    return self;
}



@end
