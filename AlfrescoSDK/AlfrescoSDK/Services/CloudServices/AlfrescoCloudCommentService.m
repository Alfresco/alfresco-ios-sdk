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

#import "AlfrescoCloudCommentService.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoBasicAuthenticationProvider.h"
#import "AlfrescoErrors.h"
#import "AlfrescoHTTPUtils.h"
#import "AlfrescoPagingUtils.h"
#import "AlfrescoISO8601DateFormatter.h"
#import "AlfrescoSortingUtils.h"
#import <objc/runtime.h>

@interface AlfrescoCloudCommentService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, strong, readwrite) NSOperationQueue *operationQueue;
@property (nonatomic, strong, readwrite) AlfrescoObjectConverter *objectConverter;
@property (nonatomic, weak, readwrite) id<AlfrescoAuthenticationProvider> authenticationProvider;
@property (nonatomic, strong)AlfrescoISO8601DateFormatter *dateFormatter;

- (NSArray *) parseCommentArrayWithData:(NSData *)data error:(NSError **)outError;
- (AlfrescoComment *) parseCommentDictWithData:(NSData *)data error:(NSError **)outError;
- (AlfrescoComment *)commentFromJSON:(NSDictionary *)commentDict;
@end

@implementation AlfrescoCloudCommentService
@synthesize baseApiUrl = _baseApiUrl;
@synthesize session = _session;
@synthesize operationQueue = _operationQueue;
@synthesize objectConverter = _objectConverter;
@synthesize authenticationProvider = _authenticationProvider;
@synthesize dateFormatter = _dateFormatter;

- (id)initWithSession:(id<AlfrescoSession>)session
{
    if (self = [super init])
    {
        self.session = session;
        self.baseApiUrl = [[self.session.baseUrl absoluteString] stringByAppendingString:kAlfrescoCloudAPIPath];
        self.objectConverter = [[AlfrescoObjectConverter alloc] initWithSession:self.session];
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 2;
        id authenticationObject = objc_getAssociatedObject(self.session, &kAlfrescoAuthenticationProviderObjectKey);
        self.authenticationProvider = nil;
        if ([authenticationObject isKindOfClass:[AlfrescoBasicAuthenticationProvider class]])
        {
            self.authenticationProvider = (AlfrescoBasicAuthenticationProvider *)authenticationObject;
        }
        self.dateFormatter = [[AlfrescoISO8601DateFormatter alloc] init];
    }
    return self;
}

- (void)retrieveCommentsForNode:(AlfrescoNode *)node completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:node assertMessage:@"node must not be nil" isOptional:NO];
    [AlfrescoErrors assertArgumentNotNil:completionBlock assertMessage:@"completionBlock must not be nil" isOptional:NO];
    [AlfrescoErrors assertArgumentNotNil:node.identifier assertMessage:@"node.identifier must not be nil" isOptional:NO];
    
    __weak AlfrescoCloudCommentService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *requestString = [kAlfrescoCloudCommentsAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef
                                                                                       withString:[node.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"]];
        
        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                         baseUrlAsString:weakSelf.baseApiUrl
                                  authenticationProvider:weakSelf.authenticationProvider
                                                   error:&operationQueueError];
        
        
        NSArray *sortedCommentArray = nil;
        if(nil != data)
        {
            NSArray *commentArray = [weakSelf parseCommentArrayWithData:data error:&operationQueueError];
            sortedCommentArray = [AlfrescoSortingUtils sortedArrayForArray:commentArray sortKey:kAlfrescoSortByCreatedAt ascending:YES];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(sortedCommentArray, operationQueueError);
        }];
    }];
}

- (void)retrieveCommentsForNode:(AlfrescoNode *)node
                 listingContext:(AlfrescoListingContext *)listingContext
                completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:node assertMessage:@"node must not be nil" isOptional:NO];
    [AlfrescoErrors assertArgumentNotNil:completionBlock assertMessage:@"completionBlock must not be nil" isOptional:NO];
    [AlfrescoErrors assertArgumentNotNil:node.identifier assertMessage:@"node.identifier must not be nil" isOptional:NO];
    [AlfrescoErrors assertArgumentNotNil:listingContext assertMessage:@"listingContext should not be nil" isOptional:YES];
    
    __weak AlfrescoCloudCommentService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        
        NSString *requestString = [kAlfrescoCloudCommentsAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef
                                                                                       withString:[node.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"]];
        
        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                         baseUrlAsString:weakSelf.baseApiUrl
                                  authenticationProvider:weakSelf.authenticationProvider
                                                   error:&operationQueueError];
        
        AlfrescoPagingResult *pagingResult = nil;
        if(nil != data)
        {
            NSArray *commentArray = [weakSelf parseCommentArrayWithData:data error:&operationQueueError];
            if (nil != commentArray)
            {
                NSArray *sortedArray = [AlfrescoSortingUtils sortedArrayForArray:commentArray sortKey:kAlfrescoSortByCreatedAt ascending:listingContext.sortAscending];
                pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedArray listingContext:listingContext];
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(pagingResult, operationQueueError);
        }];
    }];
}

