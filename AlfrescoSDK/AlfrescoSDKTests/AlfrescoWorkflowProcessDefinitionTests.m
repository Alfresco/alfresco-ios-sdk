/*
 ******************************************************************************
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
 *****************************************************************************
 */

/** AlfrescoWorkflowProcessDefinitionTests
 
 Author: Tauseef Mughal (Alfresco)
 */

#import "AlfrescoWorkflowProcessDefinitionTests.h"
#import "AlfrescoErrors.h"

@implementation AlfrescoWorkflowProcessDefinitionTests

- (void)testRetrieveAllProcessDefinitions
{
    if (self.setUpSuccess)
    {
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        [self.workflowService retrieveAllProcessDefinitionsWithCompletionBlock:^(NSArray *array, NSError *error) {
            if (!array)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(array, @"array should not be nil");
                XCTAssertTrue(array.count > 1, @"Array should contain more than 1 process");
                
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

- (void)testRetrievePagedProcessDefinitions
{
    if (self.setUpSuccess)
    {
        int maxItemsToRetrieve = 2;
        int skipCount = 2;
        
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:maxItemsToRetrieve skipCount:skipCount];
        
        [self.workflowService retrieveProcessDefinitionsWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
            if (error)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(pagingResult, @"Paging result should not be nil");
                XCTAssertTrue(pagingResult.objects.count > 1, @"Paging result should contain more than 1 process");
                XCTAssertTrue(pagingResult.objects.count == maxItemsToRetrieve, @"Paging result should be %i, instead got back %lu", maxItemsToRetrieve, (unsigned long)pagingResult.objects.count);
                
                // COMMENTED OUT FOR NOW - LOOK INTO WHY MORE ITEMS ARE BEING RETRIEVED
//                XCTAssertTrue(pagingResult.totalItems == maxItemsToRetrieve, @"Paging result should be %i, instead got back %i", maxItemsToRetrieve, pagingResult.totalItems);
//                XCTAssertFalse(pagingResult.hasMoreItems, @"The hasMoreItems flag should be false");

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

- (void)testRetrieveProcessDefinitionByID
{
    if (self.setUpSuccess)
    {
        NSString *processID = @"activitiAdhoc:1:4";
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        [self.workflowService retrieveProcessDefinitionWithIdentifier:processID completionBlock:^(AlfrescoWorkflowProcessDefinition *processDefinition, NSError *error) {
            if (error)
            {
                if (error.code == kAlfrescoErrorCodeWorkflowFunctionNotSupported)
                {
                    XCTAssertEqualObjects(error.localizedDescription, kAlfrescoErrorDescriptionWorkflowFunctionNotSupported, @"Error description should be %@, but instead got back %@", kAlfrescoErrorDescriptionWorkflowFunctionNotSupported, error.localizedDescription);
                    self.lastTestSuccessful = YES;
                }
                else
                {
                    self.lastTestSuccessful = NO;
                    self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                }
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(processDefinition, @"array should not be nil");
                
                // check values of each property
                
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

@end
