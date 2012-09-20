/*******************************************************************************
 * Copyright (C) 2005-2012 Alfresco Software Limited.
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
 ******************************************************************************/

#import <Foundation/Foundation.h>

/** The AlfrescoListingContext can be used to specify paging values.
 
 Author: Gavin Cornwell (Alfresco), Tijs Rademakers (Alfresco)
 */

@interface AlfrescoListingContext : NSObject


/// Returns the sorting field for the list.
@property (nonatomic, strong, readonly) NSString *sortProperty;


/// Returns the sorting direction.
@property (nonatomic, assign, readonly) BOOL sortAscending;


/// Returns the maximum items within the list.
@property (nonatomic, assign, readonly) int maxItems;


/// Returns current skip count.
@property (nonatomic, assign, readonly) int skipCount;

- (id)initWithMaxItems:(int)maxItems skipCount:(int)skipCount;

- (id)initWithMaxItems:(int)maxItems skipCount:(int)skipCount sortProperty:(NSString *)sortProperty sortAscending:(BOOL)sortAscending;

- (id)initWithSortProperty:(NSString *)sortProperty sortAscending:(BOOL)sortAscending;

@end
