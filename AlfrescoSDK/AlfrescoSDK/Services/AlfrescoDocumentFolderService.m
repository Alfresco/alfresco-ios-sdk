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


@interface AlfrescoDocumentFolderService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) CMISSession *cmisSession;
@property (nonatomic, strong, readwrite) NSOperationQueue *operationQueue;
@property (nonatomic, strong, readwrite) AlfrescoObjectConverter *objectConverter;
@property (nonatomic, weak, readwrite) id<AlfrescoAuthenticationProvider> authenticationProvider;
@property (nonatomic, strong, readwrite) NSArray *supportedSortKeys;
@property (nonatomic, strong, readwrite) NSString *defaultSortKey;

// retrieve children of the folder that is retrieved using the provided objectId
- (NSArray *)cmisRetrieveChildren:(NSString *)objectId
                      withSession:(__weak AlfrescoDocumentFolderService *)weakSelf
                            error:(NSError **)error;

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
//        id authenticationObject = objc_getAssociatedObject(self.session, &kAlfrescoAuthenticationProviderObjectKey);
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
    [AlfrescoErrors assertArgumentNotNil:folder argumentName:@"folder"];
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
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *folderRef = [weakSelf.cmisSession createFolder:properties inFolder:folder.identifier error:&operationQueueError];
        if (nil != folderRef)
        {
            [weakSelf retrieveNodeWithIdentifier:folderRef completionBlock:^(AlfrescoNode *node, NSError *error) {
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completionBlock((AlfrescoFolder *)node, error);
                }];
                
            }];
        }
        else
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(nil, operationQueueError);
            }];
        }
    }];
}


- (void)createDocumentWithName:(NSString *)documentName inParentFolder:(AlfrescoFolder *)folder contentFile:(AlfrescoContentFile *)file 
                    properties:(NSDictionary *)properties 
                    completionBlock:(AlfrescoDocumentCompletionBlock)completionBlock
                    progressBlock:(AlfrescoProgressBlock)progressBlock
{
    [AlfrescoErrors assertArgumentNotNil:file argumentName:@"file"];
    [AlfrescoErrors assertArgumentNotNil:folder argumentName:@"folder"];
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
        objectTypeId = [kCMISPropertyObjectTypeIdValueDocument stringByAppendingString:@",P:cm:titled"];
        [properties setValue:objectTypeId forKey:kCMISPropertyObjectTypeId];
    }
    
    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        [weakSelf.cmisSession createDocumentFromFilePath:[file.fileUrl path]
                                            withMimeType:file.mimeType
                                          withProperties:properties
                                                inFolder:folder.identifier
                                         completionBlock:^(NSString *result) {
                [weakSelf retrieveNodeWithIdentifier:result completionBlock:^(AlfrescoNode *node, NSError *error) {
                    
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        completionBlock((AlfrescoDocument *)node, error);}];
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
            failureBlock:^(NSError *error){
             NSError *alfrescoError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolder];
             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                 completionBlock(nil, alfrescoError);
             }];
            }
            progressBlock:^(NSInteger bytesDownloaded, NSInteger bytesTotal) {
             if (progressBlock) 
             {
                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                     progressBlock(bytesDownloaded, bytesTotal);
                 }];
             }
         }];
        
    }];
}


#pragma mark - Retrieval methods
- (void)retrieveRootFolderWithCompletionBlock:(AlfrescoFolderCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        NSError *operationQueueError = nil;
        AlfrescoFolder *rootFolder = nil;
        CMISObject *retrievedObject = [weakSelf.cmisSession retrieveRootFolderAndReturnError:&operationQueueError];
        if (nil != retrievedObject) {
            if ([retrievedObject isKindOfClass:[CMISFolder class]]) 
            {
                rootFolder = (AlfrescoFolder *)[self.objectConverter nodeFromCMISObject:retrievedObject];
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(rootFolder, operationQueueError);
        }];        
    }];
}

