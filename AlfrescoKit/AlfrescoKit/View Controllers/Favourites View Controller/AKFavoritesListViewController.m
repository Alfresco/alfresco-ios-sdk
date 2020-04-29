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

#import "AKFavoritesListViewController.h"
#import "AKConstants.h"
#import "AKAlfrescoNodeCell.h"
#import "AKAlfrescoNodePickingListViewController.h"

@interface AKFavoritesListViewController () <UITableViewDataSource, UITableViewDelegate, AKAlfrescoNodePickingListViewControllerDelegate>
// Views
@property (nonatomic, weak) IBOutlet UITableView *tableView;
// Data Structure
@property (nonatomic, assign) AKFavoritesControllerType mode;
@property (nonatomic, strong) NSMutableArray *tableViewData;
@property (nonatomic, strong) id<AlfrescoSession> session;
@property (nonatomic, strong) AlfrescoListingContext *listingContext;
@property (nonatomic, assign) BOOL moreItemsAvailable;
// Services
@property (nonatomic, strong) AlfrescoDocumentFolderService *documentService;
@end

@implementation AKFavoritesListViewController

- (instancetype)initWithMode:(AKFavoritesControllerType)mode delegate:(id<AKFavoritesListViewControllerDelegate>)delegate session:(id<AlfrescoSession>)session
{
    return [self initWithMode:mode listingContext:nil delegate:delegate session:session];
}

- (instancetype)initWithMode:(AKFavoritesControllerType)mode listingContext:(AlfrescoListingContext *)listingContext delegate:(id<AKFavoritesListViewControllerDelegate>)delegate session:(id<AlfrescoSession>)session
{
    self = [self init];
    if (self)
    {
        self.mode = mode;
        self.delegate = delegate;
        self.session = session;
        self.listingContext = listingContext;
        if (!listingContext)
        {
            self.listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:kMaximumItemsToRetrieveAtOneTime];
        }
        [self createServicesWithSession:session];
        self.tableViewData = [NSMutableArray array];
        self.title = AKLocalizedString(@"ak.favourites.list.view.controller.title", @"Favourites Title");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.mode == AKFavoritesControllerTypeFolderPicker)
    {
        self.navigationController.toolbarHidden = NO;
    }
    
    [self retrieveFavouritesWithListingContext:self.listingContext appendingToCurrentDataSet:NO];
}

#pragma mark - Private Methods

- (void)createServicesWithSession:(id<AlfrescoSession>)session
{
    self.documentService = [[AlfrescoDocumentFolderService alloc] initWithSession:session];
}

- (AlfrescoRequest *)retrieveFavouritesWithListingContext:(AlfrescoListingContext *)listingContext appendingToCurrentDataSet:(BOOL)append
{
    __weak typeof(self) weakSelf = self;
    __block AlfrescoRequest *request = nil;
    request = [self.documentService retrieveFavoriteNodesWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
        [weakSelf.delegate controller:weakSelf didCompleteRequest:request error:error];
        if (error)
        {
            // TODO: Handle error
        }
        else
        {
            if (append)
            {
                [weakSelf.tableViewData addObjectsFromArray:pagingResult.objects];
                [weakSelf.tableView reloadData];
            }
            else
            {
                [weakSelf.tableViewData removeAllObjects];
                [weakSelf.tableViewData addObjectsFromArray:pagingResult.objects];
                [weakSelf.tableView reloadData];
            }
            
            weakSelf.moreItemsAvailable = pagingResult.hasMoreItems;
            weakSelf.tableView.tableFooterView = nil;
        }
    }];
    
    if (request && !request.isCancelled)
    {
        [self.delegate controller:self didStartRequest:request];
    }
    
    return request;
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
    AlfrescoNode *currentNode = self.tableViewData[indexPath.row];
    [cell updateCellWithAlfrescoNode:currentNode];
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlfrescoNode *selectedNode = self.tableViewData[indexPath.row];
    
    if (self.mode == AKFavoritesControllerTypeFolderPicker && [selectedNode isKindOfClass:[AlfrescoDocument class]])
    {
        indexPath = nil;
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AlfrescoNode *selectedNode = self.tableViewData[indexPath.row];
    
    if ([selectedNode isKindOfClass:[AlfrescoFolder class]])
    {
        AKAlfrescoNodePickingListViewController *picker = nil;
        if (self.mode == AKFavoritesControllerTypeFilePicker)
        {
            picker = [[AKAlfrescoNodePickingListViewController alloc] initAlfrescoDocumentPickerWithRootFolder:(AlfrescoFolder *)selectedNode
                                                                                             multipleSelection:NO
                                                                                                 selectedNodes:nil
                                                                                                      delegate:self
                                                                                                listingContext:nil
                                                                                                       session:self.session];
        }
        else
        {
            picker = [[AKAlfrescoNodePickingListViewController alloc] initAlfrescoFolderPickerWithRootFolder:(AlfrescoFolder *)selectedNode
                                                                                               selectedNodes:nil
                                                                                                    delegate:self
                                                                                              listingContext:nil
                                                                                                     session:self.session];
        }
        
        [self.navigationController pushViewController:picker animated:YES];
    }
    else
    {
        if (self.mode == AKFavoritesControllerTypeFilePicker)
        {
            [self.delegate favoritesListViewController:self didSelectNodes:@[selectedNode]];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.listingContext)
    {
        // the last row index of the table data
        NSUInteger lastSiteRowIndex = self.tableViewData.count - 1;
        
        // if the last cell is about to be drawn, check if there are more
        if (indexPath.row == lastSiteRowIndex)
        {
            AlfrescoListingContext *moreListingContext = [[AlfrescoListingContext alloc] initWithMaxItems:self.listingContext.maxItems skipCount:[@(self.tableViewData.count) intValue]];
            if (self.moreItemsAvailable)
            {
                // show more items are loading ...
                UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [spinner startAnimating];
                self.tableView.tableFooterView = spinner;
                
                [self retrieveFavouritesWithListingContext:moreListingContext appendingToCurrentDataSet:YES];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AKAlfrescoNodeCell *cell = (AKAlfrescoNodeCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height;
}

#pragma mark - AKAlfrescoNodePickingListViewControllerDelegate Methods

- (void)nodePickingListViewController:(AKAlfrescoNodePickingListViewController *)nodePickingListViewController didSelectNodes:(NSArray *)selectedNodes
{
    [self.delegate favoritesListViewController:self didSelectNodes:selectedNodes];
}

#pragma mark - AKNetworkActivity Methods

- (void)controller:(UIViewController *)controller didStartRequest:(AlfrescoRequest *)request
{
    [self.delegate controller:self didStartRequest:request];
}

- (void)controller:(UIViewController *)controller didCompleteRequest:(AlfrescoRequest *)request error:(NSError *)error
{
    [self.delegate controller:self didCompleteRequest:request error:error];
}

@end
