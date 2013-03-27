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
                for (AlfrescoSite *site in array)
                {
                    STAssertTrue(site.isMember, @"site %@ should be marked as being a member site", site.identifier);
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
                for (AlfrescoSite *site in pagingResult.objects)
                {
                    STAssertTrue(site.isMember, @"site %@ should be marked as being a member site", site.identifier);
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
                for (AlfrescoSite *site in array)
                {
                    STAssertTrue(site.isFavorite, @"site %@ should be marked as favourite", site.identifier);
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
                    for (AlfrescoSite *site in pagingResult.objects)
                    {
                        STAssertTrue(site.isFavorite, @"site %@ should be marked as favourite", site.identifier);
                    }
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


- (void)testAddAndRemoveFavoriteSite
{
    [self runSiteTestsForSecondaryUser:^{
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:super.currentSession];
        
        [self.siteService retrieveSiteWithShortName:@"remoteapi"
                                    completionBlock:^(AlfrescoSite *remoteSite, NSError *error){
            if (remoteSite == nil)
            {
                STAssertNil(remoteSite,@"if failure, the site remoteapi should be nil");
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                super.callbackCompleted = YES;
            }
            else
            {
                [self.siteService addFavoriteSite:remoteSite completionBlock:^(AlfrescoSite *favSite, NSError *favError){
                    if (nil == favSite)
                    {
                        super.lastTestSuccessful = NO;
                        super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [favError localizedDescription], [favError localizedFailureReason]];
                        super.callbackCompleted = YES;
                    }
                    else
                    {
                        STAssertTrue([favSite.identifier isEqualToString:@"remoteapi"], @"The favorite site should be remoteapi - but instead we got %@",favSite.identifier);
                        STAssertTrue(favSite.isFavorite, @"site %@ should be set to isFavorite",favSite.identifier);
                        STAssertTrue(favSite.isPendingMember == remoteSite.isPendingMember, @"pending state should be the same for favourited site");
                        STAssertTrue(favSite.isMember == remoteSite.isMember, @"member state should be the same for favourited site");
                        [self.siteService removeFavoriteSite:favSite completionBlock:^(AlfrescoSite *unFavSite, NSError *unFavError){
                            if (nil == unFavSite)
                            {
                                super.lastTestSuccessful = NO;
                                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [unFavError localizedDescription], [unFavError localizedFailureReason]];
                                super.callbackCompleted = YES;
                            }
                            else
                            {
                                STAssertTrue([unFavSite.identifier isEqualToString:@"remoteapi"], @"The favorite site should be remoteapi - but instead we got %@",favSite.identifier);
                                STAssertFalse(unFavSite.isFavorite, @"site %@ should no longer be a favorite",unFavSite.identifier);
                                STAssertTrue(unFavSite.isPendingMember == remoteSite.isPendingMember, @"pending state should be the same for unfavourited site");
                                STAssertTrue(unFavSite.isMember == remoteSite.isMember, @"member state should be the same for unfavourited site");
                                super.lastTestSuccessful = YES;
                                super.callbackCompleted = YES;
                            }
                        }];
                    }
                }];
                
            }
        }];
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testJoinAndCancelModeratedSite
{
    [self runSiteTestsForSecondaryUser:^{
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:super.currentSession];
        [self.siteService retrieveSiteWithShortName:self.testModeratedSiteName
                                    completionBlock:^(AlfrescoSite *modSite, NSError *error){
            if (nil == modSite)
            {
                STAssertNil(modSite,@"if failure, the site object should be nil");
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                super.callbackCompleted = YES;
            }
            else
            {
                BOOL isCorrectName = [modSite.identifier isEqualToString:@"iosmoderatedsite"] || [modSite.identifier isEqualToString:@"iOSModeratedSite"];
                STAssertTrue(isCorrectName, @"the site should be equal to iosmoderatedsite/iOSModeratedSite, but instead we got %@",modSite.identifier);
                BOOL isMember = modSite.isMember;
                BOOL isPendingMember = modSite.isPendingMember;
                BOOL isFavorite = modSite.isFavorite;
                STAssertFalse(isPendingMember, @"We should not have it marked as pending just yet");
                [self.siteService joinSite:modSite completionBlock:^(AlfrescoSite *requestedSite, NSError *requestError){
                    if (nil == requestedSite)
                    {
                        STAssertNil(requestedSite,@"if failure, the requestedSite object should be nil");
                        super.lastTestSuccessful = NO;
                        super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [requestError localizedDescription], [requestError localizedFailureReason]];
                        super.callbackCompleted = YES;
                    }
                    else
                    {
                        BOOL isCorrectName = [requestedSite.identifier isEqualToString:@"iosmoderatedsite"] || [requestedSite.identifier isEqualToString:@"iOSModeratedSite"];
                        BOOL reqIsMember = requestedSite.isMember;
                        BOOL reqIsFavorite = requestedSite.isFavorite;
                        STAssertTrue(reqIsMember == isMember, @"the membership state of requested site should not have changed");
                        STAssertTrue(reqIsFavorite == isFavorite, @"the favourite state of requested site should not have changed");
                        STAssertTrue(isCorrectName, @"the site should be equal to iOSModeratedSite, but instead we got %@",requestedSite.identifier);
                        STAssertTrue(requestedSite.isPendingMember, @"Site should be in state isPendingMember - but appears to be not");
                        [self.siteService retrievePendingSitesWithCompletionBlock:^(NSArray *pendingSites, NSError *retrieveError){
                            if (nil == pendingSites)
                            {
                                super.lastTestSuccessful = NO;
                                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveError localizedDescription], [retrieveError localizedFailureReason]];
                                super.callbackCompleted = YES;
                            }
                            else
                            {
                                STAssertTrue(0 < pendingSites.count, @"We should have at least 1 requested site in the array, instead we got %d", pendingSites.count);
                                [self.siteService cancelPendingJoinRequestForSite:requestedSite completionBlock:^(AlfrescoSite *cancelledSite, NSError *cancelError){
                                    if (nil == cancelledSite)
                                    {
                                        STAssertNil(cancelledSite,@"if failure, the cancelledSite object should be nil");
                                        super.lastTestSuccessful = NO;
                                        super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [cancelError localizedDescription], [cancelError localizedFailureReason]];
                                        super.callbackCompleted = YES;
                                    }
                                    else
                                    {
                                        BOOL isCorrectName = [requestedSite.identifier isEqualToString:@"iosmoderatedsite"] || [requestedSite.identifier isEqualToString:@"iOSModeratedSite"];
                                        STAssertTrue(cancelledSite.isMember == isMember, @"the membership state of cancelled site should not have changed");
                                        STAssertTrue(cancelledSite.isFavorite == isFavorite, @"the favourite state of cancelled site should not have changed");
                                        STAssertTrue(isCorrectName, @"the site should be equal to iosmoderatedsite/iOSModeratedSite, but instead we got %@",modSite.identifier);
                                        STAssertFalse(cancelledSite.isPendingMember, @"Site should NOT be in state isPendingMember - but appears to be still in this state");
                                        super.lastTestSuccessful = YES;
                                        super.callbackCompleted = YES;
                                    }
                                }];
                            }

                        }];
                    }
                }];
                
            }
        }];
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testJoinAndLeavePublicSite
{
    [self runSiteTestsForSecondaryUser:^{
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:super.currentSession];
        [self.siteService retrieveSiteWithShortName:@"remoteapi"
                                    completionBlock:^(AlfrescoSite *modSite, NSError *error){
                                        if (nil == modSite)
                                        {
                                            STAssertNil(modSite,@"if failure, the site object should be nil");
                                            super.lastTestSuccessful = NO;
                                            super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                            super.callbackCompleted = YES;
                                        }
                                        else
                                        {
                                            BOOL isCorrectName = [modSite.identifier isEqualToString:@"remoteapi"];
                                            STAssertTrue(isCorrectName, @"the site should be equal to remoteapi, but instead we got %@",modSite.identifier);
                                            [self.siteService joinSite:modSite completionBlock:^(AlfrescoSite *requestedSite, NSError *requestError){
                                                if (nil == requestedSite)
                                                {
                                                    STAssertNil(requestedSite,@"if failure, the requestedSite object should be nil");
                                                    super.lastTestSuccessful = NO;
                                                    super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [requestError localizedDescription], [requestError localizedFailureReason]];
                                                    super.callbackCompleted = YES;
                                                }
                                                else
                                                {
                                                    BOOL isCorrectName = [modSite.identifier isEqualToString:@"remoteapi"];
                                                    STAssertTrue(requestedSite.isFavorite == modSite.isFavorite, @"favorite state of joined site should be the same");
                                                    STAssertTrue(requestedSite.isPendingMember == modSite.isPendingMember, @"pending state of joined site should be the same");
                                                    STAssertTrue(isCorrectName, @"the site should be equal to remoteapi, but instead we got %@",modSite.identifier);
                                                    STAssertTrue(requestedSite.isMember, @"Site should be in state isMember - but appears to be not");
                                                    [self.siteService leaveSite:requestedSite completionBlock:^(AlfrescoSite *noMemberSite, NSError *noMemberError){
                                                        if (nil == noMemberSite)
                                                        {
                                                            STAssertNil(noMemberSite,@"if failure, the noMemberSite object should be nil");
                                                            super.lastTestSuccessful = NO;
                                                            super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [noMemberError localizedDescription], [noMemberError localizedFailureReason]];
                                                            super.callbackCompleted = YES;
                                                        }
                                                        else
                                                        {
                                                            BOOL isCorrectName = [modSite.identifier isEqualToString:@"remoteapi"];
                                                            STAssertTrue(noMemberSite.isFavorite == modSite.isFavorite, @"favorite state of left site should be the same");
                                                            STAssertTrue(noMemberSite.isPendingMember == modSite.isPendingMember, @"pending state of left site should be the same");
                                                            STAssertTrue(isCorrectName, @"the site should be equal to remoteapi, but instead we got %@",noMemberSite.identifier);
                                                            STAssertFalse(noMemberSite.isMember, @"Site should NOT be in state isMember - but appears to be still in this state");
                                                            super.lastTestSuccessful = YES;
                                                            super.callbackCompleted = YES;
                                                            
                                                        }
                                                    }];                        
                                                    
                                                }
                                            }];
                                            
                                        }
                                    }];
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
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