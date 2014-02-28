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

/** AlfrescoWorkflowTaskServiceTest
 
 Author: Tauseef Mughal (Alfresco)
 */

#import "AlfrescoWorkflowTaskServiceTest.h"
#import "AlfrescoWorkflowTaskService.h"
#import "AlfrescoWorkflowProcessService.h"
#import "AlfrescoWorkflowProcessDefinitionService.h"
#import "AlfrescoWorkflowUtils.h"
#import "AlfrescoPersonService.h"
#import "AlfrescoErrors.h"

@interface AlfrescoWorkflowTaskServiceTest ()

@property (nonatomic, strong) AlfrescoWorkflowProcessDefinitionService *processDefinitionService;
@property (nonatomic, strong) AlfrescoWorkflowProcessService *processService;
@property (nonatomic, strong) AlfrescoWorkflowTaskService *taskService;
@property (nonatomic, strong) AlfrescoPersonService *personService;

@end

@implementation AlfrescoWorkflowTaskServiceTest

- (void)testRetrieveAllTasks
{
    if (self.setUpSuccess)
    {
        self.taskService = [[AlfrescoWorkflowTaskService alloc] initWithSession:self.currentSession];
        
        [self.taskService retrieveAllTasksWithCompletionBlock:^(NSArray *array, NSError *error) {
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
                
                // TODO
                
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

- (void)testRetrieveTasksWithListingContext
{
    if (self.setUpSuccess)
    {
        self.taskService = [[AlfrescoWorkflowTaskService alloc] initWithSession:self.currentSession];
        
        AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:10 skipCount:0];
        
        [self.taskService retrieveTasksWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *retrieveError) {
            if (retrieveError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveError localizedDescription], [retrieveError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(pagingResult, @"The paging result should not be nil");
                XCTAssertTrue(pagingResult.objects.count <= 10, @"The paging result brought back more than 10 items");
                
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

- (void)testRetrieveTaskByTaskByProcess
{
    if (self.setUpSuccess)
    {
        self.processService = [[AlfrescoWorkflowProcessService alloc] initWithSession:self.currentSession];
        
        [self createTaskAndProcessWithProcessDefinitionIdentifier:@"activitiAdhoc:1:4" completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
            if (creationError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                [self.processService retrieveAllTasksForProcess:process completionBlock:^(NSArray *array, NSError *retrieveTaskError) {
                    if (retrieveTaskError)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveTaskError localizedDescription], [retrieveTaskError localizedFailureReason]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        XCTAssertNotNil(array, @"Returned array should not be nil");
                        XCTAssertTrue(array.count > 0, @"Tasks array should contain atleast one task");
                        
                        // TODO
                        
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
        self.taskService = [[AlfrescoWorkflowTaskService alloc] initWithSession:self.currentSession];
        
        [self createTaskAndProcessWithProcessDefinitionIdentifier:@"activitiAdhoc:1:4" completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
            if (creationError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                [self.taskService retrieveTaskWithIdentifier:task.identifier completionBlock:^(AlfrescoWorkflowTask *retrievedTask, NSError *retrieveError) {
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
                        XCTAssertEqualObjects(task.taskDescription, retrievedTask.taskDescription, @"The task taskDescription property does not match");
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
        self.taskService = [[AlfrescoWorkflowTaskService alloc] initWithSession:self.currentSession];
        
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
                
                [self createTaskAndProcessWithProcessDefinitionIdentifier:@"activitiAdhoc:1:4" completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
                    if (creationError)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        [self.taskService assignTask:task toAssignee:person completionBlock:^(AlfrescoWorkflowTask *assignedTask, NSError *assignError) {
                            if (assignError)
                            {
                                self.lastTestSuccessful = NO;
                                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [assignError localizedDescription], [assignError localizedFailureReason]];
                                self.callbackCompleted = YES;
                            }
                            else
                            {
                                XCTAssertNotNil(assignedTask, @"Updated task should not be nil");
                                NSLog(@"%@ %@", newAssignee, task.assigneeIdentifier);
                                
                                // Commented out - KNOWN BUG IN JSON RESPONSE FROM SERVER - Public API (See ALF-20568)
//                                XCTAssertTrue([task.assigneeIdentifier isEqualToString:newAssignee], @"The new assignee identifier has not been updated");
                                
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
        self.taskService = [[AlfrescoWorkflowTaskService alloc] initWithSession:self.currentSession];
        
        [self createTaskAndProcessWithProcessDefinitionIdentifier:@"activitiAdhoc:1:4" completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
            if (creationError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                [self.taskService unclaimTask:task completionBlock:^(AlfrescoWorkflowTask *unclaimedTask, NSError *unclaimError) {
                    if (unclaimError)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [unclaimError localizedDescription], [unclaimError localizedFailureReason]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        // RESPONSE NOT UPDATED WITH CORRECT VALUES
//                        XCTAssertNil(unclaimedTask.assigneeIdentifier, @"Assignee Identifier should be nil");
                        
                        [self.taskService claimTask:unclaimedTask completionBlock:^(AlfrescoWorkflowTask *claimedTask, NSError *claimingError) {
                            if (claimingError)
                            {
                                self.lastTestSuccessful = NO;
                                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [claimingError localizedDescription], [claimingError localizedFailureReason]];
                                self.callbackCompleted = YES;
                            }
                            else
                            {
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
        self.taskService = [[AlfrescoWorkflowTaskService alloc] initWithSession:self.currentSession];
        
        [self createTaskAndProcessWithProcessDefinitionIdentifier:@"activitiAdhoc:1:4" completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
            if (creationError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                [self.taskService completeTask:task properties:nil completionBlock:^(AlfrescoWorkflowTask *completedTask, NSError *completedError) {
                    if (completedError)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [completedError localizedDescription], [completedError localizedFailureReason]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        XCTAssertNotNil(completedTask, @"Returned task should not be nil");
                        
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
        self.taskService = [[AlfrescoWorkflowTaskService alloc] initWithSession:self.currentSession];
        
        __weak typeof(self) weakSelf = self;
        
        [self createTaskAndProcessWithProcessDefinitionIdentifier:@"activitiAdhoc:1:4" completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
            if (creationError)
            {
                weakSelf.lastTestSuccessful = NO;
                weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                weakSelf.callbackCompleted = YES;
            }
            else
            {
                [weakSelf.taskService addAttachments:@[self.testAlfrescoDocument] toTask:task completionBlock:^(BOOL succeeded, NSError *addError) {
                    if (addError)
                    {
                        weakSelf.lastTestSuccessful = NO;
                        weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [addError localizedDescription], [addError localizedFailureReason]];
                        weakSelf.callbackCompleted = YES;
                    }
                    else
                    {
                        XCTAssertNotNil(task, @"Returned task should not be nil");
                        
                        [weakSelf.taskService retrieveAttachmentsForTask:task completionBlock:^(NSArray *array, NSError *retrieveError) {
                            if (retrieveError)
                            {
                                weakSelf.lastTestSuccessful = NO;
                                weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [addError localizedDescription], [addError localizedFailureReason]];
                                weakSelf.callbackCompleted = YES;
                            }
                            else
                            {
                                XCTAssertNotNil(array, @"Returned array should not be nil");
                                XCTAssertTrue(array.count > 0, @"Array should contain more than one item");
                                
                                AlfrescoDocument *document = array[0];
                                
                                [weakSelf.taskService removeAttachment:document fromTask:task completionBlock:^(BOOL removalSuccess, NSError *removeAttachmentError) {
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
        self.taskService = [[AlfrescoWorkflowTaskService alloc] initWithSession:self.currentSession];
            
        [self createTaskAndProcessWithProcessDefinitionIdentifier:@"activitiAdhoc:1:4" completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
            if (creationError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                [self.taskService resolveTask:task completionBlock:^(AlfrescoWorkflowTask *resolvedTask, NSError *resolveError) {
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
                            
                            /**
                             * MJH: Removed 08/Jan/2014 as Public API does not return endedAt property for task updates (as per API docs)
                             *
                            XCTAssertNotNil(resolvedTask.endedAt, @"The resolved tasks endedAt property should not be nil");
                             */
                            
                            // TODO
                            
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
    self.processDefinitionService = [[AlfrescoWorkflowProcessDefinitionService alloc] initWithSession:self.currentSession];
    self.processService = [[AlfrescoWorkflowProcessService alloc] initWithSession:self.currentSession];
        
    [self.processDefinitionService retrieveProcessDefinitionWithIdentifier:processDefinitionID completionBlock:^(AlfrescoWorkflowProcessDefinition *processDefinition, NSError *retrieveError) {
        // define creation block
        void (^createProcessAndTaskForDefinition)(AlfrescoWorkflowProcessDefinition *definition) = ^(AlfrescoWorkflowProcessDefinition *definition) {
            [self.processService startProcessForProcessDefinition:definition assignees:nil variables:nil attachments:nil completionBlock:^(AlfrescoWorkflowProcess *process, NSError *startError) {
                if (startError)
                {
                    completionBlock(nil, nil, retrieveError);
                }
                else
                {
                    [self.processService retrieveAllTasksForProcess:process completionBlock:^(NSArray *array, NSError *retrieveTaskError) {
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
                                             @"name" : @"jbpm$wf:adhoc",
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
    self.processService = [[AlfrescoWorkflowProcessService alloc] initWithSession:self.currentSession];

    [self.processService deleteProcess:process completionBlock:^(BOOL succeeded, NSError *deleteError) {
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
