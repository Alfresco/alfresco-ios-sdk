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

#import "RepositoryLoginViewController.h"
#import "AlfrescoSession.h"
#import "SamplesViewController.h"
#import "AlfrescoRepositorySession.h"

NSString * const kAlfrescoSDKSamplesHost = @"host";
NSString * const kAlfrescoSDKSamplesUsername = @"username";
NSString * const kAlfrescoSDKSamplesPassword = @"password";

@interface RepositoryLoginViewController ()
@property (nonatomic, strong) NSMutableDictionary *defaults;
- (void)defaultSettings;
- (void)authenticateRepoSession;
@end

@implementation RepositoryLoginViewController
@synthesize urlField = _urlField;
@synthesize usernameField = _usernameField;
@synthesize passwordField = _passwordField;
@synthesize doneButton = _doneButton;
@synthesize  defaults = _defaults;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.defaults = [NSMutableDictionary dictionaryWithCapacity:3];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self defaultSettings];
    
    // enable the done button
    if (self.urlField.text.length == 0 || self.usernameField.text.length == 0 || self.passwordField.text.length == 0)
    {
        [self.doneButton setEnabled:NO];
    }
    else
    {
        [self.doneButton setEnabled:YES];
    }
}

- (IBAction)authenticateWhenDone:(id)sender
{
    // this shouldn't happen but check just in case
    if (self.urlField.text.length == 0 || self.usernameField.text.length == 0 || self.passwordField.text.length == 0)
    {
        return;
    }
    
    // authenticate using the current credentials
    [self authenticateRepoSession];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[segue destinationViewController] setSession:self.session];
}

#pragma mark - private methods

- (void)defaultSettings
{
    NSString *host = [[NSUserDefaults standardUserDefaults] stringForKey:kAlfrescoSDKSamplesHost];
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:kAlfrescoSDKSamplesUsername];
    NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:kAlfrescoSDKSamplesPassword];
    if (host == nil || username == nil || password == nil)
    {        
        if (nil == host)
        {
            [self.defaults setValue:@"http://localhost:8080/alfresco" forKey:kAlfrescoSDKSamplesHost];
        }
        else
        {
            [self.defaults setValue:host forKey:kAlfrescoSDKSamplesHost];
        }
        
        if (nil == username)
        {
            [self.defaults setValue:@"admin" forKey:kAlfrescoSDKSamplesUsername];
        }
        else
        {
            [self.defaults setValue:username forKey:kAlfrescoSDKSamplesUsername];
        }
        
        if (nil == password)
        {
            [self.defaults setValue:@"admin" forKey:kAlfrescoSDKSamplesPassword];
        }
        else
        {
            [self.defaults setValue:password forKey:kAlfrescoSDKSamplesPassword];
        }
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:self.defaults];
        
        host = [[NSUserDefaults standardUserDefaults] stringForKey:kAlfrescoSDKSamplesHost];
        username = [[NSUserDefaults standardUserDefaults] stringForKey:kAlfrescoSDKSamplesUsername];
        password = [[NSUserDefaults standardUserDefaults] stringForKey:kAlfrescoSDKSamplesPassword];
    }
    
    self.urlField.text = host;
    self.usernameField.text = username;
    self.passwordField.text = password;
}

- (void)authenticateRepoSession
{
    AlfrescoSessionCompletionBlock completionBlock = ^void(id<AlfrescoSession> session, NSError *error){
        if (nil == session)
        {
            [self showFailureAlert:@"Failed to connect, please check your credentials"];
        }
        else
        {
            self.session = (AlfrescoRepositorySession *)session;
            [self performSegueWithIdentifier:@"repoAfterAuthentication" sender:self.session];
        }
    };
    
    [AlfrescoRepositorySession connectWithUrl:[NSURL URLWithString:self.urlField.text]
                                     username:self.usernameField.text
                                     password:self.passwordField.text
                              completionBlock:completionBlock];
}

- (void)toggleDoneButtonState:(NSString *)currentValue
{
    if (currentValue != nil && currentValue.length > 0)
    {
        self.doneButton.enabled = YES;
    }
    else
    {
        self.doneButton.enabled = NO;
    }
}

#pragma mark - Textfield delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    int tag = textField.tag;
    
    switch (tag)
    {
        case 1:
            [self.defaults setValue:self.urlField.text forKey:kAlfrescoSDKSamplesHost];
            break;
        case 2:
            [self.defaults setValue:self.usernameField.text forKey:kAlfrescoSDKSamplesUsername];
            break;
        case 3:
            [self.defaults setValue:self.passwordField.text forKey:kAlfrescoSDKSamplesPassword];
            break;
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:self.defaults];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // everytime a character changes check the Done button state
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self toggleDoneButtonState:newString];
    return YES;
}

@end
