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

/** AlfrescoPublicAPIWorkflowService
 
 Author: Tauseef Mughal (Alfresco)
 */

#import "AlfrescoPublicAPIWorkflowService.h"
#import "AlfrescoWorkflowObjectConverter.h"
#import "AlfrescoWorkflowInternalConstants.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoDocumentFolderService.h"
#import "AlfrescoURLUtils.h"
#import "AlfrescoLog.h"

@interface AlfrescoPublicAPIWorkflowService ()

@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, strong, readwrite) AlfrescoDocumentFolderService *documentService;
@property (nonatomic, strong, readwrite) NSDictionary *publicToPrivateStateMappings;
@property (nonatomic, strong, readwrite) NSDictionary *publicToPrivateVariableMappings;
@property (nonatomic, strong, readwrite) AlfrescoWorkflowObjectConverter *workflowObjectConverter;

@end


@implementation AlfrescoPublicAPIWorkflowService

- (id)initWithSession:(id<AlfrescoSession>)session
{
    self = [super init];
    if (self)
    {
        self.session = session;
        self.baseApiUrl = [[self.session.baseUrl absoluteString] stringByAppendingString:kAlfrescoPublicAPIWorkflowBaseURL];
        self.workflowObjectConverter = [[AlfrescoWorkflowObjectConverter alloc] init];
        self.documentService = [[AlfrescoDocumentFolderService alloc] initWithSession:session];
        self.publicToPrivateStateMappings = @{kAlfrescoWorkflowProcessStateAny : kAlfrescoPublicAPIWorkflowProcessStatusAny,
                                              kAlfrescoWorkflowProcessStateActive : kAlfrescoPublicAPIWorkflowProcessStatusActive,
                                              kAlfrescoWorkflowProcessStateCompleted : kAlfrescoPublicAPIWorkflowProcessStatusCompleted};
        self.publicToPrivateVariableMappings = @{kAlfrescoWorkflowProcessDescription : kAlfrescoWorkflowPublicBPMJSONProcessDescription,
                                                 kAlfrescoWorkflowProcessPriority : kAlfrescoWorkflowPublicBPMJSONProcessPriority,
                                                 kAlfrescoWorkflowProcessSendEmailNotification : kAlfrescoWorkflowPublicBPMJSONProcessSendEmailNotification,
                                                 kAlfrescoWorkflowProcessDueDate : kAlfrescoWorkflowPublicBPMJSONProcessDueDate,
                                                 kAlfrescoWorkflowProcessApprovalRate : kAlfrescoWorkflowPublicBPMJSONProcessApprovalRate};
    }
    
    return self;
}

#pragma mark - Retrieval methods

- (AlfrescoRequest *)retrieveProcessDefinitionsWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoPublicAPIWorkflowProcessDefinition];
    
    AlfrescoRequest *alfrescoRequest = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session requestBody:nil method:kAlfrescoHTTPGet alfrescoRequest:alfrescoRequest completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *workflowDefinitions = [self.workflowObjectConverter workflowDefinitionsFromPublicJSONData:data conversionError:&conversionError];
            completionBlock(workflowDefinitions, conversionError);
        }
    }];
    return alfrescoRequest;
}