- (void)retrievePermissionsOfNode:(AlfrescoNode *)node 
                  completionBlock:(AlfrescoPermissionsCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentName:@"node.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    [self retrieveNodeWithIdentifier:node.identifier completionBlock:^(AlfrescoNode *retrievedNode, NSError *error){
        if (nil == retrievedNode)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(nil, error);
            }];
        }
        else
        {
            id associatedObject = objc_getAssociatedObject(retrievedNode, &kAlfrescoPermissionsObjectKey);
            if ([associatedObject isKindOfClass:[AlfrescoPermissions class]])
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completionBlock((AlfrescoPermissions *)associatedObject, error);
                }];
            }
            else
            {
                error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderPermissions];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completionBlock(nil, error);
                }];
            }
        }
    }];
}


- (void)retrieveChildrenInFolder:(AlfrescoFolder *)folder 
                 completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:folder argumentName:@"folder"];
    [AlfrescoErrors assertArgumentNotNil:folder.identifier argumentName:@"folder.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSArray *childrenData = [weakSelf cmisRetrieveChildren:folder.identifier withSession:weakSelf error:&operationQueueError];
        NSArray *sortedChildren = nil;
        if (nil != childrenData) 
        {
            NSMutableArray *children = [NSMutableArray arrayWithCapacity:[childrenData count]];
            for (CMISObject *object in childrenData) 
            {
                [children addObject:[self.objectConverter nodeFromCMISObject:object]];
            }
            if (0 < children.count) 
            {
                sortedChildren = [AlfrescoSortingUtils sortedArrayForArray:children sortKey:self.defaultSortKey ascending:YES];
            }
            else 
            {
                sortedChildren = [NSArray array];
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(sortedChildren, operationQueueError);
        }];
    }];
}

- (void)retrieveChildrenInFolder:(AlfrescoFolder *)folder
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
    
    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        // TODO this is a temporary fix for the failing paging
        NSArray *childrenData = [weakSelf cmisRetrieveChildren:folder.identifier withSession:weakSelf error:&operationQueueError];
        AlfrescoPagingResult *pagingResult = nil;
        if (nil != childrenData) 
        {
            NSMutableArray *children = [NSMutableArray arrayWithCapacity:[childrenData count]];
            for (CMISObject *object in childrenData) 
            {
                [children addObject:[self.objectConverter nodeFromCMISObject:object]];
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
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(pagingResult, operationQueueError);
        }];            
        
    }];
}

- (void)retrieveDocumentsInFolder:(AlfrescoFolder *)folder 
                  completionBlock:(AlfrescoArrayCompletionBlock)completionBlock 
{
    [AlfrescoErrors assertArgumentNotNil:folder argumentName:@"folder"];
    [AlfrescoErrors assertArgumentNotNil:folder.identifier argumentName:@"folder.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{

        NSError *operationQueueError = nil;
        NSArray *sortedDocuments = nil;
        NSArray *childrenData = [weakSelf cmisRetrieveChildren:folder.identifier withSession:weakSelf error:&operationQueueError];
        if (nil != childrenData) 
        {
            NSArray *documents = [weakSelf retrieveItemsWithClassFilter:[AlfrescoDocument class] withArray:childrenData];
            if (0 < documents.count) 
            {
                sortedDocuments = [AlfrescoSortingUtils sortedArrayForArray:documents sortKey:self.defaultSortKey ascending:YES];
            }
            else 
            {
                sortedDocuments = [NSArray array];
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(sortedDocuments, operationQueueError);
        }];
    }];
}

- (void)retrieveDocumentsInFolder:(AlfrescoFolder *)folder
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
    
    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        AlfrescoPagingResult *pagingResult = nil;
        NSArray *childrenData = [weakSelf cmisRetrieveChildren:folder.identifier withSession:weakSelf error:&operationQueueError];
        if (nil != childrenData) 
        {
            NSArray *sortedDocuments = nil;
            NSArray *documents = [weakSelf retrieveItemsWithClassFilter:[AlfrescoDocument class] withArray:childrenData];
            if (0 < documents.count) 
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
            pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedDocuments listingContext:listingContext];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(pagingResult, operationQueueError);
        }];
    }];
}

