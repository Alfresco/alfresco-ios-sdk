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
@property (nonatomic, strong, readwrite) NSDateFormatter *isoDateFormatter;
@property (nonatomic, strong, readwrite) NSDateFormatter *dueDateFormatter;

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
        self.isoDateFormatter = [[NSDateFormatter alloc] init];
        self.isoDateFormatter.dateFormat = kAlfrescoISO8601DateStringFormat;
        self.dueDateFormatter = [[NSDateFormatter alloc] init];
        self.dueDateFormatter.dateFormat = @"yyyy-MM-dd";
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
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    if (!listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    return [self internalRetrieveProcessesWithListingContext:listingContext completionBlock:completionBlock];
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
                AlfrescoRequest *retrieveRequest = [self retrieveVariablesForProcess:process completionBlock:^(NSDictionary *variables, NSError *error) {
                    if (variables)
                    {
                        // using KVO pass the variables to the process object
                        [process setValue:variables forKey:@"variables"];
                        completionBlock(process, nil);
                    }
                    else
                    {
                        completionBlock(nil, error);
                    }
                }];
                request.httpRequest = retrieveRequest.httpRequest;
            }
        }
    }];
    
    return request;
}

- (AlfrescoRequest *)retrieveVariablesForProcess:(AlfrescoWorkflowProcess *)process
                                 completionBlock:(AlfrescoDictionaryCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:process argumentName:@"process"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
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
            NSDictionary *workflowVariables = [self.workflowObjectConverter variablesFromPublicJSONData:data conversionError:&conversionError];
            completionBlock(workflowVariables, conversionError);
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
    
    NSString *statusParameterValue = kAlfrescoPublicAPIWorkflowStatusAny;
    
    if ([listingContext.listingFilter hasFilter:kAlfrescoFilterByWorkflowStatus])
    {
        if ([[listingContext.listingFilter valueForFilter:kAlfrescoFilterByWorkflowStatus] isEqualToString:kAlfrescoFilterValueWorkflowStatusCompleted])
        {
            statusParameterValue = kAlfrescoPublicAPIWorkflowStatusCompleted;
        }
        else if ([[listingContext.listingFilter valueForFilter:kAlfrescoFilterByWorkflowStatus] isEqualToString:kAlfrescoFilterValueWorkflowStatusActive])
        {
            statusParameterValue = kAlfrescoPublicAPIWorkflowStatusActive;
        }
    }
    
    NSString *queryString = [AlfrescoURLUtils buildQueryStringWithDictionary:@{kAlfrescoPublicAPIWorkflowStatus : statusParameterValue}];
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

    AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:-1];
    return [self retrieveTasksWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
        completionBlock(pagingResult.objects, error);
    }];
}

- (AlfrescoRequest *)retrieveTasksWithListingContext:(AlfrescoListingContext *)listingContext
                                     completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    if (!listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    // API endpoint
    NSString *extensionURLString = kAlfrescoPublicAPIWorkflowTasks;

    // Construct the where clause from the listing context
    NSString *whereClause = [self constructWhereClauseFromListingFilter:listingContext.listingFilter isProcess:NO includeVariables:NO];
    if (whereClause)
    {
        NSString *queryString = [AlfrescoURLUtils buildQueryStringWithDictionary:@{kAlfrescoPublicAPIWorkflowWhere : whereClause}];
        extensionURLString = [extensionURLString stringByAppendingString:queryString];
    }
    
    // Construct the URL
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:extensionURLString listingContext:listingContext];
    
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

