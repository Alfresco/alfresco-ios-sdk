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

/** AlfrescoPublicAPIWorkflowProcessDefinitionService
 
 Author: Tauseef Mughal (Alfresco)
 */

#import "AlfrescoPublicAPIWorkflowProcessDefinitionService.h"
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoErrors.h"
#import "AlfrescoURLUtils.h"
#import "AlfrescoWorkflowObjectConverter.h"

@interface AlfrescoPublicAPIWorkflowProcessDefinitionService ()

@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, strong, readwrite) AlfrescoWorkflowObjectConverter *workflowObjectConverter;

@end

@implementation AlfrescoPublicAPIWorkflowProcessDefinitionService

- (id)initWithSession:(id<AlfrescoSession>)session
{
    self = [super init];
    if (self)
    {
        self.session = session;
        self.baseApiUrl = [[self.session.baseUrl absoluteString] stringByAppendingString:kAlfrescoPublicAPIWorkflowBaseURL];
        self.workflowObjectConverter = [[AlfrescoWorkflowObjectConverter alloc] init];
    }
    return self;
}

- (AlfrescoRequest *)retrieveAllProcessDefinitionsWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
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
            NSArray *workflowDefinitions = [self.workflowObjectConverter workflowDefinitionsFromPublicJSONData:data session:self.session conversionError:&conversionError];
            completionBlock(workflowDefinitions, conversionError);
        }
    }];
    return alfrescoRequest;
}

- (AlfrescoRequest *)retrieveProcessDefinitionsWithListingContext:(AlfrescoListingContext *)listingContext completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
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
            NSArray *workflowDefinitions = [self.workflowObjectConverter workflowDefinitionsFromPublicJSONData:data session:self.session conversionError:&conversionError];
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

- (AlfrescoRequest *)retrieveProcessDefinitionWithIdentifier:(NSString *)processIdentifier completionBlock:(AlfrescoProcessDefinitionCompletionBlock)completionBlock
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
                AlfrescoWorkflowProcessDefinition *processDefinition = [[AlfrescoWorkflowProcessDefinition alloc] initWithProperties:jsonResponseDictionary session:self.session];
                completionBlock(processDefinition, error);
            }
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveFormModelForProcess:(NSString *)processDefinitionId completionBlock:(AlfrescoDictionaryCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:processDefinitionId argumentName:@"processDefinitionId"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *requestString = [kAlfrescoPublicAPIWorkflowProcessDefinitionFormModel stringByReplacingOccurrencesOfString:kAlfrescoProcessDefinitionID withString:processDefinitionId];
    
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
                // return Dictionary for now
                completionBlock(jsonResponseDictionary, error);
            }
        }
    }];
    return request;
}

#pragma mark - Private Functions

@end