- (void)retrieveFoldersInFolder:(AlfrescoFolder *)folder 
                completionBlock:(AlfrescoArrayCompletionBlock)completionBlock 
{
    [AlfrescoErrors assertArgumentNotNil:folder argumentName:@"folder"];
    [AlfrescoErrors assertArgumentNotNil:folder.identifier argumentName:@"folder.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{

        NSError *operationQueueError = nil;
        NSArray *sortedFolders = nil;
        NSArray *childrenData = [weakSelf cmisRetrieveChildren:folder.identifier withSession:weakSelf error:&operationQueueError];
        if (nil != childrenData) 
        {
            NSArray *folders = [weakSelf retrieveItemsWithClassFilter:[AlfrescoFolder class] withArray:childrenData];
            if (0 < folders.count) 
            {
                sortedFolders = [AlfrescoSortingUtils sortedArrayForArray:folders sortKey:self.defaultSortKey ascending:YES];
            }
            else 
            {
                sortedFolders = [NSArray array];
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(sortedFolders, operationQueueError);
        }];
    }];
}

- (void)retrieveFoldersInFolder:(AlfrescoFolder *)folder
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
    
    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSArray *sortedFolders = nil;
        NSArray *childrenData = [weakSelf cmisRetrieveChildren:folder.identifier withSession:weakSelf error:&operationQueueError];
        AlfrescoPagingResult *pagingResult = nil;
        if (nil != childrenData) 
        {
            NSArray *folders = [weakSelf retrieveItemsWithClassFilter:[AlfrescoFolder class] withArray:childrenData];
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
            pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedFolders listingContext:listingContext];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(pagingResult, operationQueueError);
        }];
    }];
}

- (void)retrieveNodeWithIdentifier:(NSString *)identifier
                completionBlock:(AlfrescoNodeCompletionBlock)completionBlock 
{
    [AlfrescoErrors assertArgumentNotNil:identifier argumentName:@"identifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        CMISObject *cmisObject = [weakSelf.cmisSession retrieveObject:identifier error:&operationQueueError];
        AlfrescoNode *alfrescoNode = nil;
        if (nil != cmisObject) 
        {
            alfrescoNode = [weakSelf.objectConverter nodeFromCMISObject:cmisObject];
            if (nil == alfrescoNode) 
            {
                operationQueueError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderFailedToConvertNode];
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(alfrescoNode, operationQueueError);
        }];
    }];
}

- (void)retrieveNodeWithFolderPath:(NSString *)path 
                   completionBlock:(AlfrescoNodeCompletionBlock)completionBlock 
{
    [AlfrescoErrors assertArgumentNotNil:path argumentName:@"path"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        CMISObject *cmisObject = [weakSelf.cmisSession retrieveObjectByPath:path error:&operationQueueError];
        AlfrescoNode *alfrescoNode = nil;
        if (nil != cmisObject) 
        {
            alfrescoNode = [weakSelf.objectConverter nodeFromCMISObject:cmisObject];
            if (nil == alfrescoNode) 
            {
                operationQueueError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderFailedToConvertNode];
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(alfrescoNode, operationQueueError);
        }];
    }];
}

- (void)retrieveNodeWithFolderPath:(NSString *)path relativeToFolder:(AlfrescoFolder *)folder 
                   completionBlock:(AlfrescoNodeCompletionBlock)completionBlock 
{
    [AlfrescoErrors assertArgumentNotNil:path argumentName:@"path"];
    [AlfrescoErrors assertArgumentNotNil:folder argumentName:@"folder"];
    [AlfrescoErrors assertArgumentNotNil:folder.identifier argumentName:@"folder.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        CMISObject *object = [weakSelf.cmisSession retrieveObject:folder.identifier error:&operationQueueError];
        if (nil != object) 
        {
            CMISFolder *folder = (CMISFolder *)object;
            NSString *searchPath = [NSString stringWithFormat:@"%@%@", folder.path, path];
            [weakSelf retrieveNodeWithFolderPath:searchPath completionBlock:completionBlock];
        }
        else 
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(nil, operationQueueError);
            }];
        }        
    }];
}

