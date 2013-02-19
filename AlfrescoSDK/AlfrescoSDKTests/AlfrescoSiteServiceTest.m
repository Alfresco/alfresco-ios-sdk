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

#import "AlfrescoSiteServiceTest.h"
#import "AlfrescoSite.h"

@implementation AlfrescoSiteServiceTest

@synthesize siteService = _siteService;
/*
 @Unique_TCRef 45S1
 */
- (void)testRetrieveAllSites
{
    [super runAllSitesTest:^{
        
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:super.currentSession];
        
        // get all sites
        [self.siteService retrieveAllSitesWithCompletionBlock:^(NSArray *array, NSError *error) 
        {
            
            if (nil == array) 
            {
                STAssertNil(array,@"if failure, the array should be nil");
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else 
            {
                STAssertNotNil(array,@"the array should not be nil");
                STAssertTrue(array.count > 1, [NSString stringWithFormat:@"Site count should be greater than 1 not %i", array.count]);
                super.lastTestSuccessful = YES;
            }
            super.callbackCompleted = YES;
            
        }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}




/*
 @Unique_TCRef 46S1
 */
- (void)testRetrieveAllSitesWithPaging
{
    [super runAllSitesTest:^{
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:2 skipCount:1];
        
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:super.currentSession];
        
        // get all sites
        [self.siteService retrieveAllSitesWithListingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) 
        {
            if (nil == pagingResult) 
            {
                STAssertNil(pagingResult,@"if failure, the paging result should be nil");
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                STAssertNotNil(pagingResult, @"paged result should not be nil");
                super.lastTestSuccessful = YES;
            }
            
            
            super.callbackCompleted = YES;
            
        }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}


/*
 @Unique_TCRef 47S0
 */
- (void)testRetrieveSitesForUser
{
    [super runAllSitesTest:^{
        // get all sites for user admin
        
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:super.currentSession];
        
        [self.siteService retrieveSitesWithCompletionBlock:^(NSArray *array, NSError *error) 
        {
            if (nil == array) 
            {
                STAssertNil(array,@"if failure, the array should be nil");
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else 
            {
                STAssertNotNil(array,@"the array should not be nil");
                STAssertTrue(array.count > 1, @"Expected multiple sites");
                super.lastTestSuccessful = YES;
            }
            super.callbackCompleted = YES;
            
        }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}


/*
 @Unique_TCRef 48S0
 */
- (void)testRetrieveSitesForUserWithPaging
{
    [super runAllSitesTest:^{
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:2 skipCount:1];
                
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:super.currentSession];
        
        [self.siteService retrieveSitesWithListingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) 
        {
            if (nil == pagingResult) 
            {
                STAssertNil(pagingResult,@"if failure, the paging result should be nil");
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else 
            {
                STAssertNotNil(pagingResult, @"paged result should not be nil");
                super.lastTestSuccessful = YES;
            }
            super.callbackCompleted = YES;
        }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}


/*
 @Unique_TCRef 49S0
 */
- (void)testRetrieveFavoriteSitesForUser
{
    [super runAllSitesTest:^{
        
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:super.currentSession];
        
        [self.siteService retrieveFavoriteSitesWithCompletionBlock:^(NSArray *array, NSError *error) 
        {
            if (nil == array) 
            {
                STAssertNil(array,@"if failure, the array should be nil");
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else 
            {
                STAssertNotNil(array,@"the array should not be nil");
                STAssertTrue(array.count >= 1, @"Expected multiple favorite sites but got %d",array.count);
                super.lastTestSuccessful = YES;
            }
            super.callbackCompleted = YES;
        
        }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}



/*
 @Unique_TCRef 50S0
 */
- (void)testRetrieveFavoriteSitesForUserWithPaging
{
    [super runAllSitesTest:^{
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:1 skipCount:1];
        
        
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:super.currentSession];
        
        [self.siteService retrieveFavoriteSitesWithListingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) 
        {
            if (nil == pagingResult) 
            {
                STAssertNil(pagingResult,@"if failure, the paging result should be nil");
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else 
            {
                STAssertNotNil(pagingResult, @"paged result should not be nil");
                STAssertTrue(pagingResult.totalItems >= 1, @"Total favorite site count should be at least 1, but we got %d", pagingResult.totalItems);
                if (pagingResult.totalItems > 1)
                {
                    STAssertTrue(pagingResult.objects.count == 1, @"Favorite site count should be 1, instead we get %d", pagingResult.objects.count);
                }
                else
                {
                    STAssertTrue(pagingResult.objects.count == 0, @"Favorite site count should be 0, instead we get %d", pagingResult.objects.count);
                }
                super.lastTestSuccessful = YES;
            }
            super.callbackCompleted = YES;
            
        }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}


/*
 @Unique_TCRef 44S1
 */
- (void)testRetrieveSiteWithShortName
{
    [super runAllSitesTest:^{
        // get all sites
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:super.currentSession];
        
        [self.siteService retrieveSiteWithShortName:super.testSiteName completionBlock:^(AlfrescoSite *site, NSError *error)
        {
            if (nil == site || nil != error) 
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else 
            {
                STAssertTrue([site.shortName isEqualToString:super.testSiteName], [NSString stringWithFormat:@"Expected %@ site but got back %@",super.testSiteName, site.shortName]);
                STAssertNotNil(site.title, @"site title should not be nil");
                STAssertNotNil(site.summary, @"site summary should not be nil");
                super.lastTestSuccessful = YES;
            }
            
            super.callbackCompleted = YES;
            
        }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}


/*
 @Unique_TCRef 44F2/F3
 */
- (void)testRetrieveSiteWithNonExistingShortName
{
    [super runAllSitesTest:^{
        
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:super.currentSession];
        
        // get all sites
        [self.siteService retrieveSiteWithShortName:@"asfadsfsdfds" completionBlock:^(AlfrescoSite *site, NSError *error) 
        {
            if (nil == site || nil != error) 
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else 
            {
                super.lastTestSuccessful = YES;
            }
            
            super.callbackCompleted = YES;
            
        }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertFalse(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}



/*
 @Unique_TCRef 51S0
 */
- (void)testRetrieveDocumentLibraryForSite
{
    [super runAllSitesTest:^{
        
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:super.currentSession];
        
        // get document library folder for site
        [self.siteService retrieveDocumentLibraryFolderForSite:super.testSiteName completionBlock:^(AlfrescoFolder *folder, NSError *error)
        {
            if (nil == folder) 
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else 
            {
                STAssertNotNil(folder, @"folder should not be nil");
                STAssertTrue([folder.name isEqualToString:@"documentLibrary"], @"Folder name should be documentLibrary");
                
                super.lastTestSuccessful = YES;
            }
            
            super.callbackCompleted = YES;
        
        }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}



/*
 @Unique_TCRef 51F1
 */
- (void)testRetrieveDocumentLibraryForNonExistingSite
{
    [super runAllSitesTest:^{
        
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:super.currentSession];
        
        // get document library folder for site
        [self.siteService retrieveDocumentLibraryFolderForSite:@"asdfsdfsdfsdf" completionBlock:^(AlfrescoFolder *folder, NSError *error) 
        {
            if (nil == folder) 
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else 
            {
                super.lastTestSuccessful = YES;
            }
            super.callbackCompleted = YES;
            
        }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertFalse(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}


#pragma mark unit test internal methods

- (BOOL)siteArray:(NSArray *)siteArray containsShortName:(NSString *)shortName
{
    for (AlfrescoSite *site in siteArray) {
        if([site.shortName isEqualToString:shortName] == YES)
        {
            return YES;
        }
    }
    return NO;
}
@end