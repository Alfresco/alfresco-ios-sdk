/*******************************************************************************
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
 ******************************************************************************/

#import "AlfrescoDocumentFolderService.h"
#import "AlfrescoPlaceholderDocumentFolderService.h"
#import "CMISDocument.h"
#import "CMISSession.h"
#import "CMISObjectConverter.h"
#import "CMISObjectList.h"
#import "CMISPagedResult.h"
#import "CMISOperationContext.h"
#import "CMISConstants.h"
#import "CMISStringInOutParameter.h"
#import "CMISErrors.h"
#import "AlfrescoCMISToAlfrescoObjectConverter.h"
#import "AlfrescoInternalConstants.h"
#import <objc/runtime.h>
#import "AlfrescoPagingUtils.h"
#import "AlfrescoURLUtils.h"
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoBasicAuthenticationProvider.h"
#import "AlfrescoSortingUtils.h"
#import "AlfrescoLog.h"
#import "AlfrescoCMISUtil.h"
#import "AlfrescoFavoritesCache.h"

@interface AlfrescoDocumentFolderService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) CMISSession *cmisSession;
@property (nonatomic, strong, readwrite) AlfrescoCMISToAlfrescoObjectConverter *objectConverter;
@property (nonatomic, weak, readwrite) id<AlfrescoAuthenticationProvider> authenticationProvider;
@property (nonatomic, strong, readwrite) AlfrescoFavoritesCache *favoritesCache;
@property (nonatomic, strong, readwrite) NSString *defaultSortKey;
@end

@implementation AlfrescoDocumentFolderService

+ (id)alloc
{
    if (self == [AlfrescoDocumentFolderService self])
    {
        return [AlfrescoPlaceholderDocumentFolderService alloc];
    }
    return [super alloc];
}

- (id)initWithSession:(id<AlfrescoSession>)session
{
    self = [super init];
    if (nil != self)
    {
        self.session = session;
        self.cmisSession = [session objectForParameter:kAlfrescoSessionKeyCmisSession];
        self.objectConverter = [[AlfrescoCMISToAlfrescoObjectConverter alloc] initWithSession:self.session];
        id authenticationObject = [session objectForParameter:kAlfrescoAuthenticationProviderObjectKey];
        self.authenticationProvider = nil;
        if ([authenticationObject isKindOfClass:[AlfrescoBasicAuthenticationProvider class]])
        {
            self.authenticationProvider = (AlfrescoBasicAuthenticationProvider *)authenticationObject;
        }
        self.defaultSortKey = kAlfrescoSortByName;
    }
    return self;
}

#pragma mark - Create methods

- (AlfrescoRequest *)createFolderWithName:(NSString *)folderName
                           inParentFolder:(AlfrescoFolder *)folder
                               properties:(NSDictionary *)properties
                          completionBlock:(AlfrescoFolderCompletionBlock)completionBlock;
{
    return [self createFolderWithName:folderName inParentFolder:folder properties:properties aspects:nil type:nil completionBlock:completionBlock];
}

- (AlfrescoRequest *)createFolderWithName:(NSString *)folderName
                           inParentFolder:(AlfrescoFolder *)folder
                               properties:(NSDictionary *)properties
                                  aspects:(NSArray *)aspects
                          completionBlock:(AlfrescoFolderCompletionBlock)completionBlock
{
    return [self createFolderWithName:folderName inParentFolder:folder properties:properties aspects:aspects type:nil completionBlock:completionBlock];
}

- (AlfrescoRequest *)createFolderWithName:(NSString *)folderName
                           inParentFolder:(AlfrescoFolder *)folder
                               properties:(NSDictionary *)properties
                                  aspects:(NSArray *)aspects
                                     type:(NSString *)type
                          completionBlock:(AlfrescoFolderCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:folder argumentName:@"folder"];
    [AlfrescoErrors assertArgumentNotNil:folder.identifier argumentName:@"folder.identifier"];
    [AlfrescoErrors assertArgumentNotNil:folderName argumentName:@"folderName"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSDictionary *processedProperties = [self propertiesForName:folderName properties:properties type:type aspects:aspects isFolder:YES];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    request.httpRequest = [self.cmisSession createFolder:processedProperties inFolder:folder.identifier completionBlock:^(NSString *folderRef, NSError *error){
        if (nil != folderRef)
        {
            AlfrescoRequest *retrieveRequest = [self retrieveNodeWithIdentifier:folderRef completionBlock:^(AlfrescoNode *node, NSError *error) {
                completionBlock((AlfrescoFolder *)node, error);
            }];
            
            request.httpRequest = retrieveRequest.httpRequest;
        }
        else
        {
            NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:error];
            completionBlock(nil, alfrescoError);
        }
    }];
    return request;
}

- (AlfrescoRequest *)createDocumentWithName:(NSString *)documentName
                             inParentFolder:(AlfrescoFolder *)folder
                                contentFile:(AlfrescoContentFile *)file
                                 properties:(NSDictionary *)properties 
                            completionBlock:(AlfrescoDocumentCompletionBlock)completionBlock
                              progressBlock:(AlfrescoProgressBlock)progressBlock
{
    return [self createDocumentWithName:documentName
                         inParentFolder:folder
                            contentFile:file
                             properties:properties
                                aspects:nil
                                   type:nil
                        completionBlock:completionBlock
                          progressBlock:progressBlock];
}

