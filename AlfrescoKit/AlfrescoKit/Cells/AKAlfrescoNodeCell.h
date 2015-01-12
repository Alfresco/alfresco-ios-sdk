//
//  AKAlfrescoNodeCell.h
//  AlfrescoKit
//
//  Created by Tauseef Mughal on 08/01/2015.
//  Copyright (c) 2015 Alfresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AlfrescoSDK-iOS/AlfrescoSDK.h>

@interface AKAlfrescoNodeCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *nodeImageView;
@property (nonatomic, weak) IBOutlet UILabel *nodeTextLabel;
@property (nonatomic, weak) IBOutlet UILabel *nodeDetailLabel;
@property (nonatomic, weak) IBOutlet UIImageView *nodeSelectedImageView;

- (void)updateCellWithAlfrescoNode:(AlfrescoNode *)node;
- (void)updateCellWithPickedIndicator:(BOOL)picked;

@end
