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

#import <Foundation/Foundation.h>

/** AlfrescoListingFilter can be used to filter results.
 
 Author: Gavin Cornwell (Alfresco)
 */

@interface AlfrescoListingFilter : NSObject

/// Returns the current set of filters
@property (nonatomic, strong, readonly) NSDictionary *filters;

/**
 Initialises an empty listing filter
 */
- (instancetype)init;

/**
 Initialises a listing filter with a single filter.
 
 @param filter The name for the filter
 @param value The value of the filter
 */
- (instancetype)initWithFilter:(NSString *)filter value:(NSString *)value;

/** Adds a filter
 
 @param filter The name for the filter
 @param withValue The value of the filter
 */
- (void)addFilter:(NSString *)filter withValue:(NSString *)value;

/** Determines whether a filter exists
 
 @param filter The name of the filter to look for
 */
- (BOOL)hasFilter:(NSString *)filter;

/** Returns the value for the given filter, returns nil if the filter does not exist
 
 @param filter The name of the filter to get the value for
 */
- (NSString *)valueForFilter:(NSString *)filter;

@end
