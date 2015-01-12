//
//  NodePickerViewController.h
//  ListViewSample
//
//  Created by Tauseef Mughal on 09/12/2014.
//  Copyright (c) 2014 Tauseef. All rights reserved.
//

#import "AKAlfrescoNodeListViewController.h"

@class AKAlfrescoNodePickingListViewController;

@protocol AKAlfrescoNodePickingListViewControllerDelegate <NSObject, AKAlfrescoNodeListViewControllerDelegate>

- (void)nodePickingListViewController:(AKAlfrescoNodePickingListViewController *)nodePickingListViewController didSelectNodes:(NSArray *)selectedNodes;

@end

@interface AKAlfrescoNodePickingListViewController : AKAlfrescoNodeListViewController

@property (nonatomic, weak) id<AKAlfrescoNodePickingListViewControllerDelegate> delegate;

- (instancetype)initAlfrescoFolderPickerWithRootFolder:(AlfrescoFolder *)folder
                                         selectedNodes:(NSMutableArray *)selectedNodes
                                              delegate:(id<AKAlfrescoNodePickingListViewControllerDelegate>)delegate
                                               session:(id<AlfrescoSession>)session;

- (instancetype)initAlfrescoFolderPickerWithRootFolder:(AlfrescoFolder *)folder
                                         selectedNodes:(NSMutableArray *)selectedNodes
                                              delegate:(id<AKAlfrescoNodePickingListViewControllerDelegate>)delegate
                                        listingContext:(AlfrescoListingContext *)listingContext
                                               session:(id<AlfrescoSession>)session;

- (instancetype)initAlfrescoDocumentPickerWithRootFolder:(AlfrescoFolder *)folder
                                       multipleSelection:(BOOL)allowMultiple
                                           selectedNodes:(NSMutableArray *)selectedNodes
                                                delegate:(id<AKAlfrescoNodePickingListViewControllerDelegate>)delegate
                                                 session:(id<AlfrescoSession>)session;

- (instancetype)initAlfrescoDocumentPickerWithRootFolder:(AlfrescoFolder *)folder
                                       multipleSelection:(BOOL)allowMultiple
                                           selectedNodes:(NSMutableArray *)selectedNodes
                                                delegate:(id<AKAlfrescoNodePickingListViewControllerDelegate>)delegate
                                          listingContext:(AlfrescoListingContext *)listingContext
                                                 session:(id<AlfrescoSession>)session;

@end