- (AlfrescoRequest *)retrieveProcessDefinitionsWithListingContext:(AlfrescoListingContext *)listingContext
                                                  completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    if (!listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoPublicAPIWorkflowProcessDefinition listingContext:listingContext];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *workflowDefinitions = [self.workflowObjectConverter workflowDefinitionsFromPublicJSONData:data conversionError:&conversionError];
            NSDictionary *pagingInfo = [AlfrescoObjectConverter paginationJSONFromData:data error:&conversionError];
            AlfrescoPagingResult *pagingResult = nil;
            if (pagingInfo)
            {
                BOOL hasMore = [[pagingInfo valueForKeyPath:kAlfrescoWorkflowPublicJSONHasMoreItems] boolValue];
                int total = [[pagingInfo valueForKey:kAlfrescoWorkflowPublicJSONTotalItems] intValue];
                pagingResult = [[AlfrescoPagingResult alloc] initWithArray:workflowDefinitions hasMoreItems:hasMore totalItems:total];
            }
            completionBlock(pagingResult, conversionError);
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveProcessDefinitionWithIdentifier:(NSString *)processIdentifier
                                             completionBlock:(AlfrescoProcessDefinitionCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:processIdentifier argumentName:@"processIdentifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *requestString = [kAlfrescoPublicAPIWorkflowSingleProcessDefinition stringByReplacingOccurrencesOfString:kAlfrescoProcessDefinitionID withString:processIdentifier];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session method:kAlfrescoHTTPGet alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *parseError = nil;
            id jsonResponseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            if (parseError)
            {
                completionBlock(nil, parseError);
            }
            else
            {
                AlfrescoWorkflowProcessDefinition *processDefinition = [[AlfrescoWorkflowProcessDefinition alloc] initWithProperties:jsonResponseDictionary];
                completionBlock(processDefinition, error);
            }
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveProcessesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    return [self retrieveProcessesInState:kAlfrescoWorkflowProcessStateAny completionBlock:completionBlock];
}

- (AlfrescoRequest *)retrieveProcessesWithListingContext:(AlfrescoListingContext *)listingContext
                                         completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    return [self retrieveProcessesInState:kAlfrescoWorkflowProcessStateAny listingContext:listingContext completionBlock:completionBlock];
}

- (AlfrescoRequest *)retrieveProcessesInState:(NSString *)state
                              completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    /**
     * MJH: Removed 08/Jan/2014 due to ALF-20731
     *
     NSString *whereParameterString = [NSString stringWithFormat:@"(%@=%@ AND %@=%@)",
     kAlfrescoWorkflowProcessStatus, [self.publicToPrivateStateMappings objectForKey:state],
     kAlfrescoPublicAPIWorkflowProcessIncludeVariables, @"true"];
     */
    NSString *whereParameterString = [NSString stringWithFormat:@"(%@=%@)",
                                      kAlfrescoWorkflowProcessStatus, (self.publicToPrivateStateMappings)[state]];
    NSString *queryString = [AlfrescoURLUtils buildQueryStringWithDictionary:@{kAlfrescoPublicAPIWorkflowProcessWhereParameter : whereParameterString}];
    NSString *extensionURLString = [kAlfrescoPublicAPIWorkflowProcesses stringByAppendingString:queryString];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:extensionURLString];
    
    AlfrescoRequest *alfrescoRequest = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session method:kAlfrescoHTTPGet alfrescoRequest:alfrescoRequest completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *workflowProcesses = [self.workflowObjectConverter workflowProcessesFromPublicJSONData:data conversionError:&conversionError];
            completionBlock(workflowProcesses, conversionError);
        }
    }];
    return alfrescoRequest;
}

