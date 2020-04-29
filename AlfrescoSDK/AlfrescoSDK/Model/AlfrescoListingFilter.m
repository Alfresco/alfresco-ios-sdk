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

#import "AlfrescoListingFilter.h"

@interface AlfrescoListingFilter ()
@property (nonatomic, strong, readwrite) NSMutableDictionary *internalFilterDictionary;
@end

@implementation AlfrescoListingFilter

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.internalFilterDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithFilter:(NSString *)filter value:(NSString *)value
{
    self = [self init];
    if (self)
    {
        [self addFilter:filter withValue:value];
    }
    return self;
}

- (NSDictionary *)filters
{
    return [NSDictionary dictionaryWithDictionary:self.internalFilterDictionary];
}

- (void)addFilter:(NSString *)filter withValue:(NSString *)value
{
    [self.internalFilterDictionary setValue:value forKey:filter];
}

- (BOOL)hasFilter:(NSString *)filter
{
    return ([self.internalFilterDictionary objectForKey:filter] != nil);
}

- (NSString *)valueForFilter:(NSString *)filter
{
    return [self.internalFilterDictionary objectForKey:filter];
}

@end
