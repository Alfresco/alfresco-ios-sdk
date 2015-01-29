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

#import "AKAlfrescoNodeListViewController.h"
#import "AKAlfrescoNodeCell.h"

static NSUInteger const kMaximumSitesToRetrieveAtOneTime = 50;

@interface AKAlfrescoNodeListViewController () <UITableViewDelegate, UITableViewDataSource>

// Views
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
// Data Structure
@property (nonatomic, strong, readwrite) AlfrescoFolder *folder;
@property (nonatomic, strong) NSMutableArray *tableViewData;
@property (nonatomic, strong) AlfrescoListingContext *listingContext;
@property (nonatomic, strong) id<AlfrescoSession> session;
@property (nonatomic, weak) AlfrescoRequest *currentRequest;
@property (nonatomic, assign) BOOL moreItemsAvailable;
// Services
@property (nonatomic, strong) AlfrescoDocumentFolderService *documentService;

@end

@implementation AKAlfrescoNodeListViewController

- (instancetype)initWithAlfrescoFolder:(AlfrescoFolder *)folder delegate:(id<AKAlfrescoNodeListViewControllerDelegate>)delegate session:(id<AlfrescoSession>)session
{
    return [self initWithAlfrescoFolder:folder listingContext:nil delegate:delegate session:session];
}

- (instancetype)initWithAlfrescoFolder:(AlfrescoFolder *)folder listingContext:(AlfrescoListingContext *)listingContext delegate:(id<AKAlfrescoNodeListViewControllerDelegate>)delegate session:(id<AlfrescoSession>)session
{
    self = [self init];
    if (self)
    {
        self.folder = folder;
        self.listingContext = listingContext;
        if (!listingContext)
        {
            self.listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:kMaximumSitesToRetrieveAtOneTime];
        }
        self.session = session;
        self.tableViewData = [NSMutableArray array];
        self.delegate = delegate;
        [self createServicesForSession:session];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Retreive initial data
    if (self.folder)
    {
        self.currentRequest = [self retrieveChildrenForFolder:self.folder listingContext:self.listingContext appendingToCurrentDataSet:NO];
    }
    else
    {
        __weak typeof(self) weakSelf = self;
        __block AlfrescoRequest *request = nil;
        request = [self retrieveRootFolderWithCompletionBlock:^(AlfrescoFolder *rootFolder, NSError *rootError) {
            [weakSelf.delegate controller:weakSelf didCompleteRequest:request error:rootError];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (rootError)
                {
                    if ([weakSelf.delegate respondsToSelector:@selector(listViewController:didFailToRetrieveItemsWithError:)])
                    {
                        [weakSelf.delegate listViewController:weakSelf didFailToRetrieveItemsWithError:rootError];
                    }
                }
                else
                {
                    weakSelf.folder = rootFolder;
                    weakSelf.currentRequest = [weakSelf retrieveChildrenForFolder:weakSelf.folder listingContext:self.listingContext appendingToCurrentDataSet:NO];
                }
            });
        }];
        [self.delegate controller:self didStartRequest:request];
        self.currentRequest = request;
    }
}

- (void)dealloc
{
    [self.currentRequest cancel];
}

#pragma mark - Getters and Setters

- (void)setFolder:(AlfrescoFolder *)folder
{
    _folder = folder;
    self.title = folder.name;
}

#pragma mark - Private Methods

- (void)createServicesForSession:(id<AlfrescoSession>)session
{
    self.documentService = [[AlfrescoDocumentFolderService alloc] initWithSession:session];
}

- (AlfrescoRequest *)retrieveRootFolderWithCompletionBlock:(void (^)(AlfrescoFolder *rootFolder, NSError *rootError))completionBlock
{
    return [self.documentService retrieveRootFolderWithCompletionBlock:completionBlock];
}

- (AlfrescoRequest *)retrieveChildrenForFolder:(AlfrescoFolder *)folder listingContext:(AlfrescoListingContext *)listingContext appendingToCurrentDataSet:(BOOL)append
{
    __weak typeof(self) weakSelf = self;
    __block AlfrescoRequest *request = nil;
    if (listingContext)
    {
        request = [self.documentService retrieveChildrenInFolder:folder listingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
            [weakSelf.delegate controller:self didCompleteRequest:request error:error];
            if (error)
            {
                if ([weakSelf.delegate respondsToSelector:@selector(listViewController:didFailToRetrieveItemsWithError:)])
                {
                    [weakSelf.delegate listViewController:weakSelf didFailToRetrieveItemsWithError:error];
                }
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
                
                if ([weakSelf.delegate respondsToSelector:@selector(listViewController:didRetrieveItems:)])
                {
                    [weakSelf.delegate listViewController:weakSelf didRetrieveItems:pagingResult.objects];
                }
            }
        }];
    }
    else
    {
        request = [self.documentService retrieveChildrenInFolder:folder completionBlock:^(NSArray *array, NSError *error) {
            [weakSelf.delegate controller:self didCompleteRequest:request error:error];
            if (error)
            {
                if ([weakSelf.delegate respondsToSelector:@selector(listViewController:didFailToRetrieveItemsWithError:)])
                {
                    [weakSelf.delegate listViewController:weakSelf didFailToRetrieveItemsWithError:error];
                }
            }
            else
            {
                if (append)
                {
                    [weakSelf.tableViewData addObjectsFromArray:array];
                    [weakSelf.tableView reloadData];
                }
                else
                {
                    [weakSelf.tableViewData removeAllObjects];
                    [weakSelf.tableViewData addObjectsFromArray:array];
                    [weakSelf.tableView reloadData];
                }
                
                weakSelf.moreItemsAvailable = NO;
                
                if ([weakSelf.delegate respondsToSelector:@selector(listViewController:didRetrieveItems:)])
                {
                    [weakSelf.delegate listViewController:weakSelf didRetrieveItems:array];
                }
            }
        }];
    }
    
    [self.delegate controller:self didStartRequest:request];
    
    return request;
}

#pragma mark - Public Methods

- (void)updateSession:(id<AlfrescoSession>)session
{
    self.session = session;
    [self createServicesForSession:session];
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
    
    if ([currentNode isKindOfClass:[AlfrescoFolder class]])
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AlfrescoNode *selectedNode = self.tableViewData[indexPath.row];
    
    if ([selectedNode isKindOfClass:[AlfrescoFolder class]])
    {
        AKAlfrescoNodeListViewController *basicViewController = [[AKAlfrescoNodeListViewController alloc] initWithAlfrescoFolder:(AlfrescoFolder *)selectedNode listingContext:self.listingContext delegate:self.delegate session:self.session];
        [self.navigationController pushViewController:basicViewController animated:YES];
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(listViewController:didSelectAlfrescoDocument:)])
        {
            [self.delegate listViewController:self didSelectAlfrescoDocument:(AlfrescoDocument *)selectedNode];
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
                
                [self retrieveChildrenForFolder:self.folder listingContext:moreListingContext appendingToCurrentDataSet:YES];
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

@end