- (void)retrieveParentFolderOfNode:(AlfrescoNode *)node
             completionBlock:(AlfrescoFolderCompletionBlock)completionBlock 
{
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentName:@"node.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSArray *parentArray = [weakSelf.cmisSession.binding.navigationService retrieveParentsForObject:node.identifier withFilter:nil withIncludeRelationships:CMISIncludeRelationshipBoth withRenditionFilter:nil withIncludeAllowableActions:YES withIncludeRelativePathSegment:YES error:&operationQueueError];

        AlfrescoFolder *folder = nil;
        if (nil != parentArray)
        {
            for (CMISObjectData *cmisData in parentArray) {
                AlfrescoNode *alfNode = [weakSelf.objectConverter nodeFromCMISObjectData:cmisData];
                if([alfNode isKindOfClass:AlfrescoFolder.class])
                {
                    folder = (AlfrescoFolder *)alfNode;
                    break;
                }
            }
            if (nil == folder) 
            {
                operationQueueError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderNoParent];
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(folder, operationQueueError);
        }];
    }];
}

- (void)retrieveRenditionOfNode:(AlfrescoNode *)node renditionName:(NSString *)renditionName
                completionBlock:(AlfrescoContentFileCompletionBlock)completionBlock
{
    
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"folder"];
    [AlfrescoErrors assertArgumentNotNil:renditionName argumentName:@"renditionName"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        CMISOperationContext *operationContext = [CMISOperationContext defaultOperationContext];
        operationContext.renditionFilterString = @"cmis:thumbnail";
        __block CMISDocument *document = (CMISDocument *)[weakSelf.cmisSession  retrieveObject:node.identifier
                                                                  withOperationContext:operationContext
                                                                                 error:&operationQueueError];

        if (nil != document)
        {
            NSArray *renditions = document.renditions;
            if (nil == renditions)
            {
                operationQueueError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderNoThumbnail];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completionBlock(nil, operationQueueError);
                }];
            }
            else if( 0 == renditions.count)
            {
                operationQueueError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderNoThumbnail];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completionBlock(nil, operationQueueError);
                }];
            }
            else
            {
                CMISRendition *thumbnailRendition = (CMISRendition *)[renditions objectAtIndex:0];
                log(@"************* NUMBER OF RENDITION OBJECTS FOUND IS %d and the document ID is %@",renditions.count, thumbnailRendition.renditionDocumentId);
                NSString *tmpFileName = [NSTemporaryDirectory() stringByAppendingFormat:@"%@.png",node.name];
                log(@"************* DOWNLOADING TO FILE %@",tmpFileName);
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [thumbnailRendition downloadRenditionContentToFile:tmpFileName completionBlock:^{
                        log(@"************* DOWNLOADED FILE TO TEMPORARY FOLDER/FILE %@",tmpFileName);
                        AlfrescoContentFile *contentFile = [[AlfrescoContentFile alloc] initWithFilePath:tmpFileName mimeType:@"image/png"];
                        //                    NSError *operationQueueError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeDocumentFolderNoThumbnail];
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            completionBlock(contentFile, nil);
                        }];
                        
                    } failureBlock:^(NSError *error){
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            completionBlock(nil, error);
                        }];
                        
                    } progressBlock:^(NSInteger bytesDownloaded, NSInteger bytesTotal){
                        log(@"************* PROGRESS DOWNLOADING FILE with %d bytes downloaded from %d total ",bytesDownloaded, bytesTotal);
                    }];
                }];
                
                
             }
        }
        else
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(nil, operationQueueError);
            }];            
        }
    }];
