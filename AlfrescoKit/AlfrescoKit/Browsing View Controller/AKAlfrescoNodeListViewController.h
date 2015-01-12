//
//  BasicListViewController.h
//  ListViewSample
//
//  Created by Tauseef Mughal on 08/12/2014.
//  Copyright (c) 2014 Tauseef. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AlfrescoSDK-iOS/AlfrescoSDK.h>

@class AKAlfrescoNodeListViewController;

@protocol AKAlfrescoNodeListViewControllerDelegate <NSObject>

@optional
- (void)listViewController:(AKAlfrescoNodeListViewController *)listViewController didRetrieveItems:(NSArray *)items;
- (void)listViewController:(AKAlfrescoNodeListViewController *)listViewController didFailToRetrieveItemsWithError:(NSError *)error;

- (void)listViewController:(AKAlfrescoNodeListViewController *)listViewController didSelectAlfrescoDocument:(AlfrescoDocument *)document;

@end

@interface AKAlfrescoNodeListViewController : UIViewController
{
    AlfrescoFolder *_folder;
}

@property (nonatomic, weak) id<AKAlfrescoNodeListViewControllerDelegate> delegate;

- (instancetype)initWithAlfrescoFolder:(AlfrescoFolder *)folder session:(id<AlfrescoSession>)session;
- (instancetype)initWithAlfrescoFolder:(AlfrescoFolder *)folder listingContext:(AlfrescoListingContext *)listingcontext session:(id<AlfrescoSession>)session;

- (void)updateSession:(id<AlfrescoSession>)session;

@end
