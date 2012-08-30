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

#import "AlfrescoSiteService.h"
#import "AlfrescoPlaceholderSiteService.h"

@implementation AlfrescoSiteService

+ (id)alloc
{
    if (self == [AlfrescoSiteService self])
    {
        return [AlfrescoPlaceholderSiteService alloc];
    }
    else
    {
        return [super alloc];
    }
}

- (id)initWithSession:(id<AlfrescoSession>)session
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)retrieveAllSitesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)retrieveAllSitesWithListingContext:(AlfrescoListingContext *)listingContext
                           completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)retrieveSitesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)retrieveSitesWithListingContext:(AlfrescoListingContext *)listingContext
                        completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
}


- (void)retrieveFavoriteSitesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)retrieveFavoriteSitesWithListingContext:(AlfrescoListingContext *)listingContext
                                completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)retrieveSiteWithShortName:(NSString *)siteShortName
                  completionBlock:(AlfrescoSiteCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)retrieveDocumentLibraryFolderForSite:(NSString *)siteShortName
                             completionBlock:(AlfrescoFolderCompletionBlock)completionBlock
{
    [self doesNotRecognizeSelector:_cmd];
}


@end
