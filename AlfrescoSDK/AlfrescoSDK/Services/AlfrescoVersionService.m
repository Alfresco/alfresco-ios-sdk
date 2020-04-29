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

#import "AlfrescoVersionService.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoCMISToAlfrescoObjectConverter.h"
#import "AlfrescoPagingUtils.h"
#import "AlfrescoSortingUtils.h"
#import "AlfrescoCMISUtil.h"
#import "CMISVersioningService.h"
#import "CMISDocument.h"
#import "CMISSession.h"
#import "CMISOperationContext.h"
#import "CMISPagedResult.h"

@interface AlfrescoVersionService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) CMISSession *cmisSession;
@property (nonatomic, strong, readwrite) AlfrescoCMISToAlfrescoObjectConverter *objectConverter;
@property (nonatomic, strong, readwrite) NSArray *supportedSortKeys;
@property (nonatomic, strong, readwrite) NSString *defaultSortKey;

@end

@implementation AlfrescoVersionService

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
        self.defaultSortKey = kAlfrescoSortByName;
        self.supportedSortKeys = @[kAlfrescoSortByName, kAlfrescoSortByTitle, kAlfrescoSortByDescription, kAlfrescoSortByCreatedAt, kAlfrescoSortByModifiedAt];
    }
    return self;
}


- (AlfrescoRequest *)retrieveAllVersionsOfDocument:(AlfrescoDocument *)document
                      completionBlock:(AlfrescoArrayCompletionBlock)completionBlock 
{
    [AlfrescoErrors assertArgumentNotNil:document argumentName:@"document"];
    [AlfrescoErrors assertArgumentNotNil:document.identifier argumentName:@"document.identifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    request.httpRequest = [self.cmisSession.binding.versioningService
                           retrieveAllVersions:document.identifier
                           filter:nil
                           includeAllowableActions:YES
                           completionBlock:^(NSArray *allVersions, NSError *error){
         if (nil == allVersions)
         {
             NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:error];
             completionBlock(nil, alfrescoError);
         }
         else
         {
             NSMutableArray *alfrescoVersions = [NSMutableArray array];
             for (CMISObjectData *cmisData in allVersions)
             {
                 AlfrescoNode *alfrescoNode = [self.objectConverter nodeFromCMISObjectData:cmisData];
                 [alfrescoVersions addObject:alfrescoNode];
             }
             NSArray *sortedAlfrescoVersionArray = [AlfrescoSortingUtils sortedArrayForArray:alfrescoVersions sortKey:self.defaultSortKey ascending:YES];
             completionBlock(sortedAlfrescoVersionArray, nil);
             
         }
     }];
    return request;
}

- (AlfrescoRequest *)retrieveAllVersionsOfDocument:(AlfrescoDocument *)document
                       listingContext:(AlfrescoListingContext *)listingContext
                      completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:document argumentName:@"document"];
    [AlfrescoErrors assertArgumentNotNil:document.identifier argumentName:@"document.identifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    request.httpRequest = [self.cmisSession.binding.versioningService
                           retrieveAllVersions:document.identifier
                           filter:nil
                           includeAllowableActions:YES
                           completionBlock:^(NSArray *allVersions, NSError *error){
         if (nil == allVersions)
         {
             NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:error];
             completionBlock(nil, alfrescoError);
         }
         else
         {
             NSMutableArray *alfrescoVersions = [NSMutableArray array];
             for (CMISObjectData *cmisData in allVersions)
             {
                 AlfrescoNode *alfrescoNode = [self.objectConverter nodeFromCMISObjectData:cmisData];
                 [alfrescoVersions addObject:alfrescoNode];
             }
             NSArray *sortedVersionArray = [AlfrescoSortingUtils sortedArrayForArray:alfrescoVersions
                                                                             sortKey:listingContext.sortProperty
                                                                       supportedKeys:self.supportedSortKeys
                                                                          defaultKey:self.defaultSortKey
                                                                           ascending:listingContext.sortAscending];
             AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedVersionArray listingContext:listingContext];
             completionBlock(pagingResult, nil);
             
         }
     }];
    return request;
}

