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

#import "AlfrescoCommentServiceTest.h"
#import "AlfrescoDocumentFolderService.h"
#import "AlfrescoLog.h"

@implementation AlfrescoCommentServiceTest


/*
 @Unique_TCRef 7S1
 */
- (void)testRetrieveAllComments
{
    if (self.setUpSuccess)
    {
        self.commentService = [[AlfrescoCommentService alloc] initWithSession:self.currentSession];
        
        // get all comments
        [self.commentService retrieveCommentsForNode:self.testAlfrescoDocument completionBlock:^(NSArray *array, NSError *error)
         {
             if (nil == array)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else
             {
                 STAssertNotNil(array, @"array should not be nil");
                 STAssertTrue(array.count == 0, @"newly uploaded document. We expect 0 comments");
                 if (array.count > 0)
                 {
                     AlfrescoComment *comment = [array objectAtIndex:0];
                     STAssertTrue([comment.content isEqualToString:@"<p>this is a test comment</p>"], @"content should equal the test comment message");
                     STAssertTrue([comment.createdBy isEqualToString:self.userName], @"comment.createdBy should be  %@",self.userName);
                     STAssertNotNil(comment.createdAt, @"creationDate should not be nil");
                     STAssertNotNil(comment.modifiedAt, @"modificationDate should not be nil");
                     STAssertTrue(comment.canEdit, @"canEdit should be true");
                     STAssertFalse(comment.canDelete, @"canDelete should be false");
                     STAssertNotNil(comment.name, @"name should not be nil");
                 }
                 
                 self.lastTestSuccessful = YES;
             }
             self.callbackCompleted = YES;
             
         }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"We could not run this test case");
    }
}

/*
 @Unique_TCRef 33S0
 @Unique_TCRef 24S0
 @Unique_TCRef 7F0
 */
- (void)testRetrieveAllCommentsForNonExistingDocuments
{
    if (self.setUpSuccess)
    {
        NSString *filename = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.testImageName];
        self.commentService = [[AlfrescoCommentService alloc] initWithSession:self.currentSession];
        __block AlfrescoDocumentFolderService *dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        //        __weak AlfrescoCommentService *weakService = self.commentService;
        
        [dfService createDocumentWithName:filename
                           inParentFolder:self.testDocFolder
                              contentFile:self.testImageFile
                               properties:nil
                          completionBlock:^(AlfrescoDocument *document, NSError *blockError){
                              
                              if (nil == document)
                              {
                                  self.lastTestSuccessful = NO;
                                  self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [blockError localizedDescription], [blockError localizedFailureReason]];
                                  self.callbackCompleted = YES;
                              }
                              else
                              {
                                  STAssertNotNil(document.identifier, @"document identifier should be filled");
                                  STAssertTrue(document.contentLength > 100, @"expected content to be filled");
                                  
                                  // delete the test document
                                  [dfService deleteNode:document completionBlock:^(BOOL success, NSError *deleteError)
                                   {
                                       if (!success)
                                       {
                                           self.lastTestSuccessful = NO;
                                           self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [deleteError localizedDescription], [deleteError localizedFailureReason]];
                                           self.callbackCompleted = YES;
                                       }
                                       else
                                       {
                                           [self.commentService retrieveCommentsForNode:document completionBlock:^(NSArray *comments, NSError *commentError){
                                               if (nil == comments)
                                               {
                                                   self.lastTestSuccessful = YES;
                                               }
                                               else
                                               {
                                                   self.lastTestSuccessful = NO;
                                                   self.lastTestFailureMessage = @"we shouldn't be getting comments for a deleted doc";
                                                   
                                               }
                                               self.callbackCompleted = YES;
                                           }];
                                       }
                                   }];
                              }
                          }
                            progressBlock:^(unsigned long long bytesUploaded, unsigned long long bytesTotal){
                            }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"We could not run this test case");
    }
}


/*
 @Unique_TCRef 8S0
 */
