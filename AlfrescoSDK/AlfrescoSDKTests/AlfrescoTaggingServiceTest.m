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

#import "AlfrescoTaggingServiceTest.h"
#import "AlfrescoTag.h"

@implementation AlfrescoTaggingServiceTest

@synthesize taggingService = _taggingService;

/*
 */
/*
 @Unique_TCRef 52S0
 */
- (void)testRetrieveAllTags
{
    [super runAllSitesTest:^{
        
        self.taggingService = [[AlfrescoTaggingService alloc] initWithSession:super.currentSession];
        
        // get tags
        [self.taggingService retrieveAllTagsWithCompletionBlock:^(NSArray *array, NSError *error) 
        {
            if (nil == array) 
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else 
            {
                STAssertTrue(array.count > 0, @"expected tag response");
                for (AlfrescoTag *tag in array)
                {
                    STAssertNotNil(tag.identifier, @"Tag identifier should not be nil");
                    STAssertNotNil(tag.value, @"Tag value should not be nil");
                }
                super.lastTestSuccessful = YES;
            }
            super.callbackCompleted = YES;
        }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

/*
 @Unique_TCRef 53S0
 */
- (void)testRetrieveAllTagsWithPaging
{
    [super runAllSitesTest:^{
        
        self.taggingService = [[AlfrescoTaggingService alloc] initWithSession:super.currentSession];
        
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:2 skipCount:1];
        
        // get tags
        [self.taggingService retrieveAllTagsWithListingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) 
        {
            if (nil == pagingResult) 
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else 
            {
                STAssertNotNil(pagingResult, @"pagingResult should not be nil");
                STAssertTrue(pagingResult.objects.count == 2, @"expected 2 tag responses");
                STAssertTrue(pagingResult.totalItems > 2, @"expected multiple tags in total");
                super.lastTestSuccessful = YES;
            }
            super.callbackCompleted = YES;
        }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

/*
 @Unique_TCRef 54S1
 */
- (void)testRetrieveEmptyTagsForNode
{
    [super runAllSitesTest:^{
        
        self.taggingService = [[AlfrescoTaggingService alloc] initWithSession:super.currentSession];
        
        
        // get tags
        [self.taggingService retrieveTagsForNode:super.testAlfrescoDocument completionBlock:^(NSArray *array, NSError *error)
        {
            if (nil == array) 
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else 
            {
                STAssertTrue(array.count == 0, @"expected no tags for the newly uploaded file, but we got %d ",array.count);
                super.lastTestSuccessful = YES;
            }
            super.callbackCompleted = YES;
        }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}


/*
 @Unique_TCRef 55S1
 */
- (void)testRetrieveEmptyTagsForNodeWithPaging
{
    [super runAllSitesTest:^{
        
        self.taggingService = [[AlfrescoTaggingService alloc] initWithSession:super.currentSession];
        
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:1 skipCount:1];
        
        
        // get tags
        [self.taggingService retrieveTagsForNode:super.testAlfrescoDocument listingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error)
        {
            if (nil == pagingResult) 
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else 
            {
                STAssertNotNil(pagingResult, @"pagingResult should not be nil");
                STAssertTrue(pagingResult.objects.count == 0, @"expected no tag response for newly uploaded file but got %d",pagingResult.objects.count);
                super.lastTestSuccessful = YES;
            }
            super.callbackCompleted = YES;
        }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

/*
 @Unique_TCRef 55S1
 @Unique_TCRef 56S1
 */
- (void)testAddAndRetrieveTags
{
    [super runAllSitesTest:^{
        
        
        self.taggingService = [[AlfrescoTaggingService alloc] initWithSession:super.currentSession];
        __weak AlfrescoTaggingService *weakTaggingService = self.taggingService;
        
        NSArray *tags = [NSArray arrayWithObject:@"test"];

        [self.taggingService addTags:tags toNode:super.testAlfrescoDocument completionBlock:^(BOOL success, NSError *error)
        {
            if (!success) 
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                super.callbackCompleted = YES;
            }
            else 
            {
                super.lastTestSuccessful = YES;
                STAssertTrue(success, @"a dummy test to see if we still have the retain cycle problem");
                [weakTaggingService retrieveTagsForNode:super.testAlfrescoDocument completionBlock:^(NSArray *tags, NSError *error){
                    if (nil == tags)
                    {
                        super.lastTestSuccessful = NO;
                        super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                    }
                    else
                    {
                        int count = tags.count;
                        STAssertNotNil(tags, @"tags should not be nil");
                        STAssertTrue(count > 0, @"Count should be > 0, and is in fact %d",count);
                        super.lastTestSuccessful = YES;
                    }
                    super.callbackCompleted = YES;
                }];
            }
            
            
        }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}


@end
