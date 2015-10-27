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
static NSString * const kAlfrescoAdhocTaskType = @"wf:adhocTask";
static NSString * const kAlfrescoSubmitAdhocTaskType = @"wf:submitAdhocTask";
static NSString * const kAlfrescoJBPMAdhocProcessDefinitionKey = @"wf:adhoc";
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
                            XCTAssertTrue([task.identifier rangeOfString:kAlfrescoJBPMPrefix].location != NSNotFound, @"Expected identifier to contain jbpm$ but it was %@", task.identifier);
                            XCTAssertTrue([task.processIdentifier rangeOfString:kAlfrescoJBPMPrefix].location != NSNotFound, @"Expected processIdentifier to contain jbpm$ but it was %@", task.processIdentifier);
                            XCTAssertTrue([task.name isEqualToString:@"Review"] || [task.name isEqualToString:@"Approved"], @"Expected task summary to be 'Review' or 'Approved' but it was %@", task.name);
                            
                            XCTAssertNotNil(task.summary, @"Expected the name property to be populated");
                            XCTAssertNotNil(task.type, @"Expected the type property to be populated");
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
                                XCTAssertTrue([task.name isEqualToString:@"Review Task"],
                                              @"Expected task name to be 'Review Task' but it was %@", task.name);
                                
                                XCTAssertNotNil(task.identifier, @"Expected the identifier property to be populated");
                                XCTAssertNotNil(task.processIdentifier, @"Expected the processIdentifier property to be populated");
                                XCTAssertNotNil(task.name, @"Expected the name property to be populated");
                                XCTAssertNotNil(task.type, @"Expected the type property to be populated");
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
                                XCTAssertTrue([task.name isEqualToString:@"Review"],
                                              @"Expected task name to be 'Review' but it was %@", task.name);
                                
                                XCTAssertNotNil(task.summary, @"Expected the name property to be populated");
                                XCTAssertNotNil(task.type, @"Expected the type property to be populated");
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

