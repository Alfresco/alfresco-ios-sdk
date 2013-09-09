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
#import "AlfrescoPersonService.h"
#import "AlfrescoSite.h"
#import "AlfrescoLog.h"

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
        [self.siteService retrieveAllSitesWithCompletionBlock:^(NSArray *array, NSError *error)
         {
             
             if (nil == array)
             {
                 STAssertNil(array,@"if failure, the array should be nil");
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else
             {
                 STAssertNotNil(array,@"the array should not be nil");
                 STAssertTrue(array.count > 1, @"Site count should be greater than 1 not %i", array.count);
                 self.lastTestSuccessful = YES;
             }
             self.callbackCompleted = YES;
             
         }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
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
        [self.siteService retrieveAllSitesWithListingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error)
         {
             if (nil == pagingResult)
             {
                 STAssertNil(pagingResult,@"if failure, the paging result should be nil");
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else
             {
                 STAssertNotNil(pagingResult, @"paged result should not be nil");
                 self.lastTestSuccessful = YES;
             }
             
             
             self.callbackCompleted = YES;
             
         }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
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
        
        [self.siteService retrieveSitesWithCompletionBlock:^(NSArray *array, NSError *error)
         {
             if (nil == array)
             {
                 STAssertNil(array,@"if failure, the array should be nil");
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else
             {
                 STAssertNotNil(array,@"the array should not be nil");
                 STAssertTrue(array.count > 1, @"Expected multiple sites");
                 for (AlfrescoSite *site in array)
                 {
                     STAssertTrue(site.isMember, @"site %@ should be marked as being a member site", site.identifier);
                 }
                 self.lastTestSuccessful = YES;
             }
             self.callbackCompleted = YES;
             
         }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
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
        
        [self.siteService retrieveSitesWithListingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error)
         {
             if (nil == pagingResult)
             {
                 STAssertNil(pagingResult,@"if failure, the paging result should be nil");
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else
             {
                 STAssertNotNil(pagingResult, @"paged result should not be nil");
                 for (AlfrescoSite *site in pagingResult.objects)
                 {
                     STAssertTrue(site.isMember, @"site %@ should be marked as being a member site", site.identifier);
                 }
                 self.lastTestSuccessful = YES;
             }
             self.callbackCompleted = YES;
         }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
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
        
        [self.siteService retrieveFavoriteSitesWithCompletionBlock:^(NSArray *array, NSError *error)
         {
             if (nil == array)
             {
                 STAssertNil(array,@"if failure, the array should be nil");
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else
             {
                 STAssertNotNil(array,@"the array should not be nil");
                 STAssertTrue(array.count >= 1, @"Expected multiple favorite sites but got %d",array.count);
                 for (AlfrescoSite *site in array)
                 {
                     STAssertTrue(site.isFavorite, @"site %@ should be marked as favourite", site.identifier);
                 }
                 self.lastTestSuccessful = YES;
             }
             self.callbackCompleted = YES;
             
         }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
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
        
        [self.siteService retrieveFavoriteSitesWithListingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error)
         {
             if (nil == pagingResult)
             {
                 STAssertNil(pagingResult,@"if failure, the paging result should be nil");
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else
             {
                 STAssertNotNil(pagingResult, @"paged result should not be nil");
                 STAssertTrue(pagingResult.totalItems >= 1, @"Total favorite site count should be at least 1, but we got %d", pagingResult.totalItems);
                 if (pagingResult.totalItems > 1)
                 {
                     STAssertTrue(pagingResult.objects.count == 1, @"Favorite site count should be 1, instead we get %d", pagingResult.objects.count);
                     for (AlfrescoSite *site in pagingResult.objects)
                     {
                         STAssertTrue(site.isFavorite, @"site %@ should be marked as favourite", site.identifier);
                     }
                 }
                 else
                 {
                     STAssertTrue(pagingResult.objects.count == 0, @"Favorite site count should be 0, instead we get %d", pagingResult.objects.count);
                 }
                 self.lastTestSuccessful = YES;
             }
             self.callbackCompleted = YES;
             
         }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
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
        
        [self.siteService retrieveSiteWithShortName:self.testSiteName completionBlock:^(AlfrescoSite *site, NSError *error)
         {
             if (nil == site || nil != error)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else
             {
                 STAssertTrue([site.shortName isEqualToString:self.testSiteName], @"Expected %@ site but got back %@", self.testSiteName, site.shortName);
                 STAssertNotNil(site.title, @"site title should not be nil");
                 STAssertNotNil(site.summary, @"site summary should not be nil");
                 self.lastTestSuccessful = YES;
             }
             
             self.callbackCompleted = YES;
             
         }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
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
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
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
        [self.siteService retrieveDocumentLibraryFolderForSite:self.testSiteName completionBlock:^(AlfrescoFolder *folder, NSError *error)
         {
             if (nil == folder)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else
             {
                 STAssertNotNil(folder, @"folder should not be nil");
                 STAssertTrue([folder.name isEqualToString:@"documentLibrary"], @"Folder name should be documentLibrary");
                 
                 self.lastTestSuccessful = YES;
             }
             
             self.callbackCompleted = YES;
             
         }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
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
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}



- (void)testRetrievePendingSitesForUser
{
    if (self.setUpSuccess)
    {
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        [self.siteService retrievePendingSitesWithCompletionBlock:^(NSArray *array, NSError *error){
            if (nil == array)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                STAssertTrue(array.count >= 0, @"Array needs to be >= 0");
                if (0 < array.count)
                {
                    [array enumerateObjectsUsingBlock:^(AlfrescoSite *site, NSUInteger index, BOOL *stop){
                        STAssertTrue(site.isPendingMember, @"The requested site should be in state isPendingMember, but appears not to be.");
                    }];
                }
                self.lastTestSuccessful = YES;
                self.callbackCompleted = YES;
            }
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
    
}

- (void)testRetrievePendingSitesForUserWithListingContext
{
    if (self.setUpSuccess)
    {
        // get all sites for user admin
        
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:2 skipCount:0];
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        [self.siteService retrievePendingSitesWithListingContext:paging completionblock:^(AlfrescoPagingResult *pagingResult, NSError *error){
            if (nil == pagingResult)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                STAssertTrue(pagingResult.objects.count >= 0, @"Array needs to be >= 0");
                if (0 < pagingResult.objects.count)
                {
                    [pagingResult.objects enumerateObjectsUsingBlock:^(AlfrescoSite *site, NSUInteger index, BOOL *stop){
                        STAssertTrue(site.isPendingMember, @"The requested site should be in state isPendingMember, but appears not to be.");
                    }];
                }
                self.lastTestSuccessful = YES;
                self.callbackCompleted = YES;
                
            }
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
    
}

- (void)testRetrieveAllMembersForSite
{
    if (self.setUpSuccess)
    {
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        [self.siteService retrieveFavoriteSitesWithCompletionBlock:^(NSArray *array, NSError *error)
         {
             if (nil == array)
             {
                 STAssertNil(array,@"if failure, the array should be nil");
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else
             {
                 STAssertNotNil(array,@"the array should not be nil");
                 
                 if (array.count > 0)
                 {
                     [self.siteService retrieveAllMembers:[array objectAtIndex:0] completionBlock:^(NSArray *array, NSError *error) {
                         
                         for (AlfrescoPerson *person in array)
                         {
                             AlfrescoLogDebug(@"Person company Name: %@", person.company.name);
                         }
                     }];
                 }
                 self.lastTestSuccessful = YES;
             }
             self.callbackCompleted = YES;
             
         }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRetrieveFilteredMembersForSite
{
    if (self.setUpSuccess)
    {
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        [self.siteService retrieveFavoriteSitesWithCompletionBlock:^(NSArray *array, NSError *error)
         {
             if (nil == array)
             {
                 STAssertNil(array,@"if failure, the array should be nil");
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else
             {
                 STAssertNotNil(array,@"the array should not be nil");
                 
                 if (array.count > 0)
                 {
                     [self.siteService searchMembers:[array objectAtIndex:0] filter:@"" WithListingContext:nil completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
                         
                         NSArray *members = pagingResult.objects;
                         for (AlfrescoPerson *person in members)
                         {
                             AlfrescoLogDebug(@"Person company Name: %@", person.company.name);
                         }
                     }];
                 }
                 self.lastTestSuccessful = YES;
             }
             self.callbackCompleted = YES;
             
         }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testPersonIsMemberOfSite
{
    if (self.setUpSuccess)
    {
        AlfrescoPersonService *personService = [[AlfrescoPersonService alloc] initWithSession:self.currentSession];
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        [personService retrievePersonWithIdentifier:self.userName completionBlock:^(AlfrescoPerson *person, NSError *error) {
            
            if (!error)
            {
                AlfrescoListingContext * listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:5];
                [self.siteService retrieveAllSitesWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error)
                 {
                     
                     if (nil == pagingResult || nil != error)
                     {
                         self.lastTestSuccessful = NO;
                         self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                     }
                     
                     else
                     {
                         NSArray *sites = pagingResult.objects;
                         __block int requestsCompleted = 0;
                         
                         for (AlfrescoSite *site in sites)
                         {
                             [self.siteService isPerson:person memberOfSite:site completionBlock:^(BOOL succeeded, BOOL isMember, NSError *error) {
                                 
                                 requestsCompleted++;
                                 
                                 AlfrescoLogDebug(@"person %@ is member of Site %@: %d", person.fullName, site.shortName, isMember);
                                 self.lastTestSuccessful = YES;
                                 
                                 if (requestsCompleted == sites.count)
                                 {
                                     self.callbackCompleted = YES;
                                 }
                             }];
                         }
                     }
                 }];
            }
        }];
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
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