- (void)addCommentToNode:(AlfrescoNode *)node content:(NSString *)content
                   title:(NSString *)title completionBlock:(AlfrescoCommentCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:node assertMessage:@"node must not be nil" isOptional:NO];
    [AlfrescoErrors assertArgumentNotNil:completionBlock assertMessage:@"completionBlock must not be nil" isOptional:NO];
    [AlfrescoErrors assertArgumentNotNil:node.identifier assertMessage:@"node.identifier must not be nil" isOptional:NO];
    
    __weak AlfrescoCloudCommentService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        
        NSMutableDictionary *commentDict = [NSMutableDictionary dictionary];
        [commentDict setValue:content forKey:kAlfrescoJSONContent];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:commentDict options:kNilOptions error:&operationQueueError];
        
        NSString *requestString = [kAlfrescoCloudCommentsAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef
                                                                                       withString:[node.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"]];
        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                         baseUrlAsString:weakSelf.baseApiUrl
                                  authenticationProvider:weakSelf.authenticationProvider
                                                    data:jsonData httpMethod:@"POST"
                                                   error:&operationQueueError];
        
        
        AlfrescoComment *comment = nil;
        if(nil != data)
        {
            comment = [weakSelf parseCommentDictWithData:data error:&operationQueueError];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(comment, operationQueueError);
        }];
    }];
}

- (void)updateCommentOnNode:(AlfrescoNode *)node
                    comment:(AlfrescoComment *)comment
                    content:(NSString *)content
            completionBlock:(AlfrescoCommentCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:node assertMessage:@"node must not be nil" isOptional:NO];
    [AlfrescoErrors assertArgumentNotNil:completionBlock assertMessage:@"completionBlock must not be nil" isOptional:NO];
    [AlfrescoErrors assertArgumentNotNil:node.identifier assertMessage:@"node.identifier must not be nil" isOptional:NO];
    [AlfrescoErrors assertArgumentNotNil:comment assertMessage:@"comment must not be nil" isOptional:NO];
    [AlfrescoErrors assertArgumentNotNil:comment.identifier assertMessage:@"comment.identifier must not be nil" isOptional:NO];

    __weak AlfrescoCloudCommentService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        
        NSMutableDictionary *commentDict = [NSMutableDictionary dictionary];
        [commentDict setValue:content forKey:kAlfrescoJSONContent];        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:commentDict options:kNilOptions error:&operationQueueError];
        NSString *nodeRefString = [kAlfrescoCloudCommentForNodeAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef
                                                                                             withString:[node.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"]];
        NSString *requestString = [nodeRefString stringByReplacingOccurrencesOfString:kAlfrescoCommentId
                                                                           withString:[comment.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"]];
        
        
        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                         baseUrlAsString:weakSelf.baseApiUrl
                                  authenticationProvider:weakSelf.authenticationProvider
                                                    data:jsonData
                                              httpMethod:@"PUT"
                                                   error:&operationQueueError];
        
        
        AlfrescoComment *comment = nil;
        if(nil != data)
        {
            comment = [weakSelf parseCommentDictWithData:data error:&operationQueueError];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(comment, operationQueueError);
        }];
    }];
}

