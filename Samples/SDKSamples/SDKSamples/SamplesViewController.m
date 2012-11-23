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

#import "SamplesViewController.h"
#import "FolderViewController.h"
#import "SitesViewController.h"
#import "AlfrescoRepositorySession.h"
#import "AlfrescoCloudSession.h"
#import "ActivitiesTableViewController.h"
#import "AlfrescoListingContext.h"


@interface SamplesViewController ()
@property (nonatomic, assign) BOOL connectionDetailsProvided;
@end

@implementation SamplesViewController
@synthesize connectionDetailsProvided = _connectionDetailsProvided;
@synthesize session = _session;


#pragma mark View Controller methods

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = localized(@"sample_title");

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
    {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } 
    else 
    {
        return YES;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.session isKindOfClass:[AlfrescoCloudSession class]])
    {
        return 7;
    }
    else
    {
        return 6;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"samplesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    switch (indexPath.row)
    {
        case 0:
            cell.textLabel.text = localized(@"sample_browse_favourite_sites_option");
            break;
        case 1:
            cell.textLabel.text = localized(@"sample_browse_my_sites_option");
            break;
        case 2:
            cell.textLabel.text = localized(@"sample_browse_all_sites_option");
            break;
        case 3:
            cell.textLabel.text = localized(@"sample_browse_company_home_option");
            break;
        case 4:
            cell.textLabel.text = localized(@"sample_activities_option");
            break;
        case 5:
            cell.textLabel.text = localized(@"sample_search_option");
            break;
        case 6:
            cell.textLabel.text = @"Refresh access";
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
            [self performSegueWithIdentifier:@"browseFavoriteSites" sender:self];
            break;
        case 1:
            [self performSegueWithIdentifier:@"browseMySites" sender:self];
            break;
        case 2:
            [self performSegueWithIdentifier:@"browseAllSites" sender:self];
            break;
        case 3:
            [self performSegueWithIdentifier:@"browseCompanyHome" sender:self];
            break;
        case 4:
            [self performSegueWithIdentifier:@"activities" sender:self];
            break;
        case 5:
            [self performSegueWithIdentifier:@"search" sender:self];
            break;
        case 6:
            break;
    }
}

#pragma mark - Table View

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[segue destinationViewController] setSession:self.session];
    
    if([@"browseCompanyHome" isEqualToString:segue.identifier])
    {
        [[segue destinationViewController] setFolder:self.session.rootFolder];
    }
    else if([@"browseAllSites" isEqualToString:segue.identifier])
    {
        [[segue destinationViewController] setBrowsingType:AlfrescoSiteBrowsingAll];
    }
    else if([@"browseFavoriteSites" isEqualToString:segue.identifier])
    {
        [[segue destinationViewController] setBrowsingType:AlfrescoSiteBrowsingFavorites];
    }
    else if([@"browseMySites" isEqualToString:segue.identifier])
    {
        [[segue destinationViewController] setBrowsingType:AlfrescoSiteBrowsingMySites];
    }
}

@end
