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

#import "AlfrescoActivityStreamServiceTest.h"
#import "AlfrescoActivityEntry.h"
#import "AlfrescoSiteService.h"
#import "AlfrescoLog.h"

@implementation AlfrescoActivityStreamServiceTest

#pragma On Premise tests
/*
 @Unique_TCRef 2S0
 */

- (void)testRetrieveActivityStreamForLoggedinUserWithPaging
{
    if (self.setUpSuccess)
    {
        self.activityStreamService = [[AlfrescoActivityStreamService alloc] initWithSession:self.currentSession];
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:10 skipCount:0];
        
        // retrieve activity stream - there must be at least one site-based activity (e.g. document uploaded)
        [self.activityStreamService retrieveActivityStreamWithListingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error)
         {
             if (nil == pagingResult)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else
             {
                 XCTAssertNotNil(pagingResult, @"pagingResult should not be nil");
                 XCTAssertTrue(pagingResult.objects.count > 1, @"expected more than 1 activity entries, but got %d", pagingResult.objects.count);
                 XCTAssertTrue(pagingResult.totalItems > 0 || pagingResult.totalItems == -1, @"expected activity entries");
                 
                 self.lastTestSuccessful = YES;
             }
             self.callbackCompleted = YES;
         }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}
/*
 @Unique_TCRef 1S0
 */
