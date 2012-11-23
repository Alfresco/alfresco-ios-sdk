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
@property (nonatomic, strong) AlfrescoOAuthLoginViewController *loginController;
- (void)authenticateCloudWithOAuth;
@end

@implementation ServerSelectionTableViewController
@synthesize loginController = _loginController;
#pragma mark - private methods
- (void)authenticateCloudWithOAuth
{
    __weak ServerSelectionTableViewController *weakSelf = self;
    AlfrescoOAuthCompletionBlock completionBlock = ^void(AlfrescoOAuthData *oauthdata, NSError *error){
        if (nil == oauthdata)
        {
            log(@"Failed to authenticate, error message is %@ and code is %d", [error localizedDescription], [error code]);
        }
        else
        {
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
    
    // check the API key and secret have been defined
    NSString *apiKey = APIKEY;
    NSString *secretKey = SECRETKEY;
    if (apiKey.length == 0 || secretKey.length == 0)
    {
        [self showFailureAlert:@"error_no_keys"];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        // use this is you want to use the Alfresco default redirect URI
        self.loginController = [[AlfrescoOAuthLoginViewController alloc] initWithAPIKey:APIKEY
                                                                              secretKey:SECRETKEY
                                                                        completionBlock:completionBlock];
        self.loginController.oauthDelegate = self;
        [self.navigationController pushViewController:self.loginController animated:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
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

#pragma mark - OAuth delegate
- (void)oauthLoginDidFailWithError:(NSError *)error
{
    if (nil != self.loginController)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