- (AlfrescoRequest *)retrieveVariablesForTask:(AlfrescoWorkflowTask *)task
                              completionBlock:(AlfrescoDictionaryCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:task argumentName:@"task"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    
    NSString *urlString = [kAlfrescoPublicAPIWorkflowTaskVariables stringByReplacingOccurrencesOfString:kAlfrescoTaskID withString:task.identifier];
    
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
            NSDictionary *workflowVariables = [self.workflowObjectConverter variablesFromPublicJSONData:data conversionError:&conversionError];
            completionBlock(workflowVariables, conversionError);
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
            remapValue = [self.isoDateFormatter stringFromDate:valueForCurrentKey];
        }
        
        // encode the variable name
        key = [AlfrescoWorkflowObjectConverter encodeVariableName:key];
        
        // store variable
        completeVariables[key] = remapValue;
    }
    
    // assignees
    if (!assignees)
    {
        completeVariables[kAlfrescoWorkflowPublicBPMJSONProcessAssignee] = self.session.personIdentifier;
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
            completeVariables[kAlfrescoWorkflowPublicBPMJSONProcessAssignee] = assigneeIdentifiers.firstObject;
        }
        else
        {
            completeVariables[kAlfrescoWorkflowPublicBPMJSONProcessAssignees] = assigneeIdentifiers;
        }
    }
    
    // add the variables dictionary to the request
    if (completeVariables.count > 0)
    {
        requestBody[kAlfrescoWorkflowPublicJSONVariables] = completeVariables;
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
    [self.session.networkProvider executeRequestWithURL:url session:self.session requestBody:requestData method:kAlfrescoHTTPPost alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
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
                AlfrescoRequest *retrieveRequest = [self retrieveVariablesForProcess:process completionBlock:^(NSDictionary *variables, NSError *error) {
                    if (variables)
                    {
                        // using KVO pass the variables to the process object
                        [process setValue:variables forKey:@"variables"];
                        completionBlock(process, nil);
                    }
                    else
                    {
                        completionBlock(nil, error);
                    }
                }];
                request.httpRequest = retrieveRequest.httpRequest;
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

- (AlfrescoRequest *)updateVariablesForProcess:(AlfrescoWorkflowProcess *)process
                                     variables:(NSDictionary *)variables
                               completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:process argumentName:@"process"];
    [AlfrescoErrors assertArgumentNotNil:variables argumentName:@"variables"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    // create array structure for request body
    NSArray *requestBodyArray = [self variableJSONArrayForDictionary:variables scope:nil];
    
    // create request body data
    NSError *requestBodyConversionError = nil;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestBodyArray options:0 error:&requestBodyConversionError];
    
    if (requestBodyConversionError)
    {
        completionBlock(NO, [AlfrescoErrors alfrescoErrorWithUnderlyingError:requestBodyConversionError
                                                        andAlfrescoErrorCode:kAlfrescoErrorCodeWorkflow]);
        return nil;
    }
    else
    {
        // build URL
        NSString *urlString = [kAlfrescoPublicAPIWorkflowVariables stringByReplacingOccurrencesOfString:kAlfrescoProcessID
                                                                                             withString:process.identifier];
        
        NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:urlString];
        
        // execute request
        AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
        [self.session.networkProvider executeRequestWithURL:url session:self.session
                                                requestBody:requestData method:kAlfrescoHTTPPost
                                            alfrescoRequest:request
                                            completionBlock:^(NSData *data, NSError *error) {
            // call the provided completion block
            completionBlock(data != nil, error);
        }];

        return request;
    }
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

- (AlfrescoRequest *)updateVariablesForTask:(AlfrescoWorkflowTask *)task
                                  variables:(NSDictionary *)variables
                            completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:task argumentName:@"task"];
    [AlfrescoErrors assertArgumentNotNil:variables argumentName:@"variables"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    // create array structure for request body
    NSArray *requestBodyArray = [self variableJSONArrayForDictionary:variables
                                                               scope:kAlfrescoWorkflowPublicJSONVariableScopeLocal];
    
    // create request body data
    NSError *requestBodyConversionError = nil;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestBodyArray options:0 error:&requestBodyConversionError];
    
    if (requestBodyConversionError)
    {
        completionBlock(NO, [AlfrescoErrors alfrescoErrorWithUnderlyingError:requestBodyConversionError
                                                        andAlfrescoErrorCode:kAlfrescoErrorCodeWorkflow]);
        return nil;
    }
    else
    {
        // build URL
        NSString *urlString = [kAlfrescoPublicAPIWorkflowTaskVariables stringByReplacingOccurrencesOfString:kAlfrescoTaskID
                                                                                                 withString:task.identifier];
        
        NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:urlString];
        
        // execute request
        AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
        [self.session.networkProvider executeRequestWithURL:url session:self.session
                                                requestBody:requestData method:kAlfrescoHTTPPost
                                            alfrescoRequest:request
                                            completionBlock:^(NSData *data, NSError *error) {
                                                // call the provided completion block
                                                completionBlock(data != nil, error);
                                            }];
        
        return request;
    }
}

