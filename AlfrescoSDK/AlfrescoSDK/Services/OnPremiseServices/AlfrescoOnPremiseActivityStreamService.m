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

#import "AlfrescoOnPremiseActivityStreamService.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoBasicAuthenticationProvider.h"
#import "AlfrescoErrors.h"
#import "AlfrescoHTTPUtils.h"
#import "AlfrescoPagingUtils.h"
#import "AlfrescoISO8601DateFormatter.h"
#import <objc/runtime.h>

@interface AlfrescoOnPremiseActivityStreamService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, strong, readwrite) NSOperationQueue *operationQueue;
@property (nonatomic, strong, readwrite) AlfrescoObjectConverter *objectConverter;
@property (nonatomic, weak, readwrite) id<AlfrescoAuthenticationProvider> authenticationProvider;
@property (nonatomic, strong)AlfrescoISO8601DateFormatter *dateFormatter;

- (NSArray *) parseActivityStreamArrayWithData:(NSData *)data error:(NSError **)outError;
- (AlfrescoActivityEntry *)activityEntryFromJSON:(NSDictionary *)activityDict;
@end


@implementation AlfrescoOnPremiseActivityStreamService
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


 - (void)retrieveActivityStreamWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
 {
     [self retrieveActivityStreamForPerson:self.session.personIdentifier completionBlock:completionBlock];
 }
 
- (void)retrieveActivityStreamWithListingContext:(AlfrescoListingContext *)listingContext
                                 completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [self retrieveActivityStreamForPerson:self.session.personIdentifier listingContext:listingContext completionBlock:completionBlock];
}
 
 - (void)retrieveActivityStreamForPerson:(NSString *)personIdentifier completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
 {
     NSAssert(nil != personIdentifier, @"personIdentifier must not be nil");
     NSAssert(nil != completionBlock, @"completionBlock must not be nil");
     
     __weak AlfrescoOnPremiseActivityStreamService *weakSelf = self;
     [self.operationQueue addOperationWithBlock:^{
         
         NSError *operationQueueError = nil;
         
         NSData *data = [AlfrescoHTTPUtils executeRequest:kAlfrescoOnPremiseActivityAPI
                                          baseUrlAsString:weakSelf.baseApiUrl
                                   authenticationProvider:weakSelf.authenticationProvider
                                                    error:&operationQueueError];
         
         NSArray *activityStreamArray = nil;
         if(nil != data)
         {
             activityStreamArray = [weakSelf parseActivityStreamArrayWithData:data error:&operationQueueError];
         }
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             completionBlock(activityStreamArray, operationQueueError);
         }];
     }];
 }
 
 - (void)retrieveActivityStreamForPerson:(NSString *)personIdentifier listingContext:(AlfrescoListingContext *)listingContext
 completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
 {
     NSAssert(nil != personIdentifier, @"personIdentifier must not be nil");
     NSAssert(nil != listingContext, @"listingContext must not be nil");
     NSAssert(nil != completionBlock, @"completionBlock must not be nil");
 
     __weak AlfrescoOnPremiseActivityStreamService *weakSelf = self;
     [self.operationQueue addOperationWithBlock:^{
         
         NSError *operationQueueError = nil;
         
         NSData *data = [AlfrescoHTTPUtils executeRequest:kAlfrescoOnPremiseActivityAPI
                                          baseUrlAsString:weakSelf.baseApiUrl
                                   authenticationProvider:weakSelf.authenticationProvider
                                                    error:&operationQueueError];
         
         AlfrescoPagingResult *pagingResult = nil;
         if(nil != data)
         {
             NSArray *activityStreamArray = [weakSelf parseActivityStreamArrayWithData:data error:&operationQueueError];
             if (nil != activityStreamArray)
             {
                 pagingResult = [AlfrescoPagingUtils pagedResultFromArray:activityStreamArray listingContext:listingContext];
             }
         }
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             completionBlock(pagingResult, operationQueueError);
         }];
     }];
 }
 
 - (void)retrieveActivityStreamForSite:(AlfrescoSite *)site completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
 {
     NSAssert(nil != site, @"site must not be nil");
     NSAssert(nil != completionBlock, @"completionBlock must not be nil");
     
     __weak AlfrescoOnPremiseActivityStreamService *weakSelf = self;
     [self.operationQueue addOperationWithBlock:^{
         
         NSError *operationQueueError = nil;
         NSString *requestString = [kAlfrescoOnPremiseActivityForSiteAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:site.shortName];
         NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                          baseUrlAsString:weakSelf.baseApiUrl
                                   authenticationProvider:weakSelf.authenticationProvider
                                                    error:&operationQueueError];
         
         NSArray *activityStreamArray = nil;
         if(nil != data)
         {
             activityStreamArray = [weakSelf parseActivityStreamArrayWithData:data error:&operationQueueError];
         }
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             completionBlock(activityStreamArray, operationQueueError);
         }];
     }];
 }
 
