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

#import "AlfrescoSiteServiceForSecondaryUserTests.h"

@implementation AlfrescoSiteServiceForSecondaryUserTests

- (void)setUp
{
    [self setupEnvironmentParameters];

    BOOL success = NO;
    if (nil != self.secondUsername && nil != self.secondPassword && nil != self.moderatedSiteName)
    {
        self.userName = self.secondUsername;
        self.password = self.secondPassword;
        self.testModeratedSiteName = self.moderatedSiteName;
        if (self.isCloud)
        {
            success = [self authenticateCloudServer];
            [self resetTestVariables];
        }
        else
        {
            success = [self authenticateOnPremiseServer:nil];
            [self resetTestVariables];
        }
    }
    self.setUpSuccess = success;    
}


- (void)testAddAndRemoveFavoriteSite
{
    if (self.setUpSuccess)
    {
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        
        [self.siteService retrieveSiteWithShortName:self.testSiteName completionBlock:^(AlfrescoSite *remoteSite, NSError *error) {
            if (remoteSite == nil)
            {
                XCTAssertNil(remoteSite,@ "if failure, the site %@ should be nil", self.testSiteName);
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                __weak typeof(self) weakSelf = self;
                [self.siteService addFavoriteSite:remoteSite completionBlock:^(AlfrescoSite *favSite, NSError *favError) {
                    if (nil == favSite)
                    {
                        weakSelf.lastTestSuccessful = NO;
                        weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [favError localizedDescription], [favError localizedFailureReason]];
                        weakSelf.callbackCompleted = YES;
                    }
                    else
                    {
                        XCTAssertTrueWeakSelf([favSite.identifier isEqualToString:weakSelf.testSiteName], @"The favorite site should be %@ - but received %@", weakSelf.testSiteName, favSite.identifier);
                        XCTAssertTrueWeakSelf(favSite.isFavorite, @"site %@ should be set to isFavorite", favSite.identifier);
                        XCTAssertTrueWeakSelf(favSite.isPendingMember == remoteSite.isPendingMember, @"pending state should be the same for favourited site");
                        XCTAssertTrueWeakSelf(favSite.isMember == remoteSite.isMember, @"member state should be the same for favourited site");
                        [weakSelf.siteService removeFavoriteSite:favSite completionBlock:^(AlfrescoSite *unFavSite, NSError *unFavError){
                            if (nil == unFavSite)
                            {
                                weakSelf.lastTestSuccessful = NO;
                                weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [unFavError localizedDescription], [unFavError localizedFailureReason]];
                                weakSelf.callbackCompleted = YES;
                            }
                            else
                            {
                                XCTAssertTrueWeakSelf([unFavSite.identifier isEqualToString:weakSelf.testSiteName], @"The favorite site should be %@ - but instead we got %@", weakSelf.testSiteName, favSite.identifier);
                                XCTAssertFalseWeakSelf(unFavSite.isFavorite, @"site %@ should no longer be a favorite",unFavSite.identifier);
                                XCTAssertTrueWeakSelf(unFavSite.isPendingMember == remoteSite.isPendingMember, @"pending state should be the same for unfavourited site");
                                XCTAssertTrueWeakSelf(unFavSite.isMember == remoteSite.isMember, @"member state should be the same for unfavourited site");
                                weakSelf.lastTestSuccessful = YES;
                                weakSelf.callbackCompleted = YES;
                            }
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

- (void)testJoinAndCancelModeratedSite
{
    if (self.setUpSuccess)
    {
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        [self.siteService retrieveSiteWithShortName:self.testModeratedSiteName completionBlock:^(AlfrescoSite *modSite, NSError *error) {
            if (nil == modSite)
            {
                XCTAssertNil(modSite,@"if failure, the site object should be nil");
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                BOOL isCorrectName = [modSite.identifier isEqualToString:self.moderatedSiteName];
                XCTAssertTrue(isCorrectName, @"the site should be equal to %@, but instead we got %@", self.moderatedSiteName, modSite.identifier);
                BOOL isMember = modSite.isMember;
                BOOL isPendingMember = modSite.isPendingMember;
                BOOL isFavorite = modSite.isFavorite;
                XCTAssertFalse(isPendingMember, @"We should not have it marked as pending just yet");
                [self.siteService joinSite:modSite completionBlock:^(AlfrescoSite *requestedSite, NSError *requestError) {
                    if (nil == requestedSite)
                    {
                        XCTAssertNil(requestedSite,@"if failure, the requestedSite object should be nil");
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [requestError localizedDescription], [requestError localizedFailureReason]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        BOOL isCorrectName = [requestedSite.identifier isEqualToString:self.moderatedSiteName];
                        BOOL reqIsMember = requestedSite.isMember;
                        BOOL reqIsFavorite = requestedSite.isFavorite;
                        XCTAssertTrue(reqIsMember == isMember, @"the membership state of requested site should not have changed");
                        XCTAssertTrue(reqIsFavorite == isFavorite, @"the favourite state of requested site should not have changed");
                        XCTAssertTrue(isCorrectName, @"the site should be equal to %@, but instead we got %@", self.moderatedSiteName, requestedSite.identifier);
                        XCTAssertTrue(requestedSite.isPendingMember, @"Site should be in state isPendingMember - but appears to be not");
                        [self.siteService retrievePendingSitesWithCompletionBlock:^(NSArray *pendingSites, NSError *retrieveError) {
                            if (nil == pendingSites)
                            {
                                self.lastTestSuccessful = NO;
                                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveError localizedDescription], [retrieveError localizedFailureReason]];
                                self.callbackCompleted = YES;
                            }
                            else
                            {
                                XCTAssertTrue(0 < pendingSites.count, @"We should have at least 1 requested site in the array, instead we got %lu", (unsigned long)pendingSites.count);
                                [self.siteService cancelPendingJoinRequestForSite:requestedSite completionBlock:^(AlfrescoSite *cancelledSite, NSError *cancelError) {
                                    if (nil == cancelledSite)
                                    {
                                        XCTAssertNil(cancelledSite,@"if failure, the cancelledSite object should be nil");
                                        self.lastTestSuccessful = NO;
                                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [cancelError localizedDescription], [cancelError localizedFailureReason]];
                                        self.callbackCompleted = YES;
                                    }
                                    else
                                    {
                                        BOOL isCorrectName = [requestedSite.identifier isEqualToString:self.moderatedSiteName];
                                        XCTAssertTrue(cancelledSite.isMember == isMember, @"the membership state of cancelled site should not have changed");
                                        XCTAssertTrue(cancelledSite.isFavorite == isFavorite, @"the favourite state of cancelled site should not have changed");
                                        XCTAssertTrue(isCorrectName, @"the site should be equal to %@, but instead we got %@", self.moderatedSiteName, modSite.identifier);
                                        XCTAssertFalse(cancelledSite.isPendingMember, @"Site should NOT be in state isPendingMember - but appears to be still in this state");
                                        self.lastTestSuccessful = YES;
                                        self.callbackCompleted = YES;
                                    }
                                }];
                            }
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

- (void)testJoinAndLeavePublicSite
{
    if (self.setUpSuccess)
    {
        self.siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        [self.siteService retrieveSiteWithShortName:self.testSiteName completionBlock:^(AlfrescoSite *modSite, NSError *error) {
            if (nil == modSite)
            {
                XCTAssertNil(modSite,@"if failure, the site object should be nil");
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                BOOL isCorrectName = [modSite.identifier isEqualToString:self.testSiteName];
                XCTAssertTrue(isCorrectName, @"the site should be equal to %@, but instead we got %@", self.testSiteName, modSite.identifier);
                [self.siteService joinSite:modSite completionBlock:^(AlfrescoSite *requestedSite, NSError *requestError){
                    if (nil == requestedSite)
                    {
                        XCTAssertNil(requestedSite,@"if failure, the requestedSite object should be nil");
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [requestError localizedDescription], [requestError localizedFailureReason]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        BOOL isCorrectName = [modSite.identifier isEqualToString:self.testSiteName];
                        XCTAssertTrue(requestedSite.isFavorite == modSite.isFavorite, @"favorite state of joined site should be the same");
                        XCTAssertTrue(requestedSite.isPendingMember == modSite.isPendingMember, @"pending state of joined site should be the same");
                        XCTAssertTrue(isCorrectName, @"the site should be equal to %@, but instead we got %@", self.testSiteName, modSite.identifier);
                        XCTAssertTrue(requestedSite.isMember, @"Site should be in state isMember - but appears to be not");
                        [self.siteService leaveSite:requestedSite completionBlock:^(AlfrescoSite *noMemberSite, NSError *noMemberError) {
                            if (nil == noMemberSite)
                            {
                                XCTAssertNil(noMemberSite,@"if failure, the noMemberSite object should be nil");
                                self.lastTestSuccessful = NO;
                                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [noMemberError localizedDescription], [noMemberError localizedFailureReason]];
                                self.callbackCompleted = YES;
                            }
                            else
                            {
                                BOOL isCorrectName = [modSite.identifier isEqualToString:self.testSiteName];
                                XCTAssertTrue(noMemberSite.isFavorite == modSite.isFavorite, @"favorite state of left site should be the same");
                                XCTAssertTrue(noMemberSite.isPendingMember == modSite.isPendingMember, @"pending state of left site should be the same");
                                XCTAssertTrue(isCorrectName, @"the site should be equal to %@, but instead we got %@", self.testSiteName, noMemberSite.identifier);
                                XCTAssertFalse(noMemberSite.isMember, @"Site should NOT be in state isMember - but appears to be still in this state");
                                self.lastTestSuccessful = YES;
                                self.callbackCompleted = YES;
                            }
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

@end
