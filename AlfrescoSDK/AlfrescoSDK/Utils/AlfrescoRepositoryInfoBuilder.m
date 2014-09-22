/*
 ******************************************************************************
 * Copyright (C) 2005-2014 Alfresco Software Limited.
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

#import "AlfrescoRepositoryInfoBuilder.h"
#import "AlfrescoInternalConstants.h"

@implementation AlfrescoRepositoryInfoBuilder

- (AlfrescoRepositoryInfo *)repositoryInfoFromCurrentState
{
    NSMutableDictionary *repoDictionary = [NSMutableDictionary dictionary];
    NSString *productName = self.cmisSession.repositoryInfo.productName;
    NSString *identifier = self.cmisSession.repositoryInfo.identifier;
    NSString *summary = self.cmisSession.repositoryInfo.summary;
    NSString *version = self.cmisSession.repositoryInfo.productVersion;
    NSNumber *majorVersionNumber = self.versionInfo.majorVersion;
    NSNumber *minorVersionNumber = self.versionInfo.minorVersion;
    NSNumber *maintenanceVersion = self.versionInfo.maintenanceVersion;
    NSString *buildNumber = self.versionInfo.buildNumber;
    
    NSMutableDictionary *capabilities = [NSMutableDictionary dictionary];
    if (self.isCloud)
    {
        repoDictionary[kAlfrescoRepositoryEdition] = kAlfrescoRepositoryEditionCloud;
        repoDictionary[kAlfrescoRepositoryIdentifier] = identifier;
        repoDictionary[kAlfrescoRepositorySummary] = summary;
        repoDictionary[kAlfrescoRepositoryName] = productName;
        
        [capabilities setValue:@YES forKey:kAlfrescoCapabilityLike];
        [capabilities setValue:@YES forKey:kAlfrescoCapabilityCommentsCount];
        [capabilities setValue:@YES forKey:kAlfrescoCapabilityPublicAPI];
        [capabilities setValue:@YES forKey:kAlfrescoCapabilityActivitiWorkflowEngine];
        [capabilities setValue:@NO forKey:kAlfrescoCapabilityJBPMWorkflowEngine];
    }
    else
    {
        repoDictionary[kAlfrescoRepositoryName] = productName;
        if ([productName rangeOfString:kAlfrescoRepositoryEditionCommunity].location != NSNotFound)
        {
            repoDictionary[kAlfrescoRepositoryEdition] = kAlfrescoRepositoryEditionCommunity;
        }
        else if ([productName rangeOfString:kAlfrescoRepositoryEditionEnterprise].location != NSNotFound)
        {
            repoDictionary[kAlfrescoRepositoryEdition] = kAlfrescoRepositoryEditionEnterprise;
        }
        else
        {
            repoDictionary[kAlfrescoRepositoryEdition] = kAlfrescoRepositoryEditionUnknown;
        }
        repoDictionary[kAlfrescoRepositoryIdentifier] = identifier;
        repoDictionary[kAlfrescoRepositorySummary] = summary;
        repoDictionary[kAlfrescoRepositoryVersion] = version;
        repoDictionary[kAlfrescoRepositoryMajorVersion] = majorVersionNumber;
        repoDictionary[kAlfrescoRepositoryMinorVersion] = minorVersionNumber;
        repoDictionary[kAlfrescoRepositoryMaintenanceVersion] = maintenanceVersion;
        repoDictionary[kAlfrescoRepositoryBuildNumber] = buildNumber;
        if ([majorVersionNumber intValue] < 4)
        {
            [capabilities setValue:@NO forKey:kAlfrescoCapabilityLike];
            [capabilities setValue:@NO forKey:kAlfrescoCapabilityCommentsCount];
            [capabilities setValue:@NO forKey:kAlfrescoCapabilityPublicAPI];
        }
        else
        {
            [capabilities setValue:@YES forKey:kAlfrescoCapabilityLike];
            [capabilities setValue:@YES forKey:kAlfrescoCapabilityCommentsCount];
            
            // determine whether the public API is available
            float version = [[NSString stringWithFormat:@"%i.%i", majorVersionNumber.intValue, minorVersionNumber.intValue] floatValue];
            if ([repoDictionary[kAlfrescoRepositoryEdition] isEqualToString:kAlfrescoRepositoryEditionEnterprise] && version >= 4.2f)
            {
                // public Workflow API available in Alfresco 4.2 Enterprise Edition and newer
                [capabilities setValue:@YES forKey:kAlfrescoCapabilityPublicAPI];
            }
            else if ([repoDictionary[kAlfrescoRepositoryEdition] isEqualToString:kAlfrescoRepositoryEditionCommunity] && version >= 4.3f)
            {
                // public Workflow API available in Alfresco 4.3 Community Edition and newer
                [capabilities setValue:@YES forKey:kAlfrescoCapabilityPublicAPI];
            }
            else
            {
                [capabilities setValue:@NO forKey:kAlfrescoCapabilityPublicAPI];
            }
        }
        
        // determine which workflow engines are available
        if (self.workflowDefinitionData != nil)
        {
            NSString *workflowDefinitionString = [[NSString alloc] initWithData:self.workflowDefinitionData encoding:NSUTF8StringEncoding];
            
            if ([workflowDefinitionString rangeOfString:@"activiti$"].location != NSNotFound)
            {
                [capabilities setValue:@YES forKey:kAlfrescoCapabilityActivitiWorkflowEngine];
            }
            
            // only check for JBPM if the public API is not available
            if (![[capabilities valueForKey:kAlfrescoCapabilityPublicAPI] boolValue])
            {
                if ([workflowDefinitionString rangeOfString:@"jbpm$"].location != NSNotFound)
                {
                    [capabilities setValue:@YES forKey:kAlfrescoCapabilityJBPMWorkflowEngine];
                }
            }
        }
    }
    
    // create and store the capabilities object
    AlfrescoRepositoryCapabilities *repoCapabilities = [[AlfrescoRepositoryCapabilities alloc] initWithProperties:capabilities];
    [repoDictionary setValue:repoCapabilities forKey:kAlfrescoRepositoryCapabilities];
    
    // create and return the repo info object
    return [[AlfrescoRepositoryInfo alloc] initWithProperties:repoDictionary];
}

@end
