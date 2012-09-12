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

#import "AlfrescoCommentServiceTest.h"
#import "AlfrescoDocumentFolderService.h"

@implementation AlfrescoCommentServiceTest

@synthesize commentService = _commentService;

/*
 */
- (void)testRetrieveAllComments
{
    [super runAllSitesTest:^{
        
        self.commentService = [[AlfrescoCommentService alloc] initWithSession:super.currentSession];
        
        
        // get all comments
        [self.commentService retrieveCommentsForNode:super.testAlfrescoDocument completionBlock:^(NSArray *array, NSError *error)
        {
            if (nil == array) 
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else 
            {
                STAssertNotNil(array, @"array should not be nil");
                STAssertTrue(array.count == 0, @"newly uploaded document. We expect 0 comments");
                if (array.count > 0)
                {
                    AlfrescoComment *comment = [array objectAtIndex:0];
                    STAssertTrue([comment.content isEqualToString:@"<p>this is a test comment</p>"], @"content should equal the test comment message");
                    STAssertTrue([comment.createdBy isEqualToString:super.userName], @"comment.createdBy should be  %@",super.userName);
                    STAssertNotNil(comment.createdAt, @"creationDate should not be nil");
                    STAssertNotNil(comment.modifiedAt, @"modificationDate should not be nil");
                    STAssertTrue(comment.canEdit, @"canEdit should be true");
                    STAssertFalse(comment.canDelete, @"canDelete should be false");
                }
                
                super.lastTestSuccessful = YES;
            }
            super.callbackCompleted = YES;
            
        }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testRetrieveAllCommentsWithPaging
{
    [super runAllSitesTest:^{
        
        self.commentService = [[AlfrescoCommentService alloc] initWithSession:super.currentSession];
        
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:1 skipCount:0];
        
        // get all comments
        [self.commentService retrieveCommentsForNode:super.testAlfrescoDocument listingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error)
        {
            if (nil == pagingResult) 
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else 
            {
                STAssertNotNil(pagingResult, @"pagingResult should not be nil");
                STAssertTrue(pagingResult.objects.count == 0, @"expected 0 comments");
                STAssertTrue(pagingResult.totalItems == 0, @"expected total of 0 comments as we just uploaded the document");
                
                super.lastTestSuccessful = YES;
            }
            super.callbackCompleted = YES;
            
        }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testAddAndDeleteComment
{
    [super runAllSitesTest:^{
        
        self.commentService = [[AlfrescoCommentService alloc] initWithSession:super.currentSession];
        
        
        // add a comment
        __weak AlfrescoCommentService *weakCommentService = self.commentService;
        [weakCommentService addCommentToNode:super.testAlfrescoDocument content:@"<p>test</p>" title:@"test" completionBlock:^(AlfrescoComment *comment, NSError *error)
        {
            if (nil == comment) 
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                super.callbackCompleted = YES;
            }
            else 
            {
                log(@"the comment author is %@",comment.createdBy);
                STAssertTrue([comment.content isEqualToString:@"<p>test</p>"], @"content should equal the test comment message");
                STAssertTrue([comment.createdBy isEqualToString:super.userName], @"comment.createdBy should be  %@",super.userName);
                
                [weakCommentService retrieveCommentsForNode:super.testAlfrescoDocument completionBlock:^(NSArray *array, NSError *error){
                    if (nil == array)
                    {
                        super.lastTestSuccessful = NO;
                        super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                        super.callbackCompleted = YES;
                    }
                    else
                    {
                        STAssertNotNil(array, @"returned array of comments should not be nil");
                        STAssertTrue(1 == array.count, @"we expect one comment for the node");
                        if (array.count > 0)
                        {
                            STAssertTrue([comment.content isEqualToString:@"<p>test</p>"], @"content should equal the test comment message");
                            STAssertTrue([comment.createdBy isEqualToString:super.userName], @"comment.createdBy should be  %@",super.userName);
                            STAssertNotNil(comment.createdAt, @"creationDate should not be nil");
                            STAssertNotNil(comment.modifiedAt, @"modificationDate should not be nil");
                        }
                        [weakCommentService deleteCommentFromNode:super.testAlfrescoDocument comment:comment completionBlock:^(BOOL success, NSError *error)
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
         
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testAddUpdateAndDeleteComment
{
    [super runAllSitesTest:^{
        
        self.commentService = [[AlfrescoCommentService alloc] initWithSession:super.currentSession];
        
        
        // add a comment
        __weak AlfrescoCommentService *weakCommentService = self.commentService;
        [weakCommentService addCommentToNode:super.testAlfrescoDocument content:@"<p>test</p>" title:@"test" completionBlock:^(AlfrescoComment *comment, NSError *error)
        {
            if (nil == comment) 
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                super.callbackCompleted = YES;
            }
            else 
            {
                STAssertTrue([comment.content isEqualToString:@"<p>test</p>"], @"content should equal the test comment message");
                STAssertTrue([comment.createdBy isEqualToString:super.userName], @"comment.createdBy should be  %@",super.userName);
                
                [weakCommentService updateCommentOnNode:super.testAlfrescoDocument comment:comment content:@"<p>test2</p>" completionBlock:^(AlfrescoComment *comment, NSError *error) 
                 {
                     
                     if (nil == comment) 
                     {
                         super.lastTestSuccessful = NO;
                         super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                         super.callbackCompleted = YES;
                     }
                     else 
                     {
                         STAssertTrue([comment.content isEqualToString:@"<p>test2</p>"], @"content should equal the test comment message");
                         
                         [weakCommentService deleteCommentFromNode:super.testAlfrescoDocument comment:comment completionBlock:^(BOOL success, NSError *error)
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
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}




@end
