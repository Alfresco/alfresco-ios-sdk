/*
  Licensed to the Apache Software Foundation (ASF) under one
  or more contributor license agreements.  See the NOTICE file
  distributed with this work for additional information
  regarding copyright ownership.  The ASF licenses this file
  to you under the Apache License, Version 2.0 (the
  "License"); you may not use this file except in compliance
  with the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an
  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  KIND, either express or implied.  See the License for the
  specific language governing permissions and limitations
  under the License.
 */

#import "CMISPagedResult.h"
#import "CMISErrors.h"

/**
 * Implementation of the wrapper class for the returned results
 */
@implementation CMISFetchNextPageBlockResult


@end

/**
 * Private interface for CMISPagedResult
 */
@interface CMISPagedResult ()

@property (nonatomic, strong, readwrite) NSArray *resultArray;
@property (readwrite) BOOL hasMoreItems;
@property (readwrite) int numItems;
@property (readwrite) int maxItems;
@property (readwrite) int skipCount;

@property (nonatomic, copy) CMISFetchNextPageBlock fetchNextPageBlock;

@end

/**
 * The implementation of the result when fetching a new page.
 */
@implementation CMISPagedResult



/** Internal init */
- (id)initWithResultArray:(NSArray *)resultArray
 retrievedUsingFetchBlock:(CMISFetchNextPageBlock)fetchNextPageBlock
                 numItems:(int)numItems
             hasMoreItems:(BOOL)hasMoreItems
                 maxItems:(int)maxItems
                skipCount:(int)skipCount;
{
    self = [super init];
    if (self) {
        self.resultArray = resultArray;
        self.fetchNextPageBlock = fetchNextPageBlock;
        self.hasMoreItems = hasMoreItems;
        self.numItems = numItems;
        self.maxItems = maxItems;
        self.skipCount = skipCount;
    }
    return self;
}

+ (void)pagedResultUsingFetchBlock:(CMISFetchNextPageBlock)fetchNextPageBlock
                   limitToMaxItems:(int)maxItems
                startFromSkipCount:(int)skipCount
                   completionBlock:(void (^)(CMISPagedResult *result, NSError *error))completionBlock
{
    // Fetch the first requested page
    fetchNextPageBlock(skipCount, maxItems, ^(CMISFetchNextPageBlockResult *result, NSError *error) {
        if (error) {
            completionBlock(nil, [CMISErrors cmisError:error cmisErrorCode:kCMISErrorCodeRuntime]);
        } else {
            completionBlock([[CMISPagedResult alloc] initWithResultArray:result.resultArray
                                                retrievedUsingFetchBlock:fetchNextPageBlock
                                                                numItems:result.numItems
                                                            hasMoreItems:result.hasMoreItems
                                                                maxItems:maxItems
                                                               skipCount:skipCount],
                            nil);
        }
    });
}

- (void)fetchNextPageWithCompletionBlock:(void (^)(CMISPagedResult *result, NSError *error))completionBlock
{
    [CMISPagedResult pagedResultUsingFetchBlock:self.fetchNextPageBlock
                                limitToMaxItems:self.maxItems
                             startFromSkipCount:(self.skipCount + (int)self.resultArray.count)
                                completionBlock:completionBlock];
}

- (void)enumerateItemsUsingBlock:(void (^)(id object, BOOL *stop))enumerationBlock completionBlock:(void (^)(NSError *error))completionBlock
{
    BOOL stop = NO;
    for (CMISObject *object in self.resultArray) {
        enumerationBlock(object, &stop);
        if (stop) {
            NSError *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeCancelled detailedDescription:@"Item enumeration was stopped"];
            completionBlock(error);
            return;
        }
    }
    // Additional check if call returned any result as server may return hasMoreItems even if there are none; this could result in an endless loop
    if (self.hasMoreItems && [self.resultArray count] > 0) {
        [self fetchNextPageWithCompletionBlock:^(CMISPagedResult *result, NSError *error) {
            if (error) {
                completionBlock(error);
            } else {
                [result enumerateItemsUsingBlock:enumerationBlock completionBlock:completionBlock];
            }
        }];
    } else {
        completionBlock(nil);
    }
}

@end