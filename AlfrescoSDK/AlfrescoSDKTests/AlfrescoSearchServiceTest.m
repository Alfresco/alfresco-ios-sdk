/*******************************************************************************
 * Copyright (C) 2005-2013 Alfresco Software Limited.
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

#import "AlfrescoSearchServiceTest.h"
#import "AlfrescoKeywordSearchOptions.h"
#import "AlfrescoSearchLanguage.h"
#import "AlfrescoLog.h"

@interface AlfrescoSearchServiceTest ()
+ (BOOL)containsTestFile:(NSString *)name array:(NSArray *)array;

@end

@implementation AlfrescoSearchServiceTest

/*
 */
/*
 @Unique_TCRef 42S0
 */

- (void)testQueryWithKeywords
{
    
    if (self.setUpSuccess)
    {
        if (!self.isCloud)
        {
            self.searchService = [[AlfrescoSearchService alloc] initWithSession:self.currentSession];
            
            AlfrescoKeywordSearchOptions *searchOptions = [[AlfrescoKeywordSearchOptions alloc] init];
            
            // Different search terms are required on the different versions of the OnPremise server, due to known indexing issues
            BOOL isRunningOnVersion3 = (![[[self.currentSession repositoryInfo] capabilities] doesSupportCommentCounts]) ? YES : NO;
            NSString *abbreviatedSearchTerm = nil;
            if (isRunningOnVersion3)
            {
                abbreviatedSearchTerm = @"test";
            }
            else
            {
                abbreviatedSearchTerm = @"test_file";
            }
            
            if([self.testSearchFileName hasSuffix:@".pptx"])
            {
                abbreviatedSearchTerm = [self.testSearchFileName stringByReplacingOccurrencesOfString:@".pptx" withString:@""];
            }
            // search
            [self.searchService searchWithKeywords:abbreviatedSearchTerm options:searchOptions completionBlock:^(NSArray *array, NSError *error)
             {
                 if (nil == array)
                 {
                     self.lastTestSuccessful = NO;
                     self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 }
                 else
                 {
                     STAssertNotNil(array, @"array should not be nil");
                     STAssertTrue(array.count >= 1, @"expected at least 1 search result but got %d",array.count);
                     if(array.count == 0)
                     {
                         self.lastTestSuccessful = NO;
                         self.lastTestFailureMessage = @"No query result";
                     }
                     else
                     {
                         BOOL arrayContainsTestFile = [AlfrescoSearchServiceTest containsTestFile:self.testSearchFileName array:array];
                         AlfrescoLogDebug(@"Search Term: %@", abbreviatedSearchTerm);
                         AlfrescoLogDebug(@"Results array size is: %i, and the first object is: %@", [array count], [[array objectAtIndex:0] name]);
                         STAssertTrue(arrayContainsTestFile, @"the uploaded file should be found and part of the search array");
                         self.lastTestSuccessful = arrayContainsTestFile;
                     }
                 }
                 self.callbackCompleted = YES;
             }];
            
            [self waitUntilCompleteWithFixedTimeInterval];
            STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
        }
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 @Unique_TCRef 43S0
 */
- (void)testQueryWithKeywordsWithPaging
{
    if (self.setUpSuccess)
    {
        if (!self.isCloud)
        {
            self.searchService = [[AlfrescoSearchService alloc] initWithSession:self.currentSession];
            
            AlfrescoKeywordSearchOptions *searchOptions = [[AlfrescoKeywordSearchOptions alloc] initWithFolder:nil includeDescendants:YES];
            
            AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:5 skipCount:0];
            
            // Different search terms are required on the different versions of the OnPremise server, due to known indexing issues
            BOOL isRunningOnVersion3 = (![[[self.currentSession repositoryInfo] capabilities] doesSupportCommentCounts]) ? YES : NO;
            NSString *abbreviatedSearchTerm = nil;
            if (isRunningOnVersion3)
            {
                abbreviatedSearchTerm = @"test";
            }
            else
            {
                abbreviatedSearchTerm = @"test_file";
            }
            
            if([self.testSearchFileName hasSuffix:@".pptx"])
            {
                abbreviatedSearchTerm = [self.testSearchFileName stringByReplacingOccurrencesOfString:@".pptx" withString:@""];
            }
            
            // search
            [self.searchService searchWithKeywords:abbreviatedSearchTerm options:searchOptions
                                    listingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error)
             {
                 
                 if (nil == pagingResult)
                 {
                     self.lastTestSuccessful = NO;
                     self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 }
                 else
                 {
                     STAssertNotNil(pagingResult, @"pagingResult should not be nil");
                     STAssertTrue(pagingResult.objects.count >= 1, @"expected at least 1 search result");
                     STAssertTrue(pagingResult.objects.count > 0, @"number of objects found in current page should be more than 0, but we got %d",pagingResult.objects.count);
                     self.lastTestSuccessful = YES;
                 }
                 self.callbackCompleted = YES;
                 
             }];
            
            [self waitUntilCompleteWithFixedTimeInterval];
            STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
        }
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 @Unique_TCRef 42S0
 */
- (void)testQueryWithKeywordsExact
{
    if (self.setUpSuccess)
    {
        if (!self.isCloud)
        {
            self.searchService = [[AlfrescoSearchService alloc] initWithSession:self.currentSession];
            AlfrescoKeywordSearchOptions *searchOptions = [[AlfrescoKeywordSearchOptions alloc] initWithExactMatch:YES includeContent:NO];
            
            // search
            [self.searchService searchWithKeywords:self.testSearchFileName options:searchOptions completionBlock:^(NSArray *array, NSError *error)
             {
                 if (nil == array)
                 {
                     self.lastTestSuccessful = NO;
                     self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 }
                 else
                 {
                     AlfrescoLogDebug(@"search result array contains %d entries", array.count);
                     STAssertNotNil(array, @"array should not be nil");
                     STAssertTrue(array.count >= 1, @"expected at least 1 search results but got %d",array.count);
                     if(array.count == 0)
                     {
                         self.lastTestSuccessful = NO;
                         self.lastTestFailureMessage = @"No query result";
                     }
                     else
                     {
                         BOOL arrayContainsTestFile = [AlfrescoSearchServiceTest containsTestFile:self.testSearchFileName array:array];
                         STAssertTrue(arrayContainsTestFile, @"the uploaded file should be found and part of the search array");
                         
                         self.lastTestSuccessful = arrayContainsTestFile;
                     }
                 }
                 self.callbackCompleted = YES;
                 
             }];
            
            [self waitUntilCompleteWithFixedTimeInterval];
            STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
        }
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 @Unique_TCRef 42S0
 */
- (void)testQueryWithKeywordsExactWithinFolder
{
    if (self.setUpSuccess)
    {
        if (!self.isCloud)
        {
            AlfrescoKeywordSearchOptions *searchOptions = [[AlfrescoKeywordSearchOptions alloc] initWithExactMatch:YES
                                                                                                    includeContent:NO
                                                                                                            folder:self.currentSession.rootFolder
                                                                                                includeDescendants:NO];
            
            self.searchService = [[AlfrescoSearchService alloc] initWithSession:self.currentSession];
            
            
            [self.searchService searchWithKeywords:self.testSearchFileName options:searchOptions completionBlock:^(NSArray *array, NSError *error)
             {
                 if (nil == array)
                 {
                     self.lastTestSuccessful = NO;
                     self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 }
                 else
                 {
                     AlfrescoLogDebug(@"search result array contains %d entries", array.count);
                     STAssertNotNil(array, @"array should not be nil");
                     STAssertTrue(array.count > 0, @"expected >0 search results for OnPremise but got back %d",array.count);
                     self.lastTestSuccessful = YES;
                 }
                 self.callbackCompleted = YES;
                 
             }];
            [self waitUntilCompleteWithFixedTimeInterval];
            STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
        }
        
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 @Unique_TCRef 42S0
 */
- (void)testQueryWithKeywordsFullText
{
    if (self.setUpSuccess)
    {
        if (!self.isCloud)
        {
            AlfrescoKeywordSearchOptions *searchOptions = [[AlfrescoKeywordSearchOptions alloc] initWithExactMatch:NO includeContent:YES];
            
            self.searchService = [[AlfrescoSearchService alloc] initWithSession:self.currentSession];
            
            // search
            
            [self.searchService searchWithKeywords:self.textKeyWord options:searchOptions
                                   completionBlock:^(NSArray *array, NSError *error)
             {
                 if (nil == array)
                 {
                     self.lastTestSuccessful = NO;
                     self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 }
                 else
                 {
                     AlfrescoLogDebug(@"search result array contains %d entries", array.count);
                     STAssertNotNil(array, @"array should not be nil");
                     STAssertTrue(array.count >= 1, @"expected at least 1 search result but got %d",array.count);
                     if(array.count == 0)
                     {
                         self.lastTestSuccessful = NO;
                         self.lastTestFailureMessage = @"No query result";
                     }
                     else
                     {
                         BOOL arrayContainsTestFile = [AlfrescoSearchServiceTest containsTestFile:self.fixedFileName array:array];
                         STAssertTrue(arrayContainsTestFile, @"the uploaded file should be found and part of the search array");
                         
                         self.lastTestSuccessful = arrayContainsTestFile;
                     }
                 }
                 self.callbackCompleted = YES;
                 
             }];
            [self waitUntilCompleteWithFixedTimeInterval];
            STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
        }
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 @Unique_TCRef 42S0
 */
- (void)testQueryWithPlainKeywords
{
    if (self.setUpSuccess)
    {
        if (!self.isCloud)
        {
            self.searchService = [[AlfrescoSearchService alloc] initWithSession:self.currentSession];
            AlfrescoKeywordSearchOptions *searchOptions = [[AlfrescoKeywordSearchOptions alloc] init];
            
            // Different search terms are required on the different versions of the OnPremise server, due to known indexing issues
            BOOL isRunningOnVersion3 = (![[[self.currentSession repositoryInfo] capabilities] doesSupportCommentCounts]) ? YES : NO;
            NSString *abbreviatedSearchTerm = nil;
            if (isRunningOnVersion3)
            {
                abbreviatedSearchTerm = @"test";
            }
            else
            {
                abbreviatedSearchTerm = @"test_file";
            }
            
            if([self.testSearchFileName hasSuffix:@".pptx"])
            {
                abbreviatedSearchTerm = [self.testSearchFileName stringByReplacingOccurrencesOfString:@".pptx" withString:@""];
            }
            
            // search
            [self.searchService searchWithKeywords:abbreviatedSearchTerm options:searchOptions completionBlock:^(NSArray *array, NSError *error)
             {
                 if (nil == array)
                 {
                     self.lastTestSuccessful = NO;
                     self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 }
                 else
                 {
                     AlfrescoLogDebug(@"search result array contains %d entries", array.count);
                     STAssertNotNil(array, @"array should not be nil");
                     STAssertTrue(array.count >= 1, @"expected at least 1 search result but got back %d", array.count);
                     if(array.count == 0)
                     {
                         self.lastTestSuccessful = NO;
                         self.lastTestFailureMessage = @"No query result";
                     }
                     else
                     {
                         BOOL arrayContainsTestFile = [AlfrescoSearchServiceTest containsTestFile:self.testSearchFileName array:array];
                         STAssertTrue(arrayContainsTestFile, @"the uploaded file should be found and part of the search array");
                         
                         self.lastTestSuccessful = arrayContainsTestFile;
                     }
                 }
                 self.callbackCompleted = YES;
                 
             }];
            
            [self waitUntilCompleteWithFixedTimeInterval];
            STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
        }
        
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 @Unique_TCRef 42S0
 */
- (void)testQueryWithPlainKeywordsWithPaging
{
    if (self.setUpSuccess)
    {
        if (!self.isCloud)
        {
            self.searchService = [[AlfrescoSearchService alloc] initWithSession:self.currentSession];
            
            AlfrescoKeywordSearchOptions *searchOptions = [[AlfrescoKeywordSearchOptions alloc] init];
            
            AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:5 skipCount:0];
            
            // Different search terms are required on the different versions of the OnPremise server, due to known indexing issues
            BOOL isRunningOnVersion3 = (![[[self.currentSession repositoryInfo] capabilities] doesSupportCommentCounts]) ? YES : NO;
            NSString *abbreviatedSearchTerm = nil;
            if (isRunningOnVersion3)
            {
                abbreviatedSearchTerm = @"test";
            }
            else
            {
                abbreviatedSearchTerm = @"test_file";
            }
            
            if([self.testSearchFileName hasSuffix:@".pptx"])
            {
                abbreviatedSearchTerm = [self.testSearchFileName stringByReplacingOccurrencesOfString:@".pptx" withString:@""];
            }
            
            // search
            [self.searchService searchWithKeywords:abbreviatedSearchTerm options:searchOptions listingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error)
             {
                 
                 if (nil == pagingResult)
                 {
                     self.lastTestSuccessful = NO;
                     self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 }
                 else
                 {
                     AlfrescoLogDebug(@"search result array contains %d entries", pagingResult.objects.count);
                     STAssertNotNil(pagingResult, @"pagingResult should not be nil");
                     STAssertTrue(pagingResult.objects.count >= 1, @"expected at least 1 search result");
                     self.lastTestSuccessful = YES;
                 }
                 self.callbackCompleted = YES;
                 
             }];
            
            [self waitUntilCompleteWithFixedTimeInterval];
            STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
        }
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testKeywordSearchOptionsPropertiesAfterInstantiation
{
    if (self.setUpSuccess)
    {
        AlfrescoKeywordSearchOptions *searchOptions = nil;
        
        searchOptions = [[AlfrescoKeywordSearchOptions alloc] initWithExactMatch:YES includeContent:YES];
        STAssertNotNil(self.currentSession.rootFolder, @"The folder in the search options should not be nil");
        STAssertTrue(searchOptions.exactMatch, @"Expected the exact match to be true");
        STAssertTrue(searchOptions.includeContent, @"Expected the include content property to be true");
        
        searchOptions = [[AlfrescoKeywordSearchOptions alloc] initWithExactMatch:NO includeContent:YES folder:self.currentSession.rootFolder includeDescendants:YES];
        STAssertNotNil(self.currentSession.rootFolder, @"The folder in the search options should not be nil");
        STAssertFalse(searchOptions.exactMatch, @"Expected the exact match to be false");
        STAssertTrue(searchOptions.includeContent, @"Expected the include content to be true");
        STAssertTrue([searchOptions.folder isEqual:self.currentSession.rootFolder], @"Expected the folder to be that of the the sessions root folder");
        STAssertTrue(searchOptions.includeDescendants, @"Expected the include descendants property to be true");
        
        searchOptions = [[AlfrescoKeywordSearchOptions alloc] initWithFolder:self.currentSession.rootFolder includeDescendants:NO];
        STAssertNotNil(self.currentSession.rootFolder, @"The folder in the search options should not be nil");
        STAssertTrue([searchOptions.folder isEqual:self.currentSession.rootFolder], @"Expected the folder to be that of the the sessions root folder");
        STAssertFalse(searchOptions.includeDescendants, @"Expected the include descendants property to be true");
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 @Unique_TCRef 40S4
 */
- (void)testSearchWithStatementWithoutListingContext
{
    if (self.setUpSuccess)
    {
        if (!self.isCloud)
        {
            self.searchService = [[AlfrescoSearchService alloc] initWithSession:self.currentSession];
            
            NSString *searchStatement = [NSString stringWithFormat:@"SELECT * FROM cmis:document WHERE cmis:name = '%@'", self.fixedFileName];
            
            [self.searchService searchWithStatement:searchStatement language:AlfrescoSearchLanguageCMIS completionBlock:^(NSArray *resultsArray, NSError *error) {
                
                if (resultsArray == nil)
                {
                    self.lastTestSuccessful = NO;
                    self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                }
                else
                {
                    STAssertNotNil(resultsArray, @"The results array returned was nil");
                    STAssertTrue([resultsArray count] >= 1, @"Expected the results array to have atleast one result, instead got back %i", [resultsArray count]);
                    
                    self.lastTestSuccessful = YES;
                }
                self.callbackCompleted = YES;
            }];
            
            [self waitUntilCompleteWithFixedTimeInterval];
            STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
        }
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 @Unique_TCRef 40S5
 */
- (void)testSearchWithStatementWithListingContext
{
    if (self.setUpSuccess)
    {
        if (!self.isCloud)
        {
            self.searchService = [[AlfrescoSearchService alloc] initWithSession:self.currentSession];
            
            AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:5 skipCount:0];
            
            NSString *searchStatement = @"SELECT * FROM cmis:document";
            
            [self.searchService searchWithStatement:searchStatement language:AlfrescoSearchLanguageCMIS listingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
                
                if (pagingResult == nil)
                {
                    self.lastTestSuccessful = NO;
                    self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                }
                else
                {
                    STAssertNotNil(pagingResult, @"Paging result was nil");
                    STAssertTrue([pagingResult.objects count] >= 1, @"Expected the results to contain atleast one result, but instead got back %i", [pagingResult.objects count]);
                    
                    if (pagingResult.hasMoreItems)
                    {
                        STAssertTrue([pagingResult.objects count] == 25, @"Expected the objects array to contain 25 objects, instead we got back %i", [pagingResult.objects count]);
                    }
                    else
                    {
                        STAssertTrue([pagingResult.objects count] <= 25, @"Expected back less than or upto 25 items in the search result, instead got back %i", [pagingResult.objects count]);
                    }
                    
                    self.lastTestSuccessful = YES;
                }
                self.callbackCompleted = YES;
            }];
            
            [self waitUntilCompleteWithFixedTimeInterval];
            STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
        }
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

#pragma private methods

+ (BOOL)containsTestFile:(NSString *)name array:(NSArray *)array
{
    for (AlfrescoNode *node in array)
    {
        NSString *nodeName = node.name;
        if ([name isEqualToString:nodeName])
        {
            return YES;
        }
    }    
    return NO;
}


@end