- (void)deleteCommentFromNode:(AlfrescoNode *)node
                      comment:(AlfrescoComment *)comment
              completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:node assertMessage:@"node must not be nil" isOptional:NO];
    [AlfrescoErrors assertArgumentNotNil:completionBlock assertMessage:@"completionBlock must not be nil" isOptional:NO];
    [AlfrescoErrors assertArgumentNotNil:node.identifier assertMessage:@"node.identifier must not be nil" isOptional:NO];
    [AlfrescoErrors assertArgumentNotNil:comment assertMessage:@"comment must not be nil" isOptional:NO];
    [AlfrescoErrors assertArgumentNotNil:comment.identifier assertMessage:@"comment.identifier must not be nil" isOptional:NO];
    
    __weak AlfrescoCloudCommentService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *nodeRefString = [kAlfrescoCloudCommentForNodeAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef
                                                                                             withString:[node.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"]];
        
        NSString *requestString = [nodeRefString stringByReplacingOccurrencesOfString:kAlfrescoCommentId
                                                                           withString:[comment.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"]];
        
        [AlfrescoHTTPUtils executeRequest:requestString
                          baseUrlAsString:weakSelf.baseApiUrl
                   authenticationProvider:weakSelf.authenticationProvider
                                     data:nil
                               httpMethod:@"DELETE"
                                    error:&operationQueueError];
        
        BOOL success = (nil == operationQueueError) ? YES : NO;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(success, operationQueueError);
        }];
        
    }];
}


#pragma private methods
- (NSArray *) parseCommentArrayWithData:(NSData *)data error:(NSError *__autoreleasing *)outError
{
    NSLog(@"parseCommentArrayWithData with JSON data %@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    
    NSArray *entriesArray = [AlfrescoObjectConverter parseCloudJSONEntriesFromListData:data error:outError];
    if (nil == entriesArray)
    {
        return nil;
    }
    NSMutableArray *resultsArray = [NSMutableArray arrayWithCapacity:entriesArray.count];
    
    for (NSDictionary *entryDict in entriesArray)
    {
        NSDictionary *individualEntry = [entryDict valueForKey:kAlfrescoCloudJSONEntry];
        if (nil == individualEntry)
        {
            if (nil == *outError)
            {
                *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeComment];
            }
            else
            {
                NSError *error = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeComment];
                *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeComment];
                
            }
            return nil;
        }
        else
        {
            [resultsArray addObject:[self commentFromJSON:individualEntry]];
        }
    }
    return resultsArray;
}

- (AlfrescoComment *) parseCommentDictWithData:(NSData *)data error:(NSError *__autoreleasing *)outError
{
    NSLog(@"parseCommentDictWithData with JSON data %@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    if (nil == data)
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeJSONParsingNilData];
        }
        else
        {
            NSError *error = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeJSONParsingNilData];
            *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
            
        }
        return nil;
    }
    
    NSError *error = nil;
    id jsonCommentDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(nil == jsonCommentDict)
    {
        *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeComment];
        return nil;
    }
    NSDictionary *jsonComment = [jsonCommentDict valueForKey:kAlfrescoCloudJSONEntry];
    if (nil == jsonComment)
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeJSONParsing];
        }
        else
        {
            NSError *error = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeJSONParsing];
            *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeComment];
        }
        return nil;
    }
    return (AlfrescoComment *)[self commentFromJSON:jsonComment];
}


- (AlfrescoComment *)commentFromJSON:(NSDictionary *)commentDict
{
    if (nil == commentDict)
    {
        NSLog(@"AlfrescoCloudCommentService::commentFromJSON: commentDict is NIL");
        return nil;
    }
    NSLog(@"AlfrescoCloudCommentService::commentFromJSON: %@", commentDict);
    
    AlfrescoComment *alfComment = [[AlfrescoComment alloc] init];
    alfComment.identifier = [commentDict valueForKey:kAlfrescoJSONIdentifier];
    alfComment.content = [commentDict valueForKey:kAlfrescoJSONContent];
    alfComment.title = [commentDict valueForKey:kAlfrescoJSONTitle];
    NSString *createdDateString = [commentDict valueForKey:kAlfrescoJSONCreatedAt];
    if (nil != createdDateString)
    {
        alfComment.createdAt = [self.dateFormatter dateFromString:createdDateString];
    }
    NSDictionary *createdByDict = [commentDict valueForKey:kAlfrescoJSONCreatedBy];
    alfComment.createdBy = [createdByDict valueForKey:kAlfrescoJSONIdentifier];
    
    NSString *modifiedDateString = [commentDict valueForKey:kAlfrescoJSONModifedAt];
    if (nil != modifiedDateString)
    {
        alfComment.modifiedAt = [self.dateFormatter dateFromString:modifiedDateString];
    }
    alfComment.isEdited = [[commentDict valueForKey:kAlfrescoJSONEdited] boolValue];
    alfComment.canEdit = [[commentDict valueForKey:kAlfrescoJSONCanEdit] boolValue];
    alfComment.canDelete = [[commentDict valueForKey:kAlfrescoJSONCanDelete] boolValue];
    return alfComment;
}

@end