- (AlfrescoRequest *)createDocumentWithName:(NSString *)documentName
                             inParentFolder:(AlfrescoFolder *)folder
                                contentFile:(AlfrescoContentFile *)file
                                 properties:(NSDictionary *)properties
                                    aspects:(NSArray *)aspects
                            completionBlock:(AlfrescoDocumentCompletionBlock)completionBlock
                              progressBlock:(AlfrescoProgressBlock)progressBlock
{
    return [self createDocumentWithName:documentName
                         inParentFolder:folder
                            contentFile:file
                             properties:properties
                                aspects:aspects
                                   type:nil
                        completionBlock:completionBlock
                          progressBlock:progressBlock];
}

- (AlfrescoRequest *)createDocumentWithName:(NSString *)documentName
                             inParentFolder:(AlfrescoFolder *)folder
                                contentFile:(AlfrescoContentFile *)file
                                 properties:(NSDictionary *)properties
                                    aspects:(NSArray *)aspects
                                       type:(NSString *)type
                            completionBlock:(AlfrescoDocumentCompletionBlock)completionBlock
                              progressBlock:(AlfrescoProgressBlock)progressBlock
{
    [AlfrescoErrors assertArgumentNotNil:file argumentName:@"file"];
    [AlfrescoErrors assertArgumentNotNil:folder argumentName:@"folder"];
    [AlfrescoErrors assertArgumentNotNil:folder.identifier argumentName:@"folder.identifier"];
    [AlfrescoErrors assertArgumentNotNil:documentName argumentName:@"documentName"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSDictionary *processedProperties = [self propertiesForName:documentName properties:properties type:type aspects:aspects isFolder:NO];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    request.httpRequest = [self.cmisSession createDocumentFromFilePath:[file.fileUrl path] mimeType:file.mimeType properties:processedProperties inFolder:folder.identifier completionBlock:^(NSString *identifier, NSError *error){
        if (nil == identifier)
        {
            NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:error];
            completionBlock(nil, alfrescoError);
        }
        else
        {
            AlfrescoRequest *retrieveRequest = [self retrieveNodeWithIdentifier:identifier completionBlock:^(AlfrescoNode *node, NSError *error) {
                
                completionBlock((AlfrescoDocument *)node, error);
                if (nil != node)
                {
                    BOOL isExtractMetadata = [[self.session objectForParameter:kAlfrescoMetadataExtraction] boolValue];
                    if (isExtractMetadata)
                    {
                        [self extractMetadataForNode:node alfrescoRequest:request];
                    }
                    BOOL isGenerateThumbnails = [[self.session objectForParameter:kAlfrescoThumbnailCreation] boolValue];
                    if (isGenerateThumbnails)
                    {
                        [self generateThumbnailForNode:node alfrescoRequest:request];
                    }
                }
            }];
            
            request.httpRequest = retrieveRequest.httpRequest;
        }
    } progressBlock:^(unsigned long long bytesUploaded, unsigned long long bytesTotal){
        if (progressBlock)
        {
            progressBlock(bytesUploaded, bytesTotal);
        }
    }];
    return request;
}

- (AlfrescoRequest *)createDocumentWithName:(NSString *)documentName
                             inParentFolder:(AlfrescoFolder *)folder
                              contentStream:(AlfrescoContentStream *)contentStream
                                 properties:(NSDictionary *)properties
                            completionBlock:(AlfrescoDocumentCompletionBlock)completionBlock
                              progressBlock:(AlfrescoProgressBlock)progressBlock
{
    
    return [self createDocumentWithName:documentName
                         inParentFolder:folder
                          contentStream:contentStream
                             properties:properties
                                aspects:nil
                                   type:nil
                        completionBlock:completionBlock
                          progressBlock:progressBlock];
}

- (AlfrescoRequest *)createDocumentWithName:(NSString *)documentName
                             inParentFolder:(AlfrescoFolder *)folder
                              contentStream:(AlfrescoContentStream *)contentStream
                                 properties:(NSDictionary *)properties
                                    aspects:(NSArray *)aspects
                            completionBlock:(AlfrescoDocumentCompletionBlock)completionBlock
                              progressBlock:(AlfrescoProgressBlock)progressBlock
{
    return [self createDocumentWithName:documentName
                         inParentFolder:folder
                          contentStream:contentStream
                             properties:properties
                                aspects:aspects
                                   type:nil
                        completionBlock:completionBlock
                          progressBlock:progressBlock];
}


