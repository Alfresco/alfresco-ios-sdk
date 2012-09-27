//
//  RepositoryLoginViewController.m
//  SDKSamples
//
//  Created by Peter Schmidt on 26/09/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "RepositoryLoginViewController.h"
#import "AlfrescoSession.h"
#import "SamplesViewController.h"
#import "AlfrescoRepositorySession.h"

@interface RepositoryLoginViewController ()
@property (nonatomic, strong) NSString * urlText;
@property (nonatomic, strong) NSString * username;
@property (nonatomic, strong) NSString * password;
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
    self.doneButton.enabled = NO;
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
    self.doneButton.enabled = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    int tag = textField.tag;
    NSLog(@"textFieldDidEndEditing. the tag is %d and the text is %@", tag, textField.text);
    switch (tag)
    {
        case 1:
            self.urlText = textField.text;
            break;
        case 2:
            self.username = textField.text;
            break;
        case 3:
            self.password = textField.text;
            break;
    }
    
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
