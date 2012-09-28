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

@interface RepositoryLoginViewController ()
@property (nonatomic, strong) NSString * urlText;
@property (nonatomic, strong) NSString * username;
@property (nonatomic, strong) NSString * password;
@property (nonatomic, strong) NSMutableDictionary *defaults;
- (void)defaultSettings;
- (void)authenticateRepoSession;
@end

@implementation RepositoryLoginViewController
@synthesize urlField = _urlField;
@synthesize usernameField = _usernameField;
@synthesize passwordField = _passwordField;
@synthesize username = _username;
@synthesize password = _password;
@synthesize urlText = _urlText;
@synthesize doneButton = _doneButton;
@synthesize  defaults = _defaults;

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
    self.urlText = @"";
    self.username = @"";
    self.password = @"";
    self.defaults = [NSMutableDictionary dictionaryWithCapacity:3];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self defaultSettings];
}

- (void)didReceiveMemoryWarning
{
    self.urlText = nil;
    self.username = nil;
    self.password = nil;
    [super didReceiveMemoryWarning];
}


- (IBAction)authenticateWhenDone:(id)sender
{
    if ([self.urlText isEqualToString:@""] || [self.username isEqualToString:@""] || [self.password isEqualToString:@""])
    {
        NSLog(@"Nothing to do");
        return;
    }
    [self authenticateRepoSession];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue");
    [[segue destinationViewController] setSession:self.session];
}

#pragma mark - private method
- (void)defaultSettings
{
    NSString *host = [[NSUserDefaults standardUserDefaults] stringForKey:@"host"];
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    if (host == nil || username == nil || password == nil)
    {        
        if (nil == host)
        {
            [self.defaults setValue:@"http://localhost:8080/alfresco" forKey:@"host"];
        }
        else
        {
            [self.defaults setValue:host forKey:@"host"];
        }
        
        if (nil == username)
        {
            [self.defaults setValue:@"admin" forKey:@"username"];
        }
        else
        {
            [self.defaults setValue:username forKey:@"username"];
        }
        
        if (nil == password)
        {
            [self.defaults setValue:@"admin" forKey:@"password"];
        }
        else
        {
            [self.defaults setValue:password forKey:@"password"];
        }
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:self.defaults];
        
        host = [[NSUserDefaults standardUserDefaults] stringForKey:@"host"];
        username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
        password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
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
            NSLog(@"something bad happened");
            NSString *errorMsg = [NSString stringWithFormat:@"%@ and code %d",[error localizedDescription], [error code]];
            [self showFailureAlert:errorMsg];
        }
        else
        {
            NSLog(@"we got a session back and start the seque");
            self.session = (AlfrescoRepositorySession *)session;
            [self performSegueWithIdentifier:@"repoAfterAuthentication" sender:self.session];
        }
    };
    
    [AlfrescoRepositorySession connectWithUrl:[NSURL URLWithString:self.urlText]
                                     username:self.username
                                     password:self.password
                                   parameters:nil
                              completionBlock:completionBlock];
    
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
    NSLog(@"textFieldDidEndEditing. the tag is %d and the text is %@", tag, textField.text);
    switch (tag)
    {
        case 1:
            self.urlText = textField.text;
            [self.defaults setValue:self.urlText forKey:@"host"];
            break;
        case 2:
            self.username = textField.text;
            [self.defaults setValue:self.username forKey:@"username"];
            break;
        case 3:
            self.password = textField.text;
            [self.defaults setValue:self.password forKey:@"password"];
            break;
    }
    [[NSUserDefaults standardUserDefaults] registerDefaults:self.defaults];    
}

/*
 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    int tag = textField.tag;
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    switch (tag)
    {
        case 1:
            self.urlText = newString;
            break;
        case 2:
            self.username = newString;
            break;
        case 3:
            self.password = newString;
            break;
    }
    return YES;
}
@end