- (AlfrescoRequest *)createDocumentWithName:(NSString *)documentName
                             inParentFolder:(AlfrescoFolder *)folder
                              contentStream:(AlfrescoContentStream *)contentStream
                                 properties:(NSDictionary *)properties
                                    aspects:(NSArray *)aspects
                                       type:(NSString *)type
                            completionBlock:(AlfrescoDocumentCompletionBlock)completionBlock
                              progressBlock:(AlfrescoProgressBlock)progressBlock
{
    [AlfrescoErrors assertArgumentNotNil:contentStream argumentName:@"contentStream"];
    [AlfrescoErrors assertArgumentNotNil:folder argumentName:@"folder"];
    [AlfrescoErrors assertArgumentNotNil:folder.identifier argumentName:@"folder.identifier"];
    [AlfrescoErrors assertArgumentNotNil:documentName argumentName:@"documentName"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    NSDictionary *processedProperties = [self propertiesForName:documentName properties:properties type:type aspects:aspects isFolder:NO];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    request.httpRequest = [self.cmisSession createDocumentFromInputStream:contentStream.inputStream
                                                                 mimeType:contentStream.mimeType
                                                               properties:processedProperties
                                                                 inFolder:folder.identifier
                                                            bytesExpected:contentStream.length
                                                          completionBlock:^(NSString *objectId, NSError *error) {
        if (nil == objectId)
        {
            NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:error];
            completionBlock(nil, alfrescoError);
        }
        else
        {
            AlfrescoRequest *retrieveRequest = [self retrieveNodeWithIdentifier:objectId completionBlock:^(AlfrescoNode *node, NSError *error) {
                completionBlock((AlfrescoDocument *)node, error);
                if (nil != node)
                {
                    BOOL isExtractMetadata = [[self.session objectForParameter:kAlfrescoMetadataExtraction] boolValue];
                    if (isExtractMetadata)
                    {
                        [self extractMetadataForNode:node alfrescoRequest:request];
                    }
                    BOOL isGenerateThumbnails = [[self.session objectForParameter:kAlfrescoThumbnailCreation] boolValue];
                    if (isGenerateThumbnails)
                    {
                        [self generateThumbnailForNode:node alfrescoRequest:request];
                    }
                }
            }];
            
            request.httpRequest = retrieveRequest.httpRequest;
        }
    } progressBlock:^(unsigned long long bytesUploaded, unsigned long long bytesTotal) {
        if (progressBlock)
        {
            progressBlock(bytesUploaded, bytesTotal);
        }
    }];
    return request;
}


#pragma mark - Retrieval methods
- (AlfrescoRequest *)retrieveRootFolderWithCompletionBlock:(AlfrescoFolderCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    request.httpRequest = [self.cmisSession retrieveRootFolderWithCompletionBlock:^(CMISFolder *cmisFolder, NSError *error){
        AlfrescoFolder *rootFolder = nil;
        if (nil != cmisFolder)
        {
            rootFolder = (AlfrescoFolder *)[self.objectConverter nodeFromCMISObject:cmisFolder];
            completionBlock(rootFolder, error);
        }
        else
        {
            NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:error];
            completionBlock(nil, alfrescoError);
        }
    }];
    return request;    
}

- (AlfrescoRequest *)retrievePermissionsOfNode:(AlfrescoNode *)node 
                               completionBlock:(AlfrescoPermissionsCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentName:@"node.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    id associatedPermissionsObject = objc_getAssociatedObject(node, &kAlfrescoPermissionsObjectKey);
    if (nil != associatedPermissionsObject && [associatedPermissionsObject isKindOfClass:[AlfrescoPermissions class]])
    {
        completionBlock((AlfrescoPermissions *)associatedPermissionsObject, nil);
        return nil;
    }
    else
    {
        return [self retrieveNodeWithIdentifier:node.identifier completionBlock:^(AlfrescoNode *retrievedNode, NSError *error){
            if (nil == retrievedNode)
            {
                NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:error];
                completionBlock(nil, alfrescoError);
            }
            else
            {
                id associatedObject = objc_getAssociatedObject(retrievedNode, &kAlfrescoPermissionsObjectKey);
                if ([associatedObject isKindOfClass:[AlfrescoPermissions class]])
                {
                    completionBlock((AlfrescoPermissions *)associatedObject, error);
                }
                else
                {
                    error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderPermissions];
                    completionBlock(nil, error);
                }
            }
        }];        
    }
    
}


- (AlfrescoRequest *)retrieveChildrenInFolder:(AlfrescoFolder *)folder 
                              completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:-1];
    return [self retrieveChildrenInFolder:folder listingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
        completionBlock(pagingResult.objects, error);
    }];
}


- (AlfrescoRequest *)retrieveChildrenInFolder:(AlfrescoFolder *)folder
                               listingContext:(AlfrescoListingContext *)listingContext
                              completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock 
{
    [AlfrescoErrors assertArgumentNotNil:folder argumentName:@"folder"];
    [AlfrescoErrors assertArgumentNotNil:folder.identifier argumentName:@"folder.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    // -1 for maxItems is not supported by CMIS
    NSNumber *maxItems = nil;
    if (listingContext.maxItems > 0)
    {
        maxItems = [NSNumber numberWithInt:listingContext.maxItems];
    }
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];

    request.httpRequest = [self.cmisSession.binding.navigationService retrieveChildren:folder.identifier
                                                                               orderBy:[self cmisOrderByPropertyForListingContext:listingContext]
                                                                                filter:nil
                                                                         relationships:CMISIncludeRelationshipNone
                                                                       renditionFilter:nil
                                                               includeAllowableActions:YES
                                                                    includePathSegment:NO
                                                                             skipCount:[NSNumber numberWithInt:listingContext.skipCount]
                                                                              maxItems:maxItems
                                                                       completionBlock:^(CMISObjectList *objectList, NSError *cmisError) {
        if (!objectList)
        {
            NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:cmisError];
            completionBlock(nil, alfrescoError);
        }
        else
        {
            // convert objects
            NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:[objectList.objects count]];
            for (CMISObjectData *queryData in objectList.objects)
            {
                AlfrescoNode *convertedNode = [self.objectConverter nodeFromCMISObjectData:queryData];
                if (convertedNode != nil)
                {
                    [resultArray addObject:convertedNode];
                }
            }
            
            // create paged result object
            AlfrescoPagingResult *pagingResult = [[AlfrescoPagingResult alloc] initWithArray:resultArray
                                                                                hasMoreItems:objectList.hasMoreItems
                                                                                  totalItems:objectList.numItems];
            completionBlock(pagingResult, nil);
        }
    }];

    return request;
}


