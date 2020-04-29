/*******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
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
#import "AlfrescoPersonService.h"

@implementation AlfrescoSiteServiceTest

/*
 @Unique_TCRef 45S1
 */
- (void)testRetrieveAllSites
{
    if (self.setUpSuccess)
    {
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        // get all sites
        [self.siteService retrieveAllSitesWithCompletionBlock:^(NSArray *array, NSError *error) {
            if (nil == array)
            {
                XCTAssertNil(array, @"the array should be nil");
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                XCTAssertNotNil(array,@"the array should not be nil");
                XCTAssertTrue(array.count > 2, @"Site count should be greater than 2 not %lu", (unsigned long)array.count);
                self.lastTestSuccessful = YES;
            }
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 @Unique_TCRef 46S1
 */
- (void)testRetrieveAllSitesWithPaging
{
    if (self.setUpSuccess)
    {
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:2 skipCount:1];
        
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        // get all sites
        [self.siteService retrieveAllSitesWithListingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
            if (nil == pagingResult)
            {
                XCTAssertNil(pagingResult,@"if failure, the paging result should be nil");
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                XCTAssertNotNil(pagingResult, @"paged result should not be nil");
                XCTAssertNotNil(pagingResult.objects, @"objects array should not be nil");
                XCTAssertTrue(pagingResult.objects.count == 2, @"Site count should be 2 but was %lu", (unsigned long)pagingResult.objects.count);
                self.lastTestSuccessful = YES;
            }
            
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}


/*
 @Unique_TCRef 47S0
 */
- (void)testRetrieveSitesForUser
{
    if (self.setUpSuccess)
    {
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        [self.siteService retrieveSitesWithCompletionBlock:^(NSArray *array, NSError *error) {
            if (nil == array)
            {
                XCTAssertNil(array,@"if failure, the array should be nil");
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                XCTAssertNotNil(array,@"The sites array should not be nil");
                XCTAssertTrue(array.count > 1, @"Expected multiple sites but got zero");
                for (AlfrescoSite *site in array)
                {
                    XCTAssertTrue(site.isMember, @"Site %@ should be marked as being a member site", site.identifier);
                }
                self.lastTestSuccessful = YES;
            }
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}


/*
 @Unique_TCRef 48S0
 */
- (void)testRetrieveSitesForUserWithPaging
{
    if (self.setUpSuccess)
    {
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:2 skipCount:1];
        
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        [self.siteService retrieveSitesWithListingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
            if (nil == pagingResult)
            {
                XCTAssertNil(pagingResult,@"if failure, the paging result should be nil");
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                XCTAssertNotNil(pagingResult, @"paged result should not be nil");
                for (AlfrescoSite *site in pagingResult.objects)
                {
                    XCTAssertTrue(site.isMember, @"Site %@ should be marked as being a member site", site.identifier);
                }
                self.lastTestSuccessful = YES;
            }
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}


/*
 @Unique_TCRef 49S0
 */
- (void)testRetrieveFavoriteSitesForUser
{
    if (self.setUpSuccess)
    {
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        [self.siteService retrieveFavoriteSitesWithCompletionBlock:^(NSArray *array, NSError *error) {
            if (nil == array)
            {
                XCTAssertNil(array,@"if failure, the array should be nil");
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                XCTAssertNotNil(array,@"the array should not be nil");
                XCTAssertTrue(array.count >= 1, @"Expected multiple favorite sites but got %lu", (unsigned long)array.count);
                for (AlfrescoSite *site in array)
                {
                    XCTAssertTrue(site.isFavorite, @"Site %@ should be marked as favourite", site.identifier);
                }
                self.lastTestSuccessful = YES;
            }
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}


/*
 @Unique_TCRef 50S0
 */
- (void)testRetrieveFavoriteSitesForUserWithPaging
{
    if (self.setUpSuccess)
    {
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:1 skipCount:1];
        
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        [self.siteService retrieveFavoriteSitesWithListingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
            if (nil == pagingResult)
            {
                XCTAssertNil(pagingResult,@"if failure, the paging result should be nil");
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                XCTAssertNotNil(pagingResult, @"paged result should not be nil");
                XCTAssertTrue(pagingResult.totalItems >= 1, @"Total favorite site count should be at least 1, but we got %d", pagingResult.totalItems);
                if (pagingResult.totalItems > 1)
                {
                    XCTAssertTrue(pagingResult.objects.count == 1, @"Favorite site count should be 1, instead we get %lu", (unsigned long)pagingResult.objects.count);
                    for (AlfrescoSite *site in pagingResult.objects)
                    {
                        XCTAssertTrue(site.isFavorite, @"site %@ should be marked as favourite", site.identifier);
                    }
                }
                else
                {
                    XCTAssertTrue(pagingResult.objects.count == 0, @"Favorite site count should be 0, instead we get %lu", (unsigned long)pagingResult.objects.count);
                }
                self.lastTestSuccessful = YES;
            }
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}


/*
 @Unique_TCRef 44S1
 */
- (void)testRetrieveSiteWithShortName
{
    if (self.setUpSuccess)
    {
        // get all sites
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        [self.siteService retrieveSiteWithShortName:self.testSiteName completionBlock:^(AlfrescoSite *site, NSError *error) {
            if (nil == site || nil != error)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                XCTAssertTrue([site.shortName isEqualToString:self.testSiteName], @"Expected %@ site but got back %@", self.testSiteName, site.shortName);
                XCTAssertNotNil(site.title, @"site title should not be nil");
                XCTAssertNotNil(site.summary, @"site summary should not be nil");
                self.lastTestSuccessful = YES;
            }
            
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}


/*
 @Unique_TCRef 44F2/F3
 */
- (void)testRetrieveSiteWithNonExistingShortName
{
    if (self.setUpSuccess)
    {
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        // get all sites
        [self.siteService retrieveSiteWithShortName:@"asfadsfsdfds" completionBlock:^(AlfrescoSite *site, NSError *error) {
            if (nil != site || nil == error)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                self.lastTestSuccessful = YES;
            }
            
            self.callbackCompleted = YES;
            
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}



/*
 @Unique_TCRef 51S0
 */
- (void)testRetrieveDocumentLibraryForSite
{
    if (self.setUpSuccess)
    {
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        // get document library folder for site
        [self.siteService retrieveDocumentLibraryFolderForSite:self.testSiteName completionBlock:^(AlfrescoFolder *folder, NSError *error) {
            if (nil == folder)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                XCTAssertNotNil(folder, @"folder should not be nil");
                XCTAssertTrue([folder.name isEqualToString:@"documentLibrary"], @"Folder name should be documentLibrary");
                
                self.lastTestSuccessful = YES;
            }
            
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}


/*
 @Unique_TCRef 51F1
 */
- (void)testRetrieveDocumentLibraryForNonExistingSite
{
    if (self.setUpSuccess)
    {
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        // get document library folder for site
        [self.siteService retrieveDocumentLibraryFolderForSite:@"asdfsdfsdfsdf" completionBlock:^(AlfrescoFolder *folder, NSError *error) {
            if (nil != folder)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                self.lastTestSuccessful = YES;
            }
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}


- (void)testRetrievePendingSitesForUser
{
    if (self.setUpSuccess)
    {
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        [self.siteService retrievePendingSitesWithCompletionBlock:^(NSArray *array, NSError *error) {
            if (nil == array)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertTrue(array.count >= 0, @"Array needs to be >= 0");
                if (0 < array.count)
                {
                    [array enumerateObjectsUsingBlock:^(AlfrescoSite *site, NSUInteger index, BOOL *stop) {
                        XCTAssertTrue(site.isPendingMember, @"The requested site should be in state isPendingMember, but appears not to be.");
                    }];
                }
                self.lastTestSuccessful = YES;
                self.callbackCompleted = YES;
            }
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
    
}

- (void)testRetrievePendingSitesForUserWithListingContext
{
    if (self.setUpSuccess)
    {
        // get all sites for user admin
        
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:2 skipCount:0];
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        [self.siteService retrievePendingSitesWithListingContext:paging completionblock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
            if (nil == pagingResult)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertTrue(pagingResult.objects.count >= 0, @"Array needs to be >= 0");
                if (0 < pagingResult.objects.count)
                {
                    [pagingResult.objects enumerateObjectsUsingBlock:^(AlfrescoSite *site, NSUInteger index, BOOL *stop) {
                        XCTAssertTrue(site.isPendingMember, @"The requested site should be in state isPendingMember, but appears not to be.");
                    }];
                }
                self.lastTestSuccessful = YES;
                self.callbackCompleted = YES;
                
            }
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
    
}

- (void)testRetrieveMembersForSite
{
    if (self.setUpSuccess)
    {
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        [self.siteService retrieveSiteWithShortName:self.testSiteName completionBlock:^(AlfrescoSite *site, NSError *error) {
             if (nil == site)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else
             {
                 [self.siteService retrieveAllMembersOfSite:site completionBlock:^(NSArray *allSiteMembers, NSError *error) {
                     if (allSiteMembers == nil)
                     {
                         self.lastTestSuccessful = NO;
                         self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                     }
                     else
                     {
                         // check there is at least one member in the array
                         XCTAssertTrue(allSiteMembers.count > 0, @"There should be at least one member of the test site");
                         
                         BOOL testUserFound = NO;
                         for (AlfrescoPerson *person in allSiteMembers)
                         {
                             if ([person.identifier isEqualToString:self.userName])
                             {
                                 testUserFound = YES;
                             }
                         }
                         
                         if (testUserFound)
                         {
                             // we found the user we expected, now retrieve with paging
                             AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:1];
                             [self.siteService retrieveAllMembersOfSite:site listingContext:paging
                                                        completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
                                 if (pagingResult == nil)
                                 {
                                     self.lastTestSuccessful = NO;
                                     self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                 }
                                 else
                                 {
                                     // check paging results are what we are expecting them to be
                                     XCTAssertTrue(pagingResult.objects.count == 1, @"There should be one member of the test site returned");
                                     
                                     if (allSiteMembers.count == 1)
                                     {
                                         // we know there is only one result, check paging result is correct
                                         if (!self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
                                         {
                                             XCTAssertTrue(pagingResult.totalItems == 1, @"Expecting the paging totalItems count to be 1 but it was: %d", pagingResult.totalItems);
                                         }
                                         XCTAssertFalse(pagingResult.hasMoreItems, @"Expected the paging result to indicate there were no more items");
                                         
                                         // we know there is only one member so check it's the correct one
                                         AlfrescoPerson *person = pagingResult.objects.firstObject;
                                         self.lastTestSuccessful = [person.identifier isEqualToString:self.userName];
                                         if (!self.lastTestSuccessful)
                                         {
                                             self.lastTestFailureMessage = @"We expected the one member of the site to be the test user";
                                         }
                                     }
                                     else
                                     {
                                         // we know there are more results, check paging result is correct
                                         if (!self.currentSession.repositoryInfo.capabilities.doesSupportPublicAPI)
                                         {
                                             XCTAssertTrue(pagingResult.totalItems == allSiteMembers.count, @"Expecting the paging totalItems count to be the same as the number of site members: %lu", (unsigned long)allSiteMembers.count);
                                         }
                                         XCTAssertTrue(pagingResult.hasMoreItems, @"Expected the paging result to indicate there were more items");
                                         
                                         // make sure the object type is correct
                                         XCTAssertTrue([pagingResult.objects.firstObject isKindOfClass:[AlfrescoPerson class]], @"Expected to find an AlfrescoPerson object in the objects array but found: %@", pagingResult.objects.firstObject);
                                         
                                         self.lastTestSuccessful = YES;
                                     }
                                 }
                                 self.callbackCompleted = YES;
                             }];
                         }
                         else
                         {
                             self.lastTestSuccessful = NO;
                             self.lastTestFailureMessage = @"Failed to found the test user as a member of the test site";
                             self.callbackCompleted = YES;
                         }
                     }
                 }];
             }
         }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRetrieveFilteredMembersForSite
{
    if (self.setUpSuccess)
    {
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        [self.siteService retrieveSiteWithShortName:self.testSiteName completionBlock:^(AlfrescoSite *site, NSError *error) {
             if (site == nil)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else
             {
                 [self.siteService searchMembersOfSite:site keywords:self.userName listingContext:nil
                                       completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
                     if (pagingResult == nil)
                     {
                         self.lastTestSuccessful = NO;
                         self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                     }
                     else
                     {
                         // there should be one result
                         XCTAssertTrue(pagingResult.objects.count == 1, @"Exepcted to find 1 result");
                         XCTAssertTrue(pagingResult.totalItems == 1, @"Expecting the paging totalItems count to be 1 but it was: %d", pagingResult.totalItems);
                         XCTAssertFalse(pagingResult.hasMoreItems, @"Expected the paging result to indicate there were no more items");
                         XCTAssertTrue([pagingResult.objects.firstObject isKindOfClass:[AlfrescoPerson class]], @"Expected to find an AlfrescoPerson object in the objects array but found: %@", pagingResult.objects.firstObject);
                         
                         self.lastTestSuccessful = YES;
                     }
                     self.callbackCompleted = YES;
                 }];
             }
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testPersonIsMemberOfSite
{
    if (self.setUpSuccess)
    {
        AlfrescoPersonService *personService = [[AlfrescoPersonService alloc] initWithSession:self.currentSession];
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        [personService retrievePersonWithIdentifier:self.userName completionBlock:^(AlfrescoPerson *person, NSError *error) {
            if (person == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                [self.siteService retrieveSiteWithShortName:self.testSiteName completionBlock:^(AlfrescoSite *site, NSError *error) {
                     if (site == nil)
                     {
                         self.lastTestSuccessful = NO;
                         self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                     }
                     else
                     {
                         [self.siteService isPerson:person memberOfSite:site completionBlock:^(BOOL succeeded, BOOL isMember, NSError *error) {
                             if (!succeeded)
                             {
                                 self.lastTestSuccessful = NO;
                                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                             }
                             else
                             {
                                 // we know the test user is a member of the test site so check the result
                                 XCTAssertTrue(isMember, @"Expected the test user to be a member of the test site");
                                 
                                 self.lastTestSuccessful = YES;
                             }
                             self.callbackCompleted = YES;
                         }];
                     }
                }];
            }
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/** MOBSDK-711 */
- (void)testConcurrentSiteCacheBuilding
{
    if (self.setUpSuccess)
    {
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        __block int resultCount = 0;
        
        void (^completionBlock)(NSArray *, NSError *) = ^(NSArray *sites, NSError *error)
        {
            if (error != nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            
            resultCount++;
            
            XCTAssertTrue(sites.count > 0, @"Expected to retrieve at least one site from each method");
            
            if (resultCount == 3)
            {
                self.lastTestSuccessful = YES;
                self.callbackCompleted = YES;
            }
        };
        
        // request all types of site at once, this should create parallel requests to build the site caches
        [self.siteService retrieveSitesWithCompletionBlock:completionBlock];
        [self.siteService retrieveAllSitesWithCompletionBlock:completionBlock];
        [self.siteService retrieveFavoriteSitesWithCompletionBlock:completionBlock];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRetrieveAllPrivateSites
{
    if (self.setUpSuccess)
    {
        AlfrescoListingFilter *filter = [[AlfrescoListingFilter alloc] initWithFilter:kAlfrescoFilterBySiteVisibility
                                                                                value:kAlfrescoFilterValueSiteVisibilityPrivate];
        AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithListingFilter:filter];
        
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        // get all sites
        [self.siteService retrieveAllSitesWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
            if (nil == pagingResult)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [self failureMessageFromError:error];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(pagingResult.objects, @"objects array should not be nil");
                
                // make sure all returned sites are private
                for (AlfrescoSite *site in pagingResult.objects)
                {
                    XCTAssertTrue(site.visibility == AlfrescoSiteVisibilityPrivate, @"Expected all returned sites to be private");
                }
                
                self.lastTestSuccessful = YES;
            }
            
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRetrieveAllModeratedSites
{
    if (self.setUpSuccess)
    {
        AlfrescoListingFilter *filter = [[AlfrescoListingFilter alloc] initWithFilter:kAlfrescoFilterBySiteVisibility
                                                                                value:kAlfrescoFilterValueSiteVisibilityModerated];
        AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithListingFilter:filter];
        
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        // get all sites
        [self.siteService retrieveAllSitesWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
            if (nil == pagingResult)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [self failureMessageFromError:error];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(pagingResult.objects, @"objects array should not be nil");
                
                // make sure all returned sites are moderated
                for (AlfrescoSite *site in pagingResult.objects)
                {
                    XCTAssertTrue(site.visibility == AlfrescoSiteVisibilityModerated, @"Expected all returned sites to be moderated");
                }
                
                self.lastTestSuccessful = YES;
            }
            
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRetrieveAllPublicSites
{
    if (self.setUpSuccess)
    {
        AlfrescoListingFilter *filter = [[AlfrescoListingFilter alloc] initWithFilter:kAlfrescoFilterBySiteVisibility
                                                                                value:kAlfrescoFilterValueSiteVisibilityPublic];
        AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithListingFilter:filter];
        
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        // get all sites
        [self.siteService retrieveAllSitesWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
            if (nil == pagingResult)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [self failureMessageFromError:error];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(pagingResult.objects, @"objects array should not be nil");
                
                // make sure all returned sites are public
                for (AlfrescoSite *site in pagingResult.objects)
                {
                    XCTAssertTrue(site.visibility == AlfrescoSiteVisibilityPublic, @"Expected all returned sites to be public");
                }
                
                self.lastTestSuccessful = YES;
            }
            
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRetrievePrivateSitesForUser
{
    if (self.setUpSuccess)
    {
        AlfrescoListingFilter *filter = [[AlfrescoListingFilter alloc] initWithFilter:kAlfrescoFilterBySiteVisibility
                                                                                value:kAlfrescoFilterValueSiteVisibilityPrivate];
        AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithListingFilter:filter];
        
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        [self.siteService retrieveSitesWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
            if (nil == pagingResult)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [self failureMessageFromError:error];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(pagingResult.objects, @"objects array should not be nil");
                
                // make sure all returned sites are private
                for (AlfrescoSite *site in pagingResult.objects)
                {
                    XCTAssertTrue(site.visibility == AlfrescoSiteVisibilityPrivate, @"Expected all returned sites to be private");
                }
                
                self.lastTestSuccessful = YES;
            }
            
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRetrieveModeratedSitesForUser
{
    if (self.setUpSuccess)
    {
        AlfrescoListingFilter *filter = [[AlfrescoListingFilter alloc] initWithFilter:kAlfrescoFilterBySiteVisibility
                                                                                value:kAlfrescoFilterValueSiteVisibilityModerated];
        AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithListingFilter:filter];
        
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        [self.siteService retrieveSitesWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
            if (nil == pagingResult)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [self failureMessageFromError:error];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(pagingResult.objects, @"objects array should not be nil");
                
                // make sure all returned sites are private
                for (AlfrescoSite *site in pagingResult.objects)
                {
                    XCTAssertTrue(site.visibility == AlfrescoSiteVisibilityModerated, @"Expected all returned sites to be moderated");
                }
                
                self.lastTestSuccessful = YES;
            }
            
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRetrievePublicSitesForUser
{
    if (self.setUpSuccess)
    {
        AlfrescoListingFilter *filter = [[AlfrescoListingFilter alloc] initWithFilter:kAlfrescoFilterBySiteVisibility
                                                                                value:kAlfrescoFilterValueSiteVisibilityPublic];
        AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithListingFilter:filter];
        
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        [self.siteService retrieveSitesWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
            if (nil == pagingResult)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [self failureMessageFromError:error];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(pagingResult.objects, @"objects array should not be nil");
                
                // make sure all returned sites are public
                for (AlfrescoSite *site in pagingResult.objects)
                {
                    XCTAssertTrue(site.visibility == AlfrescoSiteVisibilityPublic, @"Expected all returned sites to be public");
                }
                
                self.lastTestSuccessful = YES;
            }
            
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testSearchSitesWithKeywords
{
    if (self.setUpSuccess)
    {
        if (!self.isCloud)
        {
            self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
            
            [self.siteService searchWithKeywords:@"ios"
                                 completionBlock:^(NSArray *array, NSError *error) {
                                            
                if (nil == array)
                {
                    self.lastTestSuccessful = NO;
                    self.lastTestFailureMessage = [self failureMessageFromError:error];
                    self.callbackCompleted = YES;
                }
                else
                {
                    XCTAssertTrue(array.count > 0, @"Site array length should be > 0 but it was %@", @(array.count));
                    
                    // Look for the two test sites
                    BOOL didFindTestSite = NO;
                    BOOL didFindModeratedSite = NO;
                    
                    for (AlfrescoSite *site in array)
                    {
                        if ([site.shortName isEqualToString:self.testSiteName])
                        {
                            didFindTestSite = YES;
                        }
                        
                        if ([site.shortName isEqualToString:self.moderatedSiteName])
                        {
                            didFindModeratedSite = YES;
                        }
                    }
                    
                    self.lastTestSuccessful = didFindTestSite && didFindModeratedSite;
                }
                
                self.callbackCompleted = YES;
            }];
        }
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

@end
