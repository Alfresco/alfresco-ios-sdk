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

#import "AddPhotoTableViewController.h"
#import "AlfrescoTag.h"

@interface AddPhotoTableViewController ()

@property (nonatomic) BOOL firstLoad;
@property (nonatomic, strong) NSString *currentSearchText;

- (void)loadTags;

@end

@implementation AddPhotoTableViewController

@synthesize documentName = _documentName;
@synthesize documentDescription = _documentDescription;
@synthesize tags = _tags;
@synthesize tagsInSearchResult = _tagsInSearchResult;
@synthesize tagsSelected = _tagsSelected;
@synthesize taggingService = _taggingService;
@synthesize addPhotoDelegate = _addPhotoDelegate;
@synthesize firstLoad = _firstLoad;
@synthesize currentSearchText = _currentSearchText;

#pragma mark - Alfresco service calls

/**
 loads the tags for the document - using the AlfrescoTaggingService.
 */
- (void)loadTags
{
    self.taggingService = [[AlfrescoTaggingService alloc] initWithSession:self.session];
//    __weak AddPhotoTableViewController *weakSelf = self;
    [self.taggingService retrieveAllTagsWithCompletionBlock:^(NSArray *array, NSError *error) {
        if (nil == array) 
        {
            [self showFailureAlert:@"error_retrieve_tags"];
        }
        else 
        {
            self.tags = array;
            self.tagsInSearchResult = [NSMutableArray arrayWithArray:self.tags];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
}

#pragma mark - ViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.firstLoad = YES;
    self.tags = [NSArray array];
    self.tagsSelected = [NSMutableArray array];
    [self loadTags];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    else 
    {
        return self.tagsInSearchResult.count + 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return localized(@"document_details_header");
    }
    else 
    {
        return localized(@"document_tags_header");
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"nameCell"];
        UITextField *nameField = (UITextField *)[cell viewWithTag:12];
        nameField.text = self.documentName;
        [nameField setDelegate:self];
        if (self.firstLoad == YES)
        {
            self.firstLoad = NO;
            [nameField becomeFirstResponder];
        }
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"descriptionCell"];
        UITextField *descriptionField = (UITextField *)[cell viewWithTag:11];
        [descriptionField setDelegate:self];
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"searchBarCell"];
        UISearchBar *searchBar = (UISearchBar *)[cell viewWithTag:1];
        searchBar.text = self.currentSearchText;
        [searchBar setDelegate:self];
        if (self.currentSearchText)
        {
            [searchBar becomeFirstResponder];
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"tagCell"];
        AlfrescoTag *selectedTag = [self.tagsInSearchResult objectAtIndex:indexPath.row - 1];
        cell.textLabel.text = selectedTag.value;
        if ([self.tagsSelected containsObject:selectedTag])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else 
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row > 0)
    {
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        AlfrescoTag *selectedTag = [self.tagsInSearchResult objectAtIndex:indexPath.row - 1];
        if ([self.tagsSelected containsObject:selectedTag])
        {
            [self.tagsSelected removeObject:selectedTag];
            selectedCell.accessoryType = UITableViewCellAccessoryNone;
        }
        else 
        {
            [self.tagsSelected addObject:selectedTag];
            selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
}

#pragma mark - Text field delegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField.tag == 12)
    {
        self.documentName = newString;
    }
    else 
    {
        self.documentDescription = newString;
    }
    
    return YES;
}

#pragma mark - Search bar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.tagsInSearchResult removeAllObjects];
    self.currentSearchText = searchText;
    
    if([searchText length] == 0)
    {
        [self.tagsInSearchResult addObjectsFromArray:self.tags];
    }
    else
    {
        for (AlfrescoTag *tag in self.tags)
        {
            NSString *tagValue = tag.value;
            NSRange range = [tagValue rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if(range.location != NSNotFound)
            {
                [self.tagsInSearchResult addObject:tag];
            }
        }
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    if ([self.addPhotoDelegate respondsToSelector:@selector(updatePhotoInfoWithName:description:tags:)])
    {
        [self.addPhotoDelegate updatePhotoInfoWithName:self.documentName description:self.documentDescription tags:self.tagsSelected];
        [self.navigationController popViewControllerAnimated:NO];
    }
}


@end