- (AlfrescoRequest *)retrieveDocumentsInFolder:(AlfrescoFolder *)folder 
                               completionBlock:(AlfrescoArrayCompletionBlock)completionBlock 
{
    AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:-1];
    return [self retrieveDocumentsInFolder:folder listingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
        completionBlock(pagingResult.objects, error);
    }];
}


- (AlfrescoRequest *)retrieveDocumentsInFolder:(AlfrescoFolder *)folder
                                listingContext:(AlfrescoListingContext *)listingContext
                               completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:folder argumentName:@"folder"];
    [AlfrescoErrors assertArgumentNotNil:folder.identifier argumentName:@"folder.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    return [self retrieveChildrenInFolder:folder
                           listingContext:listingContext
                          completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
        if (!pagingResult)
        {
            completionBlock(nil, error);
        }
        else
        {
            // filter the results
            NSArray *documents = [self retrieveItemsWithClassFilter:[AlfrescoDocument class] withArray:pagingResult.objects];
            
            // create new paging result object, use -1 to indicate we don't know how many documents there are!
            AlfrescoPagingResult *filteredPagingResult = [[AlfrescoPagingResult alloc] initWithArray:documents
                                                                                        hasMoreItems:pagingResult.hasMoreItems
                                                                                          totalItems:-1];
            completionBlock(filteredPagingResult, nil);
        }
    }];
}

- (AlfrescoRequest *)retrieveFoldersInFolder:(AlfrescoFolder *)folder 
                             completionBlock:(AlfrescoArrayCompletionBlock)completionBlock 
{
    AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:-1];
    return [self retrieveFoldersInFolder:folder listingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
        completionBlock(pagingResult.objects, error);
    }];
}

- (AlfrescoRequest *)retrieveFoldersInFolder:(AlfrescoFolder *)folder
                              listingContext:(AlfrescoListingContext *)listingContext
                             completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock 
{
    [AlfrescoErrors assertArgumentNotNil:folder argumentName:@"folder"];
    [AlfrescoErrors assertArgumentNotNil:folder.identifier argumentName:@"folder.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    return [self retrieveChildrenInFolder:folder listingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
        if (!pagingResult)
        {
            completionBlock(nil, error);
        }
        else
        {
            // filter the results
            NSArray *folders = [self retrieveItemsWithClassFilter:[AlfrescoFolder class] withArray:pagingResult.objects];
          
            // create new paging result object, use -1 to indicate we don't know how many folders there are!
            AlfrescoPagingResult *filteredPagingResult = [[AlfrescoPagingResult alloc] initWithArray:folders
                                                                                      hasMoreItems:pagingResult.hasMoreItems
                                                                                        totalItems:-1];
            completionBlock(filteredPagingResult, nil);
        }
    }];
}

- (AlfrescoRequest *)retrieveNodeWithIdentifier:(NSString *)identifier
                                completionBlock:(AlfrescoNodeCompletionBlock)completionBlock 
{
    [AlfrescoErrors assertArgumentNotNil:identifier argumentName:@"identifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    request.httpRequest = [self.cmisSession retrieveObject:identifier completionBlock:^(CMISObject *cmisObject, NSError *error){
        if (nil == cmisObject)
        {
            NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:error];
            completionBlock(nil, alfrescoError);
        }
        else
        {
            AlfrescoNode *node = [self.objectConverter nodeFromCMISObject:cmisObject];
            NSError *conversionError = nil;
            if (nil == node)
            {
                conversionError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderFailedToConvertNode];
            }
            completionBlock(node, conversionError);
            
        }
    }];
    
    return request;
}



- (AlfrescoRequest *)retrieveNodeWithFolderPath:(NSString *)path 
                                completionBlock:(AlfrescoNodeCompletionBlock)completionBlock 
{
    [AlfrescoErrors assertArgumentNotNil:path argumentName:@"path"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    request.httpRequest = [self.cmisSession retrieveObjectByPath:path completionBlock:^(CMISObject *cmisObject, NSError *error){
        if (nil == cmisObject)
        {
            NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:error];
            completionBlock(nil, alfrescoError);
        }
        else
        {
            AlfrescoNode *node = [self.objectConverter nodeFromCMISObject:cmisObject];
            NSError *conversionError = nil;
            if (nil == node)
            {
                conversionError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderFailedToConvertNode];
            }
            completionBlock(node, conversionError);
        }
    }];
    return request;
}


