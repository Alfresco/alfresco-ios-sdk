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
                STAssertNotNil(array, @"array should not be nil");
                STAssertTrue(array.count > 1, @"Array should contain more than 1 process");
                
                // TODO
                
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
                STAssertNotNil(pagingResult, @"The paging result should not be nil");
                STAssertTrue(pagingResult.objects.count <= 10, @"The paging result brought back more than 10 items");
                
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

- (void)testRetrieveTaskByTaskByProcess
{
    if (self.setUpSuccess)
    {
        self.processService = [[AlfrescoWorkflowProcessService alloc] initWithSession:self.currentSession];
        
        [self createTaskAndProcessWithProcessDefinitionIdentifier:@"activitiReview:1:8" completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
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
                        STAssertNotNil(array, @"Returned array should not be nil");
                        STAssertTrue(array.count > 0, @"Tasks array should contain atleast one task");
                        
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
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRetrieveTaskWithTaskIdentifier
{
    if (self.setUpSuccess)
    {
        self.taskService = [[AlfrescoWorkflowTaskService alloc] initWithSession:self.currentSession];
        
        [self createTaskAndProcessWithProcessDefinitionIdentifier:@"activitiReview:1:8" completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
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
                        STAssertEqualObjects(task.identifier, retrievedTask.identifier, @"The task identifier property does not match");
                        STAssertEqualObjects(task.processIdentifier, retrievedTask.processIdentifier, @"The task processIdentifier property does not match");
                        STAssertEqualObjects(task.processDefinitionIdentifier, retrievedTask.processDefinitionIdentifier, @"The task processDefinitionIdentifier property does not match");
                        STAssertEqualObjects(task.startedAt, retrievedTask.startedAt, @"The task startedAt property does not match");
                        STAssertEqualObjects(task.endedAt, retrievedTask.endedAt, @"The task endedAt property does not match");
                        STAssertEqualObjects(task.dueAt, retrievedTask.dueAt, @"The task dueAt property does not match");
                        STAssertEqualObjects(task.taskDescription, retrievedTask.taskDescription, @"The task taskDescription property does not match");
                        STAssertEqualObjects(task.priority, retrievedTask.priority, @"The task priority property does not match");
                        STAssertEqualObjects(task.assigneeIdentifier, retrievedTask.assigneeIdentifier, @"The task assigneeIdentifier property does not match");
                        
                        [self deleteCreatedTestProcess:process completionBlock:^(BOOL succeeded, NSError *error) {
                            self.lastTestSuccessful = succeeded;
                            self.callbackCompleted = YES;
                        }];
                    }
                }];
            }
        }];
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testAssignTask
{
    if (self.setUpSuccess)
    {
        self.personService = [[AlfrescoPersonService alloc] initWithSession:self.currentSession];
        self.taskService = [[AlfrescoWorkflowTaskService alloc] initWithSession:self.currentSession];
        
        NSString *newAssignee = @"iosunittest";
        
        [self.personService retrievePersonWithIdentifier:newAssignee completionBlock:^(AlfrescoPerson *person, NSError *personError) {
            if (personError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [personError localizedDescription], [personError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                STAssertNotNil(person, @"Person should not be nil");
                
                [self createTaskAndProcessWithProcessDefinitionIdentifier:@"activitiReview:1:8" completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
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
                                STAssertNotNil(assignedTask, @"Updated task should not be nil");
                                NSLog(@"%@ %@", newAssignee, task.assigneeIdentifier);
                                
                                // Commented out - KNOWN BUG IN JSON RESPONSE FROM SERVER - Public API
//                                STAssertTrue([task.assigneeIdentifier isEqualToString:newAssignee], @"The new assignee identifier has not bee updated");
                                
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
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testClaimAndUnclaim
{
    if (self.setUpSuccess)
    {
        self.taskService = [[AlfrescoWorkflowTaskService alloc] initWithSession:self.currentSession];
        
        [self createTaskAndProcessWithProcessDefinitionIdentifier:@"activitiReview:1:8" completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
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
//                        STAssertNil(unclaimedTask.assigneeIdentifier, @"Assignee Identifier should be nil");
                        
                        [self.taskService claimTask:unclaimedTask completionBlock:^(AlfrescoWorkflowTask *claimedTask, NSError *claimingError) {
                            if (claimingError)
                            {
                                self.lastTestSuccessful = NO;
                                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [claimingError localizedDescription], [claimingError localizedFailureReason]];
                                self.callbackCompleted = YES;
                            }
                            else
                            {
                                STAssertTrue([claimedTask.assigneeIdentifier isEqualToString:self.currentSession.personIdentifier], @"The task has not been successfully claimed");
                                
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
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testCompleteTask
{
    if (self.setUpSuccess)
    {
        self.taskService = [[AlfrescoWorkflowTaskService alloc] initWithSession:self.currentSession];
        
        [self createTaskAndProcessWithProcessDefinitionIdentifier:@"activitiReview:1:8" completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
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
                        STAssertNotNil(completedTask, @"Returned task should not be nil");
                        
                        [self deleteCreatedTestProcess:process completionBlock:^(BOOL succeeded, NSError *error) {
                            self.lastTestSuccessful = succeeded;
                            self.callbackCompleted = YES;
                        }];
                    }
                }];
            }
        }];
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testAddRetrieveAndDeleteAttachment
{
    if (self.setUpSuccess)
    {
        self.taskService = [[AlfrescoWorkflowTaskService alloc] initWithSession:self.currentSession];
        
        __weak typeof(self) weakSelf = self;
        
        [self createTaskAndProcessWithProcessDefinitionIdentifier:@"activitiReview:1:8" completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
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
                        STAssertNotNil(task, @"Returned task should not be nil");
                        
                        [weakSelf.taskService retrieveAttachmentsForTask:task completionBlock:^(NSArray *array, NSError *retrieveError) {
                            if (retrieveError)
                            {
                                weakSelf.lastTestSuccessful = NO;
                                weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [addError localizedDescription], [addError localizedFailureReason]];
                                weakSelf.callbackCompleted = YES;
                            }
                            else
                            {
                                STAssertNotNil(array, @"Returned array should not be nil");
                                STAssertTrue(array.count > 0, @"Array should contain more than one item");
                                
                                AlfrescoDocument *document = [array objectAtIndex:0];
                                
                                [weakSelf.taskService removeAttachment:document fromTask:task completionBlock:^(BOOL removalSuccess, NSError *removeAttachmentError) {
                                    STAssertTrue(removalSuccess, @"The removal of the attachment did not return true");
                                    STAssertNil(removeAttachmentError, @"The returned error should be nil");
                                        
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
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testResolveTask
{
    if (self.setUpSuccess)
    {
            self.taskService = [[AlfrescoWorkflowTaskService alloc] initWithSession:self.currentSession];
            
        [self createTaskAndProcessWithProcessDefinitionIdentifier:@"activitiReview:1:8" completionBlock:^(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *creationError) {
            if (creationError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                [self.taskService resolveTask:task completionBlock:^(AlfrescoWorkflowTask *resolvedTask, NSError *resolveError) {
                    if (self.currentSession.workflowInfo.publicAPI)
                    {
                        if (resolveError)
                        {
                            self.lastTestSuccessful = NO;
                            self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [resolveError localizedDescription], [resolveError localizedFailureReason]];
                            self.callbackCompleted = YES;
                        }
                        else
                        {
                            STAssertNotNil(resolvedTask, @"The resolved task should not be nil");
                            STAssertNotNil(resolvedTask.endedAt, @"The resolved tasks endedAt property should not be nil");
                            
                            // TODO
                            
                            [self deleteCreatedTestProcess:process completionBlock:^(BOOL succeeded, NSError *error) {
                                self.lastTestSuccessful = succeeded;
                                self.callbackCompleted = YES;
                            }];
                        }
                    }
                    else
                    {
                        STAssertNil(resolvedTask, @"Resolved task should be nil");
                        STAssertNotNil(resolveError, @"Resolving using the Old API should have thrown an error");
                        STAssertEqualObjects(resolveError.localizedDescription, kAlfrescoErrorDescriptionWorkflowFunctionNotSupported, @"Expected the error description to be - %@, instead got back an error description of - %@", kAlfrescoErrorDescriptionWorkflowFunctionNotSupported, resolveError.localizedDescription);
                        STAssertTrue(resolveError.code == kAlfrescoErrorCodeWorkflowFunctionNotSupported, @"Expected the error code %i, instead got back %i", kAlfrescoErrorCodeWorkflowFunctionNotSupported, resolveError.code);
                        
                        self.lastTestSuccessful = YES;
                        self.callbackCompleted = YES;
                    }
                }];
            }
        }];
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

#pragma mark - Private Functions

- (void)createTaskAndProcessWithProcessDefinitionIdentifier:(NSString *)processDefinitionID completionBlock:(void (^)(AlfrescoWorkflowProcess *process, AlfrescoWorkflowTask *task, NSError *error))completionBlock
{
    self.processDefinitionService = [[AlfrescoWorkflowProcessDefinitionService alloc] initWithSession:self.currentSession];
    self.processService = [[AlfrescoWorkflowProcessService alloc] initWithSession:self.currentSession];
        
    [self.processDefinitionService retrieveProcessDefinitionWithIdentifier:processDefinitionID completionBlock:^(AlfrescoWorkflowProcessDefinition *processDefinition, NSError *retrieveError) {
        if (retrieveError)
        {
            completionBlock(nil, nil, retrieveError);
        }
        else
        {
            [self.processService startProcessForProcessDefinition:processDefinition assignees:nil variables:nil attachments:nil completionBlock:^(AlfrescoWorkflowProcess *process, NSError *startError) {
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
                                completionBlock(process, array[0], retrieveTaskError);
                            }
                            else
                            {
                                completionBlock(process, nil, retrieveTaskError);
                            }
                        }
                    }];
                }
            }];
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
