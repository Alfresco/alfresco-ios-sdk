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

#import "AlfrescoOnPremiseTaggingService.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoBasicAuthenticationProvider.h"
#import "AlfrescoErrors.h"
#import "AlfrescoHTTPUtils.h"
#import "AlfrescoPagingUtils.h"
#import "AlfrescoTag.h"
#import "AlfrescoObjectConverter.h"

@interface AlfrescoOnPremiseTaggingService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, strong, readwrite) NSOperationQueue *operationQueue;
@property (nonatomic, strong, readwrite) AlfrescoObjectConverter *objectConverter;
@property (nonatomic, weak, readwrite) id<AlfrescoAuthenticationProvider> authenticationProvider;
- (NSArray *) parseTagArrayWithData:(NSData *)data error:(NSError **)outError;
- (NSArray *) customParseTagArrayWithData:(NSData *) data;

@end

@implementation AlfrescoOnPremiseTaggingService
@synthesize baseApiUrl = _baseApiUrl;
@synthesize session = _session;
@synthesize operationQueue = _operationQueue;
@synthesize objectConverter = _objectConverter;
@synthesize authenticationProvider = _authenticationProvider;

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
    }
    return self;
}


- (void)retrieveAllTagsWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentAsString:@"completionBlock"];
    __weak AlfrescoOnPremiseTaggingService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError;
        NSData *data = [AlfrescoHTTPUtils executeRequest:kAlfrescoOnPremiseTagsAPI
                                         baseUrlAsString:weakSelf.baseApiUrl
                                  authenticationProvider:weakSelf.authenticationProvider
                                                   error:&operationQueueError];
        
        NSArray *tagArray = nil;
        if(nil != data)
        {
            tagArray = [weakSelf parseTagArrayWithData:data error:&operationQueueError];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(tagArray, operationQueueError);
        }];
    }];
}

- (void)retrieveAllTagsWithListingContext:(AlfrescoListingContext *)listingContext
                          completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentAsString:@"completionBlock"];
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    __weak AlfrescoOnPremiseTaggingService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError;
        
        NSData *data = [AlfrescoHTTPUtils executeRequest:kAlfrescoOnPremiseTagsAPI
                                         baseUrlAsString:weakSelf.baseApiUrl
                                  authenticationProvider:weakSelf.authenticationProvider
                                                   error:&operationQueueError];
        
        AlfrescoPagingResult *pagingResult = nil;
        if(nil != data)
        {
            NSArray *tagArray = [weakSelf parseTagArrayWithData:data error:&operationQueueError];
            if (nil != tagArray)
            {
                pagingResult = [AlfrescoPagingUtils pagedResultFromArray:tagArray listingContext:listingContext];
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(pagingResult, operationQueueError);
        }];
    }];
}

- (void)retrieveTagsForNode:(AlfrescoNode *)node
            completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:node argumentAsString:@"node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentAsString:@"node.identifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentAsString:@"completionBlock"];
    
    __weak AlfrescoOnPremiseTaggingService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError;
        NSString *nodeId = [AlfrescoObjectConverter nodeRefWithoutVersionID:node.identifier];
        NSString *cleanId = [nodeId stringByReplacingOccurrencesOfString:@"://" withString:@"/"];
        NSString *requestString = [kAlfrescoOnPremiseTagsForNodeAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef
                                                                                              withString:cleanId];

        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                         baseUrlAsString:weakSelf.baseApiUrl
                                  authenticationProvider:weakSelf.authenticationProvider
                                                   error:&operationQueueError];
        
        NSArray *tagArray = nil;
        if(nil != data)
        {
            // the node tags service returns an invalid JSON array, therefore parsing it ourselves
            tagArray = [weakSelf customParseTagArrayWithData:data];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(tagArray, operationQueueError);
        }];
    }];
}