- (AlfrescoRequest *)retrieveNodeWithFolderPath:(NSString *)path
                               relativeToFolder:(AlfrescoFolder *)folder
                                completionBlock:(AlfrescoNodeCompletionBlock)completionBlock 
{
    [AlfrescoErrors assertArgumentNotNil:path argumentName:@"path"];
    [AlfrescoErrors assertArgumentNotNil:folder argumentName:@"folder"];
    [AlfrescoErrors assertArgumentNotNil:folder.identifier argumentName:@"folder.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    request.httpRequest = [self.cmisSession retrieveObject:folder.identifier completionBlock:^(CMISObject *cmisObject, NSError *error){
        if (nil == cmisObject)
        {
            NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:error];
            completionBlock(nil, alfrescoError);
        }
        else
        {
            CMISFolder *folder = (CMISFolder *)cmisObject;
            NSString *searchPath = [folder.path stringByAppendingPathComponent:path];
            AlfrescoRequest *retrieveRequest = [self retrieveNodeWithFolderPath:searchPath completionBlock:completionBlock];
            request.httpRequest = retrieveRequest.httpRequest;
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveParentFolderOfNode:(AlfrescoNode *)node
                                completionBlock:(AlfrescoFolderCompletionBlock)completionBlock 
{
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentName:@"node.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    request.httpRequest = [self.cmisSession.binding.navigationService retrieveParentsForObject:node.identifier
                                                                                        filter:nil
                                                                                 relationships:CMISIncludeRelationshipBoth
                                                                               renditionFilter:nil
                                                                       includeAllowableActions:YES
                                                                    includeRelativePathSegment:YES
                                                                               completionBlock:^(NSArray *parents, NSError *error){
       if (nil == parents)
       {
           NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:error];
           completionBlock(nil, alfrescoError);
       }
       else
       {
           AlfrescoFolder *parentFolder = nil;
           NSError *folderError = nil;
           for (CMISObjectData * cmisObjectData in parents)
           {
               AlfrescoNode *node = (AlfrescoNode *)[self.objectConverter nodeFromCMISObjectData:cmisObjectData];
               if ([node isKindOfClass:[AlfrescoFolder class]])
               {
                   parentFolder = (AlfrescoFolder *)node;
                   break;
               }
           }
           if (nil == parentFolder)
           {
               folderError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderNoParent];
           }
           completionBlock(parentFolder, folderError);
       }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveRenditionOfNode:(AlfrescoNode *)node
                               renditionName:(NSString *)renditionName
                             completionBlock:(AlfrescoContentFileCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)retrieveRenditionOfNode:(AlfrescoNode *)node
                               renditionName:(NSString *)renditionName
                                outputStream:(NSOutputStream *)outputStream
                             completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)retrieveContentOfDocument:(AlfrescoDocument *)document
                               completionBlock:(AlfrescoContentFileCompletionBlock)completionBlock
                                 progressBlock:(AlfrescoProgressBlock)progressBlock
{
    [AlfrescoErrors assertArgumentNotNil:document argumentName:@"document"];
    [AlfrescoErrors assertArgumentNotNil:document.identifier argumentName:@"document.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    NSString *identifier = [document.identifier stringByReplacingOccurrencesOfString:kAlfrescoLegacyAPINodeRefPrefix withString:@""];
    NSString *tmpFile = [[NSTemporaryDirectory() stringByAppendingPathComponent:identifier] stringByAppendingPathExtension:[document.name pathExtension]];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    request.httpRequest = [self.cmisSession downloadContentOfCMISObject:document.identifier toFile:tmpFile completionBlock:^(NSError *error){
        if (error)
        {
            NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:error];
            completionBlock(nil, alfrescoError);
        }
        else
        {
            AlfrescoContentFile *downloadedFile = [[AlfrescoContentFile alloc]initWithUrl:[NSURL fileURLWithPath:tmpFile]];
            completionBlock(downloadedFile, nil);
        }
    } progressBlock:^(unsigned long long bytesDownloaded, unsigned long long bytesTotal){
        if (progressBlock)
        {
            progressBlock(bytesDownloaded, bytesTotal);
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveContentOfDocument:(AlfrescoDocument *)document
                                  outputStream:(NSOutputStream *)outputStream
                               completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
                                 progressBlock:(AlfrescoProgressBlock)progressBlock
{
    [AlfrescoErrors assertArgumentNotNil:document argumentName:@"document"];
    [AlfrescoErrors assertArgumentNotNil:document.identifier argumentName:@"document.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    request.httpRequest = [self.cmisSession downloadContentOfCMISObject:document.identifier toOutputStream:outputStream completionBlock:^(NSError *error) {
        if (error)
        {
            NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:error];
            completionBlock(NO, alfrescoError);
        }
        else
        {
            completionBlock(YES, nil);
        }
    } progressBlock:^(unsigned long long bytesDownloaded, unsigned long long bytesTotal) {
        if (progressBlock)
        {
            progressBlock(bytesDownloaded, bytesTotal);
        }
    }];
    return request;
}

#pragma mark - Modification methods
- (AlfrescoRequest *)updateContentOfDocument:(AlfrescoDocument *)document
                               contentStream:(AlfrescoContentStream *)contentStream
                             completionBlock:(AlfrescoDocumentCompletionBlock)completionBlock
                               progressBlock:(AlfrescoProgressBlock)progressBlock
{
    [AlfrescoErrors assertArgumentNotNil:contentStream argumentName:@"contentStream"];
    [AlfrescoErrors assertArgumentNotNil:document argumentName:@"document"];
    [AlfrescoErrors assertArgumentNotNil:document.identifier argumentName:@"document.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    request.httpRequest = [self.cmisSession retrieveObject:document.identifier completionBlock:^(CMISObject *cmisObject, NSError *error){
        if (nil == cmisObject)
        {
            NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:error];
            completionBlock(nil, alfrescoError);
        }
        else
        {
            CMISDocument *cmisDocument = (CMISDocument *)cmisObject;
            request.httpRequest = [cmisDocument changeContentToContentOfInputStream:contentStream.inputStream
                                                                      bytesExpected:contentStream.length
                                                                           fileName:document.name
                                                                           mimeType:contentStream.mimeType
                                                                          overwrite:YES
                                                                    completionBlock:^(NSError *error){
                if (error)
                {
                    completionBlock(nil, error);
                }
                else
                {
                    NSString *versionSeriesId = [cmisObject.properties propertyValueForId:@"cmis:versionSeriesId"];
                    request.httpRequest = [self.cmisSession retrieveObject:versionSeriesId completionBlock:^(CMISObject *updatedObject, NSError *updatedError){
                        if (nil == updatedObject)
                        {
                            NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:updatedError];
                            completionBlock(nil, alfrescoError);
                        }
                        else
                        {
                            AlfrescoDocument *alfrescoDocument = (AlfrescoDocument *)[self.objectConverter nodeFromCMISObject:updatedObject];
                            NSError *alfrescoError = nil;
                            if (nil == alfrescoDocument)
                            {
                                alfrescoError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderFailedToConvertNode];
                            }
                            completionBlock(alfrescoDocument, alfrescoError);
                        }
                    }];
                }
            } progressBlock:^(unsigned long long bytesUploaded, unsigned long long bytesTotal){
                if(progressBlock && 0 < contentStream.length)
                {
                    progressBlock(bytesUploaded, bytesTotal);
                }
            }];
        }
    }];
    return request;
    
}

