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
#import "AlfrescoPagingUtils.h"

@interface AlfrescoPublicAPIWorkflowService ()

@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, strong, readwrite) AlfrescoDocumentFolderService *documentService;
@property (nonatomic, strong, readwrite) AlfrescoWorkflowObjectConverter *workflowObjectConverter;
@property (nonatomic, strong, readwrite) NSDateFormatter *dateFormatter;

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
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:kAlfrescoISO8601DateStringFormat];
    }
    
    return self;
}

#pragma mark - Retrieval methods
#pragma mark Process Definitions

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

#pragma mark Processes

- (AlfrescoRequest *)retrieveProcessesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:-1];
    return [self retrieveProcessesWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
        completionBlock(pagingResult.objects, error);
    }];
}

- (AlfrescoRequest *)retrieveProcessesWithListingContext:(AlfrescoListingContext *)listingContext
                                         completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    NSString *stateParameterValue = kAlfrescoPublicAPIWorkflowProcessStatusActive;
    
    if ([listingContext.listingFilter hasFilter:kAlfrescoFilterByWorkflowState])
    {
        if ([[listingContext.listingFilter valueForFilter:kAlfrescoFilterByWorkflowState] isEqualToString:kAlfrescoFilterValueWorkflowStateCompleted])
        {
            stateParameterValue = kAlfrescoPublicAPIWorkflowProcessStatusCompleted;
        }
        else if ([[listingContext.listingFilter valueForFilter:kAlfrescoFilterByWorkflowState] isEqualToString:kAlfrescoFilterValueWorkflowStateAny])
        {
            stateParameterValue = kAlfrescoPublicAPIWorkflowProcessStatusAny;
        }
    }
    
    return [self retrieveProcessesInState:stateParameterValue listingContext:listingContext completionBlock:completionBlock];
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
                AlfrescoRequest *retrieveRequest = [self retrieveVariablesForProcess:process completionBlock:completionBlock];
                request.httpRequest = retrieveRequest.httpRequest;
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
    AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:-1];
    return [self retrieveTasksForProcess:process listingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
        completionBlock(pagingResult.objects, error);
    }];
}

- (AlfrescoRequest *)retrieveTasksForProcess:(AlfrescoWorkflowProcess *)process
                              listingContext:(AlfrescoListingContext *)listingContext
                             completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:process argumentName:@"process"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *stateParameterValue = kAlfrescoPublicAPIWorkflowProcessStatusAny;
    
    if ([listingContext.listingFilter hasFilter:kAlfrescoFilterByWorkflowState])
    {
        if ([[listingContext.listingFilter valueForFilter:kAlfrescoFilterByWorkflowState] isEqualToString:kAlfrescoFilterValueWorkflowStateCompleted])
        {
            stateParameterValue = kAlfrescoPublicAPIWorkflowProcessStatusCompleted;
        }
        else if ([[listingContext.listingFilter valueForFilter:kAlfrescoFilterByWorkflowState] isEqualToString:kAlfrescoFilterValueWorkflowStateActive])
        {
            stateParameterValue = kAlfrescoPublicAPIWorkflowProcessStatusActive;
        }
    }
    
    NSString *queryString = [AlfrescoURLUtils buildQueryStringWithDictionary:@{kAlfrescoWorkflowTaskState : stateParameterValue}];
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
                completionBlock([AlfrescoPagingUtils pagedResultFromArray:tasks listingContext:listingContext], conversionError);
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

#pragma mark Tasks

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
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoPublicAPIWorkflowTasks listingContext:listingContext];
    
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
                if (attachmentIdentifiers.count > 0)
                {
                    [self retrieveAlfrescoNodes:attachmentIdentifiers completionBlock:completionBlock];
                }
                else
                {
                    completionBlock(attachmentIdentifiers, nil);
                }
            }
        }
    }];
    return request;
}

#pragma mark - Management methods
#pragma mark Processes

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
    
    // attachments
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
    
    // variables
    NSArray *allVariableKeys = [variables allKeys];
    NSMutableDictionary *completeVariables = [NSMutableDictionary dictionary];
    
    for (int i = 0; i < allVariableKeys.count; i++)
    {
        NSString *key = allVariableKeys[i];
        id valueForCurrentKey = variables[key];
        
        // remap to expected values
        id remapValue = variables[key];
        if ([valueForCurrentKey isKindOfClass:[NSDate class]])
        {
            remapValue = [self.dateFormatter stringFromDate:valueForCurrentKey];
        }
        
        // remapped keys
        completeVariables[key] = remapValue;
    }
    
    // assignees
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
                
                [self retrieveVariablesForProcess:process completionBlock:^(AlfrescoWorkflowProcess *processWithVariables, NSError *variablesError) {
                    completionBlock(processWithVariables, variablesError);
                }];
            }
        }
    }];
    return request;
}

