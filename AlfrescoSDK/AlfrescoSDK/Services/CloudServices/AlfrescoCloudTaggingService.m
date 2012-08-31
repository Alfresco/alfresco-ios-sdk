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

#import "AlfrescoCloudTaggingService.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoBasicAuthenticationProvider.h"
#import "AlfrescoErrors.h"
#import "AlfrescoHTTPUtils.h"
#import "AlfrescoPagingUtils.h"
#import "AlfrescoTag.h"

@interface AlfrescoCloudTaggingService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, strong, readwrite) NSOperationQueue *operationQueue;
@property (nonatomic, strong, readwrite) AlfrescoObjectConverter *objectConverter;
@property (nonatomic, weak, readwrite) id<AlfrescoAuthenticationProvider> authenticationProvider;
- (NSArray *) parseTagArrayWithData:(NSData *)data error:(NSError **)outError;
- (AlfrescoTag *)tagFromJSON:(NSDictionary *)jsonDict;
@end

@implementation AlfrescoCloudTaggingService
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
    }
    return self;
}


- (void)retrieveAllTagsWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    NSAssert(nil != completionBlock, @"completionBlock must not be nil");
    __weak AlfrescoCloudTaggingService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError;
        NSData *data = [AlfrescoHTTPUtils executeRequest:kAlfrescoCloudTagsAPI
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
    NSAssert(nil != completionBlock, @"completionBlock must not be nil");
    NSAssert(nil != listingContext, @"listingContext must not be nil");
    
    __weak AlfrescoCloudTaggingService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError;
        
        NSData *data = [AlfrescoHTTPUtils executeRequest:kAlfrescoCloudTagsAPI
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
    NSAssert(nil != completionBlock, @"completionBlock must not be nil");
    NSAssert(nil != node, @"node must not be nil");
    NSAssert(nil != node.identifier, @"node.identifier must not be nil");
    
    __weak AlfrescoCloudTaggingService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError;
        NSString *requestString = [kAlfrescoCloudTagsForNodeAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef
                                                                                          withString:[node.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"]];
        
        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
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

- (void)retrieveTagsForNode:(AlfrescoNode *)node listingContext:(AlfrescoListingContext *)listingContext
            completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    NSAssert(nil != completionBlock, @"completionBlock must not be nil");
    NSAssert(nil != node, @"node must not be nil");
    NSAssert(nil != node.identifier, @"node.identifier must not be nil");
    NSAssert(nil != listingContext, @"listingContext must not be nil");
    
    __weak AlfrescoCloudTaggingService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        
        NSString *requestString = [kAlfrescoCloudTagsForNodeAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef
                                                                                          withString:[node.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"]];
        
        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                         baseUrlAsString:weakSelf.baseApiUrl
                                  authenticationProvider:weakSelf.authenticationProvider
                                                   error:&operationQueueError];
        
        AlfrescoPagingResult *pagingResult = nil;
        if(nil != data)
        {
            // the node tags service returns an invalid JSON array, therefore parsing it ourselves
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


- (void)addTags:(NSArray *)tags toNode:(AlfrescoNode *)node
completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    NSAssert(nil != completionBlock, @"completionBlock must not be nil");
    NSAssert(nil != node, @"node must not be nil");
    NSAssert(nil != node.identifier, @"node.identifier must not be nil");
    NSAssert(nil != tags, @"tags must not be nil");
    if (0 == tags.count)
    {
        return;
    }
    
    __weak AlfrescoCloudTaggingService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *requestString = [kAlfrescoCloudTagsForNodeAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef
                                                                                              withString:[node.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"]];
        
        NSData *jsonData = nil;
        if (1 == tags.count)
        {
            NSMutableDictionary *tagDictionary = [NSMutableDictionary dictionary];
            [tagDictionary setValue:[tags objectAtIndex:0] forKey:kAlfrescoJSONTag];
            
            jsonData = [NSJSONSerialization dataWithJSONObject:tagDictionary options:kNilOptions error:&operationQueueError];
        }
        else
        {
            NSMutableArray *tagJSONArray = [NSMutableArray array];
            for (NSString *tagValue in tags)
            {
                NSDictionary *tagDictionary = [NSMutableDictionary dictionary];
                [tagDictionary setValue:tagValue forKey:kAlfrescoJSONTag];
                [tagJSONArray addObject:tagDictionary];
            }
            jsonData = [NSJSONSerialization dataWithJSONObject:tagJSONArray options:kNilOptions error:&operationQueueError];
        }
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
    NSLog(@"parseTagArrayWithData with JSON data %@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
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
                *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeTagging
                                                withDetailedDescription:@"tagging JSON entry returns with NIL"];
            }
            else
            {
                NSError *error = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeTagging
                                                     withDetailedDescription:@"tagging JSON entry returns with NIL"];
                *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeTagging];
                
            }
            return nil;
        }
        AlfrescoTag *tag = [self tagFromJSON:individualEntry];
        [resultsArray addObject:tag];
    }
    return resultsArray;
}

- (AlfrescoTag *)tagFromJSON:(NSDictionary *)jsonDict
{
    AlfrescoTag *tag = [[AlfrescoTag alloc]init];
    tag.value = [jsonDict valueForKey:kAlfrescoJSONTag];
    tag.identifier = [jsonDict valueForKey:kAlfrescoJSONIdentifier];
    return tag;
}



@end
