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

#import "AlfrescoOnPremiseCommentService.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoBasicAuthenticationProvider.h"
#import "AlfrescoErrors.h"
#import "AlfrescoHTTPUtils.h"
#import "AlfrescoPagingUtils.h"
#import "AlfrescoISO8601DateFormatter.h"
#import "AlfrescoSortingUtils.h"
#import <objc/runtime.h>

@interface AlfrescoOnPremiseCommentService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, strong, readwrite) NSOperationQueue *operationQueue;
@property (nonatomic, strong, readwrite) AlfrescoObjectConverter *objectConverter;
@property (nonatomic, weak, readwrite) id<AlfrescoAuthenticationProvider> authenticationProvider;
@property (nonatomic, strong)AlfrescoISO8601DateFormatter *dateFormatter;

- (NSArray *) parseCommentArrayWithData:(NSData *)data error:(NSError **)outError;
- (AlfrescoComment *) parseCommentDictWithData:(NSData *)data error:(NSError **)outError;
@end

@implementation AlfrescoOnPremiseCommentService
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
        self.baseApiUrl = [[self.session.baseUrl absoluteString] stringByAppendingString:kAlfrescoOnPremiseAPIPath];
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
    [AlfrescoErrors assertArgumentNotNil:node argumentAsString:@"node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentAsString:@"node.identifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentAsString:@"completionBlock"];

    __weak AlfrescoOnPremiseCommentService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *requestString = [kAlfrescoOnPremiseCommentsAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef
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
    [AlfrescoErrors assertArgumentNotNil:node argumentAsString:@"node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentAsString:@"node.identifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentAsString:@"completionBlock"];
    if (nil == listingContext)
    {
        listingContext = [[AlfrescoListingContext alloc]init];
    }
    
    __weak AlfrescoOnPremiseCommentService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        
        NSString *requestString = [kAlfrescoOnPremiseCommentsAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef
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
    [AlfrescoErrors assertArgumentNotNil:node argumentAsString:@"node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentAsString:@"node.identifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentAsString:@"completionBlock"];
    
    __weak AlfrescoOnPremiseCommentService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        
        NSMutableDictionary *commentDict = [NSMutableDictionary dictionary];
        [commentDict setValue:content forKey:kAlfrescoJSONContent];
        [commentDict setValue:node.identifier forKey:kAlfrescoJSONNodeRef];
        [commentDict setValue:title forKey:kAlfrescoJSONTitle];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:commentDict options:kNilOptions error:&operationQueueError];
        
        NSString *requestString = [kAlfrescoOnPremiseCommentsAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef
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
    [AlfrescoErrors assertArgumentNotNil:node argumentAsString:@"node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentAsString:@"node.identifier"];
    [AlfrescoErrors assertArgumentNotNil:comment argumentAsString:@"comment"];
    [AlfrescoErrors assertArgumentNotNil:comment.identifier argumentAsString:@"comment.identifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentAsString:@"completionBlock"];
    
    __weak AlfrescoOnPremiseCommentService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        
        NSMutableDictionary *commentDict = [NSMutableDictionary dictionary];
        [commentDict setValue:content forKey:kAlfrescoJSONContent];
        [commentDict setValue:comment.identifier forKey:kAlfrescoJSONNodeRef];

        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:commentDict options:kNilOptions error:&operationQueueError];
        NSString *requestString = [kAlfrescoOnPremiseCommentForNodeAPI stringByReplacingOccurrencesOfString:kAlfrescoCommentId
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
    [AlfrescoErrors assertArgumentNotNil:comment argumentAsString:@"comment"];
    [AlfrescoErrors assertArgumentNotNil:comment.identifier argumentAsString:@"comment.identifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentAsString:@"completionBlock"];
    
    __weak AlfrescoOnPremiseCommentService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        
        NSMutableDictionary *commentDict = [NSMutableDictionary dictionary];
        [commentDict setValue:comment.identifier forKey:kAlfrescoJSONNodeRef];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:commentDict options:kNilOptions error:&operationQueueError];
        NSString *requestString = [kAlfrescoOnPremiseCommentForNodeAPI stringByReplacingOccurrencesOfString:kAlfrescoCommentId
                                                                                                 withString:[comment.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"]];
        
        [AlfrescoHTTPUtils executeRequest:requestString
                          baseUrlAsString:weakSelf.baseApiUrl
                   authenticationProvider:weakSelf.authenticationProvider
                                     data:jsonData
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
    if (nil == data)
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeJSONParsingNilData];
        }
        else
        {
            NSError *error = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeJSONParsingNilData];
            *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeUnknown];
        }
        return nil;
    }
    
    NSError *error = nil;
    id jsonCommentDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(error)
    {
        *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeComment];
        return nil;
    }
    if ([[jsonCommentDict valueForKeyPath:kAlfrescoJSONStatusCode] isEqualToNumber:[NSNumber numberWithInt:404]])
    {
        // no results found
        return [NSArray array];
    }
    NSArray *jsonCommentArray = [jsonCommentDict valueForKey:kAlfrescoJSONItems];
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:[jsonCommentArray count]];
    for (NSDictionary *commentDict in jsonCommentArray)
    {
        [resultArray addObject:[[AlfrescoComment alloc] initWithProperties:commentDict]];
    }
    return resultArray;
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
            *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeUnknown];
        }
        return nil;
    }
    
    NSError *error = nil;
    id jsonCommentDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(error)
    {
        *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeComment];
        return nil;
    }
    NSDictionary *jsonComment = [jsonCommentDict valueForKey:kAlfrescoJSONItem];
    return [[AlfrescoComment alloc] initWithProperties:jsonComment];
}

@end
