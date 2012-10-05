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

#import "AlfrescoOnPremiseRatingService.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoBasicAuthenticationProvider.h"
#import "AlfrescoRepositoryInfo.h"
#import "AlfrescoErrors.h"
#import "AlfrescoHTTPUtils.h"
#import "AlfrescoObjectConverter.h"
#import <objc/runtime.h>

@interface AlfrescoOnPremiseRatingService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, strong, readwrite) NSOperationQueue *operationQueue;
@property (nonatomic, weak, readwrite) id<AlfrescoAuthenticationProvider> authenticationProvider;

@end

@implementation AlfrescoOnPremiseRatingService
@synthesize baseApiUrl = _baseApiUrl;
@synthesize session = _session;
@synthesize operationQueue = _operationQueue;
@synthesize authenticationProvider = _authenticationProvider;

- (id)initWithSession:(id<AlfrescoSession>)session
{
    if (self = [super init])
    {
        self.session = session;
        self.baseApiUrl = [[self.session.baseUrl absoluteString] stringByAppendingString:kAlfrescoOnPremiseAPIPath];
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 2;
        id authenticationObject = [session objectForParameter:kAlfrescoAuthenticationProviderObjectKey];
//        id authenticationObject = objc_getAssociatedObject(self.session, &kAlfrescoAuthenticationProviderObjectKey);
        self.authenticationProvider = nil;
        if ([authenticationObject isKindOfClass:[AlfrescoBasicAuthenticationProvider class]])
        {
            self.authenticationProvider = (AlfrescoBasicAuthenticationProvider *)authenticationObject;
        }
        AlfrescoRepositoryCapabilities *capabilities = self.session.repositoryInfo.capabilities;
        if (![capabilities doesSupportCapability:kAlfrescoCapabilityLike])
        {
            return nil;
        }
    }
    return self;
}

- (void)retrieveLikeCountForNode:(AlfrescoNode *)node
                 completionBlock:(AlfrescoNumberCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentName:@"node.identifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    __weak AlfrescoOnPremiseRatingService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *nodeIdentifier = [node.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"];
        NSString *cleanId = [AlfrescoObjectConverter nodeRefWithoutVersionID:nodeIdentifier];
        NSString *requestString = [kAlfrescoOnPremiseRatingsAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef withString:cleanId];
        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                         baseUrlAsString:weakSelf.baseApiUrl
                                                 session:weakSelf.session
                                                   error:&operationQueueError];
        
        log(@"JSON data: %@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
        NSNumber *count = nil;
        if(nil != data)
        {
            NSDictionary *ratingsDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&operationQueueError];
            count = [ratingsDict valueForKeyPath:kAlfrescoOnPremiseRatingsCount];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(count, operationQueueError);
        }];
        
    }];
}
 
- (void)likeNode:(AlfrescoNode *)node
 completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentName:@"node.identifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    __weak AlfrescoOnPremiseRatingService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        
        NSMutableDictionary *likeDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [likeDict setValue:[NSNumber numberWithInt:1] forKey:kAlfrescoJSONRating];
        [likeDict setValue:kAlfrescoJSONLikesRatingScheme forKey:kAlfrescoJSONRatingScheme];
        
        NSString *nodeIdentifier = [node.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"];
        NSString *cleanId = [AlfrescoObjectConverter nodeRefWithoutVersionID:nodeIdentifier];
        NSString *requestString = [kAlfrescoOnPremiseRatingsAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef withString:cleanId];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:likeDict options:kNilOptions error:&operationQueueError];
        
        if (nil == jsonData)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(NO, operationQueueError);
            }];
        }
        else
        {
            log(@"JSON data: %@",[[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding]);
            [AlfrescoHTTPUtils executeRequest:requestString
                              baseUrlAsString:weakSelf.baseApiUrl
                                      session:weakSelf.session
                                         data:jsonData
                                   httpMethod:@"POST"
                                        error:&operationQueueError];
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
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentName:@"node.identifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    __weak AlfrescoOnPremiseRatingService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *nodeIdentifier = [node.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"];
        NSString *cleanId = [AlfrescoObjectConverter nodeRefWithoutVersionID:nodeIdentifier];
        NSString *requestString = [kAlfrescoOnPremiseRatingsLikingSchemeAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef withString:cleanId];
        NSData *jsonData = [AlfrescoHTTPUtils executeRequest:requestString
                                             baseUrlAsString:weakSelf.baseApiUrl
                                                     session:weakSelf.session
                                                        data:nil
                                                  httpMethod:@"DELETE"
                                                       error:&operationQueueError];
        log(@"JSON data: %@",[[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding]);
        BOOL success = (nil == operationQueueError) ? YES : NO;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(success, operationQueueError);
        }];
    }];
}
 
- (void)isNodeLiked:(AlfrescoNode *)node completionBlock:(AlfrescoLikedCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentName:@"node.identifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    __weak AlfrescoOnPremiseRatingService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        
        NSString *nodeIdentifier = [node.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"];
        NSString *cleanId = [AlfrescoObjectConverter nodeRefWithoutVersionID:nodeIdentifier];
        NSString *requestString = [kAlfrescoOnPremiseRatingsAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef withString:cleanId];
        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                         baseUrlAsString:weakSelf.baseApiUrl
                                                 session:weakSelf.session
                                                   error:&operationQueueError];

        
        
        log(@"JSON data: %@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
        BOOL success = (nil == operationQueueError) ? YES : NO;
        
        BOOL liked = NO;
        if(nil != data)
        {
            NSDictionary *ratingsDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&operationQueueError];
            liked = [[ratingsDict valueForKeyPath:kAlfrescoOnPremiseLikesSchemeRatings] boolValue];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(success, liked, operationQueueError);
        }];
    }];
}
@end