- (AlfrescoRequest *)retrieveProcessesInState:(NSString *)state
                               listingContext:(AlfrescoListingContext *)listingContext
                              completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    if (!listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    /**
     * MJH: Removed 08/Jan/2014 due to ALF-20731
     *
     NSString *whereParameterString = [NSString stringWithFormat:@"(%@=%@ AND %@=%@)",
     kAlfrescoWorkflowProcessStatus, [self.publicToPrivateStateMappings objectForKey:state],
     kAlfrescoPublicAPIWorkflowProcessIncludeVariables, @"true"];
     */
    NSString *whereParameterString = [NSString stringWithFormat:@"(%@=%@)",
                                      kAlfrescoWorkflowProcessStatus, (self.publicToPrivateStateMappings)[state]];
    NSString *queryString = [AlfrescoURLUtils buildQueryStringWithDictionary:@{kAlfrescoPublicAPIWorkflowProcessWhereParameter : whereParameterString}];
    NSString *extensionURLString = [kAlfrescoPublicAPIWorkflowProcesses stringByAppendingString:queryString];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:extensionURLString listingContext:listingContext];
    
    AlfrescoRequest *alfrescoRequest = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session requestBody:nil method:kAlfrescoHTTPGet alfrescoRequest:alfrescoRequest completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *workflowDefinitions = [self.workflowObjectConverter workflowProcessesFromPublicJSONData:data conversionError:&conversionError];
            NSDictionary *pagingInfo = [AlfrescoObjectConverter paginationJSONFromData:data error:&conversionError];
            AlfrescoPagingResult *pagingResult = nil;
            if (pagingInfo)
            {
                BOOL hasMore = [[pagingInfo valueForKeyPath:kAlfrescoWorkflowPublicJSONHasMoreItems] boolValue];
                int total = [[pagingInfo valueForKey:kAlfrescoWorkflowPublicJSONTotalItems] intValue];
                pagingResult = [[AlfrescoPagingResult alloc] initWithArray:workflowDefinitions hasMoreItems:hasMore totalItems:total];
            }
            completionBlock(pagingResult, conversionError);
        }
    }];
    
    return alfrescoRequest;
}

- (AlfrescoRequest *)retrieveProcessWithIdentifier:(NSString *)processIdentifier
                                   completionBlock:(AlfrescoProcessCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:processIdentifier argumentName:@"processIdentifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *requestString = [kAlfrescoPublicAPIWorkflowSingleProcess stringByReplacingOccurrencesOfString:kAlfrescoProcessID withString:processIdentifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *workflowProcesses = [self.workflowObjectConverter workflowProcessesFromPublicJSONData:data conversionError:&conversionError];
            if (conversionError)
            {
                completionBlock(nil, conversionError);
            }
            else
            {
                AlfrescoWorkflowProcess *process = workflowProcesses[0];
                completionBlock(process, conversionError);
            }
        }
    }];
    
    return request;
}

- (AlfrescoRequest *)retrieveImageForProcess:(AlfrescoWorkflowProcess *)process
                             completionBlock:(AlfrescoContentFileCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:process argumentName:@"process"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *requestString = [kAlfrescoPublicAPIWorkflowProcessImage stringByReplacingOccurrencesOfString:kAlfrescoProcessID withString:process.identifier];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            AlfrescoContentFile *contentFile = [[AlfrescoContentFile alloc] initWithData:data mimeType:@"application/octet-stream"];
            completionBlock(contentFile, error);
        }
    }];
    
    return request;
}

- (AlfrescoRequest *)retrieveImageForProcess:(AlfrescoWorkflowProcess *)process
                                outputStream:(NSOutputStream *)outputStream
                             completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:process argumentName:@"process"];
    [AlfrescoErrors assertArgumentNotNil:outputStream argumentName:@"outputStream"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *requestString = [kAlfrescoPublicAPIWorkflowProcessImage stringByReplacingOccurrencesOfString:kAlfrescoProcessID withString:process.identifier];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request outputStream:outputStream completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(NO, error);
        }
        else
        {
            completionBlock(YES, error);
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveTasksForProcess:(AlfrescoWorkflowProcess *)process
                             completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    return [self retrieveTasksForProcess:process inState:kAlfrescoWorkflowProcessStateAny completionBlock:completionBlock];
}

