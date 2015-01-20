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

#import "AKScopePickingViewController.h"
#import "AKScopePickerCell.h"
#import "AKScopeItem.h"

@interface AKScopePickingViewController () <UITableViewDataSource, UITableViewDelegate>

// Views
@property (nonatomic, weak) IBOutlet UITableView *tableView;
// Data Structure
@property (nonatomic, strong) NSArray *scopeItems;

@end

@implementation AKScopePickingViewController

- (instancetype)initWithScopeItems:(NSArray *)scopeItems
{
    return [self initWithScopeItems:scopeItems delegate:nil];
}

- (instancetype)initWithScopeItems:(NSArray *)scopeItems delegate:(id<AKScopePickingViewControllerDelegate>)delegate
{
    self = [self init];
    if (self)
    {
        self.scopeItems = scopeItems;
        self.delegate = delegate;
        self.title = AKLocalizedString(@"ak.scope.picking.view.controller.title", @"Pick Location");
    }
    return self;
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.scopeItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AKScopePickerCell";
    AKScopePickerCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[[NSBundle alfrescoKitBundle] loadNibNamed:NSStringFromClass([AKScopePickerCell class]) owner:self options:nil] lastObject];
    }
    
    AKScopeItem *currentScopeItem = self.scopeItems[indexPath.row];
    
    UIImage *imageForCell = [UIImage imageWithContentsOfFile:currentScopeItem.imageURL.path];
    if (!imageForCell)
    {
        imageForCell = [UIImage imageFromAlfrescoKitBundleNamed:@"small_site"]; // TODO: Replace with a generic image
    }
    
    cell.scopeImageView.image = imageForCell;
    cell.scopeTextLabel.text = currentScopeItem.name;
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AKScopePickerCell *cell = (AKScopePickerCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AKScopeItem *selectedItem = self.scopeItems[indexPath.row];
    [self.delegate scopePickingController:self didSelectScopeItem:selectedItem];
}

@end
