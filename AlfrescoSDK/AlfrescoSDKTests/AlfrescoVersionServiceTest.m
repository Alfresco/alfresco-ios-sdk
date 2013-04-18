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
    [self runAllSitesTest:^
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
     ];
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
    [self runAllSitesTest:^
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
         else
         {
             // not checking version comment in cloud for now
             [self waitForCompletion];
         }
     }
     ];
}

/*
 @Unique_TCRef 58S1
 @Unique_TCRef 17S6
 */
- (void)testRetrieveAllVersionsWithPaging
{
    [self runAllSitesTest:^{
        
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
    }];
}


@end
