/*******************************************************************************
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
 ******************************************************************************/

#import "AlfrescoListingContext.h"

#define DEFAULTMAXITEMS 50
#define DEFAULTSKIPCOUNT 0

static NSInteger kListingContextModelVersion = 1;

@implementation AlfrescoListingContext

- (id)init
{
    return [self initWithMaxItems:DEFAULTMAXITEMS skipCount:DEFAULTSKIPCOUNT
                     sortProperty:nil sortAscending:YES listingFilter:nil];
}

- (id)initWithMaxItems:(int)maxItems
{
    return [self initWithMaxItems:maxItems skipCount:DEFAULTSKIPCOUNT
                     sortProperty:nil sortAscending:YES listingFilter:nil];
}


- (id)initWithMaxItems:(int)maxItems skipCount:(int)skipCount
{
    return [self initWithMaxItems:maxItems skipCount:skipCount
                     sortProperty:nil sortAscending:YES listingFilter:nil];
}

- (id)initWithSortProperty:(NSString *)sortProperty sortAscending:(BOOL)sortAscending
{
    return [self initWithMaxItems:DEFAULTMAXITEMS skipCount:DEFAULTSKIPCOUNT
                     sortProperty:sortProperty sortAscending:sortAscending listingFilter:nil];
}

- (id)initWithListingFilter:(AlfrescoListingFilter *)listingFilter
{
    return [self initWithMaxItems:DEFAULTMAXITEMS skipCount:DEFAULTSKIPCOUNT
                     sortProperty:nil sortAscending:YES listingFilter:listingFilter];
}

- (id)initWithMaxItems:(int)maxItems skipCount:(int)skipCount
          sortProperty:(NSString *)sortProperty sortAscending:(BOOL)sortAscending
{
    return [self initWithMaxItems:maxItems skipCount:skipCount
                     sortProperty:sortProperty sortAscending:sortAscending listingFilter:nil];
}

- (id)initWithMaxItems:(int)maxItems skipCount:(int)skipCount
          sortProperty:(NSString *)sortProperty sortAscending:(BOOL)sortAscending
         listingFilter:(AlfrescoListingFilter *)listingFilter
{
    self = [super init];
    if (self)
    {
        self.sortProperty = sortProperty;
        self.maxItems = DEFAULTMAXITEMS;
        self.skipCount = DEFAULTSKIPCOUNT;
        if (maxItems > 0 || maxItems == -1)
        {
            self.maxItems = maxItems;
        }
        if (skipCount >= 0)
        {
            self.skipCount = skipCount;
        }
        self.sortAscending = sortAscending;
        
        if (listingFilter != nil)
        {
            self.listingFilter = listingFilter;
        }
        else
        {
            self.listingFilter = [AlfrescoListingFilter new];
        }
    }
    return self;
    
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:kListingContextModelVersion forKey:@"AlfrescoListingContext"];
    [aCoder encodeObject:self.sortProperty forKey:@"sortProperty"];
    [aCoder encodeInt:self.maxItems forKey:@"maxItems"];
    [aCoder encodeInt:self.skipCount forKey:@"skipCount"];
    [aCoder encodeBool:self.sortAscending forKey:@"sortAscending"];
    [aCoder encodeObject:self.listingFilter forKey:@"listingFilter"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (nil != self)
    {
        //uncomment this line if you need to check the model version
//        NSInteger version = [aDecoder decodeIntForKey:@"AlfrescoListingContext"];
        self.sortAscending = [aDecoder decodeBoolForKey:@"sortAscending"];
        self.sortProperty = [aDecoder decodeObjectForKey:@"sortProperty"];
        self.maxItems = [aDecoder decodeIntForKey:@"maxItems"];
        self.skipCount = [aDecoder decodeIntForKey:@"skipCount"];
        self.listingFilter = [aDecoder decodeObjectForKey:@"listingFilter"];
    }
    return self;
}


@end
