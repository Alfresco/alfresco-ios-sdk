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

#import "AlfrescoCloudPersonService.h"
#import "AlfrescoInternalConstants.h"

NSString * const kAlfrescoSearchNotImplemented = @"searchWithKeywords is not implemented as Alfresco in the Cloud does not have this capability";

@interface AlfrescoCloudPersonService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@end

@implementation AlfrescoCloudPersonService

- (id)initWithSession:(id<AlfrescoSession>)session
{
    if (self = [super initWithSession:session])
    {
        self.session = session;
        self.baseApiUrl = [[self.session.baseUrl absoluteString] stringByAppendingString:kAlfrescoCloudAPIPath];
    }
    return self;
}

- (AlfrescoRequest *)searchWithKeywords:(NSString *)keywords completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    NSException *exception = [NSException exceptionWithName:NSGenericException reason:kAlfrescoSearchNotImplemented userInfo:nil];
    @throw exception;
}

- (AlfrescoRequest *)searchWithKeywords:(NSString *)keywords
                         listingContext:(AlfrescoListingContext *)listingContext
                        completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    NSException *exception = [NSException exceptionWithName:NSGenericException reason:kAlfrescoSearchNotImplemented userInfo:nil];
    @throw exception;
}

@end
