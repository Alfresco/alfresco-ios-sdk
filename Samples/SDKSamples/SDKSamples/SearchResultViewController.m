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

#import "SearchResultViewController.h"
#import "DocumentViewController.h"

@interface SearchResultViewController ()

- (void)loadSearch;

@end

@implementation SearchResultViewController

@synthesize searchService = _searchService;
@synthesize searchText = _searchText;
@synthesize fullText = _fullText;
@synthesize exact = _exact;
@synthesize resultArray = _resultArray;
@synthesize activityIndicator = _activityIndicator;
@synthesize activityBarButton = _activityBarButton;

#pragma mark - Alfresco methods

/**
 loadSearch - creates a search using the AlfrescoSearchService.
 The result is shown in the table view of the controller. 
 Upon tapping on one of the cells/documents found, the Document View Controller will be loaded.
 */
- (void)loadSearch
{
    [self.activityIndicator startAnimating];
    
    // get the document library for the site
    self.searchService = [[AlfrescoSearchService alloc] initWithSession:self.session];
    AlfrescoKeywordSearchOptions *searchOptions = [[AlfrescoKeywordSearchOptions alloc] initWithExactMatch:self.exact includeContent:self.fullText folder:nil includeDescendants:NO];
//    __weak SearchResultViewController *weakSelf = self;
    [self.searchService searchWithKeywords:self.searchText 
                                   options:searchOptions 
                           completionBlock:^(NSArray *array, NSError *error) {
        [self.activityIndicator stopAnimating];
        if (nil == array) 
        {
            [self showFailureAlert:@"error_search"];
        }
        else 
        {
            self.resultArray = [NSArray arrayWithArray:array];
            [self.tableView reloadData];
        }
        
    }];
}

#pragma mark View Controller methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.activityBarButton setCustomView:self.activityIndicator];
    
    self.title = self.searchText;
    self.resultArray = [NSArray array];
    [self loadSearch];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.resultArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"resultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (0 < self.resultArray.count) 
    {
        AlfrescoDocument *document = [self.resultArray objectAtIndex:indexPath.row];
        cell.textLabel.text = document.name;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlfrescoDocument *document = [self.resultArray objectAtIndex:indexPath.row];    
    [self performSegueWithIdentifier:@"showDocument" sender:document];
}

#pragma mark - Table View

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[segue destinationViewController] setSession:self.session];
    [[segue destinationViewController] setDocument:(AlfrescoDocument *)sender];
}



@end
