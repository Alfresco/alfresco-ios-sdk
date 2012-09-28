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
@synthesize browseCompanyLabel = _browseCompanyLabel;
@synthesize browseSitesLabel = _browseSitesLabel;
@synthesize browseFavouriteSitesLabel = _browseFavouriteSitesLabel;
@synthesize browseAllSitesLabel = _browseAllSitesLabel;
@synthesize browseActivitiesLabel = _browseActivitiesLabel;
@synthesize searchLabel = _searchLabel;

@synthesize connectionDetailsProvided = _connectionDetailsProvided;
@synthesize session = _session;


#pragma mark View Controller methods

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = localized(@"sample_title");
    self.browseCompanyLabel.text = localized(@"sample_browse_company_home_option");
    self.browseSitesLabel.text = localized(@"sample_browse_my_sites_option");
    self.browseFavouriteSitesLabel.text = localized(@"sample_browse_favourite_sites_option");
    self.browseAllSitesLabel.text = localized(@"sample_browse_all_sites_option");
    self.browseActivitiesLabel.text = localized(@"sample_activities_option");
    self.searchLabel.text = localized(@"sample_search_option");
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

#pragma mark - Table View

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"detected segue: %@", segue.identifier);
    
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
