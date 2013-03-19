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

#import "AlfrescoFolder.h"
#import "AlfrescoInternalConstants.h"

//NSInteger const kClassVersion = 1;

@interface AlfrescoFolder ()
@property (nonatomic, assign, readwrite) BOOL isFolder;
@property (nonatomic, assign, readwrite) BOOL isDocument;
@property (nonatomic, assign, readwrite) NSUInteger modelClassVersion;
@end

@implementation AlfrescoFolder
- (id)initWithProperties:(NSDictionary *)properties
{
    self = [super initWithProperties:properties];
    if (nil != self)
    {
        self.modelClassVersion = kAlfrescoFolderModelVersion;
        self.isFolder = YES;
        self.isDocument = NO;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];

//    [aCoder encodeInt:kClassVersion forKey:kAlfrescoClassVersion];
    [aCoder encodeBool:self.isFolder forKey:kAlfrescoPropertyTypeFolder];
    [aCoder encodeBool:self.isDocument forKey:kAlfrescoPropertyTypeDocument];
    [aCoder encodeInteger:self.modelClassVersion forKey:kAlfrescoModelClassVersion];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        self.isFolder = [aDecoder decodeBoolForKey:kAlfrescoPropertyTypeFolder];
        self.isDocument = [aDecoder decodeBoolForKey:kAlfrescoPropertyTypeDocument];
        self.modelClassVersion = [aDecoder decodeIntForKey:kAlfrescoModelClassVersion];
    }
    return self;
}


@end
