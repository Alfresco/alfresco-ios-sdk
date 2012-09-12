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

#import "AlfrescoVersionServiceTest.h"
#import "AlfrescoDocumentFolderService.h"

@implementation AlfrescoVersionServiceTest

@synthesize versionService = _versionService;
/*
 */

- (void)testRetrieveAllVersions
{
    [super runAllSitesTest:^{
        
        self.versionService = [[AlfrescoVersionService alloc] initWithSession:super.currentSession];
        __block AlfrescoDocumentFolderService *documentService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        
        
        [documentService retrieveNodeWithIdentifier:super.testAlfrescoDocument.identifier completionBlock:^(AlfrescoNode *node, NSError *error)
        {
            if (nil == node)
            {
                documentService = nil;
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                super.callbackCompleted = YES;
            }
            else
            {                
                [self.versionService retrieveAllVersionsOfDocument:(AlfrescoDocument *)node completionBlock:^(NSArray *array, NSError *error) 
                 {
                     if (nil == array)
                     {
                         super.lastTestSuccessful = NO;
                         super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                     }
                     else
                     {                
                         STAssertNotNil(array, @"array should not be nil");
                         STAssertTrue(array.count == 1, @"expected 1 version");
                         
                         super.lastTestSuccessful = YES;
                     }
                     super.callbackCompleted = YES;
                     
                 }];
                
                documentService = nil;
            }
            
            
        }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testRetrieveAllVersionsWithPaging
{
    [super runAllSitesTest:^{
        
        self.versionService = [[AlfrescoVersionService alloc] initWithSession:super.currentSession];
        __block AlfrescoDocumentFolderService *documentService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:1 skipCount:0];
        
        [documentService retrieveNodeWithIdentifier:super.testAlfrescoDocument.identifier completionBlock:^(AlfrescoNode *node, NSError *error) 
        {
            if (nil == node)
            {
                documentService = nil;
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                super.callbackCompleted = YES;
            }
            else
            {                
                [self.versionService retrieveAllVersionsOfDocument:(AlfrescoDocument *)node listingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) 
                 {
                     if (nil == pagingResult)
                     {
                         super.lastTestSuccessful = NO;
                         super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                     }
                     else
                     {                
                         STAssertNotNil(pagingResult, @"pagingResult should not be nil");
                         STAssertTrue(pagingResult.objects.count == 1, @"expected 1 version, but got %d",pagingResult.objects.count);
                         STAssertTrue(pagingResult.totalItems >= 1, @"expected at least 1 version in total");
                         
                         super.lastTestSuccessful = YES;
                     }
                     super.callbackCompleted = YES;
                     
                 }];
                
                documentService = nil;
            }
        }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}


@end
