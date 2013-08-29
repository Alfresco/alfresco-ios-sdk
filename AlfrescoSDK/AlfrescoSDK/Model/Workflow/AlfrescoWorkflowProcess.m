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

/** The AlfrescoWorkflowProcess model object
 
 Author: Tauseef Mughal (Alfresco)
 */

#import "AlfrescoWorkflowProcess.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoSession.h"

@interface AlfrescoWorkflowProcess ()

@property (nonatomic, weak, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *identifier;
@property (nonatomic, strong, readwrite) NSString *processDefinitionIdentifier;
@property (nonatomic, strong, readwrite) NSString *processDefinitionKey;
@property (nonatomic, strong, readwrite) NSDate *startedAt;
@property (nonatomic, strong, readwrite) NSDate *endedAt;
@property (nonatomic, strong, readwrite) NSDate *dueAt;
@property (nonatomic, strong, readwrite) NSNumber *priority;
@property (nonatomic, strong, readwrite) NSString *processDescription;
@property (nonatomic, strong, readwrite) NSString *initiatorUsername;

@end

@implementation AlfrescoWorkflowProcess

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
        NSDictionary *entry = [properties objectForKey:kAlfrescoPublicJSONEntry];
        self.identifier = [entry objectForKey:kAlfrescoPublicJSONIdentifier];
        self.processDefinitionIdentifier = [entry objectForKey:kAlfrescoPublicJSONProcessDefinitionID];
        self.processDefinitionKey = [entry objectForKey:kAlfrescoPublicJSONProcessDefinitionKey];
        self.startedAt = [entry objectForKey:kAlfrescoPublicJSONStartedAt];
        self.endedAt = [entry objectForKey:kAlfrescoPublicJSONEndedAt];
        self.dueAt = [entry objectForKey:kAlfrescoPublicJSONDueAt];
        self.processDescription = [entry objectForKey:kAlfrescoPublicJSONDescription];
        self.priority = [entry objectForKey:kAlfrescoPublicJSONPriority];
        self.initiatorUsername = [entry objectForKey:kAlfrescoPublicJSONStartUserID];
    }
    else
    {
        NSString *workflowEnginePrefix = [AlfrescoWorkflowUtils prefixForActivitiEngineType:self.session.workflowInfo.workflowEngine];
        self.identifier = [[properties objectForKey:kAlfrescoPublicJSONIdentifier] stringByReplacingOccurrencesOfString:workflowEnginePrefix withString:@""];
        self.processDefinitionIdentifier = [[[properties objectForKey:kAlfrescoOldJSONProcessDefinitionID] lastPathComponent] stringByReplacingOccurrencesOfString:workflowEnginePrefix withString:@""];
        self.processDefinitionKey = [[properties objectForKey:kAlfrescoOldJSONName] stringByReplacingOccurrencesOfString:workflowEnginePrefix withString:@""];
        self.startedAt = [properties objectForKey:kAlfrescoOldJSONStartedAt];
        self.endedAt = [properties objectForKey:kAlfrescoOldJSONEndedAt];
        self.dueAt = [properties objectForKey:kAlfrescoOldJSONDueAt];
        self.processDescription = [properties objectForKey:kAlfrescoOldJSONDescription];
        self.priority = [properties objectForKey:kAlfrescoOldJSONPriority];        
        NSDictionary *initiatorDictionary = [properties objectForKey:kAlfrescoOldJSONInitiator];
        self.initiatorUsername = [initiatorDictionary objectForKey:kAlfrescoJSONUserName];
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    // TODO
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    // TODO
    return self;
}

@end
