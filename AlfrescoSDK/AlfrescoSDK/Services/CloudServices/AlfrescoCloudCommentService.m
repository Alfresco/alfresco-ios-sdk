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

- (NSArray *) commentArrayFromJSONData:(NSData *)data error:(NSError **)outError;
- (AlfrescoComment *) alfrescoCommentFromJSONData:(NSData *)data error:(NSError **)outError;
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
        id authenticationObject = [session objectForParameter:kAlfrescoAuthenticationProviderObjectKey];
//        id authenticationObject = objc_getAssociatedObject(self.session, &kAlfrescoAuthenticationProviderObjectKey);
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
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentName:@"node.identifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    __weak AlfrescoCloudCommentService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *requestString = [kAlfrescoCloudCommentsAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef
                                                                                       withString:[node.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"]];
        
        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                         baseUrlAsString:weakSelf.baseApiUrl
                                                 session:weakSelf.session
                                                   error:&operationQueueError];
        
        
        NSArray *sortedCommentArray = nil;
        if(nil != data)
        {
            NSArray *commentArray = [weakSelf commentArrayFromJSONData:data error:&operationQueueError];
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
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentName:@"node.identifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    __weak AlfrescoCloudCommentService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        
        NSString *requestString = [kAlfrescoCloudCommentsAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef
                                                                                       withString:[node.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"]];
        
        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                         baseUrlAsString:weakSelf.baseApiUrl
                                                 session:weakSelf.session
                                                   error:&operationQueueError];
        
        AlfrescoPagingResult *pagingResult = nil;
        if(nil != data)
        {
            NSArray *commentArray = [weakSelf commentArrayFromJSONData:data error:&operationQueueError];
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
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentName:@"node.identifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
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
                                                 session:weakSelf.session
                                                    data:jsonData
                                              httpMethod:@"POST"
                                                   error:&operationQueueError];
        
        
        AlfrescoComment *comment = nil;
        if(nil != data)
        {
            comment = [weakSelf alfrescoCommentFromJSONData:data error:&operationQueueError];
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
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentName:@"node.identifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    [AlfrescoErrors assertArgumentNotNil:comment argumentName:@"comment"];
    [AlfrescoErrors assertArgumentNotNil:comment.identifier argumentName:@"comment.identifier"];

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
                                                 session:weakSelf.session
                                                    data:jsonData
                                              httpMethod:@"PUT"
                                                   error:&operationQueueError];
        
        
        AlfrescoComment *comment = nil;
        if(nil != data)
        {
            comment = [weakSelf alfrescoCommentFromJSONData:data error:&operationQueueError];
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
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentName:@"node.identifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    [AlfrescoErrors assertArgumentNotNil:comment argumentName:@"comment"];
    [AlfrescoErrors assertArgumentNotNil:comment.identifier argumentName:@"comment.identifier"];
    
    __weak AlfrescoCloudCommentService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *nodeRefString = [kAlfrescoCloudCommentForNodeAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef
                                                                                             withString:[node.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"]];
        
        NSString *requestString = [nodeRefString stringByReplacingOccurrencesOfString:kAlfrescoCommentId
                                                                           withString:[comment.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"]];
        
        [AlfrescoHTTPUtils executeRequest:requestString
                          baseUrlAsString:weakSelf.baseApiUrl
                                  session:weakSelf.session
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
- (NSArray *) commentArrayFromJSONData:(NSData *)data error:(NSError *__autoreleasing *)outError
{
    log(@"JSON data: %@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    
    NSArray *entriesArray = [AlfrescoObjectConverter arrayJSONEntriesFromListData:data error:outError];
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
                *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeComment];
            }
            else
            {
                NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeComment];
                *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeComment];
                
            }
            return nil;
        }
        else
        {
            [resultsArray addObject:[[AlfrescoComment alloc] initWithProperties:individualEntry]];
        }
    }
    return resultsArray;
}

- (AlfrescoComment *) alfrescoCommentFromJSONData:(NSData *)data error:(NSError *__autoreleasing *)outError
{
    log(@"JSON data: %@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    if (nil == data)
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        }
        else
        {
            NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
            *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
            
        }
        return nil;
    }
    
    NSError *error = nil;
    id jsonCommentDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(nil == jsonCommentDict)
    {
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeComment];
        return nil;
    }
    NSDictionary *jsonComment = [jsonCommentDict valueForKey:kAlfrescoCloudJSONEntry];
    if (nil == jsonComment)
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        }
        else
        {
            NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
            *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        }
        return nil;
    }
    return [[AlfrescoComment alloc] initWithProperties:jsonComment];
}

@end