- (AlfrescoRequest *)retrieveLatestVersionOfDocument:(AlfrescoDocument *)document
                                     completionBlock:(AlfrescoDocumentCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:document argumentName:@"document"];
    [AlfrescoErrors assertArgumentNotNil:document.identifier argumentName:@"document.identifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    CMISOperationContext *operationContext = [CMISOperationContext defaultOperationContext];
    request.httpRequest = [self.cmisSession.binding.versioningService retrieveObjectOfLatestVersion:document.identifier
                                                                                              major:NO
                                                                                             filter:operationContext.filterString
                                                                                      relationships:operationContext.relationships
                                                                                   includePolicyIds:operationContext.includePolicies
                                                                                    renditionFilter:operationContext.renditionFilterString
                                                                                         includeACL:operationContext.includeACLs
                                                                            includeAllowableActions:operationContext.includeAllowableActions
                                                                                    completionBlock:^(CMISObjectData *objectData, NSError *error) {
        if (nil == objectData)
        {
            NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:error];
            completionBlock(nil, alfrescoError);
        }
        else
        {
            AlfrescoDocument *alfrescoDocument = (AlfrescoDocument *)[self.objectConverter nodeFromCMISObjectData:objectData];
            completionBlock(alfrescoDocument, nil);
        }
    }];
    return request;
}

- (AlfrescoRequest *)checkoutDocument:(AlfrescoDocument *)document
                      completionBlock:(AlfrescoDocumentCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:document argumentName:@"document"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    // make sure the version identifier is stripped if present
    NSString *versionFreeIdentifier = [AlfrescoObjectConverter nodeRefWithoutVersionID:document.identifier];
    
    AlfrescoRequest *request = [AlfrescoRequest new];
    request.httpRequest = [self.cmisSession.binding.versioningService checkOut:versionFreeIdentifier completionBlock:^(CMISObjectData *objectData, NSError *error) {
        if (objectData == nil)
        {
            completionBlock(nil, [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeVersion]);
        }
        else
        {
            AlfrescoDocument *checkedOutNode = (AlfrescoDocument *)[self.objectConverter nodeFromCMISObjectData:objectData];
            NSError *conversionError = nil;
            if (checkedOutNode == nil)
            {
                conversionError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderFailedToConvertNode];
            }
            completionBlock(checkedOutNode, conversionError);
        }
    }];
    
    return request;
}


- (AlfrescoRequest *)cancelCheckoutOfDocument:(AlfrescoDocument *)document
                              completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:document argumentName:@"document"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    AlfrescoRequest *request = [AlfrescoRequest new];
    request.httpRequest = [self.cmisSession.binding.versioningService cancelCheckOut:document.identifier
                                                                     completionBlock:^(BOOL checkOutCancelled, NSError *error) {
        if (!checkOutCancelled)
        {
            completionBlock(NO, [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeVersion]);
        }
        else
        {
            completionBlock(checkOutCancelled, error);
        }
    }];
    
    return request;
}


- (AlfrescoRequest *)checkinDocument:(AlfrescoDocument *)document
                      asMajorVersion:(BOOL)majorVersion
                         contentFile:(AlfrescoContentFile *)file
                          properties:(NSDictionary *)properties
                             comment:(NSString *)comment
                     completionBlock:(AlfrescoDocumentCompletionBlock)completionBlock
                       progressBlock:(AlfrescoProgressBlock)progressBlock
{
    [AlfrescoErrors assertArgumentNotNil:document argumentName:@"document"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    // define completion block to perform the checkin
    CMISRequest* (^checkin)(CMISProperties *cmisProperties) = ^CMISRequest*(CMISProperties *cmisProperties) {
        return [self.cmisSession.binding.versioningService checkIn:document.identifier asMajorVersion:majorVersion
                                                          filePath:[file.fileUrl path] mimeType:file.mimeType
                                                        properties:cmisProperties checkinComment:comment
                                                   completionBlock:^(CMISObjectData *objectData, NSError *error) {
            if (objectData == nil)
            {
                completionBlock(nil, [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeVersion]);
            }
            else
            {
                // The CMISObjectData object is not fully populated so we need to retrieve the object
                [self.cmisSession retrieveObject:objectData.identifier completionBlock:^(CMISObject *object, NSError *error) {
                    if (object == nil)
                    {
                        completionBlock(nil, [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeVersion]);
                    }
                    else
                    {
                        AlfrescoDocument *checkedInNode = (AlfrescoDocument *)[self.objectConverter nodeFromCMISObject:object];
                        NSError *conversionError = nil;
                        if (checkedInNode == nil)
                        {
                            conversionError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderFailedToConvertNode];
                        }
                        completionBlock(checkedInNode, conversionError);
                    }
                }];
            }
        } progressBlock:^(unsigned long long bytesUploaded, unsigned long long bytesTotal) {
            if (progressBlock)
            {
                progressBlock(bytesUploaded, bytesTotal);
            }
        }];
    };
    
    AlfrescoRequest *request = [AlfrescoRequest new];
    if (properties != nil)
    {
        [AlfrescoCMISUtil preparePropertiesForUpdate:properties
                                             aspects:nil
                                                node:document
                                         cmisSession:self.cmisSession
                                     completionBlock:^(CMISProperties *cmisProperties, NSError *error) {
            if (cmisProperties != nil)
            {
                request.httpRequest = checkin(cmisProperties);
            }
            else
            {
                completionBlock(nil, error);
            }
        }];
    }
    else
    {
        request.httpRequest = checkin(nil);
    }
    
    return request;
}