- (void)testRetrieveTasksWithHighPriority
{
    if (self.setUpSuccess)
    {
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        // setup variables to create process with
        NSDictionary *variables = @{kAlfrescoWorkflowVariableProcessPriority: @(1)};
        
        // create a workflow with high priority
        [self createAdhocTaskAndProcessWithVariables:variables completionBlock:^(AlfrescoWorkflowProcess *createdProcess, AlfrescoWorkflowTask *createdTask, NSError *creationError) {
            if (createdProcess == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [self failureMessageFromError:creationError];
                self.callbackCompleted = YES;
            }
            else
            {
                // create filter to only return high priority workflows
                AlfrescoListingFilter *listingFilter = [[AlfrescoListingFilter alloc]
                                                        initWithFilter:kAlfrescoFilterByWorkflowPriority value:kAlfrescoFilterValueWorkflowPriorityHigh];
                AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithListingFilter:listingFilter];
                
                [self.workflowService retrieveTasksWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *retrieveError) {
                    if (retrieveError)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [self failureMessageFromError:retrieveError];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        XCTAssertTrue(pagingResult.objects.count >= 1, @"There should be at least one result");
                        
                        // check every task returned has a high priority
                        for (AlfrescoWorkflowTask *task in pagingResult.objects)
                        {
                            XCTAssertTrue(task.priority.intValue == 1,
                                          @"Only expected to get tasks that are high priority but task %@ has a priority of: %d",
                                          task.identifier, task.priority.intValue);
                        }
                        
                        // delete the process we created
                        [self deleteCreatedTestProcess:createdProcess completionBlock:^(BOOL succeeded, NSError *deleteError) {
                            self.lastTestSuccessful = YES;
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

- (void)testRetrieveTasksDueInNext7Days
{
    if (self.setUpSuccess)
    {
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        // setup variables to create process with (due date in 5 days time)
        NSDate *dateNow = [[NSDate alloc] init];
        NSDate *dueDate = [dateNow dateByAddingTimeInterval:(60*60*24*5)];
        NSDate *oneWeekDate = [dateNow dateByAddingTimeInterval:(60*60*24*7)];
        NSDictionary *variables = @{kAlfrescoWorkflowVariableProcessDueDate: dueDate};
        
        // create a workflow with high priority
        [self createAdhocTaskAndProcessWithVariables:variables completionBlock:^(AlfrescoWorkflowProcess *createdProcess, AlfrescoWorkflowTask *createdTask, NSError *creationError) {
            if (createdProcess == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [self failureMessageFromError:creationError];
                self.callbackCompleted = YES;
            }
            else
            {
                // create filter to only return high priority workflows
                AlfrescoListingFilter *listingFilter = [[AlfrescoListingFilter alloc]
                                                        initWithFilter:kAlfrescoFilterByWorkflowDueDate value:kAlfrescoFilterValueWorkflowDueDate7Days];
                AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithListingFilter:listingFilter];
                
                [self.workflowService retrieveTasksWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *retrieveError) {
                    if (retrieveError)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [self failureMessageFromError:retrieveError];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        XCTAssertTrue(pagingResult.objects.count >= 1, @"There should be at least one result");
                        
                        // check every task returned has a due date less than a week away
                        for (AlfrescoWorkflowTask *task in pagingResult.objects)
                        {
                            XCTAssertNotNil(task.dueAt, @"Expected dueAt to be populated");
                            
                            NSDate *retrievedDueDate = task.dueAt;
                            NSComparisonResult result = [retrievedDueDate compare:oneWeekDate];
                            
                            XCTAssertTrue(result == NSOrderedAscending,
                                          @"Only expected to get tasks that are due in the next week but task %@ is due: %@",
                                          task.identifier, task.dueAt);
                        }
                        
                        // delete the process we created
                        [self deleteCreatedTestProcess:createdProcess completionBlock:^(BOOL succeeded, NSError *deleteError) {
                            self.lastTestSuccessful = YES;
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

- (void)testRetrieveUnassignedTasks
{
    if (self.setUpSuccess)
    {
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        AlfrescoListingFilter *listingFilter = [[AlfrescoListingFilter alloc]
                                                initWithFilter:kAlfrescoFilterByWorkflowAssignee value:kAlfrescoFilterValueWorkflowAssigneeUnassigned];
        AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithListingFilter:listingFilter];
        
        [self.workflowService retrieveTasksWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *retrieveError) {
            if (retrieveError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [self failureMessageFromError:retrieveError];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(pagingResult, @"Paging result should not be nil");
                
                // check every task returned has a nil assignee
                for (AlfrescoWorkflowTask *task in pagingResult.objects)
                {
                    XCTAssertNil(task.assigneeIdentifier,
                                 @"Only expected to get tasks that have no assignee but task %@ is assigned to: %@",
                                task.identifier, task.assigneeIdentifier);
                }
                
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

- (void)testRetrieveCompleteTasks
{
    if (self.setUpSuccess)
    {
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        AlfrescoListingFilter *listingFilter = [[AlfrescoListingFilter alloc]
                                                initWithFilter:kAlfrescoFilterByWorkflowStatus value:kAlfrescoFilterValueWorkflowStatusCompleted];
        AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithListingFilter:listingFilter];
        
        [self.workflowService retrieveTasksWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *retrieveError) {
            if (retrieveError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [self failureMessageFromError:retrieveError];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(pagingResult, @"Paging result should not be nil");
                
                // check every task returned has an end date and is marked as complete
                for (AlfrescoWorkflowTask *task in pagingResult.objects)
                {
                    XCTAssertTrue(task.completed,
                                  @"Only expected to get tasks that are complete but task %@ is not", task.identifier);
                    
                    // A bug on 4.0.x servers can leave the endDate unset so don't test
                    if (!([self.currentSession.repositoryInfo.majorVersion intValue] == 4 &&
                          [self.currentSession.repositoryInfo.minorVersion intValue] == 0))
                    {
                        XCTAssertNotNil(task.endedAt,
                                        @"Only expected to get tasks that have an end date but task %@ does not", task.identifier);
                    }
                }
                
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

- (void)testRetrieveTasksForProcess
{
    if (self.setUpSuccess)
    {
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        NSString *processDefinitionID = kAlfrescoActivitiAdhocProcessDefinition;
        if (!self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
        {
            processDefinitionID = [kAlfrescoActivitiPrefix stringByAppendingString:kAlfrescoActivitiAdhocProcessDefinition];
        }
        
        [self createAdhocTaskAndProcessWithVariables:nil completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
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
                        XCTAssertNotNil(firstRetrievedTask.type, @"Expected the type property to be populated");
                        XCTAssertNotNil(firstRetrievedTask.summary, @"Expected the summary property to be populated");
                        XCTAssertNotNil(firstRetrievedTask.priority, @"Expected the priority property to be populated");
                        XCTAssertNotNil(firstRetrievedTask.assigneeIdentifier, @"Expected the assigneeIdentifier property to be populated");
                        
                        XCTAssertTrue([firstRetrievedTask.processDefinitionIdentifier rangeOfString:@"dhoc"].location != NSNotFound,
                                      @"Expected processDefinitionIdentifier to contain 'dhoc' but it was %@", firstRetrievedTask.processDefinitionIdentifier);
                        
                        if (self.currentSession.repositoryInfo.capabilities.doesSupportActivitiWorkflowEngine)
                        {
                            XCTAssertTrue([firstRetrievedTask.type isEqualToString:kAlfrescoAdhocTaskType],
                                          @"Expected type of task to be %@ but it was %@", kAlfrescoAdhocTaskType, firstRetrievedTask.type);
                        }
                        else
                        {
                            XCTAssertTrue([firstRetrievedTask.type isEqualToString:kAlfrescoSubmitAdhocTaskType],
                                          @"Expected type of task to be %@ but it was %@", kAlfrescoSubmitAdhocTaskType, firstRetrievedTask.type);
                        }
                        
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
        
        [self createAdhocTaskAndProcessWithVariables:nil completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
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
                        XCTAssertEqualObjects(task.type, retrievedTask.type, @"The task type property does not match");
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
                
                [self createAdhocTaskAndProcessWithVariables:nil completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
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
                                
                                // Re-query the task on non-public API servers due to ALF-20568 (assignee is not updated in response)
                                if (self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
                                {
                                    [self.workflowService retrieveTaskWithIdentifier:task.identifier completionBlock:^(AlfrescoWorkflowTask *reassignedTask, NSError *error) {
                                        XCTAssertTrue([reassignedTask.assigneeIdentifier isEqualToString:newAssignee],
                                                      @"Expected the new assignee to be %@ but it was %@", newAssignee, reassignedTask.assigneeIdentifier);
                                    }];
                                }
                                else
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
        
        [self createAdhocTaskAndProcessWithVariables:nil completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
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
                        
                        // Re-query the task on non-public API servers due to ALF-20568 (assignee is not updated in response)
                        if (self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
                        {
                            [self.workflowService retrieveTaskWithIdentifier:task.identifier completionBlock:^(AlfrescoWorkflowTask *requeriedTask, NSError *error) {
                                XCTAssertNil(requeriedTask.assigneeIdentifier, @"Expected unclaimedTask assignee to be nil");
                            }];
                        }
                        else
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
        
        [self createAdhocTaskAndProcessWithVariables:nil completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
            if (creationError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [self failureMessageFromError:creationError];
                self.callbackCompleted = YES;
            }
            else
            {
                NSString *taskComment = @"Comment added by SDK tests";
                NSDictionary *variables = @{kAlfrescoWorkflowVariableTaskComment: taskComment};
                
                [self.workflowService completeTask:task variables:variables completionBlock:^(AlfrescoWorkflowTask *completedTask, NSError *completedError) {
                    if (completedError)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [self failureMessageFromError:completedError];
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
                        XCTAssertTrue(completedTask.completed, @"Expected the completed property to be true");
                        
                        // retrieve the variables for the task and ensure the comment was saved
                        [self.workflowService retrieveVariablesForTask:completedTask completionBlock:^(NSDictionary *variables, NSError *retrieveError) {
                            if (retrieveError)
                            {
                                self.lastTestSuccessful = NO;
                                self.lastTestFailureMessage = [self failureMessageFromError:retrieveError];
                                self.callbackCompleted = YES;
                            }
                            else
                            {
                                AlfrescoProperty *updatedComment = variables[kAlfrescoWorkflowVariableTaskComment];
                                XCTAssertNotNil(updatedComment, @"Expected to find the comment variable");
                                XCTAssertTrue([updatedComment.value isEqualToString:taskComment],
                                              @"Expected the comment variable to be '%@' but it was: %@", taskComment, updatedComment.value);
                                
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
        
        [self createAdhocTaskAndProcessWithVariables:nil completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
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
        
        [self createAdhocTaskAndProcessWithVariables:nil completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
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
                                weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveError localizedDescription], [retrieveError localizedFailureReason]];
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

- (void)testRetrieveNoAttachments
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
        
        [self createAdhocTaskAndProcessWithVariables:nil completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
            if (creationError)
            {
                weakSelf.lastTestSuccessful = NO;
                weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                weakSelf.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(task, @"Returned task should not be nil");
                
                [weakSelf.workflowService retrieveAttachmentsForTask:task completionBlock:^(NSArray *array, NSError *retrieveError) {
                    if (retrieveError)
                    {
                        weakSelf.lastTestSuccessful = NO;
                        weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveError localizedDescription], [retrieveError localizedFailureReason]];
                        weakSelf.callbackCompleted = YES;
                    }
                    else
                    {
                        XCTAssertNotNil(array, @"Returned array should not be nil");
                        XCTAssertTrue(array.count == 0, @"Array should be empty");
                            
                        [weakSelf deleteCreatedTestProcess:process completionBlock:^(BOOL succeeded, NSError *error) {
                            weakSelf.lastTestSuccessful = succeeded;
                            weakSelf.callbackCompleted = YES;
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
        [self createAdhocTaskAndProcessWithVariables:variables
                                     completionBlock:^(AlfrescoWorkflowProcess *createdProcess, AlfrescoWorkflowTask *createdTask, NSError *creationError) {
            if (createdProcess == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [self failureMessageFromError:creationError];
                self.callbackCompleted = YES;
            }
            else
            {
                // setup variables to update on process
                NSNumber *taskPriority = [NSNumber numberWithInt:1];
                NSNumber *taskStatus = [NSNumber numberWithInt:1];
                NSString *taskComment = @"Comment for the task";
                
                NSDictionary *variables = @{kAlfrescoWorkflowVariableTaskStatus: taskStatus,
                                            kAlfrescoWorkflowVariableTaskComment: taskComment,
                                            @"bpm:priority": taskPriority};
                
                // update the variables on the process just created
                [self.workflowService updateVariablesForTask:createdTask variables:variables completionBlock:^(BOOL succeeded, NSError *updateError) {
                    if (!succeeded)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [self failureMessageFromError:updateError];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        [self.workflowService retrieveVariablesForTask:createdTask completionBlock:^(NSDictionary *variables, NSError *retrieveError) {
                          if (variables == nil)
                          {
                              self.lastTestSuccessful = NO;
                              self.lastTestFailureMessage = [self failureMessageFromError:retrieveError];
                              self.callbackCompleted = YES;
                          }
                          else
                          {
                              // ensure the common variables are present and correct
                              AlfrescoProperty *taskDescription = variables[@"bpm:description"];
                              AlfrescoProperty *taskPackageActionGroup = variables[@"bpm:packageActionGroup"];
                              XCTAssertNotNil(taskDescription, @"Expected to find the description variable");
                              XCTAssertNotNil(taskPackageActionGroup, @"Expected to find the due package action group variable");
                              XCTAssertTrue([taskDescription.value isEqualToString:processDescription],
                                            @"Expected the description variable to be '%@' but it was: %@", processDescription, taskDescription.value);
                              XCTAssertTrue([taskPackageActionGroup.value isEqualToString:@"add_package_item_actions"],
                                            @"Expected the package action group variable to be 'add_package_item_actions' but it was: %@", taskPackageActionGroup.value);
                              
                              if (self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
                              {
                                  // for some reason the task specific due date is not returned by the public API
                                  // so look for the workflow wide due date instead
                                  AlfrescoProperty *taskDueDate = variables[kAlfrescoWorkflowVariableProcessDueDate];
                                  XCTAssertNotNil(taskDueDate, @"Expected to find the due date variable");
                              }
                              else
                              {
                                  AlfrescoProperty *taskDueDate = variables[@"bpm:dueDate"];
                                  XCTAssertNotNil(taskDueDate, @"Expected to find the due date variable");
                              }
                              
                              // ensure the updated variables are present and correct
                              AlfrescoProperty *updatedPriority = variables[@"bpm:priority"];
                              XCTAssertNotNil(updatedPriority, @"Expected to find the priority variable");
                              XCTAssertTrue([updatedPriority.value intValue] == taskPriority.intValue,
                                            @"Expected the priority variable to be '%@' but it was: %@", taskPriority, updatedPriority.value);

                              AlfrescoProperty *updatedStatus = variables[kAlfrescoWorkflowVariableTaskStatus];
                              XCTAssertNotNil(updatedStatus, @"Expected to find the status variable");
                              XCTAssertTrue([updatedStatus.value intValue] == taskStatus.intValue,
                                            @"Expected the status variable to be '%@' but it was: %@", taskStatus, updatedStatus.value);
                              
                              AlfrescoProperty *updatedComment = variables[kAlfrescoWorkflowVariableTaskComment];
                              XCTAssertNotNil(updatedComment, @"Expected to find the comment variable");
                              XCTAssertTrue([updatedComment.value isEqualToString:taskComment],
                                            @"Expected the comment variable to be '%@' but it was: %@", taskComment, updatedComment.value);
                              
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
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

#pragma mark - Private Functions

- (void)createAdhocTaskAndProcessWithVariables:(NSDictionary *)variables
                               completionBlock:(void (^)(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *error))completionBlock
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
        // define creation block
        void (^createProcessAndTaskForDefinition)(AlfrescoWorkflowProcessDefinition *definition) = ^(AlfrescoWorkflowProcessDefinition *definition) {
            
            // make sure there is a description for the process
            NSMutableDictionary *processVariables = [NSMutableDictionary dictionaryWithDictionary:variables];
            if (processVariables[kAlfrescoWorkflowVariableProcessName] == nil)
            {
                NSString *processName = [NSString stringWithFormat:@"iOS SDK Test Process - %@", [NSDate date]];
                processVariables[kAlfrescoWorkflowVariableProcessName] = processName;
            }
            
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
            // 3.x servers do not support retrieval of workflow definitions by id, f this error has occurred
            // manually construct a JBPM adhoc process definition object to use.
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
