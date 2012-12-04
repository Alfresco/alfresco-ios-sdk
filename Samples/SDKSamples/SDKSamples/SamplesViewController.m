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
#import "AlfrescoOAuthHelper.h"
#import "AlfrescoOAuthData.h"

@interface SamplesViewController ()
@property (nonatomic, assign) BOOL connectionDetailsProvided;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
- (void)refreshAccessToken;
- (void)createActivityView;
@end

@implementation SamplesViewController
@synthesize connectionDetailsProvided = _connectionDetailsProvided;
@synthesize session = _session;


#pragma mark View Controller methods

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = localized(@"sample_title");
    [self createActivityView];

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
            cell.textLabel.text = localized(@"sample_refresh_access_token");
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
            [self refreshAccessToken];
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

/**
 The AlfrescoOAuthHelper class facilitates refresh of access tokens. For that it requires the existing AlfrescoOAuthData set.
 In our example here, we simply obtain the AlfrescoOAuthData from the AlfrescoCloudSession object directly.
 For production code, a different route may be chosen:
 AlfrescoOAuthData is serializable. Therefore, the data may be stored, e.g. in User defaults. 
 The commented out code demonstrates how you obtain the archived OAuthData from user defaults.
 It then shows how we reset the archived OAuth data to the updated object containing the new access/refresh token.
 
 Storing/archiving AlfrescoOAuthData is also demonstrated in the ServerSelectionTableViewController
 */
- (void)refreshAccessToken
{
    if (nil != self.activityIndicator)
    {
        [self.activityIndicator startAnimating];
    }
    /* ---- obtain the archived AlfrescoOAuthData with the original access/refresh token from User defaults ----
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    NSData *archivedOAuthData = [standardDefaults objectForKey:@"ArchivedOAuthData"];
    if (nil == archivedOAuthData)
    {
        NSString *message = @"There are no Archived OAuth data";
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
        return;
    }

    AlfrescoOAuthData *oauthData = [NSKeyedUnarchiver unarchiveObjectWithData:archivedOAuthData];
     */
    
    __block AlfrescoCloudSession *cloudSession = (AlfrescoCloudSession *)self.session;
    AlfrescoOAuthHelper *oauthHelper = [[AlfrescoOAuthHelper alloc] initWithParameters:nil delegate:self];
    [oauthHelper refreshAccessToken:cloudSession.oauthData completionBlock:^(AlfrescoOAuthData *refreshedOAuthData, NSError *error){
        if (nil == refreshedOAuthData)
        {
            if (nil != self.activityIndicator)
            {
                [self.activityIndicator stopAnimating];
            }
            
            NSString *title = localized(@"error_refresh_access_token");
            NSString *message = [NSString stringWithFormat:@"Error refreshing OAuth Data %@", [error localizedDescription]];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alertView show];
        }
        else
        {
            if (nil != self.activityIndicator)
            {
                [self.activityIndicator stopAnimating];
            }

            /* ---- now that we refreshed the access/refresh tokens -> archive them back to User defaults ----
            NSData *refreshedData = [NSKeyedArchiver archivedDataWithRootObject:refreshedOAuthData];
            [standardDefaults removeObjectForKey:@"ArchivedOAuthData"];
            [standardDefaults setObject:refreshedData forKey:@"ArchivedOAuthData"];
            [standardDefaults synchronize];
             */
            
            [cloudSession setOauthData:refreshedOAuthData];
            
            
            NSString *message = localized(@"sample_alert_refresh_success");
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alertView show];
            
        }
    }];
}


- (void)createActivityView
{
    CGSize size = self.view.bounds.size;
    CGFloat xOffset = size.width/2 - 50;
    CGFloat yOffset = size.height/2 - 50;
    CGRect viewFrame = CGRectMake(xOffset, yOffset, 100, 100);
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.activityIndicator.frame = viewFrame;
    self.activityIndicator.hidesWhenStopped = YES;
    [self.view insertSubview:self.activityIndicator aboveSubview:self.tableView];
}

#pragma mark - OAuth delegate method
- (void)oauthLoginDidFailWithError:(NSError *)error
{
    NSString *message = [NSString stringWithFormat:@"Refresh error %@", [error localizedDescription]];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alertView show];
}

@end