- (AlfrescoRequest *)updateContentOfDocument:(AlfrescoDocument *)document
                                 contentFile:(AlfrescoContentFile *)file
                             completionBlock:(AlfrescoDocumentCompletionBlock)completionBlock
                               progressBlock:(AlfrescoProgressBlock)progressBlock
{
    [AlfrescoErrors assertArgumentNotNil:file argumentName:@"file"];
    [AlfrescoErrors assertArgumentNotNil:document argumentName:@"document"];
    [AlfrescoErrors assertArgumentNotNil:document.identifier argumentName:@"document.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    request.httpRequest = [self.cmisSession retrieveObject:document.identifier completionBlock:^(CMISObject *cmisObject, NSError *error){
        if (nil == cmisObject)
        {
            NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:error];
            completionBlock(nil, alfrescoError);
        }
        else
        {
            CMISDocument *document = (CMISDocument *)cmisObject;
            request.httpRequest = [document changeContentToContentOfFile:[file.fileUrl path] mimeType:file.mimeType overwrite:YES completionBlock:^(NSError *error){
                if (error)
                {
                    completionBlock(nil, error);
                }
                else
                {
                    NSString *versionSeriesId = [cmisObject.properties propertyValueForId:@"cmis:versionSeriesId"];
                    request.httpRequest = [self.cmisSession retrieveObject:versionSeriesId completionBlock:^(CMISObject *updatedObject, NSError *updatedError){
                        if (nil == updatedObject)
                        {
                            NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:updatedError];
                            completionBlock(nil, alfrescoError);
                        }
                        else
                        {
                            AlfrescoDocument *alfrescoDocument = (AlfrescoDocument *)[self.objectConverter nodeFromCMISObject:updatedObject];
                            NSError *alfrescoError = nil;
                            if (nil == alfrescoDocument)
                            {
                                alfrescoError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderFailedToConvertNode];
                            }
                            completionBlock(alfrescoDocument, alfrescoError);
                        }
                    }];
                }
            } progressBlock:^(unsigned long long bytesUploaded, unsigned long long bytesTotal){
                if(progressBlock)
                {
                    progressBlock(bytesUploaded, bytesTotal);
                }
            }];
        }
    }];
    return request;    
}


- (AlfrescoRequest *)updatePropertiesOfNode:(AlfrescoNode *)node 
                                 properties:(NSDictionary *)properties
                            completionBlock:(AlfrescoNodeCompletionBlock)completionBlock
{
    return [self updatePropertiesOfNode:node properties:properties aspects:nil completionBlock:completionBlock];
}

