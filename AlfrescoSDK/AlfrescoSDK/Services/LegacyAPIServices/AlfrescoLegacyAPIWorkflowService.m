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

/** AlfrescoLegacyAPIWorkflowService
 
 Author: Tauseef Mughal (Alfresco)
 */

#import "AlfrescoLegacyAPIWorkflowService.h"
#import "AlfrescoWorkflowObjectConverter.h"
#import "AlfrescoWorkflowInternalConstants.h"
#import "AlfrescoWorkflowUtils.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoDocumentFolderService.h"
#import "AlfrescoURLUtils.h"
#import "AlfrescoPagingUtils.h"
#import "AlfrescoLog.h"

@interface AlfrescoLegacyAPIWorkflowService ()

@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, strong, readwrite) AlfrescoDocumentFolderService *documentService;
@property (nonatomic, strong, readwrite) NSDictionary *publicToPrivateStateMappings;
@property (nonatomic, strong, readwrite) NSDictionary *publicToPrivateVariableMappings;
@property (nonatomic, strong, readwrite) AlfrescoWorkflowObjectConverter *workflowObjectConverter;

@end

@implementation AlfrescoLegacyAPIWorkflowService

- (id)initWithSession:(id<AlfrescoSession>)session
{
    self = [super init];
    if (self)
    {
        self.session = session;
        self.baseApiUrl = [[self.session.baseUrl absoluteString] stringByAppendingString:kAlfrescoLegacyAPIWorkflowBaseURL];
        self.workflowObjectConverter = [[AlfrescoWorkflowObjectConverter alloc] init];
        self.documentService = [[AlfrescoDocumentFolderService alloc] initWithSession:session];
        self.publicToPrivateStateMappings = @{kAlfrescoWorkflowProcessStateActive : kAlfrescoLegacyAPIWorkflowStatusInProgress,
                                              kAlfrescoWorkflowProcessStateCompleted : kAlfrescoLegacyAPIWorkflowStatusCompleted};
        self.publicToPrivateVariableMappings = @{kAlfrescoWorkflowProcessDescription : kAlfrescoWorkflowLegacyJSONBPMProcessDescription,
                                                 kAlfrescoWorkflowProcessPriority : kAlfrescoWorkflowLegacyJSONLegacyProcessPriority,
                                                 kAlfrescoWorkflowProcessSendEmailNotification : kAlfrescoWorkflowLegacyJSONBPMProcessSendEmailNotification,
                                                 kAlfrescoWorkflowProcessDueDate : kAlfrescoWorkflowLegacyJSONBPMProcessDueDate,
                                                 kAlfrescoWorkflowProcessApprovalRate : kAlfrescoWorkflowLegacyJSONBPMProcessApprovalRate};
    }
    
    return self;
}

#pragma mark - Retrieval methods

- (AlfrescoRequest *)retrieveProcessDefinitionsWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoLegacyAPIWorkflowProcessDefinition];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (!data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *workflowDefinitions = [self.workflowObjectConverter workflowDefinitionsFromLegacyJSONData:data conversionError:&conversionError];
            completionBlock(workflowDefinitions, conversionError);
        }
    }];
    
    return request;
}

- (AlfrescoRequest *)retrieveProcessDefinitionsWithListingContext:(AlfrescoListingContext *)listingContext
                                                  completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    if (!listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoLegacyAPIWorkflowProcessDefinition];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (!data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *workflowDefinitions = [self.workflowObjectConverter workflowDefinitionsFromLegacyJSONData:data conversionError:&conversionError];
            AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:workflowDefinitions listingContext:listingContext];
            completionBlock(pagingResult, conversionError);
        }
    }];
    
    return request;
}

