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

#import "AlfrescoCloudActivityStreamService.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoBasicAuthenticationProvider.h"
#import "AlfrescoErrors.h"
#import "AlfrescoHTTPUtils.h"
#import "AlfrescoPagingUtils.h"
#import "AlfrescoISO8601DateFormatter.h"
#import <objc/runtime.h>

@interface AlfrescoCloudActivityStreamService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, strong, readwrite) NSOperationQueue *operationQueue;
@property (nonatomic, strong, readwrite) AlfrescoObjectConverter *objectConverter;
@property (nonatomic, weak, readwrite) id<AlfrescoAuthenticationProvider> authenticationProvider;
@property (nonatomic, strong)AlfrescoISO8601DateFormatter *dateFormatter;

- (NSArray *) parseActivityStreamArrayWithData:(NSData *)data error:(NSError **)outError;
- (AlfrescoActivityEntry *)activityEntryFromJSON:(NSDictionary *)activityDict;

@end

@implementation AlfrescoCloudActivityStreamService
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


- (AlfrescoActivityEntry *)activityEntryFromJSON:(NSDictionary *)activityDict
{
    AlfrescoActivityEntry *alfEntry = [[AlfrescoActivityEntry alloc] init];
    
    alfEntry.identifier = [activityDict valueForKey:kAlfrescoJSONIdentifier];
    NSString *dateString = [activityDict valueForKey:kAlfrescoJSONPostedAt];
    if (nil != dateString)
    {
        alfEntry.createdAt = [self.dateFormatter dateFromString:dateString];
    }
    alfEntry.createdBy = [activityDict valueForKey:kAlfrescoJSONActivityPostPersonID];
    alfEntry.siteShortName = [activityDict valueForKey:kAlfrescoJSONSiteID];
    alfEntry.type = [activityDict valueForKey:kAlfrescoJSONActivityType];
    
    id summary = [activityDict valueForKey:kAlfrescoJSONActivitySummary];
    if ([summary isKindOfClass:[NSDictionary class]])
    {
        alfEntry.data = (NSDictionary *)summary;
    }
        
    return alfEntry;
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
    
    __weak AlfrescoCloudActivityStreamService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *requestString = [kAlfrescoCloudActivitiesAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:weakSelf.session.personIdentifier];
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

- (void)retrieveActivityStreamForPerson:(NSString *)personIdentifier listingContext:(AlfrescoListingContext *)listingContext
                        completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    NSAssert(nil != personIdentifier, @"personIdentifier must not be nil");
    NSAssert(nil != listingContext, @"listingContext must not be nil");
    NSAssert(nil != completionBlock, @"completionBlock must not be nil");
    
    __weak AlfrescoCloudActivityStreamService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *skipCountRequest = [kAlfrescoPagingRequest stringByReplacingOccurrencesOfString:kAlfrescoSkipCountRequest
                                                                                       withString:[NSString stringWithFormat:@"%d",listingContext.skipCount]];
        NSString *pagingRequest = [skipCountRequest stringByReplacingOccurrencesOfString:kAlfrescoMaxItemsRequest
                                                                                withString:[NSString stringWithFormat:@"%d",listingContext.maxItems]];
        NSString *baseRequestString = [kAlfrescoCloudActivitiesAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:weakSelf.session.personIdentifier];
        NSString *requestString = [NSString stringWithFormat:@"%@%@",baseRequestString, pagingRequest];
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

- (void)retrieveActivityStreamForSite:(AlfrescoSite *)site completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    NSAssert(nil != site, @"site must not be nil");
    NSAssert(nil != completionBlock, @"completionBlock must not be nil");
    
    __weak AlfrescoCloudActivityStreamService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *peopleRefString = [kAlfrescoCloudActivitiesForSiteAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:weakSelf.session.personIdentifier];
        NSString *requestString = [peopleRefString stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:site.shortName];
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
    
    __weak AlfrescoCloudActivityStreamService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *skipCountRequest = [kAlfrescoPagingRequest stringByReplacingOccurrencesOfString:kAlfrescoSkipCountRequest
                                                                                       withString:[NSString stringWithFormat:@"%d",listingContext.skipCount]];
        NSString *pagingRequest = [skipCountRequest stringByReplacingOccurrencesOfString:kAlfrescoMaxItemsRequest
                                                                              withString:[NSString stringWithFormat:@"%d",listingContext.maxItems]];
        
        NSString *peopleRefString = [kAlfrescoCloudActivitiesForSiteAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:weakSelf.session.personIdentifier];
        NSString *baseRequestString = [peopleRefString stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:site.shortName];
        
        NSString *requestString = [NSString stringWithFormat:@"%@%@",baseRequestString, pagingRequest];
        
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
    NSArray *entriesArray = [AlfrescoObjectConverter parseCloudJSONEntriesFromListData:data error:outError];
    if (nil == entriesArray)
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeActivityStream
                                            withDetailedDescription:@"could not parse JSON array"];
        }
        else
        {
            NSError *underlyingError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeActivityStream
                                                           withDetailedDescription:@"could not parse JSON array"];
            *outError = [AlfrescoErrors alfrescoError:underlyingError withAlfrescoErrorCode:kAlfrescoErrorCodeActivityStream];
        }
        return nil;
    }
    NSMutableArray *resultsArray = [NSMutableArray array];
    
    for (NSDictionary *entryDict in entriesArray)
    {
        NSDictionary *individualEntry = [entryDict valueForKey:kAlfrescoCloudJSONEntry];
        if (nil == individualEntry)
        {
            if (nil == *outError)
            {
                *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeActivityStream
                                                withDetailedDescription:@"activity JSON data are NIL"];
            }
            else
            {
                NSError *underlyingError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeActivityStream
                                                               withDetailedDescription:@"activity JSON data are NIL"];
                *outError = [AlfrescoErrors alfrescoError:underlyingError withAlfrescoErrorCode:kAlfrescoErrorCodeActivityStream];
            }
            return nil;
        }
        [resultsArray addObject:[self activityEntryFromJSON:individualEntry]];
    }
    return resultsArray;
}

@end
