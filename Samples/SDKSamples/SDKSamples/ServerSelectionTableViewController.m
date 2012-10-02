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

#import "ServerSelectionTableViewController.h"
#import "AlfrescoCloudSession.h"
#import "AlfrescoOAuthData.h"
#import "AlfrescoOAuthLoginViewController.h"

@interface ServerSelectionTableViewController ()
@property (nonatomic, strong) AlfrescoCloudSession *session;
- (void)authenticateCloudWithOAuth;
@end

@implementation ServerSelectionTableViewController
@synthesize session = _session;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private methods
- (void)authenticateCloudWithOAuth
{
    __weak ServerSelectionTableViewController *weakSelf = self;
    AlfrescoOAuthCompletionBlock completionBlock = ^void(AlfrescoOAuthData *oauthdata, NSError *error){
        if (nil == oauthdata)
        {
            NSLog(@"something went wrong with the authentication. Error message is %@ and code is %d", [error localizedDescription], [error code]);
        }
        else
        {
            NSLog(@"We got something back: access token is %@", oauthdata.accessToken);
            NSLog(@"The refresh token is %@ the grant_type is %@", oauthdata.refreshToken, oauthdata.tokenType);
            [AlfrescoCloudSession connectWithOAuthData:oauthdata completionBlock:^(id<AlfrescoSession> session, NSError *error){
                if (nil == session)
                {
                    [weakSelf.navigationController popToViewController:weakSelf animated:YES ];
                }
                else
                {
                    weakSelf.session = session;
                    [weakSelf performSegueWithIdentifier:@"cloudAfterAuthentication" sender:weakSelf.session];
                }
            }];
        }
    };
    /**
     if you provide your own redirectURI from the server, then uncomment the lines below
     */
//    AlfrescoOAuthLoginViewController *loginController = [[AlfrescoOAuthLoginViewController alloc] initWithAPIKey:APIKEY
//                                                                                                       secretKey:SECRETKEY
//                                                                                                     redirectURI:REDIRECTURI
//                                                                                                 completionBlock:completionBlock];
    
    // use this is you want to use the Alfresco default redirect URI
    AlfrescoOAuthLoginViewController *loginController = [[AlfrescoOAuthLoginViewController alloc] initWithAPIKey:APIKEY
                                                                                                       secretKey:SECRETKEY
                                                                                                 completionBlock:completionBlock];
    [self.navigationController pushViewController:loginController animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue");
    [[segue destinationViewController] setSession:self.session];    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (1 == indexPath.row) //cloud row
    {
        [self authenticateCloudWithOAuth];
    }
}

@end