- (AlfrescoRequest *)retrieveProcessDefinitionWithIdentifier:(NSString *)processIdentifier
                                             completionBlock:(AlfrescoProcessDefinitionCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    [AlfrescoErrors assertArgumentNotNil:processIdentifier argumentName:@"processIdentifier"];
    
    AlfrescoRequest *request = nil;
    
    if (!self.session.repositoryInfo.capabilities.doesSupportLikingNodes)
    {
        NSError *notSupportedError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeWorkflowFunctionNotSupported];
        completionBlock(nil, notSupportedError);
    }
    else
    {
        request = [[AlfrescoRequest alloc] init];
        NSString *requestString = [kAlfrescoLegacyAPIWorkflowSingleProcessDefinition stringByReplacingOccurrencesOfString:kAlfrescoProcessDefinitionID withString:processIdentifier];
        
        NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
        
        [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
            if (!data)
            {
                completionBlock(nil, error);
            }
            else
            {
                NSError *conversionError = nil;
                NSArray *workflowDefinitions = [self.workflowObjectConverter workflowDefinitionsFromLegacyJSONData:data conversionError:&conversionError];
                if (workflowDefinitions.count > 0)
                {
                    AlfrescoWorkflowProcessDefinition *processDefinition = workflowDefinitions[0];
                    completionBlock(processDefinition, conversionError);
                }
                else
                {
                    completionBlock(nil, conversionError);
                }
            }
        }];
    }
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
    
    NSString *queryString = nil;
    
    if (state && ![state isEqualToString:kAlfrescoWorkflowProcessStateAny])
    {
        queryString = [AlfrescoURLUtils buildQueryStringWithDictionary:@{kAlfrescoWorkflowProcessStatus : (self.publicToPrivateStateMappings)[state]}];
    }
    
    NSString *requestString = (queryString) ? [kAlfrescoLegacyAPIWorkflowInstances stringByAppendingString:queryString] : kAlfrescoLegacyAPIWorkflowInstances;
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
            NSArray *processes = [self.workflowObjectConverter workflowProcessesFromLegacyJSONData:data conversionError:&conversionError];
            completionBlock(processes, conversionError);
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveProcessesInState:(NSString *)state
                               listingContext:(AlfrescoListingContext *)listingContext
                              completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *queryString = nil;
    
    if (state && ![state isEqualToString:kAlfrescoWorkflowProcessStateAny])
    {
        queryString = [AlfrescoURLUtils buildQueryStringWithDictionary:@{kAlfrescoWorkflowProcessStatus : (self.publicToPrivateStateMappings)[state]}];
    }
    
    if (!listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    NSString *requestString = (queryString) ? [kAlfrescoLegacyAPIWorkflowInstances stringByAppendingString:queryString] : kAlfrescoLegacyAPIWorkflowInstances;
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString listingContext:listingContext];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *processes = [self.workflowObjectConverter workflowProcessesFromLegacyJSONData:data conversionError:&conversionError];
            NSDictionary *pagingInfo = [AlfrescoObjectConverter paginationJSONFromOldAPIData:data error:&conversionError];
            int total = [[pagingInfo valueForKey:kAlfrescoWorkflowLegacyJSONTotalItems] intValue];
            int maxItems = [[pagingInfo valueForKey:kAlfrescoWorkflowLegacyJSONMaxItems] intValue];
            BOOL hasMore = ((listingContext.skipCount + maxItems) < total);
            AlfrescoPagingResult *pagingResult = [[AlfrescoPagingResult alloc] initWithArray:processes hasMoreItems:hasMore totalItems:total];
            completionBlock(pagingResult, conversionError);
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveProcessWithIdentifier:(NSString *)processIdentifier
                                   completionBlock:(AlfrescoProcessCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    [AlfrescoErrors assertArgumentNotNil:processIdentifier argumentName:@"processIdentifier"];
    
    NSString *requestString = [kAlfrescoLegacyAPIWorkflowSingleInstance stringByReplacingOccurrencesOfString:kAlfrescoProcessID withString:processIdentifier];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (!data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *tasks = [self.workflowObjectConverter workflowProcessesFromLegacyJSONData:data conversionError:&conversionError];
            AlfrescoWorkflowProcess *task = tasks[0];
            completionBlock(task, conversionError);
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveImageForProcess:(AlfrescoWorkflowProcess *)process
                             completionBlock:(AlfrescoContentFileCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    [AlfrescoErrors assertArgumentNotNil:process argumentName:@"process"];
    
    if (self.session.repositoryInfo.capabilities.doesSupportActivitiWorkflowEngine)
    {
        NSString *requestString = [kAlfrescoLegacyAPIWorkflowProcessDiagram stringByReplacingOccurrencesOfString:kAlfrescoProcessID withString:process.identifier];
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
    else
    {
        NSError *notSupportedError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeWorkflowFunctionNotSupported];
        if (completionBlock != NULL)
        {
            completionBlock(nil, notSupportedError);
        }
        return nil;
    }
}

- (AlfrescoRequest *)retrieveImageForProcess:(AlfrescoWorkflowProcess *)process
                                outputStream:(NSOutputStream *)outputStream
                             completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    [AlfrescoErrors assertArgumentNotNil:outputStream argumentName:@"outputStream"];
    [AlfrescoErrors assertArgumentNotNil:process argumentName:@"process"];
    
    if (self.session.repositoryInfo.capabilities.doesSupportActivitiWorkflowEngine)
    {
        NSString *requestString = [kAlfrescoLegacyAPIWorkflowProcessDiagram stringByReplacingOccurrencesOfString:kAlfrescoProcessID withString:process.identifier];
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
        return nil;
    }
    else
    {
        NSError *notSupportedError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeWorkflowFunctionNotSupported];
        if (completionBlock != NULL)
        {
            completionBlock(NO, notSupportedError);
        }
        return nil;
    }
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
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    [AlfrescoErrors assertArgumentNotNil:process argumentName:@"process"];
    
    NSString *queryString = nil;
    if (state && ![state isEqualToString:kAlfrescoWorkflowProcessStateAny])
    {
        queryString = [AlfrescoURLUtils buildQueryStringWithDictionary:@{kAlfrescoWorkflowTaskState : (self.publicToPrivateStateMappings)[state]}];
    }
    
    NSString *requestString = [kAlfrescoLegacyAPIWorkflowTasksForInstance stringByReplacingOccurrencesOfString:kAlfrescoProcessID withString:process.identifier];
    if (queryString)
    {
        requestString = [requestString stringByAppendingString:queryString];
    }
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (!data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *tasks = [self.workflowObjectConverter workflowTasksFromLegacyJSONData:data conversionError:&conversionError];
            completionBlock(tasks, conversionError);
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveTasksWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoLegacyAPIWorkflowTasks];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *tasks = [self.workflowObjectConverter workflowTasksFromLegacyJSONData:data conversionError:&conversionError];
            completionBlock(tasks, conversionError);
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
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoLegacyAPIWorkflowTasks listingContext:listingContext];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *workflowTasks = [self.workflowObjectConverter workflowTasksFromLegacyJSONData:data conversionError:&conversionError];
            NSDictionary *pagingInfo = [AlfrescoObjectConverter paginationJSONFromOldAPIData:data error:&conversionError];
            int total = [[pagingInfo valueForKey:kAlfrescoWorkflowLegacyJSONTotalItems] intValue];
            int maxItems = [[pagingInfo valueForKey:kAlfrescoWorkflowLegacyJSONMaxItems] intValue];
            BOOL hasMore = ((listingContext.skipCount + maxItems) < total);
            AlfrescoPagingResult *pagingResult = [[AlfrescoPagingResult alloc] initWithArray:workflowTasks hasMoreItems:hasMore totalItems:total];
            completionBlock(pagingResult, conversionError);
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveTaskWithIdentifier:(NSString *)taskIdentifier
                                completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    [AlfrescoErrors assertArgumentNotNil:taskIdentifier argumentName:@"taskIdentifier"];
    
    NSString *requestString = [kAlfrescoLegacyAPIWorkflowSingleTask stringByReplacingOccurrencesOfString:kAlfrescoTaskID withString:taskIdentifier];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (!data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            id responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&conversionError];
            
            NSDictionary *entry = ((NSDictionary *)responseObject)[kAlfrescoWorkflowLegacyJSONData];
            AlfrescoWorkflowTask *task = [[AlfrescoWorkflowTask alloc] initWithProperties:entry];
            completionBlock(task, conversionError);
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveAttachmentsForTask:(AlfrescoWorkflowTask *)task
                                completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    [AlfrescoErrors assertArgumentNotNil:task argumentName:@"task"];
    
    NSDictionary *requestDictionary = @{kAlfrescoLegacyAPIWorkflowItemKind : kAlfrescoLegacyAPIWorkflowItemTypeTask,
                                        kAlfrescoLegacyAPIWorkflowItemID : task.identifier,
                                        kAlfrescoLegacyAPIWorkflowFields : @[kAlfrescoLegacyAPIWorkflowPackageItems]};
    NSError *jsonParseError = nil;
    NSData *containerRequestData = [NSJSONSerialization dataWithJSONObject:requestDictionary options:0 error:&jsonParseError];
    
    if (jsonParseError)
    {
        AlfrescoLogDebug(@"Unable to parse data in selector - %@", NSStringFromSelector(_cmd));
    }
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoLegacyAPIWorkflowTaskAttachments];
    
    __block AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session requestBody:containerRequestData method:kAlfrescoHTTPPOST alfrescoRequest:request completionBlock:^(NSData *data, NSError *attachmentRefError) {
        if (!data)
        {
            completionBlock(nil, attachmentRefError);
        }
        else
        {
            NSError *nodeIdentifierError = nil;
            NSArray *nodeIdentifiers = [self.workflowObjectConverter attachmentIdentifiersFromLegacyJSONData:data conversionError:&nodeIdentifierError];
            
            if (nodeIdentifiers)
            {
                [self retrieveAlfrescoNodes:nodeIdentifiers completionBlock:completionBlock];
            }
            else
            {
                completionBlock(nil, nil);
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
    
    NSArray *allVariableKeys = [variables allKeys];
    for (id keyObject in allVariableKeys)
    {
        NSString *key = (NSString *)keyObject;
        NSString *mappedPrivateKey = (self.publicToPrivateVariableMappings)[key];
        
        if (mappedPrivateKey)
        {
            [requestBody setValue:variables[key] forKey:mappedPrivateKey];
        }
        else
        {
            [requestBody setValue:variables[key] forKey:key];
        }
    }
    
    // attachments
    NSString *documentsAdded = nil;
    for (int i = 0; i < attachmentNodes.count; i++)
    {
        id nodeObject = attachmentNodes[i];
        
        if (![nodeObject isKindOfClass:[AlfrescoNode class]])
        {
            NSString *reason = [NSString stringWithFormat:@"The attachment array should contain instances of %@, but instead contains %@", NSStringFromClass([AlfrescoNode class]), NSStringFromClass([nodeObject class])];
            @throw [NSException exceptionWithName:@"Invalid attachments" reason:reason userInfo:nil];
        }
        
        AlfrescoNode *currentNode = (AlfrescoNode *)nodeObject;
        if (i == 0)
        {
            documentsAdded = currentNode.identifier;
        }
        else
        {
            documentsAdded = [NSString stringWithFormat:@"%@,%@", documentsAdded, currentNode.identifier];
        }
    }
    
    if (documentsAdded)
    {
        [requestBody setValue:documentsAdded forKey:kAlfrescoWorkflowLegacyJSONBPMProcessAttachmentsAdd];
    }
    
    void (^parseAndSendCreationRequest)(AlfrescoRequest *request) = ^(AlfrescoRequest *request){
        // parse
        NSError *requestConversionError = nil;
        NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestBody options:0 error:&requestConversionError];
        
        if (requestConversionError)
        {
            AlfrescoLogDebug(@"Unable to successfully create request data");
            completionBlock(nil, requestConversionError);
        }
        
        NSString *requestString = [kAlfrescoLegacyAPIWorkflowFormProcessor stringByReplacingOccurrencesOfString:kAlfrescoProcessDefinitionID withString:processDefinition.key];
        NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
        
        [self.session.networkProvider executeRequestWithURL:url session:self.session requestBody:requestData method:kAlfrescoHTTPPOST alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
            if (error)
            {
                completionBlock(nil, error);
            }
            else
            {
                NSError *conversionError = nil;
                id responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&conversionError];
                if (conversionError)
                {
                    completionBlock(nil, conversionError);
                }
                else
                {
                    NSString *completedString = ((NSDictionary *)responseObject)[@"persistedObject"];
                    NSArray *separatedStrings = [completedString componentsSeparatedByString:@","];
                    NSString *createdProcessID = [[separatedStrings[0] componentsSeparatedByString:@"id="] lastObject];
                    
                    NSString *requestString = [kAlfrescoLegacyAPIWorkflowSingleInstance stringByReplacingOccurrencesOfString:kAlfrescoProcessID withString:createdProcessID];
                    
                    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
                    
                    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
                    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
                        if (!data)
                        {
                            completionBlock(nil, error);
                        }
                        else
                        {
                            NSError *conversionError = nil;
                            id responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&conversionError];
                            
                            NSDictionary *entry = ((NSDictionary *) responseObject)[kAlfrescoWorkflowLegacyJSONData];
                            AlfrescoWorkflowProcess *process = [[AlfrescoWorkflowProcess alloc] initWithProperties:entry];
                            completionBlock(process, conversionError);
                        }
                    }];
                }
            }
        }];
    };
    
    // assignees
    __block AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    if (assignees)
    {
        [self retrieveNodeRefIdentifiersForPeople:assignees completionBlock:^(NSArray *personNodeRefs, NSError *error) {
            NSString *assigneesAdded = nil;
            for (NSString *assigneeNodeRef in personNodeRefs)
            {
                assigneesAdded = [NSString stringWithFormat:@"%@,%@", assigneesAdded, assigneeNodeRef];
            }
            
            if (assignees.count == 1)
            {
                [requestBody setValue:assigneesAdded forKey:kAlfrescoWorkflowLegacyJSONBPMProcessAssignee];
            }
            else
            {
                [requestBody setValue:assigneesAdded forKey:kAlfrescoWorkflowLegacyJSONBPMProcessAssignees];
            }
            
            parseAndSendCreationRequest(request);
        }];
    }
    else
    {
        [self retrieveNodeRefForUsername:self.session.personIdentifier completionBlock:^(NSString *nodeRef, NSError *error) {
            [requestBody setValue:nodeRef forKey:kAlfrescoWorkflowLegacyJSONBPMProcessAssignee];
            parseAndSendCreationRequest(request);
        }];
    }
    return request;
}

