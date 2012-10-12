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

#import "AlfrescoDocument.h"
#import "CMISEnums.h"
#import "CMISConstants.h"

@interface AlfrescoDocument ()
@property (nonatomic, strong, readwrite) NSString *contentMimeType;
@property (nonatomic, assign, readwrite) unsigned long long contentLength;
@property (nonatomic, strong, readwrite) NSString *versionLabel;
@property (nonatomic, strong, readwrite) NSString *versionComment;
@property (nonatomic, assign, readwrite) BOOL isLatestVersion;
@property (nonatomic, assign, readwrite) BOOL isFolder;
@property (nonatomic, assign, readwrite) BOOL isDocument;
- (void)setUpDocumentProperties:(NSDictionary *)properties;
@end

@implementation AlfrescoDocument

@synthesize contentMimeType = _contentMimeType;
@synthesize contentLength = _contentLength;
@synthesize versionLabel = _versionLabel;
@synthesize versionComment = _versionComment;
@synthesize isLatestVersion = _isLatestVersion;

- (id)initWithProperties:(NSDictionary *)properties
{
    self = [super initWithProperties:properties];
    if (nil != self)
    {
        self.isDocument = YES;
        self.isFolder = NO;
        self.contentMimeType = nil;
        self.versionLabel = nil;
        self.versionComment = nil;
        [self setUpDocumentProperties:properties];
    }
    return self;
}

- (void)setUpDocumentProperties:(NSDictionary *)properties
{
    if ([[properties allKeys] containsObject:kCMISPropertyIsLatestVersion])
    {
        self.isLatestVersion = [[properties valueForKey:kCMISPropertyIsLatestVersion] boolValue];
    }    
    if ([[properties allKeys] containsObject:kCMISPropertyContentStreamLength])
    {
        self.contentLength = [[properties valueForKey:kCMISPropertyContentStreamLength] intValue];
    }
    if ([[properties allKeys] containsObject:kCMISPropertyContentStreamMediaType])
    {
        self.contentMimeType = [properties valueForKey:kCMISPropertyContentStreamMediaType];
    }
    if ([[properties allKeys] containsObject:kCMISPropertyVersionLabel])
    {
        self.versionLabel = [properties valueForKey:kCMISPropertyVersionLabel];
    }    
}

@end
