/*
 ******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
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

#import "AKLocalFilesViewController.h"
#import "AKAlfrescoNodeCell.h"

@interface AKLocalFilesViewController ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, assign) AKLocalFileControllerType mode;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSMutableArray *tableViewData;

@end

@implementation AKLocalFilesViewController

- (instancetype)initWithMode:(AKLocalFileControllerType)mode url:(NSURL *)url delegate:(id<AKLocalFilesViewControllerDelegate>)delegate
{
    self = [self init];
    if (self)
    {
        self.mode = mode;
        self.url = url;
        self.delegate = delegate;
        self.tableViewData = [NSMutableArray array];
        self.title = AKLocalizedString(@"ak.local.files.view.controller.title", @"Local Files");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupToolbar];
    
    if (self.mode == AKLocalFileControllerTypeFolderPicker)
    {
        self.navigationController.toolbarHidden = NO;
    }
    
    [self loadContentsFromURL:self.url];
}

#pragma mark - Private Methods

- (void)loadContentsFromURL:(NSURL *)url
{
    self.tableViewData = [[self pathsForContentsOfURL:url] mutableCopy];
}

- (NSArray *)pathsForContentsOfURL:(NSURL *)url
{
    __block NSMutableArray *documents = [NSMutableArray array];
    NSError *enumeratorError = nil;
    
    AlfrescoFileManager *fileManager = [AlfrescoFileManager sharedManager];
    [fileManager enumerateThroughDirectory:url.path includingSubDirectories:NO withBlock:^(NSString *fullFilePath) {
        BOOL isDirectory;
        [fileManager fileExistsAtPath:fullFilePath isDirectory:&isDirectory];
        NSURL *fullFileURL = [NSURL fileURLWithPath:fullFilePath isDirectory:isDirectory];
        
        if (!isDirectory)
        {
            [documents addObject:fullFileURL];
        }
    } error:&enumeratorError];
    
    if (enumeratorError)
    {
        AlfrescoLogError(@"Enumeration Error: %@", enumeratorError.localizedDescription);
    }
    
    NSSortDescriptor *sortOrder = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES comparator:^NSComparisonResult(NSURL *firstDocument, NSURL *secondDocument) {
        return [firstDocument.path caseInsensitiveCompare:secondDocument.path];
    }];
    
    return [documents sortedArrayUsingDescriptors:@[sortOrder]];
}

- (void)setupToolbar
{
    UIBarButtonItem *flexibleSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *chooseButton = [[UIBarButtonItem alloc] initWithTitle:AKLocalizedString(@"ak.alfresco.node.picking.list.view.controller", @"Choose") style:UIBarButtonItemStylePlain target:self action:@selector(chooseButtonSelected:)];
    
    self.toolbarItems = @[flexibleSpacer, chooseButton, flexibleSpacer];
}

- (void)chooseButtonSelected:(id)sender
{
    [self.delegate localFileViewController:self didSelectFolderURL:self.url];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableViewData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AKNodeCellIdentifier";
    AKAlfrescoNodeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[[NSBundle alfrescoKitBundle] loadNibNamed:NSStringFromClass([AKAlfrescoNodeCell class]) owner:self options:nil] lastObject];
    }
    
    // customise cell
    NSURL *currentURL = self.tableViewData[indexPath.row];
    [cell updateCellWithURL:currentURL];
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.mode == AKLocalFileControllerTypeFilePicker)
    {
        NSString *selectedPath = self.tableViewData[indexPath.row];
        
        [self.delegate localFileViewController:self didSelectDocumentURLPaths:@[selectedPath]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AKAlfrescoNodeCell *cell = (AKAlfrescoNodeCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height;
}

@end
