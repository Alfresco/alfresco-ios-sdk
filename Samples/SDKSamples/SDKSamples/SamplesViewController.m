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
@property (nonatomic, strong) AlfrescoRepositorySession *session;
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

#pragma mark Alfresco methods being used
- (void) authenticate
{
    if(self.session != nil) return;
    
    // gather the user's connection details.
    NSString *host = [[NSUserDefaults standardUserDefaults] stringForKey:@"host"];
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *pwd = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    
    if (host == nil || username == nil || pwd == nil)
    {
        self.connectionDetailsProvided = NO;
        
        NSDictionary *appDefaults = [NSMutableDictionary dictionaryWithCapacity:3];
        if (host == nil)
        {
            [appDefaults setValue:@"http://localhost:8080/alfresco" forKey:@"host"];
        }
        else 
        {
            [appDefaults setValue:host forKey:@"host"];
        }
        
        if (username == nil)
        {
            [appDefaults setValue:@"admin" forKey:@"username"];
        }
        else 
        {
            [appDefaults setValue:username forKey:@"username"];
        }
        
        if (pwd == nil)
        {
            [appDefaults setValue:@"admin" forKey:@"password"];
        }
        else 
        {
            [appDefaults setValue:pwd forKey:@"password"];
        }
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
        
        host = [[NSUserDefaults standardUserDefaults] stringForKey:@"host"];
        username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
        pwd = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    }
    
    NSLog(@"Loading session for user '%@' in background...", username);
    self.connectionDetailsProvided = YES;
    
    // determine which kind of session to create
    __weak SamplesViewController *weakSelf = self;
    if ([host isEqualToString:@"http://my.alfresco.com"])
    {
        NSLog(@"Connecting to Alfresco in the Cloud server");
        
        // create and authenticate an on-premise repository session
        [AlfrescoCloudSession connectWithEmailAddress:username
                                             password:pwd
                                               apiKey:nil
                                             parameters:nil
                                      completionBlock:^(id<AlfrescoSession> session, NSError *error) {
                                          if (nil == session)
                                          {
                                              UIAlertView *connectionFailedAlert = [[UIAlertView alloc] initWithTitle:localized(@"error_title")
                                                                                                              message:localized(@"error_connection_failed")
                                                                                                             delegate:nil
                                                                                                    cancelButtonTitle:localized(@"dialog_cancel")
                                                                                                    otherButtonTitles:nil];
                                              [connectionFailedAlert show];
                                          }
                                          else
                                          {
                                              weakSelf.session = session;
                                              NSLog(@"Authenticated successfully.");
                                          }
                                      }];
    }
    else
    {
        NSURL *url = [NSURL URLWithString:host];
        NSLog(@"Connecting to on-premise repository at %@", url);
        
        // create and authenticate an on-premise repository session
        [AlfrescoRepositorySession connectWithUrl:url
                                         username:username
                                         password:pwd
                                         parameters:nil
                                  completionBlock:^(id<AlfrescoSession> session, NSError *error) {
                                      if (nil == session)
                                      {
                                          UIAlertView *connectionFailedAlert = [[UIAlertView alloc] initWithTitle:localized(@"error_title")
                                                                                                          message:localized(@"error_connection_failed")
                                                                                                         delegate:nil
                                                                                                cancelButtonTitle:localized(@"dialog_cancel")
                                                                                                otherButtonTitles:nil];
                                          [connectionFailedAlert show];
                                      }
                                      else 
                                      {
                                          weakSelf.session = session;
                                          NSLog(@"Authenticated successfully.");
                                      }
                                  }];
    }
}

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
    [self authenticate];
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
