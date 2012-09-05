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

#import "AlfrescoSearchServiceTest.h"
#import "AlfrescoKeywordSearchOptions.h"
#import "AlfrescoSearchLanguage.h"

@interface AlfrescoSearchServiceTest ()
+ (BOOL)containsTestFile:(NSString *)name array:(NSArray *)array;

@end

@implementation AlfrescoSearchServiceTest

@synthesize searchService = _searchService;
/*
 */
 
- (void)testQueryWithKeywords
{
    [super runAllSitesTest:^{
        
        self.searchService = [[AlfrescoSearchService alloc] initWithSession:super.currentSession];

        AlfrescoKeywordSearchOptions *searchOptions = [[AlfrescoKeywordSearchOptions alloc] init];
//        searchOptions.exactMatch = NO;
//        searchOptions.includeContent = NO;
//        searchOptions.includeDescendants = YES;

        NSString *abbreviatedSearchTerm = @"test_file";
        if([super.testSearchFileName hasSuffix:@".pptx"])
        {
            abbreviatedSearchTerm = [super.testSearchFileName stringByReplacingOccurrencesOfString:@".pptx" withString:@""];            
        }
        log(@"Searching for name %@",abbreviatedSearchTerm);
        // search
        [self.searchService searchWithKeywords:abbreviatedSearchTerm options:searchOptions completionBlock:^(NSArray *array, NSError *error)
        {
            log(@"ENTERING searchWithKeywords completionBlock");
            if (nil == array)
            {
                log(@"search result array comes back as nil");
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else 
            {
                log(@"search result array contains %d entries", array.count);
                STAssertNotNil(array, @"array should not be nil");
                STAssertTrue(array.count >= 1, @"expected at least 1 search result but got %d",array.count);
                if(array.count == 0)
                {
                    super.lastTestSuccessful = NO;
                    super.lastTestFailureMessage = @"No query result";
                }
                else 
                {
                    BOOL arrayContainsTestFile = [AlfrescoSearchServiceTest containsTestFile:super.testSearchFileName array:array];
                    STAssertTrue(arrayContainsTestFile, @"the uploaded file should be found and part of the search array");
                    super.lastTestSuccessful = arrayContainsTestFile;
                }
            }
            super.callbackCompleted = YES;
            log(@"LEAVING searchWithKeywords completionBlock");
        }];
        
        [super waitForCompletion:20];
        
        // check the test outcome
        STAssertTrue(super.callbackCompleted, @"TIMED OUT: test returned before callback was complete");
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testQueryWithKeywordsWithPaging
{
    [super runAllSitesTest:^{
        
        self.searchService = [[AlfrescoSearchService alloc] initWithSession:super.currentSession];
        
        AlfrescoKeywordSearchOptions *searchOptions = [[AlfrescoKeywordSearchOptions alloc] initWithFolder:nil includeDescendants:YES];
//        searchOptions.exactMatch = NO;
//        searchOptions.includeContent = NO;
//        searchOptions.includeDescendants = YES;
        
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:5 skipCount:0];
        NSString *abbreviatedSearchTerm = @"test_file";
        if([super.testSearchFileName hasSuffix:@".pptx"])
        {
            abbreviatedSearchTerm = [super.testSearchFileName stringByReplacingOccurrencesOfString:@".pptx" withString:@""];
        }
        
        // search
        [self.searchService searchWithKeywords:abbreviatedSearchTerm options:searchOptions
                            listingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) 
        {
            log(@"ENTERING searchWithKeywords completionBlock");
                                
            if (nil == pagingResult) 
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else 
            {
                log(@"search result array contains %d entries", pagingResult.objects.count);
                STAssertNotNil(pagingResult, @"pagingResult should not be nil");
                STAssertTrue(pagingResult.objects.count >= 1, @"expected at least 1 search result");
                STAssertTrue(pagingResult.objects.count > 0, @"number of objects found in current page should be more than 0, but we got %d",pagingResult.objects.count);
                super.lastTestSuccessful = YES;
            }
            super.callbackCompleted = YES;
            log(@"LEAVING searchWithKeywords completionBlock");
            
        }];
        
        [super waitForCompletion:20];
        
        // check the test outcome
        STAssertTrue(super.callbackCompleted, @"TIMED OUT: test returned before callback was complete");
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testQueryWithKeywordsExact
{
    [super runAllSitesTest:^{
        
        self.searchService = [[AlfrescoSearchService alloc] initWithSession:super.currentSession];
        AlfrescoKeywordSearchOptions *searchOptions = [[AlfrescoKeywordSearchOptions alloc] initWithExactMatch:YES includeContent:NO];
//        searchOptions.exactMatch = YES;
//        searchOptions.includeContent = NO;
//        searchOptions.includeDescendants = YES;
        
        // search
        [self.searchService searchWithKeywords:super.testSearchFileName options:searchOptions completionBlock:^(NSArray *array, NSError *error)
        {
            if (nil == array) 
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else 
            {
                log(@"search result array contains %d entries", array.count);
                STAssertNotNil(array, @"array should not be nil");
                STAssertTrue(array.count >= 1, @"expected at least 1 search results but got %d",array.count);
                if(array.count == 0)
                {
                    super.lastTestSuccessful = NO;
                    super.lastTestFailureMessage = @"No query result";
                }
                else 
                {
                    BOOL arrayContainsTestFile = [AlfrescoSearchServiceTest containsTestFile:super.testSearchFileName array:array];
                    STAssertTrue(arrayContainsTestFile, @"the uploaded file should be found and part of the search array");
                    
                    super.lastTestSuccessful = arrayContainsTestFile;
                }
            }
            super.callbackCompleted = YES;
            
        }];
        
        [super waitForCompletion:20];
        
        // check the test outcome
        STAssertTrue(super.callbackCompleted, @"TIMED OUT: test returned before callback was complete");
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testQueryWithKeywordsExactWithinFolder
{
    [super runAllSitesTest:^{
        
        AlfrescoKeywordSearchOptions *searchOptions = [[AlfrescoKeywordSearchOptions alloc] initWithExactMatch:YES
                                                                                                includeContent:NO
                                                                                                        folder:super.currentSession.rootFolder
                                                                                            includeDescendants:NO];
        
//        searchOptions.exactMatch = YES;
//        searchOptions.includeContent = NO;
//        searchOptions.includeDescendants = NO;
//        searchOptions.folder = super.currentSession.rootFolder;
        
        self.searchService = [[AlfrescoSearchService alloc] initWithSession:super.currentSession];
        
        
        [self.searchService searchWithKeywords:super.testSearchFileName options:searchOptions completionBlock:^(NSArray *array, NSError *error)
         {
             if (nil == array) 
             {
                 super.lastTestSuccessful = NO;
                 super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else 
             {
                 log(@"search result array contains %d entries", array.count);
                 STAssertNotNil(array, @"array should not be nil");
                 STAssertTrue(array.count > 0, @"expected >0 search results for OnPremise but got back %d",array.count);
                 super.lastTestSuccessful = YES;
             }
             super.callbackCompleted = YES;
             
         }];
        [super waitForCompletion:20];
        
        // check the test outcome
        STAssertTrue(super.callbackCompleted, @"TIMED OUT: test returned before callback was complete");
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testQueryWithKeywordsFullText
{
    [super runAllSitesTest:^{
        
        AlfrescoKeywordSearchOptions *searchOptions = [[AlfrescoKeywordSearchOptions alloc] initWithExactMatch:NO includeContent:YES];
//        searchOptions.exactMatch = NO;
//        searchOptions.includeContent = YES;
//        searchOptions.includeDescendants = YES;
        
        self.searchService = [[AlfrescoSearchService alloc] initWithSession:super.currentSession];
        
        // search
        
        [self.searchService searchWithKeywords:super.textKeyWord options:searchOptions
                               completionBlock:^(NSArray *array, NSError *error) 
         {
             if (nil == array) 
             {
                 super.lastTestSuccessful = NO;
                 super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else 
             {
                 log(@"search result array contains %d entries", array.count);
                 STAssertNotNil(array, @"array should not be nil");
                 STAssertTrue(array.count >= 1, @"expected at least 1 search result but got %d",array.count);
                 if(array.count == 0)
                 {
                     super.lastTestSuccessful = NO;
                     super.lastTestFailureMessage = @"No query result";
                 }
                 else 
                 {
                     BOOL arrayContainsTestFile = [AlfrescoSearchServiceTest containsTestFile:super.testSearchFileName array:array];
                     STAssertTrue(arrayContainsTestFile, @"the uploaded file should be found and part of the search array");
                     
                     super.lastTestSuccessful = arrayContainsTestFile;
                 }
             }
             super.callbackCompleted = YES;
             
         }];
        [super waitForCompletion:20];
        
        // check the test outcome
        STAssertTrue(super.callbackCompleted, @"TIMED OUT: test returned before callback was complete");
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testQueryWithPlainKeywords
{
    [super runAllSitesTest:^{
        
        self.searchService = [[AlfrescoSearchService alloc] initWithSession:super.currentSession];
        AlfrescoKeywordSearchOptions *searchOptions = [[AlfrescoKeywordSearchOptions alloc] init];
        
        NSString *abbreviatedSearchTerm = @"test_file";
        if([super.testSearchFileName hasSuffix:@".pptx"])
        {
            abbreviatedSearchTerm = [super.testSearchFileName stringByReplacingOccurrencesOfString:@".pptx" withString:@""];
        }
        // search
        [self.searchService searchWithKeywords:abbreviatedSearchTerm options:searchOptions completionBlock:^(NSArray *array, NSError *error)
        {
            if (nil == array) 
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else 
            {
                log(@"search result array contains %d entries", array.count);
                STAssertNotNil(array, @"array should not be nil");
                STAssertTrue(array.count >= 1, @"expected at least 1 search result but got back %d", array.count);
                if(array.count == 0)
                {
                    super.lastTestSuccessful = NO;
                    super.lastTestFailureMessage = @"No query result";
                }
                else 
                {
                    BOOL arrayContainsTestFile = [AlfrescoSearchServiceTest containsTestFile:super.testSearchFileName array:array];
                    STAssertTrue(arrayContainsTestFile, @"the uploaded file should be found and part of the search array");
                    
                    super.lastTestSuccessful = arrayContainsTestFile;
                }
            }
            super.callbackCompleted = YES;
            
        }];
        
        [super waitForCompletion:20];
        
        // check the test outcome
        STAssertTrue(super.callbackCompleted, @"TIMED OUT: test returned before callback was complete");
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testQueryWithPlainKeywordsWithPaging
{
    [super runAllSitesTest:^{
        
        self.searchService = [[AlfrescoSearchService alloc] initWithSession:super.currentSession];
        
        AlfrescoKeywordSearchOptions *searchOptions = [[AlfrescoKeywordSearchOptions alloc] init];

        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:5 skipCount:0];
        NSString *abbreviatedSearchTerm = @"test_file";
        if([super.testSearchFileName hasSuffix:@".pptx"])
        {
            abbreviatedSearchTerm = [super.testSearchFileName stringByReplacingOccurrencesOfString:@".pptx" withString:@""];
        }
        
        // search
        [self.searchService searchWithKeywords:abbreviatedSearchTerm options:searchOptions listingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error)
        {
                                
            if (nil == pagingResult) 
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else 
            {
                log(@"search result array contains %d entries", pagingResult.objects.count);
                STAssertNotNil(pagingResult, @"pagingResult should not be nil");
                STAssertTrue(pagingResult.objects.count >= 1, @"expected at least 1 search result");
                if (pagingResult.objects.count > 0)
                {
                    BOOL arrayContainsTestFile = [AlfrescoSearchServiceTest containsTestFile:super.testSearchFileName array:pagingResult.objects];
                    if (arrayContainsTestFile)
                    {
                        log(@"the file was found in the current page");
                    }
                    else
                    {
                        log(@"the file could not be found in the current page");
                    }
                    super.lastTestSuccessful = arrayContainsTestFile;
                }
                else
                {
                    super.lastTestSuccessful = NO;
                    super.lastTestFailureMessage = @"Failed to query with keywords";
                }
            }
            super.callbackCompleted = YES;
            
        }];
        
        [super waitForCompletion:20];
        
        // check the test outcome
        STAssertTrue(super.callbackCompleted, @"TIMED OUT: test returned before callback was complete");
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

#pragma private methods

+ (BOOL)containsTestFile:(NSString *)name array:(NSArray *)array
{
    for (AlfrescoNode *node in array)
    {
        NSString *nodeName = node.name;
        log(@"AlfrescoSearchServiceTest::containsTestFile the name in folder is %@",nodeName);
        if ([name isEqualToString:nodeName])
        {
            return YES;
        }
    }    
    return NO;
}


@end
