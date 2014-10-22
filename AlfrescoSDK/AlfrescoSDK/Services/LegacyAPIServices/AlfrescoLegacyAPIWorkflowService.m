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
#import "AlfrescoConstants.h"

@interface AlfrescoLegacyAPIWorkflowService ()

@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, strong, readwrite) AlfrescoDocumentFolderService *documentService;
@property (nonatomic, strong, readwrite) AlfrescoWorkflowObjectConverter *workflowObjectConverter;
@property (nonatomic, strong, readwrite) NSDateFormatter *dateFormatter;

@end

@implementation AlfrescoLegacyAPIWorkflowService

- (id)initWithSession:(id<AlfrescoSession>)session
{
    self = [super init];
    if (self)
    {
        self.session = session;
        self.baseApiUrl = [[self.session.baseUrl absoluteString] stringByAppendingString:kAlfrescoLegacyAPIPath];
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
    
    if ([self.session.repositoryInfo.majorVersion intValue] <= 3)
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
    
    NSString *requestString = [kAlfrescoLegacyAPIWorkflowInstances stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
    
    // for now map the new filter listing to the existing state constants (now internal) but these should be removed soon
    if ([listingContext.listingFilter hasFilter:kAlfrescoFilterByWorkflowStatus])
    {
        NSString *requestedState = [listingContext.listingFilter valueForFilter:kAlfrescoFilterByWorkflowStatus];
        
        if (![requestedState isEqualToString:kAlfrescoFilterValueWorkflowStatusAny])
        {
            NSString *stateParameterValue = kAlfrescoLegacyAPIWorkflowStatusInProgress;
            
            if ([requestedState isEqualToString:kAlfrescoFilterValueWorkflowStatusCompleted])
            {
                stateParameterValue = kAlfrescoLegacyAPIWorkflowStatusCompleted;
            }
        
            requestString = [requestString stringByAppendingFormat:@"&%@=%@", kAlfrescoLegacyAPIWorkflowProcessState, stateParameterValue];
        }
    }
    
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

- (AlfrescoRequest *)retrieveVariablesForProcess:(AlfrescoWorkflowProcess *)process
                                 completionBlock:(AlfrescoDictionaryCompletionBlock)completionBlock
{
    NSError *notSupportedError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeWorkflowFunctionNotSupported];
    completionBlock(nil, notSupportedError);
    return nil;
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
    AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:-1];
    return [self retrieveTasksForProcess:process listingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
        completionBlock(pagingResult.objects, error);
    }];
}

- (AlfrescoRequest *)retrieveTasksForProcess:(AlfrescoWorkflowProcess *)process
                              listingContext:(AlfrescoListingContext *)listingContext
                             completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    [AlfrescoErrors assertArgumentNotNil:process argumentName:@"process"];
    
    if (!listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    NSString *stateParameterValue = kAlfrescoLegacyAPIWorkflowStatusInProgress;
    
    if ([listingContext.listingFilter hasFilter:kAlfrescoFilterByWorkflowStatus])
    {
        NSString *requestedState = [listingContext.listingFilter valueForFilter:kAlfrescoFilterByWorkflowStatus];
        
        if ([requestedState isEqualToString:kAlfrescoFilterValueWorkflowStatusCompleted])
        {
            stateParameterValue = kAlfrescoLegacyAPIWorkflowStatusCompleted;
        }
    }
    
    NSString *requestString = [kAlfrescoLegacyAPIWorkflowTasksForInstance stringByReplacingOccurrencesOfString:kAlfrescoProcessID withString:process.identifier];
    
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
            NSArray *tasks = [self.workflowObjectConverter workflowTasksFromLegacyJSONData:data inState:stateParameterValue conversionError:&conversionError];
            completionBlock([AlfrescoPagingUtils pagedResultFromArray:tasks listingContext:listingContext], conversionError);
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveAttachmentsForProcess:(AlfrescoWorkflowProcess *)process
                                   completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    [AlfrescoErrors assertArgumentNotNil:process argumentName:@"process"];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    request = [self retrieveTasksForProcess:process completionBlock:^(NSArray *array, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            AlfrescoWorkflowTask *firstTask = array[0];
            AlfrescoRequest *retrieveRequest = [self retrieveAttachmentsForTask:firstTask completionBlock:completionBlock];
            request.httpRequest = retrieveRequest.httpRequest;
        }
    }];
    return request;
}

#pragma mark Tasks