/*
        NSString *renditionString = [kAlfrescoOnPremiseThumbnailRenditionAPI stringByReplacingOccurrencesOfString:kAlfrescoRenditionId withString:renditionName];
        NSString *requestString = [renditionString stringByReplacingOccurrencesOfString:kAlfrescoNodeRef
                                                                             withString:[node.identifier stringByReplacingOccurrencesOfString:@"://"
                                                                                                                                   withString:@"/"]];
        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                         baseUrlAsString:kAlfrescoOnPremiseAPIPath
                                  authenticationProvider:weakSelf.authenticationProvider
                                                   error:&operationQueueError];
//        AlfrescoContentFile *thumbnailFile = nil;
        if (nil != data)
        {
            thumbnailFile = [[AlfrescoContentFile alloc] initWithData:data mimeType:kAlfrescoDefaultMimeType];
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(thumbnailFile, operationQueueError);
        }];
 */

}


- (void)retrieveContentOfDocument:(AlfrescoDocument *)document
                  completionBlock:(AlfrescoContentFileCompletionBlock)completionBlock
                    progressBlock:(AlfrescoProgressBlock)progressBlock
{
    [AlfrescoErrors assertArgumentNotNil:document argumentName:@"document"];
    [AlfrescoErrors assertArgumentNotNil:document.identifier argumentName:@"document.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    NSString *tmpFile = [NSTemporaryDirectory() stringByAppendingFormat:@"%@",document.name];
    [self.cmisSession downloadContentOfCMISObject:document.identifier toFile:tmpFile completionBlock:^{
        log(@"Document name is '%@' and we'll download to %@",document.name, tmpFile);
        AlfrescoContentFile *downloadedFile = [[AlfrescoContentFile alloc]initWithUrl:[NSURL fileURLWithPath:tmpFile]];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(downloadedFile, nil);
        }];
        
    } failureBlock:^(NSError *operationQueueError) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(nil, operationQueueError);
        }];
        
    } progressBlock:^(NSInteger bytesDownloaded, NSInteger bytesTotal) {
        if (progressBlock)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                progressBlock(bytesDownloaded, bytesTotal);
            }];
        }
    }];
    
    
    
}

#pragma mark - Modification methods

- (void)updateContentOfDocument:(AlfrescoDocument *)document
                    contentFile:(AlfrescoContentFile *)file
                completionBlock:(AlfrescoDocumentCompletionBlock)completionBlock
                  progressBlock:(AlfrescoProgressBlock)progressBlock
{
    [AlfrescoErrors assertArgumentNotNil:file argumentName:@"file"];
    [AlfrescoErrors assertArgumentNotNil:document argumentName:@"document"];
    [AlfrescoErrors assertArgumentNotNil:document.identifier argumentName:@"document.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    
    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        CMISDocument *cmisDocument = (CMISDocument *) [weakSelf.cmisSession retrieveObject:document.identifier error:&operationQueueError];
        if(cmisDocument != nil && cmisDocument.identifier != nil)
        {
            [cmisDocument changeContentToContentOfFile:[file.fileUrl path] withOverwriteExisting:YES completionBlock:^{
                
                NSError *anotherError = nil;
                AlfrescoDocument *resultDocument = nil;
                CMISDocument *resultCmisDocument = (CMISDocument *) [weakSelf.cmisSession retrieveObject:cmisDocument.identifier error:&anotherError];
                if(!anotherError)
                {
                    resultDocument = (AlfrescoDocument *)[weakSelf.objectConverter nodeFromCMISObject:resultCmisDocument];
                    if (nil == resultDocument)
                    {
                        anotherError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderFailedToConvertNode];
                    }
                }
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completionBlock(resultDocument, anotherError);
                }];
                
            }
                                          failureBlock:^(NSError *error) {
                                              [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                  completionBlock(nil, error);
                                              }];
                                          } progressBlock:^(NSInteger bytesDownloaded, NSInteger bytesTotal) {
                                              if(progressBlock)
                                              {
                                                  [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                      progressBlock(bytesDownloaded, bytesTotal);
                                                  }];
                                              }
                                          }];
        }
        else
        {
            operationQueueError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeRequestedNodeNotFound];
        }
        
        if(nil != operationQueueError)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(nil, operationQueueError);
            }];
        }
    }];
    
}