- (AlfrescoRequest *)deleteProcess:(AlfrescoWorkflowProcess *)process
                   completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:process argumentName:@"process"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *requestString = [kAlfrescoLegacyAPIWorkflowSingleInstance stringByReplacingOccurrencesOfString:kAlfrescoProcessID withString:process.identifier];
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
    NSMutableDictionary *requestBody = [[NSMutableDictionary alloc] init];
    
    [requestBody addEntriesFromDictionary:properties];
    
    if ([AlfrescoWorkflowUtils isActivitiTask:task])
    {
        requestBody[kAlfrescoWorkflowLegacyJSONBPMTransition] = kAlfrescoWorkflowLegacyJSONNext;
        requestBody[kAlfrescoWorkflowLegacyJSONBPMStatus] = kAlfrescoWorkflowLegacyJSONCompleted;
        
        if ([task.processDefinitionIdentifier isEqualToString:kAlfrescoWorkflowReviewAndApprove])
        {
            requestBody[kAlfrescoWorkflowLegacyJSONBPMReviewOutcome] = properties[kAlfrescoTaskReviewOutcome];
        }
        
        if ([[properties allKeys] containsObject:kAlfrescoTaskComment])
        {
            requestBody[kAlfrescoWorkflowLegacyJSONBPMComment] = properties[kAlfrescoTaskComment];
        }
    }
    else if ([AlfrescoWorkflowUtils isJBPMTask:task])
    {
        if ([task.processDefinitionIdentifier isEqualToString:kAlfrescoWorkflowReviewAndApprove])
        {
            requestBody[kAlfrescoWorkflowLegacyJSONBPMTransition] = properties[kAlfrescoTaskReviewOutcome];
        }
        else
        {
            requestBody[kAlfrescoWorkflowLegacyJSONBPMTransition] = @"";
        }
        
        requestBody[kAlfrescoWorkflowLegacyJSONBPMStatus] = kAlfrescoWorkflowLegacyJSONCompleted;
        
        if ([[properties allKeys] containsObject:kAlfrescoTaskComment])
        {
            requestBody[kAlfrescoWorkflowLegacyJSONBPMComment] = properties[kAlfrescoTaskComment];
        }
    }
    else
    {
        AlfrescoLogError(@"The workflow engine type can not be determined in selector - %@", NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSString *requestString = [kAlfrescoLegacyAPIWorkflowTaskFormProcessor stringByReplacingOccurrencesOfString:kAlfrescoTaskID withString:task.identifier];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    NSError *requestBodyConversionError = nil;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestBody options:0 error:&requestBodyConversionError];
    
    if (requestBodyConversionError)
    {
        AlfrescoLogDebug(@"Request could not be parsed correctly in %@", NSStringFromSelector(_cmd));
        return nil;
    }
    
    __block AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session requestBody:requestData method:kAlfrescoHTTPPOST alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            id responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&conversionError];
            if (conversionError)
            {
                completionBlock(nil, conversionError);
            }
            else
            {
                NSString *completedString = ((NSDictionary *)responseObject)[@"persistedObject"];
                NSArray *separatedStrings = [completedString componentsSeparatedByString:@","];
                NSString *createdTaskID = [[separatedStrings[0] componentsSeparatedByString:@"id="] lastObject];
                
                NSString *requestString = [kAlfrescoLegacyAPIWorkflowSingleTask stringByReplacingOccurrencesOfString:kAlfrescoTaskID withString:createdTaskID];
                
                NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
                
                [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
                    if (!data)
                    {
                        completionBlock(nil, error);
                    }
                    else
                    {
                        NSError *conversionError = nil;
                        id responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&conversionError];
                        
                        NSDictionary *entry = ((NSDictionary *) responseObject)[kAlfrescoWorkflowLegacyJSONData];
                        AlfrescoWorkflowTask *task = [[AlfrescoWorkflowTask alloc] initWithProperties:entry];
                        completionBlock(task, conversionError);
                    }
                }];
            }
        }
    }];
    return request;
}

