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

#import "AlfrescoFolder.h"
#import "AlfrescoInternalConstants.h"

static NSInteger kFolderModelVersion = 1;

@interface AlfrescoFolder ()
@property (nonatomic, assign, readwrite) BOOL isFolder;
@property (nonatomic, assign, readwrite) BOOL isDocument;
@end

@implementation AlfrescoFolder

@dynamic isFolder;
@dynamic isDocument;

- (id)initWithProperties:(NSDictionary *)properties
{
    self = [super initWithProperties:properties];
    if (nil != self)
    {
        self.isFolder = YES;
        self.isDocument = NO;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeInteger:kFolderModelVersion forKey:@"AlfrescoFolder"];
    [aCoder encodeBool:self.isFolder forKey:kAlfrescoCMISFolderTypePrefix];
    [aCoder encodeBool:self.isDocument forKey:kAlfrescoCMISDocumentTypePrefix];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        //uncomment this line if you need to check the model version
//        NSInteger version = [aDecoder decodeIntForKey:@"AlfrescoFolder"];
        self.isFolder = [aDecoder decodeBoolForKey:kAlfrescoCMISFolderTypePrefix];
        self.isDocument = [aDecoder decodeBoolForKey:kAlfrescoCMISDocumentTypePrefix];
    }
    return self;
}


@end
