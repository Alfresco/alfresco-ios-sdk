/*******************************************************************************
 * Copyright (C) 2005-2013 Alfresco Software Limited.
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
#import "AlfrescoURLUtils.h"
#import "AlfrescoPagingUtils.h"
#import "AlfrescoTag.h"
#import "AlfrescoNetworkProvider.h"
#import "AlfrescoLog.h"

@interface AlfrescoCloudTaggingService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, strong, readwrite) AlfrescoObjectConverter *objectConverter;
@property (nonatomic, weak, readwrite) id<AlfrescoAuthenticationProvider> authenticationProvider;
- (NSArray *) tagArrayFromJSONData:(NSData *)data error:(NSError **)outError;
//- (AlfrescoTag *)tagFromJSON:(NSDictionary *)jsonDict;
@end

@implementation AlfrescoCloudTaggingService

- (id)initWithSession:(id<AlfrescoSession>)session
{
    if (self = [super init])
    {
        self.session = session;
        self.baseApiUrl = [[self.session.baseUrl absoluteString] stringByAppendingString:kAlfrescoCloudAPIPath];
        self.objectConverter = [[AlfrescoObjectConverter alloc] initWithSession:self.session];
        id authenticationObject = [session objectForParameter:kAlfrescoAuthenticationProviderObjectKey];
        self.authenticationProvider = nil;
        if ([authenticationObject isKindOfClass:[AlfrescoBasicAuthenticationProvider class]])
        {
            self.authenticationProvider = (AlfrescoBasicAuthenticationProvider *)authenticationObject;
        }
    }
    return self;
}


- (AlfrescoRequest *)retrieveAllTagsWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    NSAssert(nil != completionBlock, @"completionBlock must not be nil");
//    __weak AlfrescoCloudTaggingService *weakSelf = self;
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoCloudTagsAPI];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url
                                                session:self.session
                                        alfrescoRequest:request
                                        completionBlock:^(NSData *data, NSError *error){
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *tagArray = [self tagArrayFromJSONData:data error:&conversionError];
            completionBlock(tagArray, conversionError);
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveAllTagsWithListingContext:(AlfrescoListingContext *)listingContext
                          completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
//    __weak AlfrescoCloudTaggingService *weakSelf = self;
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:kAlfrescoCloudTagsAPI];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url
                                                session:self.session
                                        alfrescoRequest:request
                                        completionBlock:^(NSData *data, NSError *error){
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *tagArray = [self tagArrayFromJSONData:data error:&conversionError];
            AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:tagArray listingContext:listingContext];
            completionBlock(pagingResult, conversionError);
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveTagsForNode:(AlfrescoNode *)node
            completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentName:@"node.identifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
//    __weak AlfrescoCloudTaggingService *weakSelf = self;
    NSString *requestString = [kAlfrescoCloudTagsForNodeAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef
                                                                                      withString:[node.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"]];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url
                                                session:self.session
                                        alfrescoRequest:request
                                        completionBlock:^(NSData *data, NSError *error){
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *tagArray = [self tagArrayFromJSONData:data error:&conversionError];
            completionBlock(tagArray, conversionError);
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveTagsForNode:(AlfrescoNode *)node listingContext:(AlfrescoListingContext *)listingContext
            completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentName:@"node.identifier"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    if (nil == listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
//    __weak AlfrescoCloudTaggingService *weakSelf = self;
    NSString *requestString = [kAlfrescoCloudTagsForNodeAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef
                                                                                      withString:[node.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"]];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url
                                                session:self.session
                                        alfrescoRequest:request
                                        completionBlock:^(NSData *data, NSError *error){
        if (nil == data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *tagArray = [self tagArrayFromJSONData:data error:&conversionError];
            AlfrescoPagingResult *pagingResult = [AlfrescoPagingUtils pagedResultFromArray:tagArray listingContext:listingContext];
            completionBlock(pagingResult, conversionError);
        }
    }];
    return request;
}


- (AlfrescoRequest *)addTags:(NSArray *)tags toNode:(AlfrescoNode *)node
completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:node argumentName:@"node"];
    [AlfrescoErrors assertArgumentNotNil:node.identifier argumentName:@"node.identifier"];
    [AlfrescoErrors assertArgumentNotNil:tags argumentName:@"tags"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    if (0 == tags.count)
    {
        return nil;
    }
    
    NSString *requestString = [kAlfrescoCloudTagsForNodeAPI stringByReplacingOccurrencesOfString:kAlfrescoNodeRef
                                                                                      withString:[node.identifier stringByReplacingOccurrencesOfString:@"://" withString:@"/"]];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    NSData *jsonData = nil;
    NSError *jsonError = nil;
    if (1 == tags.count)
    {
        NSMutableDictionary *tagDictionary = [NSMutableDictionary dictionary];
        [tagDictionary setValue:[tags objectAtIndex:0] forKey:kAlfrescoJSONTag];
        
        jsonData = [NSJSONSerialization dataWithJSONObject:tagDictionary options:kNilOptions error:&jsonError];
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
        jsonData = [NSJSONSerialization dataWithJSONObject:tagJSONArray options:kNilOptions error:&jsonError];
    }
    if (nil != jsonData)
    {
        AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
        [self.session.networkProvider executeRequestWithURL:url
                                                    session:self.session
                                                requestBody:jsonData
                                                     method:kAlfrescoHTTPPOST
                                            alfrescoRequest:request
                                            completionBlock:^(NSData *data, NSError *error){
            if (nil != error)
            {
                completionBlock(NO, error);
            }
            else
            {
                completionBlock(YES, nil);
            }
        }];
        return request;
    }
    else
    {
        completionBlock(NO, jsonError);
        return nil;
    }
        
}


#pragma mark Site service internal methods

- (NSArray *) tagArrayFromJSONData:(NSData *)data error:(NSError **)outError
{    
    AlfrescoLogDebug(@"JSON data: %@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
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
                *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeTaggingNoTags];
            }
            else
            {
                NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeTaggingNoTags];
                *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeTaggingNoTags];
                
            }
            return nil;
        }
        AlfrescoTag *tag = [[AlfrescoTag alloc] initWithProperties:individualEntry];
//        AlfrescoTag *tag = [self tagFromJSON:individualEntry];
        [resultsArray addObject:tag];
    }
    return resultsArray;
}

/*
- (AlfrescoTag *)tagFromJSON:(NSDictionary *)jsonDict
{
    AlfrescoTag *tag = [[AlfrescoTag alloc]init];
    tag.value = [jsonDict valueForKey:kAlfrescoJSONTag];
    tag.identifier = [jsonDict valueForKey:kAlfrescoJSONIdentifier];
    return tag;
}
*/


@end
