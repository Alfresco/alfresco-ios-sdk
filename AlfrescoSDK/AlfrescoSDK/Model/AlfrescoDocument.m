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
#import "CMISConstants.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoProperty.h"

static NSInteger kDocumentModelVersion = 1;

@interface AlfrescoDocument ()
@property (nonatomic, strong, readwrite) NSString *contentMimeType;
@property (nonatomic, assign, readwrite) unsigned long long contentLength;
@property (nonatomic, strong, readwrite) NSString *versionLabel;
@property (nonatomic, strong, readwrite) NSString *versionComment;
@property (nonatomic, assign, readwrite) BOOL isLatestVersion;
@property (nonatomic, assign, readwrite) BOOL isFolder;
@property (nonatomic, assign, readwrite) BOOL isDocument;
@property (nonatomic, assign, readwrite) NSUInteger modelClassVersion;
@end

@implementation AlfrescoDocument

@dynamic isFolder;
@dynamic isDocument;

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
    self.isLatestVersion = [[properties valueForKey:kCMISPropertyIsLatestVersion] boolValue];
    self.contentLength = [[properties valueForKey:kCMISPropertyContentStreamLength] unsignedLongLongValue];
    self.contentMimeType = [properties valueForKey:kCMISPropertyContentStreamMediaType];
    self.versionLabel = [properties valueForKey:kCMISPropertyVersionLabel];
    self.versionComment = [(AlfrescoProperty *)[properties[kAlfrescoNodeProperties] valueForKey:kCMISPropertyCheckinComment] value];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeInteger:kDocumentModelVersion forKey:@"AlfrescoDocument"];
    [aCoder encodeBool:self.isFolder forKey:kAlfrescoCMISFolderTypePrefix];
    [aCoder encodeBool:self.isDocument forKey:kAlfrescoCMISDocumentTypePrefix];
    [aCoder encodeBool:self.isLatestVersion forKey:kCMISPropertyIsLatestVersion];
    [aCoder encodeInt64:self.contentLength forKey:kCMISPropertyContentStreamLength];
    [aCoder encodeObject:self.contentMimeType forKey:kCMISPropertyContentStreamMediaType];
    [aCoder encodeObject:self.versionLabel forKey:kCMISPropertyVersionLabel];
    [aCoder encodeObject:self.versionComment forKey:kCMISPropertyCheckinComment];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        //uncomment this line if you need to check the model version
//        NSInteger version = [aDecoder decodeIntForKey:@"AlfrescoDocument"];
        self.isFolder = [aDecoder decodeBoolForKey:kAlfrescoCMISFolderTypePrefix];
        self.isDocument = [aDecoder decodeBoolForKey:kAlfrescoCMISDocumentTypePrefix];
        self.isLatestVersion = [aDecoder decodeBoolForKey:kCMISPropertyIsLatestVersion];
        self.contentLength = [aDecoder decodeInt64ForKey:kCMISPropertyContentStreamLength];
        self.contentMimeType = [aDecoder decodeObjectForKey:kCMISPropertyContentStreamMediaType];
        self.versionLabel = [aDecoder decodeObjectForKey:kCMISPropertyVersionLabel];
        self.versionComment = [aDecoder decodeObjectForKey:kCMISPropertyCheckinComment];
    }
    return self;
}


@end
