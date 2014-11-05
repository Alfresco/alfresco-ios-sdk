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

#import <Foundation/Foundation.h>
#import "AlfrescoConstants.h"

/** The AlfrescoRepositoryCapabilities are used as a property on AlfrescoRepositoryInfo.
 
 Author: Gavin Cornwell (Alfresco), Tijs Rademakers (Alfresco), Peter Schmidt (Alfresco)
 */

@interface AlfrescoRepositoryCapabilities : NSObject <NSCoding>

/// Indicates whether the server connected to supports the ability to like nodes.
@property (nonatomic, assign, readonly) BOOL doesSupportLikingNodes;

/// Indicates whether the server connected to provides comment counts.
@property (nonatomic, assign, readonly) BOOL doesSupportCommentCounts;

/// Indicates whether the server connected to supports the public API.
@property (nonatomic, assign, readonly) BOOL doesSupportPublicAPI;

/// Indicates whether the server connected to supports the Activiti workflow engine and it's enabled.
@property (nonatomic, assign, readonly) BOOL doesSupportActivitiWorkflowEngine;

/// Indicates whether the server connected to supports the JBPM workflow engine and it's enabled.
@property (nonatomic, assign, readonly) BOOL doesSupportJBPMWorkflowEngine;

/// Indicates whether the server connected to supports the My Files folder.
@property (nonatomic, assign, readonly) BOOL doesSupportMyFiles;

/// Indicates whether the server connected to supports the Shared folder.
@property (nonatomic, assign, readonly) BOOL doesSupportSharedFiles;

- (id)initWithProperties:(NSDictionary *)properties;

/**
 Checks whether a capability is supported.

 @param capability - the defined capability to check (one of the constants starting with "kAlfrescoCapability")
 */
- (BOOL)doesSupportCapability:(NSString *)capability;

@end
