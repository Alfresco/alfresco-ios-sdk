/*******************************************************************************
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
 ******************************************************************************/

#import "AlfrescoRepositoryCapabilities.h"

static NSInteger kRepositoryCapabilitiesModelVersion = 1;

@interface AlfrescoRepositoryCapabilities ()
@property (nonatomic, assign, readwrite) BOOL doesSupportLikingNodes;
@property (nonatomic, assign, readwrite) BOOL doesSupportCommentCounts;
@property (nonatomic, assign, readwrite) BOOL doesSupportPublicAPI;
@property (nonatomic, assign, readwrite) BOOL doesSupportActivitiWorkflowEngine;
@property (nonatomic, assign, readwrite) BOOL doesSupportJBPMWorkflowEngine;
@end

@implementation AlfrescoRepositoryCapabilities

- (id)initWithProperties:(NSDictionary *)properties
{
    self = [super init];
    if (nil != self)
    {
        if (nil != properties)
        {
            self.doesSupportCommentCounts = [[properties valueForKey:kAlfrescoCapabilityCommentsCount] boolValue];
            self.doesSupportLikingNodes = [[properties valueForKey:kAlfrescoCapabilityLike] boolValue];
            self.doesSupportPublicAPI = [[properties valueForKey:kAlfrescoCapabilityPublicAPI] boolValue];
            self.doesSupportActivitiWorkflowEngine = [[properties valueForKey:kAlfrescoCapabilityActivitiWorkflowEngine] boolValue];
            self.doesSupportJBPMWorkflowEngine = [[properties valueForKey:kAlfrescoCapabilityJBPMWorkflowEngine] boolValue];
        }
        else
        {
            self.doesSupportCommentCounts = NO;
            self.doesSupportLikingNodes = NO;
            self.doesSupportPublicAPI = NO;
            self.doesSupportActivitiWorkflowEngine = NO;
            self.doesSupportJBPMWorkflowEngine = NO;
        }
    }
    return self;
}


- (BOOL)doesSupportCapability:(NSString *)capability
{
    if ([capability isEqualToString:kAlfrescoCapabilityPublicAPI])
    {
        return self.doesSupportPublicAPI;
    }
    else if ([capability isEqualToString:kAlfrescoCapabilityLike])
    {
        return self.doesSupportLikingNodes;
    }
    else if ([capability isEqualToString:kAlfrescoCapabilityCommentsCount])
    {
        return self.doesSupportCommentCounts;
    }
    else if ([capability isEqualToString:kAlfrescoCapabilityActivitiWorkflowEngine])
    {
        return self.doesSupportActivitiWorkflowEngine;
    }
    else if ([capability isEqualToString:kAlfrescoCapabilityJBPMWorkflowEngine])
    {
        return self.doesSupportJBPMWorkflowEngine;
    }
    
    return NO;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:kRepositoryCapabilitiesModelVersion forKey:NSStringFromClass([self class])];
    [aCoder encodeBool:self.doesSupportCommentCounts forKey:kAlfrescoCapabilityCommentsCount];
    [aCoder encodeBool:self.doesSupportLikingNodes forKey:kAlfrescoCapabilityLike];
    [aCoder encodeBool:self.doesSupportPublicAPI forKey:kAlfrescoCapabilityPublicAPI];
    [aCoder encodeBool:self.doesSupportActivitiWorkflowEngine forKey:kAlfrescoCapabilityActivitiWorkflowEngine];
    [aCoder encodeBool:self.doesSupportJBPMWorkflowEngine forKey:kAlfrescoCapabilityJBPMWorkflowEngine];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (nil != self)
    {
        //uncomment this line if you need to check the model version
//        NSInteger version = [aDecoder decodeIntForKey:NSStringFromClass([self class])];
        self.doesSupportLikingNodes = [aDecoder decodeBoolForKey:kAlfrescoCapabilityCommentsCount];
        self.doesSupportCommentCounts = [aDecoder decodeBoolForKey:kAlfrescoCapabilityLike];
        self.doesSupportPublicAPI = [aDecoder decodeBoolForKey:kAlfrescoCapabilityPublicAPI];
        self.doesSupportActivitiWorkflowEngine = [aDecoder decodeBoolForKey:kAlfrescoCapabilityActivitiWorkflowEngine];
        self.doesSupportJBPMWorkflowEngine = [aDecoder decodeBoolForKey:kAlfrescoCapabilityJBPMWorkflowEngine];
    }
    return self;
}


@end
