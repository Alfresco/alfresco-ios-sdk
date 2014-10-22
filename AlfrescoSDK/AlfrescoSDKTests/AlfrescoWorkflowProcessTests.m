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

/** AlfrescoWorkflowProcessTests
 
 Author: Tauseef Mughal (Alfresco)
 */

#import "AlfrescoWorkflowProcessTests.h"
#import "AlfrescoFileManager.h"
#import "AlfrescoErrors.h"
#import "AlfrescoProperty.h"
#import "AlfrescoWorkflowUtils.h"
#import "AlfrescoConstants.h"
#import "AlfrescoInternalConstants.h"

static NSString * const kAlfrescoJBPMPrefix = @"jbpm$";
static NSString * const kAlfrescoActivitiPrefix = @"activiti$";
static NSString * const kAlfrescoActivitiAdhocProcessDefinition = @"activitiAdhoc:1:4";
static NSString * const kAlfrescoJBPMAdhocProcessDefinitionKey = @"wf:adhoc";
static NSString * const kAlfrescoActivitiAdhocProcessDefinitionKey = @"activitiAdhoc";
static NSString * const kAlfrescoJBPMReviewProcessDefinitionKey = @"wf:review";
static NSString * const kAlfrescoActivitiReviewProcessDefinitionKey = @"activitiReview";
static NSString * const kAlfrescoActivitiParallelReviewProcessDefinitionKey = @"activitiParallelReview";

@implementation AlfrescoWorkflowProcessTests

