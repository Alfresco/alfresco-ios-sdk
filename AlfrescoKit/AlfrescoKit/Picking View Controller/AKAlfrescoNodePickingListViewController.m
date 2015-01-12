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

#import "AKAlfrescoNodePickingListViewController.h"
#import "AKAlfrescoNodeCell.h"

typedef NS_OPTIONS(NSUInteger, AKAlfrescoNodePickerType)
{
    AKAlfrescoNodePickerTypeDocumentPicker    = 1 << 0,
    AKAlfrescoNodePickerTypeFolderPicker      = 1 << 1,
    AKAlfrescoNodePickerTypeMultiplePicker    = 1 << 2
};

@interface AKAlfrescoNodePickingListViewController ()

@property (nonatomic, strong) NSMutableArray *tableViewData;
@property (nonatomic, strong) AlfrescoListingContext *listingContext;
@property (nonatomic, strong) NSMutableArray *selectedNodes;
@property (nonatomic, strong) id<AlfrescoSession> session;
@property (nonatomic, assign) AKAlfrescoNodePickerType nodePickerOptions;

@end

@implementation AKAlfrescoNodePickingListViewController

- (instancetype)initAlfrescoFolderPickerWithRootFolder:(AlfrescoFolder *)folder
                                         selectedNodes:(NSMutableArray *)selectedNodes
                                              delegate:(id<AKAlfrescoNodePickingListViewControllerDelegate>)delegate
                                               session:(id<AlfrescoSession>)session
{
    return [self initAlfrescoFolderPickerWithRootFolder:folder selectedNodes:selectedNodes delegate:delegate listingContext:nil session:session];
}

- (instancetype)initAlfrescoFolderPickerWithRootFolder:(AlfrescoFolder *)folder
                                         selectedNodes:(NSMutableArray *)selectedNodes
                                              delegate:(id<AKAlfrescoNodePickingListViewControllerDelegate>)delegate
                                        listingContext:(AlfrescoListingContext *)listingContext
                                               session:(id<AlfrescoSession>)session
{
    self = [self initWithAlfrescoFolder:folder listingContext:listingContext session:session];
    if (self)
    {
        self.nodePickerOptions = AKAlfrescoNodePickerTypeFolderPicker;
        self.delegate = delegate;
        self.selectedNodes = (selectedNodes) ? selectedNodes : [NSMutableArray array];
    }
    return self;
}

- (instancetype)initAlfrescoDocumentPickerWithRootFolder:(AlfrescoFolder *)folder
                                       multipleSelection:(BOOL)allowMultiple
                                           selectedNodes:(NSMutableArray *)selectedNodes
                                                delegate:(id<AKAlfrescoNodePickingListViewControllerDelegate>)delegate
                                                 session:(id<AlfrescoSession>)session
{
    return [self initAlfrescoDocumentPickerWithRootFolder:folder multipleSelection:allowMultiple selectedNodes:selectedNodes delegate:delegate listingContext:nil session:session];
}

- (instancetype)initAlfrescoDocumentPickerWithRootFolder:(AlfrescoFolder *)folder
                                       multipleSelection:(BOOL)allowMultiple
                                           selectedNodes:(NSMutableArray *)selectedNodes
                                                delegate:(id<AKAlfrescoNodePickingListViewControllerDelegate>)delegate
                                          listingContext:(AlfrescoListingContext *)listingContext
                                                 session:(id<AlfrescoSession>)session
{
    self = [self initWithAlfrescoFolder:folder listingContext:listingContext session:session];
    if (self)
    {
        self.nodePickerOptions = AKAlfrescoNodePickerTypeDocumentPicker;
        if (allowMultiple)
        {
            self.nodePickerOptions |= AKAlfrescoNodePickerTypeMultiplePicker;
        }
        self.delegate = delegate;
        self.selectedNodes = (selectedNodes) ? selectedNodes : [NSMutableArray array];
        
    }
    return self;
}

- (NSString *)nibName
{
    return NSStringFromClass([self superclass]);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup the toolbar
    [self setupToolbar];
    // Display the toolbar if required
    BOOL isFolderPicker = self.nodePickerOptions & AKAlfrescoNodePickerTypeFolderPicker;
    BOOL isMultipleDocumentPicker = self.nodePickerOptions & AKAlfrescoNodePickerTypeDocumentPicker && self.nodePickerOptions & AKAlfrescoNodePickerTypeMultiplePicker;
    
    if (isFolderPicker || isMultipleDocumentPicker)
    {
        self.navigationController.toolbarHidden = NO;
    }
}

