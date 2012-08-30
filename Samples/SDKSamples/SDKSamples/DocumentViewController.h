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
#import <QuickLook/QuickLook.h>
#import "BaseViewController.h"
#import "AddCommentViewController.h"
#import "AlfrescoCommentService.h"
#import "AlfrescoVersionService.h"
#import "AlfrescoDocumentFolderService.h"
#import "AlfrescoRepositorySession.h"
#import "AlfrescoDocument.h"
#import "AlfrescoRatingService.h"
#import "AlfrescoTaggingService.h"
#import "AlfrescoPersonService.h"

@interface DocumentViewController : BaseViewController <AddCommentViewDelegate, QLPreviewControllerDataSource, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) AlfrescoDocument *document;
@property (nonatomic, strong) AlfrescoCommentService *commentService;
@property (nonatomic, strong) AlfrescoVersionService *versionService;
@property (nonatomic, strong) AlfrescoDocumentFolderService *documentService;
@property (nonatomic, strong) AlfrescoPersonService *personService;
@property (nonatomic, strong) AlfrescoRatingService *ratingService;
@property (nonatomic, strong) AlfrescoTaggingService *taggingService;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *likeButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *commentButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *downloadButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *activityBarButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIImage *thumbnail;
@property BOOL isLiked;

- (IBAction)setLikeDocumentTag:(id)sender;
- (IBAction)downloadDocument:(id)sender;

@end