- (void)updatePropertiesOfNode:(AlfrescoNode *)node 
                properties:(NSDictionary *)properties
               completionBlock:(AlfrescoNodeCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:properties argumentName:@"properties"];
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentName:@"node.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSMutableDictionary *cmisProperties = [NSMutableDictionary dictionaryWithDictionary:properties];
    if ([[properties allKeys] containsObject:kAlfrescoPropertyName])
    {
        NSString *name = [properties valueForKey:kAlfrescoPropertyName];
        [cmisProperties setValue:name forKey:@"cmis:name"];
        [cmisProperties removeObjectForKey:kAlfrescoPropertyName];
        properties = cmisProperties;
    }
    
    
    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        CMISObject *cmisObject = [weakSelf.cmisSession retrieveObject:node.identifier error:&operationQueueError];
        
        if(nil != cmisObject && nil != cmisObject.identifier)
        {
            [cmisObject updateProperties:properties error:&operationQueueError];
            AlfrescoNode *resultNode = nil;
            CMISObject *resultCmisObject = [weakSelf.cmisSession retrieveObject:cmisObject.identifier error:&operationQueueError];
            if (nil != resultCmisObject)
            {
                resultNode = [weakSelf.objectConverter nodeFromCMISObject:resultCmisObject];
                if (nil == resultNode)
                {
                    operationQueueError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderFailedToConvertNode];
                }
            }
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(resultNode, operationQueueError);
            }];
        }
        else
        {
            operationQueueError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeRequestedNodeNotFound];
        }
        
        if(operationQueueError)
        {
            if(completionBlock)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completionBlock(nil, operationQueueError);
                }];
            }
        }
    }];
}

- (void)deleteNode:(AlfrescoNode *)node completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock 
{
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentName:@"node.identifer"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
       
    __weak AlfrescoDocumentFolderService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        BOOL deletedSuccessfully = [weakSelf.cmisSession.binding.objectService deleteObject:node.identifier allVersions:YES error:&operationQueueError];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(deletedSuccessfully, operationQueueError);
        }];
    }];
}

#pragma mark - Internal methods

- (NSArray *)cmisRetrieveChildren:(NSString *)objectId
                      withSession:(__weak AlfrescoDocumentFolderService *)weakSelf
                            error:(NSError **)error
{
    CMISObject *object = [self.cmisSession retrieveObject:objectId error:error];
    if (nil == object) 
    {
        return nil;
    }
    if (![object isKindOfClass:[CMISFolder class]])
    {
        if (nil == *error)
        {
            *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderWrongNodeType];
        }
        else
        {
            NSError *underlyingError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderWrongNodeType];
            *error = [AlfrescoErrors alfrescoErrorWithUnderlyingError:underlyingError andAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolder];
            
        }
        return nil;
    }
    CMISFolder *folder = (CMISFolder *)object;
    CMISPagedResult *result = [folder retrieveChildrenAndReturnError:error];
    if (nil == result)
    {
        return nil;
    }
    log(@"***** AlfrescoDocumentFolderService::cmisRetrieveChildren - the number of returned CMIS objects is %d",result.resultArray.count);
    return (NSArray *)result.resultArray;
}

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
        [jsonDictionary setValue:node.identifier forKey:kAlfrescoJSONActionedUponNode];
        [jsonDictionary setValue:kAlfrescoJSONExtractMetadata forKey:kAlfrescoJSONActionDefinitionName];
        NSError *postError = nil;
        NSURL *apiUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                              self.session.baseUrl,kAlfrescoOnPremiseMetadataExtractionAPI]];
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
