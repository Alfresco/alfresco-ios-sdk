/*******************************************************************************
 * Copyright (C) 2005-2012 Alfresco Software Limited.
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
#import <MobileCoreServices/MobileCoreServices.h>
#import "CMISDocument.h"
#import "CMISSession.h"
#import "CMISQueryResult.h"
#import "CMISObjectConverter.h"
#import "CMISObjectId.h"
#import "CMISFolder.h"
#import "CMISPagedResult.h"
#import "CMISOperationContext.h"
#import "CMISConstants.h"
#import "CMISStringInOutParameter.h"
#import "CMISRendition.h"
#import "CMISEnums.h"
#import "AlfrescoObjectConverter.h"
#import "AlfrescoProperty.h"
#import "AlfrescoErrors.h"
#import "AlfrescoListingContext.h"
#import "AlfrescoInternalConstants.h"
#import <objc/runtime.h>
#import "AlfrescoInternalConstants.h"
#import "AlfrescoPagingUtils.h"
#import "AlfrescoHTTPUtils.h"
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoBasicAuthenticationProvider.h"
#import "AlfrescoSortingUtils.h"
#import "AlfrescoCloudSession.h"


typedef void (^CMISObjectCompletionBlock)(CMISObject *cmisObject, NSError *error);

@interface AlfrescoDocumentFolderService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) CMISSession *cmisSession;
@property (nonatomic, strong, readwrite) NSOperationQueue *operationQueue;
@property (nonatomic, strong, readwrite) AlfrescoObjectConverter *objectConverter;
@property (nonatomic, weak, readwrite) id<AlfrescoAuthenticationProvider> authenticationProvider;
@property (nonatomic, strong, readwrite) NSArray *supportedSortKeys;
@property (nonatomic, strong, readwrite) NSString *defaultSortKey;

// filter the provided array with items that match the provided class type
- (NSArray *)retrieveItemsWithClassFilter:(Class) typeClass withArray:(NSArray *)itemArray;

- (void)extractMetadataForNode:(AlfrescoNode *)node;
- (void)generateThumbnailForNode:(AlfrescoNode *)node;
@end

@implementation AlfrescoDocumentFolderService
@synthesize session = _session;
@synthesize cmisSession = _cmisSession;
@synthesize operationQueue = _operationQueue;
@synthesize objectConverter = _objectConverter;
@synthesize authenticationProvider = _authenticationProvider;
@synthesize supportedSortKeys = _supportedSortKeys;
@synthesize defaultSortKey = _defaultSortKey;


- (id)initWithSession:(id<AlfrescoSession>)session
{
    self = [super init];
    if (nil != self)
    {
        self.session = session;
        self.cmisSession = [session objectForParameter:kAlfrescoSessionKeyCmisSession];
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 2;
        self.objectConverter = [[AlfrescoObjectConverter alloc] initWithSession:self.session];
        id authenticationObject = [session objectForParameter:kAlfrescoAuthenticationProviderObjectKey];
        self.authenticationProvider = nil;
        if ([authenticationObject isKindOfClass:[AlfrescoBasicAuthenticationProvider class]])
        {
            self.authenticationProvider = (AlfrescoBasicAuthenticationProvider *)authenticationObject;
        }
        self.defaultSortKey = kAlfrescoSortByName;
        self.supportedSortKeys = [NSArray arrayWithObjects:kAlfrescoSortByName, kAlfrescoSortByTitle, kAlfrescoSortByDescription, kAlfrescoSortByCreatedAt, kAlfrescoSortByModifiedAt, nil];
    }
    return self;
}

#pragma mark - Create methods

- (void)createFolderWithName:(NSString *)folderName inParentFolder:(AlfrescoFolder *)folder properties:(NSDictionary *)properties 
             completionBlock:(AlfrescoFolderCompletionBlock)completionBlock;
{
    [AlfrescoErrors assertArgumentNotNil:folder argumentName:@"createFolderWithName folder"];
    [AlfrescoErrors assertArgumentNotNil:folder.identifier argumentName:@"folder.identifier"];
    [AlfrescoErrors assertArgumentNotNil:folderName argumentName:@"folderName"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    if(properties == nil)
    {
        properties = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    [properties setValue:folderName forKey:kCMISPropertyName];
    
    // check for a user supplied objectTypeId and use if present.
    NSString *objectTypeId = [properties objectForKey:kCMISPropertyObjectTypeId];
    if (objectTypeId == nil)
    {
        // Add the titled aspect by default when creating a folder.
        objectTypeId = [kCMISPropertyObjectTypeIdValueFolder stringByAppendingString:@",P:cm:titled"];
        [properties setValue:objectTypeId forKey:kCMISPropertyObjectTypeId];
    }
    
    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.cmisSession createFolder:properties inFolder:folder.identifier completionBlock:^(NSString *folderRef, NSError *error){
        if (nil != folderRef)
        {
            [weakSelf retrieveNodeWithIdentifier:folderRef completionBlock:^(AlfrescoNode *node, NSError *error) {
                
                completionBlock((AlfrescoFolder *)node, error);
                
            }];
        }
        else
        {
            completionBlock(nil, error);
        }
        
    }];
}


- (void)createDocumentWithName:(NSString *)documentName inParentFolder:(AlfrescoFolder *)folder contentFile:(AlfrescoContentFile *)file 
                    properties:(NSDictionary *)properties 
                    completionBlock:(AlfrescoDocumentCompletionBlock)completionBlock
                    progressBlock:(AlfrescoProgressBlock)progressBlock
{
    [AlfrescoErrors assertArgumentNotNil:file argumentName:@"createDocumentWithName file"];
    [AlfrescoErrors assertArgumentNotNil:folder argumentName:@"createDocumentWithName folder"];
    [AlfrescoErrors assertArgumentNotNil:folder.identifier argumentName:@"folder.identifier"];
    [AlfrescoErrors assertArgumentNotNil:documentName argumentName:@"folderName"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    [AlfrescoErrors assertArgumentNotNil:progressBlock argumentName:@"progressBlock"];

    if(properties == nil)
    {
        properties = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    [properties setValue:documentName forKey:kCMISPropertyName];
    
    // check for a user supplied objectTypeId and use if present.
    NSString *objectTypeId = [properties objectForKey:kCMISPropertyObjectTypeId];
    if (objectTypeId == nil)
    {
        // Add the titled aspect by default when creating a document.
        objectTypeId = [kCMISPropertyObjectTypeIdValueDocument stringByAppendingString:@", P:cm:titled"];
        [properties setValue:objectTypeId forKey:kCMISPropertyObjectTypeId];
    }
        
    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.cmisSession createDocumentFromFilePath:[file.fileUrl path] withMimeType:file.mimeType withProperties:properties inFolder:folder.identifier completionBlock:^(NSString *identifier, NSError *error){
        if (nil == identifier)
        {
            NSError *alfrescoError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolder];
            completionBlock(nil, alfrescoError);
        }
        else
        {
            [weakSelf retrieveNodeWithIdentifier:identifier completionBlock:^(AlfrescoNode *node, NSError *error) {
                
                completionBlock((AlfrescoDocument *)node, error);
                if (nil != node)
                {
                    BOOL isExtractMetadata = [[weakSelf.session objectForParameter:kAlfrescoMetadataExtraction] boolValue];
                    if (isExtractMetadata)
                    {
                        [weakSelf extractMetadataForNode:node];
                    }
                    BOOL isGenerateThumbnails = [[weakSelf.session objectForParameter:kAlfrescoThumbnailCreation] boolValue];
                    if (isGenerateThumbnails)
                    {
                        [weakSelf generateThumbnailForNode:node];
                    }
                }
            }];
            
        }
    } progressBlock:^(unsigned long long bytesUploaded, unsigned long long bytesTotal){
        if (progressBlock)
        {
            progressBlock(bytesUploaded, bytesTotal);
        }
    }];
}


#pragma mark - Retrieval methods
- (void)retrieveRootFolderWithCompletionBlock:(AlfrescoFolderCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    [self.cmisSession retrieveRootFolderWithCompletionBlock:^(CMISFolder *cmisFolder, NSError *error){
        AlfrescoFolder *rootFolder = nil;
        if (nil != cmisFolder)
        {
            rootFolder = (AlfrescoFolder *)[self.objectConverter nodeFromCMISObject:cmisFolder];
        }
        completionBlock(rootFolder, error);
    }];
    
}

- (void)retrievePermissionsOfNode:(AlfrescoNode *)node 
                  completionBlock:(AlfrescoPermissionsCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"retrievePermissionsOfNode node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentName:@"node.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    [self retrieveNodeWithIdentifier:node.identifier completionBlock:^(AlfrescoNode *retrievedNode, NSError *error){
        if (nil == retrievedNode)
        {
            completionBlock(nil, error);
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


- (void)retrieveChildrenInFolder:(AlfrescoFolder *)folder 
                 completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:folder argumentName:@"retrieveChildrenInFolder folder"];
    [AlfrescoErrors assertArgumentNotNil:folder.identifier argumentName:@"folder.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    [self.cmisSession retrieveObject:folder.identifier completionBlock:^(CMISObject *cmisObject, NSError *error){
        if (nil == cmisObject)
        {
            completionBlock(nil, error);
        }
        else if (![cmisObject isKindOfClass:[CMISFolder class]])
        {
            NSError *classError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderWrongNodeType];
            completionBlock(nil, classError);
        }
        else
        {
            CMISFolder *folder = (CMISFolder *)cmisObject;
            [folder retrieveChildrenWithCompletionBlock:^(CMISPagedResult *pagedResult, NSError *error){
                if (nil == pagedResult)
                {
                    completionBlock(nil, error);
                }
                else
                {
                    NSMutableArray *children = [NSMutableArray array];
                    for (CMISObject *cmisObject in pagedResult.resultArray)
                    {
                        [children addObject:[self.objectConverter nodeFromCMISObject:cmisObject]];
                    }
                    NSArray *sortedArray = [AlfrescoSortingUtils sortedArrayForArray:children sortKey:self.defaultSortKey ascending:YES];
                    completionBlock(sortedArray, nil);
                }
            }];
        }
    }];
}





- (void)retrieveChildrenInFolder:(AlfrescoFolder *)folder
                  listingContext:(AlfrescoListingContext *)listingContext
                 completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock 
{
    [AlfrescoErrors assertArgumentNotNil:folder argumentName:@"retrieveChildrenInFolder folder"];
    [AlfrescoErrors assertArgumentNotNil:folder.identifier argumentName:@"folder.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.cmisSession retrieveObject:folder.identifier completionBlock:^(CMISObject *cmisObject, NSError *error){
        if (nil == cmisObject)
        {
            completionBlock(nil, error);
        }
        else if (![cmisObject isKindOfClass:[CMISFolder class]])
        {
            NSError *classError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderWrongNodeType];
            completionBlock(nil, classError);
        }
        else
        {
            CMISFolder *folder = (CMISFolder *)cmisObject;
            [folder retrieveChildrenWithCompletionBlock:^(CMISPagedResult *pagedResult, NSError *error){
                if (nil == pagedResult)
                {
                    completionBlock(nil, error);
                }
                else
                {
                    AlfrescoPagingResult *pagingResult = nil;
                    NSMutableArray *children = [NSMutableArray array];
                    for (CMISObject *node in pagedResult.resultArray)
                    {
                        [children addObject:[weakSelf.objectConverter nodeFromCMISObject:node]];
                    }
                    NSArray *sortedChildren = nil;
                    if (0 < children.count)
                    {
                        sortedChildren = [AlfrescoSortingUtils sortedArrayForArray:children
                                                                           sortKey:listingContext.sortProperty
                                                                     supportedKeys:self.supportedSortKeys
                                                                        defaultKey:self.defaultSortKey
                                                                         ascending:listingContext.sortAscending];
                    }
                    else
                    {
                        sortedChildren = [NSArray array];
                    }
                    pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedChildren listingContext:listingContext];
                    completionBlock(pagingResult, nil);
                }
            }];
        }
    }];
    
}



- (void)retrieveDocumentsInFolder:(AlfrescoFolder *)folder 
                  completionBlock:(AlfrescoArrayCompletionBlock)completionBlock 
{
    [AlfrescoErrors assertArgumentNotNil:folder argumentName:@"retrieveDocumentsInFolder folder"];
    [AlfrescoErrors assertArgumentNotNil:folder.identifier argumentName:@"folder.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.cmisSession retrieveObject:folder.identifier completionBlock:^(CMISObject *cmisObject, NSError *error){
        if (nil == cmisObject)
        {
            completionBlock(nil, error);
        }
        else if (![cmisObject isKindOfClass:[CMISFolder class]])
        {
            NSError *classError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderWrongNodeType];
            completionBlock(nil, classError);
        }
        else
        {
            CMISFolder *folder = (CMISFolder *)cmisObject;
            [folder retrieveChildrenWithCompletionBlock:^(CMISPagedResult *pagedResult, NSError *error){
                if (nil == pagedResult)
                {
                    completionBlock(nil, error);
                }
                else
                {
                    NSArray *sortedDocuments = nil;
                    NSArray *documents = [weakSelf retrieveItemsWithClassFilter:[AlfrescoDocument class] withArray:pagedResult.resultArray];
                    if (documents.count > 0)
                    {
                        sortedDocuments = [AlfrescoSortingUtils sortedArrayForArray:documents sortKey:self.defaultSortKey ascending:YES];
                    }
                    else
                    {
                        sortedDocuments = [NSArray array];
                    }
                    completionBlock(sortedDocuments, nil);
                }
            }];
        }
    }];
}

- (void)retrieveDocumentsInFolder:(AlfrescoFolder *)folder
                   listingContext:(AlfrescoListingContext *)listingContext
                  completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:folder argumentName:@"retrieveDocumentsInFolder folder"];
    [AlfrescoErrors assertArgumentNotNil:folder.identifier argumentName:@"folder.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.cmisSession retrieveObject:folder.identifier completionBlock:^(CMISObject *cmisObject, NSError *error){
        if (nil == cmisObject)
        {
            completionBlock(nil, error);
        }
        else if (![cmisObject isKindOfClass:[CMISFolder class]])
        {
            NSError *classError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderWrongNodeType];
            completionBlock(nil, classError);
        }
        else
        {
            CMISFolder *folder = (CMISFolder *)cmisObject;
            [folder retrieveChildrenWithCompletionBlock:^(CMISPagedResult *pagedResult, NSError *error){
                if (nil == pagedResult)
                {
                    completionBlock(nil, error);
                }
                else
                {
                    NSArray *sortedDocuments = nil;
                    NSArray *documents = [weakSelf retrieveItemsWithClassFilter:[AlfrescoDocument class] withArray:pagedResult.resultArray];
                    if (documents.count > 0)
                    {
                        sortedDocuments = [AlfrescoSortingUtils sortedArrayForArray:documents
                                                                            sortKey:listingContext.sortProperty
                                                                      supportedKeys:self.supportedSortKeys
                                                                         defaultKey:self.defaultSortKey
                                                                          ascending:listingContext.sortAscending];
                    }
                    else
                    {
                        sortedDocuments = [NSArray array];
                    }
                    AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedDocuments listingContext:listingContext];
                    completionBlock(pagingResult, nil);
                }
            }];
        }
    }];
}

- (void)retrieveFoldersInFolder:(AlfrescoFolder *)folder 
                completionBlock:(AlfrescoArrayCompletionBlock)completionBlock 
{
    [AlfrescoErrors assertArgumentNotNil:folder argumentName:@"retrieveFoldersInFolder folder"];
    [AlfrescoErrors assertArgumentNotNil:folder.identifier argumentName:@"folder.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.cmisSession retrieveObject:folder.identifier completionBlock:^(CMISObject *cmisObject, NSError *error){
        if (nil == cmisObject)
        {
            completionBlock(nil, error);
        }
        else if (![cmisObject isKindOfClass:[CMISFolder class]])
        {
            NSError *classError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderWrongNodeType];
            completionBlock(nil, classError);
        }
        else
        {
            CMISFolder *folder = (CMISFolder *)cmisObject;
            [folder retrieveChildrenWithCompletionBlock:^(CMISPagedResult *pagedResult, NSError *error){
                if (nil == pagedResult)
                {
                    completionBlock(nil, error);
                }
                else
                {
                    NSArray *sortedFolders = nil;
                    NSArray *folders = [weakSelf retrieveItemsWithClassFilter:[AlfrescoFolder class] withArray:pagedResult.resultArray];
                    if (0 < folders.count)
                    {
                        sortedFolders = [AlfrescoSortingUtils sortedArrayForArray:folders sortKey:self.defaultSortKey ascending:YES];
                    }
                    else
                    {
                        sortedFolders = [NSArray array];
                    }
                    completionBlock(sortedFolders, nil);
                }
            }];
        }
    }];
}

- (void)retrieveFoldersInFolder:(AlfrescoFolder *)folder
                 listingContext:(AlfrescoListingContext *)listingContext
                completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock 
{
    [AlfrescoErrors assertArgumentNotNil:folder argumentName:@"retrieveFoldersInFolder folder"];
    [AlfrescoErrors assertArgumentNotNil:folder.identifier argumentName:@"folder.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.cmisSession retrieveObject:folder.identifier completionBlock:^(CMISObject *cmisObject, NSError *error){
        if (nil == cmisObject)
        {
            completionBlock(nil, error);
        }
        else if (![cmisObject isKindOfClass:[CMISFolder class]])
        {
            NSError *classError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderWrongNodeType];
            completionBlock(nil, classError);
        }
        else
        {
            CMISFolder *folder = (CMISFolder *)cmisObject;
            [folder retrieveChildrenWithCompletionBlock:^(CMISPagedResult *pagedResult, NSError *error){
                if (nil == pagedResult)
                {
                    completionBlock(nil, error);
                }
                else
                {
                    NSArray *sortedFolders = nil;
                    NSArray *folders = [weakSelf retrieveItemsWithClassFilter:[AlfrescoFolder class] withArray:pagedResult.resultArray];
                    if (0 < folders.count)
                    {
                        sortedFolders = [AlfrescoSortingUtils sortedArrayForArray:folders
                                                                          sortKey:listingContext.sortProperty
                                                                    supportedKeys:self.supportedSortKeys
                                                                       defaultKey:self.defaultSortKey
                                                                        ascending:listingContext.sortAscending];
                    }
                    else
                    {
                        sortedFolders = [NSArray array];
                    }
                    AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedFolders listingContext:listingContext];
                    completionBlock(pagingResult, nil);
                }
            }];
        }
    }];
}

- (void)retrieveNodeWithIdentifier:(NSString *)identifier
                completionBlock:(AlfrescoNodeCompletionBlock)completionBlock 
{
    [AlfrescoErrors assertArgumentNotNil:identifier argumentName:@"retrieveNodeWithIdentifier identifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.cmisSession retrieveObject:identifier completionBlock:^(CMISObject *cmisObject, NSError *error){
        if (nil == cmisObject)
        {
            completionBlock(nil, error);
        }
        else
        {
            AlfrescoNode *node = [weakSelf.objectConverter nodeFromCMISObject:cmisObject];
            NSError *conversionError = nil;
            if (nil == node)
            {
                conversionError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderFailedToConvertNode];
            }
            completionBlock(node, conversionError);
            
        }
    }];
}

- (void)retrieveNodeWithFolderPath:(NSString *)path 
                   completionBlock:(AlfrescoNodeCompletionBlock)completionBlock 
{
    [AlfrescoErrors assertArgumentNotNil:path argumentName:@"retrieveNodeWithFolderPath path"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.cmisSession retrieveObjectByPath:path completionBlock:^(CMISObject *cmisObject, NSError *error){
        if (nil == cmisObject)
        {
            completionBlock(nil, error);
        }
        else
        {
            AlfrescoNode *node = [weakSelf.objectConverter nodeFromCMISObject:cmisObject];
            NSError *conversionError = nil;
            if (nil == node)
            {
                conversionError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderFailedToConvertNode];
            }
            completionBlock(node, conversionError);
        }
    }];
}

- (void)retrieveNodeWithFolderPath:(NSString *)path relativeToFolder:(AlfrescoFolder *)folder 
                   completionBlock:(AlfrescoNodeCompletionBlock)completionBlock 
{
    [AlfrescoErrors assertArgumentNotNil:path argumentName:@"retrieveNodeWithFolderPath path"];
    [AlfrescoErrors assertArgumentNotNil:folder argumentName:@"folder"];
    [AlfrescoErrors assertArgumentNotNil:folder.identifier argumentName:@"folder.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.cmisSession retrieveObject:folder.identifier completionBlock:^(CMISObject *cmisObject, NSError *error){
        if (nil == cmisObject)
        {
            completionBlock(nil, error);
        }
        else
        {
            CMISFolder *folder = (CMISFolder *)cmisObject;
            NSString *searchPath = [NSString stringWithFormat:@"%@%@", folder.path, path];
            if (![folder.path hasSuffix:@"/"] && ![path hasPrefix:@"/"])
            {
                searchPath = [NSString stringWithFormat:@"%@/%@", folder.path, path];
            }
            [weakSelf retrieveNodeWithFolderPath:searchPath completionBlock:completionBlock];
        }
    }];    
}

- (void)retrieveParentFolderOfNode:(AlfrescoNode *)node
             completionBlock:(AlfrescoFolderCompletionBlock)completionBlock 
{
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"retrieveParentFolderOfNode node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentName:@"node.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.cmisSession.binding.navigationService
     retrieveParentsForObject:node.identifier
     withFilter:nil
     withIncludeRelationships:CMISIncludeRelationshipBoth
     withRenditionFilter:nil
     withIncludeAllowableActions:YES
     withIncludeRelativePathSegment:YES
     completionBlock:^(NSArray *parents, NSError *error){
         
         log(@"retrieveParentFolderOfNode::in completionBlock");
         if (nil == parents)
         {
             log(@"retrieveParentFolderOfNode::in completionBlock --> parents array is NIL");
             completionBlock(nil, error);
         }
         else
         {
             AlfrescoFolder *parentFolder = nil;
             log(@"retrieveParentFolderOfNode::in completionBlock --> parents array has %d elements", parents.count);
             NSError *folderError = nil;
             for (CMISObjectData * cmisObjectData in parents)
             {
                 AlfrescoNode *node = (AlfrescoNode *)[weakSelf.objectConverter nodeFromCMISObjectData:cmisObjectData];
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
    
}

- (void)retrieveRenditionOfNode:(AlfrescoNode *)node renditionName:(NSString *)renditionName
                completionBlock:(AlfrescoContentFileCompletionBlock)completionBlock
{
    
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"retrieveRenditionOfNode folder"];
    [AlfrescoErrors assertArgumentNotNil:renditionName argumentName:@"renditionName"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    CMISOperationContext *operationContext = [CMISOperationContext defaultOperationContext];
    operationContext.renditionFilterString = @"cmis:thumbnail";
    [self.cmisSession retrieveObject:node.identifier withOperationContext:operationContext completionBlock:^(CMISObject *cmisObject, NSError *error){
        if (nil == cmisObject)
        {
            completionBlock(nil, error);
        }
        else if([cmisObject isKindOfClass:[CMISFolder class]])
        {
            NSError *wrongTypeError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderNoThumbnail];
            completionBlock(nil, wrongTypeError);
        }
        else
        {
            NSError *renditionsError = nil;
            CMISDocument *document = (CMISDocument *)cmisObject;
            NSArray *renditions = document.renditions;
            if (nil == renditions)
            {
                renditionsError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderNoThumbnail];
                completionBlock(nil, renditionsError);
            }
            else if(0 == renditions.count)
            {
                renditionsError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderNoThumbnail];
                completionBlock(nil, renditionsError);
            }
            else
            {
                CMISRendition *thumbnailRendition = (CMISRendition *)[renditions objectAtIndex:0];
                log(@"************* NUMBER OF RENDITION OBJECTS FOUND IS %d and the document ID is %@",renditions.count, thumbnailRendition.renditionDocumentId);
                NSString *tmpFileName = [NSTemporaryDirectory() stringByAppendingFormat:@"%@.png",node.name];
                log(@"************* DOWNLOADING TO FILE %@",tmpFileName);
                [thumbnailRendition downloadRenditionContentToFile:tmpFileName completionBlock:^(NSError *downloadError){
                    if (downloadError)
                    {
                        completionBlock(nil, downloadError);
                    }
                    else
                    {
                        AlfrescoContentFile *contentFile = [[AlfrescoContentFile alloc] initWithUrl:[NSURL fileURLWithPath:tmpFileName] mimeType:@"image/png"];
                        completionBlock(contentFile, nil);
                    }
                } progressBlock:^(unsigned long long bytesDownloaded, unsigned long long bytesTotal){
                    log(@"************* PROGRESS DOWNLOADING FILE with %llu bytes downloaded from %llu total ",bytesDownloaded, bytesTotal);
                }];
            }
        }
    }];
    
}


- (void)retrieveContentOfDocument:(AlfrescoDocument *)document
                  completionBlock:(AlfrescoContentFileCompletionBlock)completionBlock
                    progressBlock:(AlfrescoProgressBlock)progressBlock
{
    [AlfrescoErrors assertArgumentNotNil:document argumentName:@"retrieveContentOfDocument document"];
    [AlfrescoErrors assertArgumentNotNil:document.identifier argumentName:@"document.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    NSString *tmpFile = [NSTemporaryDirectory() stringByAppendingFormat:@"%@",document.name];
    [self.cmisSession downloadContentOfCMISObject:document.identifier toFile:tmpFile completionBlock:^(NSError *error){
        if (error)
        {
            completionBlock(nil, error);
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
    
}

#pragma mark - Modification methods

- (void)updateContentOfDocument:(AlfrescoDocument *)document
                    contentFile:(AlfrescoContentFile *)file
                completionBlock:(AlfrescoDocumentCompletionBlock)completionBlock
                  progressBlock:(AlfrescoProgressBlock)progressBlock
{
    [AlfrescoErrors assertArgumentNotNil:file argumentName:@"updateContentOfDocument file"];
    [AlfrescoErrors assertArgumentNotNil:document argumentName:@"document"];
    [AlfrescoErrors assertArgumentNotNil:document.identifier argumentName:@"document.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    
    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.cmisSession retrieveObject:document.identifier completionBlock:^(CMISObject *cmisObject, NSError *error){
        if (nil == cmisObject)
        {
            completionBlock(nil, error);
        }
        else
        {
            CMISDocument *document = (CMISDocument *)cmisObject;
            [document changeContentToContentOfFile:[file.fileUrl path] withOverwriteExisting:YES completionBlock:^(NSError *error){
                if (error)
                {
                    completionBlock(nil, error);
                }
                else
                {
                    [weakSelf.cmisSession retrieveObject:document.identifier completionBlock:^(CMISObject *updatedObject, NSError *updatedError){
                        if (nil == updatedObject)
                        {
                            completionBlock(nil, updatedError);
                        }
                        else
                        {
                            AlfrescoDocument *alfrescoDocument = (AlfrescoDocument *)[weakSelf.objectConverter nodeFromCMISObject:updatedObject];
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
        
}


- (void)updatePropertiesOfNode:(AlfrescoNode *)node 
                properties:(NSDictionary *)properties
               completionBlock:(AlfrescoNodeCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:properties argumentName:@"updatePropertiesOfNode properties"];
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"updatePropertiesOfNode node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentName:@"node.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSMutableDictionary *cmisProperties = [NSMutableDictionary dictionaryWithDictionary:properties];
    if ([[properties allKeys] containsObject:kAlfrescoPropertyName])
    {
        NSString *name = [properties valueForKey:kAlfrescoPropertyName];
        log(@"updatePropertiesOfNode contains key %@ with value %@",kAlfrescoPropertyName, name );
        [cmisProperties setValue:name forKey:@"cmis:name"];
        [cmisProperties removeObjectForKey:kAlfrescoPropertyName];
    }
    
    if (![[cmisProperties allKeys] containsObject:@"cmis:name"])
    {
        log(@"updatePropertiesOfNode we do NOT have a cmis:name property. so let's set it now to the node name");
        [cmisProperties setValue:node.name forKey:@"cmis:name"];
    }
    
    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.cmisSession retrieveObject:node.identifier completionBlock:^(CMISObject *cmisObject, NSError *error){
        if (nil == cmisObject)
        {
            completionBlock(nil, error);
        }
        else
        {
            [cmisObject updateProperties:cmisProperties completionBlock:^(CMISObject *updatedObject, NSError *updateError){
                if (nil == updatedObject)
                {
                    completionBlock(nil, updateError);
                }
                else
                {
                    AlfrescoNode *resultNode = [weakSelf.objectConverter nodeFromCMISObject:updatedObject];
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

- (void)deleteNode:(AlfrescoNode *)node completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock 
{
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"deleteNode node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentName:@"node.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
       
    if ([node isKindOfClass:[AlfrescoDocument class]])
    {
        [self.cmisSession.binding.objectService deleteObject:node.identifier allVersions:YES completionBlock:^(BOOL objectDeleted, NSError *error){
            completionBlock(objectDeleted, error);
        }];
    }
    else
    {
        [self.cmisSession.binding.objectService deleteTree:node.identifier allVersion:YES unfileObjects:CMISDelete continueOnFailure:YES completionBlock:^(NSArray *failedObjects, NSError *error){
            if (error)
            {
                completionBlock(NO, error);
            }
            else
            {
                completionBlock(YES, nil);
            }
        }];
    }
        
}



#pragma mark - Internal methods


- (NSArray *)retrieveItemsWithClassFilter:(Class) typeClass withArray:(NSArray *)itemArray
{
    NSMutableArray *filteredArray = [NSMutableArray array];
    for (CMISObject *object in itemArray)
    {
        AlfrescoNode *childNode = [self.objectConverter nodeFromCMISObject:object];
        if ([childNode isKindOfClass:typeClass])
        {
            [filteredArray addObject:childNode];
        }
    }
    return filteredArray;
}

- (void)extractMetadataForNode:(AlfrescoNode *)node
{
    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        NSMutableDictionary *jsonDictionary = [NSMutableDictionary dictionary];
        
        NSArray *components = [node.identifier componentsSeparatedByString:@";"];
        NSString *identifier = node.identifier;
        if (components.count > 1)
        {
            identifier = [components objectAtIndex:0];
        }
        
        [jsonDictionary setValue:identifier forKey:kAlfrescoJSONActionedUponNode];
        [jsonDictionary setValue:kAlfrescoJSONExtractMetadata forKey:kAlfrescoJSONActionDefinitionName];
        NSError *postError = nil;
        NSURL *apiUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                              self.session.baseUrl,kAlfrescoOnPremiseMetadataExtractionAPI]];
        NSData *jsonData = [NSJSONSerialization 
                            dataWithJSONObject:jsonDictionary 
                            options:kNilOptions 
                            error:&postError];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
        log(@"jsonstring %@", jsonString);
        if (nil != jsonData)
        {
            [AlfrescoHTTPUtils executeRequestWithURL:apiUrl
                                             session:weakSelf.session
                                                data:jsonData
                                          httpMethod:@"POST"
                                               error:&postError];
        }
    }];    
}

- (void)generateThumbnailForNode:(AlfrescoNode *)node
{
    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        NSMutableDictionary *jsonDictionary = [NSMutableDictionary dictionary];
        [jsonDictionary setValue:kAlfrescoJSONThumbnailName forKey:kAlfrescoThumbnailRendition];
        NSError *postError = nil;
        NSString *requestString = [kAlfrescoOnPremiseThumbnailCreationAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef
                                                                                                    withString:[node.identifier stringByReplacingOccurrencesOfString:@"://"
                                                                                                                                                          withString:@"/"]];
        NSURL *apiUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.session.baseUrl, requestString]];
        
        NSData *jsonData = [NSJSONSerialization 
                            dataWithJSONObject:jsonDictionary 
                            options:kNilOptions 
                            error:&postError];
        if (nil != jsonData)
        {
            [AlfrescoHTTPUtils executeRequestWithURL:apiUrl
                                             session:weakSelf.session
                                                data:jsonData
                                          httpMethod:@"POST"
                                               error:&postError];
        }
    }];    
}



@end
