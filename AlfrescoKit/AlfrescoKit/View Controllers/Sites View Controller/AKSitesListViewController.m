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

#import "AKSitesListViewController.h"
#import "AKSitesCell.h"

typedef NS_ENUM(NSUInteger, AKSitesType)
{
    AKSitesTypeFavourites = 0,
    AKSitesTypeMySites,
    AKSitesTypeAllSites
};

@interface AKSitesListViewController ()

// Views
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentControl;
// Data Structure
@property (nonatomic, strong) NSMutableArray *sitesArray;
@property (nonatomic, strong) AlfrescoListingContext *listingContext;
@property (nonatomic, assign) BOOL moreItemsAvailable;
@property (nonatomic, strong) id<AlfrescoSession> session;
// Services
@property (nonatomic, strong) AlfrescoSiteService *siteService;

@end

@implementation AKSitesListViewController

- (instancetype)initWithSession:(id<AlfrescoSession>)session
{
    return [self initWithListingContext:nil session:session];
}

- (instancetype)initWithSession:(id<AlfrescoSession>)session delegate:(id<AKSitesListViewControllerDelegate>)delegate
{
    return [self initWithListingContext:nil delegate:delegate session:session];
}

- (instancetype)initWithListingContext:(AlfrescoListingContext *)listingContext session:(id<AlfrescoSession>)session
{
    return [self initWithListingContext:listingContext delegate:nil session:session];
}

- (instancetype)initWithListingContext:(AlfrescoListingContext *)listingContext delegate:(id<AKSitesListViewControllerDelegate>)delegate session:(id<AlfrescoSession>)session
{
    self = [self init];
    if (self)
    {
        self.sitesArray = [NSMutableArray array];
        self.listingContext = listingContext;
        if (!listingContext)
        {
            self.listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:kMaximumItemsToRetrieveAtOneTime];
        }
        self.delegate = delegate;
        self.session = session;
        [self createServicesWithSession:session];
        self.title = AKLocalizedString(@"ak.sites.view.controller.title", @"Sites Title");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    [self.segmentControl setTitle:AKLocalizedString(@"ak.sites.view.controller.segment.control.mysites", @"My Sites") forSegmentAtIndex:AKSitesTypeMySites];
    [self.segmentControl setTitle:AKLocalizedString(@"ak.sites.view.controller.segment.control.favourites", @"Favourite Sites") forSegmentAtIndex:AKSitesTypeFavourites];
    [self.segmentControl setTitle:AKLocalizedString(@"ak.sites.view.controller.segment.control.allsites", @"All Sites") forSegmentAtIndex:AKSitesTypeAllSites];
    
    [self loadSitesForType:AKSitesTypeFavourites listingContext:nil appendingToCurrentDataSet:NO];
}

#pragma mark - Private Methods

- (void)createServicesWithSession:(id<AlfrescoSession>)session
{
    self.siteService = [[AlfrescoSiteService alloc] initWithSession:session];
}

- (AlfrescoRequest *)loadSitesForType:(AKSitesType)siteType listingContext:(AlfrescoListingContext *)listingContext appendingToCurrentDataSet:(BOOL)append
{
    __block AlfrescoRequest *loadRequest = nil;
    
    if (!listingContext)
    {
        listingContext = self.listingContext;
    }
    
    __weak typeof(self) weakSelf = self;
    void (^reloadBlock)(AlfrescoPagingResult *pagingResult, NSError *pagingError) = ^(AlfrescoPagingResult *pagingResult, NSError *pagingError) {
        if (!append)
        {
            [weakSelf.delegate controller:weakSelf didCompleteRequest:loadRequest error:pagingError];
        }
        
        if (pagingError)
        {
            // handle error
        }
        else
        {
            if (append)
            {
                [weakSelf.sitesArray addObjectsFromArray:pagingResult.objects];
                [weakSelf.tableView reloadData];
            }
            else
            {
                [weakSelf.sitesArray removeAllObjects];
                [weakSelf.sitesArray addObjectsFromArray:pagingResult.objects];
                [weakSelf.tableView reloadData];
            }
            
            weakSelf.moreItemsAvailable = pagingResult.hasMoreItems;
            weakSelf.tableView.tableFooterView = nil;
        }
    };
    
    switch (siteType)
    {
        case AKSitesTypeMySites:
        {
            loadRequest = [self.siteService retrieveSitesWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
                reloadBlock(pagingResult, error);
            }];
        }
        break;
            
        case AKSitesTypeFavourites:
        {
            loadRequest = [self.siteService retrieveFavoriteSitesWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
                reloadBlock(pagingResult, error);
            }];
        }
        break;
            
        case AKSitesTypeAllSites:
        {
            loadRequest = [self.siteService retrieveAllSitesWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
                reloadBlock(pagingResult, error);
            }];
        }
        break;
            
        default:
            break;
    }
    
    if (!append && (loadRequest && !loadRequest.isCancelled))
    {
        [self.delegate controller:self didStartRequest:loadRequest];
    }
    
    return loadRequest;
}

#pragma mark - Public Methods

- (void)updateSession:(id<AlfrescoSession>)session
{
    self.session = session;
    [self createServicesWithSession:session];
}

#pragma mark - IBActions

- (IBAction)didChangeSegementTab:(id)sender
{
    UISegmentedControl *segmentControl = (UISegmentedControl *)sender;
    
    AKSitesType selectedSiteType = segmentControl.selectedSegmentIndex;
    
    [self loadSitesForType:selectedSiteType listingContext:self.listingContext appendingToCurrentDataSet:NO];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sitesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AKSitesCell";
    AKSitesCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = (AKSitesCell *)[[[NSBundle alfrescoKitBundle] loadNibNamed:NSStringFromClass([AKSitesCell class]) owner:self options:nil] lastObject];
    }
    
    AlfrescoSite *currentSite = self.sitesArray[indexPath.row];
    cell.siteImageView.image = [UIImage imageFromAlfrescoKitBundleNamed:@"small_site"];
    cell.siteTextLabel.text = currentSite.title;
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AlfrescoSite *selectedSite = self.sitesArray[indexPath.row];
    
    __weak typeof(self) weakSelf = self;
    __block AlfrescoRequest *request = nil;
    request = [self.siteService retrieveDocumentLibraryFolderForSite:selectedSite.shortName completionBlock:^(AlfrescoFolder *folder, NSError *error) {
        [weakSelf.delegate controller:weakSelf didCompleteRequest:request error:error];
        [weakSelf.delegate sitesListViewController:weakSelf didSelectSite:selectedSite documentLibraryFolder:folder error:error];
    }];
    
    if (!request.isCancelled)
    {
        [self.delegate controller:self didStartRequest:request];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.listingContext)
    {
        // the last row index of the table data
        NSUInteger lastSiteRowIndex = self.sitesArray.count - 1;
        
        // if the last cell is about to be drawn, check if there are more
        if (indexPath.row == lastSiteRowIndex)
        {
            AlfrescoListingContext *moreListingContext = [[AlfrescoListingContext alloc] initWithMaxItems:self.listingContext.maxItems skipCount:[@(self.sitesArray.count) intValue]];
            if (self.moreItemsAvailable)
            {
                // show more items are loading ...
                UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [spinner startAnimating];
                self.tableView.tableFooterView = spinner;
                
                [self loadSitesForType:self.segmentControl.selectedSegmentIndex listingContext:moreListingContext appendingToCurrentDataSet:YES];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AKSitesCell *cell = (AKSitesCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height;
}

@end