- (AlfrescoRequest *)retrieveTasksWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *requestString = [kAlfrescoLegacyAPIWorkflowTasks stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
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

    NSString *requestString = [kAlfrescoLegacyAPIWorkflowTasks stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
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

- (AlfrescoRequest *)retrieveVariablesForTask:(AlfrescoWorkflowTask *)task
                              completionBlock:(AlfrescoDictionaryCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:task argumentName:@"task"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *requestString = [kAlfrescoLegacyAPIWorkflowSingleTask stringByReplacingOccurrencesOfString:kAlfrescoTaskID withString:task.identifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (!data)
        {
            completionBlock(nil, error);
        }
        else
        {
            // NOTE: we should really lookup the type definition of the task to properly type all the variables
            
            NSError *conversionError = nil;
            NSDictionary *variables = [self.workflowObjectConverter taskVariablesFromLegacyJSONData:data conversionError:&conversionError];
            completionBlock(variables, conversionError);
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
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session requestBody:containerRequestData method:kAlfrescoHTTPPost alfrescoRequest:request completionBlock:^(NSData *data, NSError *attachmentRefError) {
        if (!data)
        {
            completionBlock(nil, attachmentRefError);
        }
        else
        {
            NSError *nodeIdentifierError = nil;
            NSArray *nodeIdentifiers = [self.workflowObjectConverter attachmentIdentifiersFromLegacyJSONData:data conversionError:&nodeIdentifierError];
            
            if (nodeIdentifierError)
            {
                completionBlock(nil, nodeIdentifierError);
            }
            else
            {
                if (nodeIdentifiers.count > 0)
                {
                    [self retrieveAlfrescoNodes:nodeIdentifiers completionBlock:completionBlock];
                }
                else
                {
                    completionBlock(nodeIdentifiers, nil);
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
    
    // variables
    NSArray *allVariableKeys = [variables allKeys];
    for (int i = 0; i < allVariableKeys.count; i++)
    {
        NSString *key = allVariableKeys[i];
        id valueForCurrentKey = variables[key];
        
        // remap to expected values
        id remapValue = variables[key];
        if ([valueForCurrentKey isKindOfClass:[NSNumber class]])
        {
            if (strcmp([valueForCurrentKey objCType], @encode(BOOL)) == 0)
            {
                remapValue = ([valueForCurrentKey boolValue]) ? @"true" : @"false";
            }
            else
            {
                remapValue = [NSString stringWithFormat:@"%@", valueForCurrentKey];
            }
        }
        else if ([valueForCurrentKey isKindOfClass:[NSDate class]])
        {
            NSString *formattedDateString = [self.dateFormatter stringFromDate:valueForCurrentKey];
            
            // GMT gets a "Z" suffix instead of a time offset
            if (![formattedDateString hasSuffix:@"Z"])
            {
                // hack to get timezone as +02:00 instead of +0200
                formattedDateString = [NSString stringWithFormat:@"%@:%@", [formattedDateString substringToIndex:formattedDateString.length -2], [formattedDateString substringFromIndex:formattedDateString.length - 2]];
            }
            
            remapValue = formattedDateString;
        }
        
        // process the keys (apply appropriate prefix for form processor i.e. prop_ or assoc_ and change : to _)
        NSString *processedKey = [self processVariableKey:key];
        requestBody[processedKey] = remapValue;
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
        NSString *cleanNodeRef = [AlfrescoObjectConverter nodeRefWithoutVersionID:currentNode.identifier];
        if (i == 0)
        {
            documentsAdded = cleanNodeRef;
        }
        else
        {
            documentsAdded = [NSString stringWithFormat:@"%@,%@", documentsAdded, cleanNodeRef];
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
        
        [self.session.networkProvider executeRequestWithURL:url session:self.session requestBody:requestData method:kAlfrescoHTTPPost alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
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
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    if (assignees)
    {
        [self retrieveNodeRefIdentifiersForPeople:assignees completionBlock:^(NSArray *personNodeRefs, NSError *error) {
            NSString *assigneesAdded = [personNodeRefs componentsJoinedByString:@","];

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

- (AlfrescoRequest *)updateVariablesForProcess:(AlfrescoWorkflowProcess *)process
                                     variables:(NSDictionary *)variables
                               completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    NSError *notSupportedError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeWorkflowFunctionNotSupported];
    completionBlock(NO, notSupportedError);
    return nil;
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

#pragma mark Tasks

- (AlfrescoRequest *)updateVariablesForTask:(AlfrescoWorkflowTask *)task
                                  variables:(NSDictionary *)variables
                            completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    // encode the provided variables before updating
    NSMutableDictionary *processedVariables = [NSMutableDictionary dictionary];
    for (NSString *key in [variables allKeys])
    {
        NSString *variableName = [AlfrescoWorkflowObjectConverter encodeVariableName:key];
        processedVariables[variableName] = variables[key];
    }
    
    // update the task
    return [self updateTask:task requestBody:processedVariables completionBlock:^(AlfrescoWorkflowTask *task, NSError *error) {
        completionBlock(task != nil, error);
    }];
}

- (AlfrescoRequest *)completeTask:(AlfrescoWorkflowTask *)task
                        variables:(NSDictionary *)variables
                  completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    NSMutableDictionary *requestBody = [[NSMutableDictionary alloc] init];
    
    // process the variable names
    for (NSString *key in [variables allKeys])
    {
        NSString *processedKey = [self processVariableKey:key];
        requestBody[processedKey] = variables[key];
    }

    // make sure a transition is present
    if (requestBody[kAlfrescoWorkflowVariableTaskTransition] == nil)
    {
        if ([AlfrescoWorkflowUtils isActivitiTask:task])
        {
            // always set the transition to "next" for activiti tasks
            requestBody[kAlfrescoWorkflowLegacyJSONTransitions] = kAlfrescoWorkflowLegacyJSONNext;
        }
        else if ([AlfrescoWorkflowUtils isJBPMTask:task])
        {
            // if jbpm task and there is no transition set, set it to ""
            requestBody[kAlfrescoWorkflowLegacyJSONTransitions] = @"";
        }
    }
    
    // always set the bpm_status flag to completed
    requestBody[kAlfrescoWorkflowLegacyJSONBPMStatus] = kAlfrescoWorkflowLegacyJSONCompleted;
    
    NSString *requestString = [kAlfrescoLegacyAPIWorkflowTaskFormProcessor stringByReplacingOccurrencesOfString:kAlfrescoTaskID withString:task.identifier];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    NSError *requestBodyConversionError = nil;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestBody options:0 error:&requestBodyConversionError];
    
    if (requestBodyConversionError)
    {
        AlfrescoLogDebug(@"Request could not be parsed correctly in %@", NSStringFromSelector(_cmd));
        return nil;
    }
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session requestBody:requestData method:kAlfrescoHTTPPost alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
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
    return [self updateTask:task requestBody:@{kAlfrescoWorkflowLegacyJSONOwner : self.session.personIdentifier} completionBlock:completionBlock];
}

- (AlfrescoRequest *)unclaimTask:(AlfrescoWorkflowTask *)task
                 completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    return [self updateTask:task requestBody:@{kAlfrescoWorkflowLegacyJSONOwner : [NSNull null]} completionBlock:completionBlock];
}

- (AlfrescoRequest *)reassignTask:(AlfrescoWorkflowTask *)task
                       toAssignee:(AlfrescoPerson *)assignee
                  completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    return [self updateTask:task requestBody:@{kAlfrescoWorkflowLegacyJSONOwner : assignee.identifier} completionBlock:completionBlock];
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
                              attachment:(AlfrescoDocument *)document
                         completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    return [self updateAttachmentsOnTask:task attachments:@[document] addition:YES completionBlock:completionBlock];
}

- (AlfrescoRequest *)addAttachmentsToTask:(AlfrescoWorkflowTask *)task
                              attachments:(NSArray *)documentArray
                          completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    return [self updateAttachmentsOnTask:task attachments:documentArray addition:YES completionBlock:completionBlock];
}

- (AlfrescoRequest *)removeAttachmentFromTask:(AlfrescoWorkflowTask *)task
                                   attachment:(AlfrescoDocument *)document
                              completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    return [self updateAttachmentsOnTask:task attachments:@[document] addition:NO completionBlock:completionBlock];
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

- (AlfrescoRequest *)updateTask:(AlfrescoWorkflowTask *)task
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
                id responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&conversionError];
                
                NSDictionary *entry = ((NSDictionary *) responseObject)[kAlfrescoWorkflowLegacyJSONData];
                AlfrescoWorkflowTask *task = [[AlfrescoWorkflowTask alloc] initWithProperties:entry];
                completionBlock(task, conversionError);
            }
        }];
        
        return request;
    }
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
                                 attachments:(NSArray *)documentArray
                                    addition:(BOOL)addition
                             completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:documentArray argumentName:@"documentArray"];
    [AlfrescoErrors assertArgumentNotNil:task argumentName:@"task"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *nodeReferences = @"";
    for (int i = 0; i < documentArray.count; i++)
    {
        id documentObject = documentArray[i];
        if (![documentObject isKindOfClass:[AlfrescoDocument class]])
        {
            NSString *exceptionMessage = [NSString stringWithFormat:@"The node array passed into %@ should contain instances of %@, instead it contained instances of %@",
                                          NSStringFromSelector(_cmd),
                                          NSStringFromClass([AlfrescoDocument class]),
                                          NSStringFromClass([documentObject class])];
            @throw [NSException exceptionWithName:@"Invaild parameters" reason:exceptionMessage userInfo:nil];
        }
        
        AlfrescoDocument *currentNode = (AlfrescoDocument *)documentObject;
        
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
    [self.session.networkProvider executeRequestWithURL:url session:self.session requestBody:requestData method:kAlfrescoHTTPPost alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
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

- (NSString *)processVariableKey:(NSString *)key
{
    NSString *processedKey = key;
    
    // encode the variable name
    processedKey = [AlfrescoWorkflowObjectConverter encodeVariableName:key];
    
    // check whether the key already has either prefix
    if ([key rangeOfString:kAlfrescoWorkflowLegacyJSONPropertyPrefix].location == NSNotFound &&
        [key rangeOfString:kAlfrescoWorkflowLegacyJSONAssociationPrefix].location == NSNotFound)
    {
        // Ideally we should look up the variable using the Alfresco model defined for the
        // workflow/task to determine which prefix is required, for now presume a property
        
        processedKey = [kAlfrescoWorkflowLegacyJSONPropertyPrefix stringByAppendingString:processedKey];
    }
    
    return processedKey;
}

@end