- (void)retrieveTagsForNode:(AlfrescoNode *)node listingContext:(AlfrescoListingContext *)listingContext
            completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:node argumentAsString:@"node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentAsString:@"node.identifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentAsString:@"completionBlock"];
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    __weak AlfrescoOnPremiseTaggingService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        
        NSString *nodeId = [AlfrescoObjectConverter nodeRefWithoutVersionID:node.identifier];
        NSString *cleanId = [nodeId stringByReplacingOccurrencesOfString:@"://" withString:@"/"];
        NSString *requestString = [kAlfrescoOnPremiseTagsForNodeAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef
                                                                                              withString:cleanId];
        
        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                         baseUrlAsString:weakSelf.baseApiUrl
                                  authenticationProvider:weakSelf.authenticationProvider
                                                   error:&operationQueueError];
        
        AlfrescoPagingResult *pagingResult = nil;
        if(nil != data)
        {
            // the node tags service returns an invalid JSON array, therefore parsing it ourselves
            NSArray *tagArray = [weakSelf customParseTagArrayWithData:data];
            if (nil != tagArray)
            {
                pagingResult = [AlfrescoPagingUtils pagedResultFromArray:tagArray listingContext:listingContext];
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(pagingResult, operationQueueError);
        }];
        
    }];
}

- (void)addTags:(NSArray *)tags toNode:(AlfrescoNode *)node
completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:tags argumentAsString:@"tags"];
    [AlfrescoErrors assertArgumentNotNil:node argumentAsString:@"node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentAsString:@"node.identifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentAsString:@"completionBlock"];
    
    __weak AlfrescoOnPremiseTaggingService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *nodeId = [AlfrescoObjectConverter nodeRefWithoutVersionID:node.identifier];
        NSString *cleanId = [nodeId stringByReplacingOccurrencesOfString:@"://" withString:@"/"];
        NSString *requestString = [kAlfrescoOnPremiseTagsForNodeAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef
                                                                                              withString:cleanId];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tags options:kNilOptions error:&operationQueueError];
        if (nil != jsonData)
        {
            [AlfrescoHTTPUtils executeRequest:requestString
                              baseUrlAsString:weakSelf.baseApiUrl
                       authenticationProvider:weakSelf.authenticationProvider
                                         data:jsonData httpMethod:@"POST"
                                        error:&operationQueueError];
        }
                
        BOOL success = (nil == operationQueueError) ? YES : NO;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(success, operationQueueError);
        }];
        
    }];
}

#pragma mark Site service internal methods

- (NSArray *) parseTagArrayWithData:(NSData *)data error:(NSError **)outError
{
    if (nil == data)
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeJSONParsingNilData];
        }
        else
        {
            NSError *error = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeJSONParsingNilData];
            *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeTagging];
            
        }
        return nil;
    }
    NSError *error = nil;
    id jsonTagArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (nil != error)
    {
        *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeTagging];
        return nil;
    }
    if ([jsonTagArray isKindOfClass:[NSArray class]] == NO)
    {
        if([jsonTagArray isKindOfClass:[NSDictionary class]] == YES &&
           [[jsonTagArray valueForKeyPath:kAlfrescoJSONStatusCode] isEqualToNumber:[NSNumber numberWithInt:404]])
        {
            // no results found
            return [NSArray array];
        }
        else
        {
            if (nil == *outError)
            {
                *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeJSONParsing];
            }
            else
            {
                NSError *underlyingError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeJSONParsing];
                *outError = [AlfrescoErrors alfrescoError:underlyingError withAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
                
            }
            return nil;
        }
    }
    NSMutableArray *resultsArray = [NSMutableArray array];
    for (NSString * tagValue in jsonTagArray)
    {
        NSMutableDictionary *tagDict = [NSMutableDictionary dictionary];
        [tagDict setValue:tagValue forKey:kAlfrescoJSONTag];
        AlfrescoTag *tag = [[AlfrescoTag alloc] initWithProperties:tagDict];
        [resultsArray addObject:tag];
    }
    return resultsArray;
}

- (NSArray *) customParseTagArrayWithData:(NSData *) data
{
    NSString *tagString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    tagString = [tagString stringByReplacingOccurrencesOfString:@"[" withString:@""];
    tagString = [tagString stringByReplacingOccurrencesOfString:@"]" withString:@""];
    NSArray *separatedTagArray = [tagString componentsSeparatedByString:@","];
    NSMutableArray *tagArray = [NSMutableArray arrayWithCapacity:separatedTagArray.count];
    for (NSString *tag in separatedTagArray)
    {
        NSString *trimmedString = [tag stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([trimmedString length] > 0)
        {
            NSMutableDictionary *tagDict = [NSMutableDictionary dictionary];
            [tagDict setValue:trimmedString forKey:kAlfrescoJSONTag];
            AlfrescoTag *tag = [[AlfrescoTag alloc] initWithProperties:tagDict];
            [tagArray addObject:tag];
        }
    }
    
    return tagArray;
}

@end