- (void)testRetrieveAllCommentsWithPaging
{
    if (self.setUpSuccess)
    {
        self.commentService = [[AlfrescoCommentService alloc] initWithSession:self.currentSession];
        
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:1 skipCount:0];
        
        // get all comments
        [self.commentService retrieveCommentsForNode:self.testAlfrescoDocument listingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error)
         {
             if (nil == pagingResult)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else
             {
                 STAssertNotNil(pagingResult, @"pagingResult should not be nil");
                 STAssertTrue(pagingResult.objects.count == 0, @"expected 0 comments");
                 STAssertTrue(pagingResult.totalItems == 0, @"expected total of 0 comments as we just uploaded the document");
                 
                 self.lastTestSuccessful = YES;
             }
             self.callbackCompleted = YES;
             
         }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"We could not run this test case");
    }
}

/*
 @Unique_TCRef 7S0
 @Unique_TCRef 9S0
 @Unique_TCRef 11S0
 */
- (void)testAddAndDeleteComment
{
    if (self.setUpSuccess)
    {
        self.commentService = [[AlfrescoCommentService alloc] initWithSession:self.currentSession];
        
        // add a comment
        __weak typeof(self) weakSelf = self;

        [self.commentService addCommentToNode:self.testAlfrescoDocument content:@"<p>test</p>" title:@"test" completionBlock:^(AlfrescoComment *comment, NSError *error) {
             if (nil == comment)
             {
                 weakSelf.lastTestSuccessful = NO;
                 weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 weakSelf.callbackCompleted = YES;
             }
             else
             {
                 STAssertTrueWeakSelf([comment.content isEqualToString:@"<p>test</p>"], @"content should equal the test comment message");
                 STAssertTrueWeakSelf([comment.createdBy isEqualToString:weakSelf.userName], @"comment.createdBy should be  %@",weakSelf.userName);
                 
                 [weakSelf.commentService retrieveCommentsForNode:weakSelf.testAlfrescoDocument completionBlock:^(NSArray *array, NSError *error){
                     if (nil == array)
                     {
                         weakSelf.lastTestSuccessful = NO;
                         weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                         weakSelf.callbackCompleted = YES;
                     }
                     else
                     {
                         STAssertNotNilWeakSelf(array, @"returned array of comments should not be nil");
                         STAssertTrueWeakSelf(1 == array.count, @"we expect one comment for the node");
                         if (array.count > 0)
                         {
                             STAssertTrueWeakSelf([comment.content isEqualToString:@"<p>test</p>"], @"content should equal the test comment message");
                             STAssertTrueWeakSelf([comment.createdBy isEqualToString:weakSelf.userName], @"comment.createdBy should be  %@",weakSelf.userName);
                             STAssertNotNilWeakSelf(comment.createdAt, @"creationDate should not be nil");
                             STAssertNotNilWeakSelf(comment.modifiedAt, @"modificationDate should not be nil");
                             STAssertFalseWeakSelf(comment.isEdited, @"isEdited should return false");
                         }
                         [weakSelf.commentService deleteCommentFromNode:weakSelf.testAlfrescoDocument comment:comment completionBlock:^(BOOL success, NSError *error)
                          {
                              if (!success)
                              {
                                  weakSelf.lastTestSuccessful = NO;
                                  weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                              }
                              else
                              {
                                  weakSelf.lastTestSuccessful = YES;
                              }
                              weakSelf.callbackCompleted = YES;
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
        STFail(@"We could not run this test case");
    }
}


/*
 @Unique_TCRef 7S0
 @Unique_TCRef 9S0
 @Unique_TCRef 10S0
 */
- (void)testAddAndUpdateCommentNonExisting
{
    if (self.setUpSuccess)
    {
        self.commentService = [[AlfrescoCommentService alloc] initWithSession:self.currentSession];
        
        // add a comment
        __weak typeof(self) weakSelf = self;
        [self.commentService addCommentToNode:self.testAlfrescoDocument content:@"<p>test</p>" title:@"test" completionBlock:^(AlfrescoComment *comment, NSError *error)
         {
             if (nil == comment)
             {
                 weakSelf.lastTestSuccessful = NO;
                 weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 weakSelf.callbackCompleted = YES;
             }
             else
             {
                 __block AlfrescoComment *strongComment = comment;
                 STAssertTrueWeakSelf([comment.content isEqualToString:@"<p>test</p>"], @"content should equal the test comment message");
                 STAssertTrueWeakSelf([comment.createdBy isEqualToString:weakSelf.userName], @"comment.createdBy should be  %@",weakSelf.userName);
                 
                 [weakSelf.commentService retrieveCommentsForNode:weakSelf.testAlfrescoDocument completionBlock:^(NSArray *array, NSError *error){
                     if (nil == array)
                     {
                         weakSelf.lastTestSuccessful = NO;
                         weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                         weakSelf.callbackCompleted = YES;
                     }
                     else
                     {
                         STAssertNotNilWeakSelf(array, @"returned array of comments should not be nil");
                         STAssertTrueWeakSelf(1 == array.count, @"we expect one comment for the node");
                         if (array.count > 0)
                         {
                             STAssertTrueWeakSelf([comment.content isEqualToString:@"<p>test</p>"], @"content should equal the test comment message");
                             STAssertTrueWeakSelf([comment.createdBy isEqualToString:weakSelf.userName], @"comment.createdBy should be  %@",weakSelf.userName);
                             STAssertNotNilWeakSelf(comment.createdAt, @"creationDate should not be nil");
                             STAssertNotNilWeakSelf(comment.modifiedAt, @"modificationDate should not be nil");
                         }
                         [weakSelf.commentService deleteCommentFromNode:weakSelf.testAlfrescoDocument comment:strongComment completionBlock:^(BOOL success, NSError *error)
                          {
                              if (!success)
                              {
                                  weakSelf.lastTestSuccessful = NO;
                                  weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                  weakSelf.callbackCompleted = YES;
                              }
                              else
                              {
                                  [weakSelf.commentService updateCommentOnNode:weakSelf.testAlfrescoDocument comment:strongComment content:@"Another string" completionBlock:^(AlfrescoComment *updatedComment, NSError *error){
                                      if (nil == updatedComment)
                                      {
                                          weakSelf.lastTestSuccessful = YES;
                                      }
                                      else
                                      {
                                          weakSelf.lastTestSuccessful = NO;
                                          weakSelf.lastTestFailureMessage = @"we shouldn't be able to update a deleted comment";
                                      }
                                      weakSelf.callbackCompleted = YES;
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
        STFail(@"We could not run this test case");
    }
}


/*
 @Unique_TCRef 33S0
 @Unique_TCRef 24S0
 @Unique_TCRef 9F0
 */
- (void)testAddAndDeleteForNonExistingDocument
{
    if (self.setUpSuccess)
    {
        NSString *filename = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.testImageName];
        self.commentService = [[AlfrescoCommentService alloc] initWithSession:self.currentSession];
        __block AlfrescoDocumentFolderService *dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        //        __weak AlfrescoCommentService *weakService = self.commentService;
        
        [dfService createDocumentWithName:filename inParentFolder:self.testDocFolder
                              contentFile:self.testImageFile
                               properties:nil
                          completionBlock:^(AlfrescoDocument *document, NSError *blockError){
                              
                              if (nil == document)
                              {
                                  self.lastTestSuccessful = NO;
                                  self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [blockError localizedDescription], [blockError localizedFailureReason]];
                                  self.callbackCompleted = YES;
                              }
                              else
                              {
                                  STAssertNotNil(document.identifier, @"document identifier should be filled");
                                  STAssertTrue(document.contentLength > 100, @"expected content to be filled");
                                  
                                  // delete the test document
                                  [dfService deleteNode:document completionBlock:^(BOOL success, NSError *deleteError)
                                   {
                                       if (!success)
                                       {
                                           self.lastTestSuccessful = NO;
                                           self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [deleteError localizedDescription], [deleteError localizedFailureReason]];
                                           self.callbackCompleted = YES;
                                       }
                                       else
                                       {
                                           __weak typeof(self) weakSelf = self;
                                           [self.commentService addCommentToNode:document content:@"blabla" title:@"test" completionBlock:^(AlfrescoComment *comment, NSError *commentError){
                                               if (nil == comment)
                                               {
                                                   weakSelf.lastTestSuccessful = YES;
                                               }
                                               else
                                               {
                                                   weakSelf.lastTestSuccessful = NO;
                                                   weakSelf.lastTestFailureMessage = @"we shouldn't be able to add comments for a deleted doc";
                                                   
                                               }
                                               weakSelf.callbackCompleted = YES;
                                           }];
                                       }
                                   }];
                              }
                          }
                            progressBlock:^(unsigned long long bytesUploaded, unsigned long long bytesTotal){
                            }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"We could not run this test case");
    }
}



/*
 @Unique_TCRef 7S0
 @Unique_TCRef 9S0, 9S5, 9S6
 @Unique_TCRef 11S0
 */
- (void)testAddAndDeleteCommentEULanguages
{
    if (self.setUpSuccess)
    {
        self.commentService = [[AlfrescoCommentService alloc] initWithSession:self.currentSession];
        __block NSString *content = @"Übersicht Ändern Östrogen und das mit ß";
        __block NSString *title = @"Änderungswünsche";
        
        // add a comment
        __weak typeof(self) weakSelf = self;
        [self.commentService addCommentToNode:self.testAlfrescoDocument content:content title:title completionBlock:^(AlfrescoComment *comment, NSError *error) {
             if (nil == comment)
             {
                 weakSelf.lastTestSuccessful = NO;
                 weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 weakSelf.callbackCompleted = YES;
             }
             else
             {
                 STAssertTrueWeakSelf([comment.content isEqualToString:content], @"content should equal the test comment message, which is %@. But instead we got %@",content, comment.content);
                 STAssertTrueWeakSelf([comment.createdBy isEqualToString:weakSelf.userName], @"comment.createdBy should be  %@",weakSelf.userName);
                 if (!weakSelf.isCloud)
                 {
                     STAssertTrueWeakSelf([comment.title isEqualToString:title], @"the comment title should be equal to %@ but instead we got %@",title, comment.title);
                 }
                 [weakSelf.commentService retrieveCommentsForNode:weakSelf.testAlfrescoDocument completionBlock:^(NSArray *array, NSError *error){
                     if (nil == array)
                     {
                         weakSelf.lastTestSuccessful = NO;
                         weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                         weakSelf.callbackCompleted = YES;
                     }
                     else
                     {
                         STAssertNotNilWeakSelf(array, @"returned array of comments should not be nil");
                         STAssertTrueWeakSelf(1 == array.count, @"we expect one comment for the node");
                         if (array.count > 0)
                         {
                             AlfrescoComment *retrievedComment = (AlfrescoComment *)[array objectAtIndex:0];
                             STAssertTrueWeakSelf([retrievedComment.content isEqualToString:content],@"content should equal the test comment message, which is %@. But instead we got %@",content, retrievedComment.content);
                             if (!weakSelf.isCloud)
                             {
                                 STAssertTrueWeakSelf([retrievedComment.title isEqualToString:title], @"the comment title should be equal to %@ but instead we got %@",title, retrievedComment.title);
                             }
                             STAssertTrueWeakSelf([retrievedComment.createdBy isEqualToString:weakSelf.userName], @"comment.createdBy should be  %@",weakSelf.userName);
                             STAssertNotNilWeakSelf(retrievedComment.createdAt, @"creationDate should not be nil");
                             STAssertNotNilWeakSelf(retrievedComment.modifiedAt, @"modificationDate should not be nil");
                         }
                         [weakSelf.commentService deleteCommentFromNode:weakSelf.testAlfrescoDocument comment:comment completionBlock:^(BOOL success, NSError *error)
                          {
                              if (!success)
                              {
                                  weakSelf.lastTestSuccessful = NO;
                                  weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                              }
                              else
                              {
                                  weakSelf.lastTestSuccessful = YES;
                              }
                              weakSelf.callbackCompleted = YES;
                              
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
        STFail(@"We could not run this test case");
    }
}

/*
 @Unique_TCRef 7S0
 @Unique_TCRef 9S0, 9S5, 9S6
 @Unique_TCRef 11S0
 */
- (void)testAddAndDeleteCommentJPLanguages
{
    if (self.setUpSuccess)
    {
        self.commentService = [[AlfrescoCommentService alloc] initWithSession:self.currentSession];
        __block NSString *content = @"ありがと　にほんご";
        __block NSString *title = @"わさび";
        
        // add a comment
        __weak typeof(self) weakSelf = self;
        [self.commentService addCommentToNode:self.testAlfrescoDocument content:content title:title completionBlock:^(AlfrescoComment *comment, NSError *error) {
            if (nil == comment)
            {
                weakSelf.lastTestSuccessful = NO;
                weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                weakSelf.callbackCompleted = YES;
            }
            else
            {
                STAssertTrueWeakSelf([comment.content isEqualToString:content], @"content should equal the test comment message, which is %@. But instead we got %@",content, comment.content);
                STAssertTrueWeakSelf([comment.createdBy isEqualToString:weakSelf.userName], @"comment.createdBy should be  %@",weakSelf.userName);
                if (!weakSelf.isCloud)
                {
                    STAssertTrueWeakSelf([comment.title isEqualToString:title], @"the comment title should be equal to %@ but instead we got %@",title, comment.title);
                }
                [weakSelf.commentService retrieveCommentsForNode:weakSelf.testAlfrescoDocument completionBlock:^(NSArray *array, NSError *error){
                    if (nil == array)
                    {
                        weakSelf.lastTestSuccessful = NO;
                        weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                        weakSelf.callbackCompleted = YES;
                    }
                    else
                    {
                        STAssertNotNilWeakSelf(array, @"returned array of comments should not be nil");
                        STAssertTrueWeakSelf(1 == array.count, @"we expect one comment for the node");
                        if (array.count > 0)
                        {
                            AlfrescoComment *retrievedComment = (AlfrescoComment *)[array objectAtIndex:0];
                            STAssertTrueWeakSelf([retrievedComment.content isEqualToString:content],@"content should equal the test comment message, which is %@. But instead we got %@",content, retrievedComment.content);
                            if (!weakSelf.isCloud)
                            {
                                STAssertTrueWeakSelf([retrievedComment.title isEqualToString:title], @"the comment title should be equal to %@ but instead we got %@",title, retrievedComment.title);
                            }
                            STAssertTrueWeakSelf([retrievedComment.createdBy isEqualToString:weakSelf.userName], @"comment.createdBy should be  %@",weakSelf.userName);
                            STAssertNotNilWeakSelf(retrievedComment.createdAt, @"creationDate should not be nil");
                            STAssertNotNilWeakSelf(retrievedComment.modifiedAt, @"modificationDate should not be nil");
                        }
                        [weakSelf.commentService deleteCommentFromNode:weakSelf.testAlfrescoDocument comment:comment completionBlock:^(BOOL success, NSError *error)
                         {
                             if (!success)
                             {
                                 weakSelf.lastTestSuccessful = NO;
                                 weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                             }
                             else
                             {
                                 weakSelf.lastTestSuccessful = YES;
                             }
                             weakSelf.callbackCompleted = YES;
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
        STFail(@"We could not run this test case");
    }
}


/*
 @Unique_TCRef 7S0
 @Unique_TCRef 10S0
 @Unique_TCRef 11S0
 */
- (void)testAddUpdateAndDeleteComment
{
    if (self.setUpSuccess)
    {
        self.commentService = [[AlfrescoCommentService alloc] initWithSession:self.currentSession];
        
        
        // add a comment
        __weak typeof(self) weakSelf = self;
        [self.commentService addCommentToNode:self.testAlfrescoDocument content:@"<p>test</p>" title:@"test" completionBlock:^(AlfrescoComment *comment, NSError *error) {
            if (nil == comment)
            {
                weakSelf.lastTestSuccessful = NO;
                weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                weakSelf.callbackCompleted = YES;
            }
            else
            {
                STAssertTrueWeakSelf([comment.content isEqualToString:@"<p>test</p>"], @"content should equal the test comment message");
                STAssertTrueWeakSelf([comment.createdBy isEqualToString:weakSelf.userName], @"comment.createdBy should be  %@",weakSelf.userName);
                
                [weakSelf.commentService updateCommentOnNode:weakSelf.testAlfrescoDocument comment:comment content:@"<p>test2</p>" completionBlock:^(AlfrescoComment *comment, NSError *error)
                 {
                     
                     if (nil == comment)
                     {
                         weakSelf.lastTestSuccessful = NO;
                         weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                         weakSelf.callbackCompleted = YES;
                     }
                     else
                     {
                         STAssertTrueWeakSelf([comment.content isEqualToString:@"<p>test2</p>"], @"content should equal the test comment message");
                         
                         [weakSelf.commentService deleteCommentFromNode:weakSelf.testAlfrescoDocument comment:comment completionBlock:^(BOOL success, NSError *error)
                          {
                              if (!success)
                              {
                                  weakSelf.lastTestSuccessful = NO;
                                  weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                              }
                              else
                              {
                                  weakSelf.lastTestSuccessful = YES;
                              }
                              weakSelf.callbackCompleted = YES;
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
        STFail(@"We could not run this test case");
    }
}

/*
 @Unique_TCRef 7S5
 @Unique_TCRef 10S0
 @Unique_TCRef 11S0
 */
- (void)testAddUpdateAndDeleteCommentEULanguages
{
    if (self.setUpSuccess)
    {
        self.commentService = [[AlfrescoCommentService alloc] initWithSession:self.currentSession];
        __block NSString *content = @"Übersicht Ändern Östrogen und das mit ß";
        
        
        // add a comment
        __weak typeof(self) weakSelf = self;
        [self.commentService addCommentToNode:self.testAlfrescoDocument content:@"<p>test</p>" title:@"test" completionBlock:^(AlfrescoComment *comment, NSError *error) {
            if (nil == comment)
            {
                weakSelf.lastTestSuccessful = NO;
                weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                weakSelf.callbackCompleted = YES;
            }
            else
            {
                STAssertTrueWeakSelf([comment.content isEqualToString:@"<p>test</p>"], @"content should equal the test comment message");
                STAssertTrueWeakSelf([comment.createdBy isEqualToString:weakSelf.userName], @"comment.createdBy should be  %@",weakSelf.userName);
                
                [weakSelf.commentService updateCommentOnNode:weakSelf.testAlfrescoDocument comment:comment content:content completionBlock:^(AlfrescoComment *comment, NSError *error)
                 {
                     
                     if (nil == comment)
                     {
                         weakSelf.lastTestSuccessful = NO;
                         weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                         weakSelf.callbackCompleted = YES;
                     }
                     else
                     {
                         STAssertTrueWeakSelf([comment.content isEqualToString:content], @"content should equal to %@ but instead we got %@", content, comment.content);
                         
                         [weakSelf.commentService deleteCommentFromNode:weakSelf.testAlfrescoDocument comment:comment completionBlock:^(BOOL success, NSError *error)
                          {
                              if (!success)
                              {
                                  weakSelf.lastTestSuccessful = NO;
                                  weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                              }
                              else
                              {
                                  weakSelf.lastTestSuccessful = YES;
                              }
                              weakSelf.callbackCompleted = YES;
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
        STFail(@"We could not run this test case");
    }
}

/*
 @Unique_TCRef 7S6
 @Unique_TCRef 10S0
 @Unique_TCRef 11S0
 */
- (void)testAddUpdateAndDeleteCommentJPLanguage
{
    if (self.setUpSuccess)
    {
        self.commentService = [[AlfrescoCommentService alloc] initWithSession:self.currentSession];
        __block NSString *content = @"ありがと　にほんご";
        
        
        // add a comment
        __weak typeof(self) weakSelf = self;
        [self.commentService addCommentToNode:self.testAlfrescoDocument content:@"<p>test</p>" title:@"test" completionBlock:^(AlfrescoComment *comment, NSError *error) {
            if (nil == comment)
            {
                weakSelf.lastTestSuccessful = NO;
                weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                weakSelf.callbackCompleted = YES;
            }
            else
            {
                STAssertTrueWeakSelf([comment.content isEqualToString:@"<p>test</p>"], @"content should equal the test comment message");
                STAssertTrueWeakSelf([comment.createdBy isEqualToString:weakSelf.userName], @"comment.createdBy should be  %@",weakSelf.userName);
                
                [weakSelf.commentService updateCommentOnNode:weakSelf.testAlfrescoDocument comment:comment content:content completionBlock:^(AlfrescoComment *comment, NSError *error)
                 {
                     
                     if (nil == comment)
                     {
                         weakSelf.lastTestSuccessful = NO;
                         weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                         weakSelf.callbackCompleted = YES;
                     }
                     else
                     {
                         STAssertTrueWeakSelf([comment.content isEqualToString:content], @"content should equal to %@ but instead we got %@", content, comment.content);
                         
                         [weakSelf.commentService deleteCommentFromNode:weakSelf.testAlfrescoDocument comment:comment completionBlock:^(BOOL success, NSError *error)
                          {
                              if (!success)
                              {
                                  weakSelf.lastTestSuccessful = NO;
                                  weakSelf.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                              }
                              else
                              {
                                  weakSelf.lastTestSuccessful = YES;
                              }
                              weakSelf.callbackCompleted = YES;
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
        STFail(@"We could not run this test case");
    }
}


@end