- (AlfrescoRequest *)retrieveTasksForProcess:(AlfrescoWorkflowProcess *)process
                                     inState:(NSString *)state
                             completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:process argumentName:@"process"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *queryString = [AlfrescoURLUtils buildQueryStringWithDictionary:@{kAlfrescoWorkflowTaskState : (self.publicToPrivateStateMappings)[state]}];
    NSString *requestString = [kAlfrescoPublicAPIWorkflowTasksForProcess stringByReplacingOccurrencesOfString:kAlfrescoProcessID withString:process.identifier];
    NSString *completeRequestString = [requestString stringByAppendingString:queryString];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:completeRequestString];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *tasks = [self.workflowObjectConverter workflowTasksFromPublicJSONData:data conversionError:&conversionError];
            
            if (error)
            {
                completionBlock(nil, conversionError);
            }
            else
            {
                completionBlock(tasks, conversionError);
            }
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveAttachmentsForProcess:(AlfrescoWorkflowProcess *)process
                                   completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:process argumentName:@"process"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *requestString = [kAlfrescoPublicAPIWorkflowAttachmentsForProcess stringByReplacingOccurrencesOfString:kAlfrescoProcessID withString:process.identifier];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *attachmentIdentifiers = [self.workflowObjectConverter attachmentIdentifiersFromPublicJSONData:data conversionError:&conversionError];
            if (conversionError)
            {
                completionBlock(nil, conversionError);
            }
            else
            {
                [self retrieveAlfrescoNodes:attachmentIdentifiers completionBlock:completionBlock];
            }
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveTasksWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoPublicAPIWorkflowTasks];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *workflowTasks = [self.workflowObjectConverter workflowTasksFromPublicJSONData:data conversionError:&conversionError];
            completionBlock(workflowTasks, conversionError);
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveTasksWithListingContext:(AlfrescoListingContext *)listingContext
                                     completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    if (!listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoPublicAPIWorkflowProcessDefinition listingContext:listingContext];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *workflowDefinitions = [self.workflowObjectConverter workflowTasksFromPublicJSONData:data conversionError:&conversionError];;
            NSDictionary *pagingInfo = [AlfrescoObjectConverter paginationJSONFromData:data error:&conversionError];
            AlfrescoPagingResult *pagingResult = nil;
            if (pagingInfo)
            {
                BOOL hasMore = [[pagingInfo valueForKeyPath:kAlfrescoWorkflowPublicJSONHasMoreItems] boolValue];
                int total = [[pagingInfo valueForKey:kAlfrescoWorkflowPublicJSONTotalItems] intValue];
                pagingResult = [[AlfrescoPagingResult alloc] initWithArray:workflowDefinitions hasMoreItems:hasMore totalItems:total];
            }
            completionBlock(pagingResult, conversionError);
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveTaskWithIdentifier:(NSString *)taskIdentifier
                                completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:taskIdentifier argumentName:@"taskIdentifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *requestString = [kAlfrescoPublicAPIWorkflowSingleTask stringByReplacingOccurrencesOfString:kAlfrescoTaskID withString:taskIdentifier];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            id workflowTaskJSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&conversionError];
            if (conversionError || ![workflowTaskJSONObject isKindOfClass:[NSDictionary class]])
            {
                completionBlock(nil, conversionError);
            }
            else
            {
                AlfrescoWorkflowTask *task = [[AlfrescoWorkflowTask alloc] initWithProperties:(NSDictionary *)workflowTaskJSONObject];
                completionBlock(task, conversionError);
            }
            
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveAttachmentsForTask:(AlfrescoWorkflowTask *)task
                                completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:task argumentName:@"task"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *requestString = [kAlfrescoPublicAPIWorkflowTaskAttachments stringByReplacingOccurrencesOfString:kAlfrescoTaskID withString:task.identifier];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *attachmentIdentifiers = [self.workflowObjectConverter attachmentIdentifiersFromPublicJSONData:data conversionError:&conversionError];
            if (conversionError)
            {
                completionBlock(nil, conversionError);
            }
            else
            {
                [self retrieveAlfrescoNodes:attachmentIdentifiers completionBlock:completionBlock];
            }
        }
    }];
    return request;
}

#pragma mark - Process management methods