#pragma mark - Private Methods

- (void)chooseButtonSelected:(id)sender
{
    if (self.nodePickerOptions & AKAlfrescoNodePickerTypeFolderPicker)
    {
        [self.delegate nodePickingListViewController:self didSelectNodes:@[_folder]];
    }
    else if (self.nodePickerOptions & AKAlfrescoNodePickerTypeDocumentPicker)
    {
        if (self.nodePickerOptions & AKAlfrescoNodePickerTypeMultiplePicker)
        {
            [self.delegate nodePickingListViewController:self didSelectNodes:self.selectedNodes];
        }
    }
}

- (void)setupToolbar
{
    UIBarButtonItem *flexibleSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *chooseButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ak.alfresco.node.picking.list.view.controller", @"Choose") style:UIBarButtonItemStylePlain target:self action:@selector(chooseButtonSelected:)];
    
    self.toolbarItems = @[flexibleSpacer, chooseButton, flexibleSpacer];
}

- (void)didFinishSelectingNodes:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(nodePickingListViewController:didSelectNodes:)])
    {
        [self.delegate nodePickingListViewController:self didSelectNodes:self.selectedNodes];
    }
}

- (BOOL)nodeIsCurrentlySelected:(AlfrescoNode *)node
{
    NSArray *selectedNodeIdentifiers = [self.selectedNodes valueForKey:@"identifier"];
    return [selectedNodeIdentifiers containsObject:node.identifier];
}

#pragma mark - UITableViewDataSource Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AKNodeCellIdentifier";
    AKAlfrescoNodeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([AKAlfrescoNodeCell class]) owner:self options:nil] lastObject];
    }
    
    // customise cell
    AlfrescoNode *currentNode = self.tableViewData[indexPath.row];
    [cell updateCellWithAlfrescoNode:currentNode];
    
    BOOL currentNodeIsSelected = [self nodeIsCurrentlySelected:currentNode];
    [cell updateCellWithPickedIndicator:currentNodeIsSelected];
    
    if ([currentNode isKindOfClass:[AlfrescoFolder class]])
    {
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        cell.accessoryView = nil;
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
        AKAlfrescoNodePickingListViewController *basicViewController = nil;
        if ((self.nodePickerOptions & AKAlfrescoNodePickerTypeFolderPicker) != 0)
        {
            basicViewController = [[AKAlfrescoNodePickingListViewController alloc] initAlfrescoFolderPickerWithRootFolder:(AlfrescoFolder *)selectedNode
                                                                                                            selectedNodes:self.selectedNodes
                                                                                                                 delegate:self.delegate
                                                                                                           listingContext:self.listingContext
                                                                                                                  session:self.session];
        }
        else if ((self.nodePickerOptions & AKAlfrescoNodePickerTypeDocumentPicker) != 0)
        {
            BOOL isMultiple = self.nodePickerOptions & AKAlfrescoNodePickerTypeMultiplePicker;
            basicViewController = [[AKAlfrescoNodePickingListViewController alloc] initAlfrescoDocumentPickerWithRootFolder:(AlfrescoFolder *)selectedNode
                                                                                                          multipleSelection:isMultiple
                                                                                                              selectedNodes:self.selectedNodes
                                                                                                                   delegate:self.delegate
                                                                                                             listingContext:self.listingContext
                                                                                                                    session:self.session];
        }
        
        [self.navigationController pushViewController:basicViewController animated:YES];
    }
    else
    {
        if ([self.selectedNodes containsObject:selectedNode])
        {
            [self.selectedNodes removeObject:selectedNode];
        }
        else
        {
            [self.selectedNodes addObject:selectedNode];
        }
        
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        if ((self.nodePickerOptions & AKAlfrescoNodePickerTypeMultiplePicker) == 0)
        {
            [self didFinishSelectingNodes:self.selectedNodes];
        }
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlfrescoNode *willSelectNode = self.tableViewData[indexPath.row];
    
    if ((self.nodePickerOptions & AKAlfrescoNodePickerTypeFolderPicker) != 0)
    {
        if (![willSelectNode isKindOfClass:[AlfrescoFolder class]])
        {
            return nil;
        }
    }
    
    return indexPath;
}

@end
