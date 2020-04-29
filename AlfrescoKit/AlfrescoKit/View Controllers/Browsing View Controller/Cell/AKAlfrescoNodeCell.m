/*
 ******************************************************************************
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
 *****************************************************************************
 */

#import "AKAlfrescoNodeCell.h"
#import "AKUtility.h"

@implementation AKAlfrescoNodeCell

- (void)updateCellWithAlfrescoNode:(AlfrescoNode *)node
{
    self.nodeTextLabel.text = node.name;
    
    if ([node isKindOfClass:[AlfrescoFolder class]])
    {
        self.nodeImageView.image = [UIImage imageFromAlfrescoKitBundleNamed:@"small_folder"];
        self.nodeDetailLabel.text = @"";
    }
    else
    {
        self.nodeImageView.image = [AKUtility smallIconForType:node.name.pathExtension];
        AlfrescoDocument *document = (AlfrescoDocument *)node;
        NSString *fileDateString = [AKUtility stringDateFromDate:document.modifiedAt];
        NSString *fileSizeString = [AKUtility stringForFileSize:document.contentLength];
        self.nodeDetailLabel.text = [NSString stringWithFormat:@"%@ • %@", fileSizeString, fileDateString];
    }
}

- (void)updateCellWithURL:(NSURL *)url
{
    NSString *name = url.path.lastPathComponent;
    NSString *extension = url.path.pathExtension;
    NSDictionary *fileAttributes = [[AlfrescoFileManager sharedManager] attributesOfItemAtPath:url.path error:nil];
    unsigned long fileSize = [fileAttributes[kAlfrescoFileSize] longValue];
    NSDate *modificationDate = [fileAttributes objectForKey:kAlfrescoFileLastModification];
    
    self.nodeTextLabel.text = name;
    
    if ([fileAttributes[kAlfrescoIsFolder] boolValue])
    {
        self.nodeImageView.image = [UIImage imageFromAlfrescoKitBundleNamed:@"small_folder"];
        self.nodeDetailLabel.text = @"";
    }
    else
    {
        self.nodeImageView.image = [AKUtility smallIconForType:extension];
        NSString *fileDateString = [AKUtility stringDateFromDate:modificationDate];
        NSString *fileSizeString = [AKUtility stringForFileSize:fileSize];
        self.nodeDetailLabel.text = [NSString stringWithFormat:@"%@ • %@", fileSizeString, fileDateString];
    }
}

- (void)updateCellWithPickedIndicator:(BOOL)picked
{
    if (picked)
    {
        self.nodeSelectedImageView.image = [UIImage imageFromAlfrescoKitBundleNamed:@"green_selected_circle"];
    }
    else
    {
        self.nodeSelectedImageView.image = nil;
    }
}

@end
