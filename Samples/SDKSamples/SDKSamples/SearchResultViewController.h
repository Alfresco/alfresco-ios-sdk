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
#import "BaseTableViewController.h"
#import "AlfrescoRepositorySession.h"
#import "AlfrescoSearchService.h"
#import "AlfrescoKeywordSearchOptions.h"

@interface SearchResultViewController : BaseTableViewController

@property (nonatomic, strong) AlfrescoSearchService *searchService;
@property (nonatomic, strong) NSString *searchText;
@property (nonatomic) BOOL fullText;
@property (nonatomic) BOOL exact;
@property (nonatomic, strong) NSArray *resultArray;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *activityBarButton;

@end