- (AlfrescoRequest *)claimTask:(AlfrescoWorkflowTask *)task
               completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    return [self updateTaskState:task requestBody:@{kAlfrescoWorkflowLegacyJSONOwner : self.session.personIdentifier} completionBlock:completionBlock];
}

- (AlfrescoRequest *)unclaimTask:(AlfrescoWorkflowTask *)task
                 completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    return [self updateTaskState:task requestBody:@{kAlfrescoWorkflowLegacyJSONOwner : [NSNull null]} completionBlock:completionBlock];
}

- (AlfrescoRequest *)reassignTask:(AlfrescoWorkflowTask *)task
                       toAssignee:(AlfrescoPerson *)assignee
                  completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    return [self updateTaskState:task requestBody:@{kAlfrescoWorkflowLegacyJSONOwner : assignee.identifier} completionBlock:completionBlock];
}

- (AlfrescoRequest *)resolveTask:(AlfrescoWorkflowTask *)task
                 completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    NSError *notSupportedError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeWorkflowFunctionNotSupported];
    if (completionBlock != NULL)
    {
        completionBlock(nil, notSupportedError);
    }
    return nil;
}

- (AlfrescoRequest *)addAttachmentToTask:(AlfrescoWorkflowTask *)task
                              attachment:(AlfrescoNode *)node
                         completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    return [self updateAttachmentsOnTask:task attachments:@[node] addition:YES completionBlock:completionBlock];
}