- (AlfrescoRequest *)updatePropertiesOfNode:(AlfrescoNode *)node
                                 properties:(NSDictionary *)properties
                                    aspects:(NSArray *)aspects
                            completionBlock:(AlfrescoNodeCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:properties argumentName:@"properties"];
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    // remember the versionSeriesId of the node
    NSString *versionSeriesId = [node propertyValueWithName:kCMISPropertyVersionSeriesId];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [AlfrescoCMISUtil preparePropertiesForUpdate:properties
                                         aspects:aspects
                                            node:node
                                     cmisSession:self.cmisSession
                                 completionBlock:^(CMISProperties *cmisProperties, NSError *prepareError) {
         if (cmisProperties == nil)
         {
             NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:prepareError];
             completionBlock(nil, alfrescoError);
         }
         else
         {
             CMISStringInOutParameter *inOutParam = [CMISStringInOutParameter inOutParameterUsingInParameter:node.identifier];
             request.httpRequest = [self.cmisSession.binding.objectService
                                    updatePropertiesForObject:inOutParam
                                    properties:cmisProperties
                                    changeToken:nil
                                    completionBlock:^(NSError *updateError){
                if (nil != updateError)
                {
                    NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:updateError];
                    completionBlock(nil, alfrescoError);
                }
                else
                {
                    request.httpRequest = [self.cmisSession retrieveObject:versionSeriesId completionBlock:^(CMISObject *updatedCMISObject, NSError *retrievalError) {
                        if (nil == updatedCMISObject)
                        {
                            completionBlock(nil, retrievalError);
                        }
                        else
                        {
                            AlfrescoNode *resultNode = [self.objectConverter nodeFromCMISObject:updatedCMISObject];
                            NSError *conversionError = nil;
                            if (nil == resultNode)
                            {
                                conversionError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderFailedToConvertNode];
                            }
                            completionBlock(resultNode, conversionError);
                        }
                    }];
                }
            }];
         }
     }];
    
    return request;
}

- (AlfrescoRequest *)addAspectsToNode:(AlfrescoNode *)node
                              aspects:(NSArray *)aspects
                      completionBlock:(AlfrescoNodeCompletionBlock)completionBlock
{
    return [self updatePropertiesOfNode:node properties:@{} aspects:aspects completionBlock:completionBlock];
}

- (AlfrescoRequest *)deleteNode:(AlfrescoNode *)node
                completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentName:@"node.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    if ([node isKindOfClass:[AlfrescoDocument class]])
    {
        request.httpRequest = [self.cmisSession.binding.objectService deleteObject:node.identifier allVersions:YES completionBlock:^(BOOL objectDeleted, NSError *error){
            if (!objectDeleted)
            {
                NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:error];
                completionBlock(NO, alfrescoError);
            }
            else
            {
                completionBlock(YES, nil);
            }
        }];
    }
    else
    {
        request.httpRequest = [self.cmisSession.binding.objectService deleteTree:node.identifier allVersion:YES unfileObjects:CMISDelete continueOnFailure:YES completionBlock:^(NSArray *failedObjects, NSError *error){
            if (error)
            {
                NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:error];
                completionBlock(NO, alfrescoError);
            }
            else
            {
                completionBlock(YES, nil);
            }
        }];
    }
    return request;
        
}

#pragma mark - Internal methods

// filter the provided array with items that match the provided class type
- (NSArray *)retrieveItemsWithClassFilter:(Class) typeClass withArray:(NSArray *)itemArray
{
    NSMutableArray *filteredArray = [NSMutableArray array];
    for (AlfrescoNode *childNode in itemArray)
    {
        if ([childNode isKindOfClass:typeClass])
        {
            [filteredArray addObject:childNode];
        }
    }
    return filteredArray;
}

- (void)extractMetadataForNode:(AlfrescoNode *)node alfrescoRequest:(AlfrescoRequest *)alfrescoRequest
{
    NSMutableDictionary *jsonDictionary = [NSMutableDictionary dictionary];
    
    NSArray *components = [node.identifier componentsSeparatedByString:@";"];
    NSString *identifier = node.identifier;
    if (components.count > 1)
    {
        identifier = components[0];
    }
    
    [jsonDictionary setValue:identifier forKey:kAlfrescoJSONActionedUponNode];
    [jsonDictionary setValue:kAlfrescoJSONExtractMetadata forKey:kAlfrescoJSONActionDefinitionName];
    NSError *postError = nil;
    NSURL *apiUrl = [AlfrescoURLUtils buildURLFromBaseURLString:[self.session.baseUrl absoluteString] extensionURL:kAlfrescoLegacyMetadataExtractionAPI];
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:jsonDictionary
                        options:0
                        error:&postError];
    
    [self.session.networkProvider executeRequestWithURL:apiUrl
                                     session:self.session
                                 requestBody:jsonData
                                                 method:kAlfrescoHTTPPost
                                        alfrescoRequest:alfrescoRequest
                             completionBlock:^(NSData *data, NSError *error){
                                 if (error)
                                 {
                                     AlfrescoLogError(@"Extract metadata call failed: %@", error);
                                 }
                             }];
}

