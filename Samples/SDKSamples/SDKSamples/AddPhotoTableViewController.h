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

@protocol AddPhotoTableViewDelegate <NSObject>

- (void)updatePhotoInfoWithName:(NSString *)name description:(NSString *)description tags:(NSArray *)tags;

@end

@interface AddPhotoTableViewController : BaseTableViewController <UISearchBarDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSString *documentName;
@property (nonatomic, strong) NSString *documentDescription;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSMutableArray *tagsInSearchResult;
@property (nonatomic, strong) NSMutableArray *tagsSelected;
@property (nonatomic, strong) AlfrescoTaggingService *taggingService;
@property (nonatomic, weak) id<AddPhotoTableViewDelegate>addPhotoDelegate;

- (IBAction)done:(id)sender;

@end