- (void)retrieveActivityStreamForSite:(AlfrescoSite *)site
                   listingContext:(AlfrescoListingContext *)listingContext
                      completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    NSAssert(nil != site, @"site must not be nil");
    NSAssert(nil != completionBlock, @"completionBlock must not be nil");
    NSAssert(nil != listingContext, @"listingContext must not be nil");
    
    __weak AlfrescoOnPremiseActivityStreamService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *requestString = [kAlfrescoOnPremiseActivityForSiteAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:site.shortName];
        
        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                         baseUrlAsString:weakSelf.baseApiUrl
                                  authenticationProvider:weakSelf.authenticationProvider
                                                   error:&operationQueueError];
        
        AlfrescoPagingResult *pagingResult = nil;
        if(nil != data)
        {
            NSArray *activityStreamArray = [weakSelf parseActivityStreamArrayWithData:data error:&operationQueueError];
            if (nil != activityStreamArray)
            {
                pagingResult = [AlfrescoPagingUtils pagedResultFromArray:activityStreamArray listingContext:listingContext];
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(pagingResult, operationQueueError);
        }];
    }];
}
 
 #pragma mark Activity stream service internal methods
 
- (NSArray *) parseActivityStreamArrayWithData:(NSData *)data error:(NSError **)outError
{
//    NSLog(@"parseActivityStreamArrayWithData with JSON data %@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    if (nil == data)
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeActivityStream
                                            withDetailedDescription:@"JSON data shouldn't be NIL"];
        }
        else
        {
            NSError *error = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeActivityStream
                                                 withDetailedDescription:@"JSON data shouldn't be NIL"];
            *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeActivityStream];
        }
        return nil;
    }
    NSError *error = nil;
    id jsonActivityStreamArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(nil == jsonActivityStreamArray)
    {
        *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeActivityStream];
        return nil;
    }
    if ([jsonActivityStreamArray isKindOfClass:[NSArray class]] == NO)
    {
        if([jsonActivityStreamArray isKindOfClass:[NSDictionary class]] == YES &&
           [[jsonActivityStreamArray valueForKeyPath:kAlfrescoJSONStatusCode] isEqualToNumber:[NSNumber numberWithInt:404]])
        {
            // no results found
            return [NSArray array];
        }
        else
        {
            if (nil == *outError)
            {
                *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeActivityStream
                                                withDetailedDescription:@"Parse result has no activity entry"];
            }
            else
            {
                NSError *underlyingError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeActivityStream
                                                               withDetailedDescription:@"Parse result has no activity entry"];
                *outError = [AlfrescoErrors alfrescoError:underlyingError withAlfrescoErrorCode:kAlfrescoErrorCodeActivityStream];
            }
            return nil;
        }
    }
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:[jsonActivityStreamArray count]];
    for (NSDictionary *activityDict in jsonActivityStreamArray) {
        [resultArray addObject:[self activityEntryFromJSON:activityDict]];
    }
    return resultArray;
}

- (AlfrescoActivityEntry *)activityEntryFromJSON:(NSDictionary *)activityDict
{
    AlfrescoActivityEntry *alfEntry = [[AlfrescoActivityEntry alloc] init];
    
    alfEntry.identifier = [activityDict valueForKey:kAlfrescoJSONIdentifier];
    NSString *dateString = [activityDict valueForKey:kAlfrescoJSONActivityPostDate];
    if (nil != dateString)
    {
        alfEntry.createdAt = [self.dateFormatter dateFromString:dateString];
    }
    alfEntry.createdBy = [activityDict valueForKey:kAlfrescoJSONActivityPostUserID];
    alfEntry.siteShortName = [activityDict valueForKey:kAlfrescoJSONActivitySiteNetwork];
    alfEntry.type = [activityDict valueForKey:kAlfrescoJSONActivityType];
    NSError *error;
    alfEntry.data = [NSJSONSerialization JSONObjectWithData:[[activityDict valueForKey:kAlfrescoJSONActivitySummary] dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:kNilOptions error:&error];
    
    return alfEntry;
}

@end
