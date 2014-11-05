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

#import "AlfrescoVersionServiceTest.h"
#import "AlfrescoLog.h"
#import "AlfrescoErrors.h"
#import "AlfrescoProperty.h"

@implementation AlfrescoVersionServiceTest

/*
 */

/*
 @Unique_TCRef 57S1
 @Unique_TCRef 17S6
 */
- (void)testRetrieveAllVersions
{
    if (self.setUpSuccess)
    {
        self.versionService = [[AlfrescoVersionService alloc] initWithSession:self.currentSession];
        __block AlfrescoDocumentFolderService *documentService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        [documentService retrieveNodeWithIdentifier:self.testAlfrescoDocument.identifier completionBlock:^(AlfrescoNode *node, NSError *error)
         {
             if (nil == node)
             {
                 documentService = nil;
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 self.callbackCompleted = YES;
             }
             else
             {
                 [self.versionService retrieveAllVersionsOfDocument:(AlfrescoDocument *)node completionBlock:^(NSArray *array, NSError *error)
                  {
                      if (nil == array)
                      {
                          self.lastTestSuccessful = NO;
                          self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                      }
                      else
                      {
                          XCTAssertNotNil(array, @"array should not be nil");
                          XCTAssertTrue(array.count == 1, @"expected 1 version");
                          AlfrescoNode * temp = array[0];
                          
                          NSLog(@"Temp.name =  %@", temp.name);
                          self.lastTestSuccessful = YES;
                      }
                      self.callbackCompleted = YES;
                      
                  }];
                 
                 documentService = nil;
             }
             
         }
         ];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 @Unique_TCRef 57S1
 @Unique_TCRef 57S2
 @Unique_TCRef 57S3
 @Unique_TCRef 57S4
 @Unique_TCRef 58F3
 @Unique_TCRef 58F4
 */
- (void)testRetrieveVersionComment
{
    if (self.setUpSuccess)
    {
        if (!self.isCloud)
        {
            self.versionService = [[AlfrescoVersionService alloc] initWithSession:self.currentSession];
            __block AlfrescoDocumentFolderService *documentService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
            
            NSString *versionedFile = [self.testFolderPathName stringByAppendingPathComponent:@"multiple-versions.txt"];
            [documentService retrieveNodeWithFolderPath:versionedFile completionBlock:^(AlfrescoNode *node, NSError *error) {
                 if (nil == node)
                 {
                     documentService = nil;
                     self.lastTestSuccessful = NO;
                     self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                     self.callbackCompleted = YES;
                 }
                 else
                 {
                     [self.versionService retrieveAllVersionsOfDocument:(AlfrescoDocument *)node completionBlock:^(NSArray *array, NSError *error)
                      {
                          if (nil == array)
                          {
                              self.lastTestSuccessful = NO;
                              self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                          }
                          else
                          {
                              XCTAssertNotNil(array, @"array should not be nil");
                              
                              __block BOOL versionCommentRetrieved = NO;
                              
                              [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                               {
                                   AlfrescoDocument *node = (AlfrescoDocument *)obj;
                                   
                                   if (node.versionComment != nil)
                                   {
                                       versionCommentRetrieved = YES;
                                       *stop = YES;
                                   }
                               }
                               ];
                              
                              XCTAssertTrue(versionCommentRetrieved, @"version comment was retrieved successfully");
                              
                              self.lastTestSuccessful = YES;
                          }
                          self.callbackCompleted = YES;
                      }
                      ];
                     
                     documentService = nil;
                 }
             }
             ];
            
            [self waitUntilCompleteWithFixedTimeInterval];
            XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
        }
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 @Unique_TCRef 58S1
 @Unique_TCRef 17S6
 */
- (void)testRetrieveAllVersionsWithPaging
{
    if (self.setUpSuccess)
    {
        self.versionService = [[AlfrescoVersionService alloc] initWithSession:self.currentSession];
        __block AlfrescoDocumentFolderService *documentService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:1 skipCount:0];
        
        [documentService retrieveNodeWithIdentifier:self.testAlfrescoDocument.identifier completionBlock:^(AlfrescoNode *node, NSError *error)
         {
             if (nil == node)
             {
                 documentService = nil;
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 self.callbackCompleted = YES;
             }
             else
             {
                 [self.versionService retrieveAllVersionsOfDocument:(AlfrescoDocument *)node listingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error)
                  {
                      if (nil == pagingResult)
                      {
                          self.lastTestSuccessful = NO;
                          self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                      }
                      else
                      {
                          XCTAssertNotNil(pagingResult, @"pagingResult should not be nil");
                          XCTAssertTrue(pagingResult.objects.count == 1, @"expected 1 version, but got %lu", (unsigned long)pagingResult.objects.count);
                          XCTAssertTrue(pagingResult.totalItems >= 1, @"expected at least 1 version in total");
                          
                          self.lastTestSuccessful = YES;
                      }
                      self.callbackCompleted = YES;
                      
                  }];
                 
                 documentService = nil;
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

- (void)testUpdateContentWithVersioningForDocument
{
    if (self.setUpSuccess)
    {
        if (!self.isCloud)
        {
            XCTAssertTrue(YES, @"");
        }
        else
        {
            self.versionService = [[AlfrescoVersionService alloc] initWithSession:self.currentSession];
            __block AlfrescoDocumentFolderService *documentService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
            
            [documentService retrieveNodeWithIdentifier:self.testAlfrescoDocument.identifier completionBlock:^(AlfrescoNode *node, NSError *error)
             {
                 if (nil == node)
                 {
                     documentService = nil;
                     self.lastTestSuccessful = NO;
                     self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                     self.callbackCompleted = YES;
                 }
                 else
                 {
                     AlfrescoDocument *document = (AlfrescoDocument *)node;
                     NSDate *createdAt = document.createdAt;
                     __unused NSDate *modifiedAt = document.modifiedAt;
                     
                     [self.versionService retrieveAllVersionsOfDocument:document completionBlock:^(NSArray *array, NSError *error)
                      {
                          if (nil == array)
                          {
                              self.lastTestSuccessful = NO;
                              self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                              self.callbackCompleted = YES;
                          }
                          else
                          {
                              XCTAssertNotNil(array, @"array should not be nil");
                              XCTAssertTrue(array.count == 1, @"expected 1 version");
                              NSString *versionLabel = document.versionLabel;
                              [documentService retrieveContentOfDocument:document completionBlock:^(AlfrescoContentFile *content, NSError *error){
                                  if (nil == content)
                                  {
                                      self.lastTestSuccessful = NO;
                                      self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                      self.callbackCompleted = YES;
                                      
                                  }
                                  else
                                  {
                                      NSError *readError = nil;
                                      __block NSString *stringContent = [NSString stringWithContentsOfFile:[content.fileUrl path]
                                                                                                  encoding:NSUTF8StringEncoding error:&readError];
                                      __block NSString *updatedContent = [NSString stringWithFormat:@"%@ - and we added some text.",stringContent];
                                      NSData *data = [updatedContent dataUsingEncoding:NSUTF8StringEncoding];
                                      __block AlfrescoContentFile *updatedContentFile = [[AlfrescoContentFile alloc] initWithData:data mimeType:content.mimeType];
                                      [documentService updateContentOfDocument:document contentFile:updatedContentFile completionBlock:^(AlfrescoDocument *updatedDocument, NSError *error){
                                          if (nil == updatedDocument)
                                          {
                                              self.lastTestSuccessful = NO;
                                              self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                              self.callbackCompleted = YES;
                                          }
                                          else
                                          {
                                              [self.versionService retrieveAllVersionsOfDocument:updatedDocument completionBlock:^(NSArray *versions, NSError *error){
                                                  if (nil == versions)
                                                  {
                                                      self.lastTestSuccessful = NO;
                                                      self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                                      self.callbackCompleted = YES;
                                                  }
                                                  else
                                                  {
                                                      XCTAssertTrue(versions.count == 2, @"the versions count should have been incremented to 2. Instead we got %lu", (unsigned long)versions.count);
                                                      self.lastTestSuccessful = YES;
                                                      BOOL foundPreviousVersion = NO;
                                                      AlfrescoDocument *lastDocument = nil;
                                                      for (AlfrescoDocument *doc in versions)
                                                      {
                                                          if ([doc.versionLabel isEqualToString:versionLabel])
                                                          {
                                                              foundPreviousVersion = YES;
                                                          }
                                                          if (doc.isLatestVersion)
                                                          {
                                                              lastDocument = doc;
                                                              BOOL hasHigherVersion = [AlfrescoVersionServiceTest isHigherVersionLabel:doc.versionLabel previousLabel:versionLabel];
                                                              XCTAssertTrue(hasHigherVersion, @"The version label of the latest doc should be higher than the previous one");
                                                          }
                                                      }
                                                      XCTAssertTrue(foundPreviousVersion, @"The array of document versions should still contain the previous version, but doesn't");
                                                      if (nil != lastDocument)
                                                      {
                                                          [documentService retrieveContentOfDocument:lastDocument completionBlock:^(AlfrescoContentFile *content, NSError *contentError){
                                                              if (nil == content)
                                                              {
                                                                  self.lastTestSuccessful = NO;
                                                                  self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [contentError localizedDescription], [contentError localizedFailureReason]];
                                                              }
                                                              else
                                                              {
                                                                  NSError *fileError = nil;
                                                                  NSDictionary *fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:[content.fileUrl path] error:&fileError];
                                                                  XCTAssertNil(fileError, @"expected no error with getting file attributes for content file at path %@", [content.fileUrl path]);
                                                                  unsigned long long size = [[fileDict valueForKey:NSFileSize] unsignedLongLongValue];
                                                                  XCTAssertTrue(size > 0, @"checkContentFile length should be greater than 0. We got %llu", size);
                                                                  NSError *checkError = nil;
                                                                  NSString *checkContentString = [NSString stringWithContentsOfFile:[content.fileUrl path]
                                                                                                                           encoding:NSUTF8StringEncoding
                                                                                                                              error:&checkError];
                                                                  
                                                                  NSDate *earlierDate = [createdAt earlierDate:lastDocument.modifiedAt];
                                                                  XCTAssertTrue([earlierDate isEqualToDate:createdAt], @"The modified Date should come AFTER the original date");
                                                                  if (nil == checkContentString)
                                                                  {
                                                                      self.lastTestSuccessful = NO;
                                                                      self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [checkError localizedDescription], [checkError localizedFailureReason]];
                                                                  }
                                                                  else
                                                                  {
                                                                      XCTAssertTrue([checkContentString isEqualToString:updatedContent], @"We should get back the updated content, instead we get %@", checkContentString);
                                                                      self.lastTestSuccessful = YES;
                                                                  }
                                                                  
                                                              }
                                                              self.callbackCompleted = YES;
                                                          } progressBlock:^(unsigned long long transferred, unsigned long long total){}];
                                                          
                                                      }
                                                      else
                                                      {
                                                          self.callbackCompleted = YES;
                                                      }
                                                  }
                                              }];
                                          }
                                      } progressBlock:^(unsigned long long bytesTransferred, unsigned long long bytesTotal){}];
                                      
                                  }
                                  
                                  
                              } progressBlock:^(unsigned long long bytesTransferred, unsigned long long bytesTotal){}];
                              self.lastTestSuccessful = YES;
                          }
                          self.callbackCompleted = YES;
                          
                      }];
                     
                     documentService = nil;
                 }
                 
             }
             ];
            
            [self waitUntilCompleteWithFixedTimeInterval];
            XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
            
        }
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testCheckoutCheckin
{
    if (self.setUpSuccess)
    {
        self.versionService = [[AlfrescoVersionService alloc] initWithSession:self.currentSession];
        
        // capture current version
        NSString *startingVersionLabel = self.testAlfrescoDocument.versionLabel;
        
        [self.versionService checkoutDocument:self.testAlfrescoDocument completionBlock:^(AlfrescoDocument *checkedOutDocument, NSError *checkoutError) {
            if (checkedOutDocument == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"Checkout Error: %@ - %@", [checkoutError localizedDescription], [checkoutError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                // create some content to checkin with
                NSString *updatedContent = @"This should be the v1.1 content.";
                NSString *versionComment = @"Version 1.1";
                NSData *data = [updatedContent dataUsingEncoding:NSUTF8StringEncoding];
                AlfrescoContentFile *updatedContentFile = [[AlfrescoContentFile alloc] initWithData:data mimeType:@"text/plain"];
                
                // also update some properties
                NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                properties[kAlfrescoModelPropertyTitle] = @"Updated by checkin";
                properties[kAlfrescoModelPropertyExifManufacturer] = @"Canon";
                
                // sleep for a couple of seconds before checking back in
                [NSThread sleepForTimeInterval:2.0];
                
                [self.versionService checkinDocument:checkedOutDocument asMajorVersion:NO contentFile:updatedContentFile
                                          properties:properties comment:versionComment completionBlock:^(AlfrescoDocument *checkedInDocument, NSError *checkinError) {
                                              if (checkedInDocument == nil)
                                              {
                                                  self.lastTestSuccessful = NO;
                                                  self.lastTestFailureMessage = [NSString stringWithFormat:@"Checkin Error: %@ - %@", [checkoutError localizedDescription], [checkoutError localizedFailureReason]];
                                                  
                                                  // cancel the checkout to cleanup
                                                  [self.versionService cancelCheckoutOfDocument:checkedOutDocument completionBlock:^(BOOL succeeded, NSError *error) {
                                                      self.callbackCompleted = YES;
                                                  }];
                                              }
                                              else
                                              {
                                                  // check version label
                                                  XCTAssertFalse([checkedInDocument.versionLabel isEqualToString:startingVersionLabel],
                                                                 @"Expected version label to change but it was: %@", checkedInDocument.versionLabel);
                                                  XCTAssertTrue([checkedInDocument.versionLabel isEqualToString:@"1.1"],
                                                                @"Expected version label to be 1.1 but it was: %@", checkedInDocument.versionLabel);
                                                  XCTAssertTrue([checkedInDocument.versionComment isEqualToString:versionComment],
                                                                @"Expected version comment to be %@ but it was: %@", versionComment, checkedInDocument.versionComment);
                                                  XCTAssertTrue(checkedInDocument.isLatestVersion, @"Expected document to be the latest version");
                                                  
                                                  // check properties were updated and aspects are present
                                                  XCTAssertTrue([checkedInDocument hasAspectWithName:kAlfrescoModelAspectTitled],
                                                                @"Expected the checked in document to have the titled aspect");
                                                  XCTAssertTrue([checkedInDocument hasAspectWithName:kAlfrescoModelAspectExif],
                                                                @"Expected the checked in document to have the exif aspect");
                                                  AlfrescoProperty *updatedTitle = checkedInDocument.properties[kAlfrescoModelPropertyTitle];
                                                  XCTAssertTrue([updatedTitle.value isEqualToString:@"Updated by checkin"],
                                                                @"Expected the title to be Updated by checkin but it was :%@", updatedTitle.value);
                                                  AlfrescoProperty *updatedManufacturer = checkedInDocument.properties[kAlfrescoModelPropertyExifManufacturer];
                                                  XCTAssertTrue([updatedManufacturer.value isEqualToString:@"Canon"],
                                                                @"Expected the author to be Canon but it was: %@", updatedManufacturer.value);
                                                  
                                                  // check content got updated
                                                  AlfrescoDocumentFolderService *documentService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
                                                  [documentService retrieveContentOfDocument:checkedInDocument completionBlock:^(AlfrescoContentFile *contentFile, NSError *retrieveError) {
                                                      if (contentFile == nil)
                                                      {
                                                          self.lastTestSuccessful = NO;
                                                          self.lastTestFailureMessage = [NSString stringWithFormat:@"Retrieve Error: %@ - %@", [checkoutError localizedDescription], [checkoutError localizedFailureReason]];
                                                          self.callbackCompleted = YES;
                                                      }
                                                      else
                                                      {
                                                          NSError *fileError = nil;
                                                          NSDictionary *fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:[contentFile.fileUrl path] error:&fileError];
                                                          XCTAssertNil(fileError, @"Expected no error with getting file attributes for content file at path %@", [contentFile.fileUrl path]);
                                                          unsigned long long size = [[fileDict valueForKey:NSFileSize] unsignedLongLongValue];
                                                          XCTAssertTrue(size > 0, @"checkContentFile length should be greater than 0. We got %llu", size);
                                                          NSError *contentError = nil;
                                                          NSString *checkedInContent = [NSString stringWithContentsOfFile:[contentFile.fileUrl path]
                                                                                                                 encoding:NSUTF8StringEncoding
                                                                                                                    error:&contentError];
                                                          
                                                          if (nil == checkedInContent)
                                                          {
                                                              self.lastTestSuccessful = NO;
                                                              self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [contentError localizedDescription], [contentError localizedFailureReason]];
                                                          }
                                                          else
                                                          {
                                                              XCTAssertTrue([checkedInContent isEqualToString:updatedContent],
                                                                            @"Expected to get back the updated content, instead we got: %@", checkedInContent);
                                                              self.lastTestSuccessful = YES;
                                                          }
                                                          
                                                          self.callbackCompleted = YES;
                                                      }
                                                  } progressBlock:^(unsigned long long bytesDownloaded, unsigned long long bytesTotal) {
                                                      AlfrescoLogDebug(@"content retrieval progress %i/%i", bytesDownloaded, bytesTotal);
                                                  }];
                                              }
                                          } progressBlock:^(unsigned long long bytesUploaded, unsigned long long bytesTotal) {
                                              AlfrescoLogDebug(@"checkin progress %i/%i", bytesUploaded, bytesTotal);
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

- (void)testCancelCheckout
{
    if (self.setUpSuccess)
    {
        self.versionService = [[AlfrescoVersionService alloc] initWithSession:self.currentSession];
        
        [self.versionService checkoutDocument:self.testAlfrescoDocument completionBlock:^(AlfrescoDocument *checkedOutDocument, NSError *checkoutError) {
            if (checkedOutDocument == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"Checkout Error: %@ - %@", [checkoutError localizedDescription], [checkoutError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                // remember the nodeIdentifier of the private working copy
                NSString *pwcNodeIdentifier = checkedOutDocument.identifier;
                
                // cancel the checkout
                [self.versionService cancelCheckoutOfDocument:checkedOutDocument completionBlock:^(BOOL succeeded, NSError *cancelCheckoutError) {
                    if(succeeded)
                    {
                        // ensure the private working copy has been deleted
                        AlfrescoDocumentFolderService *documentService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
                        [documentService retrieveNodeWithIdentifier:pwcNodeIdentifier completionBlock:^(AlfrescoNode *node, NSError *retrieveError) {
                            if (node != nil)
                            {
                                self.lastTestSuccessful = NO;
                                self.lastTestFailureMessage = @"Expected the private working copy to have been deleted";
                                self.callbackCompleted = YES;
                            }
                            else
                            {
                                XCTAssertNotNil(retrieveError, @"Expected the retrieveError object to be returned");
                                XCTAssertTrue(retrieveError.code == kAlfrescoErrorCodeRequestedNodeNotFound,
                                              @"Expected error code to be 2 (kAlfrescoErrorCodeRequestedNodeNotFound) but was %ld", (long)retrieveError.code);

                                self.lastTestSuccessful = YES;
                                self.callbackCompleted = YES;
                            }
                        }];
                    }
                    else
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"Cancel Checkout Error: %@ - %@", [cancelCheckoutError localizedDescription], [cancelCheckoutError localizedFailureReason]];
                        self.callbackCompleted = YES;
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

- (void)testRetrieveCheckedOutDocuments
{
    if (self.setUpSuccess)
    {
        self.versionService = [[AlfrescoVersionService alloc] initWithSession:self.currentSession];
        
        [self.versionService checkoutDocument:self.testAlfrescoDocument completionBlock:^(AlfrescoDocument *checkedOutDocument, NSError *checkoutError) {
            if (checkedOutDocument == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [self failureMessageFromError:checkoutError];
                self.callbackCompleted = YES;
            }
            else
            {
                // remember the nodeIdentifier of the private working copy
                NSString *pwcNodeIdentifier = checkedOutDocument.identifier;
                
                // retrieve the checked out documents
                [self.versionService retrieveCheckedOutDocumentsWithCompletionBlock:^(NSArray *checkedOutDocs, NSError *retrieveError) {
                    if (checkedOutDocs == nil)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [self failureMessageFromError:retrieveError];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        // make sure the one we just checked out is present
                        BOOL pwcFound = NO;
                        for (AlfrescoDocument *document in checkedOutDocs)
                        {
                            if ([document.identifier isEqualToString:pwcNodeIdentifier])
                            {
                                pwcFound = YES;
                                break;
                            }
                        }
                        
                        XCTAssertTrue(pwcFound, @"Expected to find the private working copy in the list of checked out documents");
                        
                        // cancel the checkout
                        [self.versionService cancelCheckoutOfDocument:checkedOutDocument completionBlock:^(BOOL succeeded, NSError *cancelCheckoutError) {
                            if (succeeded)
                            {
                                // retrieve the checked out documents again
                                [self.versionService retrieveCheckedOutDocumentsWithCompletionBlock:^(NSArray *checkedOutDocs2, NSError *retrieveError2) {
                                    if (checkedOutDocs2 == nil)
                                    {
                                        self.lastTestSuccessful = NO;
                                        self.lastTestFailureMessage = [self failureMessageFromError:retrieveError2];
                                        self.callbackCompleted = YES;
                                    }
                                    else
                                    {
                                        // make sure the one we just checked out is no longer present
                                        BOOL pwcFound = NO;
                                        for (AlfrescoDocument *document in checkedOutDocs2)
                                        {
                                            if ([document.identifier isEqualToString:pwcNodeIdentifier])
                                            {
                                                pwcFound = YES;
                                                break;
                                            }
                                        }
                                        
                                        XCTAssertFalse(pwcFound, @"Did not expect to find the private working copy in the list of checked out documents");
                                        
                                        self.lastTestSuccessful = YES;
                                        self.callbackCompleted = YES;
                                    }
                                }];
                            }
                            else
                            {
                                self.lastTestSuccessful = NO;
                                self.lastTestFailureMessage = [NSString stringWithFormat:@"Cancel Checkout Error: %@ - %@", [cancelCheckoutError localizedDescription], [cancelCheckoutError localizedFailureReason]];
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

+ (BOOL)isHigherVersionLabel:(NSString *)lastVersionLabel previousLabel:(NSString *)previousLabel
{
    if (nil == lastVersionLabel || nil == previousLabel)
    {
        return NO;
    }
    if ([lastVersionLabel isEqualToString:previousLabel])
    {
        return NO;
    }
    if (lastVersionLabel.length != previousLabel.length)
    {
        return NO;
    }
    BOOL isHigherVersion = NO;
    NSArray *firstComponents = [lastVersionLabel componentsSeparatedByString:@"."];
    NSArray *secondComponents = [previousLabel componentsSeparatedByString:@"."];
    for (int i = 0; i < firstComponents.count; i++)
    {
        int first = [firstComponents[i] intValue];
        int second = [secondComponents[i] intValue];
        if (first > second)
        {
            isHigherVersion = YES;
            break;
        }
    }
    
    return isHigherVersion;
}

@end
