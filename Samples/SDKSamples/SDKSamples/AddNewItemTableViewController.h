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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "BaseTableViewController.h"
#import "AddPhotoTableViewController.h"

@protocol AddNewItemTableViewDelegate <NSObject>

- (void)updateFolderContent;

@end

@interface AddNewItemTableViewController : BaseTableViewController <AddPhotoTableViewDelegate, UINavigationControllerDelegate,
        UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) AlfrescoDocument *document;
@property (nonatomic, strong) AlfrescoFolder *folder;
@property (nonatomic, weak) IBOutlet UILabel *folderLabel;
@property (nonatomic, weak) IBOutlet UILabel *photoLabel;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, weak) id<AddNewItemTableViewDelegate>addNewItemDelegate;
@property (nonatomic, strong) AlfrescoDocumentFolderService *documentFolderService;
@property (nonatomic, strong) AlfrescoTaggingService *taggingService;
@end

