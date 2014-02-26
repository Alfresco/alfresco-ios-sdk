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

/** The AlfrescoWorkflowProcessDefinition model object
 
 Author: Tauseef Mughal (Alfresco)
 */

#import "AlfrescoWorkflowProcessDefinition.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoSession.h"
#import "AlfrescoWorkflowUtils.h"

static NSInteger kWorkflowProcessDefinitionModelVersion = 1;

@interface AlfrescoWorkflowProcessDefinition ()

@property (nonatomic, weak, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *identifier;
@property (nonatomic, strong, readwrite) NSString *key;
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSString *processDescription;
@property (nonatomic, strong, readwrite) NSNumber *version;

@end

@implementation AlfrescoWorkflowProcessDefinition

- (id)initWithProperties:(NSDictionary *)properties session:(id<AlfrescoSession>)session
{
    self = [super init];
    if (self)
    {
        self.session = session;
        [self setupProperties:properties];
    }
    return self;
}

#pragma mark - Private Functions

- (void)setupProperties:(NSDictionary *)properties
{
    if (self.session.workflowInfo.publicAPI)
    {
        NSDictionary *entry = [properties objectForKey:kAlfrescoWorkflowPublicJSONEntry];
        self.identifier = [entry objectForKey:kAlfrescoWorkflowPublicJSONIdentifier];
        self.key = [entry objectForKey:kAlfrescoWorkflowPublicJSONKey];
        self.name = [entry objectForKey:kAlfrescoWorkflowPublicJSONTitle];
        self.processDescription = [entry objectForKey:kAlfrescoWorkflowPublicJSONDescription];
        self.version = [entry objectForKey:kAlfrescoWorkflowPublicJSONVersion];
    }
    else
    {
        NSString *workflowEnginePrefix = [AlfrescoWorkflowUtils prefixForActivitiEngineType:self.session.workflowInfo.workflowEngine];
        self.identifier = [[properties objectForKey:kAlfrescoJSONIdentifier] stringByReplacingOccurrencesOfString:workflowEnginePrefix withString:@""];
        self.key = [[properties objectForKey:kAlfrescoWorkflowLegacyJSONName] stringByReplacingOccurrencesOfString:workflowEnginePrefix withString:@""];
        self.name = [properties objectForKey:kAlfrescoWorkflowLegacyJSONTitle];
        self.processDescription = [properties objectForKey:kAlfrescoWorkflowLegacyJSONDescription];
        self.version = [properties objectForKey:kAlfrescoWorkflowPublicJSONVersion];
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:kWorkflowProcessDefinitionModelVersion forKey:NSStringFromClass([self class])];
    [aCoder encodeObject:self.identifier forKey:kAlfrescoWorkflowPublicJSONIdentifier];
    [aCoder encodeObject:self.key forKey:kAlfrescoWorkflowPublicJSONKey];
    [aCoder encodeObject:self.name forKey:kAlfrescoWorkflowPublicJSONTitle];
    [aCoder encodeObject:self.processDescription forKey:kAlfrescoWorkflowPublicJSONDescription];
    [aCoder encodeObject:self.version forKey:kAlfrescoWorkflowPublicJSONVersion];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        //        NSInteger version = [aDecoder decodeIntegerForKey:NSStringFromClass([self class])];
        self.identifier = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONIdentifier];
        self.key = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONKey];
        self.name = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONTitle];
        self.processDescription = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONDescription];
        self.version = [aDecoder decodeObjectForKey:kAlfrescoWorkflowPublicJSONVersion];
    }
    return self;
}

@end