- (AlfrescoRequest *)startProcessForProcessDefinition:(AlfrescoWorkflowProcessDefinition *)processDefinition
                                            assignees:(NSArray *)assignees
                                            variables:(NSDictionary *)variables
                                          attachments:(NSArray *)attachmentNodes
                                      completionBlock:(AlfrescoProcessCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:processDefinition argumentName:@"processDefinition"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSMutableDictionary *requestBody = [NSMutableDictionary dictionary];
    NSMutableArray *nodeRefs = [NSMutableArray arrayWithCapacity:attachmentNodes.count];
    
    for (id attachmentNodeObject in attachmentNodes)
    {
        if (![attachmentNodeObject isKindOfClass:[AlfrescoNode class]])
        {
            NSString *reason = [NSString stringWithFormat:@"The assignees passed in must be AlfrescoPerson instances, but instead you passed in an instance of %@", NSStringFromClass([attachmentNodeObject class])];
            @throw [NSException exceptionWithName:@"Invalid assignees value" reason:reason userInfo:nil];
        }
        
        AlfrescoNode *node = (AlfrescoNode *)attachmentNodeObject;
        NSString *cleanNodeRef = [AlfrescoObjectConverter nodeRefWithoutVersionID:node.identifier];
        [nodeRefs addObject:cleanNodeRef];
    }
    
    if (nodeRefs.count > 0)
    {
        requestBody[kAlfrescoJSONItems] = nodeRefs;
    }
    
    NSArray *allVariableKeys = [variables allKeys];
    NSDictionary *completeVariables = [NSMutableDictionary dictionary];
    for (id keyObject in allVariableKeys)
    {
        NSString *key = (NSString *)keyObject;
        NSString *mappedPrivateKey = (self.publicToPrivateVariableMappings)[key];
        
        if (mappedPrivateKey)
        {
            [completeVariables setValue:variables[key] forKey:mappedPrivateKey];
        }
        else
        {
            [completeVariables setValue:variables[key] forKey:key];
        }
    }
    
    if (!assignees)
    {
        [completeVariables setValue:self.session.personIdentifier forKey:kAlfrescoWorkflowPublicBPMJSONProcessAssignee];
    }
    else
    {
        NSMutableArray *assigneeIdentifiers = [NSMutableArray arrayWithCapacity:assignees.count];
        for (AlfrescoPerson *person in assignees)
        {
            [assigneeIdentifiers addObject:person.identifier];
        }
        
        if (assignees.count == 1)
        {
            [completeVariables setValue:assigneeIdentifiers[0] forKey:kAlfrescoWorkflowPublicBPMJSONProcessAssignee];
        }
        else
        {
            [completeVariables setValue:assigneeIdentifiers forKey:kAlfrescoWorkflowPublicBPMJSONProcessAssignees];
        }
    }
    
    // add the variables dictionary to the request
    if (completeVariables.count > 0)
    {
        [requestBody setValue:completeVariables forKey:kAlfrescoWorkflowPublicJSONVariables];
    }
    
    requestBody[kAlfrescoWorkflowPublicJSONProcessDefinitionID] = processDefinition.identifier;
    
    NSError *requestConversionError = nil;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestBody options:0 error:&requestConversionError];
    if (requestConversionError)
    {
        AlfrescoLogDebug(@"Parsing of dictionary failed in selector - %@", NSStringFromSelector(_cmd));
        completionBlock(nil, requestConversionError);
    }
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoPublicAPIWorkflowProcesses];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session requestBody:requestData method:kAlfrescoHTTPPOST alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            id workflowProcessesDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&conversionError];
            if (conversionError || ![workflowProcessesDictionary isKindOfClass:[NSDictionary class]])
            {
                completionBlock(nil, conversionError);
            }
            else
            {
                AlfrescoWorkflowProcess *process = [[AlfrescoWorkflowProcess alloc] initWithProperties:(NSDictionary *)workflowProcessesDictionary];
                completionBlock(process, conversionError);
            }
        }
    }];
    return request;
}

