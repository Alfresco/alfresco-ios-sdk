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

#import "HelloRepoViewController.h"
#import "AlfrescoRepositorySession.h"
#import "AlfrescoCloudSession.h"
#import "AlfrescoDocumentFolderService.h"
#import "AlfrescoNode.h"
#import "AlfrescoOAuthData.h"
#import "AlfrescoOAuthLoginViewController.h"

//#import "OAuthLoginWebViewController.h"

@interface HelloRepoViewController ()

@property (nonatomic, strong) NSMutableArray *nodes;
@property (nonatomic, strong) id<AlfrescoSession> session;
@property BOOL isCloudTest;

- (void)helloFromRepository;
- (void)helloFromCloud;
- (void)helloFromCloudWithOAuth;
- (void)loadRootFolder;

@end

@implementation HelloRepoViewController

@synthesize nodes = _nodes;
@synthesize session = _session;
@synthesize isCloudTest = _isCloudTest;
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isCloudTest = YES;
    self.navigationItem.title = @"Hello Repo";

    self.nodes = [NSMutableArray array];
    
//    [self helloFromRepository];
//    [self helloFromCloud];
    [self helloFromCloudWithOAuth];
}

#pragma mark - Repository methods

- (void)helloFromRepository
{
    NSLog(@"*********** helloFromRepository");
    NSURL *url = [NSURL URLWithString:@"http://localhost:8080/alfresco"];
    NSString *username = @"admin";
    NSString *password = @"admin";
    
    __weak HelloRepoViewController *weakSelf = self;
    [AlfrescoRepositorySession connectWithUrl:url
                                     username:username
                                     password:password
                                   parameters:nil
                              completionBlock:^(id<AlfrescoSession> session, NSError *error) {
                                  if (nil == session)
                                  {
                                      NSLog(@"Failed to authenticate: %@:", error);
                                  }
                                  else
                                  {
                                      NSLog(@"Authenticated successfully");
                                      NSLog(@"Repository version: %@", session.repositoryInfo.version);
                                      NSLog(@"Repository edition: %@", session.repositoryInfo.edition);
                                      weakSelf.session = session;
                                      [weakSelf loadRootFolder];
                                  }
                              }];
}

- (void)helloFromCloud
{
    NSLog(@"*********** helloFromCloud");
    NSString *emailAddress = @"peter.schmidt@alfresco.com";
    NSString *password = @"alzheimer\"\"";
    
    __weak HelloRepoViewController *weakSelf = self;
    [AlfrescoCloudSession connectWithEmailAddress:emailAddress
                                         password:password
                                           apiKey:nil
                                       parameters:nil
                                  completionBlock:^(id<AlfrescoSession> session, NSError *error) {
                                      if (session == nil)
                                      {
                                          NSLog(@"Failed to authenticate: %@:", error);
                                      }
                                      else
                                      {
                                          NSLog(@"Authenticated successfully");
                                          NSLog(@"Repository edition: %@", session.repositoryInfo.edition);
                                          weakSelf.session = session;
                                          [weakSelf loadRootFolder];
                                      }
    }];
}


- (void)helloFromCloudWithOAuth
{
    NSLog(@"*********** helloFromCloudWithOAuth");
    __block NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSNumber numberWithBool:self.isCloudTest] forKey:@"org.alfresco.mobile.cloud.isStaging"];
    __block NSString *apiKey = (self.isCloudTest) ? TESTAPIKEY : APIKEY;
    __block NSString *secretKey = (self.isCloudTest) ? TESTSECRETKEY : SECRETKEY;
    
    
    __weak HelloRepoViewController *weakSelf = self;
    AlfrescoOAuthCompletionBlock completionBlock = ^void(AlfrescoOAuthData *oauthdata, NSError *error){
        if (nil == oauthdata)
        {
            NSLog(@"something went wrong with the authentication. Error message is %@ and code is %d", [error localizedDescription], [error code]);
        }
        else
        {
            NSLog(@"We got something back: access token is %@", oauthdata.accessToken);
            NSLog(@"The refresh token is %@ the grant_type is %@", oauthdata.refreshToken, oauthdata.tokenType);
            [AlfrescoCloudSession connectWithOAuthData:oauthdata parameters:parameters sessionDelegate:self completionBlock:^(id<AlfrescoSession> session, NSError *error){
                if (nil == session)
                {
                }
                else
                {
                    weakSelf.session = session;
                    [weakSelf loadRootFolder];
                }
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            }];
        }
    };
    AlfrescoOAuthLoginViewController *webLoginController = [[AlfrescoOAuthLoginViewController alloc] initWithAPIKey:apiKey secretKey:secretKey redirectURI:REDIRECT completionBlock:completionBlock parameters:parameters];
    [self.navigationController pushViewController:webLoginController animated:YES];
}



- (void)loadRootFolder
{
    NSLog(@"*********** loadRootFolder");
    // create service
    AlfrescoDocumentFolderService *docFolderService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.session];
    __weak HelloRepoViewController *weakSelf = self;
    
    // retrieve the nodes from the given folder
    [docFolderService retrieveChildrenInFolder:self.session.rootFolder completionBlock:^(NSArray *array, NSError *error) {
        if (array == nil)
        {
            NSLog(@"Failed to retrieve root folder: %@", error);
        }
        else
        {
            NSLog(@"Retrieved root folder with %d children", array.count);
            weakSelf.nodes = [NSArray arrayWithArray:array];
            [weakSelf.tableView reloadData];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of nodes.
    return [self.nodes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // setup the cell, just show the node name
    AlfrescoNode *node = [self.nodes objectAtIndex:indexPath.row];
    cell.textLabel.text = node.name;
    
    return cell;
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }
    else
    {
        return YES;
    }
}

#pragma mark - AlfrescoSessionDelegate Methods

- (void)sessionDidExpire
{
    NSLog(@"notified that access token expired. But it turns out the refresh token also expired. Therefore we need to login again");
    [self helloFromCloudWithOAuth];
    
}
- (void)sessionWillRefresh
{
    NSLog(@"notified that access token expired and we are about to get a new one");
    
}
- (void)sessionDidRefresh
{
    NSLog(@"notified that access token expired and we did get a new one");
    
}
- (void)sessionDidFailWithError:(NSError *)error
{
    NSLog(@"notified that access token expired, we tried to get a new one but something wrong happened on the way");
    NSLog(@"sessionDidFailWithError:: error with %@ and code %d", [error localizedDescription] , [error code]);
    
}



@end
