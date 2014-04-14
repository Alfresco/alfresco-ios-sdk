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

/** AlfrescoWorkflowTaskTests
 
 Author: Tauseef Mughal (Alfresco)
 */

#import "AlfrescoWorkflowTaskTests.h"
#import "AlfrescoWorkflowUtils.h"
#import "AlfrescoErrors.h"

static NSString * const kAlfrescoJBPMPrefix = @"jbpm$";
static NSString * const kAlfrescoActivitiPrefix = @"activiti$";
static NSString * const kAlfrescoActivitiAdhocProcessDefinition = @"activitiAdhoc:1:4";
static NSString * const kAlfrescoJBPMAdhocProcessDefinition = @"jbpm$wf:adhoc";
static NSString * const kAlfrescoJBPMReviewProcessDefinitionKey = @"wf:review";
static NSString * const kAlfrescoActivitiReviewProcessDefinitionKey = @"activitiReview";
static NSString * const kAlfrescoActivitiParallelReviewProcessDefinitionKey = @"activitiParallelReview";

@implementation AlfrescoWorkflowTaskTests

- (void)testRetrieveAllTasks
{
    if (self.setUpSuccess)
    {
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        [self.workflowService retrieveTasksWithCompletionBlock:^(NSArray *array, NSError *error) {
            if (!array)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(array, @"array should not be nil");
                XCTAssertTrue(array.count > 1, @"array should contain more than 1 task");
                
                BOOL reviewTaskFound = NO;
                
                if (self.currentSession.repositoryInfo.capabilities.doesSupportJBPMWorkflowEngine)
                {
                    NSString *reviewKey = [kAlfrescoJBPMPrefix stringByAppendingString:kAlfrescoJBPMReviewProcessDefinitionKey];
                    
                    // go through the tasks looking for a review task
                    for (AlfrescoWorkflowTask *task in array)
                    {
                        if ([task.processDefinitionIdentifier isEqualToString:reviewKey])
                        {
                            XCTAssertTrue([task.identifier rangeOfString:kAlfrescoJBPMPrefix].location != NSNotFound,
                                          @"Expected identifier to contain jbpm$ but it was %@", task.identifier);
                            XCTAssertTrue([task.processIdentifier rangeOfString:kAlfrescoJBPMPrefix].location != NSNotFound,
                                          @"Expected processIdentifier to contain jbpm$ but it was %@", task.processIdentifier);
                            XCTAssertTrue([task.summary isEqualToString:@"Review Documents to Approve or Reject them"],
                                          @"Expected task summary to be 'Review Documents to Approve or Reject them' but it was %@", task.summary);
                            
                            XCTAssertNotNil(task.name, @"Expected the name property to be populated");
                            XCTAssertNotNil(task.priority, @"Expected the priority property to be populated");
                            XCTAssertNotNil(task.assigneeIdentifier, @"Expected the assigneeIdentifier property to be populated");
                            
                            reviewTaskFound = YES;
                            break;
                        }
                    }
                }
                else if (self.currentSession.repositoryInfo.capabilities.doesSupportActivitiWorkflowEngine)
                {
                    if (self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
                    {
                        // go through the tasks looking for a review task
                        for (AlfrescoWorkflowTask *task in array)
                        {
                            if ((self.isCloud && [task.processDefinitionIdentifier rangeOfString:kAlfrescoActivitiParallelReviewProcessDefinitionKey].location != NSNotFound) ||
                                (!self.isCloud && [task.processDefinitionIdentifier rangeOfString:kAlfrescoActivitiReviewProcessDefinitionKey].location != NSNotFound))
                            {
                                XCTAssertTrue([task.summary isEqualToString:@"Review Task"],
                                              @"Expected task summary to be 'Review Task' but it was %@", task.summary);
                                
                                XCTAssertNotNil(task.identifier, @"Expected the identifier property to be populated");
                                XCTAssertNotNil(task.processIdentifier, @"Expected the processIdentifier property to be populated");
                                XCTAssertNotNil(task.name, @"Expected the name property to be populated");
                                XCTAssertNotNil(task.priority, @"Expected the priority property to be populated");
                                XCTAssertNotNil(task.assigneeIdentifier, @"Expected the assigneeIdentifier property to be populated");
                                
                                reviewTaskFound = YES;
                                break;
                            }
                        }
                    }
                    else
                    {
                        NSString *reviewKey = [kAlfrescoActivitiPrefix stringByAppendingString:kAlfrescoActivitiReviewProcessDefinitionKey];
                        
                        // go through the tasks looking for a review task
                        for (AlfrescoWorkflowTask *task in array)
                        {
                            if ([task.processDefinitionIdentifier isEqualToString:reviewKey])
                            {
                                XCTAssertTrue([task.identifier rangeOfString:kAlfrescoActivitiPrefix].location != NSNotFound,
                                              @"Expected identifier to contain activiti$ but it was %@", task.identifier);
                                XCTAssertTrue([task.processIdentifier rangeOfString:kAlfrescoActivitiPrefix].location != NSNotFound,
                                              @"Expected processIdentifier to contain activiti$ but it was %@", task.processIdentifier);
                                XCTAssertTrue([task.summary isEqualToString:@"Review Documents to Approve or Reject them"],
                                              @"Expected task summary to be 'Review Documents to Approve or Reject them' but it was %@", task.summary);
                                
                                XCTAssertNotNil(task.name, @"Expected the name property to be populated");
                                XCTAssertNotNil(task.priority, @"Expected the priority property to be populated");
                                XCTAssertNotNil(task.assigneeIdentifier, @"Expected the assigneeIdentifier property to be populated");
                                
                                reviewTaskFound = YES;
                                break;
                            }
                        }
                    }
                }
                
                self.lastTestSuccessful = reviewTaskFound;
                if (!reviewTaskFound)
                {
                    self.lastTestFailureMessage = @"Failed to find a review task";
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

- (void)testRetrieveTasksWithListingContext
{
    if (self.setUpSuccess)
    {
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:1 skipCount:0];
        
        [self.workflowService retrieveTasksWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *retrieveError) {
            if (retrieveError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveError localizedDescription], [retrieveError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(pagingResult, @"Paging result should not be nil");
                XCTAssertTrue(pagingResult.objects.count == 1, @"PagingResult objects should contain 1 task");
                XCTAssertTrue(pagingResult.hasMoreItems, @"PagingResult should contain more objects");
                
                // make sure the array contains the correct type of objects
                AlfrescoWorkflowTask *task = pagingResult.objects[0];
                XCTAssertTrue([task isKindOfClass:[AlfrescoWorkflowTask class]], @"Expected the objects array to contain AlfrescoWorkflowTask objects");
                
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

- (void)testRetrieveTaskForProcess
{
    if (self.setUpSuccess)
    {
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        NSString *processDefinitionID = kAlfrescoActivitiAdhocProcessDefinition;
        if (!self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
        {
            processDefinitionID = [kAlfrescoActivitiPrefix stringByAppendingString:kAlfrescoActivitiAdhocProcessDefinition];
        }
        
        [self createTaskAndProcessWithProcessDefinitionIdentifier:processDefinitionID completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
            if (creationError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                [self.workflowService retrieveTasksForProcess:process completionBlock:^(NSArray *array, NSError *retrieveTaskError) {
                    if (retrieveTaskError)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveTaskError localizedDescription], [retrieveTaskError localizedFailureReason]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        XCTAssertNotNil(array, @"Returned array should not be nil");
                        XCTAssertTrue(array.count > 0, @"Tasks array should contain at least one task");

                        AlfrescoWorkflowTask *firstRetrievedTask = array[0];
                        XCTAssertNotNil(firstRetrievedTask.identifier, @"Expected the identifier property to be populated");
                        XCTAssertNotNil(firstRetrievedTask.processIdentifier, @"Expected the processIdentifier property to be populated");
                        XCTAssertNotNil(firstRetrievedTask.name, @"Expected the name property to be populated");
                        XCTAssertNotNil(firstRetrievedTask.summary, @"Expected the summary property to be populated");
                        XCTAssertNotNil(firstRetrievedTask.priority, @"Expected the priority property to be populated");
                        XCTAssertNotNil(firstRetrievedTask.assigneeIdentifier, @"Expected the assigneeIdentifier property to be populated");
                        
                        XCTAssertTrue([firstRetrievedTask.processDefinitionIdentifier rangeOfString:@"dhoc"].location != NSNotFound,
                                      @"Expected processDefinitionIdentifier to contain 'dhoc' but it was %@", firstRetrievedTask.processDefinitionIdentifier);
                        
                        [self deleteCreatedTestProcess:process completionBlock:^(BOOL succeeded, NSError *error) {
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

- (void)testRetrieveTaskWithTaskIdentifier
{
    if (self.setUpSuccess)
    {
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        NSString *processDefinitionID = kAlfrescoActivitiAdhocProcessDefinition;
        if (!self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
        {
            processDefinitionID = [kAlfrescoActivitiPrefix stringByAppendingString:kAlfrescoActivitiAdhocProcessDefinition];
        }
        
        [self createTaskAndProcessWithProcessDefinitionIdentifier:processDefinitionID completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
            if (creationError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                [self.workflowService retrieveTaskWithIdentifier:task.identifier completionBlock:^(AlfrescoWorkflowTask *retrievedTask, NSError *retrieveError) {
                    if (retrieveError)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveError localizedDescription], [retrieveError localizedFailureReason]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        XCTAssertEqualObjects(task.identifier, retrievedTask.identifier, @"The task identifier property does not match");
                        XCTAssertEqualObjects(task.processIdentifier, retrievedTask.processIdentifier, @"The task processIdentifier property does not match");
                        XCTAssertEqualObjects(task.processDefinitionIdentifier, retrievedTask.processDefinitionIdentifier, @"The task processDefinitionIdentifier property does not match");
                        XCTAssertEqualObjects(task.startedAt, retrievedTask.startedAt, @"The task startedAt property does not match");
                        XCTAssertEqualObjects(task.endedAt, retrievedTask.endedAt, @"The task endedAt property does not match");
                        XCTAssertEqualObjects(task.dueAt, retrievedTask.dueAt, @"The task dueAt property does not match");
                        XCTAssertEqualObjects(task.summary, retrievedTask.summary, @"The task summary property does not match");
                        XCTAssertEqualObjects(task.priority, retrievedTask.priority, @"The task priority property does not match");
                        XCTAssertEqualObjects(task.assigneeIdentifier, retrievedTask.assigneeIdentifier, @"The task assigneeIdentifier property does not match");
                        
                        [self deleteCreatedTestProcess:process completionBlock:^(BOOL succeeded, NSError *error) {
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

- (void)testAssignTask
{
    if (self.setUpSuccess)
    {
        self.personService = [[AlfrescoPersonService alloc] initWithSession:self.currentSession];
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        NSString *newAssignee = self.secondUsername;
        
        [self.personService retrievePersonWithIdentifier:newAssignee completionBlock:^(AlfrescoPerson *person, NSError *personError) {
            if (personError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [personError localizedDescription], [personError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(person, @"Person should not be nil");
                
                NSString *processDefinitionID = kAlfrescoActivitiAdhocProcessDefinition;
                if (!self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
                {
                    processDefinitionID = [kAlfrescoActivitiPrefix stringByAppendingString:kAlfrescoActivitiAdhocProcessDefinition];
                }
                
                [self createTaskAndProcessWithProcessDefinitionIdentifier:processDefinitionID completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
                    if (creationError)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        [self.workflowService reassignTask:task toAssignee:person completionBlock:^(AlfrescoWorkflowTask *assignedTask, NSError *assignError) {
                            if (assignError)
                            {
                                self.lastTestSuccessful = NO;
                                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [assignError localizedDescription], [assignError localizedFailureReason]];
                                self.callbackCompleted = YES;
                            }
                            else
                            {
                                XCTAssertNotNil(assignedTask, @"Assigned task should not be nil");
                                XCTAssertTrue([task.identifier isEqualToString:assignedTask.identifier], @"Expected the assigned task to have the same id");
                                
                                // only test the following on non-public API servers due to ALF-20568 (assignee is not updated in response)
                                if (!self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
                                {
                                    XCTAssertTrue([assignedTask.assigneeIdentifier isEqualToString:newAssignee],
                                                  @"Expected the new assignee to be %@ but it was %@", newAssignee, assignedTask.assigneeIdentifier);
                                }
                                
                                [self deleteCreatedTestProcess:process completionBlock:^(BOOL succeeded, NSError *error) {
                                    self.lastTestSuccessful = succeeded;
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
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testClaimAndUnclaim
{
    if (self.setUpSuccess)
    {
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        NSString *processDefinitionID = kAlfrescoActivitiAdhocProcessDefinition;
        if (!self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
        {
            processDefinitionID = [kAlfrescoActivitiPrefix stringByAppendingString:kAlfrescoActivitiAdhocProcessDefinition];
        }
        
        [self createTaskAndProcessWithProcessDefinitionIdentifier:processDefinitionID completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
            if (creationError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                [self.workflowService unclaimTask:task completionBlock:^(AlfrescoWorkflowTask *unclaimedTask, NSError *unclaimError) {
                    if (unclaimError)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [unclaimError localizedDescription], [unclaimError localizedFailureReason]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        XCTAssertNotNil(unclaimedTask, @"Unclaimed task should not be nil");
                        XCTAssertTrue([task.identifier isEqualToString:unclaimedTask.identifier], @"Expected the unclaimed task to have the same id");
                        
                        // only test the following on non-public API servers due to ALF-20568 (assignee is not updated in response)
                        if (!self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
                        {
                            XCTAssertNil(unclaimedTask.assigneeIdentifier, @"Expected unclaimedTask assignee to be nil");
                        }
                        
                        [self.workflowService claimTask:unclaimedTask completionBlock:^(AlfrescoWorkflowTask *claimedTask, NSError *claimingError) {
                            if (claimingError)
                            {
                                self.lastTestSuccessful = NO;
                                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [claimingError localizedDescription], [claimingError localizedFailureReason]];
                                self.callbackCompleted = YES;
                            }
                            else
                            {
                                XCTAssertNotNil(claimedTask, @"Claimed task should not be nil");
                                XCTAssertTrue([claimedTask.assigneeIdentifier isEqualToString:self.currentSession.personIdentifier], @"The task has not been successfully claimed");
                                
                                [self deleteCreatedTestProcess:process completionBlock:^(BOOL succeeded, NSError *error) {
                                    self.lastTestSuccessful = succeeded;
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
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testCompleteTask
{
    if (self.setUpSuccess)
    {
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        NSString *processDefinitionID = kAlfrescoActivitiAdhocProcessDefinition;
        if (!self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
        {
            processDefinitionID = [kAlfrescoActivitiPrefix stringByAppendingString:kAlfrescoActivitiAdhocProcessDefinition];
        }
        
        [self createTaskAndProcessWithProcessDefinitionIdentifier:processDefinitionID completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
            if (creationError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                [self.workflowService completeTask:task properties:nil completionBlock:^(AlfrescoWorkflowTask *completedTask, NSError *completedError) {
                    if (completedError)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [completedError localizedDescription], [completedError localizedFailureReason]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        XCTAssertNotNil(completedTask, @"Completed task should not be nil");
                        XCTAssertNotNil(completedTask.identifier, @"Expected the identifier property to be populated");
                        XCTAssertNotNil(completedTask.processIdentifier, @"Expected the processIdentifier property to be populated");
                        XCTAssertNotNil(completedTask.name, @"Expected the name property to be populated");
                        XCTAssertNotNil(completedTask.priority, @"Expected the priority property to be populated");
                        XCTAssertNotNil(completedTask.assigneeIdentifier, @"Expected the assigneeIdentifier property to be populated");
                        XCTAssertNotNil(completedTask.endedAt, @"Expected the endedAt property to be populated");
                        
                        [self deleteCreatedTestProcess:process completionBlock:^(BOOL succeeded, NSError *error) {
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

- (void)testAddRetrieveAndDeleteAttachment
{
    if (self.setUpSuccess)
    {
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        NSString *processDefinitionID = kAlfrescoActivitiAdhocProcessDefinition;
        if (!self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
        {
            processDefinitionID = [kAlfrescoActivitiPrefix stringByAppendingString:kAlfrescoActivitiAdhocProcessDefinition];
        }
        
        __weak typeof(self) weakSelf = self;
        
        [self createTaskAndProcessWithProcessDefinitionIdentifier:processDefinitionID completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
            if (creationError)
            {
                weakSelf.lastTestSuccessful = NO;
                weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                weakSelf.callbackCompleted = YES;
            }
            else
            {
                [weakSelf.workflowService addAttachmentsToTask:task attachments:@[self.testAlfrescoDocument] completionBlock:^(BOOL succeeded, NSError *addError) {
                    if (addError)
                    {
                        weakSelf.lastTestSuccessful = NO;
                        weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [addError localizedDescription], [addError localizedFailureReason]];
                        weakSelf.callbackCompleted = YES;
                    }
                    else
                    {
                        XCTAssertNotNil(task, @"Returned task should not be nil");
                        
                        [weakSelf.workflowService retrieveAttachmentsForTask:task completionBlock:^(NSArray *array, NSError *retrieveError) {
                            if (retrieveError)
                            {
                                weakSelf.lastTestSuccessful = NO;
                                weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [addError localizedDescription], [addError localizedFailureReason]];
                                weakSelf.callbackCompleted = YES;
                            }
                            else
                            {
                                XCTAssertNotNil(array, @"Returned array should not be nil");
                                XCTAssertTrue(array.count == 1, @"Array should contain one item");
                                
                                AlfrescoDocument *document = array[0];
                                XCTAssertTrue([document.identifier isEqualToString:self.testAlfrescoDocument.identifier],
                                              @"Expected the attached document to have the same identifier as the document passed to the addAttachmentsToTask method");
                                
                                [weakSelf.workflowService removeAttachmentFromTask:task attachment:document completionBlock:^(BOOL removalSuccess, NSError *removeAttachmentError) {
                                    XCTAssertTrue(removalSuccess, @"The removal of the attachment did not return true");
                                    XCTAssertNil(removeAttachmentError, @"The returned error should be nil");
                                        
                                    [weakSelf deleteCreatedTestProcess:process completionBlock:^(BOOL succeeded, NSError *error) {
                                        weakSelf.lastTestSuccessful = succeeded;
                                        weakSelf.callbackCompleted = YES;
                                    }];
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
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testResolveTask
{
    if (self.setUpSuccess)
    {
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        NSString *processDefinitionID = kAlfrescoActivitiAdhocProcessDefinition;
        if (!self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
        {
            processDefinitionID = [kAlfrescoActivitiPrefix stringByAppendingString:kAlfrescoActivitiAdhocProcessDefinition];
        }
            
        [self createTaskAndProcessWithProcessDefinitionIdentifier:processDefinitionID completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
            if (creationError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                [self.workflowService resolveTask:task completionBlock:^(AlfrescoWorkflowTask *resolvedTask, NSError *resolveError) {
                    if (self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
                    {
                        if (resolveError)
                        {
                            self.lastTestSuccessful = NO;
                            self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [resolveError localizedDescription], [resolveError localizedFailureReason]];
                            self.callbackCompleted = YES;
                        }
                        else
                        {
                            XCTAssertNotNil(resolvedTask, @"The resolved task should not be nil");
                            XCTAssertNotNil(resolvedTask.identifier, @"Expected the identifier property to be populated");
                            XCTAssertNotNil(resolvedTask.processIdentifier, @"Expected the processIdentifier property to be populated");
                            XCTAssertNotNil(resolvedTask.name, @"Expected the name property to be populated");
                            XCTAssertNotNil(resolvedTask.priority, @"Expected the priority property to be populated");
                            
                            // only test the following on non-public API servers due to a bug on the public API
                            if (!self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
                            {
                                XCTAssertNotNil(resolvedTask.endedAt, @"Expected the endedAt property to be populated");
                                XCTAssertNotNil(resolvedTask.assigneeIdentifier, @"Expected the assigneeIdentifier property to be populated");
                            }
                            
                            [self deleteCreatedTestProcess:process completionBlock:^(BOOL succeeded, NSError *error) {
                                self.lastTestSuccessful = succeeded;
                                self.callbackCompleted = YES;
                            }];
                        }
                    }
                    else
                    {
                        XCTAssertNil(resolvedTask, @"Resolved task should be nil");
                        XCTAssertNotNil(resolveError, @"Resolving using the Old API should have thrown an error");
                        XCTAssertEqualObjects(resolveError.localizedDescription, kAlfrescoErrorDescriptionWorkflowFunctionNotSupported, @"Expected the error description to be - %@, instead got back an error description of - %@", kAlfrescoErrorDescriptionWorkflowFunctionNotSupported, resolveError.localizedDescription);
                        XCTAssertTrue(resolveError.code == kAlfrescoErrorCodeWorkflowFunctionNotSupported, @"Expected the error code %ld, instead got back %li", (long)kAlfrescoErrorCodeWorkflowFunctionNotSupported, (long)resolveError.code);
                        
                        self.lastTestSuccessful = YES;
                        self.callbackCompleted = YES;
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

#pragma mark - Private Functions

- (void)createTaskAndProcessWithProcessDefinitionIdentifier:(NSString *)processDefinitionID completionBlock:(void (^)(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *error))completionBlock
{
    self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
    [self.workflowService retrieveProcessDefinitionWithIdentifier:processDefinitionID completionBlock:^(AlfrescoWorkflowProcessDefinition *processDefinition, NSError *retrieveError) {
        // define creation block
        void (^createProcessAndTaskForDefinition)(AlfrescoWorkflowProcessDefinition *definition) = ^(AlfrescoWorkflowProcessDefinition *definition) {
            
            // provide a description for the process
            NSString *processName = [NSString stringWithFormat:@"iOS SDK Test Process - %@", [NSDate date]];
            NSDictionary *processVariables = @{kAlfrescoWorkflowProcessDescription: processName};
            
            [self.workflowService startProcessForProcessDefinition:definition assignees:nil variables:processVariables attachments:nil completionBlock:^(AlfrescoWorkflowProcess *process, NSError *startError) {
                if (startError)
                {
                    completionBlock(nil, nil, retrieveError);
                }
                else
                {
                    [self.workflowService retrieveTasksForProcess:process completionBlock:^(NSArray *array, NSError *retrieveTaskError) {
                        if (retrieveTaskError)
                        {
                            completionBlock(process, nil, retrieveTaskError);
                        }
                        else
                        {
                            if (array.count > 0)
                            {
                                AlfrescoWorkflowTask *returnedTask = nil;
                                if ([AlfrescoWorkflowUtils isJBPMProcess:process])
                                {
                                    returnedTask = [array lastObject];
                                }
                                else
                                {
                                    returnedTask = array[0];
                                }
                                completionBlock(process, returnedTask, retrieveTaskError);
                            }
                            else
                            {
                                completionBlock(process, nil, retrieveTaskError);
                            }
                        }
                    }];
                }
            }];
        };
        
        if (retrieveError)
        {
            if (retrieveError.code == kAlfrescoErrorCodeWorkflowFunctionNotSupported)
            {
                NSDictionary *properties = @{@"id" : @"jbpm$1",
                                             @"url" : @"api/workflow-definitions/jbpm$1",
                                             @"name" : kAlfrescoJBPMAdhocProcessDefinition,
                                             @"title" : @"Adhoc",
                                             @"description" : @"Assign task to colleague",
                                             @"version" : @"1"};
                processDefinition = [[AlfrescoWorkflowProcessDefinition alloc] initWithProperties:properties];
                createProcessAndTaskForDefinition(processDefinition);
            }
            else
            {
                completionBlock(nil, nil, retrieveError);
            }
        }
        else
        {
            createProcessAndTaskForDefinition(processDefinition);
        }
    }];
}

- (void)deleteCreatedTestProcess:(AlfrescoWorkflowProcess *)process completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];

    [self.workflowService deleteProcess:process completionBlock:^(BOOL succeeded, NSError *deleteError) {
        if (deleteError)
        {
            completionBlock(NO, deleteError);
        }
        else
        {
            completionBlock(YES, deleteError);
        }
    }];
}

@end