- (AlfrescoRequest *)addAttachmentsToTask:(AlfrescoWorkflowTask *)task
                              attachments:(NSArray *)nodeArray
                          completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    return [self updateAttachmentsOnTask:task attachments:nodeArray addition:YES completionBlock:completionBlock];
}

- (AlfrescoRequest *)removeAttachmentFromTask:(AlfrescoWorkflowTask *)task
                                   attachment:(AlfrescoNode *)node
                              completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    return [self updateAttachmentsOnTask:task attachments:@[node] addition:NO completionBlock:completionBlock];
}

#pragma mark - Private helper methods

- (void)retrieveNodeRefIdentifiersForPeople:(NSArray *)assignees
                             completionBlock:(void (^)(NSArray *personNodeRefs, NSError *error))completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:assignees argumentName:@"assignees"];
    
    __block NSMutableArray *nodeRefIdentifiers = [NSMutableArray array];
    __block NSInteger callbacks = 0;
    
    for (AlfrescoPerson *person in assignees)
    {
        [self retrieveNodeRefForUsername:person.identifier completionBlock:^(NSString *nodeRef, NSError *error) {
            callbacks++;
            if (nodeRef)
            {
                [nodeRefIdentifiers addObject:nodeRef];
            }
            
            if (callbacks == assignees.count)
            {
                completionBlock(nodeRefIdentifiers, nil);
            }
        }];
    }
}

