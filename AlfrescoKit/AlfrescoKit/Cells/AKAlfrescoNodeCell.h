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

/** Default representation of an AlfrescoNode in a table view.
 
 Author: Tauseef Mughal (Alfresco)
 */

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
