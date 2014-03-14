/*
 ******************************************************************************
 * Copyright (C) 2005-2014 Alfresco Software Limited.
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
#import "AlfrescoListingFilter.h"

/** The AlfrescoListingContext can be used to specify paging and filter values.
 If not provided maximum items will default to 50 and skip count will default to 0.
 
 Author: Gavin Cornwell (Alfresco), Tijs Rademakers (Alfresco), Peter Schmidt (Alfresco)
 */

@interface AlfrescoListingContext : NSObject <NSCoding>


/// Returns the sorting field for the list.
@property (nonatomic, strong, readonly) NSString *sortProperty;


/// Returns the sorting direction.
@property (nonatomic, assign, readonly) BOOL sortAscending;


/// Returns the maximum items within the list.
@property (nonatomic, assign, readonly) int maxItems;


/// Returns current skip count.
@property (nonatomic, assign, readonly) int skipCount;


/// Returns the listing filter.
@property (nonatomic, strong, readonly) AlfrescoListingFilter *listingFilter;

/**
 Creates and returns a listing context with a maximum number of items.
 
 @param maxItems The maximum number of items to be returned, 0 or -1 will be interpreted as all items.
 */
- (id)initWithMaxItems:(int)maxItems;

/**
 Creates and returns a listing context with a maximum number of items after skipping the given number of items.
 
 @param maxItems The maximum number of items to be returned, 0 or -1 will be interpreted as all items.
 @param skipCount The number of items to skip before results are returned.
 */
- (id)initWithMaxItems:(int)maxItems skipCount:(int)skipCount;

/**
 Creates and returns a listing context with sorted items.
 
 @param sortProperty A string indicating which value should be used for sorting. A nil string (or invalid string) will result in default sorting.
 @param sortAscending Determines whether the sorting should be ascending.
 */
- (id)initWithSortProperty:(NSString *)sortProperty sortAscending:(BOOL)sortAscending;

/**
 Creates and returns a listing context with filtered items.
 
 @param listingFilter The filtering that must be applied to the returned items.
 */
- (id)initWithListingFilter:(AlfrescoListingFilter *)listingFilter;

/**
 Creates and returns a listing context with a maximum number of sorted items after skipping the given number of items.
 
 @param maxItems The maximum number of items to be returned, 0 or -1 will be interpreted as all items.
 @param skipCount The number of items to skip before results are returned.
 @param sortProperty A string indicating which value should be used for sorting. A nil string (or invalid string) will result in default sorting.
 @param sortAscending Determines whether the sorting should be ascending.
 */
- (id)initWithMaxItems:(int)maxItems skipCount:(int)skipCount
          sortProperty:(NSString *)sortProperty sortAscending:(BOOL)sortAscending;

/**
 Creates and returns a listing context with a maximum number of sorted and filtered items after skipping the given number of items.

 @param maxItems The maximum number of items to be returned, 0 or -1 will be interpreted as all items.
 @param skipCount The number of items to skip before results are returned.
 @param sortProperty A string indicating which value should be used for sorting. A nil string (or invalid string) will result in default sorting.
 @param sortAscending Determines whether the sorting should be ascending.
 @param listingFilter The filtering that must be applied to the returned items.
 */
- (id)initWithMaxItems:(int)maxItems skipCount:(int)skipCount
          sortProperty:(NSString *)sortProperty sortAscending:(BOOL)sortAscending
         listingFilter:(AlfrescoListingFilter *)listingFilter;

@end
