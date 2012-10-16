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
 @Unique_TCRef 7S1
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
                    STAssertNotNil(comment.name, @"name should not be nil");
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
 @Unique_TCRef 33S0
 @Unique_TCRef 24S0
 @Unique_TCRef 7F0
 */
- (void)testRetrieveAllCommentsForNonExistingDocuments
{
    [super runAllSitesTest:^{
        
        self.commentService = [[AlfrescoCommentService alloc] initWithSession:super.currentSession];
        __block AlfrescoDocumentFolderService *dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        
        __weak AlfrescoCommentService *weakService = self.commentService;
        
        [dfService createDocumentWithName:@"millenium-dome.jpg" inParentFolder:super.testDocFolder
                                   contentFile:super.testImageFile
                                    properties:nil
                               completionBlock:^(AlfrescoDocument *document, NSError *blockError){
                                   
                                   if (nil == document)
                                   {
                                       super.lastTestSuccessful = NO;
                                       super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [blockError localizedDescription], [blockError localizedFailureReason]];
                                       super.callbackCompleted = YES;
                                   }
                                   else
                                   {
                                       STAssertNotNil(document.identifier, @"document identifier should be filled");
                                       STAssertTrue(document.contentLength > 100, @"expected content to be filled");
                                       
                                       // delete the test document
                                       [dfService deleteNode:document completionBlock:^(BOOL success, NSError *error)
                                        {
                                            if (!success)
                                            {
                                                super.lastTestSuccessful = NO;
                                                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                                super.callbackCompleted = YES;
                                            }
                                            else
                                            {
                                                [weakService retrieveCommentsForNode:document completionBlock:^(NSArray *comments, NSError *error){
                                                    if (nil == comments)
                                                    {
                                                        super.lastTestSuccessful = YES;
                                                        NSString *errorMsg = [NSString stringWithFormat:@"%@ - %@", [blockError localizedDescription], [blockError localizedFailureReason]];
                                                        log(@"Expected error %@",errorMsg);
                                                    }
                                                    else
                                                    {
                                                        super.lastTestSuccessful = NO;
                                                        super.lastTestFailureMessage = @"we shouldn't be getting comments for a deleted doc";
                                                        
                                                    }
                                                    super.callbackCompleted = YES;
                                                }];
                                            }
                                        }];
                                   }
                               }
                            progressBlock:^(NSInteger bytesUploaded, NSInteger bytesTotal){
                               }];
                
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}


/*
 @Unique_TCRef 8S0
 */
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

/*
 @Unique_TCRef 7S0
 @Unique_TCRef 9S0
 @Unique_TCRef 11S0
 */
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
                            STAssertFalse(comment.isEdited, @"isEdited should return false");
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


/*
 @Unique_TCRef 7S0
 @Unique_TCRef 9S0
 @Unique_TCRef 10S0
 */
- (void)testAddAndUpdateCommentNonExisting
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
                 __block AlfrescoComment *strongComment = comment;
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
                         [weakCommentService deleteCommentFromNode:super.testAlfrescoDocument comment:strongComment completionBlock:^(BOOL success, NSError *error)
                          {
                              if (!success)
                              {
                                  super.lastTestSuccessful = NO;
                                  super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                  super.callbackCompleted = YES;
                              }
                              else
                              {
                                  [weakCommentService updateCommentOnNode:super.testAlfrescoDocument comment:strongComment content:@"Another string" completionBlock:^(AlfrescoComment *updatedComment, NSError *error){
                                      if (nil == updatedComment)
                                      {
                                          super.lastTestSuccessful = YES;
                                          NSString *errorMsg = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                          log(@"Expected error %@", errorMsg);
                                      }
                                      else
                                      {
                                          super.lastTestSuccessful = NO;
                                          super.lastTestFailureMessage = @"we shouldn't be able to update a deleted comment";
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


/*
 @Unique_TCRef 33S0
 @Unique_TCRef 24S0
 @Unique_TCRef 9F0
 */
- (void)testAddAndDeleteForNonExistingDocument
{
    [super runAllSitesTest:^{
        
        self.commentService = [[AlfrescoCommentService alloc] initWithSession:super.currentSession];
        __block AlfrescoDocumentFolderService *dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        
        __weak AlfrescoCommentService *weakService = self.commentService;
        
        [dfService createDocumentWithName:@"millenium-dome.jpg" inParentFolder:super.testDocFolder
                              contentFile:super.testImageFile
                               properties:nil
                          completionBlock:^(AlfrescoDocument *document, NSError *blockError){
                              
                              if (nil == document)
                              {
                                  super.lastTestSuccessful = NO;
                                  super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [blockError localizedDescription], [blockError localizedFailureReason]];
                                  super.callbackCompleted = YES;
                              }
                              else
                              {
                                  STAssertNotNil(document.identifier, @"document identifier should be filled");
                                  STAssertTrue(document.contentLength > 100, @"expected content to be filled");
                                  
                                  // delete the test document
                                  [dfService deleteNode:document completionBlock:^(BOOL success, NSError *error)
                                   {
                                       if (!success)
                                       {
                                           super.lastTestSuccessful = NO;
                                           super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                           super.callbackCompleted = YES;
                                       }
                                       else
                                       {
                                           [weakService addCommentToNode:document content:@"blabla" title:@"test" completionBlock:^(AlfrescoComment *comment, NSError *error){
                                               if (nil == comment)
                                               {
                                                   super.lastTestSuccessful = YES;
                                                   NSString *errorMsg = [NSString stringWithFormat:@"%@ - %@", [blockError localizedDescription], [blockError localizedFailureReason]];
                                                   log(@"Expected error %@",errorMsg);
                                               }
                                               else
                                               {
                                                   super.lastTestSuccessful = NO;
                                                   super.lastTestFailureMessage = @"we shouldn't be able to add comments for a deleted doc";
                                                   
                                               }
                                               super.callbackCompleted = YES;
                                           }];
                                       }
                                   }];
                              }
                          }
                            progressBlock:^(NSInteger bytesUploaded, NSInteger bytesTotal){
                            }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}



/*
 @Unique_TCRef 7S0
 @Unique_TCRef 9S0, 9S5, 9S6
 @Unique_TCRef 11S0
 */
- (void)testAddAndDeleteCommentEULanguages
{
    [super runAllSitesTest:^{
        
        self.commentService = [[AlfrescoCommentService alloc] initWithSession:super.currentSession];
        __block NSString *content = @"Übersicht Ändern Östrogen und das mit ß";
        __block NSString *title = @"Änderungswünsche";
        
        // add a comment
        __weak AlfrescoCommentService *weakCommentService = self.commentService;
        [weakCommentService addCommentToNode:super.testAlfrescoDocument content:content title:title completionBlock:^(AlfrescoComment *comment, NSError *error)
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
                 STAssertTrue([comment.content isEqualToString:content], @"content should equal the test comment message, which is %@. But instead we got %@",content, comment.content);
                 STAssertTrue([comment.createdBy isEqualToString:super.userName], @"comment.createdBy should be  %@",super.userName);
                 if (!self.isCloud)
                 {
                     STAssertTrue([comment.title isEqualToString:title], @"the comment title should be equal to %@ but instead we got %@",title, comment.title);
                 }
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
                             AlfrescoComment *retrievedComment = (AlfrescoComment *)[array objectAtIndex:0];
                             STAssertTrue([retrievedComment.content isEqualToString:content],@"content should equal the test comment message, which is %@. But instead we got %@",content, retrievedComment.content);
                             if (!self.isCloud)
                             {
                                 STAssertTrue([retrievedComment.title isEqualToString:title], @"the comment title should be equal to %@ but instead we got %@",title, retrievedComment.title);
                             }
                             STAssertTrue([retrievedComment.createdBy isEqualToString:super.userName], @"comment.createdBy should be  %@",super.userName);
                             STAssertNotNil(retrievedComment.createdAt, @"creationDate should not be nil");
                             STAssertNotNil(retrievedComment.modifiedAt, @"modificationDate should not be nil");
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

/*
 @Unique_TCRef 7S0
 @Unique_TCRef 9S0, 9S5, 9S6
 @Unique_TCRef 11S0
 */
- (void)testAddAndDeleteCommentJPLanguages
{
    [super runAllSitesTest:^{
        
        self.commentService = [[AlfrescoCommentService alloc] initWithSession:super.currentSession];
        __block NSString *content = @"ありがと　にほんご";
        __block NSString *title = @"わさび";
        
        // add a comment
        __weak AlfrescoCommentService *weakCommentService = self.commentService;
        [weakCommentService addCommentToNode:super.testAlfrescoDocument content:content title:title completionBlock:^(AlfrescoComment *comment, NSError *error)
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
                 STAssertTrue([comment.content isEqualToString:content], @"content should equal the test comment message, which is %@. But instead we got %@",content, comment.content);
                 STAssertTrue([comment.createdBy isEqualToString:super.userName], @"comment.createdBy should be  %@",super.userName);
                 if (!self.isCloud)
                 {
                     STAssertTrue([comment.title isEqualToString:title], @"the comment title should be equal to %@ but instead we got %@",title, comment.title);
                 }
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
                             AlfrescoComment *retrievedComment = (AlfrescoComment *)[array objectAtIndex:0];
                             STAssertTrue([retrievedComment.content isEqualToString:content],@"content should equal the test comment message, which is %@. But instead we got %@",content, retrievedComment.content);
                             if (!self.isCloud)
                             {
                                 STAssertTrue([retrievedComment.title isEqualToString:title], @"the comment title should be equal to %@ but instead we got %@",title, retrievedComment.title);
                             }
                             STAssertTrue([retrievedComment.createdBy isEqualToString:super.userName], @"comment.createdBy should be  %@",super.userName);
                             STAssertNotNil(retrievedComment.createdAt, @"creationDate should not be nil");
                             STAssertNotNil(retrievedComment.modifiedAt, @"modificationDate should not be nil");
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


/*
 @Unique_TCRef 7S0
 @Unique_TCRef 10S0
 @Unique_TCRef 11S0
 */
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

/*
 @Unique_TCRef 7S5
 @Unique_TCRef 10S0
 @Unique_TCRef 11S0
 */
- (void)testAddUpdateAndDeleteCommentEULanguages
{
    [super runAllSitesTest:^{
        
        self.commentService = [[AlfrescoCommentService alloc] initWithSession:super.currentSession];
        __block NSString *content = @"Übersicht Ändern Östrogen und das mit ß";
        
        
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
                 
                 [weakCommentService updateCommentOnNode:super.testAlfrescoDocument comment:comment content:content completionBlock:^(AlfrescoComment *comment, NSError *error)
                  {
                      
                      if (nil == comment)
                      {
                          super.lastTestSuccessful = NO;
                          super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                          super.callbackCompleted = YES;
                      }
                      else
                      {
                          STAssertTrue([comment.content isEqualToString:content], @"content should equal to %@ but instead we got %@", content, comment.content);
                          
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

/*
 @Unique_TCRef 7S6
 @Unique_TCRef 10S0
 @Unique_TCRef 11S0
 */
- (void)testAddUpdateAndDeleteCommentJPLanguage
{
    [super runAllSitesTest:^{
        
        self.commentService = [[AlfrescoCommentService alloc] initWithSession:super.currentSession];
        __block NSString *content = @"ありがと　にほんご";
        
        
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
                 
                 [weakCommentService updateCommentOnNode:super.testAlfrescoDocument comment:comment content:content completionBlock:^(AlfrescoComment *comment, NSError *error)
                  {
                      
                      if (nil == comment)
                      {
                          super.lastTestSuccessful = NO;
                          super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                          super.callbackCompleted = YES;
                      }
                      else
                      {
                          STAssertTrue([comment.content isEqualToString:content], @"content should equal to %@ but instead we got %@", content, comment.content);
                          
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
