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

/** AlfrescoWorkflowProcessServiceTest
 
 Author: Tauseef Mughal (Alfresco)
 */

#import "AlfrescoWorkflowProcessServiceTest.h"
#import "AlfrescoWorkflowProcessService.h"
#import "AlfrescoWorkflowProcessDefinitionService.h"
#import "AlfrescoFileManager.h"
#import "AlfrescoErrors.h"

@interface AlfrescoWorkflowProcessServiceTest ()

@property (nonatomic, strong) AlfrescoWorkflowProcessDefinitionService *processesDefinitionService;
@property (nonatomic, strong) AlfrescoWorkflowProcessService *processesService;

@end

@implementation AlfrescoWorkflowProcessServiceTest

- (void)testRetrieveAllProcesses
{
    if (self.setUpSuccess)
    {
        self.processesService = [[AlfrescoWorkflowProcessService alloc] initWithSession:self.currentSession];
                
        [self.processesService retrieveAllProcessesWithCompletionBlock:^(NSArray *array, NSError *retrieveError) {
            if (retrieveError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveError localizedDescription], [retrieveError localizedFailureReason]];
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

- (void)testRetrieveProcessesWithListingContext
{
    if (self.setUpSuccess)
    {
        self.processesService = [[AlfrescoWorkflowProcessService alloc] initWithSession:self.currentSession];
        
        AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:10 skipCount:0];
        
        [self.processesService retrieveProcessesWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *retrieveError) {
            if (retrieveError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveError localizedDescription], [retrieveError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                STAssertNotNil(pagingResult, @"Paging result should not be nil");
                STAssertTrue(pagingResult.objects.count > 1, @"PagingResult objects should contain more than 1 process");
                STAssertFalse(pagingResult.hasMoreItems, @"PagingResult should not conatin more objects");
                
                // TODO
                
                self.lastTestSuccessful = YES;
                
                self.callbackCompleted = YES;
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

- (void)testRetrieveAllProcessesInStateActive
{
    if (self.setUpSuccess)
    {
        self.processesService = [[AlfrescoWorkflowProcessService alloc] initWithSession:self.currentSession];
        
        [self.processesService retrieveProcessesInState:kAlfrescoWorkflowProcessStateActive completionBlock:^(NSArray *array, NSError *retrieveError) {
            if (retrieveError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveError localizedDescription], [retrieveError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                STAssertNotNil(array, @"array should not be nil");
                STAssertTrue(array.count >= 1, @"Array should contain more than or 1 process");
                
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

- (void)testRetrieveAllProcessesInStateCompleted
{
    if (self.setUpSuccess)
    {
        self.processesService = [[AlfrescoWorkflowProcessService alloc] initWithSession:self.currentSession];
        
        [self.processesService retrieveProcessesInState:kAlfrescoWorkflowProcessStateCompleted completionBlock:^(NSArray *array, NSError *retrieveError) {
            if (retrieveError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveError localizedDescription], [retrieveError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                STAssertNotNil(array, @"array should not be nil");
                STAssertTrue(array.count >= 1, @"Array should contain more than or 1 process");
                
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

- (void)testRetrieveProcessesInStateWithListingContext
{
    if (self.setUpSuccess)
    {
        self.processesService = [[AlfrescoWorkflowProcessService alloc] initWithSession:self.currentSession];
        
        AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:10 skipCount:0];
        
        [self.processesService retrieveProcessesInState:kAlfrescoWorkflowProcessStateAny listingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *retrieveError) {
            if (retrieveError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveError localizedDescription], [retrieveError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                STAssertNotNil(pagingResult, @"Paging result should not be nil");
                STAssertTrue(pagingResult.objects.count > 1, @"PagingResult objects should contain more than 1 process");
                STAssertFalse(pagingResult.hasMoreItems, @"PagingResult should not conatin more objects");
                
                // TODO
                
                self.lastTestSuccessful = YES;
                
                self.callbackCompleted = YES;
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

// retrieve by ID, start, delete
- (void)testStartProcessForProcessDefinition
{
    if (self.setUpSuccess)
    {
        self.processesDefinitionService = [[AlfrescoWorkflowProcessDefinitionService alloc] initWithSession:self.currentSession];
        self.processesService = [[AlfrescoWorkflowProcessService alloc] initWithSession:self.currentSession];
        
        NSString *processDefinitionID = @"activitiReview:1:8";
        
        [self createProcessUsingProcessDefinitionIdentifier:processDefinitionID assignees:nil variables:nil attachements:nil completionBlock:^(AlfrescoWorkflowProcess *createdProcess, NSError *creationError) {
            if (creationError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                STAssertNotNil(createdProcess, @"Process should not be nil");
                STAssertNotNil(createdProcess.identifier, @"Process identifier should not be nil");
                
                [self deleteCreatedTestProcess:createdProcess completionBlock:^(BOOL succeeded, NSError *deleteError) {
                    STAssertTrue(succeeded, @"Deletion flag should be true");
                    self.lastTestSuccessful = succeeded;
                    self.callbackCompleted = YES;
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

- (void)testRetrieveProcessImage
{
    if (self.setUpSuccess)
    {
        self.processesDefinitionService = [[AlfrescoWorkflowProcessDefinitionService alloc] initWithSession:self.currentSession];
        self.processesService = [[AlfrescoWorkflowProcessService alloc] initWithSession:self.currentSession];
        
        NSString *processDefinitionID = @"activitiReview:1:8";
        
        [self createProcessUsingProcessDefinitionIdentifier:processDefinitionID assignees:nil variables:nil attachements:nil completionBlock:^(AlfrescoWorkflowProcess *createdProcess, NSError *creationError) {
            if (creationError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                STAssertNotNil(createdProcess, @"Process should not be nil");
                STAssertNotNil(createdProcess.identifier, @"Process identifier should not be nil");
                
                [self.processesService retrieveProcessImage:createdProcess completionBlock:^(AlfrescoContentFile *contentFile, NSError *retrieveImageError) {
                    if (retrieveImageError)
                    {
                        if (self.currentSession.workflowInfo.workflowEngine == AlfrescoWorkflowEngineTypeActiviti)
                        {
                            self.lastTestSuccessful = NO;
                            self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveImageError localizedDescription], [retrieveImageError localizedFailureReason]];
                            self.callbackCompleted = YES;
                        }
                        else
                        {
                            STAssertNil(contentFile, @"Content file should be nil");
                            STAssertNotNil(retrieveImageError, @"Retrieving image on JBPM engine should have thrown an error");
                            STAssertEqualObjects(retrieveImageError.localizedDescription, kAlfrescoErrorDescriptionWorkflowFunctionNotSupported, @"Expected the error description to be - %@, instead got back an error description of - %@", kAlfrescoErrorDescriptionWorkflowFunctionNotSupported, retrieveImageError.localizedDescription);
                            STAssertTrue(retrieveImageError.code == kAlfrescoErrorCodeWorkflowFunctionNotSupported, @"Expected the error code %i, instead got back %i", kAlfrescoErrorCodeWorkflowFunctionNotSupported, retrieveImageError.code);
                     
                            self.lastTestSuccessful = YES;
                            self.callbackCompleted = YES;
                        }
                    }
                    else
                    {
                        STAssertNotNil(contentFile, @"Content file should not be nil");
                        BOOL fileExists = [[AlfrescoFileManager sharedManager] fileExistsAtPath:contentFile.fileUrl.path];
                        STAssertTrue(fileExists, @"The image does not exist at the path");
                     
                        [self deleteCreatedTestProcess:createdProcess completionBlock:^(BOOL succeeded, NSError *deleteError) {
                            STAssertTrue(succeeded, @"Deletion flag should be true");
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

- (void)testRetrieveProcessImageWithOutputStream
{
    if (self.setUpSuccess)
    {
        self.processesDefinitionService = [[AlfrescoWorkflowProcessDefinitionService alloc] initWithSession:self.currentSession];
        self.processesService = [[AlfrescoWorkflowProcessService alloc] initWithSession:self.currentSession];
        
        NSString *processDefinitionID = @"activitiReview:1:8";
        
        [self createProcessUsingProcessDefinitionIdentifier:processDefinitionID assignees:nil variables:nil attachements:nil completionBlock:^(AlfrescoWorkflowProcess *createdProcess, NSError *creationError) {
            if (creationError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                STAssertNotNil(createdProcess, @"Process should not be nil");
                STAssertNotNil(createdProcess.identifier, @"Process identifier should not be nil");
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
                NSString *imageName = [NSString stringWithFormat:@"%@%@.png", @"processImageFromOutputstream", [dateFormatter stringFromDate:[NSDate date]]];
                NSString *filePath = [[[AlfrescoFileManager sharedManager] temporaryDirectory] stringByAppendingPathComponent:imageName];
                
                NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
                
                [self.processesService retrieveProcessImage:createdProcess outputStream:outputStream completionBlock:^(BOOL succeeded, NSError *retrieveImageError) {
                    if (retrieveImageError)
                    {
                        if (self.currentSession.workflowInfo.workflowEngine == AlfrescoWorkflowEngineTypeActiviti)
                        {
                        
                            self.lastTestSuccessful = NO;
                            self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveImageError localizedDescription], [retrieveImageError localizedFailureReason]];
                            self.callbackCompleted = YES;
                        }
                        else
                        {
                            STAssertFalse(succeeded, @"Success flag should be false.");
                            STAssertNotNil(retrieveImageError, @"Retrieving image on JBPM engine should have thrown an error");
                            STAssertEqualObjects(retrieveImageError.localizedDescription, kAlfrescoErrorDescriptionWorkflowFunctionNotSupported, @"Expected the error description to be - %@, instead got back an error description of - %@", kAlfrescoErrorDescriptionWorkflowFunctionNotSupported, retrieveImageError.localizedDescription);
                            STAssertTrue(retrieveImageError.code == kAlfrescoErrorCodeWorkflowFunctionNotSupported, @"Expected the error code %i, instead got back %i", kAlfrescoErrorCodeWorkflowFunctionNotSupported, retrieveImageError.code);
                        
                            self.lastTestSuccessful = YES;
                            self.callbackCompleted = YES;
                        }
                    }
                    else
                    {
                        if (self.currentSession.workflowInfo.workflowEngine == AlfrescoWorkflowEngineTypeActiviti)
                        {
                            STAssertTrue(succeeded, @"The completion of the file writing did not complete");
                            BOOL fileExists = [[AlfrescoFileManager sharedManager] fileExistsAtPath:filePath];
                            STAssertTrue(fileExists, @"The image does not exist at the path");
                            
                            [self deleteCreatedTestProcess:createdProcess completionBlock:^(BOOL succeeded, NSError *deleteError) {
                                STAssertTrue(succeeded, @"Deletion flag should be true");
                                self.lastTestSuccessful = succeeded;
                                self.callbackCompleted = YES;
                            }];
                        }
                        else
                        {
                            STAssertFalse(succeeded, @"Success flag should be false.");
                            STAssertNotNil(retrieveImageError, @"Retrieving image on JBPM engine should have thrown an error");
                            STAssertEqualObjects(retrieveImageError.localizedDescription, kAlfrescoErrorDescriptionWorkflowFunctionNotSupported, @"Expected the error description to be - %@, instead got back an error description of - %@", kAlfrescoErrorDescriptionWorkflowFunctionNotSupported, retrieveImageError.localizedDescription);
                            STAssertTrue(retrieveImageError.code == kAlfrescoErrorCodeWorkflowFunctionNotSupported, @"Expected the error code %i, instead got back %i", kAlfrescoErrorCodeWorkflowFunctionNotSupported, retrieveImageError.code);
                            
                            self.lastTestSuccessful = YES;
                            self.callbackCompleted = YES;
                        }
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

- (void)testRetrieveAllTasksForProcess
{
    if (self.setUpSuccess)
    {
        self.processesDefinitionService = [[AlfrescoWorkflowProcessDefinitionService alloc] initWithSession:self.currentSession];
        self.processesService = [[AlfrescoWorkflowProcessService alloc] initWithSession:self.currentSession];
        
        NSString *processDefinitionID = @"activitiAdhoc:1:4";
        
        [self createProcessUsingProcessDefinitionIdentifier:processDefinitionID assignees:nil variables:nil attachements:nil completionBlock:^(AlfrescoWorkflowProcess *createdProcess, NSError *creationError) {
            if (creationError)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [creationError localizedDescription], [creationError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                STAssertNotNil(createdProcess, @"Process should not be nil");
                STAssertNotNil(createdProcess.identifier, @"Process identifier should not be nil");
                
                [self.processesService retrieveAllTasksForProcess:createdProcess completionBlock:^(NSArray *array, NSError *retrieveTasksError) {
                    if (retrieveTasksError)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveTasksError localizedDescription], [retrieveTasksError localizedFailureReason]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        STAssertNotNil(array, @"array should not be nil");
                        STAssertTrue(array.count > 0, @"Array should contain more than or atleast 1 task");
                        
                        [self deleteCreatedTestProcess:createdProcess completionBlock:^(BOOL succeeded, NSError *deleteError) {
                            STAssertTrue(succeeded, @"Deletion flag should be true");
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

#pragma mark - Private Functions

- (void)createProcessUsingProcessDefinitionIdentifier:(NSString *)processDefinitionID assignees:(NSArray *)assignees variables:(NSDictionary *)variables attachements:(NSArray *)attachmentNodes completionBlock:(void (^)(AlfrescoWorkflowProcess *createdProcess, NSError *creationError))completionBlock
{
    self.processesDefinitionService = [[AlfrescoWorkflowProcessDefinitionService alloc] initWithSession:self.currentSession];
    self.processesService = [[AlfrescoWorkflowProcessService alloc] initWithSession:self.currentSession];
    
    [self.processesDefinitionService retrieveProcessDefinitionWithIdentifier:processDefinitionID completionBlock:^(AlfrescoWorkflowProcessDefinition *processDefinition, NSError *retrieveError) {
        
        // define the process creation block
        void (^createProcessWithDefinition)(AlfrescoWorkflowProcessDefinition *definition) = ^(AlfrescoWorkflowProcessDefinition *definition) {
            [self.processesService startProcessForProcessDefinition:definition assignees:assignees variables:variables attachments:attachmentNodes completionBlock:^(AlfrescoWorkflowProcess *process, NSError *startError) {
                if (startError)
                {
                    completionBlock(nil, startError);
                }
                else
                {
                    completionBlock(process, startError);
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
                processDefinition = [[AlfrescoWorkflowProcessDefinition alloc] initWithProperties:properties session:self.currentSession];
                createProcessWithDefinition(processDefinition);
            }
            else
            {
                completionBlock(nil, retrieveError);
            }
        }
        else
        {
            STAssertNotNil(processDefinition, @"Process definition should not be nil");
            STAssertNotNil(processDefinition.identifier, @"Process definition identifier should not be nil");
            
            createProcessWithDefinition(processDefinition);
        }
    }];
}

- (void)deleteCreatedTestProcess:(AlfrescoWorkflowProcess *)process completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    self.processesService = [[AlfrescoWorkflowProcessService alloc] initWithSession:self.currentSession];
    
    [self.processesService deleteProcess:process completionBlock:^(BOOL succeeded, NSError *deleteError) {
        completionBlock(succeeded, deleteError);
    }];
}

@end
