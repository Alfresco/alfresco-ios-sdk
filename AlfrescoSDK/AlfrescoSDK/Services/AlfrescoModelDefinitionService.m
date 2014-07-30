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

#import "AlfrescoModelDefinitionService.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoErrors.h"
#import "AlfrescoCMISToAlfrescoObjectConverter.h"
#import "AlfrescoRequest.h"
#import "CMISConstants.h"
#import "CMISSession.h"
#import "CMISRequest.h"

@interface AlfrescoModelDefinitionService ()
@property (nonatomic, strong) id<AlfrescoSession> session;
@property (nonatomic, strong) CMISSession *cmisSession;
@property (nonatomic, strong) AlfrescoCMISToAlfrescoObjectConverter *objectConverter;

@property (nonatomic, strong) NSMutableDictionary *typeCache;
@property (nonatomic, strong) NSMutableDictionary *aspectCache;
@end

@implementation AlfrescoModelDefinitionService

#pragma mark - Lifecycle methods

- (id)initWithSession:(id<AlfrescoSession>)session
{
    self = [super init];
    if (nil != self)
    {
        self.session = session;
        self.cmisSession = [session objectForParameter:kAlfrescoSessionKeyCmisSession];
        self.objectConverter = [[AlfrescoCMISToAlfrescoObjectConverter alloc] initWithSession:self.session];
        
        self.typeCache = [NSMutableDictionary dictionary];
        self.aspectCache = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)clear
{
    [self.typeCache removeAllObjects];
    [self.aspectCache removeAllObjects];
}

#pragma mark - Retrieval methods

- (AlfrescoRequest *)retrieveDefinitionForDocumentType:(NSString *)type
                                       completionBlock:(AlfrescoDocumentTypeDefinitionCompletionBlock)completionBlock
{
    // construct CMIS specific type identifier
    NSString *cmisType = kCMISPropertyObjectTypeIdValueDocument;
    if (![type isEqualToString:kAlfrescoModelTypeContent])
    {
        cmisType = [kAlfrescoCMISDocumentTypePrefix stringByAppendingString:type];
    }
    
    return [self retrieveDefinition:cmisType completionBlock:^(CMISTypeDefinition *typeDefinition, NSError *error) {
        if (typeDefinition != nil)
        {
            // convert the CMIS type definition
            AlfrescoDocumentTypeDefinition *documentTypeDefinition = [self.objectConverter documentTypeDefinitionFromCMISTypeDefinition:typeDefinition];
            if (documentTypeDefinition != nil)
            {
                completionBlock(documentTypeDefinition, nil);
            }
            else
            {
                completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeModelDefinitionNotFound]);
            }
        }
        else
        {
            completionBlock(nil, [AlfrescoErrors alfrescoErrorWithUnderlyingError:error
                                                             andAlfrescoErrorCode:kAlfrescoErrorCodeModelDefinitionNotFound]);
        }
    }];
}


- (AlfrescoRequest *)retrieveDefinitionForDocument:(AlfrescoDocument *)document
                                   completionBlock:(AlfrescoDocumentTypeDefinitionCompletionBlock)completionBlock
{
    // TODO: examine the aspects and incorporate their definitions into the response
    return [self retrieveDefinitionForDocumentType:document.type completionBlock:completionBlock];
}

- (AlfrescoRequest *)retrieveDefinitionForFolderType:(NSString *)type
                                     completionBlock:(AlfrescoFolderTypeDefinitionCompletionBlock)completionBlock
{
    // construct CMIS specific type identifier
    NSString *cmisType = kCMISPropertyObjectTypeIdValueFolder;
    if (![type isEqualToString:kAlfrescoModelTypeFolder])
    {
        cmisType = [kAlfrescoCMISFolderTypePrefix stringByAppendingString:type];
    }
    
    return [self retrieveDefinition:cmisType completionBlock:^(CMISTypeDefinition *typeDefinition, NSError *error) {
        if (typeDefinition != nil)
        {
            // convert the CMIS type definition
            AlfrescoFolderTypeDefinition *folderTypeDefinition = [self.objectConverter folderTypeDefinitionFromCMISTypeDefinition:typeDefinition];
            if (folderTypeDefinition != nil)
            {
                completionBlock(folderTypeDefinition, nil);
            }
            else
            {
                completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeModelDefinitionNotFound]);
            }
        }
        else
        {
            completionBlock(nil, [AlfrescoErrors alfrescoErrorWithUnderlyingError:error
                                                             andAlfrescoErrorCode:kAlfrescoErrorCodeModelDefinitionNotFound]);
        }
    }];
}

- (AlfrescoRequest *)retrieveDefinitionForFolder:(AlfrescoFolder *)folder
                                 completionBlock:(AlfrescoFolderTypeDefinitionCompletionBlock)completionBlock
{
    // TODO: examine the aspects and incorporate their definitions into the response
    return [self retrieveDefinitionForFolderType:folder.type completionBlock:completionBlock];
}


- (AlfrescoRequest *)retrieveDefinitionForAspect:(NSString *)aspect
                                 completionBlock:(AlfrescoAspectDefinitionCompletionBlock)completionBlock
{
    // construct CMIS specific type identifier
    NSString *cmisType = [kAlfrescoCMISAspectPrefix stringByAppendingString:aspect];
    
    return [self retrieveDefinition:cmisType completionBlock:^(CMISTypeDefinition *typeDefinition, NSError *error) {
        if (typeDefinition != nil)
        {
            // convert the CMIS type definition
            AlfrescoAspectDefinition *aspectDefinition = [self.objectConverter aspectDefinitionFromCMISTypeDefinition:typeDefinition];
            if (aspectDefinition != nil)
            {
                completionBlock(aspectDefinition, nil);
            }
            else
            {
                completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeModelDefinitionNotFound]);
            }
        }
        else
        {
            completionBlock(nil, [AlfrescoErrors alfrescoErrorWithUnderlyingError:error
                                                             andAlfrescoErrorCode:kAlfrescoErrorCodeModelDefinitionNotFound]);
        }
    }];
}


- (AlfrescoRequest *)retrieveDefinitionForTaskType:(NSString *)type
                                   completionBlock:(AlfrescoTaskTypeDefinitionCompletionBlock)completionBlock
{
    completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeModelDefinition reason:@"Method Not Implemented"]);
    return nil;
}


- (AlfrescoRequest *)retrieveDefinitionForTask:(AlfrescoWorkflowTask *)task
                               completionBlock:(AlfrescoTaskTypeDefinitionCompletionBlock)completionBlock
{
    // TODO: examine the aspects and incorporate their definitions into the response
    return [self retrieveDefinitionForTaskType:task.type completionBlock:completionBlock];
}

#pragma mark - Private methods

- (AlfrescoRequest *)retrieveDefinition:(NSString *)definitionName completionBlock:(void (^)(CMISTypeDefinition *typeDefinition, NSError *error))completionBlock
{
    // ask CMIS for the definition of the type or aspect
    CMISRequest *cmisRequest = [self.cmisSession retrieveTypeDefinition:definitionName completionBlock:completionBlock];
    
    // return a request object
    AlfrescoRequest *alfrescoRequest = [AlfrescoRequest new];
    alfrescoRequest.httpRequest = cmisRequest.httpRequest;
    return alfrescoRequest;
}

@end
