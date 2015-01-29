/*
 ******************************************************************************
 * Copyright (C) 2005-2015 Alfresco Software Limited.
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
 *****************************************************************************
 */

#import "AKLoginViewController.h"
#import "AKLoginEntryCell.h"
#import "AKLoginService.h"

static NSUInteger const kNumberOfRowsInSection = 2;
static CGFloat const kLoginButtonContainerHeight = 50.0f;

typedef NS_ENUM(NSUInteger, LoginEntryCell)
{
    LoginEntryCellUsername = 0,
    LoginEntryCellPassword
};

@interface AKLoginViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

// Views
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIView *loginFooterView;
@property (nonatomic, strong) AKLoginEntryCell *usernameCell;
@property (nonatomic, strong) AKLoginEntryCell *passwordCell;
@property (nonatomic, weak) UITextField *activeTextField;
// Data Structure
@property (nonatomic, strong) id<AKUserAccount> account;
// Services
@property (nonatomic, strong) AKLoginService *loginService;

@end

@implementation AKLoginViewController

- (instancetype)initWithUserAccount:(id<AKUserAccount>)userAccount
{
    return [self initWithUserAccount:userAccount delegate:nil];
}

- (instancetype)initWithUserAccount:(id<AKUserAccount>)userAccount delegate:(id<AKLoginViewControllerDelegate>)delegate
{
    self = [self init];
    if (self)
    {
        self.account = userAccount;
        self.delegate = delegate;
        self.loginService = [[AKLoginService alloc] init];
        self.title = userAccount.username;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupCells];
}

#pragma mark - Getters and Setters

- (UIView *)loginFooterView
{
    if (!_loginFooterView)
    {
        UIView *loginContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, kLoginButtonContainerHeight)];
        
        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
        loginButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        [loginButton setTitle:AKLocalizedString(@"ak.login.view.controller.login.button.title", @"Login Title") forState:UIControlStateNormal];
        [loginButton addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [loginContainer addSubview:loginButton];

        NSArray *vertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[loginContainer]-(<=1)-[loginButton]"
                                                                    options:NSLayoutFormatAlignAllCenterX
                                                                    metrics:nil
                                                                      views:NSDictionaryOfVariableBindings(loginButton, loginContainer)];
        NSArray *horizonal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[loginContainer]-(<=1)-[loginButton]"
                                                                     options:NSLayoutFormatAlignAllCenterY
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(loginButton, loginContainer)];
        
        [loginContainer addConstraints:vertical];
        [loginContainer addConstraints:horizonal];
        
        _loginFooterView = loginContainer;
    }
    
    return _loginFooterView;
}

#pragma mark - Private Methods

- (void)setupCells
{
    // Load the cells
    self.usernameCell = (AKLoginEntryCell *)[[[NSBundle alfrescoKitBundle] loadNibNamed:NSStringFromClass([AKLoginEntryCell class]) owner:self options:nil] lastObject];
    self.passwordCell = (AKLoginEntryCell *)[[[NSBundle alfrescoKitBundle] loadNibNamed:NSStringFromClass([AKLoginEntryCell class]) owner:self options:nil] lastObject];
    
    // Additional setup
    self.usernameCell.entryTextField.placeholder = AKLocalizedString(@"ak.login.view.controller.cell.username.placeholder", "Username placeholder");
    self.usernameCell.entryTextField.returnKeyType = UIReturnKeyNext;
    self.passwordCell.entryTextField.placeholder = AKLocalizedString(@"ak.login.view.controller.cell.password.placeholder", @"Password placeholder");
    self.passwordCell.entryTextField.secureTextEntry = YES;
    self.passwordCell.entryTextField.clearsOnBeginEditing = YES;
    // Set delegates
    self.usernameCell.entryTextField.delegate = self;
    self.passwordCell.entryTextField.delegate = self;
    
    // Preload the cell data
    self.usernameCell.titleTextLabel.text = AKLocalizedString(@"ak.login.view.controller.cell.username.title", @"Username title");
    self.usernameCell.entryTextField.text = (self.account.username) ?: AKLocalizedString(@"ak.login.view.controller.cell.username.placeholder", "Username placeholder");
    self.passwordCell.titleTextLabel.text = AKLocalizedString(@"ak.login.view.controller.cell.password.title", @"Password Title");
    self.passwordCell.entryTextField.text = (self.account.password) ?: AKLocalizedString(@"ak.login.view.controller.cell.password.placeholder", @"Password placeholder");
}

- (void)loginButtonPressed:(id)sender
{
    [self.usernameCell.entryTextField resignFirstResponder];
    [self.passwordCell.entryTextField resignFirstResponder];
    
    NSString *username = self.usernameCell.entryTextField.text;
    NSString *password = self.passwordCell.entryTextField.text;
    
    __weak typeof(self) weakSelf = self;
    __block AlfrescoRequest *request = nil;
    request = [self.loginService loginToOnPremiseRepositoryWithAccount:self.account username:username password:password completionBlock:^(BOOL successful, id<AlfrescoSession> session, NSError *error) {
        [weakSelf.delegate controller:self didCompleteRequest:request error:error];
        [weakSelf.delegate loginViewController:weakSelf didLoginSuccessfully:successful toAccount:self.account username:username password:password creatingSession:session error:error];
        
        if (!successful)
        {
            [weakSelf.activeTextField becomeFirstResponder];
        }
    }];
    [self.delegate controller:self didStartRequest:request];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kNumberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AKLoginEntryCell *cell = nil;
    
    if (indexPath.row == LoginEntryCellUsername)
    {
        cell = self.usernameCell;
    }
    else if (indexPath.row == LoginEntryCellPassword)
    {
        cell = self.passwordCell;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AKLoginEntryCell *cell = (AKLoginEntryCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return self.loginFooterView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kLoginButtonContainerHeight;
}

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.passwordCell.entryTextField)
    {
        [self loginButtonPressed:nil];
    }
    else if (textField == self.usernameCell.entryTextField)
    {
        [self.passwordCell.entryTextField becomeFirstResponder];
    }
    return YES;
}

@end
