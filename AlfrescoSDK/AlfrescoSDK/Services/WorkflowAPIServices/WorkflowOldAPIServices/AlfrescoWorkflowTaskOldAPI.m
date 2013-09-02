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

/** AlfrescoWorkflowTaskOldAPI
 
 Author: Tauseef Mughal (Alfresco)
 */

#import "AlfrescoWorkflowTaskOldAPI.h"
#import "AlfrescoSession.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoLog.h"
#import "AlfrescoURLUtils.h"
#import "AlfrescoWorkflowUtils.h"
#import "AlfrescoErrors.h"
#import "AlfrescoPagingUtils.h"
#import "AlfrescoDocumentFolderService.h"

@interface AlfrescoWorkflowTaskOldAPI ()

@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, strong, readwrite) AlfrescoDocumentFolderService *documentService;

@end

@implementation AlfrescoWorkflowTaskOldAPI

- (id)initWithSession:(id<AlfrescoSession>)session
{
    self = [super init];
    if (self)
    {
        self.session = session;
        self.baseApiUrl = [[self.session.baseUrl absoluteString] stringByAppendingString:kAlfrescoWorkflowBaseOldAPIURL];
        self.documentService = [[AlfrescoDocumentFolderService alloc] initWithSession:session];
    }
    return self;
}

- (AlfrescoRequest *)retrieveAllTasksWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoWorkflowTasksOldAPI];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *tasks = [self workflowTasksFromJSONData:data error:&conversionError];
            completionBlock(tasks, conversionError);
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveTasksWithListingContext:(AlfrescoListingContext *)listingContext completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    if (!listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoWorkflowTasksOldAPI];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *workflowDefinitions = [self workflowTasksFromJSONData:data error:&conversionError];
            AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:workflowDefinitions listingContext:listingContext];
            completionBlock(pagingResult, conversionError);
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveTaskWithIdentifier:(NSString *)taskIdentifier completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    [AlfrescoErrors assertArgumentNotNil:taskIdentifier argumentName:@"taskIdentifier"];
    
    NSString *workflowEnginePrefix = [AlfrescoWorkflowUtils prefixForActivitiEngineType:self.session.workflowInfo.workflowEngine];
    NSString *completeTaskIdentifier = [workflowEnginePrefix stringByAppendingString:taskIdentifier];
    NSString *requestString = [kAlfrescoWorkflowSingleTaskOldAPI stringByReplacingOccurrencesOfString:kAlfrescoTaskID withString:completeTaskIdentifier];
    
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
            
            NSDictionary *entry = [(NSDictionary *)responseObject objectForKey:kAlfrescoOldJSONData];
            AlfrescoWorkflowTask *task = [[AlfrescoWorkflowTask alloc] initWithProperties:entry session:self.session];
            completionBlock(task, conversionError);
        }
    }];
    return request;
}

//- (AlfrescoRequest *)retrieveFormModelForTask:(AlfrescoWorkflowTask *)task completionBlock:(Return Type?)completionBlock;

- (AlfrescoRequest *)retrieveAttachmentsForTask:(AlfrescoWorkflowTask *)task completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    [AlfrescoErrors assertArgumentNotNil:task argumentName:@"task"];
    
    NSString *workflowEnginePrefix = [AlfrescoWorkflowUtils prefixForActivitiEngineType:self.session.workflowInfo.workflowEngine];
    NSString *completeTaskIdentifier = [workflowEnginePrefix stringByAppendingString:task.identifier];
    NSString *requestString = [kAlfrescoWorkflowSingleTaskOldAPI stringByReplacingOccurrencesOfString:kAlfrescoTaskID withString:completeTaskIdentifier];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    __weak AlfrescoWorkflowTaskOldAPI *weakSelf = self;
    
    __block AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *taskError) {
        if (!data)
        {
            completionBlock(nil, taskError);
        }
        else
        {
            NSError *conversionError = nil;
            NSString *containerRef = [self retrieveAttachmentContainerNodeRefsFromJSONData:data error:&conversionError];
            
            NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:weakSelf.baseApiUrl extensionURL:kAlfrescoWorkflowTaskAttachmentsOldAPI];
            
            NSDictionary *containerRequest = @{kAlfrescoJSONItems : @[containerRef], kAlfrescoOldJSONItemValue : kAlfrescoJSONNodeRef};
            NSError *jsonParseError = nil;
            NSData *containerRequestData = [NSJSONSerialization dataWithJSONObject:containerRequest options:0 error:&jsonParseError];
            
            if (jsonParseError)
            {
                AlfrescoLogDebug(@"Unable to parse data in selector - %@", NSStringFromSelector(_cmd));
            }
            
            [weakSelf.session.networkProvider executeRequestWithURL:url session:weakSelf.session requestBody:containerRequestData method:kAlfrescoHTTPPOST alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
                if (error)
                {
                    completionBlock(nil, error);
                }
                else
                {
                    NSError *nodeIdentifierError = nil;
                    NSArray *nodeIdentifiers = [self attachmentIdentifiersFromJSONData:data error:&nodeIdentifierError];
                    
                    if (nodeIdentifiers)
                    {
                        [self retrieveAlfrescoNodes:nodeIdentifiers completionBlock:completionBlock];
                    }
                }
            }];
        }
    }];
    
    return request;
}