- (void)testRetrieveActivityStreamForLoggedinUser
{
    if (self.setUpSuccess)
    {
        self.activityStreamService = [[AlfrescoActivityStreamService alloc] initWithSession:self.currentSession];
        
        // retrieve activity stream - there must be at least one site-based activity (e.g. document uploaded)
        [self.activityStreamService retrieveActivityStreamWithCompletionBlock:^(NSArray *array, NSError *error)
         {
             if (nil == array)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else
             {
                 XCTAssertNotNil(array, @"array should not be nil");
                 XCTAssertTrue(array.count > 0, @"expected activity entries");
                 
                 for (AlfrescoActivityEntry *entry in array) {
                     XCTAssertNotNil(entry.createdBy, @"createdBy user ID should not be nil");
                     XCTAssertTrue([entry.createdAt isKindOfClass:[NSDate class]], @"post date should be a NSDate");
                     XCTAssertNotNil(entry.identifier, @"identifier should not be nil");
                     XCTAssertNotNil(entry.siteShortName, @"site should not be nil");
                     XCTAssertNotNil(entry.type, @"type should not be nil");
                     XCTAssertTrue([entry.data isKindOfClass:[NSDictionary class]], @"data should be a NSDictionary");
                 }
                 
                 self.lastTestSuccessful = YES;
             }
             self.callbackCompleted = YES;
             
         }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}


/*
 @Unique_TCRef 3S0
 */
- (void)testRetrieveActivityStreamForUser
{
    if (self.setUpSuccess)
    {
        self.activityStreamService = [[AlfrescoActivityStreamService alloc] initWithSession:self.currentSession];
        
        // retrieve activity stream - there must be at least one site-based activity (e.g. document uploaded)
        [self.activityStreamService retrieveActivityStreamForPerson:self.userName completionBlock:^(NSArray *array, NSError *error)
         {
             if (nil == array)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else
             {
                 XCTAssertNotNil(array, @"array should not be nil");
                 XCTAssertTrue(array.count > 0, @"expected activity entries");
                 
                 for (AlfrescoActivityEntry *entry in array) {
                     XCTAssertNotNil(entry.createdBy, @"createdBy user ID should not be nil");
                     XCTAssertTrue([entry.createdAt isKindOfClass:[NSDate class]], @"post date should be a NSDate");
                     XCTAssertNotNil(entry.identifier, @"identifier should not be nil");
                     XCTAssertNotNil(entry.siteShortName, @"site should not be nil");
                     XCTAssertNotNil(entry.type, @"type should not be nil");
                     XCTAssertTrue([entry.data isKindOfClass:[NSDictionary class]], @"data should be a NSDictionary");
                 }
                 
                 self.lastTestSuccessful = YES;
             }
             self.callbackCompleted = YES;
             
         }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 @Unique_TCRef 4S0
 */
- (void)testRetrieveActivityStreamForUserWithPaging
{
    if (self.setUpSuccess)
    {
        self.activityStreamService = [[AlfrescoActivityStreamService alloc] initWithSession:self.currentSession];
        
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:5 skipCount:0];
        
        [self.activityStreamService retrieveActivityStreamForPerson:self.userName listingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error)
         {
             if (nil == pagingResult)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else
             {
                 XCTAssertNotNil(pagingResult, @"pagingResult should not be nil");
                 XCTAssertTrue(pagingResult.objects.count > 0, @"expected at least 1 activity entries");
                 XCTAssertTrue(pagingResult.totalItems > 0 || pagingResult.totalItems == -1, @"expected activity entries");
                 
                 self.lastTestSuccessful = YES;
             }
             self.callbackCompleted = YES;
             
         }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 @Unique_TCRef 44S1
 @Unique_TCRef 5S0
 */
- (void)testRetrieveActivityStreamForSite
{
    if (self.setUpSuccess)
    {
        
        self.activityStreamService = [[AlfrescoActivityStreamService alloc] initWithSession:self.currentSession];
        __block AlfrescoSiteService *siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        [siteService retrieveSiteWithShortName:self.testSiteName completionBlock:^(AlfrescoSite *site, NSError *error)
         {
             if (nil == site || nil != error)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 self.callbackCompleted = YES;
             }
             else
             {
                 // retrieve activity stream - there must be at least one site-based activity (e.g. document uploaded)
                 [self.activityStreamService retrieveActivityStreamForSite:site completionBlock:^(NSArray *array, NSError *error)
                  {
                      if (nil == array)
                      {
                          self.lastTestSuccessful = NO;
                          self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                      }
                      else
                      {
                          XCTAssertNotNil(array, @"array should not be nil");
                          AlfrescoLogDebug(@"activity stream for site returns array count = %d",array.count);
                          XCTAssertTrue(array.count >= 0, @"site may have more than 0 entries");
                          
                          for (AlfrescoActivityEntry *entry in array) {
                              XCTAssertNotNil(entry.createdBy, @"createdBy user ID should not be nil");
                              XCTAssertTrue([entry.createdAt isKindOfClass:[NSDate class]], @"post date should be a NSDate");
                              XCTAssertNotNil(entry.identifier, @"identifier should not be nil");
                              XCTAssertNotNil(entry.siteShortName, @"site should not be nil");
                              XCTAssertNotNil(entry.type, @"type should not be nil");
                              XCTAssertTrue([entry.data isKindOfClass:[NSDictionary class]], @"data should be a NSDictionary");
                          }
                          
                          self.lastTestSuccessful = YES;
                      }
                      self.callbackCompleted = YES;
                      
                  }];
             }
             
         }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 @Unique_TCRef 44S1
 @Unique_TCRef 6S0
 */
- (void)testRetrieveActivityStreamForSiteWithPaging
{
    if (self.setUpSuccess)
    {
        self.activityStreamService = [[AlfrescoActivityStreamService alloc] initWithSession:self.currentSession];
        __block AlfrescoSiteService *siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:5 skipCount:0];
        
        [siteService retrieveSiteWithShortName:self.testSiteName completionBlock:^(AlfrescoSite *site, NSError *error)
         {
             if (nil == site || nil != error)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 self.callbackCompleted = YES;
             }
             else
             {
                 // retrieve activity stream - there must be at least one site-based activity (e.g. document uploaded)
                 [self.activityStreamService retrieveActivityStreamForSite:site listingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error)
                  {
                      if (nil == pagingResult)
                      {
                          self.lastTestSuccessful = NO;
                          self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                      }
                      else
                      {
                          AlfrescoLogDebug(@"activity stream for site returns paging results count = %d",pagingResult.objects.count);
                          XCTAssertNotNil(pagingResult, @"pagingResult should not be nil");
                          XCTAssertTrue(pagingResult.objects.count <= 5, @"the returned objects count should be up to 5");
                          
                          self.lastTestSuccessful = YES;
                      }
                      self.callbackCompleted = YES;
                      
                  }];
             }
             
         }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}



@end
