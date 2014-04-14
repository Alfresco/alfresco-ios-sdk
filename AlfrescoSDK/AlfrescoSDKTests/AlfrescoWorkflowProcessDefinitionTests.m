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
#import "AlfrescoLog.h"

static NSString * const kAlfrescoJBPMPrefix = @"jbpm$";
static NSString * const kAlfrescoActivitiPrefix = @"activiti$";
static NSString * const kAlfrescoActivitiAdhocProcessDefinition = @"activitiAdhoc:1:4";
static NSString * const kAlfrescoJBPMAdhocProcessDefinitionKey = @"wf:adhoc";
static NSString * const kAlfrescoActivitiAdhocProcessDefinitionKey = @"activitiAdhoc";

@implementation AlfrescoWorkflowProcessDefinitionTests

- (void)testRetrieveAllProcessDefinitions
{
    if (self.setUpSuccess)
    {
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        [self.workflowService retrieveProcessDefinitionsWithCompletionBlock:^(NSArray *array, NSError *error) {
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
                
                BOOL adhocDefinitionFound = NO;
                
                if (self.currentSession.repositoryInfo.capabilities.doesSupportJBPMWorkflowEngine)
                {
                    NSString *adhocKey = [kAlfrescoJBPMPrefix stringByAppendingString:kAlfrescoJBPMAdhocProcessDefinitionKey];
                    
                    // go through the process definitions looking for the adhoc workflow
                    for (AlfrescoWorkflowProcessDefinition *processDefinition in array)
                    {
                        if ([processDefinition.key isEqualToString:adhocKey])
                        {
                            XCTAssertTrue([processDefinition.identifier isEqualToString:@"jbpm$1"],
                                          @"Expected adhoc identifer to be jbpm$1 but it was %@", processDefinition.identifier);
                            XCTAssertTrue([processDefinition.name isEqualToString:@"Adhoc"],
                                          @"Expected adhoc name to be 'Adhoc' but it was %@", processDefinition.name);
                            XCTAssertTrue([processDefinition.summary isEqualToString:@"Assign task to colleague"],
                                          @"Expected adhoc summary to be 'Assign task to colleague' but it was %@", processDefinition.summary);
                            XCTAssertTrue([processDefinition.version intValue] == 1, @"Expected adhoc version to be 1 but it was %d", [processDefinition.version intValue]);
                            
                            adhocDefinitionFound = YES;
                            break;
                        }
                    }
                }
                else if (self.currentSession.repositoryInfo.capabilities.doesSupportActivitiWorkflowEngine)
                {
                    if (self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
                    {
                        // go through the process definitions looking for the adhoc workflow
                        for (AlfrescoWorkflowProcessDefinition *processDefinition in array)
                        {
                            if ([processDefinition.key isEqualToString:kAlfrescoActivitiAdhocProcessDefinitionKey])
                            {
                                XCTAssertTrue([processDefinition.identifier isEqualToString:kAlfrescoActivitiAdhocProcessDefinition],
                                              @"Expected adhoc identifer to be activitiAdhoc:1:4 but it was %@", processDefinition.identifier);
                                XCTAssertTrue([processDefinition.name isEqualToString:@"New Task"],
                                              @"Expected adhoc name to be 'New Task' but it was %@", processDefinition.name);
                                XCTAssertTrue([processDefinition.summary isEqualToString:@"Assign a new task to yourself or a colleague"],
                                              @"Expected adhoc summary to be 'Assign a new task to yourself or a colleague' but it was %@", processDefinition.summary);
                                XCTAssertTrue([processDefinition.version intValue] == 1, @"Expected adhoc version to be 1 but it was %d", [processDefinition.version intValue]);
                                
                                adhocDefinitionFound = YES;
                                break;
                            }
                        }
                    }
                    else
                    {
                        NSString *adhocKey = [kAlfrescoActivitiPrefix stringByAppendingString:kAlfrescoActivitiAdhocProcessDefinitionKey];
                        
                        // go through the process definitions looking for the adhoc workflow
                        for (AlfrescoWorkflowProcessDefinition *processDefinition in array)
                        {
                            if ([processDefinition.key isEqualToString:adhocKey])
                            {
                                XCTAssertTrue([processDefinition.identifier isEqualToString:[kAlfrescoActivitiPrefix stringByAppendingString:kAlfrescoActivitiAdhocProcessDefinition]],
                                              @"Expected adhoc identifer to be activiti$activitiAdhoc:1:4 but it was %@", processDefinition.identifier);
                                XCTAssertTrue([processDefinition.name isEqualToString:@"Adhoc Workflow"],
                                              @"Expected adhoc name to be 'Adhoc Workflow' but it was %@", processDefinition.name);
                                XCTAssertTrue([processDefinition.summary isEqualToString:@"Assign arbitrary task to colleague using Activiti workflow engine"],
                                              @"Expected adhoc summary to be 'Assign arbitrary task to colleague using Activiti workflow engine' but it was %@", processDefinition.summary);
                                XCTAssertTrue([processDefinition.version intValue] == 1, @"Expected adhoc version to be 1 but it was %d", [processDefinition.version intValue]);
                                
                                adhocDefinitionFound = YES;
                                break;
                            }
                        }
                    }
                }
                
                self.lastTestSuccessful = adhocDefinitionFound;
                if (!adhocDefinitionFound)
                {
                    self.lastTestFailureMessage = @"Failed to find adhoc process definition";
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
                XCTAssertTrue(pagingResult.objects.count == maxItemsToRetrieve, @"Paging result should be %i, instead got back %lu", maxItemsToRetrieve, (unsigned long)pagingResult.objects.count);
                XCTAssertTrue(pagingResult.totalItems > maxItemsToRetrieve, @"Total items should be more than 2 but was %d", pagingResult.totalItems);
                XCTAssertTrue(pagingResult.hasMoreItems, @"The hasMoreItems flag should be true");

                // make sure the array contains the correct type of objects
                AlfrescoWorkflowProcessDefinition *processDefinition = pagingResult.objects[0];
                XCTAssertTrue([processDefinition isKindOfClass:[AlfrescoWorkflowProcessDefinition class]], @"Expected the objects array to contain AlfrescoWorkflowProcessDefinition objects");
                
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
        self.workflowService = [[AlfrescoWorkflowService alloc] initWithSession:self.currentSession];
        
        NSString *processDefinitionID = kAlfrescoActivitiAdhocProcessDefinition;
        if (!self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
        {
            processDefinitionID = [kAlfrescoActivitiPrefix stringByAppendingString:kAlfrescoActivitiAdhocProcessDefinition];
        }
        
        [self.workflowService retrieveProcessDefinitionWithIdentifier:processDefinitionID completionBlock:^(AlfrescoWorkflowProcessDefinition *processDefinition, NSError *error) {
            if (error)
            {
                if (error.code == kAlfrescoErrorCodeWorkflowFunctionNotSupported && [self.currentSession.repositoryInfo.majorVersion intValue] == 3)
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
                XCTAssertNotNil(processDefinition, @"processDefinition should not be nil");
                XCTAssertTrue([processDefinition.identifier isEqualToString:processDefinitionID],
                              @"Expected process definition identifier to be %@ but was %@", processDefinitionID, processDefinition.identifier);
                
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

- (void)testRetrieveProcessDefinitionByKey
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
        
        [self.workflowService retrieveProcessDefinitionWithKey:processDefinitionKey completionBlock:^(AlfrescoWorkflowProcessDefinition *processDefinition, NSError *error) {
            if (error)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(processDefinition, @"The returned process definition should not be nil");
                XCTAssertTrue([processDefinition.key isEqualToString:processDefinitionKey], @"The process definition key should be %@, but instead got back %@", processDefinitionKey, processDefinition.key);
                
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

@end
