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

#import "AlfrescoRatingServiceTest.h"
#import "AlfrescoRepositoryCapabilities.h"

@implementation AlfrescoRatingServiceTest
/*
 */
/*
 @Unique_TCRef 12S1
 */

- (void)testRetrieveLikeCount
{
    
    if (self.setUpSuccess)
    {
        AlfrescoRepositoryCapabilities *capabilities = self.currentSession.repositoryInfo.capabilities;
        if (capabilities.doesSupportLikingNodes)
        {
            self.ratingService = [[AlfrescoRatingService alloc] initWithSession:self.currentSession];
            // get like count
            [self.ratingService retrieveLikeCountForNode:self.testAlfrescoDocument completionBlock:^(NSNumber *count, NSError *error)
             {
                 if (nil == count)
                 {
                     self.lastTestSuccessful = NO;
                     self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 }
                 else
                 {
                     STAssertTrue([count intValue] == 0, @"Retrieve like count: expected like count of 0 but got count %d",[count intValue]);
                     self.lastTestSuccessful = YES;
                 }
                 self.callbackCompleted = YES;
             }];
            [self waitUntilCompleteWithFixedTimeInterval];
            STAssertTrue(self.lastTestSuccessful, self.lastTestFailureMessage);
        }
        else
        {
            self.lastTestSuccessful = YES;
        }
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 @Unique_TCRef 37S1
 @Unique_TCRef 38S1,38S2
 @Unique_TCRef 12S1
 */
- (void)testLikeAndUnlike
{
    if (self.setUpSuccess)
    {
        AlfrescoRepositoryCapabilities *capabilities = self.currentSession.repositoryInfo.capabilities;
        if (capabilities.doesSupportLikingNodes)
        {
            self.ratingService = [[AlfrescoRatingService alloc] initWithSession:self.currentSession];
            
            // get like count
            [self.ratingService likeNode:self.testAlfrescoDocument completionBlock:^(BOOL success, NSError *error)
             {
                 if (!success)
                 {
                     self.lastTestSuccessful = NO;
                     self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                     self.callbackCompleted = YES;
                 }
                 else
                 {
                     [self.ratingService retrieveLikeCountForNode:self.testAlfrescoDocument completionBlock:^(NSNumber *count, NSError *error)
                      {
                          if (nil == count)
                          {
                              self.lastTestSuccessful = NO;
                              self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                              self.callbackCompleted = YES;
                          }
                          else
                          {
                              STAssertTrue([count intValue] == 1, @"Retrieve like count: expected like count of 1 but got count %d",[count intValue]);
                              
                              [self.ratingService unlikeNode:self.testAlfrescoDocument completionBlock:^(BOOL success, NSError *error)
                               {
                                   
                                   if (!success)
                                   {
                                       self.lastTestSuccessful = NO;
                                       self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                       self.callbackCompleted = YES;
                                   }
                                   else
                                   {
                                       [self.ratingService retrieveLikeCountForNode:self.testAlfrescoDocument completionBlock:^(NSNumber *count, NSError *error)
                                        {
                                            if (nil == count)
                                            {
                                                self.lastTestSuccessful = NO;
                                                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                            }
                                            else
                                            {
                                                STAssertTrue([count intValue] == 0, @"Retrieve like count: expected like count of 0 but got count %d", [count intValue]);
                                                self.lastTestSuccessful = YES;
                                            }
                                            self.callbackCompleted = YES;
                                        }];
                                   }
                                   
                               }];
                          }
                          
                      }];
                 }
                 
                 
             }];
            
            [self waitUntilCompleteWithFixedTimeInterval];
            STAssertTrue(self.lastTestSuccessful, self.lastTestFailureMessage);
        }
        else
        {
            self.lastTestSuccessful = YES;
        }
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 @Unique_TCRef 37S1
 @Unique_TCRef 38S2/S1
 @Unique_TCRef 39S1, 39S3
 */
- (void)testIsNodeLiked
{
    if (self.setUpSuccess)
    {
        
        AlfrescoRepositoryCapabilities *capabilities = self.currentSession.repositoryInfo.capabilities;
        if (capabilities.doesSupportLikingNodes)
        {
            self.ratingService = [[AlfrescoRatingService alloc] initWithSession:self.currentSession];
            
            // get like count
            [self.ratingService isNodeLiked:self.testAlfrescoDocument completionBlock:^(BOOL succeeded, BOOL isLiked, NSError *error)
             {
                 if (!succeeded)
                 {
                     self.lastTestSuccessful = NO;
                     self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                     self.callbackCompleted = YES;
                 }
                 else
                 {
                     STAssertFalse(isLiked, @"expected false");
                     
                     [self.ratingService likeNode:self.testAlfrescoDocument completionBlock:^(BOOL success, NSError *error)
                      {
                          
                          if (!success)
                          {
                              self.lastTestSuccessful = NO;
                              self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                              self.callbackCompleted = YES;
                          }
                          else
                          {
                              [self.ratingService isNodeLiked:self.testAlfrescoDocument completionBlock:^(BOOL succeeded, BOOL isLiked, NSError *error)
                               {
                                   if (!succeeded)
                                   {
                                       self.lastTestSuccessful = NO;
                                       self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                       self.callbackCompleted = YES;
                                   }
                                   else
                                   {
                                       STAssertTrue(succeeded, @"expected true");
                                       
                                       [self.ratingService unlikeNode:self.testAlfrescoDocument completionBlock:^(BOOL success, NSError *error)
                                        {
                                            
                                            if (!success)
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
                                   }
                                   
                               }];
                          }
                          
                      }];
                 }
                 
             }];
            
            [self waitUntilCompleteWithFixedTimeInterval];
            STAssertTrue(self.lastTestSuccessful, self.lastTestFailureMessage);
        }
        else
        {
            self.lastTestSuccessful = YES;
        }
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}


@end
