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

#import "AlfrescoCloudRatingService.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoBasicAuthenticationProvider.h"
#import "AlfrescoErrors.h"
#import "AlfrescoHTTPUtils.h"
#import "AlfrescoPagingUtils.h"
#import <objc/runtime.h>

@interface AlfrescoCloudRatingService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, strong, readwrite) NSOperationQueue *operationQueue;
@property (nonatomic, weak, readwrite) id<AlfrescoAuthenticationProvider> authenticationProvider;
- (NSDictionary *) parseRatingsDictionaryWithData:(NSData *)data error:(NSError **)outError;

@end

@implementation AlfrescoCloudRatingService
@synthesize baseApiUrl = _baseApiUrl;
@synthesize session = _session;
@synthesize operationQueue = _operationQueue;
@synthesize authenticationProvider = _authenticationProvider;

- (id)initWithSession:(id<AlfrescoSession>)session
{
    if (self = [super init])
    {
        self.session = session;
        self.baseApiUrl = [[self.session.baseUrl absoluteString] stringByAppendingString:kAlfrescoCloudAPIPath];
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

- (void)retrieveLikeCountForNode:(AlfrescoNode *)node
                 completionBlock:(AlfrescoNumberCompletionBlock)completionBlock
{
    NSAssert(nil != node, @"node must not be nil");
    NSAssert(nil != node.identifier, @"node.identifier must not be nil");
    NSAssert(nil != completionBlock, @"completionBlock must not be nil");
    
    __weak AlfrescoCloudRatingService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *requestString = [kAlfrescoCloudRatingsAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef
                                                                                      withString:[node.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"]];
        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                         baseUrlAsString:weakSelf.baseApiUrl
                                  authenticationProvider:weakSelf.authenticationProvider
                                                   error:&operationQueueError];
        
        NSNumber *count = nil;
        if(nil != data)
        {
            NSDictionary *ratingsDict = [weakSelf parseRatingsDictionaryWithData:data error:&operationQueueError];
            if (nil == ratingsDict)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completionBlock(count, operationQueueError);
                }];
            }
            else
            {
                id aggregateObject = [ratingsDict valueForKey:kAlfrescoJSONAggregate];
                if ([aggregateObject isKindOfClass:[NSDictionary class]])
                {
                    NSDictionary *aggregateDict = (NSDictionary *)aggregateObject;
                    count = [aggregateDict valueForKey:kAlfrescoJSONNumberOfRatings];
                }
                else
                {
                    operationQueueError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeRatings withDetailedDescription:@"No ratings count was found"];
                }
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(count, operationQueueError);
        }];
        
    }];
}

- (void)isNodeLiked:(AlfrescoNode *)node completionBlock:(AlfrescoLikedCompletionBlock)completionBlock
{
    NSAssert(nil != node, @"node must not be nil");
    NSAssert(nil != node.identifier, @"node.identifier must not be nil");
    NSAssert(nil != completionBlock, @"completionBlock must not be nil");
    
    __weak AlfrescoCloudRatingService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        
        NSString *requestString = [kAlfrescoCloudRatingsAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef
                                                                                      withString:[node.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"]];
        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                         baseUrlAsString:weakSelf.baseApiUrl
                                  authenticationProvider:weakSelf.authenticationProvider
                                                   error:&operationQueueError];
        
        
        
        BOOL success;
        
        BOOL liked = NO;
        if(nil != data)
        {
            NSDictionary *ratingsDict = [weakSelf parseRatingsDictionaryWithData:data error:&operationQueueError];
            if (nil == ratingsDict)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completionBlock(NO, NO, operationQueueError);
                }];
            }
            else
            {
                id aggregateObject = [ratingsDict valueForKey:kAlfrescoJSONAggregate];
                if ([aggregateObject isKindOfClass:[NSDictionary class]])
                {
                    NSDictionary *aggregateDict = (NSDictionary *)aggregateObject;
                    NSNumber *count = [aggregateDict valueForKey:kAlfrescoJSONNumberOfRatings];
                    NSNumber *isLikedValue = [ratingsDict valueForKey:kAlfrescoJSONMyRating];
                    if (0 < [count intValue])
                    {
                        liked = [isLikedValue boolValue];
                    }
                    success = YES;
                }
                else
                {
                    operationQueueError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeRatings withDetailedDescription:@"No ratings count was found"];
                    success = NO;
                }
                
            }
            
        }
        else
        {
            success = NO;
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(success, liked, operationQueueError);
        }];
    }];
}