- (AlfrescoRequest *)deleteProcess:(AlfrescoWorkflowProcess *)process
                   completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:process argumentName:@"process"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *requestString = [kAlfrescoPublicAPIWorkflowSingleProcess stringByReplacingOccurrencesOfString:kAlfrescoProcessID withString:process.identifier];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session method:kAlfrescoHTTPDelete alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(NO, error);
        }
        else
        {
            completionBlock(YES, error);
        }
    }];
    return request;
}

#pragma mark - Task management methods


- (AlfrescoRequest *)completeTask:(AlfrescoWorkflowTask *)task
                       properties:(NSDictionary *)properties
                  completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    return [self updateStateForTask:task state:@{kAlfrescoWorkflowTaskState : kAlfrescoPublicAPIWorkflowTaskStateCompleted} completionBlock:completionBlock];
}

- (AlfrescoRequest *)claimTask:(AlfrescoWorkflowTask *)task
               completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    return [self updateStateForTask:task state:@{kAlfrescoWorkflowTaskState : kAlfrescoPublicAPIWorkflowTaskStateClaimed} completionBlock:completionBlock];
}

- (AlfrescoRequest *)unclaimTask:(AlfrescoWorkflowTask *)task
                 completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    return [self updateStateForTask:task state:@{kAlfrescoWorkflowTaskState : kAlfrescoPublicAPIWorkflowTaskStateUnclaimed} completionBlock:completionBlock];
}

- (AlfrescoRequest *)reassignTask:(AlfrescoWorkflowTask *)task
                       toAssignee:(AlfrescoPerson *)assignee
                  completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    return [self updateStateForTask:task state:@{kAlfrescoWorkflowTaskState : kAlfrescoPublicAPIWorkflowTaskStateClaimed, kAlfrescoPublicAPIWorkflowTaskAssignee : assignee.identifier} completionBlock:completionBlock];
}

- (AlfrescoRequest *)resolveTask:(AlfrescoWorkflowTask *)task
                 completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    return [self updateStateForTask:task state:@{kAlfrescoWorkflowTaskState : kAlfrescoPublicAPIWorkflowTaskStateResolved} completionBlock:completionBlock];
}

- (AlfrescoRequest *)addAttachmentToTask:(AlfrescoWorkflowTask *)task
                              attachment:(AlfrescoNode *)node
                         completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    return [self addAttachmentsToTask:task attachments:@[node] completionBlock:completionBlock];
}

- (AlfrescoRequest *)addAttachmentsToTask:(AlfrescoWorkflowTask *)task
                              attachments:(NSArray *)nodeArray
                          completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:nodeArray argumentName:@"nodeArray"];
    [AlfrescoErrors assertArgumentNotNil:task argumentName:@"task"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSMutableArray *requestBody = [NSMutableArray arrayWithCapacity:nodeArray.count];
    for (id nodeObject in nodeArray)
    {
        if (![nodeObject isKindOfClass:[AlfrescoNode class]])
        {
            NSString *exceptionMessage = [NSString stringWithFormat:@"The node array passed into %@ should contain instances of %@, instead it contained instances of %@",
                                          NSStringFromSelector(_cmd),
                                          NSStringFromClass([AlfrescoNode class]),
                                          NSStringFromClass([nodeObject class])];
            @throw [NSException exceptionWithName:@"Invaild parameters" reason:exceptionMessage userInfo:nil];
        }
        
        AlfrescoNode *currentNode = (AlfrescoNode *)nodeObject;
        // this should be fixed in the workflow api to accept complete node refs
        //        [nodeRefs addObject:@{kAlfrescoJSONIdentifier : currentNode.identifier}];
        [requestBody addObject:@{kAlfrescoJSONIdentifier : [AlfrescoObjectConverter nodeGUIDFromNodeIdentifier:currentNode.identifier]}];
    }
    
    NSError *requestConversionError = nil;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestBody options:0 error:&requestConversionError];
    
    if (requestConversionError)
    {
        AlfrescoLogDebug(@"Request could not be parsed correctly in %@", NSStringFromSelector(_cmd));
    }
    
    NSString *requestString = [kAlfrescoPublicAPIWorkflowTaskAttachments stringByReplacingOccurrencesOfString:kAlfrescoTaskID withString:task.identifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session requestBody:requestData method:kAlfrescoHTTPPOST alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(NO, error);
        }
        else
        {
            completionBlock(YES, error);
        }
    }];
    return request;
}

