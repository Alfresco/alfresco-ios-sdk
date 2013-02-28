/*******************************************************************************
 * Copyright (C) 2005-2013 Alfresco Software Limited.
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
- (void)defaultSettings;
- (void)authenticateRepoSession;
@end

@implementation RepositoryLoginViewController
@synthesize urlField = _urlField;
@synthesize usernameField = _usernameField;
@synthesize passwordField = _passwordField;
@synthesize doneButton = _doneButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    NSUserDefaults *defaultSettings = [NSUserDefaults standardUserDefaults];
    NSString *host = [defaultSettings stringForKey:kAlfrescoSDKSamplesHost];
    NSString *username = [defaultSettings stringForKey:kAlfrescoSDKSamplesUsername];
    NSString *password = [defaultSettings stringForKey:kAlfrescoSDKSamplesPassword];
    if (host == nil || username == nil || password == nil)
    {        
        if (nil == host)
        {
            host = @"http://localhost:8080/alfresco";
            [defaultSettings setObject:host forKey:kAlfrescoSDKSamplesHost];
        }
        
        if (nil == username)
        {
            username = @"admin";
            [defaultSettings setObject:username forKey:kAlfrescoSDKSamplesUsername];
        }
        
        if (nil == password)
        {
            password = @"admin";
            [defaultSettings setObject:password forKey:kAlfrescoSDKSamplesPassword];
        }
    }
    [defaultSettings synchronize];
    
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
    
    // enable metadata extraction
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                           forKey:kAlfrescoMetadataExtraction];
    
    [AlfrescoRepositorySession connectWithUrl:[NSURL URLWithString:self.urlField.text]
                                     username:self.usernameField.text
                                     password:self.passwordField.text
                                   parameters:parameters
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
    NSUserDefaults *defaultSettings = [NSUserDefaults standardUserDefaults];
    
    switch (tag)
    {
        case 1:
            [defaultSettings setObject:self.urlField.text forKey:kAlfrescoSDKSamplesHost];
            break;
        case 2:
            [defaultSettings setObject:self.usernameField.text forKey:kAlfrescoSDKSamplesUsername];
            break;
        case 3:
            [defaultSettings setObject:self.passwordField.text forKey:kAlfrescoSDKSamplesPassword];
            break;
    }    
    [defaultSettings synchronize];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // everytime a character changes check the Done button state
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self toggleDoneButtonState:newString];
    return YES;
}

@end
