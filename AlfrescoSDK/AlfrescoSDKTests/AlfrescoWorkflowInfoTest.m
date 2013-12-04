
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

//
//  AlfrescoWorkflowInfoTest.m
//  AlfrescoSDK
//
//

#import "AlfrescoWorkflowInfoTest.h"
#import "AlfrescoWorkflowInfo.h"
#import "AlfrescoCloudSession.h"
#import "AlfrescoRepositorySession.h"
#import "AlfrescoInternalConstants.h"

@interface AlfrescoWorkflowInfoTest ()

@end

@implementation AlfrescoWorkflowInfoTest

- (void)testPublicAPIFlag
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    /**
     * Cloud Server:
     *      Should always return PublicAPI flag set
     *
     * On Premise Servers:
     *      For JBPM Workflow Engine types, should always return with flag unset
     *      Enterprise: Version 4.2 and newer should have Public API flag set
     *      Community: Version 4.3 and newer should have Public API flag set
     *
     * All other cases:
     *      Public API flag should be unset
     */
    
    id<AlfrescoSession> session = nil;
    AlfrescoWorkflowInfo *workflowInfo = nil;
    AlfrescoRepositoryInfo *repositoryInfo = nil;
    SEL setRepositoryInfo = sel_registerName("setRepositoryInfo:");
    
    // Cloud
    session = [[AlfrescoCloudSession alloc] init];

    workflowInfo = [[AlfrescoWorkflowInfo alloc] initWithSession:session workflowEngine:AlfrescoWorkflowEngineTypeJBPM];
    STAssertTrue(workflowInfo.publicAPI, @"Public API flag should be set always for Cloud [Note: Invalid combination]");

    workflowInfo = [[AlfrescoWorkflowInfo alloc] initWithSession:session workflowEngine:AlfrescoWorkflowEngineTypeActiviti];
    STAssertTrue(workflowInfo.publicAPI, @"Public API flag should be set always for Cloud");

    // Enterprise 3.4
    repositoryInfo = [[AlfrescoRepositoryInfo alloc] initWithProperties:@{ kAlfrescoRepositoryMajorVersion : @3,
                                                                           kAlfrescoRepositoryMinorVersion : @4,
                                                                           kAlfrescoRepositoryEdition : kAlfrescoRepositoryEditionEnterprise }];
    session = [[AlfrescoRepositorySession alloc] init];
    [session performSelector:setRepositoryInfo withObject:repositoryInfo];

    workflowInfo = [[AlfrescoWorkflowInfo alloc] initWithSession:session workflowEngine:AlfrescoWorkflowEngineTypeJBPM];
    STAssertFalse(workflowInfo.publicAPI, @"Public API flag should not be set for v3.4EE and JBPM");

    workflowInfo = [[AlfrescoWorkflowInfo alloc] initWithSession:session workflowEngine:AlfrescoWorkflowEngineTypeActiviti];
    STAssertFalse(workflowInfo.publicAPI, @"Public API flag should not be set for v3.4EE and Activiti [Note: Invalid combination]");

    // Enterprise 4.2
    repositoryInfo = [[AlfrescoRepositoryInfo alloc] initWithProperties:@{ kAlfrescoRepositoryMajorVersion : @4,
                                                                           kAlfrescoRepositoryMinorVersion : @2,
                                                                           kAlfrescoRepositoryEdition : kAlfrescoRepositoryEditionEnterprise }];
    session = [[AlfrescoRepositorySession alloc] init];
    [session performSelector:setRepositoryInfo withObject:repositoryInfo];

    workflowInfo = [[AlfrescoWorkflowInfo alloc] initWithSession:session workflowEngine:AlfrescoWorkflowEngineTypeJBPM];
    STAssertFalse(workflowInfo.publicAPI, @"Public API flag should not be set for v4.2EE and JBPM");
    
    workflowInfo = [[AlfrescoWorkflowInfo alloc] initWithSession:session workflowEngine:AlfrescoWorkflowEngineTypeActiviti];
    STAssertTrue(workflowInfo.publicAPI, @"Public API flag should be set for v4.2EE and Activiti");

    // Enterprise 5.1 (randomly chosen)
    repositoryInfo = [[AlfrescoRepositoryInfo alloc] initWithProperties:@{ kAlfrescoRepositoryMajorVersion : @5,
                                                                           kAlfrescoRepositoryMinorVersion : @1,
                                                                           kAlfrescoRepositoryEdition : kAlfrescoRepositoryEditionEnterprise }];
    session = [[AlfrescoRepositorySession alloc] init];
    [session performSelector:setRepositoryInfo withObject:repositoryInfo];
    
    workflowInfo = [[AlfrescoWorkflowInfo alloc] initWithSession:session workflowEngine:AlfrescoWorkflowEngineTypeJBPM];
    STAssertFalse(workflowInfo.publicAPI, @"Public API flag should not be set for v5.1EE and JBPM");
    
    workflowInfo = [[AlfrescoWorkflowInfo alloc] initWithSession:session workflowEngine:AlfrescoWorkflowEngineTypeActiviti];
    STAssertTrue(workflowInfo.publicAPI, @"Public API flag should be set for v5.1EE and Activiti");

    // Community 3.4.e
    repositoryInfo = [[AlfrescoRepositoryInfo alloc] initWithProperties:@{ kAlfrescoRepositoryMajorVersion : @3,
                                                                           kAlfrescoRepositoryMinorVersion : @4,
                                                                           kAlfrescoRepositoryMaintenanceVersion : @"e",
                                                                           kAlfrescoRepositoryEdition : kAlfrescoRepositoryEditionCommunity }];
    session = [[AlfrescoRepositorySession alloc] init];
    [session performSelector:setRepositoryInfo withObject:repositoryInfo];
    
    workflowInfo = [[AlfrescoWorkflowInfo alloc] initWithSession:session workflowEngine:AlfrescoWorkflowEngineTypeJBPM];
    STAssertFalse(workflowInfo.publicAPI, @"Public API flag should not be set for v3.4.e and JBPM");
    
    workflowInfo = [[AlfrescoWorkflowInfo alloc] initWithSession:session workflowEngine:AlfrescoWorkflowEngineTypeActiviti];
    STAssertFalse(workflowInfo.publicAPI, @"Public API flag should not be set for v3.4.e and Activiti [Note: Invalid combination]");
    
    // Community 4.2.e
    repositoryInfo = [[AlfrescoRepositoryInfo alloc] initWithProperties:@{ kAlfrescoRepositoryMajorVersion : @4,
                                                                           kAlfrescoRepositoryMinorVersion : @2,
                                                                           kAlfrescoRepositoryMaintenanceVersion : @"e",
                                                                           kAlfrescoRepositoryEdition : kAlfrescoRepositoryEditionCommunity }];
    session = [[AlfrescoRepositorySession alloc] init];
    [session performSelector:setRepositoryInfo withObject:repositoryInfo];
    
    workflowInfo = [[AlfrescoWorkflowInfo alloc] initWithSession:session workflowEngine:AlfrescoWorkflowEngineTypeJBPM];
    STAssertFalse(workflowInfo.publicAPI, @"Public API flag should not be set for v4.2.e and JBPM");
    
    // Note: Even though 4.2.e does support the Public API, the SDK does not perform checks on the maintenance version number
    workflowInfo = [[AlfrescoWorkflowInfo alloc] initWithSession:session workflowEngine:AlfrescoWorkflowEngineTypeActiviti];
    STAssertFalse(workflowInfo.publicAPI, @"Public API flag should be set for v4.2.e and Activiti");

    // Community 4.3.a
    repositoryInfo = [[AlfrescoRepositoryInfo alloc] initWithProperties:@{ kAlfrescoRepositoryMajorVersion : @4,
                                                                           kAlfrescoRepositoryMinorVersion : @3,
                                                                           kAlfrescoRepositoryMaintenanceVersion : @"a",
                                                                           kAlfrescoRepositoryEdition : kAlfrescoRepositoryEditionCommunity }];
    session = [[AlfrescoRepositorySession alloc] init];
    [session performSelector:setRepositoryInfo withObject:repositoryInfo];
    
    workflowInfo = [[AlfrescoWorkflowInfo alloc] initWithSession:session workflowEngine:AlfrescoWorkflowEngineTypeJBPM];
    STAssertFalse(workflowInfo.publicAPI, @"Public API flag should not be set for v4.3.a and JBPM");
    
    workflowInfo = [[AlfrescoWorkflowInfo alloc] initWithSession:session workflowEngine:AlfrescoWorkflowEngineTypeActiviti];
    STAssertTrue(workflowInfo.publicAPI, @"Public API flag should be set for v4.3.a and Activiti");

    // Community 5.3.e (randomly chosen)
    repositoryInfo = [[AlfrescoRepositoryInfo alloc] initWithProperties:@{ kAlfrescoRepositoryMajorVersion : @5,
                                                                           kAlfrescoRepositoryMinorVersion : @3,
                                                                           kAlfrescoRepositoryMaintenanceVersion : @"e",
                                                                           kAlfrescoRepositoryEdition : kAlfrescoRepositoryEditionCommunity }];
    session = [[AlfrescoRepositorySession alloc] init];
    [session performSelector:setRepositoryInfo withObject:repositoryInfo];
    
    workflowInfo = [[AlfrescoWorkflowInfo alloc] initWithSession:session workflowEngine:AlfrescoWorkflowEngineTypeJBPM];
    STAssertFalse(workflowInfo.publicAPI, @"Public API flag should not be set for v5.3.e and JBPM");
    
    workflowInfo = [[AlfrescoWorkflowInfo alloc] initWithSession:session workflowEngine:AlfrescoWorkflowEngineTypeActiviti];
    STAssertTrue(workflowInfo.publicAPI, @"Public API flag should be set for v5.3.e and Activiti");

#pragma clang diagnostic pop
}

@end
