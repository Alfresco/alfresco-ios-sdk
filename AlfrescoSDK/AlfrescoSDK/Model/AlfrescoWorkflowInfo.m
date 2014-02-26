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

/** The AlfrescoWorkflowInfo model object
 
 Author: Tauseef Mughal (Alfresco)
 */

#import "AlfrescoWorkflowInfo.h"
#import "AlfrescoCloudSession.h"
#import "AlfrescoInternalConstants.h"

static NSInteger kWorkflowInfoModelVersion = 1;

@interface AlfrescoWorkflowInfo ()

@property (nonatomic, assign, readwrite) AlfrescoWorkflowEngineType workflowEngine;
@property (nonatomic, assign, readwrite) BOOL publicAPI;

@end

@implementation AlfrescoWorkflowInfo

- (id)initWithSession:(id<AlfrescoSession>)session workflowEngine:(AlfrescoWorkflowEngineType)workflowEngine
{
    self = [super init];
    if (self)
    {
        self.workflowEngine = workflowEngine;
        [self setupAPIVersionUsingSession:session];
    }
    return self;
}

#pragma mark - Private Functions

- (void)setupAPIVersionUsingSession:(id<AlfrescoSession>)session
{
    AlfrescoRepositoryInfo *repositoryInfo = session.repositoryInfo;

    // Assume no Public Workflow API support
    self.publicAPI = NO;
    
    if ([session isKindOfClass:[AlfrescoCloudSession class]])
    {
        // Alfresco in the Cloud must only be accessed using the Public Workflow API
        self.publicAPI = YES;
    }
    else if (self.workflowEngine == AlfrescoWorkflowEngineTypeActiviti)
    {
        // Public Workflow API only supports the Activiti workflow engine and does not support JBPM
        NSNumber *majorVersion = repositoryInfo.majorVersion;
        NSNumber *minorVersion = repositoryInfo.minorVersion;
        float version = [[NSString stringWithFormat:@"%i.%i", majorVersion.intValue, minorVersion.intValue] floatValue];
        
        if ([repositoryInfo.edition isEqualToString:kAlfrescoRepositoryEditionEnterprise] && version >= 4.2f)
        {
            // Public Workflow API available in Alfresco 4.2 Enterprise Edition and newer
            self.publicAPI = YES;
        }
        else if ([repositoryInfo.edition isEqualToString:kAlfrescoRepositoryEditionCommunity] && version >= 4.3f)
        {
            // Public Workflow API available in Alfresco 4.3 Community Edition and newer
            self.publicAPI = YES;
        }
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:kWorkflowInfoModelVersion forKey:NSStringFromClass([self class])];
    [aCoder encodeInteger:self.workflowEngine forKey:kAlfrescoWorkflowEngineType];
    [aCoder encodeBool:self.publicAPI forKey:kAlfrescoWorkflowUsingPublicAPI];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
//        NSInteger version = [aDecoder decodeIntegerForKey:NSStringFromClass([self class])];
        self.workflowEngine = [aDecoder decodeIntegerForKey:kAlfrescoWorkflowEngineType];
        self.publicAPI = [aDecoder decodeBoolForKey:kAlfrescoWorkflowUsingPublicAPI];
    }
    return self;
}

@end
