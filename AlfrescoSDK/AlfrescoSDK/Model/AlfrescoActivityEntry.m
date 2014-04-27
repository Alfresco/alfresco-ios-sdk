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

#import "AlfrescoActivityEntry.h"
#import "AlfrescoInternalConstants.h"
#import "CMISDateUtil.h"

static NSUInteger kActivityModelVersion = 1;

@interface AlfrescoActivityEntry ()
@property (nonatomic, strong, readwrite) NSString *identifier;
@property (nonatomic, strong, readwrite) NSDate *createdAt;
@property (nonatomic, strong, readwrite) NSString *createdBy;
@property (nonatomic, strong, readwrite) NSString *siteShortName;
@property (nonatomic, strong, readwrite) NSString *type;
@property (nonatomic, strong, readwrite) NSDictionary *data;

/// Convenience helper properties
@property (nonatomic, assign, readwrite, getter = isDocument) BOOL document;
@property (nonatomic, assign, readwrite, getter = isFolder) BOOL folder;
@property (nonatomic, strong, readwrite) NSString *nodeIdentifier;

@property (nonatomic, assign) BOOL activityTypeDocumentCalculated;
@property (nonatomic, assign) BOOL activityTypeFolderCalculated;
@end

@implementation AlfrescoActivityEntry

/**
 * Cloud and OnPremise sessions have slightly different JSON response types
 *
 * Cloud:           OnPremise:
 *  postedAt         postDate
 *  postPersonID     postUserId
 *  siteId           siteNetwork
 */