- (void)testRetrieveAllProcesses
{
    if (self.setUpSuccess)
    {
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
                
        [self.workflowService retrieveProcessesWithCompletionBlock:^(NSArray *array, NSError *retrieveError) {
            if (retrieveError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveError localizedDescription], [retrieveError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(array, @"array should not be nil");
                XCTAssertTrue(array.count > 1, @"Array should contain more than 1 process");
                
                BOOL reviewProcessFound = NO;
                
                if (self.currentSession.repositoryInfo.capabilities.doesSupportJBPMWorkflowEngine)
                {
                    NSString *reviewKey = [kAlfrescoJBPMPrefix stringByAppendingString:kAlfrescoJBPMReviewProcessDefinitionKey];
                    
                    // go through the processes looking for a review process
                    for (AlfrescoWorkflowProcess *process in array)
                    {
                        if ([process.processDefinitionKey isEqualToString:reviewKey])
                        {
                            XCTAssertTrue([process.processDefinitionIdentifier isEqualToString:reviewKey],
                                          @"Expected processDefinitionIdentifier to be %@ but it was %@", kAlfrescoJBPMReviewProcessDefinitionKey,
                                          process.processDefinitionIdentifier);
                            XCTAssertTrue([process.identifier rangeOfString:@"jbpm$"].location != NSNotFound,
                                          @"Expected identifer to contain jbpm$ but it was %@", process.identifier);
                            XCTAssertTrue([process.name isEqualToString:@"Review & Approve"],
                                          @"Expected adhoc summary to be 'Review & Approve' but it was %@", process.summary);
                            
                            XCTAssertNotNil(process.summary, @"Expected summary to be populated");
                            XCTAssertNotNil(process.startedAt, @"Expected startedAt to be populated");
                            XCTAssertNotNil(process.priority, @"Expected priority to be populated");
                            XCTAssertNotNil(process.initiatorUsername, @"Expected initiatorUsername to be populated");
                            
                            reviewProcessFound = YES;
                            break;
                        }
                    }
                }
                else if (self.currentSession.repositoryInfo.capabilities.doesSupportActivitiWorkflowEngine)
                {
                    if (self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
                    {
                        NSString *reviewKey = nil;
                        if (self.isCloud)
                        {
                            reviewKey = kAlfrescoActivitiParallelReviewProcessDefinitionKey;
                        }
                        else
                        {
                            reviewKey = kAlfrescoActivitiReviewProcessDefinitionKey;
                        }
                        
                        // go through the processes looking for the review workflow
                        for (AlfrescoWorkflowProcess *process in array)
                        {
                            if ([process.processDefinitionKey isEqualToString:reviewKey])
                            {
                                if (self.isCloud)
                                {
                                    XCTAssertTrue([process.processDefinitionIdentifier rangeOfString:kAlfrescoActivitiParallelReviewProcessDefinitionKey].location != NSNotFound,
                                                  @"Expected processDefinitionIdentifier to contain activitiParallelReview but it was %@", process.processDefinitionIdentifier);
                                }
                                else
                                {
                                    XCTAssertTrue([process.processDefinitionIdentifier rangeOfString:kAlfrescoActivitiReviewProcessDefinitionKey].location != NSNotFound,
                                                  @"Expected processDefinitionIdentifier to contain activitiReview but it was %@", process.processDefinitionIdentifier);
                                }
                                
                                XCTAssertNotNil(process.identifier, @"Expected identifier to be populated");
                                XCTAssertNotNil(process.summary, @"Expected summary to be populated");
                                XCTAssertNotNil(process.startedAt, @"Expected startedAt to be populated");
                                XCTAssertNotNil(process.priority, @"Expected priority to be populated");
                                XCTAssertNotNil(process.initiatorUsername, @"Expected initiatorUsername to be populated");
                                
                                // the name property for the public api will always be nil
                                XCTAssertNil(process.name, @"Expected the name property to be nil when using the public API");
                                
                                reviewProcessFound = YES;
                                break;
                            }
                        }
                    }
                    else
                    {
                        NSString *reviewKey = [kAlfrescoActivitiPrefix stringByAppendingString:kAlfrescoActivitiReviewProcessDefinitionKey];
                        
                        // go through the processes looking for the adhoc workflow
                        for (AlfrescoWorkflowProcess *process in array)
                        {
                            if ([process.processDefinitionKey isEqualToString:reviewKey])
                            {
                                XCTAssertTrue([process.processDefinitionIdentifier isEqualToString:reviewKey],
                                              @"Expected processDefinitionIdentifier to be %@ but it was %@", kAlfrescoJBPMReviewProcessDefinitionKey,
                                              process.processDefinitionIdentifier);
                                XCTAssertTrue([process.identifier rangeOfString:@"activiti$"].location != NSNotFound,
                                              @"Expected identifer to contain activit$ but it was %@", process.identifier);
                                XCTAssertTrue([process.name isEqualToString:@"Review And Approve"],
                                              @"Expected adhoc name to be 'Review And Approve' but it was %@", process.name);
                                
                                XCTAssertNotNil(process.summary, @"Expected summary to be populated");
                                XCTAssertNotNil(process.startedAt, @"Expected startedAt to be populated");
                                XCTAssertNotNil(process.priority, @"Expected priority to be populated");
                                XCTAssertNotNil(process.initiatorUsername, @"Expected initiatorUsername to be populated");
                                
                                reviewProcessFound = YES;
                                break;
                            }
                        }
                    }
                }
                
                self.lastTestSuccessful = reviewProcessFound;
                if (!reviewProcessFound)
                {
                    self.lastTestFailureMessage = @"Failed to find instance of review process";
                }
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

- (void)testRetrieveProcessesWithListingContext
{
    if (self.setUpSuccess)
    {
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:1 skipCount:0];
        
        [self.workflowService retrieveProcessesWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *retrieveError) {
            if (retrieveError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveError localizedDescription], [retrieveError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(pagingResult, @"Paging result should not be nil");
                XCTAssertTrue(pagingResult.objects.count == 1, @"PagingResult objects should contain 1 process");
                XCTAssertTrue(pagingResult.hasMoreItems, @"PagingResult should contain more objects");
                
                // make sure the array contains the correct type of objects
                AlfrescoWorkflowProcess *process = pagingResult.objects[0];
                XCTAssertTrue([process isKindOfClass:[AlfrescoWorkflowProcess class]], @"Expected the objects array to contain AlfrescoWorkflowProcess objects");
                
                self.lastTestSuccessful = YES;
                self.callbackCompleted = YES;
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

- (void)testRetrieveAllProcessesInStateActive
{
    if (self.setUpSuccess)
    {
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        AlfrescoListingFilter *listingFilter = [[AlfrescoListingFilter alloc]
                                                initWithFilter:kAlfrescoFilterByWorkflowStatus value:kAlfrescoFilterValueWorkflowStatusActive];
        AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithListingFilter:listingFilter];
        
        [self.workflowService retrieveProcessesWithListingContext:listingContext
                                                  completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *retrieveError) {
            if (retrieveError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveError localizedDescription], [retrieveError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(pagingResult, @"Expected a paging result to be returned");
                NSArray *array = pagingResult.objects;
                XCTAssertNotNil(array, @"array should not be nil");
                XCTAssertTrue(array.count >= 1, @"Array should contain 1 or more process");
                
                // check every process returned is active
                for (AlfrescoWorkflowProcess *process in array)
                {
                    XCTAssertTrue(process.endedAt == nil, @"Only expected to get processes that are active but process %@ has an end date set", process.identifier);
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

- (void)testRetrieveAllProcessesInStateCompleted
{
    if (self.setUpSuccess)
    {
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        AlfrescoListingFilter *listingFilter = [[AlfrescoListingFilter alloc]
                                                initWithFilter:kAlfrescoFilterByWorkflowStatus value:kAlfrescoFilterValueWorkflowStatusCompleted];
        AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithListingFilter:listingFilter];
        
        [self.workflowService retrieveProcessesWithListingContext:listingContext
                                                  completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *retrieveError) {
            if (retrieveError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveError localizedDescription], [retrieveError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(pagingResult, @"Expected a paging result to be returned");
                NSArray *array = pagingResult.objects;
                XCTAssertNotNil(array, @"array should not be nil");
                XCTAssertTrue(array.count >= 1, @"Array should contain 1 or more processes");
                
                // check every process returned is completed
                for (AlfrescoWorkflowProcess *process in array)
                {
                    XCTAssertTrue(process.endedAt != nil, @"Only expected to get processes that are complete but process %@ does not have an end date set", process.identifier);
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

- (void)testRetrieveProcessWithIdentifier
{
    if (self.setUpSuccess)
    {
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        [self createAdhocProcessWithAssignees:nil variables:nil attachments:nil completionBlock:^(AlfrescoWorkflowProcess *createdProcess, NSError *creationError) {
            if (creationError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(createdProcess, @"Process should not be nil");
                XCTAssertNotNil(createdProcess.identifier, @"Process identifier should not be nil");
                
                [self.workflowService retrieveProcessWithIdentifier:createdProcess.identifier completionBlock:^(AlfrescoWorkflowProcess *process, NSError *error) {
                    if (error)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        XCTAssertNotNil(process.identifier, @"Expected identifier property to be populated");
                        XCTAssertNotNil(process.processDefinitionKey, @"Expected processDefinitionKey property to be populated");
                        XCTAssertNotNil(process.processDefinitionIdentifier, @"Expected processDefinitionIdentifier property to be populated");
                        XCTAssertNotNil(process.summary, @"Expected summary property to be populated");
                        XCTAssertNotNil(process.identifier, @"Expected identifier property to be populated");
                        XCTAssertNotNil(process.startedAt, @"Expected startedAt property to be populated");
                        XCTAssertNotNil(process.priority, @"Expected priority property to be populated");
                        XCTAssertNotNil(process.initiatorUsername, @"Expected initiatorUsername property to be populated");
                        XCTAssertNotNil(process.identifier, @"Expected identifier property to be populated");
                        XCTAssertNil(process.dueAt, @"Expected dueAt property to be nil");
                        XCTAssertNil(process.endedAt, @"Expected endedAt property to be nil");
                        
                        XCTAssertTrue([process.processDefinitionIdentifier rangeOfString:@"dhoc"].location != NSNotFound,
                                      @"Expected processDefinitionIdentifier to contain 'dhoc' but it was %@", process.processDefinitionIdentifier);
                        XCTAssertTrue([process.processDefinitionKey rangeOfString:@"dhoc"].location != NSNotFound,
                                      @"Expected processDefinitionKey to contain 'dhoc' but it was %@", process.processDefinitionKey);
                        
                        // the name property for the public api will always be nil
                        if (self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
                        {
                            XCTAssertNil(process.name, @"Expected the name property to be nil when using the public API");
                        }
                        else
                        {
                            XCTAssertNotNil(process.summary, @"Expected summary property to be populated");
                        }
                        
                        [self deleteCreatedTestProcess:createdProcess completionBlock:^(BOOL succeeded, NSError *deleteError) {
                            XCTAssertTrue(succeeded, @"Deletion flag should be true");
                            self.lastTestSuccessful = succeeded;
                            self.callbackCompleted = YES;
                        }];
                    }
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

- (void)testStartProcessForProcessDefinition
{
    if (self.setUpSuccess)
    {
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        [self createAdhocProcessWithAssignees:nil variables:nil attachments:nil completionBlock:^(AlfrescoWorkflowProcess *createdProcess, NSError *creationError) {
            if (creationError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(createdProcess, @"Process should not be nil");
                XCTAssertNotNil(createdProcess.identifier, @"Expected identifier property to be populated");
                XCTAssertNotNil(createdProcess.processDefinitionKey, @"Expected processDefinitionKey property to be populated");
                XCTAssertNotNil(createdProcess.processDefinitionIdentifier, @"Expected processDefinitionIdentifier property to be populated");
                XCTAssertNotNil(createdProcess.summary, @"Expected summary property to be populated");
                XCTAssertNotNil(createdProcess.identifier, @"Expected identifier property to be populated");
                XCTAssertNotNil(createdProcess.startedAt, @"Expected startedAt property to be populated");
                XCTAssertNotNil(createdProcess.priority, @"Expected priority property to be populated");
                XCTAssertNotNil(createdProcess.initiatorUsername, @"Expected initiatorUsername property to be populated");
                XCTAssertNotNil(createdProcess.identifier, @"Expected identifier property to be populated");
                
                XCTAssertTrue([createdProcess.processDefinitionIdentifier rangeOfString:@"dhoc"].location != NSNotFound,
                              @"Expected processDefinitionIdentifier to contain 'dhoc' but it was %@", createdProcess.processDefinitionIdentifier);
                XCTAssertTrue([createdProcess.processDefinitionKey rangeOfString:@"dhoc"].location != NSNotFound,
                              @"Expected processDefinitionKey to contain 'dhoc' but it was %@", createdProcess.processDefinitionKey);
                
                // the name property for the public api will always be nil
                if (self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
                {
                    XCTAssertNil(createdProcess.name, @"Expected the name property to be nil when using the public API");
                }
                else
                {
                    XCTAssertNotNil(createdProcess.summary, @"Expected summary property to be populated");
                }
                
                [self deleteCreatedTestProcess:createdProcess completionBlock:^(BOOL succeeded, NSError *deleteError) {
                    XCTAssertTrue(succeeded, @"Deletion flag should be true");
                    self.lastTestSuccessful = succeeded;
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

- (void)testStartProcessForDefinitionWithConvenienceMethod
{
    if (self.setUpSuccess)
    {
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        NSString *processDefinitionKey = kAlfrescoActivitiAdhocProcessDefinitionKey;
        if (!self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
        {
            if (self.currentSession.repositoryInfo.capabilities.doesSupportActivitiWorkflowEngine)
            {
                processDefinitionKey = [kAlfrescoActivitiPrefix stringByAppendingString:kAlfrescoActivitiAdhocProcessDefinitionKey];
            }
            else if (self.currentSession.repositoryInfo.capabilities.doesSupportJBPMWorkflowEngine)
            {
                processDefinitionKey = [kAlfrescoJBPMPrefix stringByAppendingString:kAlfrescoJBPMAdhocProcessDefinitionKey];
            }
        }
        
        // retrieveProcessForIdentifier:completionBlock: not supported on jbpm
        [self.workflowService retrieveProcessDefinitionWithKey:processDefinitionKey completionBlock:^(AlfrescoWorkflowProcessDefinition *processDefinition, NSError *retrieveError) {
            if (retrieveError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveError localizedDescription], [retrieveError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                // Process name
                NSString *processName = [NSString stringWithFormat:@"MOBSDK Test Process - %@", [NSDate date]];
                // priority - Randomised
                NSNumber *priority = [NSNumber numberWithInt:(arc4random() % 3) + 1];
                // due date - Between 1 and 7 days from today.
                NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
                dayComponent.day = ((arc4random() % 7) + 1);
                
                NSCalendar *theCalendar = [NSCalendar currentCalendar];
                NSDate *dueDate = [theCalendar dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];
                
                NSNumber *sendEmailNotification = @YES;
                
                [self.workflowService startProcessForProcessDefinition:processDefinition name:processName priority:priority dueDate:dueDate sendEmailNotification:sendEmailNotification assignees:nil variables:nil attachments:@[self.testAlfrescoDocument] completionBlock:^(AlfrescoWorkflowProcess *createdProcess, NSError *creationError) {
                    if (creationError)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        XCTAssertNotNil(createdProcess, @"Process should not be nil");
                        XCTAssertNotNil(createdProcess.identifier, @"Expected identifier property to be populated");
                        XCTAssertNotNil(createdProcess.processDefinitionKey, @"Expected processDefinitionKey property to be populated");
                        XCTAssertNotNil(createdProcess.processDefinitionIdentifier, @"Expected processDefinitionIdentifier property to be populated");
                        XCTAssertNotNil(createdProcess.summary, @"Expected summary property to be populated");
                        XCTAssertNotNil(createdProcess.identifier, @"Expected identifier property to be populated");
                        XCTAssertNotNil(createdProcess.startedAt, @"Expected startedAt property to be populated");
                        XCTAssertNotNil(createdProcess.priority, @"Expected priority property to be populated");
                        XCTAssertNotNil(createdProcess.initiatorUsername, @"Expected initiatorUsername property to be populated");
                        XCTAssertNotNil(createdProcess.identifier, @"Expected identifier property to be populated");
                        
                        XCTAssertTrue([createdProcess.processDefinitionIdentifier rangeOfString:@"dhoc"].location != NSNotFound,
                                      @"Expected processDefinitionIdentifier to contain 'dhoc' but it was %@", createdProcess.processDefinitionIdentifier);
                        XCTAssertTrue([createdProcess.processDefinitionKey rangeOfString:@"dhoc"].location != NSNotFound,
                                      @"Expected processDefinitionKey to contain 'dhoc' but it was %@", createdProcess.processDefinitionKey);
                        XCTAssertTrue([createdProcess.summary isEqualToString:processName], @"The process summary should be %@, but got back %@", processName, createdProcess.summary);
                        XCTAssertTrue(createdProcess.priority.intValue == priority.integerValue, @"The priority should be %i, but got back %i", priority.intValue, createdProcess.priority.intValue);
                        
                        // the name property for the public api will always be nil
                        if (self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
                        {
                            XCTAssertNil(createdProcess.name, @"Expected the name property to be nil when using the public API");
                        }
                        else
                        {
                            XCTAssertNotNil(createdProcess.summary, @"Expected summary property to be populated");
                        }
                        
                        double providedDueDateInterval = floor([dueDate timeIntervalSince1970]);
                        double retrievedDueDateInterval = floor([createdProcess.dueAt timeIntervalSince1970]);
                        XCTAssertTrue(providedDueDateInterval == retrievedDueDateInterval,
                                      @"Expected due date to match (%f vs %f)", providedDueDateInterval, retrievedDueDateInterval);
                        
                        [self deleteCreatedTestProcess:createdProcess completionBlock:^(BOOL succeeded, NSError *deleteError) {
                            XCTAssertTrue(succeeded, @"Deletion flag should be true");
                            self.lastTestSuccessful = succeeded;
                            self.callbackCompleted = YES;
                        }];
                    }
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

- (void)testRetrieveProcessImage
{
    if (self.setUpSuccess)
    {
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        [self createAdhocProcessWithAssignees:nil variables:nil attachments:nil completionBlock:^(AlfrescoWorkflowProcess *createdProcess, NSError *creationError) {
            if (creationError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(createdProcess, @"Process should not be nil");
                XCTAssertNotNil(createdProcess.identifier, @"Process identifier should not be nil");
                
                [self.workflowService retrieveImageForProcess:createdProcess completionBlock:^(AlfrescoContentFile *contentFile, NSError *retrieveImageError) {
                    if (retrieveImageError)
                    {
                        if (self.currentSession.repositoryInfo.capabilities.doesSupportActivitiWorkflowEngine)
                        {
                            self.lastTestSuccessful = NO;
                            self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveImageError localizedDescription], [retrieveImageError localizedFailureReason]];
                            self.callbackCompleted = YES;
                        }
                        else
                        {
                            XCTAssertNil(contentFile, @"Content file should be nil");
                            XCTAssertNotNil(retrieveImageError, @"Retrieving image on JBPM engine should have thrown an error");
                            XCTAssertEqualObjects(retrieveImageError.localizedDescription, kAlfrescoErrorDescriptionWorkflowFunctionNotSupported, @"Expected the error description to be - %@, instead got back an error description of - %@", kAlfrescoErrorDescriptionWorkflowFunctionNotSupported, retrieveImageError.localizedDescription);
                            XCTAssertTrue(retrieveImageError.code == kAlfrescoErrorCodeWorkflowFunctionNotSupported, @"Expected the error code %ld, instead got back %li", (long)kAlfrescoErrorCodeWorkflowFunctionNotSupported, (long)retrieveImageError.code);
                     
                            self.lastTestSuccessful = YES;
                            self.callbackCompleted = YES;
                        }
                    }
                    else
                    {
                        XCTAssertNotNil(contentFile, @"Content file should not be nil");
                        BOOL fileExists = [[AlfrescoFileManager sharedManager] fileExistsAtPath:contentFile.fileUrl.path];
                        XCTAssertTrue(fileExists, @"The image does not exist at the path");
                     
                        [self deleteCreatedTestProcess:createdProcess completionBlock:^(BOOL succeeded, NSError *deleteError) {
                            XCTAssertTrue(succeeded, @"Deletion flag should be true");
                            self.lastTestSuccessful = succeeded;
                            self.callbackCompleted = YES;
                        }];
                    }
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

- (void)testRetrieveProcessImageWithOutputStream
{
    if (self.setUpSuccess)
    {
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        [self createAdhocProcessWithAssignees:nil variables:nil attachments:nil completionBlock:^(AlfrescoWorkflowProcess *createdProcess, NSError *creationError) {
            if (creationError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(createdProcess, @"Process should not be nil");
                XCTAssertNotNil(createdProcess.identifier, @"Process identifier should not be nil");
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
                NSString *imageName = [NSString stringWithFormat:@"%@%@.png", @"processImageFromOutputstream", [dateFormatter stringFromDate:[NSDate date]]];
                NSString *filePath = [[[AlfrescoFileManager sharedManager] temporaryDirectory] stringByAppendingPathComponent:imageName];
                
                NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
                
                [self.workflowService retrieveImageForProcess:createdProcess outputStream:outputStream completionBlock:^(BOOL succeeded, NSError *retrieveImageError) {
                    if (retrieveImageError)
                    {
                        if (self.currentSession.repositoryInfo.capabilities.doesSupportActivitiWorkflowEngine)
                        {
                        
                            self.lastTestSuccessful = NO;
                            self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveImageError localizedDescription], [retrieveImageError localizedFailureReason]];
                            self.callbackCompleted = YES;
                        }
                        else
                        {
                            XCTAssertFalse(succeeded, @"Success flag should be false.");
                            XCTAssertNotNil(retrieveImageError, @"Retrieving image on JBPM engine should have thrown an error");
                            XCTAssertEqualObjects(retrieveImageError.localizedDescription, kAlfrescoErrorDescriptionWorkflowFunctionNotSupported, @"Expected the error description to be - %@, instead got back an error description of - %@", kAlfrescoErrorDescriptionWorkflowFunctionNotSupported, retrieveImageError.localizedDescription);
                            XCTAssertTrue(retrieveImageError.code == kAlfrescoErrorCodeWorkflowFunctionNotSupported, @"Expected the error code %ld, instead got back %li", (long)kAlfrescoErrorCodeWorkflowFunctionNotSupported, (long)retrieveImageError.code);
                        
                            self.lastTestSuccessful = YES;
                            self.callbackCompleted = YES;
                        }
                    }
                    else
                    {
                        if (self.currentSession.repositoryInfo.capabilities.doesSupportActivitiWorkflowEngine)
                        {
                            XCTAssertTrue(succeeded, @"The completion of the file writing did not complete");
                            BOOL fileExists = [[AlfrescoFileManager sharedManager] fileExistsAtPath:filePath];
                            XCTAssertTrue(fileExists, @"The image does not exist at the path");
                            
                            [self deleteCreatedTestProcess:createdProcess completionBlock:^(BOOL succeeded, NSError *deleteError) {
                                XCTAssertTrue(succeeded, @"Deletion flag should be true");
                                self.lastTestSuccessful = succeeded;
                                self.callbackCompleted = YES;
                            }];
                        }
                        else
                        {
                            XCTAssertFalse(succeeded, @"Success flag should be false.");
                            XCTAssertNotNil(retrieveImageError, @"Retrieving image on JBPM engine should have thrown an error");
                            XCTAssertEqualObjects(retrieveImageError.localizedDescription, kAlfrescoErrorDescriptionWorkflowFunctionNotSupported, @"Expected the error description to be - %@, instead got back an error description of - %@", kAlfrescoErrorDescriptionWorkflowFunctionNotSupported, retrieveImageError.localizedDescription);
                            XCTAssertTrue(retrieveImageError.code == kAlfrescoErrorCodeWorkflowFunctionNotSupported, @"Expected the error code %ld, instead got back %li", (long)kAlfrescoErrorCodeWorkflowFunctionNotSupported, (long)retrieveImageError.code);
                            
                            self.lastTestSuccessful = YES;
                            self.callbackCompleted = YES;
                        }
                    }
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

- (void)testRetrieveAllTasksForProcess
{
    if (self.setUpSuccess)
    {
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        NSString *processDefinitionID = kAlfrescoActivitiAdhocProcessDefinition;
        if (!self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
        {
            processDefinitionID = [kAlfrescoActivitiPrefix stringByAppendingString:kAlfrescoActivitiAdhocProcessDefinition];
        }
        
        [self createAdhocProcessWithAssignees:nil variables:nil attachments:nil completionBlock:^(AlfrescoWorkflowProcess *createdProcess, NSError *creationError) {
            if (creationError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(createdProcess, @"Process should not be nil");
                XCTAssertNotNil(createdProcess.identifier, @"Process identifier should not be nil");
                
                [self.workflowService retrieveTasksForProcess:createdProcess completionBlock:^(NSArray *array, NSError *retrieveTasksError) {
                    if (retrieveTasksError)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveTasksError localizedDescription], [retrieveTasksError localizedFailureReason]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        XCTAssertNotNil(array, @"array should not be nil");
                        XCTAssertTrue(array.count > 0, @"Array should contain more than or at least 1 task");
                        
                        [self deleteCreatedTestProcess:createdProcess completionBlock:^(BOOL succeeded, NSError *deleteError) {
                            XCTAssertTrue(succeeded, @"Deletion flag should be true");
                            self.lastTestSuccessful = succeeded;
                            self.callbackCompleted = YES;
                        }];
                    }
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

- (void)testRetrieveAttachmentsForProcessWithAttachment
{
    if (self.setUpSuccess)
    {
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        NSString *processDefinitionID = kAlfrescoActivitiAdhocProcessDefinition;
        if (!self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
        {
            processDefinitionID = [kAlfrescoActivitiPrefix stringByAppendingString:kAlfrescoActivitiAdhocProcessDefinition];
        }
        
        NSArray *attachmentArray = @[self.testAlfrescoDocument];
        
        [self createAdhocProcessWithAssignees:nil variables:nil attachments:attachmentArray completionBlock:^(AlfrescoWorkflowProcess *createdProcess, NSError *creationError) {
            if (creationError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(createdProcess, @"Process should not be nil");
                XCTAssertNotNil(createdProcess.identifier, @"Process identifier should not be nil");
                
                [self.workflowService retrieveAttachmentsForProcess:createdProcess completionBlock:^(NSArray *attachmentNodes, NSError *retrieveAttachmentsError) {
                    if (retrieveAttachmentsError)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveAttachmentsError localizedDescription], [retrieveAttachmentsError localizedFailureReason]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        XCTAssertNotNil(attachmentNodes, @"array should not be nil");
                        XCTAssertTrue(attachmentNodes.count == attachmentArray.count, @"Array should contain %lu attachment(s)", (unsigned long)attachmentArray.count);
                        
                        AlfrescoDocument *attachedDocument = attachmentNodes[0];
                        XCTAssertTrue([attachedDocument.identifier isEqualToString:self.testAlfrescoDocument.identifier],
                                      @"Expected the attached document to have the same identifier as the document passed to the create method");
                        
                        [self deleteCreatedTestProcess:createdProcess completionBlock:^(BOOL succeeded, NSError *deleteError) {
                            XCTAssertTrue(succeeded, @"Deletion flag should be true");
                            self.lastTestSuccessful = succeeded;
                            self.callbackCompleted = YES;
                        }];
                    }
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

- (void)testUpdateAndRetrieveVariables
{
    if (self.setUpSuccess)
    {
        if (self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
        {
            self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
            
            // setup variables to create process with
            NSString *processDescription = @"iOS SDK Unit Test Process";
            NSNumber *processPriority = [NSNumber numberWithInt:3];
            NSDate *processDueDate = [NSDate date];
            NSNumber *processSendEmail = @(NO);
            
            NSDictionary *variables = @{kAlfrescoWorkflowVariableProcessDescription: processDescription,
                                        kAlfrescoWorkflowVariableProcessPriority: processPriority,
                                        kAlfrescoWorkflowVariableProcessDueDate: processDueDate,
                                        kAlfrescoWorkflowVariableProcessSendEmailNotifications: processSendEmail};
            
            // create an adhoc process
            [self createAdhocProcessWithAssignees:nil variables:variables attachments:nil completionBlock:^(AlfrescoWorkflowProcess *createdProcess, NSError *creationError) {
                if (createdProcess == nil)
                {
                    self.lastTestSuccessful = NO;
                    self.lastTestFailureMessage = [self failureMessageFromError:creationError];
                    self.callbackCompleted = YES;
                }
                else
                {
                    // setup variables to update on process
                    NSNumber *processPriority = [NSNumber numberWithInt:1];
                    NSDate *processDueDate = [NSDate date];
                    
                    NSDictionary *variables = @{kAlfrescoWorkflowVariableProcessPriority: processPriority,
                                                kAlfrescoWorkflowVariableProcessDueDate: processDueDate};
                    
                    // update the variables on the process just created
                    [self.workflowService updateVariablesForProcess:createdProcess variables:variables
                                                    completionBlock:^(BOOL succeeded, NSError *updateError) {
                        if (!succeeded)
                        {
                            self.lastTestSuccessful = NO;
                            self.lastTestFailureMessage = [self failureMessageFromError:updateError];
                            self.callbackCompleted = YES;
                        }
                        else
                        {
                            [self.workflowService retrieveVariablesForProcess:createdProcess
                                                              completionBlock:^(NSDictionary *variables, NSError *retrieveError) {
                                if (variables == nil)
                                {
                                    self.lastTestSuccessful = NO;
                                    self.lastTestFailureMessage = [self failureMessageFromError:retrieveError];
                                    self.callbackCompleted = YES;
                                }
                                else
                                {
                                    // ensure provided variables are present and correct
                                    AlfrescoProperty *retrievedDescription = variables[kAlfrescoWorkflowVariableProcessDescription];
                                    AlfrescoProperty *retrievedSendEmail = variables[kAlfrescoWorkflowVariableProcessSendEmailNotifications];
                                    
                                    XCTAssertNotNil(retrievedDescription, @"Expected to find the description variable");
                                    XCTAssertNotNil(retrievedSendEmail, @"Expected to find the send email variable");
                                    
                                    XCTAssertTrue([retrievedDescription.value isEqualToString:processDescription],
                                                  @"Expected the description variable to be '%@' but it was: %@", processDescription, retrievedDescription);
                                    XCTAssertTrue([retrievedSendEmail.value boolValue] == processSendEmail.boolValue,
                                                  @"Expected the send email variable to be '%@' but it was: %@", processSendEmail, retrievedSendEmail);
                                    
                                    // ensure the updated variables are present and correct
                                    AlfrescoProperty *updatedPriority = variables[kAlfrescoWorkflowVariableProcessPriority];
                                    AlfrescoProperty *updatedDueDate = variables[kAlfrescoWorkflowVariableProcessDueDate];
                                    
                                    XCTAssertNotNil(updatedPriority, @"Expected to find the priority variable");
                                    XCTAssertNotNil(updatedDueDate, @"Expected to find the due date variable");
                                    
                                    XCTAssertTrue([updatedPriority.value intValue] == processPriority.intValue,
                                                  @"Expected the priority variable to be '%@' but it was: %@", processPriority, updatedPriority);
                                    
                                    // delete the process we created
                                    [self deleteCreatedTestProcess:createdProcess completionBlock:^(BOOL succeeded, NSError *deleteError) {
                                        self.lastTestSuccessful = YES;
                                        self.callbackCompleted = YES;
                                    }];
                                }
                            }];
                        }
                    }];
                }
            }];
            
            [self waitUntilCompleteWithFixedTimeInterval];
            XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
        }
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

#pragma mark - Private Functions

- (void)createAdhocProcessWithAssignees:(NSArray *)assignees variables:(NSDictionary *)variables attachments:(NSArray *)attachmentNodes completionBlock:(void (^)(AlfrescoWorkflowProcess *createdProcess, NSError *creationError))completionBlock
{
    // determine which adhoc process definition to use
    NSString *processDefinitionId = nil;
    if (self.currentSession.repositoryInfo.capabilities.doesSupportActivitiWorkflowEngine)
    {
        if (self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
        {
            processDefinitionId = kAlfrescoActivitiAdhocProcessDefinition;
        }
        else
        {
            processDefinitionId = [kAlfrescoActivitiPrefix stringByAppendingString:kAlfrescoActivitiAdhocProcessDefinition];
        }
    }
    else
    {
        processDefinitionId = [kAlfrescoJBPMPrefix stringByAppendingString:kAlfrescoJBPMAdhocProcessDefinitionKey];
    }
    
    self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
    
    [self.workflowService retrieveProcessDefinitionWithIdentifier:processDefinitionId completionBlock:^(AlfrescoWorkflowProcessDefinition *processDefinition, NSError *retrieveError) {
        
        // define the process creation block
        void (^createProcessWithDefinition)(AlfrescoWorkflowProcessDefinition *definition) = ^(AlfrescoWorkflowProcessDefinition *definition) {
            
            // make sure there is a description for the process
            NSMutableDictionary *processVariables = [NSMutableDictionary dictionaryWithDictionary:variables];
            if (processVariables[kAlfrescoWorkflowVariableProcessName] == nil)
            {
                NSString *processName = [NSString stringWithFormat:@"iOS SDK Test Process - %@", [NSDate date]];
                processVariables[kAlfrescoWorkflowVariableProcessName] = processName;
            }
            
            // start the process
            [self.workflowService startProcessForProcessDefinition:definition assignees:assignees variables:processVariables attachments:attachmentNodes completionBlock:^(AlfrescoWorkflowProcess *process, NSError *startError) {
                // call the completion block
                completionBlock(process, startError);
            }];
        };
        
        if (retrieveError)
        {
            // 3.x servers do not support retrieval of workflow definitions by id, f this error has occurred
            // manually construct a JBPM adhoc process definition object to use.
            if (retrieveError.code == kAlfrescoErrorCodeWorkflowFunctionNotSupported)
            {
                NSDictionary *properties = @{@"id" : @"jbpm$1",
                                                 @"url" : @"api/workflow-definitions/jbpm$1",
                                                 @"name" : [kAlfrescoJBPMPrefix stringByAppendingString:kAlfrescoJBPMAdhocProcessDefinitionKey],
                                                 @"title" : @"Adhoc",
                                                 @"description" : @"Assign task to colleague",
                                                 @"version" : @"1"};
                processDefinition = [[AlfrescoWorkflowProcessDefinition alloc] initWithProperties:properties];
                createProcessWithDefinition(processDefinition);
            }
            else
            {
                completionBlock(nil, retrieveError);
            }
        }
        else
        {
            XCTAssertNotNil(processDefinition, @"Process definition should not be nil");
            XCTAssertNotNil(processDefinition.identifier, @"Process definition identifier should not be nil");
            
            createProcessWithDefinition(processDefinition);
        }
    }];
}

- (void)deleteCreatedTestProcess:(AlfrescoWorkflowProcess *)process completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
    
    [self.workflowService deleteProcess:process completionBlock:^(BOOL succeeded, NSError *deleteError) {
        completionBlock(succeeded, deleteError);
    }];
}

@end