- (AlfrescoRequest *)startProcessForProcessDefinition:(AlfrescoWorkflowProcessDefinition *)processDefinition
                                                 name:(NSString *)name
                                             priority:(NSNumber *)priority
                                              dueDate:(NSDate *)dueDate
                                sendEmailNotification:(NSNumber *)sendEmail
                                            assignees:(NSArray *)assignees
                                            variables:(NSDictionary *)variables
                                          attachments:(NSArray *)attachmentNodes
                                      completionBlock:(AlfrescoProcessCompletionBlock)completionBlock
{
    NSMutableDictionary *populatedVariables = [NSMutableDictionary dictionaryWithDictionary:(variables) ? variables : @{}];
    
    if (name)
    {
        populatedVariables[kAlfrescoWorkflowVariableProcessName] = name;
    }
    
    if (priority)
    {
        populatedVariables[kAlfrescoWorkflowVariableProcessPriority] = priority;
    }
    
    if (dueDate)
    {
        populatedVariables[kAlfrescoWorkflowVariableProcessDueDate] = dueDate;
    }
    
    if (sendEmail)
    {
        populatedVariables[kAlfrescoWorkflowVariableProcessSendEmailNotifications] = sendEmail;
    }
    
    return [self startProcessForProcessDefinition:processDefinition assignees:assignees variables:populatedVariables attachments:attachmentNodes completionBlock:completionBlock];
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

#pragma mark Tasks

- (AlfrescoRequest *)completeTask:(AlfrescoWorkflowTask *)task
                        variables:(NSDictionary *)variables
                  completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    return [self updateStateForTask:task state:kAlfrescoPublicAPIWorkflowTaskStateCompleted
                           assignee:nil variables:variables completionBlock:completionBlock];
}

- (AlfrescoRequest *)claimTask:(AlfrescoWorkflowTask *)task
               completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    return [self updateStateForTask:task state:kAlfrescoPublicAPIWorkflowTaskStateClaimed
                           assignee:nil variables:nil completionBlock:completionBlock];
}

- (AlfrescoRequest *)unclaimTask:(AlfrescoWorkflowTask *)task
                 completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    return [self updateStateForTask:task state:kAlfrescoPublicAPIWorkflowTaskStateUnclaimed
                           assignee:nil variables:nil completionBlock:completionBlock];
}

- (AlfrescoRequest *)reassignTask:(AlfrescoWorkflowTask *)task
                       toAssignee:(AlfrescoPerson *)assignee
                  completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    return [self updateStateForTask:task state:kAlfrescoPublicAPIWorkflowTaskStateClaimed
                           assignee:assignee.identifier variables:nil completionBlock:completionBlock];
}

- (AlfrescoRequest *)resolveTask:(AlfrescoWorkflowTask *)task
                 completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    return [self updateStateForTask:task state:kAlfrescoPublicAPIWorkflowTaskStateResolved
                           assignee:nil variables:nil completionBlock:completionBlock];
}

- (AlfrescoRequest *)addAttachmentToTask:(AlfrescoWorkflowTask *)task
                              attachment:(AlfrescoDocument *)document
                         completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    return [self addAttachmentsToTask:task attachments:@[document] completionBlock:completionBlock];
}

