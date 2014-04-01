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
#import "AlfrescoInternalConstants.h"

static NSString * const kAlfrescoJBPMPrefix = @"jbpm$";
static NSString * const kAlfrescoActivitiPrefix = @"activiti$";
static NSString * const kAlfrescoActivitiAdhocProcessDefinition = @"activitiAdhoc:1:4";
static NSString * const kAlfrescoJBPMAdhocProcessDefinitionKey = @"wf:adhoc";
static NSString * const kAlfrescoActivitiAdhocProcessDefinitionKey = @"activitiAdhoc";

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
                
                // TODO
                
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
                                                initWithFilter:kAlfrescoFilterByWorkflowState value:kAlfrescoFilterValueWorkflowStateActive];
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
                                                initWithFilter:kAlfrescoFilterByWorkflowState value:kAlfrescoFilterValueWorkflowStateCompleted];
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
        
        NSString *processDefinitionID = kAlfrescoActivitiAdhocProcessDefinition;
        if (!self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
        {
            processDefinitionID = [kAlfrescoActivitiPrefix stringByAppendingString:kAlfrescoActivitiAdhocProcessDefinition];
        }
        
        [self createProcessUsingProcessDefinitionIdentifier:processDefinitionID assignees:nil variables:nil attachements:nil completionBlock:^(AlfrescoWorkflowProcess *createdProcess, NSError *creationError) {
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
                        XCTAssertNotNil(process.processDefinitionIdentifier, @"Process definition identifier should not be nil");
                        XCTAssertNotNil(process.startedAt, @"Process started at date should not be nil");
                        
                        NSDictionary *variables = process.variables;
                        XCTAssertNotNil(variables, @"Expected to find a set of variables for the process");
                        
                        if ([AlfrescoWorkflowUtils isJBPMProcess:process] ||
                            !self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
                        {
                            AlfrescoProperty *priorityProperty = variables[@"priority"];
                            XCTAssertNotNil(priorityProperty, @"Expected to find the priority process variable");
                            XCTAssertTrue(priorityProperty.type == AlfrescoPropertyTypeInteger);
                            
                            AlfrescoProperty *descriptionProperty = variables[@"description"];
                            XCTAssertNotNil(descriptionProperty, @"Expected to find the description process variable");
                            XCTAssertTrue(descriptionProperty.type == AlfrescoPropertyTypeString);
                        }
                        else
                        {
                            AlfrescoProperty *priorityProperty = variables[@"bpm_priority"];
                            XCTAssertNotNil(priorityProperty, @"Expected to find the bpm_priority process variable");
                            XCTAssertTrue(priorityProperty.type == AlfrescoPropertyTypeInteger);
                            
                            AlfrescoProperty *statusProperty = variables[@"bpm_status"];
                            XCTAssertNotNil(statusProperty, @"Expected to find the bpm_status process variable");
                            XCTAssertTrue(statusProperty.type == AlfrescoPropertyTypeString);
                            XCTAssertTrue([statusProperty.value isEqualToString:@"Not Yet Started"],
                                          @"Expected status property to be 'Not Yet Started' but was %@", statusProperty.value);
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

// retrieve by ID, start, delete
- (void)testStartProcessForProcessDefinition
{
    if (self.setUpSuccess)
    {
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        NSString *processDefinitionID = kAlfrescoActivitiAdhocProcessDefinition;
        if (!self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
        {
            processDefinitionID = [kAlfrescoActivitiPrefix stringByAppendingString:kAlfrescoActivitiAdhocProcessDefinition];
        }
        
        [self createProcessUsingProcessDefinitionIdentifier:processDefinitionID assignees:nil variables:nil attachements:nil completionBlock:^(AlfrescoWorkflowProcess *createdProcess, NSError *creationError) {
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
                        XCTAssertTrue([createdProcess.name isEqualToString:processName], @"The process summary should be %@, but got back %@", processName, createdProcess.name);
                        XCTAssertTrue(createdProcess.priority.intValue == priority.integerValue, @"The priority should be %i, but got back %i", priority.intValue, createdProcess.priority.intValue);
                        
                        // Should get back an ISO8601 format date, even if a standard date was passed in
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        [formatter setDateFormat:kAlfrescoISO8601DateStringFormat];
                        // drop the milliseconds on JBPM
                        if (self.currentSession.repositoryInfo.capabilities.doesSupportJBPMWorkflowEngine)
                        {
                            [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
                        }
                        
                        NSDate *isoDateReturned = [formatter dateFromString:[formatter stringFromDate:dueDate]];
                        
                        XCTAssertTrue([createdProcess.dueAt isEqualToDate:isoDateReturned], @"The due date should be %@, but got back %@", isoDateReturned, createdProcess.dueAt);
                        
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
        
        NSString *processDefinitionID = kAlfrescoActivitiAdhocProcessDefinition;
        if (!self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
        {
            processDefinitionID = [kAlfrescoActivitiPrefix stringByAppendingString:kAlfrescoActivitiAdhocProcessDefinition];
        }
        
        [self createProcessUsingProcessDefinitionIdentifier:processDefinitionID assignees:nil variables:nil attachements:nil completionBlock:^(AlfrescoWorkflowProcess *createdProcess, NSError *creationError) {
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
        
        NSString *processDefinitionID = kAlfrescoActivitiAdhocProcessDefinition;
        if (!self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
        {
            processDefinitionID = [kAlfrescoActivitiPrefix stringByAppendingString:kAlfrescoActivitiAdhocProcessDefinition];
        }
        
        [self createProcessUsingProcessDefinitionIdentifier:processDefinitionID assignees:nil variables:nil attachements:nil completionBlock:^(AlfrescoWorkflowProcess *createdProcess, NSError *creationError) {
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
        
        [self createProcessUsingProcessDefinitionIdentifier:processDefinitionID assignees:nil variables:nil attachements:nil completionBlock:^(AlfrescoWorkflowProcess *createdProcess, NSError *creationError) {
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
                        XCTAssertTrue(array.count > 0, @"Array should contain more than or atleast 1 task");
                        
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
        
        [self createProcessUsingProcessDefinitionIdentifier:processDefinitionID assignees:nil variables:nil attachements:attachmentArray completionBlock:^(AlfrescoWorkflowProcess *createdProcess, NSError *creationError) {
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
                        XCTAssertTrue(attachmentNodes.count == attachmentArray.count, @"Array should contain %d attachment(s)", attachmentArray.count);
                        
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

#pragma mark - Private Functions

- (void)createProcessUsingProcessDefinitionIdentifier:(NSString *)processDefinitionID assignees:(NSArray *)assignees variables:(NSDictionary *)variables attachements:(NSArray *)attachmentNodes completionBlock:(void (^)(AlfrescoWorkflowProcess *createdProcess, NSError *creationError))completionBlock
{
    self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
    
    [self.workflowService retrieveProcessDefinitionWithIdentifier:processDefinitionID completionBlock:^(AlfrescoWorkflowProcessDefinition *processDefinition, NSError *retrieveError) {
        
        // define the process creation block
        void (^createProcessWithDefinition)(AlfrescoWorkflowProcessDefinition *definition) = ^(AlfrescoWorkflowProcessDefinition *definition) {
            [self.workflowService startProcessForProcessDefinition:definition assignees:assignees variables:variables attachments:attachmentNodes completionBlock:^(AlfrescoWorkflowProcess *process, NSError *startError) {
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
