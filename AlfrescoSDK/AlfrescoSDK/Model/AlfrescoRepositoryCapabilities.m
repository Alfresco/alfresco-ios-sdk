/*******************************************************************************
 * Copyright (C) 2005-2012 Alfresco Software Limited.
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

@interface AlfrescoRepositoryCapabilities ()
@property (nonatomic, assign, readwrite) BOOL doesSupportLikingNodes;
@property (nonatomic, assign, readwrite) BOOL doesSupportCommentCounts;

@end

@implementation AlfrescoRepositoryCapabilities
@synthesize doesSupportLikingNodes = _doesSupportLikingNodes;
@synthesize doesSupportCommentCounts = _doesSupportCommentCounts;

- (id)initWithProperties:(NSDictionary *)properties
{
    self = [super init];
    if (nil != self)
    {
        if (nil != properties)
        {
            self.doesSupportCommentCounts = [[properties valueForKey:kAlfrescoCapabilityCommentsCount] boolValue];
            self.doesSupportLikingNodes = [[properties valueForKey:kAlfrescoCapabilityLike] boolValue];
        }
        else
        {
            self.doesSupportCommentCounts = NO;
            self.doesSupportLikingNodes = NO;
        }
    }
    return self;
}


- (BOOL)doesSupportCapability:(NSString *)capability
{
    if ([capability isEqualToString:kAlfrescoCapabilityLike])
    {
        return self.doesSupportLikingNodes;
    }
    else if ([capability isEqualToString:kAlfrescoCapabilityCommentsCount])
    {
        return self.doesSupportCommentCounts;
    }
    return NO;
}


@end
