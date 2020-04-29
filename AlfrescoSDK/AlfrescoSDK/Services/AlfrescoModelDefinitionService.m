/*
 ******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
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
#import "AlfrescoLog.h"
#import "CMISConstants.h"
#import "CMISSession.h"
#import "CMISRequest.h"

typedef void (^AlfrescoNodeTypeDefinitionCompletionBlock)(AlfrescoNodeTypeDefinition *typeDefinition, NSError *error);

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
    // we can't do much without a session so just return nil
    if (session == nil)
    {
        return nil;
    }
    
    self = [super init];
    if (nil != self)
    {
        self.session = session;
        self.cmisSession = [session objectForParameter:kAlfrescoSessionKeyCmisSession];
        self.objectConverter = [[AlfrescoCMISToAlfrescoObjectConverter alloc] initWithSession:self.session];
        
        // setup caches
        id cachedTypeObj = [self.session objectForParameter:kAlfrescoSessionCacheDefinitionType];
        if (cachedTypeObj)
        {
            AlfrescoLogDebug(@"Found an existing type definition cache in session");
            self.typeCache = (NSMutableDictionary *)cachedTypeObj;
        }
        else
        {
            self.typeCache = [NSMutableDictionary dictionary];
            [self.session setObject:self.typeCache forParameter:kAlfrescoSessionCacheDefinitionType];
            AlfrescoLogDebug(@"Created new type definition cache");
        }
        
        id cachedAspectObj = [self.session objectForParameter:kAlfrescoSessionCacheDefinitionAspect];
        if (cachedAspectObj)
        {
            AlfrescoLogDebug(@"Found an existing aspect definition cache in session");
            self.aspectCache = (NSMutableDictionary *)cachedAspectObj;
        }
        else
        {
            self.aspectCache = [NSMutableDictionary dictionary];
            [self.session setObject:self.aspectCache forParameter:kAlfrescoSessionCacheDefinitionAspect];
            AlfrescoLogDebug(@"Created new aspect definition cache");
        }
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
    
    AlfrescoRequest *request = nil;
    
    // check cache first
    AlfrescoDocumentTypeDefinition *cachedTypeDefinition = self.typeCache[cmisType];
    if (cachedTypeDefinition != nil)
    {
        AlfrescoLogDebug(@"Cache hit: returning document type definition for %@ from cache", cmisType);
        completionBlock(cachedTypeDefinition, nil);
    }
    else
    {
        request = [self retrieveDefinition:cmisType completionBlock:^(CMISTypeDefinition *typeDefinition, NSError *error) {
            if (typeDefinition != nil)
            {
                // convert the CMIS type definition
                AlfrescoDocumentTypeDefinition *documentTypeDefinition = [self.objectConverter documentTypeDefinitionFromCMISTypeDefinition:typeDefinition];
                if (documentTypeDefinition != nil)
                {
                    // cache the type definition
                    AlfrescoLogDebug(@"Cached document type definition for %@", cmisType);
                    self.typeCache[cmisType] = documentTypeDefinition;
                    
                    // call completion block
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
    
    return request;
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
    
    AlfrescoRequest *request = nil;
    
    // check cache first
    AlfrescoFolderTypeDefinition *cachedTypeDefinition = self.typeCache[cmisType];
    if (cachedTypeDefinition != nil)
    {
        AlfrescoLogDebug(@"Cache hit: returning folder type definition for %@ from cache", cmisType);
        completionBlock(cachedTypeDefinition, nil);
    }
    else
    {
        request =  [self retrieveDefinition:cmisType completionBlock:^(CMISTypeDefinition *typeDefinition, NSError *error) {
            if (typeDefinition != nil)
            {
                // convert the CMIS type definition
                AlfrescoFolderTypeDefinition *folderTypeDefinition = [self.objectConverter folderTypeDefinitionFromCMISTypeDefinition:typeDefinition];
                if (folderTypeDefinition != nil)
                {
                    // cache the type definition
                    AlfrescoLogDebug(@"Cached folder type definition for %@", cmisType);
                    self.typeCache[cmisType] = folderTypeDefinition;
                    
                    // call completion block
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
    
    return request;
}

- (AlfrescoRequest *)retrieveDefinitionForTaskType:(NSString *)type
                                   completionBlock:(AlfrescoTaskTypeDefinitionCompletionBlock)completionBlock
{
    NSString *cmisType = [kAlfrescoCMISDocumentTypePrefix stringByAppendingString:type];
    
    AlfrescoRequest *request = nil;
    
    // check cache first
    AlfrescoTaskTypeDefinition *cachedTypeDefinition = self.typeCache[cmisType];
    if (cachedTypeDefinition != nil)
    {
        AlfrescoLogDebug(@"Cache hit: returning task type definition for %@ from cache", cmisType);
        completionBlock(cachedTypeDefinition, nil);
    }
    else
    {
        request = [self retrieveDefinition:cmisType completionBlock:^(CMISTypeDefinition *typeDefinition, NSError *error) {
            if (typeDefinition != nil)
            {
                // convert the CMIS type definition
                AlfrescoTaskTypeDefinition *taskTypeDefinition = [self.objectConverter taskTypeDefinitionFromCMISTypeDefinition:typeDefinition];
                if (taskTypeDefinition != nil)
                {
                    // cache the type definition
                    AlfrescoLogDebug(@"Cached task type definition for %@", cmisType);
                    self.typeCache[cmisType] = taskTypeDefinition;
                    
                    // call completion block
                    completionBlock(taskTypeDefinition, nil);
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
    
    return request;
}

- (AlfrescoRequest *)retrieveDefinitionForAspect:(NSString *)aspect
                                 completionBlock:(AlfrescoAspectDefinitionCompletionBlock)completionBlock
{
    // construct CMIS specific type identifier
    NSString *cmisType = [kAlfrescoCMISAspectPrefix stringByAppendingString:aspect];
    
    AlfrescoRequest *request = nil;
    
    // check cache first
    AlfrescoAspectDefinition *cachedDefinition = self.aspectCache[cmisType];
    if (cachedDefinition != nil)
    {
        AlfrescoLogDebug(@"Cache hit: returning aspect definition for %@ from cache", cmisType);
        completionBlock(cachedDefinition, nil);
    }
    else
    {
        request = [self retrieveDefinition:cmisType completionBlock:^(CMISTypeDefinition *typeDefinition, NSError *error) {
            if (typeDefinition != nil)
            {
                // convert the CMIS type definition
                AlfrescoAspectDefinition *aspectDefinition = [self.objectConverter aspectDefinitionFromCMISTypeDefinition:typeDefinition];
                if (aspectDefinition != nil)
                {
                    // cache the definition
                    AlfrescoLogDebug(@"Cached aspect definition for %@", cmisType);
                    self.aspectCache[cmisType] = aspectDefinition;
                    
                    // call completion block
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
    
    return request;
}

- (AlfrescoRequest *)retrieveDefinitionForDocument:(AlfrescoDocument *)document
                                   completionBlock:(AlfrescoDocumentTypeDefinitionCompletionBlock)completionBlock
{
    AlfrescoRequest *request = nil;
    request = [self retrieveDefinitionForDocumentType:document.type completionBlock:^(AlfrescoDocumentTypeDefinition *typeDefinition, NSError *typeError) {
        if (typeDefinition == nil)
        {
            completionBlock(nil, typeError);
        }
        else
        {
            // add all properties from applied aspects to the type definition
            [self typeDefinitonWithAspectsFromNode:document
                                    typeDefinition:typeDefinition
                                           request:request
                                   completionBlock:^(AlfrescoNodeTypeDefinition *typeDefinition, NSError *aspectError) {
                                       completionBlock((AlfrescoDocumentTypeDefinition*)typeDefinition, aspectError);
                                   }];
        }
    }];
    
    return request;
}

- (AlfrescoRequest *)retrieveDefinitionForFolder:(AlfrescoFolder *)folder
                                 completionBlock:(AlfrescoFolderTypeDefinitionCompletionBlock)completionBlock
{
    AlfrescoRequest *request = nil;
    request = [self retrieveDefinitionForFolderType:folder.type completionBlock:^(AlfrescoFolderTypeDefinition *typeDefinition, NSError *typeError) {
        if (typeDefinition == nil)
        {
            completionBlock(nil, typeError);
        }
        else
        {
            // add all properties from applied aspects to the type definition
            [self typeDefinitonWithAspectsFromNode:folder
                                    typeDefinition:typeDefinition
                                           request:request
                                   completionBlock:^(AlfrescoNodeTypeDefinition *typeDefinition, NSError *aspectError) {
                                       completionBlock((AlfrescoFolderTypeDefinition*)typeDefinition, aspectError);
                                   }];
        }
    }];
    
    return request;
}

- (AlfrescoRequest *)retrieveDefinitionForTask:(AlfrescoWorkflowTask *)task
                               completionBlock:(AlfrescoTaskTypeDefinitionCompletionBlock)completionBlock
{
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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (void)typeDefinitonWithAspectsFromNode:(AlfrescoNode *)node
                          typeDefinition:(AlfrescoNodeTypeDefinition *)typeDefinition
                                 request:(AlfrescoRequest *)request
                         completionBlock:(AlfrescoNodeTypeDefinitionCompletionBlock)completionBlock
{
    NSMutableArray *aspectPropertyDefinitions = [NSMutableArray array];
    
    // retrieve the definition of each aspect applied to the node and extract the property definitions
    __block int aspectsRetrieved = 0;
    for (NSString *aspect in node.aspects)
    {
        AlfrescoRequest *aspectRequest = nil;
        aspectRequest = [self retrieveDefinitionForAspect:aspect completionBlock:^(AlfrescoAspectDefinition *aspectDefinition, NSError *error) {
            if (aspectDefinition == nil)
            {
                completionBlock(nil, error);
            }
            else
            {
                aspectsRetrieved++;
                
                for (NSString *propertyName in aspectDefinition.propertyNames)
                {
                    AlfrescoPropertyDefinition *propertyDefinition = [aspectDefinition propertyDefinitionForPropertyWithName:propertyName];
                    [aspectPropertyDefinitions addObject:propertyDefinition];
                }
                
                if (aspectsRetrieved == node.aspects.count)
                {
                    // using a selector add the extra property definitons to the existing type definition
                    SEL addPropertyDefinitions = sel_registerName("addPropertyDefinitions:");
                    [typeDefinition performSelector:addPropertyDefinitions withObject:aspectPropertyDefinitions];
                    
                    completionBlock(typeDefinition, nil);
                }
            }
        }];
        
        request.httpRequest = aspectRequest.httpRequest;
    }
}

#pragma clang diagnostic pop

@end
