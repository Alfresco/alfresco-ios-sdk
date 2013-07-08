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
#import "AlfrescoDocumentFolderService.h"

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
                          STAssertNotNil(array, @"array should not be nil");
                          STAssertTrue(array.count == 1, @"expected 1 version");
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
        STAssertTrue(self.lastTestSuccessful, self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
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
            
            [documentService retrieveNodeWithFolderPath:@"/multiple-versions.txt" completionBlock:^(AlfrescoNode *node, NSError *error)
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
                              STAssertNotNil(array, @"array should not be nil");
                              
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
                              
                              STAssertTrue(versionCommentRetrieved, @"version comment was retrieved successfully");
                              
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
            STAssertTrue(self.lastTestSuccessful, self.lastTestFailureMessage);
        }
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
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
                          STAssertNotNil(pagingResult, @"pagingResult should not be nil");
                          STAssertTrue(pagingResult.objects.count == 1, @"expected 1 version, but got %d",pagingResult.objects.count);
                          STAssertTrue(pagingResult.totalItems >= 1, @"expected at least 1 version in total");
                          
                          self.lastTestSuccessful = YES;
                      }
                      self.callbackCompleted = YES;
                      
                  }];
                 
                 documentService = nil;
             }
         }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testUpdateContentWithVersioningForDocument
{
    if (self.setUpSuccess)
    {
        if (!self.isCloud)
        {
            STAssertTrue(YES, @"");
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
                              STAssertNotNil(array, @"array should not be nil");
                              STAssertTrue(array.count == 1, @"expected 1 version");
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
                                                      STAssertTrue(versions.count == 2, @"the versions count should have been incremented to 2. Instead we got %d", versions.count);
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
                                                              STAssertTrue(hasHigherVersion, @"The version label of the latest doc should be higher than the previous one");
                                                          }
                                                      }
                                                      STAssertTrue(foundPreviousVersion, @"The array of document versions should still contain the previous version, but doesn't");
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
                                                                  STAssertNil(fileError, @"expected no error with getting file attributes for content file at path %@",[content.fileUrl path]);
                                                                  unsigned long long size = [[fileDict valueForKey:NSFileSize] unsignedLongLongValue];
                                                                  STAssertTrue(size > 0, @"checkContentFile length should be greater than 0. We got %llu",size);
                                                                  NSError *checkError = nil;
                                                                  NSString *checkContentString = [NSString stringWithContentsOfFile:[content.fileUrl path]
                                                                                                                           encoding:NSUTF8StringEncoding
                                                                                                                              error:&checkError];
                                                                  
                                                                  NSDate *earlierDate = [createdAt earlierDate:lastDocument.modifiedAt];
                                                                  STAssertTrue([earlierDate isEqualToDate:createdAt], @"The modified Date should come AFTER the original date");
                                                                  if (nil == checkContentString)
                                                                  {
                                                                      self.lastTestSuccessful = NO;
                                                                      self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [checkError localizedDescription], [checkError localizedFailureReason]];
                                                                  }
                                                                  else
                                                                  {
                                                                      STAssertTrue([checkContentString isEqualToString:updatedContent],@"We should get back the updated content, instead we get %@",updatedContent);
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
            STAssertTrue(self.lastTestSuccessful, self.lastTestFailureMessage);
            
        }
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
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
        int first = [[firstComponents objectAtIndex:i] intValue];
        int second = [[secondComponents objectAtIndex:i] intValue];
        if (first > second)
        {
            isHigherVersion = YES;
            break;
        }
    }
    
    return isHigherVersion;
}

@end