- (AlfrescoRequest *)addAttachmentsToTask:(AlfrescoWorkflowTask *)task
                              attachments:(NSArray *)documentArray
                          completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:documentArray argumentName:@"documentArray"];
    [AlfrescoErrors assertArgumentNotNil:task argumentName:@"task"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSMutableArray *requestBody = [NSMutableArray arrayWithCapacity:documentArray.count];
    for (id documentObject in documentArray)
    {
        if (![documentObject isKindOfClass:[AlfrescoDocument class]])
        {
            NSString *exceptionMessage = [NSString stringWithFormat:@"The node array passed into %@ should contain instances of %@, instead it contained instances of %@",
                                          NSStringFromSelector(_cmd),
                                          NSStringFromClass([AlfrescoDocument class]),
                                          NSStringFromClass([documentObject class])];
            @throw [NSException exceptionWithName:@"Invaild parameters" reason:exceptionMessage userInfo:nil];
        }
        
        AlfrescoDocument *currentNode = (AlfrescoDocument *)documentObject;
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
                                   attachment:(AlfrescoDocument *)document
                              completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:document argumentName:@"document"];
    [AlfrescoErrors assertArgumentNotNil:task argumentName:@"task"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *requestString = [kAlfrescoPublicAPIWorkflowTaskSingleAttachment stringByReplacingOccurrencesOfString:kAlfrescoTaskID withString:task.identifier];
    requestString = [requestString stringByReplacingOccurrencesOfString:kAlfrescoItemID withString:[AlfrescoObjectConverter nodeGUIDFromNodeIdentifier:document.identifier]];
    
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
                                  state:(NSString *)state
                               assignee:(NSString *)assignee
                                  variables:(NSDictionary *)variables
                        completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:task argumentName:@"task"];
    [AlfrescoErrors assertArgumentNotNil:state argumentName:@"state"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSMutableString *requestString = [[kAlfrescoPublicAPIWorkflowSingleTask stringByReplacingOccurrencesOfString:kAlfrescoTaskID withString:task.identifier] mutableCopy];
    
    // build the select parameters string
    NSString *requestParametersString = [[NSString alloc] initWithFormat:@"?%@=%@", kAlfrescoWorkflowTaskSelectParameter, kAlfrescoWorkflowTaskState];

    // if there is an assignee present add to select parameter
    if (assignee != nil)
    {
        requestParametersString = [requestParametersString stringByAppendingFormat:@",%@", kAlfrescoPublicAPIWorkflowTaskAssignee];
    }
    
    // if there are variables present add to select parameter
    if (variables != nil)
    {
        requestParametersString = [requestParametersString stringByAppendingFormat:@",%@", kAlfrescoWorkflowPublicJSONVariables];
    }
    
    // add parameters
    [requestString appendString:requestParametersString];
    
    // create dictionary structure for request body
    NSMutableDictionary *requestBodyDictionary = [NSMutableDictionary dictionary];
    
    // set the state
    requestBodyDictionary[kAlfrescoWorkflowTaskState] = state;
    
    // set the assignee, if there is one
    if (assignee != nil)
    {
        requestBodyDictionary[kAlfrescoWorkflowPublicJSONAssignee] = assignee;
    }
    
    // set the variables, if there are any
    if (variables != nil && variables.count > 0)
    {
        // generate dictionary for each variable
        
        // NOTE: currently we have no way of knowing whether a variable is "local" or "global", as
        // we're updating a task lets presume it's local for now, once we support variables on a
        // task we can maintain a list of local and global variables and refer to that.
        NSMutableArray *variablesArray = [NSMutableArray array];
        for (NSString *variableName in [variables allKeys])
        {
            [variablesArray addObject:@{kAlfrescoWorkflowPublicJSONName: variableName,
                                        kAlfrescoWorkflowPublicJSONVariableValue: variables[variableName],
                                        kAlfrescoWorkflowPublicJSONVariableScope: kAlfrescoWorkflowPublicJSONVariableScopeLocal}];
        }
        
        // add variables array
        requestBodyDictionary[kAlfrescoWorkflowPublicJSONVariables] = variablesArray;
    }
    
    // construct full url
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    NSError *requestBodyConversionError = nil;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestBodyDictionary options:0 error:&requestBodyConversionError];
    
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

- (AlfrescoRequest *)fallbackRetrieveProcessesInState:(NSString *)state listingContext:(AlfrescoListingContext *)listingContext completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    [AlfrescoErrors assertArgumentNotNil:listingContext argumentName:@"listingContext"];
    
    // Attempt to get all processes without variables
    NSString *whereParameterString = [NSString stringWithFormat:@"(%@=%@)", kAlfrescoPublicAPIWorkflowProcessStatus, state];
    
    NSString *queryString = [AlfrescoURLUtils buildQueryStringWithDictionary:@{kAlfrescoPublicAPIWorkflowProcessWhereParameter : whereParameterString}];
    NSString *extensionURLString = [kAlfrescoPublicAPIWorkflowProcesses stringByAppendingString:queryString];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:extensionURLString listingContext:listingContext];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session method:kAlfrescoHTTPGet alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *workflowProcesses = [self.workflowObjectConverter workflowProcessesFromPublicJSONData:data conversionError:&conversionError];
            NSDictionary *pagingInfo = [AlfrescoObjectConverter paginationJSONFromData:data error:&conversionError];
            AlfrescoPagingResult *pagingResult = nil;
            if (pagingInfo)
            {
                BOOL hasMore = [[pagingInfo valueForKeyPath:kAlfrescoWorkflowPublicJSONHasMoreItems] boolValue];
                int total = [[pagingInfo valueForKey:kAlfrescoWorkflowPublicJSONTotalItems] intValue];
                pagingResult = [[AlfrescoPagingResult alloc] initWithArray:workflowProcesses hasMoreItems:hasMore totalItems:total];
            }
            
            // Get variables for each process
            if (workflowProcesses.count > 0)
            {
                __block int callbacks = 0;
                __block NSMutableArray *processesWithVariables = [NSMutableArray arrayWithCapacity:workflowProcesses.count];
                
                for (AlfrescoWorkflowProcess *process in workflowProcesses)
                {
                    [self retrieveVariablesForProcess:process completionBlock:^(AlfrescoWorkflowProcess *processWithVariables, NSError *variablesError) {
                        callbacks++;
                        if (processWithVariables)
                        {
                            [processesWithVariables addObject:processWithVariables];
                        }
                        
                        if (callbacks == workflowProcesses.count)
                        {
                            completionBlock(pagingResult, conversionError);
                        }
                    }];
                }
            }
            else
            {
                completionBlock(pagingResult, error);
            }
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveVariablesForProcess:(AlfrescoWorkflowProcess *)process completionBlock:(AlfrescoProcessCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    [AlfrescoErrors assertArgumentNotNil:process argumentName:@"process"];
    
    NSString *urlString = [kAlfrescoPublicAPIWorkflowVariables stringByReplacingOccurrencesOfString:kAlfrescoProcessID withString:process.identifier];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:urlString];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session method:kAlfrescoHTTPGet alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSDictionary *workflowVariables = [self.workflowObjectConverter workflowVariablesFromPublicJSONData:data conversionError:&conversionError];
            
            // set the readonly property using KVO
            [process setValue:workflowVariables forKey:@"variables"];
            
            completionBlock(process, error);
        }
    }];
    return request;
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
    
    NSString *whereParameterString = [NSString stringWithFormat:@"(%@=%@ AND %@=%@)",
                                      kAlfrescoPublicAPIWorkflowProcessStatus, state,
                                      kAlfrescoPublicAPIWorkflowProcessIncludeVariables, @"true"];
    
    NSString *queryString = [AlfrescoURLUtils buildQueryStringWithDictionary:@{kAlfrescoPublicAPIWorkflowProcessWhereParameter : whereParameterString}];
    NSString *extensionURLString = [kAlfrescoPublicAPIWorkflowProcesses stringByAppendingString:queryString];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:extensionURLString listingContext:listingContext];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session requestBody:nil method:kAlfrescoHTTPGet alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            // If the request fails, there is a possibility of ALF-20731 throwing an internal HTTP 500 status code on the server.
            // As a result, we use a slower and network heavy fallback mechanism which first retrieves the processes and then the variables for each process.
            if (error.code == kAlfrescoErrorCodeHTTPResponse)
            {
                AlfrescoRequest *retrieveRequest = [self fallbackRetrieveProcessesInState:state listingContext:listingContext completionBlock:completionBlock];
                request.httpRequest = retrieveRequest.httpRequest;
            }
            else
            {
                completionBlock(nil, error);
            }
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *workflowDefinitions = [self.workflowObjectConverter workflowProcessesFromPublicJSONData:data conversionError:&conversionError];
            NSDictionary *pagingInfo = [AlfrescoObjectConverter paginationJSONFromData:data error:&conversionError];
            AlfrescoPagingResult *pagingResult = nil;
            if (pagingInfo)
            {
                /*
                 Workaround for MNT-10977 - https://issues.alfresco.com/jira/browse/MNT-10977
                 BOOL hasMore = [[pagingInfo valueForKeyPath:kAlfrescoWorkflowPublicJSONHasMoreItems] boolValue];
                 int total = [[pagingInfo valueForKey:kAlfrescoWorkflowPublicJSONTotalItems] intValue];
                 pagingResult = [[AlfrescoPagingResult alloc] initWithArray:workflowDefinitions hasMoreItems:hasMore totalItems:total];
                 */
                int skipCount = [pagingInfo[@"skipCount"] intValue];
                int count = [pagingInfo[@"count"] intValue];
                int totalItems = [pagingInfo[kAlfrescoWorkflowPublicJSONTotalItems] intValue];
                BOOL hasMore = ((skipCount + count) < totalItems);
                pagingResult = [[AlfrescoPagingResult alloc] initWithArray:workflowDefinitions hasMoreItems:hasMore totalItems:totalItems];
            }
            completionBlock(pagingResult, conversionError);
        }
    }];
    
    return request;
}

@end
