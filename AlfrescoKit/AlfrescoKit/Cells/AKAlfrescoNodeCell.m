//
//  AKAlfrescoNodeCell.m
//  AlfrescoKit
//
//  Created by Tauseef Mughal on 08/01/2015.
//  Copyright (c) 2015 Alfresco. All rights reserved.
//

#import "AKAlfrescoNodeCell.h"
#import "AKUtility.h"

@implementation AKAlfrescoNodeCell

- (void)updateCellWithAlfrescoNode:(AlfrescoNode *)node
{
    self.nodeTextLabel.text = node.name;
    
    if ([node isKindOfClass:[AlfrescoFolder class]])
    {
        self.nodeImageView.image = [UIImage imageNamed:@"small_folder.tiff"];
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

- (void)updateCellWithPickedIndicator:(BOOL)picked
{
    if (picked)
    {
        self.nodeSelectedImageView.image = [UIImage imageNamed:@"green_selected_circle.tiff"];
    }
    else
    {
        self.nodeSelectedImageView.image = nil;
    }
}

@end