- (void)generateThumbnailForNode:(AlfrescoNode *)node alfrescoRequest:(AlfrescoRequest *)alfrescoRequest
{
    NSMutableDictionary *jsonDictionary = [NSMutableDictionary dictionary];
    [jsonDictionary setValue:kAlfrescoJSONThumbnailName forKey:kAlfrescoThumbnailRendition];
    NSError *postError = nil;
    NSString *requestString = [kAlfrescoLegacyThumbnailCreationAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef
                                                                                                withString:[node.identifier stringByReplacingOccurrencesOfString:@"://"
                                                                                                                                                      withString:@"/"]];
    NSURL *apiUrl = [AlfrescoURLUtils buildURLFromBaseURLString:[self.session.baseUrl absoluteString] extensionURL:requestString];
    
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:jsonDictionary
                        options:0
                        error:&postError];
    [self.session.networkProvider executeRequestWithURL:apiUrl
                                                session:self.session
                                            requestBody:jsonData
                                                 method:kAlfrescoHTTPPost
                                        alfrescoRequest:alfrescoRequest
                                        completionBlock:^(NSData *data, NSError *error){
                                            if (error)
                                            {
                                                AlfrescoLogError(@"Generate thumbnail call failed: %@", error);
                                            }
                                        }];
}

- (NSString *)propertyType:(NSString *)type aspects:(NSArray *)aspects isFolder:(BOOL)isFolder
{
    NSMutableString *propertyString = [NSMutableString string];
    if (isFolder)
    {
        [propertyString appendString:kAlfrescoCMISFolderTypePrefix];
    }
    else
    {
        [propertyString appendString:kAlfrescoCMISDocumentTypePrefix];
    }
    [propertyString appendString:type];
    [propertyString appendString:@","];
    for (NSString *aspect in aspects)
    {
        [propertyString appendString:kAlfrescoCMISAspectPrefix];
        [propertyString appendString:aspect];
        [propertyString appendString:@","];
    }
    return propertyString;
}

- (NSDictionary *)propertiesForName:(NSString *)name
                         properties:(NSDictionary *)properties
                               type:(NSString *)type
                            aspects:(NSArray *)aspects
                           isFolder:(BOOL)isFolder
{
    NSMutableDictionary *processedProperties = [NSMutableDictionary dictionary];
    
    // make sure the cmis:name property is present
    if (nil != properties)
    {
        [processedProperties addEntriesFromDictionary:properties];
    }
    [processedProperties setValue:name forKey:kCMISPropertyName];
    
    // make sure the cm:titled aspect is always applied
    NSMutableArray *modifiedAspects = [NSMutableArray arrayWithArray:aspects];
    if (![modifiedAspects containsObject:kAlfrescoModelAspectTitled])
    {
        [modifiedAspects addObject:kAlfrescoModelAspectTitled];
    }
    
    // prepare the objectTypeId
    NSString *objectTypeId = [AlfrescoCMISUtil prepareObjectTypeIdForProperties:processedProperties type:type aspects:aspects folder:isFolder];
    [processedProperties setValue:objectTypeId forKey:kCMISPropertyObjectTypeId];
    
    return processedProperties;
}

- (NSString *)cmisOrderByPropertyForListingContext:(AlfrescoListingContext *)listingContext
{
    NSString *orderBy = kCMISPropertyName;
    
    if (listingContext)
    {
        // use appropriate CMIS property name
        NSString *sortProperty = listingContext.sortProperty;
        if (sortProperty)
        {
            if ([sortProperty isEqualToString:kAlfrescoSortByDescription])
            {
                orderBy = kCMISPropertyDescription;
            }
            else if ([sortProperty isEqualToString:kAlfrescoSortByCreatedAt])
            {
                orderBy = kCMISPropertyCreationDate;
            }
            else if ([sortProperty isEqualToString:kAlfrescoSortByModifiedAt])
            {
                orderBy = kCMISPropertyModificationDate;
            }
            else if ([sortProperty isEqualToString:kAlfrescoSortByTitle])
            {
                orderBy = kAlfrescoModelPropertyTitle;
            }
        }
    }
    
    // append sort order
    orderBy = [NSString stringWithFormat:@"%@ %@", orderBy, listingContext.sortAscending ? @"ASC" : @"DESC"];
    
    return orderBy;
}

#pragma mark - Favorites

- (AlfrescoRequest *)retrieveFavoriteDocumentsWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)retrieveFavoriteDocumentsWithListingContext:(AlfrescoListingContext *)listingContext
                                                 completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)retrieveFavoriteFoldersWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)retrieveFavoriteFoldersWithListingContext:(AlfrescoListingContext *)listingContext
                                               completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)retrieveFavoriteNodesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)retrieveFavoriteNodesWithListingContext:(AlfrescoListingContext *)listingContext
                                             completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)isFavorite:(AlfrescoNode *)node
              	completionBlock:(AlfrescoFavoritedCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)addFavorite:(AlfrescoNode *)node
                 completionBlock:(AlfrescoFavoritedCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)removeFavorite:(AlfrescoNode *)node
                    completionBlock:(AlfrescoFavoritedCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)retrieveHomeFolderWithCompletionBlock:(AlfrescoFolderCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (AlfrescoRequest *)refreshNode:(AlfrescoNode *)node
                 completionBlock:(AlfrescoNodeCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    AlfrescoRequest *request = [self retrieveNodeWithIdentifier:node.identifier completionBlock:completionBlock];
    return request;
}

- (void)clear
{
    [self.favoritesCache clear];
}


@end
