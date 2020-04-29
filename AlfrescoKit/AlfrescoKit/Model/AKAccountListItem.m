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

#import "AKAccountListItem.h"

@interface AKAccountListItem ()

@property (nonatomic, strong, readwrite) id<AKUserAccount> account;
@property (nonatomic, strong, readwrite) NSString *networkIdentifier;
@property (nonatomic, strong, readwrite) NSIndexPath *indexPath;

@end

@implementation AKAccountListItem

+ (instancetype)itemWithAccount:(id<AKUserAccount>)account networkIdentifier:(NSString *)networkIdentifier indexPath:(NSIndexPath *)indexPath
{
    return [[AKAccountListItem alloc] initWithAccount:account networkIdentifier:networkIdentifier indexPath:indexPath];
}

- (instancetype)initWithAccount:(id<AKUserAccount>)account networkIdentifier:(NSString *)networkIdentifier indexPath:(NSIndexPath *)indexPath
{
    self = [self init];
    if (self)
    {
        self.indexPath = indexPath;
        self.account = account;
        self.networkIdentifier = networkIdentifier;
    }
    return self;
}

@end