- (AlfrescoRequest *)removeAttachmentFromTask:(AlfrescoWorkflowTask *)task
                                   attachment:(AlfrescoNode *)node
                              completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:task argumentName:@"task"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *requestString = [kAlfrescoPublicAPIWorkflowTaskSingleAttachment stringByReplacingOccurrencesOfString:kAlfrescoTaskID withString:task.identifier];
    requestString = [requestString stringByReplacingOccurrencesOfString:kAlfrescoItemID withString:[AlfrescoObjectConverter nodeGUIDFromNodeIdentifier:node.identifier]];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session method:kAlfrescoHTTPDelete alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(NO, nil);
        }
        else
        {
            completionBlock(YES, error);
        }
    }];
    return request;
}

#pragma mark - Private helper methods

- (void)retrieveAlfrescoNodes:(NSArray *)alfrescoNodeIdentifiers
              completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    __block NSMutableArray *alfrescoNodes = [NSMutableArray array];
    __block NSInteger callBacks = 0;
    
    for (NSString *nodeIdentifier in alfrescoNodeIdentifiers)
    {
        [self.documentService retrieveNodeWithIdentifier:nodeIdentifier completionBlock:^(AlfrescoNode *node, NSError *error) {
            callBacks++;
            if (node)
            {
                [alfrescoNodes addObject:node];
            }
            
            if (callBacks == alfrescoNodeIdentifiers.count)
            {
                completionBlock(alfrescoNodes, nil);
            }
        }];
    }
}

- (AlfrescoRequest *)updateStateForTask:(AlfrescoWorkflowTask *)task
                                  state:(NSDictionary *)requestDictionary
                        completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:task argumentName:@"task"];
    [AlfrescoErrors assertArgumentNotNil:requestDictionary argumentName:@"requestDictionary"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSMutableString *requestString = [[kAlfrescoPublicAPIWorkflowSingleTask stringByReplacingOccurrencesOfString:kAlfrescoTaskID withString:task.identifier] mutableCopy];
    
    // build the select parameters string
    NSMutableString *requestParametersString = [[NSMutableString alloc] init];
    NSArray *allParameterKeys = [requestDictionary allKeys];
    for (int i = 0; i < allParameterKeys.count; i++)
    {
        NSString *key = allParameterKeys[i];
        [requestParametersString appendString:key];
        if (i != (allParameterKeys.count - 1))
        {
            [requestParametersString appendString:@","];
        }
    }
    
    NSString *parameters = [AlfrescoURLUtils buildQueryStringWithDictionary:@{kAlfrescoWorkflowTaskSelectParameter : requestParametersString}];
    [requestString appendString:parameters];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    NSError *requestBodyConversionError = nil;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestDictionary options:0 error:&requestBodyConversionError];
    
    if (requestBodyConversionError)
    {
        AlfrescoLogDebug(@"Request could not be parsed correctly in %@", NSStringFromSelector(_cmd));
        return nil;
    }
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session requestBody:requestData method:kAlfrescoHTTPPut alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            id workflowTaskJSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&conversionError];
            if (conversionError || ![workflowTaskJSONObject isKindOfClass:[NSDictionary class]])
            {
                completionBlock(nil, conversionError);
            }
            else
            {
                AlfrescoWorkflowTask *task = [[AlfrescoWorkflowTask alloc] initWithProperties:(NSDictionary *)workflowTaskJSONObject];
                completionBlock(task, conversionError);
            }
        }
    }];
    return request;
}

@end