- (id)initWithProperties:(NSDictionary *)properties
{
    self = [super init];
    if (self && properties)
    {
        self.identifier = properties[kAlfrescoJSONIdentifier];
        self.type = properties[kAlfrescoJSONActivityType];
        id summary = properties[kAlfrescoJSONActivitySummary];
        if ([summary isKindOfClass:[NSDictionary class]])
        {
            self.data = (NSDictionary *)summary;
        }
        else
        {
            self.data = [NSJSONSerialization JSONObjectWithData:[properties[kAlfrescoJSONActivitySummary] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
        }

        [self setOnPremiseProperties:properties];
        [self setCloudProperties:properties];

        self.nodeIdentifier = self.data[kAlfrescoJSONActivityDataNodeRef] ? self.data[kAlfrescoJSONActivityDataNodeRef] : self.data[kAlfrescoJSONActivityDataObjectId];

        self.activityTypeDocumentCalculated = NO;
        self.activityTypeFolderCalculated = NO;
    }
    return self;
}

- (void)setOnPremiseProperties:(NSDictionary *)properties
{
    self.createdBy = properties[kAlfrescoJSONActivityPostUserID];

    NSString *rawDateString = properties[kAlfrescoJSONActivityPostDate];
    if (rawDateString)
    {
        self.createdAt = [CMISDateUtil dateFromString:rawDateString];
    }

    self.siteShortName = properties[kAlfrescoJSONActivitySiteNetwork];
}

- (void)setCloudProperties:(NSDictionary *)properties
{
    self.createdBy = properties[kAlfrescoJSONActivityPostPersonID];
    
    NSString *rawDateString = properties[kAlfrescoJSONPostedAt];
    if (rawDateString)
    {
        self.createdAt = [CMISDateUtil dateFromString:rawDateString];
    }

    self.siteShortName = properties[kAlfrescoJSONSiteID];
}

#pragma mark - Activity decode helpers

- (BOOL)isDocument
{
    if (!self.activityTypeDocumentCalculated)
    {
        NSArray *determinateTypes = @[@"org.alfresco.documentlibrary.file-added",
                                      @"org.alfresco.documentlibrary.file-created",
                                      @"org.alfresco.documentlibrary.file-deleted",
                                      @"org.alfresco.documentlibrary.file-updated",
                                      @"org.alfresco.documentlibrary.file-liked",
                                      @"org.alfresco.documentlibrary.google-docs-checkout",
                                      @"org.alfresco.documentlibrary.google-docs-checkin",
                                      @"org.alfresco.documentlibrary.inline-edit",
                                      @"org.alfresco.documentlibrary.file-liked"];
        NSArray *indeterminateTypes = @[@"org.alfresco.comments.comment-created",
                                        @"org.alfresco.comments.comment-updated",
                                        @"org.alfresco.comments.comment-deleted"];
        
        if ([determinateTypes containsObject:self.type])
        {
            _document = YES;
        }
        else if ([indeterminateTypes containsObject:self.type])
        {
            // Check the Share page - it's the only way to determine what the target node type was without a round-trip request
            // Note this parameter *does not exist* when accessing the activity stream via the Public API
            _document = [self.data[kAlfrescoJSONActivityDataPage] hasPrefix:@"document-details"];
        }
        
        self.activityTypeDocumentCalculated = YES;
    }
    return _document;
}

- (BOOL)isFolder
{
    if (!self.activityTypeFolderCalculated)
    {
        // TODO: Consider handling the following types here too.
        /*
         org.alfresco.documentlibrary.files-added={1} added {0} documents
         org.alfresco.documentlibrary.files-deleted={1} deleted {0} documents
         org.alfresco.documentlibrary.files-updated={1} updated {0} documents
         */
        
        NSArray *determinateTypes = @[@"org.alfresco.documentlibrary.folder-added",
                                      @"org.alfresco.documentlibrary.folder-deleted",
                                      @"org.alfresco.documentlibrary.folder-liked"];
        NSArray *indeterminateTypes = @[@"org.alfresco.comments.comment-created",
                                        @"org.alfresco.comments.comment-updated",
                                        @"org.alfresco.comments.comment-deleted"];
        
        if ([determinateTypes containsObject:self.type])
        {
            _folder = YES;
        }
        else if ([indeterminateTypes containsObject:self.type])
        {
            // Check the Share page - it's the only way to determine what the target node type was without a round-trip request
            // Note this parameter *does not exist* when accessing the activity stream via the Public API
            _folder = [self.data[kAlfrescoJSONActivityDataPage] hasPrefix:@"folder-details"];
        }
        
        self.activityTypeFolderCalculated = YES;
        
    }
    return _folder;
}

- (BOOL)isDeleted
{
    return [self.type hasSuffix:@"-deleted"];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:kActivityModelVersion forKey:@"AlfrescoActivityEntry"];
    [aCoder encodeObject:self.createdAt forKey:kAlfrescoJSONActivityPostDate];
    [aCoder encodeObject:self.identifier forKey:kAlfrescoJSONIdentifier];
    [aCoder encodeObject:self.type forKey:kAlfrescoJSONActivityType];
    [aCoder encodeObject:self.data forKey:kAlfrescoJSONActivitySummary];
    [aCoder encodeObject:self.createdBy forKey:kAlfrescoJSONActivityPostPersonID];
    [aCoder encodeObject:self.siteShortName forKey:kAlfrescoJSONSiteID];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (nil != self)
    {
        //uncomment this line if you need to check the model version
//        NSInteger version = [aDecoder decodeIntForKey:@"AlfrescoActivityEntry"];
        self.createdBy = [aDecoder decodeObjectForKey:kAlfrescoJSONActivityPostPersonID];
        self.createdAt = [aDecoder decodeObjectForKey:kAlfrescoJSONActivityPostDate];
        self.identifier = [aDecoder decodeObjectForKey:kAlfrescoJSONIdentifier];
        self.type = [aDecoder decodeObjectForKey:kAlfrescoJSONActivityType];
        self.data = [aDecoder decodeObjectForKey:kAlfrescoJSONActivitySummary];
        self.siteShortName = [aDecoder decodeObjectForKey:kAlfrescoJSONSiteID];
    }
    return self;
}

@end