- (AlfrescoRequest *)checkinDocument:(AlfrescoDocument *)document
                      asMajorVersion:(BOOL)majorVersion
                       contentStream:(AlfrescoContentStream *)contentStream
                          properties:(NSDictionary *)properties
                             comment:(NSString *)comment
                     completionBlock:(AlfrescoDocumentCompletionBlock)completionBlock
                       progressBlock:(AlfrescoProgressBlock)progressBlock
{
    [AlfrescoErrors assertArgumentNotNil:document argumentName:@"document"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    // define completion block to perform the checkin
    CMISRequest* (^checkin)(CMISProperties *cmisProperties) = ^CMISRequest*(CMISProperties *cmisProperties) {
        return [self.cmisSession.binding.versioningService checkIn:document.identifier asMajorVersion:majorVersion
                                                                      inputStream:contentStream.inputStream bytesExpected:contentStream.length
                                                                         mimeType:contentStream.mimeType properties:cmisProperties checkinComment:comment
                                                                  completionBlock:^(CMISObjectData *objectData, NSError *error) {
            if (objectData == nil)
            {
                completionBlock(nil, [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeVersion]);
            }
            else
            {
                // The CMISObjectData object is not fully populated so we need to retrieve the object
                [self.cmisSession retrieveObject:objectData.identifier completionBlock:^(CMISObject *object, NSError *error) {
                    if (object == nil)
                    {
                        completionBlock(nil, [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeVersion]);
                    }
                    else
                    {
                        AlfrescoDocument *checkedInNode = (AlfrescoDocument *)[self.objectConverter nodeFromCMISObject:object];
                        NSError *conversionError = nil;
                        if (checkedInNode == nil)
                        {
                            conversionError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeDocumentFolderFailedToConvertNode];
                        }
                        completionBlock(checkedInNode, conversionError);
                    }
                }];
            }
        } progressBlock:^(unsigned long long bytesUploaded, unsigned long long bytesTotal) {
            if (progressBlock)
            {
                progressBlock(bytesUploaded, bytesTotal);
            }
        }];
    };
    
    AlfrescoRequest *request = [AlfrescoRequest new];
    if (properties != nil)
    {
        [AlfrescoCMISUtil preparePropertiesForUpdate:properties
                                             aspects:nil
                                                node:document
                                         cmisSession:self.cmisSession
                                     completionBlock:^(CMISProperties *cmisProperties, NSError *error) {
            if (cmisProperties != nil)
            {
                request.httpRequest = checkin(cmisProperties);
            }
            else
            {
                completionBlock(nil, error);
            }
        }];
    }
    else
    {
        request.httpRequest = checkin(nil);
    }
    
    return request;
}

- (AlfrescoRequest *)retrieveCheckedOutDocumentsWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:-1];
    return [self retrieveCheckedOutDocumentsWithListingContext:listingContext
                                               completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
        completionBlock(pagingResult.objects, error);
    }];
}


- (AlfrescoRequest *)retrieveCheckedOutDocumentsWithListingContext:(AlfrescoListingContext *)listingContext
                                                   completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    
    CMISOperationContext *opContext = [CMISOperationContext defaultOperationContext];
    if (listingContext.maxItems > 0)
    {
        opContext.maxItemsPerPage = listingContext.maxItems;
        opContext.skipCount = listingContext.skipCount;
    }
    
    request.httpRequest = [self.cmisSession retrieveCheckedOutDocumentsWithOperationContext:opContext completionBlock:^(CMISPagedResult *pagedResult, NSError *error) {
        if (nil == pagedResult)
        {
            NSError *alfrescoError = [AlfrescoCMISUtil alfrescoErrorWithCMISError:error];
            completionBlock(nil, alfrescoError);
        }
        else
        {
            AlfrescoPagingResult *pagingResult = nil;
            NSMutableArray *children = [NSMutableArray array];
            for (CMISObject *node in pagedResult.resultArray)
            {
                [children addObject:[self.objectConverter nodeFromCMISObject:node]];
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
                sortedChildren = @[];
            }
            pagingResult = [[AlfrescoPagingResult alloc] initWithArray:sortedChildren hasMoreItems:pagedResult.hasMoreItems totalItems:(int)pagedResult.numItems];
            completionBlock(pagingResult, nil);
        }
    }];
    
    return request;
}

@end