- (AlfrescoRequest *)retrieveVariablesForTask:(AlfrescoWorkflowTask *)task completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    // STUB - Not part of 1.3
    return nil;
}

- (AlfrescoRequest *)completeTask:(AlfrescoWorkflowTask *)task properties:(NSDictionary *)properties completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    NSMutableDictionary *requestBody = [[NSMutableDictionary alloc] init];
    
    [requestBody addEntriesFromDictionary:properties];
    
    if (self.session.workflowInfo.workflowEngine == AlfrescoWorkflowEngineTypeActiviti)
    {
        [requestBody setObject:kAlfrescoOldJSONNext forKey:kAlfrescoOldBPMJSONTransition];
        
        [requestBody setObject:kAlfrescoOldJSONCompleted forKey:kAlfrescoOldBPMJSONStatus];
        
        if ([task.processDefinitionIdentifier isEqualToString:kAlfrescoWorkflowReviewAndApprove])
        {
            [requestBody setObject:[properties objectForKey:kAlfrescoTaskReviewOutcome] forKey:kAlfrescoOldBPMJSONReviewOutcome];
        }
        
        if ([[properties allKeys] containsObject:kAlfrescoTaskComment])
        {
            [requestBody setObject:[properties objectForKey:kAlfrescoTaskComment] forKey:kAlfrescoOldBPMJSONComment];
        }
    }
    else if (self.session.workflowInfo.workflowEngine == AlfrescoWorkflowEngineTypeJBPM)
    {
        if ([task.processDefinitionIdentifier isEqualToString:kAlfrescoWorkflowReviewAndApprove])
        {
            [requestBody setObject:[properties objectForKey:kAlfrescoTaskReviewOutcome] forKey:kAlfrescoOldBPMJSONTransition];
        }
        else
        {
            [requestBody setObject:@"" forKey:kAlfrescoOldBPMJSONTransition];
        }
        
        [requestBody setObject:kAlfrescoOldJSONCompleted forKey:kAlfrescoOldBPMJSONStatus];
        
        if ([[properties allKeys] containsObject:kAlfrescoTaskComment])
        {
            [requestBody setObject:[properties objectForKey:kAlfrescoTaskComment] forKey:kAlfrescoOldBPMJSONComment];
        }
    }
    else
    {
        AlfrescoLogError(@"The workflow engine type can not be determined in selector - %@", NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSString *workflowEnginePrefix = [AlfrescoWorkflowUtils prefixForActivitiEngineType:self.session.workflowInfo.workflowEngine];
    NSString *taskIdentifier = [workflowEnginePrefix stringByAppendingString:task.identifier];
    NSString *requestString = [kAlfrescoWorkflowTaskCompleteOldAPI stringByReplacingOccurrencesOfString:kAlfrescoTaskID withString:taskIdentifier];
    
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
                NSString *completedString = [(NSDictionary *)responseObject objectForKey:@"persistedObject"];
                NSArray *seperatedStrings = [completedString componentsSeparatedByString:@","];
                NSString *createdTaskID = [[[seperatedStrings objectAtIndex:0] componentsSeparatedByString:@"$"] lastObject];
                
                NSString *workflowEnginePrefix = [AlfrescoWorkflowUtils prefixForActivitiEngineType:self.session.workflowInfo.workflowEngine];
                NSString *completeTaskIdentifier = [workflowEnginePrefix stringByAppendingString:createdTaskID];
                NSString *requestString = [kAlfrescoWorkflowSingleTaskOldAPI stringByReplacingOccurrencesOfString:kAlfrescoTaskID withString:completeTaskIdentifier];
                
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
                        
                        NSDictionary *entry = [(NSDictionary *)responseObject objectForKey:kAlfrescoOldJSONData];
                        AlfrescoWorkflowTask *task = [[AlfrescoWorkflowTask alloc] initWithProperties:entry session:self.session];
                        completionBlock(task, conversionError);
                    }
                }];
            }
        }
    }];
    return request;
}

