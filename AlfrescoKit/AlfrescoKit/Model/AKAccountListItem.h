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

/** AKAccountListItem
 
 Author: Tauseef Mughal (Alfresco)
 */

#import <Foundation/Foundation.h>

@protocol AKUserAccount;

@interface AKAccountListItem : NSObject

@property (nonatomic, strong, readonly) id<AKUserAccount> account;
@property (nonatomic, strong, readonly) NSString *networkIdentifier;
@property (nonatomic, strong, readonly) NSIndexPath *indexPath;


+ (instancetype)itemWithAccount:(id<AKUserAccount>)account networkIdentifier:(NSString *)networkIdentifier indexPath:(NSIndexPath *)indexPath;
- (instancetype)initWithAccount:(id<AKUserAccount>)account networkIdentifier:(NSString *)networkIdentifier indexPath:(NSIndexPath *)indexPath;

@end
