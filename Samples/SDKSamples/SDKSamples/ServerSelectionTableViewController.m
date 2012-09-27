//
//  ServerSelectionTableViewController.m
//  SDKSamples
//
//  Created by Peter Schmidt on 26/09/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private methods
- (void)authenticateCloudWithOAuth
{
    
    __block NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSNumber numberWithBool:YES] forKey:@"org.alfresco.mobile.cloud.isStaging"];
    
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
            [AlfrescoCloudSession connectWithOAuthData:oauthdata parameters:nil completionBlock:^(id<AlfrescoSession> session, NSError *error){
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
    AlfrescoOAuthLoginViewController *loginController = [[AlfrescoOAuthLoginViewController alloc] initWithAPIKey:APIKEY secretKey:SECRETKEY redirectURI:REDIRECT completionBlock:completionBlock];
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
