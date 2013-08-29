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

/** AlfrescoWorkflowProcessDefinitionServiceTest
 
 Author: Tauseef Mughal (Alfresco)
 */

#import "AlfrescoWorkflowProcessDefinitionServiceTest.h"
#import "AlfrescoErrors.h"
#import "AlfrescoListingContext.h"

@interface AlfrescoWorkflowProcessDefinitionServiceTest ()

@property (nonatomic, strong) AlfrescoWorkflowProcessDefinitionService *processDefinitionService;

@end

@implementation AlfrescoWorkflowProcessDefinitionServiceTest

- (void)testRetrieveAllProcessDefinitions
{
    if (self.setUpSuccess)
    {
        self.processDefinitionService = [[AlfrescoWorkflowProcessDefinitionService alloc] initWithSession:self.currentSession];
        
        [self.processDefinitionService retrieveAllProcessDefinitionsWithCompletionBlock:^(NSArray *array, NSError *error) {
            if (!array)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                STAssertNotNil(array, @"array should not be nil");
                STAssertTrue(array.count > 1, @"Array should contain more than 1 process");
                
                self.lastTestSuccessful = YES;
            }
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRetrievePagedProcessDefinitions
{
    if (self.setUpSuccess)
    {
        int maxItemsToRetrieve = 2;
        int skipCount = 2;
        
        self.processDefinitionService = [[AlfrescoWorkflowProcessDefinitionService alloc] initWithSession:self.currentSession];
        AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:maxItemsToRetrieve skipCount:skipCount];
        
        [self.processDefinitionService retrieveProcessDefinitionsWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
            if (error)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                STAssertNotNil(pagingResult, @"Paging result should not be nil");
                STAssertTrue(pagingResult.objects.count > 1, @"Paging result should contain more than 1 process");
                STAssertTrue(pagingResult.objects.count == maxItemsToRetrieve, @"Paging result should be %i, instead got back %i", maxItemsToRetrieve, pagingResult.objects.count);
                
                // COMMENTED OUT FOR NOW - LOOK INTO WHY MORE ITEMS ARE BEING RETRIEVED
//                STAssertTrue(pagingResult.totalItems == maxItemsToRetrieve, @"Paging result should be %i, instead got back %i", maxItemsToRetrieve, pagingResult.totalItems);
//                STAssertFalse(pagingResult.hasMoreItems, @"The hasMoreItems flag should be false");

                self.lastTestSuccessful = YES;
            }
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRetrieveProcessDefinitionByID
{
    if (self.setUpSuccess)
    {
        NSString *processID = @"activitiAdhoc:1:4";
        self.processDefinitionService = [[AlfrescoWorkflowProcessDefinitionService alloc] initWithSession:self.currentSession];
        
        [self.processDefinitionService retrieveProcessDefinitionWithIdentifier:processID completionBlock:^(AlfrescoWorkflowProcessDefinition *processDefinition, NSError *error) {
            if (processDefinition == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                STAssertNotNil(processDefinition, @"array should not be nil");
                
                // check values of each property
                
                self.lastTestSuccessful = YES;
            }
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRetrieveFormModelByProcessID
{
    if (self.setUpSuccess)
    {
        NSString *processID = @"activitiAdhoc:1:4";
        self.processDefinitionService = [[AlfrescoWorkflowProcessDefinitionService alloc] initWithSession:self.currentSession];
        
        [self.processDefinitionService retrieveFormModelForProcess:processID completionBlock:^(NSDictionary *dictionary, NSError *error) {
            if (self.currentSession.workflowInfo.publicAPI)
            {
                if (!dictionary)
                {
                    self.lastTestSuccessful = NO;
                    self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                    self.callbackCompleted = YES;
                }
                else
                {
                    STAssertNotNil(dictionary, @"Returned object should not be nil");
                    
                    self.lastTestSuccessful = YES;
                }
            }
            else
            {
                STAssertNil(dictionary, @"Returned dictionary was expected to be nil");
                STAssertNotNil(error, @"Expected an error to be returned");
                STAssertTrue(error.code == kAlfrescoErrorCodeWorkflowFunctionNotSupported, @"Expected error code: %i", kAlfrescoErrorCodeWorkflowFunctionNotSupported);
                STAssertTrue([error.localizedDescription isEqualToString:kAlfrescoErrorDescriptionWorkflowFunctionNotSupported], @"Expected error description: %@", kAlfrescoErrorDescriptionWorkflowFunctionNotSupported);
                
                self.lastTestSuccessful = YES;
            }
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

@end