- (AlfrescoRequest *)retrieveNodeRefForUsername:(NSString *)username
                                completionBlock:(void (^)(NSString *nodeRef, NSError *error))completionBlock
{
    NSString *requestString = [kAlfrescoLegacyAPIPersonNodeRef stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:username];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *parseError = nil;
            id jsonResponseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            if (parseError || ![jsonResponseObject isKindOfClass:[NSDictionary class]])
            {
                completionBlock(nil, parseError);
            }
            else
            {
                NSDictionary *jsonResponseDictionary = (NSDictionary *)jsonResponseObject;
                NSArray *itemsArray = jsonResponseDictionary[kAlfrescoWorkflowLegacyJSONData][kAlfrescoJSONItems];
                NSDictionary *personDictionary = itemsArray[0];
                NSString *nodeRefIdentifier = personDictionary[kAlfrescoJSONNodeRef];
                completionBlock(nodeRefIdentifier, parseError);
            }
        }
    }];
    return request;
}

- (AlfrescoRequest *)updateTaskState:(AlfrescoWorkflowTask *)task
                         requestBody:(NSDictionary *)requestDictionary
                     completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:task argumentName:@"task"];
    [AlfrescoErrors assertArgumentNotNil:requestDictionary argumentName:@"requestDictionary"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *requestString = [kAlfrescoLegacyAPIWorkflowSingleTask stringByReplacingOccurrencesOfString:kAlfrescoTaskID withString:task.identifier];
    
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
            id responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&conversionError];
            
            NSDictionary *entry = ((NSDictionary *) responseObject)[kAlfrescoWorkflowLegacyJSONData];
            AlfrescoWorkflowTask *task = [[AlfrescoWorkflowTask alloc] initWithProperties:entry];
            completionBlock(task, conversionError);
        }
    }];
    
    return request;
}