- (void)likeNode:(AlfrescoNode *)node
 completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    NSAssert(nil != node, @"node must not be nil");
    NSAssert(nil != node.identifier, @"node.identifier must not be nil");
    NSAssert(nil != completionBlock, @"completionBlock must not be nil");
    
    __weak AlfrescoCloudRatingService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        
        NSMutableDictionary *likeDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [likeDict setValue:[NSNumber numberWithBool:YES] forKey:kAlfrescoJSONMyRating];
        [likeDict setValue:kAlfrescoJSONLikes forKey:kAlfrescoJSONIdentifier];
        
        NSString *requestString = [kAlfrescoCloudRatingsAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef
                                                                                      withString:[node.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"]];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:likeDict options:kNilOptions error:&operationQueueError];
        
        if (nil == jsonData)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(NO, operationQueueError);
            }];
        }
        else
        {
            NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                             baseUrlAsString:weakSelf.baseApiUrl
                                      authenticationProvider:weakSelf.authenticationProvider
                                                        data:jsonData
                                                  httpMethod:@"POST"
                                                       error:&operationQueueError];
            NSLog(@"likeNode with JSON data %@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
            BOOL success = (nil == operationQueueError) ? YES : NO;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(success, operationQueueError);
            }];
            
        }
        
    }];
}




- (void)unlikeNode:(AlfrescoNode *)node
   completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    NSAssert(nil != node, @"node must not be nil");
    NSAssert(nil != node.identifier, @"node.identifier must not be nil");
    NSAssert(nil != completionBlock, @"completionBlock must not be nil");
    
    __weak AlfrescoCloudRatingService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *nodeRatings = [kAlfrescoCloudRatingsAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef
                                                                                      withString:[node.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"]];
        NSString *requestString = [NSString stringWithFormat:@"%@/%@",nodeRatings, kAlfrescoJSONLikes];
        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                         baseUrlAsString:weakSelf.baseApiUrl
                                  authenticationProvider:weakSelf.authenticationProvider
                                                    data:nil
                                              httpMethod:@"DELETE"
                                                   error:&operationQueueError];
        NSLog(@"unlikeNode with JSON data %@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
        BOOL success = (nil == operationQueueError) ? YES : NO;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(success, operationQueueError);
        }];
    }];
}


- (NSDictionary *) parseRatingsDictionaryWithData:(NSData *)data error:(NSError **)outError
{
    
    NSLog(@"parseRatingsDictionaryWithData with JSON data %@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    NSArray *entriesArray = [AlfrescoObjectConverter parseCloudJSONEntriesFromListData:data error:outError];
    if (nil == entriesArray)
    {
        return nil;
    }

    
    for (NSDictionary *entryDict in entriesArray)
    {
        NSDictionary *individualEntry = [entryDict valueForKey:kAlfrescoCloudJSONEntry];
        if (nil == individualEntry)
        {
            if (nil == *outError)
            {
                *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeRatings
                                                withDetailedDescription:@"Ratings JSON data return NIL"];
            }
            else
            {
                NSError *error = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeRatings
                                                     withDetailedDescription:@"Ratings JSON data return NIL"];
                *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeRatings];
                
            }
            return nil;
        }
        NSString *ratingsType = [individualEntry valueForKey:kAlfrescoJSONIdentifier];
        if ([ratingsType hasPrefix:kAlfrescoJSONLikes])
        {
            return individualEntry;
        }
    }
    if (nil == *outError)
    {
        *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeRatings withDetailedDescription:@"No valid rating scheme was found. Must be likes"];
    }
    else
    {
        NSError *error = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeRatings
                                             withDetailedDescription:@"No valid rating scheme was found. Must be likes"];
        *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeRatings];        
    }
    return nil;
    
}


@end
