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

#import "AKNamingViewController.h"
#import "AKNamingCell.h"

static NSUInteger const kNumberOfRowsInSection = 1;
static CGFloat const kUploadButtonContainerHeight = 50.0f;

@interface AKNamingViewController ()

@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, strong) id userInfo;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIView *uploadFooterView;
@property (nonatomic, strong) AKNamingCell *namingCell;

@end

@implementation AKNamingViewController

- (instancetype)initWithURL:(NSURL *)url delegate:(id<AKNamingViewControllerDelegate>)delegate
{
    return [self initWithURL:url delegate:delegate userInfo:nil];
}

- (instancetype)initWithURL:(NSURL *)url delegate:(id<AKNamingViewControllerDelegate>)delegate userInfo:(id)userInfo
{
    self = [self init];
    if (self)
    {
        self.fileURL = url;
        self.delegate = delegate;
        self.userInfo = userInfo;
        self.title = AKLocalizedString(@"ak.naming.view.controller.title", @"Naming Title");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupCells];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.namingCell.entryTextField becomeFirstResponder];
}

#pragma mark - Getters and Setters

- (UIView *)uploadFooterView
{
    if (!_uploadFooterView)
    {
        UIView *uploadContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, kUploadButtonContainerHeight)];
        
        UIButton *uploadButton = [UIButton buttonWithType:UIButtonTypeSystem];
        uploadButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        [uploadButton setTitle:AKLocalizedString(@"ak.naming.view.controller.select.button.title", @"Select Title") forState:UIControlStateNormal];
        [uploadButton addTarget:self action:@selector(uploadButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [uploadContainer addSubview:uploadButton];
        
        NSArray *vertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[uploadContainer]-(<=1)-[uploadButton]"
                                                                    options:NSLayoutFormatAlignAllCenterX
                                                                    metrics:nil
                                                                      views:NSDictionaryOfVariableBindings(uploadButton, uploadContainer)];
        NSArray *horizonal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[uploadContainer]-(<=1)-[uploadButton]"
                                                                     options:NSLayoutFormatAlignAllCenterY
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(uploadButton, uploadContainer)];
        
        [uploadContainer addConstraints:vertical];
        [uploadContainer addConstraints:horizonal];
        
        _uploadFooterView = uploadContainer;
    }
    
    return _uploadFooterView;
}

#pragma mark - Private Methods

- (void)setupCells
{
    // Load the cells
    self.namingCell = (AKNamingCell *)[[[NSBundle alfrescoKitBundle] loadNibNamed:NSStringFromClass([AKNamingCell class]) owner:self options:nil] lastObject];
    
    // Additional setup
    self.namingCell.entryTextField.placeholder = AKLocalizedString(@"ak.naming.view.controller.cell.name.placeholder", "Name placeholder");
    
    // Preload the cell data
    self.namingCell.titleTextLabel.text = AKLocalizedString(@"ak.naming.view.controller.cell.title", @"Name title");
    self.namingCell.entryTextField.text = (self.fileURL) ? self.fileURL.lastPathComponent : @"";
}

- (void)uploadButtonPressed:(id)sender
{
    NSString *enteredName = [self.namingCell.entryTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (enteredName && enteredName.length > 0)
    {
        [self.namingCell.entryTextField resignFirstResponder];
        [self.delegate namingViewController:self didEnterName:enteredName userInfo:self.userInfo];
    }
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kNumberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AKNamingCell *cell = self.namingCell;
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AKNamingCell *cell = (AKNamingCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return self.uploadFooterView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kUploadButtonContainerHeight;
}

@end