- (AlfrescoRequest *)claimTask:(AlfrescoWorkflowTask *)task completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    return [self updateTaskState:task requestBody:@{kAlfrescoOldJSONOwner : self.session.personIdentifier} completionBlock:completionBlock];
}

- (AlfrescoRequest *)unclaimTask:(AlfrescoWorkflowTask *)task completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    return [self updateTaskState:task requestBody:@{kAlfrescoOldJSONOwner : [NSNull null]} completionBlock:completionBlock];
}

- (AlfrescoRequest *)assignTask:(AlfrescoWorkflowTask *)task toAssignee:(AlfrescoPerson *)assignee completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    return [self updateTaskState:task requestBody:@{kAlfrescoOldJSONOwner : assignee.identifier} completionBlock:completionBlock];
}

- (AlfrescoRequest *)resolveTask:(AlfrescoWorkflowTask *)task completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    NSError *notSupportedError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeWorkflowFunctionNotSupported];
    if (completionBlock != NULL)
    {
        completionBlock(nil, notSupportedError);
    }
    return nil;
}

- (AlfrescoRequest *)addAttachment:(AlfrescoNode *)node toTask:(AlfrescoWorkflowTask *)task completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    return [self updateAttachments:@[node] onTask:task addition:YES completionBlock:completionBlock];
}

- (AlfrescoRequest *)addAttachments:(NSArray *)nodeArray toTask:(AlfrescoWorkflowTask *)task completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    return [self updateAttachments:nodeArray onTask:task addition:YES completionBlock:completionBlock];
}

- (AlfrescoRequest *)updateVariables:(NSDictionary *)variables forTask:(AlfrescoWorkflowTask *)task completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    // STUB - Not part of 1.3
    return nil;
}

- (AlfrescoRequest *)removeAttachment:(AlfrescoNode *)node fromTask:(AlfrescoWorkflowTask *)task completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
     return [self updateAttachments:@[node] onTask:task addition:NO completionBlock:completionBlock];
}

- (AlfrescoRequest *)removeVariables:(NSArray *)variablesKeys forTask:(AlfrescoWorkflowTask *)task completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    // STUB - Not part of 1.3
    return nil;
}

#pragma mark - Private Functions

- (NSArray *)workflowTasksFromJSONData:(NSData *)jsonData error:(NSError **)conversionError
{
    NSMutableArray *workflowTasks = nil;
    
    if (jsonData == nil)
    {
        if (*conversionError == nil)
        {
            *conversionError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        }
        else
        {
            NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
            *conversionError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        }
        return workflowTasks;
    }
    
    NSError *error = nil;
    id jsonResponseDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (error)
    {
        *conversionError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeWorkflowNoProcessDefinitionFound];
        return workflowTasks;
    }
    if ([[jsonResponseDictionary valueForKeyPath:kAlfrescoJSONStatusCode] isEqualToNumber:[NSNumber numberWithInt:404]])
    {
        *conversionError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeWorkflowNoProcessDefinitionFound];
        return workflowTasks;
    }
    
    NSArray *processArray = [jsonResponseDictionary valueForKey:kAlfrescoJSONData];
    workflowTasks = [@[] mutableCopy];
    for (NSDictionary *entryDictionary in processArray)
    {
        [workflowTasks addObject:[[AlfrescoWorkflowTask alloc] initWithProperties:entryDictionary session:self.session]];
    }
    
    return workflowTasks;
}

