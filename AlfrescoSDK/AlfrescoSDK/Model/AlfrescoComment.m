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

#import "AlfrescoComment.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoISO8601DateFormatter.h"

@interface AlfrescoComment ()
@property (nonatomic, strong, readwrite) NSString *identifier;
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) NSDate *createdAt;
@property (nonatomic, strong, readwrite) NSDate *modifiedAt;
@property (nonatomic, strong, readwrite) NSString *content;
@property (nonatomic, strong, readwrite) NSString *createdBy;
@property (nonatomic, readwrite) BOOL isEdited;
@property (nonatomic, readwrite) BOOL canEdit;
@property (nonatomic, readwrite) BOOL canDelete;
@property (nonatomic, strong) AlfrescoISO8601DateFormatter * dateFormatter;
@property (nonatomic, strong) NSDateFormatter * standardDateFormatter;
- (void)setOnPremiseProperties:(NSDictionary *)properties;
- (void)setCloudProperties:(NSDictionary *)properties;
@end


@implementation AlfrescoComment
@synthesize dateFormatter = _dateFormatter;
@synthesize identifier = _identifier;
@synthesize name = _name;
@synthesize title = _title;
@synthesize createdAt = _createdAt;
@synthesize modifiedAt = _modifiedAt;
@synthesize content = _content;
@synthesize createdBy = _createdBy;
@synthesize isEdited = _isEdited;
@synthesize canEdit = _canEdit;
@synthesize canDelete = _canDelete;


- (id)initWithProperties:(NSDictionary *)properties
{
    self = [super init];
    if (nil != self)
    {
        self.standardDateFormatter = [[NSDateFormatter alloc] init];
        [self.standardDateFormatter setDateFormat:@"MMM' 'dd' 'yyyy' 'HH:mm:ss' 'zzz"];
        self.dateFormatter = [[AlfrescoISO8601DateFormatter alloc] init];
        if ([[properties allKeys] containsObject:kAlfrescoJSONTitle])
        {
            self.title = [properties valueForKey:kAlfrescoJSONTitle];
        }
        if ([[properties allKeys] containsObject:kAlfrescoJSONContent])
        {
            self.content = [properties valueForKey:kAlfrescoJSONContent];
        }
        [self setCloudProperties:properties];
        [self setOnPremiseProperties:properties];
    }
    return self;
}

- (void)setOnPremiseProperties:(NSDictionary *)properties
{
    if ([[properties allKeys] containsObject:kAlfrescoJSONNodeRef])
    {
        self.identifier = [properties valueForKey:kAlfrescoJSONNodeRef];
    }
    if ([[properties allKeys] containsObject:kAlfrescoJSONName])
    {
        self.name = [properties valueForKey:kAlfrescoJSONName];
    }
    if ([[properties allKeys] containsObject:kAlfrescoJSONAuthor])
    {
        NSDictionary *authorDict = [properties valueForKey:kAlfrescoJSONAuthor];
        if ([[authorDict allKeys] containsObject:kAlfrescoJSONUsername]) {
            self.createdBy = [authorDict valueForKey:kAlfrescoJSONUsername];
        }
    }
    if ([[properties allKeys] containsObject:kAlfrescoJSONPermissions])
    {
        NSDictionary *permissionDict = [properties valueForKey:kAlfrescoJSONPermissions];
        if ([[permissionDict allKeys] containsObject:kAlfrescoJSONEdit])
        {
            self.canEdit = [[permissionDict valueForKeyPath:kAlfrescoJSONEdit] boolValue];
        }
        if ([[permissionDict allKeys] containsObject:kAlfrescoJSONDelete])
        {
            self.canDelete = [[permissionDict valueForKeyPath:kAlfrescoJSONDelete] boolValue];
        }
    }
    if ([[properties allKeys] containsObject:kAlfrescoJSONIsUpdated])
    {
        self.isEdited = [[properties valueForKey:kAlfrescoJSONIsUpdated] boolValue];
    }
    
    if ([[properties allKeys] containsObject:kAlfrescoJSONCreatedOnISO] || [[properties allKeys] containsObject:kAlfrescoJSONCreatedOn])
    {
        if ([[properties allKeys] containsObject:kAlfrescoJSONCreatedOnISO])
        {
            NSString *created = [properties valueForKey:kAlfrescoJSONCreatedOnISO];
            if (nil != created)
            {
                self.createdAt = [self.dateFormatter dateFromString:created];
            }
        }
        else
        {
            NSString *created = [properties valueForKey:kAlfrescoJSONCreatedOn];
            if (nil != created)
            {
                NSArray *dateComponents = [created componentsSeparatedByString:@"("];
                NSString *dateWithZZZTimeZone = [dateComponents objectAtIndex:0];
                self.createdAt = [self.standardDateFormatter dateFromString:dateWithZZZTimeZone];
            }
        }
    }
    
    if ([[properties allKeys] containsObject:kAlfrescoJSONModifiedOnISO] || [[properties allKeys] containsObject:kAlfrescoJSONModifiedOn])
    {
        if ([[properties allKeys] containsObject:kAlfrescoJSONModifiedOnISO])
        {
            NSString *modified = [properties valueForKey:kAlfrescoJSONModifiedOnISO];
            if (nil != modified)
            {
                self.modifiedAt = [self.dateFormatter dateFromString:modified];
            }
        }
        else
        {
            NSString *modified = [properties valueForKey:kAlfrescoJSONModifiedOn];
            if (nil != modified)
            {
                NSArray *dateComponents = [modified componentsSeparatedByString:@"("];
                NSString *dateWithZZZTimeZone = [dateComponents objectAtIndex:0];
                self.modifiedAt = [self.standardDateFormatter dateFromString:dateWithZZZTimeZone];
            }
        }
    }
    
}

- (void)setCloudProperties:(NSDictionary *)properties
{
    if ([[properties allKeys] containsObject:kAlfrescoJSONIdentifier])
    {
        self.identifier = [properties valueForKey:kAlfrescoJSONIdentifier];
    }
    if ([[properties allKeys] containsObject:kAlfrescoJSONCreatedAt])
    {
        NSString *createdDateString = [properties valueForKey:kAlfrescoJSONCreatedAt];
        if (nil != createdDateString)
        {
            self.createdAt = [self.dateFormatter dateFromString:createdDateString];
        }
        
    }
    if ([[properties allKeys] containsObject:kAlfrescoJSONCreatedBy])
    {
        NSDictionary *createdByDict = [properties valueForKey:kAlfrescoJSONCreatedBy];
        self.createdBy = [createdByDict valueForKey:kAlfrescoJSONIdentifier];
    }
    if ([[properties allKeys] containsObject:kAlfrescoJSONModifedAt])
    {
        NSString *modifiedDateString = [properties valueForKey:kAlfrescoJSONModifedAt];
        if (nil != modifiedDateString)
        {
            self.modifiedAt = [self.dateFormatter dateFromString:modifiedDateString];
        }
    }
    if ([[properties allKeys] containsObject:kAlfrescoJSONCanEdit])
    {
        self.canEdit = [[properties valueForKey:kAlfrescoJSONCanEdit] boolValue];
    }
    if ([[properties allKeys] containsObject:kAlfrescoJSONEdited])
    {
        self.isEdited = [[properties valueForKey:kAlfrescoJSONEdited] boolValue];
    }
    if ([[properties allKeys] containsObject:kAlfrescoJSONCanDelete])
    {
        self.canDelete = [[properties valueForKey:kAlfrescoJSONCanDelete] boolValue];
    }
    
}


@end
