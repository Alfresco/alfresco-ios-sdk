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

#import "AKScopeItem.h"

@interface AKScopeItem ()

@property (nonatomic, strong, readwrite) NSString *identifier;
@property (nonatomic, strong, readwrite) NSURL *imageURL;
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) id userInfo;

@end

@implementation AKScopeItem

- (instancetype)initWithImageURL:(NSURL *)imageURL name:(NSString *)name
{
    
    return [self initWithIdentifier:nil imageURL:imageURL name:name userInfo:nil];
}

- (instancetype)initWithImageURL:(NSURL *)imageURL name:(NSString *)name userInfo:(id)userInfo
{
    return [self initWithIdentifier:nil imageURL:imageURL name:name userInfo:userInfo];
}

- (instancetype)initWithIdentifier:(NSString *)identifier imageURL:(NSURL *)imageURL name:(NSString *)name
{
    return [self initWithIdentifier:identifier imageURL:imageURL name:name userInfo:nil];
}

- (instancetype)initWithIdentifier:(NSString *)identifier imageURL:(NSURL *)imageURL name:(NSString *)name userInfo:(id)userInfo
{
    self = [self init];
    if (self)
    {
        self.identifier = (identifier) ?: [[NSUUID UUID] UUIDString];
        self.name = name;
        self.imageURL = imageURL;
        self.userInfo = userInfo;
    }
    return self;
}

@end