- (NSString *)retrieveAttachmentContainerNodeRefsFromJSONData:(NSData *)jsonData error:(NSError **)conversionError
{
    NSString *containerRef = nil;
    
    id response = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:conversionError];
    
    if ([response isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *jsonResponseDictionary = (NSDictionary *)response;
        NSDictionary *processDictionary = [jsonResponseDictionary valueForKey:kAlfrescoJSONData];
        
        if (processDictionary)
        {
            NSDictionary *taskProperties = [processDictionary objectForKey:kAlfrescoOldJSONProperties];
            containerRef = [taskProperties objectForKey:kAlfrescoOldBPMJSONPackageContainer];
        }
    }
    else
    {
        AlfrescoLogDebug(@"Parsing response, should have returned a dictionary in selector - %@", NSStringFromSelector(_cmd));
    }
    
    return containerRef;
}

- (NSArray *)attachmentIdentifiersFromJSONData:(NSData *)jsonData error:(NSError **)conversionError
{
    NSMutableArray *nodeRefIdentifiers = nil;
    
    id response = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:conversionError];
    
    if ([response isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *jsonResponseDictionary = (NSDictionary *)response;
        NSArray *itemsArray = [[jsonResponseDictionary valueForKey:kAlfrescoOldJSONData] valueForKey:kAlfrescoJSONItems];
        
        nodeRefIdentifiers = [NSMutableArray array];
        
        if (itemsArray)
        {
            for (NSDictionary *item in itemsArray)
            {
                NSString *nodeIdentifier = [item objectForKey:kAlfrescoJSONNodeRef];
                if (nodeIdentifier)
                {
                    [nodeRefIdentifiers addObject:nodeIdentifier];
                }
            }
        }
    }
    else
    {
        AlfrescoLogDebug(@"Parsing response, should have returned a dictionary in selector - %@", NSStringFromSelector(_cmd));
    }
    
    return nodeRefIdentifiers;
}

- (AlfrescoRequest *)updateTaskState:(AlfrescoWorkflowTask *)task requestBody:(NSDictionary *)requestDictionary completionBlock:(AlfrescoTaskCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:task argumentName:@"task"];
    [AlfrescoErrors assertArgumentNotNil:requestDictionary argumentName:@"requestDictionary"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *workflowEnginePrefix = [AlfrescoWorkflowUtils prefixForActivitiEngineType:self.session.workflowInfo.workflowEngine];
    NSString *taskIdentifier = [workflowEnginePrefix stringByAppendingString:task.identifier];
    NSString *requestString = [kAlfrescoWorkflowSingleTaskOldAPI stringByReplacingOccurrencesOfString:kAlfrescoTaskID withString:taskIdentifier];
    
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
            
            NSDictionary *entry = [(NSDictionary *)responseObject objectForKey:kAlfrescoOldJSONData];
            AlfrescoWorkflowTask *task = [[AlfrescoWorkflowTask alloc] initWithProperties:entry session:self.session];
            completionBlock(task, conversionError);
        }
    }];
    
    return request;
}

- (void)retrieveAlfrescoNodes:(NSArray *)alfrescoNodeIdentifiers completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    __block NSMutableArray *alfrescoNodes = [NSMutableArray arrayWithCapacity:alfrescoNodeIdentifiers.count];
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

- (AlfrescoRequest *)updateAttachments:(NSArray *)nodeArray onTask:(AlfrescoWorkflowTask *)task addition:(BOOL)addition completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
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
    NSString *attachmentKey = (addition) ? kAlfrescoOldBPMJSONProcessAttachmentsAdd : kAlfrescoOldBPMJSONProcessAttachmentsRemove;
    NSDictionary *requestBody = @{attachmentKey : nodeReferences};
    
    // build URL
    NSString *workflowEnginePrefix = [AlfrescoWorkflowUtils prefixForActivitiEngineType:self.session.workflowInfo.workflowEngine];
    NSString *completeTaskID = [workflowEnginePrefix stringByAppendingString:task.identifier];
    NSString *requestString = [kAlfrescoWorkflowTaskCompleteOldAPI stringByReplacingOccurrencesOfString:kAlfrescoTaskID withString:completeTaskID];
    
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
