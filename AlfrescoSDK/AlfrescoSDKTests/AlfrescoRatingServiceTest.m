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

#import "AlfrescoRatingServiceTest.h"

@implementation AlfrescoRatingServiceTest
@synthesize ratingService = _ratingService;
/*
 */
 
- (void)testRetrieveLikeCount
{
    
    [super runAllSitesTest:^{
        self.ratingService = [[AlfrescoRatingService alloc] initWithSession:super.currentSession];
        // get like count
        [self.ratingService retrieveLikeCountForNode:super.testAlfrescoDocument completionBlock:^(NSNumber *count, NSError *error)
         {
             if (nil == count)
             {
                 super.lastTestSuccessful = NO;
                 super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else 
             {
                 log(@"the like count is %d",[count intValue]);
                 STAssertTrue([count intValue] == 0, @"Retrieve like count: expected like count of 0 but got count %d",[count intValue]);
                 super.lastTestSuccessful = YES;
             }
             super.callbackCompleted = YES;
         }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testLikeAndUnlike
{
    [super runAllSitesTest:^{
        
        self.ratingService = [[AlfrescoRatingService alloc] initWithSession:super.currentSession];
        
        // get like count
        [self.ratingService likeNode:super.testAlfrescoDocument completionBlock:^(BOOL success, NSError *error)
         {
             if (!success)
             {
                 super.lastTestSuccessful = NO;
                 super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 super.callbackCompleted = YES;
             }
             else 
             {
                 [self.ratingService retrieveLikeCountForNode:super.testAlfrescoDocument completionBlock:^(NSNumber *count, NSError *error)
                  {
                      if (nil == count)
                      {
                          super.lastTestSuccessful = NO;
                          super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                          super.callbackCompleted = YES;
                      }
                      else 
                      {
                          STAssertTrue([count intValue] == 1, @"Retrieve like count: expected like count of 1 but got count %d",[count intValue]);
                          
                          [self.ratingService unlikeNode:super.testAlfrescoDocument completionBlock:^(BOOL success, NSError *error)
                           {
                               
                               if (!success) 
                               {
                                   super.lastTestSuccessful = NO;
                                   super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                   super.callbackCompleted = YES;
                               }
                               else 
                               {
                                   [self.ratingService retrieveLikeCountForNode:super.testAlfrescoDocument completionBlock:^(NSNumber *count, NSError *error)
                                    {
                                        log(@"ENTERING retrieveLikeCountForNode TEST BLOCK");
                                        if (nil == count)
                                        {
                                            super.lastTestSuccessful = NO;
                                            super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                        }
                                        else 
                                        {
                                            log(@"In block retrieveLikeCountForNode the like count is %d",[count intValue]);
                                            STAssertTrue([count intValue] == 0, @"Retrieve like count: expected like count of 0 but got count %d", [count intValue]);
                                            super.lastTestSuccessful = YES;
                                        }
                                        super.callbackCompleted = YES;
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

- (void)testIsNodeLiked
{
    [super runAllSitesTest:^{
        
        self.ratingService = [[AlfrescoRatingService alloc] initWithSession:super.currentSession];
                
        // get like count
        [self.ratingService isNodeLiked:super.testAlfrescoDocument completionBlock:^(BOOL succeeded, BOOL isLiked, NSError *error) 
         {
             if (!succeeded) 
             {
                 super.lastTestSuccessful = NO;
                 super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 super.callbackCompleted = YES;
             }
             else 
             {
                 STAssertFalse(isLiked, @"expected false");
                 
                 [self.ratingService likeNode:super.testAlfrescoDocument completionBlock:^(BOOL success, NSError *error)
                  {
                      
                      if (!success) 
                      {
                          super.lastTestSuccessful = NO;
                          super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                          super.callbackCompleted = YES;
                      }
                      else 
                      {
                          [self.ratingService isNodeLiked:super.testAlfrescoDocument completionBlock:^(BOOL succeeded, BOOL isLiked, NSError *error) 
                           {
                               if (!succeeded) 
                               {
                                   super.lastTestSuccessful = NO;
                                   super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                   super.callbackCompleted = YES;
                               }
                               else 
                               {
                                   STAssertTrue(succeeded, @"expected true");
                                   
                                   [self.ratingService unlikeNode:super.testAlfrescoDocument completionBlock:^(BOOL success, NSError *error)
                                    {
                                        
                                        if (!success) 
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


@end