- (AlfrescoRequest *)completeTask:(AlfrescoWorkflowTask *)task
                        variables:(NSDictionary *)variables
                  completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{kAlfrescoPublicAPIWorkflowTaskState: kAlfrescoPublicAPIWorkflowTaskStateCompleted}];
    if (variables)
    {
        parameters[kAlfrescoWorkflowPublicJSONVariables] = variables;
    }
    
    return [self transitionTask:task parameters:parameters completionBlock:completionBlock];
}

- (AlfrescoRequest *)claimTask:(AlfrescoWorkflowTask *)task
               completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    return [self transitionTask:task
                     parameters:@{kAlfrescoPublicAPIWorkflowTaskState: kAlfrescoPublicAPIWorkflowTaskStateClaimed}
                completionBlock:completionBlock];
}

- (AlfrescoRequest *)unclaimTask:(AlfrescoWorkflowTask *)task
                 completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    return [self transitionTask:task
                     parameters:@{kAlfrescoPublicAPIWorkflowTaskState: kAlfrescoPublicAPIWorkflowTaskStateUnclaimed}
                completionBlock:completionBlock];
}

- (AlfrescoRequest *)reassignTask:(AlfrescoWorkflowTask *)task
                       toAssignee:(AlfrescoPerson *)assignee
                  completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    return [self transitionTask:task
                     parameters:@{kAlfrescoWorkflowPublicJSONAssignee: assignee.identifier}
                completionBlock:completionBlock];
}

- (AlfrescoRequest *)resolveTask:(AlfrescoWorkflowTask *)task
                 completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    return [self transitionTask:task
                     parameters:@{kAlfrescoPublicAPIWorkflowTaskState: kAlfrescoPublicAPIWorkflowTaskStateResolved}
                completionBlock:completionBlock];
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
    [self.session.networkProvider executeRequestWithURL:url session:self.session requestBody:requestData method:kAlfrescoHTTPPost alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(NO, error);
        }
        else
        {
            completionBlock(YES, nil);
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
            completionBlock(NO, error);
        }
        else
        {
            completionBlock(YES, nil);
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

- (AlfrescoRequest *)transitionTask:(AlfrescoWorkflowTask *)task
                         parameters:(NSDictionary *)parameters
                    completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:task argumentName:@"task"];
    [AlfrescoErrors assertArgumentNotNil:parameters argumentName:@"parameters"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSMutableString *requestString = [[kAlfrescoPublicAPIWorkflowSingleTask stringByReplacingOccurrencesOfString:kAlfrescoTaskID withString:task.identifier] mutableCopy];
    
    // create dictionary structure for request body
    NSMutableDictionary *requestBodyDictionary = [NSMutableDictionary dictionary];
    
    for (NSString *key in parameters)
    {
        id parameter = parameters[key];

        // Special handling for variables
        if ([key isEqualToString:kAlfrescoWorkflowPublicJSONVariables])
        {
            // Generate an array of dictionary objects
            NSArray *variablesArray = [self variableJSONArrayForDictionary:parameter
                                                                     scope:kAlfrescoWorkflowPublicJSONVariableScopeLocal];
            
            // Add variables array
            requestBodyDictionary[kAlfrescoWorkflowPublicJSONVariables] = variablesArray;
        }
        else if ([key isEqualToString:kAlfrescoWorkflowPublicJSONDueAt] && [parameter isKindOfClass:[NSDate class]])
        {
            requestBodyDictionary[key] = [self.isoDateFormatter stringFromDate:parameter];
        }
        else
        {
            // Treat everything else as-is.
            requestBodyDictionary[key] = parameter;
        }
    }
    
    // Build the parameters string
    NSString *queryString = [NSString stringWithFormat:@"?%@=%@", kAlfrescoPublicAPIWorkflowTaskSelectParameter, [[parameters allKeys] componentsJoinedByString:@","]];
    
    // Construct full url
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:[requestString stringByAppendingString:queryString]];
    
    NSError *requestBodyConversionError = nil;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestBodyDictionary options:0 error:&requestBodyConversionError];
    
    if (requestBodyConversionError)
    {
        completionBlock(nil, [AlfrescoErrors alfrescoErrorWithUnderlyingError:requestBodyConversionError
                                                        andAlfrescoErrorCode:kAlfrescoErrorCodeWorkflow]);
        return nil;
    }
    else
    {
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
}

