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

#import "AKUserAccountListViewController.h"
#import "AKUserAccount.h"
#import "AKLoginService.h"
#import "AKNetworkActivity.h"

static CGFloat const kAccountCellMinimumHeight = 60.0f;

typedef NS_ENUM(NSUInteger, AccountTableViewControllerSection)
{
    AccountTableViewControllerSectionAccount = 0,
    AccountTableViewControllerSectionDownloads,
    AccountTableViewControllerSectionTotal // ENSURE THIS IS THE LAST ENTRY
};

@interface AKUserAccountListViewController () <UITableViewDataSource, UITableViewDelegate>
// Data Structure
@property (nonatomic, strong) NSArray *accountList;
// Views
@property (nonatomic, weak) IBOutlet UITableView *tableView;
// Services
@property (nonatomic, strong) AKLoginService *loginService;
@end

@implementation AKUserAccountListViewController

- (instancetype)initWithAccountList:(NSArray *)accountList
{
    return [self initWithAccountList:accountList delegate:nil];
}

- (instancetype)initWithAccountList:(NSArray *)accountList delegate:(id<AKUserAccountListViewControllerDelegate>)delegate
{
    self = [self init];
    if (self)
    {
        self.accountList = accountList;
        self.delegate = delegate;
        self.loginService = [[AKLoginService alloc] init];
        self.title = AKLocalizedString(@"ak.user.account.list.view.controller.title", @"Accounts Title");
    }
    return self;
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return AccountTableViewControllerSectionTotal;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 1; // defaults to one
    
    if (section == AccountTableViewControllerSectionAccount)
    {
        numberOfRows = self.accountList.count;
    }
    
    return numberOfRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *titleString = nil;
    
    if (section == AccountTableViewControllerSectionAccount)
    {
        titleString = AKLocalizedString(@"ak.user.account.list.view.controller.section.header.accounts", @"Accounts");
    }
    else if (section == AccountTableViewControllerSectionDownloads)
    {
        titleString = AKLocalizedString(@"ak.user.account.list.view.controller.section.header.local.files", @"Local Files");
    }
    
    return titleString;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == AccountTableViewControllerSectionAccount)
    {
        id<AKUserAccount> currentAccount = self.accountList[indexPath.row];
        NSString *accountImageName = (currentAccount.isOnPremiseAccount) ? @"account-type-onpremise" : @"account-type-cloud";
        cell.imageView.image = [UIImage imageFromAlfrescoKitBundleNamed:accountImageName];
        cell.textLabel.text = currentAccount.accountDescription;
    }
    else
    {
        cell.imageView.image = [UIImage imageFromAlfrescoKitBundleNamed:@"account-local"];
        cell.textLabel.text = AKLocalizedString(@"ak.user.account.list.view.controller.cell.local.files", @"Local Files");
    }
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == AccountTableViewControllerSectionAccount)
    {
        id<AKUserAccount> selectedAccount = self.accountList[indexPath.row];
        if ([self.delegate respondsToSelector:@selector(userAccountListViewController:didSelectUserAccount:)])
        {
            [self.delegate userAccountListViewController:self didSelectUserAccount:selectedAccount];
        }
        
        __weak typeof(self) weakSelf = self;
        __block AlfrescoRequest *request = nil;
        request = [self.loginService loginToAccount:selectedAccount networkIdentifier:nil completionBlock:^(BOOL successful, id<AlfrescoSession> session, NSError *error) {
            [weakSelf.delegate controller:weakSelf didCompleteRequest:request error:error];
            [weakSelf.delegate userAccountListViewController:weakSelf didLoginSuccessfully:successful toAccount:selectedAccount creatingSession:session error:error];
        }];
        
        if (!request.isCancelled)
        {
            [self.delegate controller:self didStartRequest:request];
        }
    }
    else if (indexPath.section == AccountTableViewControllerSectionDownloads)
    {
        [self.delegate didSelectLocalFilesOnUserAccountListViewController:self];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return MAX(height, kAccountCellMinimumHeight);
}

@end
