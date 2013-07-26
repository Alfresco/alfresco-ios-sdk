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

#import "SitesViewController.h"
#import "FolderViewController.h"

@interface SitesViewController ()

@property (nonatomic, strong) NSMutableArray *sites;
- (void)loadSites;
- (void)loadSite:(AlfrescoSite *)site;
@end

@implementation SitesViewController

#pragma mark - Alfresco Methods

/**
 loadSites: gets the sites using the AlfrescoSiteService. The obtained results are stored in the array "sites" from within the 
 completion block.
 3 site browsing methods are being illustrated
    - retrieving all sites (retrieveAllSitesWithCompletionBlock)
    - retrieving favourite sites (retrieveFavoriteSitesWithCompletionBlock)
    - retrieving my sites (retrieveSitesWithCompletionBlock)
 
 */
- (void)loadSites
{
    // get the children for the folder using an AlfrescoDocumentFolderService
    self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.session];
    if (nil != self.session)
    {
        if(self.browsingType == AlfrescoSiteBrowsingAll)
        {
            self.title = localized(@"select_all_sites_title");
            [self.siteService retrieveAllSitesWithCompletionBlock:^(NSArray *array, NSError *error) {
                if (nil == array) 
                {
                    [self showFailureAlert:@"error_retrieve_sites"];
                }
                else 
                {
                    // update the items array and reload the table data
                    self.sites = [NSArray arrayWithArray:array];
                    [self.tableView reloadData];
                }
            }];
        }
        else if(self.browsingType == AlfrescoSiteBrowsingFavorites)
        {
            self.title = localized(@"select_favourite_sites_title");
            [self.siteService retrieveFavoriteSitesWithCompletionBlock:^(NSArray *array, NSError *error) {
                if (nil == array) 
                {
                    [self showFailureAlert:@"error_retrieve_sites"];
                }
                else 
                {
                    // update the items array and reload the table data
                    self.sites = [NSArray arrayWithArray:array];
                    [self.tableView reloadData];
                }
            }];
        }
        else 
        {
            self.title = localized(@"select_my_sites_title");
            [self.siteService retrieveSitesWithCompletionBlock:^(NSArray *array, NSError *error) {
                if (nil == array) 
                {
                    [self showFailureAlert:@"error_retrieve_sites"];
                }
                else 
                {
                    // update the items array and reload the table data
                    self.sites = [NSArray arrayWithArray:array];
                    [self.tableView reloadData];
                }
            }];
        }
    }
}

/**
 loadSite loads a specific Alfresco Site. If the completion block returns successful (folder != nil) it starts
 the segue to a View controller displaying the selected site.
 */
- (void)loadSite:(AlfrescoSite *)site
{
    // get the document library for the site
    self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.session];
    [self.siteService retrieveDocumentLibraryFolderForSite:site.shortName
                                           completionBlock:^(AlfrescoFolder *folder, NSError *error){
         if (nil == folder) 
         {
             [self showFailureAlert:@"error_retrieve_doc_library"];
         }
         else 
         {
             [self performSegueWithIdentifier:@"browseSite" sender:folder];
         }
     }];
}

#pragma mark View Controller methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sites = [NSMutableArray array];
    [self loadSites];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sites count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"nodeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    AlfrescoSite *site = [self.sites objectAtIndex:indexPath.row];
    cell.textLabel.text = site.title;
    if(site.summary != nil && [site.summary length] > 0)
    {
        cell.detailTextLabel.text = site.summary;
    }
    else 
    {
        cell.detailTextLabel.text = localized(@"document_general_nodata");
    }
    UIImage *img = [UIImage imageNamed:@"site.png"];
    cell.imageView.image = img;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlfrescoSite *site = [self.sites objectAtIndex:indexPath.row];
    [self loadSite:site];
}

#pragma mark - Segue preparation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[segue destinationViewController] setSession:self.session];
    [[segue destinationViewController] setFolder:(AlfrescoFolder *)sender];
}


@end