- (AlfrescoRequest *)fallbackRetrieveProcessesWithListingContext:(AlfrescoListingContext *)listingContext
                                                 completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    [AlfrescoErrors assertArgumentNotNil:listingContext argumentName:@"listingContext"];
    
    // API endpoint
    NSString *extensionURLString = kAlfrescoPublicAPIWorkflowProcesses;

    // Construct the where clause from the listing context (without variables)
    NSString *whereClause = [self constructWhereClauseFromListingFilter:listingContext.listingFilter isProcess:YES includeVariables:NO];
    if (whereClause)
    {
        NSString *queryString = [AlfrescoURLUtils buildQueryStringWithDictionary:@{kAlfrescoPublicAPIWorkflowWhere : whereClause}];
        extensionURLString = [extensionURLString stringByAppendingString:queryString];
    }
    
    // Construct the url
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
                    [self retrieveVariablesForProcess:process completionBlock:^(NSDictionary *variables, NSError *error) {
                        callbacks++;
                        if (variables)
                        {
                            // using KVO pass the variables to the process object
                            [process setValue:variables forKey:@"variables"];
                            [processesWithVariables addObject:process];
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

- (NSArray *)variableJSONArrayForDictionary:(NSDictionary *)variables scope:(NSString *)scope;
{
    // build an array of dictionaries representing the provided variables
    NSMutableArray *jsonArray = [NSMutableArray array];
    
    for (NSString *variableName in [variables allKeys])
    {
        id variableValue = variables[variableName];
        
        // if the variable is a date, change to a string
        if ([variableValue isKindOfClass:[NSDate class]])
        {
            variableValue = [self.isoDateFormatter stringFromDate:variableValue];
        }
        
        // encode the variable name
        NSString *processedVariableName = [AlfrescoWorkflowObjectConverter encodeVariableName:variableName];
        
        NSMutableDictionary *variableDictionary = [NSMutableDictionary dictionary];
        variableDictionary[kAlfrescoWorkflowPublicJSONName] = processedVariableName;
        variableDictionary[kAlfrescoWorkflowPublicJSONVariableValue] = variableValue;
        
        if (scope)
        {
            variableDictionary[kAlfrescoWorkflowPublicJSONVariableScope] = scope;
        }
        
        // add to json array
        [jsonArray addObject:variableDictionary];
    }
    
    return jsonArray;
}

- (AlfrescoRequest *)internalRetrieveProcessesWithListingContext:(AlfrescoListingContext *)listingContext completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:listingContext argumentName:@"listingContext"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    // API endpoint
    NSString *extensionURLString = kAlfrescoPublicAPIWorkflowProcesses;
    
    // Construct the where clause from the listing context
    NSString *whereClause = [self constructWhereClauseFromListingFilter:listingContext.listingFilter isProcess:YES includeVariables:YES];
    if (whereClause)
    {
        NSString *queryString = [AlfrescoURLUtils buildQueryStringWithDictionary:@{kAlfrescoPublicAPIWorkflowWhere : whereClause}];
        extensionURLString = [extensionURLString stringByAppendingString:queryString];
    }

    // Construct URL
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:extensionURLString listingContext:listingContext];
    
    // retrieve processes
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session requestBody:nil method:kAlfrescoHTTPGet alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            // If the request fails, there is a possibility of ALF-20731 throwing an internal HTTP 500 status code on the server.
            // As a result, we use a slower and network heavy fallback mechanism which first retrieves the processes and then the variables for each process.
            if (error.code == kAlfrescoErrorCodeHTTPResponse)
            {
                AlfrescoRequest *retrieveRequest = [self fallbackRetrieveProcessesWithListingContext:listingContext completionBlock:completionBlock];
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

- (NSString *)constructWhereClauseFromListingFilter:(AlfrescoListingFilter *)filter
                                          isProcess:(BOOL)isProcess
                                   includeVariables:(BOOL)includeVariables
{
    NSMutableString *mutableString = [NSMutableString string];
    
    /**
     * Assignee
     */
    
    /**
     * The workflow public API for tasks is returning other users tasks (MNT-11264), additionally the workflow API does not
     * support the -me- identifer (ACE-1445) so we use person identifier stored in the session data.
     */
    NSString *currentUserIdentifier = [self.session objectForParameter:kAlfrescoSessionAlternatePersonIdentifier] ?: self.session.personIdentifier;
    
    if (isProcess)
    {
        if ([filter hasFilter:kAlfrescoFilterByWorkflowInitiator])
        {
            NSString *initiatorValue = [filter valueForFilter:kAlfrescoFilterByWorkflowInitiator];
            
            if ([initiatorValue isEqualToString:kAlfrescoFilterValueWorkflowInitiatorMe])
            {
                initiatorValue = currentUserIdentifier;
            }

            [self appendStringPredicateToWhereClause:mutableString name:kAlfrescoPublicAPIWorkflowProcessStartUserID value:initiatorValue operator:@"="];
        }
        else
        {
            [self appendStringPredicateToWhereClause:mutableString name:kAlfrescoPublicAPIWorkflowProcessStartUserID value:currentUserIdentifier operator:@"="];
        }
    }
    else
    {
        if ([filter hasFilter:kAlfrescoFilterByWorkflowAssignee])
        {
            NSString *assigneeValue = [filter valueForFilter:kAlfrescoFilterByWorkflowAssignee];
            NSString *predicateName = kAlfrescoPublicAPIWorkflowTaskAssignee;
            
            if ([assigneeValue isEqualToString:kAlfrescoFilterValueWorkflowAssigneeMe])
            {
                assigneeValue = currentUserIdentifier;
            }
            else if ([assigneeValue isEqualToString:kAlfrescoFilterValueWorkflowAssigneeAll])
            {
                assigneeValue = nil;
            }
            else if ([assigneeValue isEqualToString:kAlfrescoFilterValueWorkflowAssigneeUnassigned])
            {
                assigneeValue = currentUserIdentifier;
                predicateName = kAlfrescoPublicAPIWorkflowTaskCandidateUser;
            }
            
            if (assigneeValue)
            {
                [self appendStringPredicateToWhereClause:mutableString name:predicateName value:assigneeValue operator:@"="];
            }
        }
        else
        {
            [self appendStringPredicateToWhereClause:mutableString name:kAlfrescoWorkflowPublicJSONAssignee value:currentUserIdentifier operator:@"="];
        }
    }

    /**
     * Priority
     */
    
    if ([filter hasFilter:kAlfrescoFilterByWorkflowPriority])
    {
        int priority = 1;

        if ([[filter valueForFilter:kAlfrescoFilterByWorkflowPriority] isEqualToString:kAlfrescoFilterValueWorkflowPriorityMedium])
        {
            priority = 2;
        }
        else if ([[filter valueForFilter:kAlfrescoFilterByWorkflowPriority] isEqualToString:kAlfrescoFilterValueWorkflowPriorityLow])
        {
            priority = 3;
        }
        
        [self appendNumberPredicateToWhereClause:mutableString name:kAlfrescoPublicAPIWorkflowPriority value:[NSNumber numberWithInt:priority] operator:@"="];
    }


    /**
     * Status
     */
    
    if ([filter hasFilter:kAlfrescoFilterByWorkflowStatus])
    {
        NSString *statusValue = [filter valueForFilter:kAlfrescoFilterByWorkflowStatus];
        
        if ([statusValue isEqualToString:kAlfrescoFilterValueWorkflowStatusAny])
        {
            [self appendEnumPredicateToWhereClause:mutableString name:kAlfrescoPublicAPIWorkflowStatus value:kAlfrescoPublicAPIWorkflowStatusAny operator:@"="];
        }
        else if ([statusValue isEqualToString:kAlfrescoFilterValueWorkflowStatusCompleted])
        {
            [self appendEnumPredicateToWhereClause:mutableString name:kAlfrescoPublicAPIWorkflowStatus value:kAlfrescoPublicAPIWorkflowStatusCompleted operator:@"="];
        }
    }
    else
    {
        [self appendEnumPredicateToWhereClause:mutableString name:kAlfrescoPublicAPIWorkflowStatus value:kAlfrescoPublicAPIWorkflowStatusActive operator:@"="];
    }
    
    
    /**
     * Due Date
     */
    
    if ([filter hasFilter:kAlfrescoFilterByWorkflowDueDate])
    {
        NSDate *now = [NSDate date];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSString *dueDateValue = [filter valueForFilter:kAlfrescoFilterByWorkflowDueDate];
            
        if ([dueDateValue isEqualToString:kAlfrescoFilterValueWorkflowDueDateToday])
        {
            NSDateComponents *components = [NSDateComponents new];
            components.day = -1;
            NSDate *yesterday = [gregorian dateByAddingComponents:components toDate:now options:0];
            [self appendStringPredicateToWhereClause:mutableString name:kAlfrescoPublicAPIWorkflowDueAt value:[self.dueDateFormatter stringFromDate:yesterday] operator:@">"];
            
            components.day = 1;
            NSDate *tomorrow = [gregorian dateByAddingComponents:components toDate:now options:0];
            [self appendStringPredicateToWhereClause:mutableString name:kAlfrescoPublicAPIWorkflowDueAt value:[self.dueDateFormatter stringFromDate:tomorrow] operator:@"<"];
        }
        else if ([dueDateValue isEqualToString:kAlfrescoFilterValueWorkflowDueDateTomorrow])
        {
            [self appendStringPredicateToWhereClause:mutableString name:kAlfrescoPublicAPIWorkflowDueAt value:[self.dueDateFormatter stringFromDate:now] operator:@">"];
            
            NSDateComponents *components = [NSDateComponents new];
            components.day = 2;
            NSDate *dayAfterTomorrow = [gregorian dateByAddingComponents:components toDate:now options:0];
            [self appendStringPredicateToWhereClause:mutableString name:kAlfrescoPublicAPIWorkflowDueAt value:[self.dueDateFormatter stringFromDate:dayAfterTomorrow] operator:@"<"];
        }
        else if ([dueDateValue isEqualToString:kAlfrescoFilterValueWorkflowDueDate7Days])
        {
            NSDateComponents *components = [NSDateComponents new];
            components.day = 7;
            NSDate *oneWeek = [gregorian dateByAddingComponents:components toDate:now options:0];
            
            [self appendStringPredicateToWhereClause:mutableString name:kAlfrescoPublicAPIWorkflowDueAt value:[self.dueDateFormatter stringFromDate:oneWeek] operator:@"<"];
        }
        else if ([dueDateValue isEqualToString:kAlfrescoFilterValueWorkflowDueDateOverdue])
        {
            [self appendStringPredicateToWhereClause:mutableString name:kAlfrescoPublicAPIWorkflowDueAt value:[self.dueDateFormatter stringFromDate:now] operator:@"<"];
        }
    }

    
    /**
     * Include Variables
     */
    if (includeVariables)
    {
        [self appendBooleanPredicateToWhereClause:mutableString name:kAlfrescoPublicAPIWorkflowProcessIncludeVariables value:YES operator:@"="];
    }
    

    NSString *whereClause = nil;
    
    if (mutableString.length > 0)
    {
        whereClause = [NSString stringWithFormat:@"(%@)", mutableString];
    }
    
    return whereClause;
}

- (void)appendStringPredicateToWhereClause:(NSMutableString *)whereClause name:(NSString *)name value:(NSString *)value operator:(NSString *)operator
{
    return [self appendPredicateToWhereClause:whereClause
                                         name:name
                                        value:[NSString stringWithFormat:@"'%@'", value]
                                     operator:operator];
}

- (void)appendNumberPredicateToWhereClause:(NSMutableString *)whereClause name:(NSString *)name value:(NSNumber *)value operator:(NSString *)operator
{
    return [self appendPredicateToWhereClause:whereClause
                                         name:name
                                        value:[value stringValue]
                                     operator:operator];
}

- (void)appendBooleanPredicateToWhereClause:(NSMutableString *)whereClause name:(NSString *)name value:(BOOL)value operator:(NSString *)operator
{
    return [self appendPredicateToWhereClause:whereClause
                                         name:name
                                        value:(value) ? @"true" : @"false"
                                     operator:operator];
}

- (void)appendEnumPredicateToWhereClause:(NSMutableString *)whereClause name:(NSString *)name value:(NSString *)value operator:(NSString *)operator
{
    return [self appendPredicateToWhereClause:whereClause
                                         name:name
                                        value:value
                                     operator:operator];
}

- (void)appendPredicateToWhereClause:(NSMutableString *)whereClause name:(NSString *)name value:(NSString *)value operator:(NSString *)operator
{
    // only proceed if all parameters are provided
    if (whereClause && operator && name && value)
    {
        if (whereClause.length > 1)
        {
            [whereClause appendString:@" AND "];
        }
        
        [whereClause appendFormat:@"%@%@%@", name, operator, [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    }
}

@end
