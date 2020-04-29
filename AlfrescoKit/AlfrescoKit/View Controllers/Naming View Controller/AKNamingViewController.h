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

/** Provides a name entry
 
 Author: Tauseef Mughal (Alfresco)
 */

#import "AKUIViewController.h"

@class AKNamingViewController;

@protocol AKNamingViewControllerDelegate <NSObject>

- (void)namingViewController:(AKNamingViewController *)namingController didEnterName:(NSString *)name userInfo:(id)userInfo;

@end

@interface AKNamingViewController : AKUIViewController

@property (nonatomic, weak) id<AKNamingViewControllerDelegate> delegate;

- (instancetype)initWithURL:(NSURL *)url delegate:(id<AKNamingViewControllerDelegate>)delegate;
- (instancetype)initWithURL:(NSURL *)url delegate:(id<AKNamingViewControllerDelegate>)delegate userInfo:(id)userInfo;

@end
