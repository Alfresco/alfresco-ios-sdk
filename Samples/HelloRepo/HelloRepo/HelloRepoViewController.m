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
    self.isCloudTest = NO;
    self.navigationItem.title = @"Hello Repo";

    self.nodes = [NSMutableArray array];
    
//    [self helloFromRepository];
    [self helloFromCloud];
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
    
    __weak HelloRepoViewController *weakSelf = self;
    AlfrescoOAuthCompletionBlock completionBlock = ^void(AlfrescoOAuthData *oauthdata, NSError *error){
        if (nil == oauthdata)
        {
            NSLog(@"Failed to authenticate: %@:", error);
        }
        else
        {
            [AlfrescoCloudSession connectWithOAuthData:oauthdata parameters:nil completionBlock:^(id<AlfrescoSession> session, NSError *error){
                if (nil == session)
                {
                    NSLog(@"Failed to create session: %@:", error);
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
    AlfrescoOAuthLoginViewController *webLoginController = [[AlfrescoOAuthLoginViewController alloc] initWithAPIKey:APIKEY secretKey:SECRETKEY completionBlock:completionBlock parameters:nil];
    
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

@end