- (void)retrieveAlfrescoNodes:(NSArray *)alfrescoNodeIdentifiers
              completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    __block NSMutableArray *alfrescoNodes = [NSMutableArray arrayWithCapacity:alfrescoNodeIdentifiers.count];
    
    if (alfrescoNodeIdentifiers.count > 0)
    {
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
    else
    {
        completionBlock(alfrescoNodes, nil);
    }
}

- (AlfrescoRequest *)updateAttachmentsOnTask:(AlfrescoWorkflowTask *)task
                                 attachments:(NSArray *)nodeArray
                                    addition:(BOOL)addition
                             completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:nodeArray argumentName:@"nodeArray"];
    [AlfrescoErrors assertArgumentNotNil:task argumentName:@"task"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *nodeReferences = @"";
    for (int i = 0; i < nodeArray.count; i++)
    {
        id nodeObject = nodeArray[i];
        if (![nodeObject isKindOfClass:[AlfrescoNode class]])
        {
            NSString *exceptionMessage = [NSString stringWithFormat:@"The node array passed into %@ should contain instances of %@, instead it contained instances of %@",
                                          NSStringFromSelector(_cmd),
                                          NSStringFromClass([AlfrescoNode class]),
                                          NSStringFromClass([nodeObject class])];
            @throw [NSException exceptionWithName:@"Invaild parameters" reason:exceptionMessage userInfo:nil];
        }
        
        AlfrescoNode *currentNode = (AlfrescoNode *)nodeObject;
        
        // remove the version number
        NSRange range = [currentNode.identifier rangeOfString:@";" options:NSBackwardsSearch];
        NSString *nodeRefWithoutVersionNumber = (!NSEqualRanges(range, NSMakeRange(NSNotFound, 0))) ? [currentNode.identifier substringToIndex:range.location] : currentNode.identifier;
        
        if (i == 0)
        {
            nodeReferences = nodeRefWithoutVersionNumber;
        }
        else
        {
            nodeReferences = [NSString stringWithFormat:@"%@,%@", nodeReferences, nodeRefWithoutVersionNumber];
        }
    }
    
    // request body
    NSString *attachmentKey = (addition) ? kAlfrescoWorkflowLegacyJSONBPMProcessAttachmentsAdd : kAlfrescoWorkflowLegacyJSONBPMProcessAttachmentsRemove;
    NSDictionary *requestBody = @{attachmentKey : nodeReferences};
    
    // build URL
    NSString *requestString = [kAlfrescoLegacyAPIWorkflowTaskFormProcessor stringByReplacingOccurrencesOfString:kAlfrescoTaskID withString:task.identifier];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    // convert
    NSError *requestConversionError = nil;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestBody options:0 error:&requestConversionError];
    
    if (requestConversionError)
    {
        AlfrescoLogDebug(@"Request could not be parsed correctly in %@", NSStringFromSelector(_cmd));
        return nil;
    }
    
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

@end
