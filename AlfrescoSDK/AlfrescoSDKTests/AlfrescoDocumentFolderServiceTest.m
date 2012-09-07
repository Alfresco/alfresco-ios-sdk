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

#import "AlfrescoDocumentFolderServiceTest.h"
#import "AlfrescoProperty.h"
#import "AlfrescoListingContext.h"
#import "AlfrescoPermissions.h"
#import "CMISConstants.h"

@implementation AlfrescoDocumentFolderServiceTest
/*
 */

@synthesize dfService = _dfService;
#pragma mark OnPremise tests
- (void)testCreateFolder
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:2];
        [props setObject:@"test description" forKey:@"cm:description"];
        [props setObject:@"test title" forKey:@"cm:title"];
        
        // create a new folder in the repository's root folder
        [self.dfService createFolderWithName:super.unitTestFolder inParentFolder:super.testDocFolder properties:props
                             completionBlock:^(AlfrescoFolder *folder, NSError *error) 
         {
             if (nil == folder) 
             {
                 super.lastTestSuccessful = NO;
                 super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 super.callbackCompleted = YES;
             }
             else 
             {
                 STAssertNotNil(folder, @"folder should not be nil");
                 STAssertTrue([folder.name isEqualToString:super.unitTestFolder], @"folder name should be %@",super.unitTestFolder);
                 
                 // check the properties were added at creation time
                 NSDictionary *newFolderProps = folder.properties;
                 AlfrescoProperty *newDescriptionProp = [newFolderProps objectForKey:@"cm:description"];
                 AlfrescoProperty *newTitleProp = [newFolderProps objectForKey:@"cm:title"];
                 STAssertTrue([newDescriptionProp.value isEqualToString:@"test description"], @"cm:description property value does not match");
                 STAssertTrue([newTitleProp.value isEqualToString:@"test title"], @"cm:title property value does not match");
                 
                 [self.dfService deleteNode:folder completionBlock:^(BOOL success, NSError *error)
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
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testRetrieveRootFolder
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        [self.dfService retrieveRootFolderWithCompletionBlock:^(AlfrescoFolder *rootFolder, NSError *error)
         {
             if (nil == rootFolder) 
             {
                 super.lastTestSuccessful = NO;
                 super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else 
             {
                 STAssertNotNil(rootFolder,@"root folder should not be nil");
                 super.lastTestSuccessful = YES;
             }
             super.callbackCompleted = YES;
             
         }];
        
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];    
}

- (void)testRetrieveChildrenInFolder
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        
        // get the children of the repository's root folder
        [self.dfService retrieveChildrenInFolder:super.testDocFolder completionBlock:^(NSArray *array, NSError *error)
         {
             if (nil == array) 
             {
                 super.lastTestSuccessful = NO;
                 super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else 
             {
                 STAssertTrue(array.count > 0, [NSString stringWithFormat:@"Expected folder children but got %i", array.count]);
                 if (super.isCloud)
                 {
                     STAssertTrue([self nodeArray:array containsName:@"Sample Filesrr"], @"Folder children should contain Sample Filesrr");
                 }
                 else
                 {
                     STAssertTrue([self nodeArray:array containsName:@"Sites"], @"Folder children should contain Sites");
                 }
                 
                 super.lastTestSuccessful = YES;
             }
             super.callbackCompleted = YES;
             
         }];
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testRetrieveChildrenInFolderWithPaging
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] init];
        paging.maxItems = 1;
        paging.skipCount = 0;
        
        // get the children of the repository's root folder
        [self.dfService retrieveChildrenInFolder:super.testDocFolder listingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error)
         {
             if (nil == pagingResult) 
             {
                 super.lastTestSuccessful = NO;
                 super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else 
             {
                 STAssertTrue(pagingResult.totalItems > 0, @"Expected folder children");
                 STAssertTrue(pagingResult.objects.count > 0, @"Expected at least 1 folder children returned");
                 STAssertTrue(pagingResult.hasMoreItems, @"Expected that there are more items left");
                 NSLog(@"total items %i", pagingResult.objects.count);
                 
                 super.lastTestSuccessful = YES;
             }
             super.callbackCompleted = YES;
         }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testRetrieveNodeWithFolderPathRelative
{
    [super runAllSitesTest:^{
        
        __block AlfrescoFolder *rootFolder = nil;
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        rootFolder = super.currentSession.rootFolder;
        
        // get the Sites child of the repository's root folder
        [self.dfService retrieveNodeWithFolderPath:@"Sites" relativeToFolder:rootFolder completionBlock:^(AlfrescoNode *node, NSError *error) 
         {
             if (nil == node) 
             {
                 super.lastTestSuccessful = NO;
                 super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else 
             {
                 STAssertNotNil(node, @"node should not be nil");
                 STAssertTrue([node.name isEqualToString:@"Sites"], [NSString stringWithFormat:@"node name should be Sites and not %@", node.name]);
                 
                 super.lastTestSuccessful = YES;
             }
             super.callbackCompleted = YES;
             
         }];
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testRetrieveNodeWithNonExistingFolderPathRelative
{
    [super runAllSitesTest:^{
        
        __block AlfrescoFolder *rootFolder = nil;
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        rootFolder = super.currentSession.rootFolder;
        
        // get the Sites child of the repository's root folder
        NSString *name = @"Sites2";
        [self.dfService retrieveNodeWithFolderPath:name relativeToFolder:rootFolder completionBlock:^(AlfrescoNode *node, NSError *error) 
         {
             if (nil == node) 
             {
                 STAssertNotNil(error, @"error should not be nil");                
                 super.lastTestSuccessful = YES;
             }
             else 
             {
                 STAssertNil(node, @"Expected empty node");
                 super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 super.lastTestSuccessful = NO;
             }
             super.callbackCompleted = YES;
             
         }];
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testRetrieveDocumentsInFolder
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        
        // get the documents of the repository's root folder
        [self.dfService retrieveDocumentsInFolder:super.testDocFolder completionBlock:^(NSArray *array, NSError *error)
         {
             if (nil == array) 
             {
                 super.lastTestSuccessful = NO;
                 super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else 
             {
                 STAssertTrue(array.count > 0, @"Expected more than 0 documents");
                 if (array.count > 0)
                 {
                     for (AlfrescoDocument *document in array) {
                         if([document.name isEqualToString:@"versioned-quote.txt"])
                         {
                             STAssertNotNil(document.type, @"type should be filled");
                             STAssertNotNil(document.contentMimeType, @"contentMimeType should be filled");
                             STAssertNotNil(document.versionLabel, @"versionLabel should be filled");
                             STAssertTrue(document.contentLength > 0, @"contentLength should be filled");
                             STAssertTrue(document.isLatestVersion, @"isLatestVersion should be filled");
                             STAssertTrue([document.contentMimeType isEqualToString:@"text/plain"], @"Expected text mimetype");
                             log(@"document title is %@ and the description is %@",document.title, document.summary);
                             STAssertNotNil(document.title, @"At least the document title should NOT be nil");
                            
                         }
                     }
                     super.lastTestSuccessful = YES;
                 }
                 else
                 {
                     super.lastTestSuccessful = NO;
                     super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 }
                 
             }
             super.callbackCompleted = YES;
             
         }];
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testRetrieveDocumentsInFolderWithPaging
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] init];
        paging.maxItems = 2;
        paging.skipCount = 1;
        
        // get the documents of the repository's root folder
        [self.dfService retrieveDocumentsInFolder:super.testDocFolder listingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error)
         {
             if (nil == pagingResult) 
             {
                 super.lastTestSuccessful = NO;
                 super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else 
             {
                 STAssertTrue(pagingResult.objects.count == 2, @"Expected 2 documents");
                 STAssertTrue(pagingResult.totalItems > 2, @"Expected more than 2 documents in total");
                 
                 super.lastTestSuccessful = YES;
             }
             super.callbackCompleted = YES;
             
         }];
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testRetrieveFoldersInFolder
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        
        // get the documents of the repository's root folder
        [self.dfService retrieveFoldersInFolder:super.testDocFolder completionBlock:^(NSArray *array, NSError *error)
         {
             if (nil == array) 
             {
                 super.lastTestSuccessful = NO;
                 super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else 
             {
                 STAssertTrue(array.count > 0, @"Expected more than 0 folders");
                 if (array.count > 0)
                 {
                     for (AlfrescoFolder *folder in array) {
                         if([folder.name isEqualToString:@"Guest Home"])
                         {
                             STAssertNotNil(folder.createdBy, @"createdBy should be filled");
                             STAssertNotNil(folder.type, @"type should be filled");
                             STAssertNotNil(folder.title, @"title should be filled");
                             STAssertTrue(folder.isFolder, @"isFolder should be filled");
                             STAssertFalse(folder.isDocument, @"isDocument should be filled");
                             STAssertNotNil(folder.createdBy, @"createdBy should be filled");
                             STAssertNotNil(folder.createdAt, @"creationDate should be filled");
                             STAssertNotNil(folder.modifiedBy, @"modifiedBy should be filled");
                             STAssertNotNil(folder.modifiedAt, @"modificationDate should be filled");
                             STAssertTrue([folder.title isEqualToString:@"Guest Home"], @"Expected Guest Home as title");
                         }
                     }
                     super.lastTestSuccessful = YES;
                 }
                 else
                 {
                     super.lastTestSuccessful = NO;
                     super.lastTestFailureMessage = @"Empty array.";
                 }
                 
             }
             super.callbackCompleted = YES;
             
         }];
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testRetrieveFoldersInFolderWithPaging
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] init];
        paging.maxItems = 1;
        paging.skipCount = 0;
        
        // get the documents of the repository's root folder
        [self.dfService retrieveFoldersInFolder:super.testDocFolder listingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error)
         {
             if (nil == pagingResult) 
             {
                 super.lastTestSuccessful = NO;
                 super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else 
             {
                 STAssertTrue(pagingResult.objects.count >= 1, @"Expected at least 1 folders");
                 if (self.isCloud)
                 {
                     STAssertTrue(pagingResult.totalItems == 1, @"Expected 1 folder in total, but we have %d",pagingResult.totalItems);
                     STAssertFalse(pagingResult.hasMoreItems, @"Expected no more folders available, but instead it says there are more items");
                 }
                 else
                 {
                     STAssertTrue(pagingResult.totalItems > 1, @"Expected more than 1 folders in total, but we have %d",pagingResult.totalItems);
                     STAssertTrue(pagingResult.hasMoreItems, @"Expected more folders available, but instead it says there are no more items");
                     
                 }
                 
                 super.lastTestSuccessful = YES;
             }
             super.callbackCompleted = YES;
             
         }];
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testRetrieveNodeWithIdentifier
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        
        
        [self.dfService retrieveNodeWithIdentifier:super.testDocFolder.identifier completionBlock:^(AlfrescoNode *node, NSError *error)
         {
             if (nil == node) 
             {
                 super.lastTestSuccessful = NO;
                 super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else 
             {
                 STAssertNotNil(node, @"node should not be nil");
                 STAssertNotNil(node.identifier, @"nodeRef should not be nil");
                 STAssertTrue([node.identifier isEqualToString:super.testDocFolder.identifier], @"nodeRef should be the same as root folder");
                 
                 super.lastTestSuccessful = YES;
             }
             super.callbackCompleted = YES;
         }];
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testRetrieveNodeWithFolderPath
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        NSString *folderPath = [NSString stringWithFormat:@"%@%@",super.testFolderPathName, super.fixedFileName];
        log(@"testRetrieveNodeWithFolderPath folderPath variable  is %@",folderPath);
        [self.dfService retrieveNodeWithFolderPath:folderPath completionBlock:^(AlfrescoNode *node, NSError *error)
        {
            if (nil == node) 
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else 
            {
                STAssertNotNil(node, @"node should not be nil");
                STAssertNotNil(node.identifier, @"nodeRef should not be nil");
                STAssertTrue([node.name isEqualToString:super.fixedFileName], @"name should be equal to %@",super.fixedFileName);
                
                super.lastTestSuccessful = YES;
            }
            super.callbackCompleted = YES;
        }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testRetrieveParentNode
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        
        [self.dfService retrieveParentFolderOfNode:super.testAlfrescoDocument completionBlock:^(AlfrescoFolder *folder, NSError *error){
            if (nil == folder)
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                STAssertNotNil(folder, @"node should not be nil");
                STAssertNotNil(folder.identifier, @"nodeRef should not be nil");
                STAssertTrue([folder.identifier isEqualToString:super.testDocFolder.identifier], @"nodeRef should be the same as root folder");
                
                super.lastTestSuccessful = YES;
            }
            super.callbackCompleted = YES;
        }];

        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}


- (void)testDownloadDocument
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        
        // get the documents of the repository's root folder
        __weak AlfrescoDocumentFolderService *weakDfService = self.dfService;
        [self.dfService retrieveDocumentsInFolder:super.testDocFolder completionBlock:^(NSArray *array, NSError *error)
         {
             if (nil == array) 
             {
                 super.lastTestSuccessful = NO;
                 super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 super.callbackCompleted = YES;
             }
             else 
             {
                 STAssertTrue(array.count > 0, @"Expected more than 0 documents");
                 if (array.count > 0)
                 {
                     [weakDfService retrieveContentOfDocument:[array objectAtIndex:0] completionBlock:^(AlfrescoContentFile *contentFile, NSError *error)
                      {
                          if (nil == contentFile)
                          {
                              super.lastTestSuccessful = NO;
                              super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                          }
                          else
                          {
                              super.lastTestSuccessful = YES;
                              // Assert File exists and check file length
                              NSString *filePath = [contentFile.fileUrl path];
                              STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:filePath], @"File does not exist");
                              NSError *error;
                              NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
                              STAssertNil(error, @"Could not verify attributes of file %@: %@", filePath, [error description]);
                              STAssertTrue([fileAttributes fileSize] > 100, @"Expected a file large than 100 bytes, but found one of %d kb", [fileAttributes fileSize]/1024.0);
                              
                              // Nice boys clean up after themselves
                              [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                              STAssertNil(error, @"Could not remove file %@: %@", filePath, [error description]);
                          }
                          
                          super.callbackCompleted = YES;
                          
                      } progressBlock:^(NSInteger bytesDownloaded, NSInteger bytesTotal) {
                          NSLog(@"progress %i/%i", bytesDownloaded, bytesTotal);
                      }];
                 }
                 else
                 {
                     super.lastTestSuccessful = NO;
                     super.lastTestFailureMessage = @"Failed to download document.";
                     super.callbackCompleted = YES;
                 }
                 
             }
             
         }];
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}


- (void)testUploadImage
{
    [super runAllSitesTest:^{
        
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:4];
        // provide the objectTypeId so we can specify the cm:author aspect
        [props setObject:[kCMISPropertyObjectTypeIdValueDocument stringByAppendingString:@",P:cm:titled,P:cm:author"]
                  forKey:kCMISPropertyObjectTypeId];
        [props setObject:@"test description" forKey:@"cm:description"];
        [props setObject:@"test title" forKey:@"cm:title"];
        [props setObject:@"test author" forKey:@"cm:author"];
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        [self.dfService createDocumentWithName:@"millenium-dome.jpg" inParentFolder:super.testDocFolder
                                   contentFile:super.testImageFile
                                    properties:props
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
                                       
                                       // check the properties were added at creation time
                                       NSDictionary *newDocProps = document.properties;
                                       AlfrescoProperty *newDescriptionProp = [newDocProps objectForKey:@"cm:description"];
                                       AlfrescoProperty *newTitleProp = [newDocProps objectForKey:@"cm:title"];
                                       AlfrescoProperty *newAuthorProp = [newDocProps objectForKey:@"cm:author"];
                                       STAssertTrue([newDescriptionProp.value isEqualToString:@"test description"], @"cm:description property value does not match");
                                       STAssertTrue([newTitleProp.value isEqualToString:@"test title"], @"cm:title property value does not match");
                                       STAssertTrue([newAuthorProp.value isEqualToString:@"test author"], @"cm:author property value does not match");
                                       
                                       // delete the test document
                                       [self.dfService deleteNode:document completionBlock:^(BOOL success, NSError *error)
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
                               } progressBlock:^(NSInteger bytesUploaded, NSInteger bytesTotal){
                               }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
    
}
/*

*/
- (void)testUpdateContentForDocument
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        __weak AlfrescoDocumentFolderService *weakDfService = self.dfService;
        [self.dfService retrieveContentOfDocument:super.testAlfrescoDocument completionBlock:^(AlfrescoContentFile *contentFile, NSError *error){
            if (nil == contentFile)
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                super.callbackCompleted = YES;
            }
            else
            {
                STAssertNotNil(contentFile,@"created content file should not be nil");
                log(@"created content file: url=%@ mimetype = %@ data length = %u",[contentFile.fileUrl path], contentFile.mimeType, contentFile.length);
                NSError *readError = nil;
                __block NSString *stringContent = [NSString stringWithContentsOfFile:[contentFile.fileUrl path] encoding:NSASCIIStringEncoding error:&readError];
                if (nil == stringContent)
                {
                    log(@"stringContent::we got nil as content from %@",[contentFile.fileUrl path]);
                    super.lastTestSuccessful = NO;
                    super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [readError localizedDescription], [readError localizedFailureReason]];
                    super.callbackCompleted = YES;
                }
                else
                {
                    __block NSString *updatedContent = [NSString stringWithFormat:@"%@ - and we added some text.",stringContent];
                    NSData *data = [updatedContent dataUsingEncoding:NSASCIIStringEncoding];
                    __block AlfrescoContentFile *updatedContentFile = [[AlfrescoContentFile alloc] initWithData:data mimeType:contentFile.mimeType];
                    [weakDfService updateContentOfDocument:super.testAlfrescoDocument contentFile:updatedContentFile
                                           completionBlock:^(AlfrescoDocument *updatedDocument, NSError *error)
                     {
                         
                         if (nil == updatedDocument)
                         {
                             super.lastTestSuccessful = NO;
                             super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                             super.callbackCompleted = YES;
                         }
                         else
                         {
                             STAssertNotNil(updatedDocument.identifier, @"document identifier should be filled");
                             STAssertTrue(updatedDocument.contentLength > 100, @"expected content to be filled");
                             
                             [weakDfService retrieveContentOfDocument:updatedDocument completionBlock:^(AlfrescoContentFile *checkContentFile, NSError *error){
                                 if (nil == checkContentFile)
                                 {
                                     super.lastTestSuccessful = NO;
                                     super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                 }
                                 else
                                 {
                                     STAssertTrue(checkContentFile.length > 0, @"checkContentFile length should be greater than 0. We got %d",checkContentFile.length);
                                     NSError *checkError = nil;
                                     NSString *checkContentString = [NSString stringWithContentsOfFile:[checkContentFile.fileUrl path]
                                                                                              encoding:NSASCIIStringEncoding
                                                                                                 error:&checkError];
                                     if (nil == checkContentString)
                                     {
                                         log(@"checkContentString::we got nil as content from %@",[contentFile.fileUrl path]);
                                         super.lastTestSuccessful = NO;
                                         super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [checkError localizedDescription], [checkError localizedFailureReason]];
                                     }
                                     else
                                     {
                                         log(@"we got the following text back %@",checkContentString);
                                         STAssertTrue([checkContentString isEqualToString:updatedContent],@"We should get back the updated content, instead we get %@",updatedContent);
                                         super.lastTestSuccessful = YES;                                         
                                     }
                                     
                                 }
                                 super.callbackCompleted = YES;
                             } progressBlock:^(NSInteger bytesTransferred, NSInteger bytesTotal){}];
                         }
                     } progressBlock:^(NSInteger bytesDownloaded, NSInteger bytesTotal) {
                         NSLog(@"progress %i/%i", bytesDownloaded, bytesTotal);
                     }];
                }
            }
            
        } progressBlock:^(NSInteger bytesDownloaded, NSInteger bytesTotal) {
            NSLog(@"progress %i/%i", bytesDownloaded, bytesTotal);
        }];
        
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
    
}

- (void)testUpdatePropertiesForDocument
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        
                
        __weak AlfrescoDocumentFolderService *weakDfService = self.dfService;
        
        [self.dfService retrieveContentOfDocument:super.testAlfrescoDocument completionBlock:^(AlfrescoContentFile *contentFile, NSError *error)
         {
             
             if (nil == contentFile) 
             {
                 super.lastTestSuccessful = NO;
                 super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 super.callbackCompleted = YES;
             }
             else 
             {
                 __block NSString *propertyObjectTestValue = @"version-download-test-updated.txt";
                 NSMutableDictionary *propDict = [NSMutableDictionary dictionaryWithCapacity:8];
//                 [propDict setObject:[kCMISPropertyObjectTypeIdValueDocument stringByAppendingString:@",P:cm:titled,P:cm:author"]
//                              forKey:kCMISPropertyObjectTypeId];
                 [propDict setObject:propertyObjectTestValue forKey:kCMISPropertyName];
                 [propDict setObject:@"updated description" forKey:@"cm:description"];
                 [propDict setObject:@"updated title" forKey:@"cm:title"];
//                 [propDict setObject:@"updated author" forKey:@"cm:author"];
                 
                 [weakDfService updatePropertiesOfNode:super.testAlfrescoDocument properties:propDict completionBlock:^(AlfrescoNode *updatedNode, NSError *error)
                  {
                      
                      if (nil == updatedNode)
                      {
                          super.lastTestSuccessful = NO;
                          super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                      }
                      else
                      {
                          AlfrescoDocument *updatedDocument = (AlfrescoDocument *)updatedNode;
                          STAssertNotNil(updatedDocument.identifier, @"document identifier should be filled");
                          STAssertTrue([updatedDocument.name isEqualToString:@"version-download-test-updated.txt"], @"name should be updated");
                          STAssertTrue(updatedDocument.contentLength > 100, @"expected content to be filled");
                          
                          // check the updated properties
                          NSDictionary *updatedProps = updatedDocument.properties;
                          AlfrescoProperty *updatedDescription = [updatedProps objectForKey:@"cm:description"];
                          AlfrescoProperty *updatedTitle = [updatedProps objectForKey:@"cm:title"];
                          AlfrescoProperty *updatedAuthor = [updatedProps objectForKey:@"cm:author"];
                          STAssertTrue([updatedDescription.value isEqualToString:@"updated description"], @"Updated description is incorrect");
                          STAssertTrue([updatedTitle.value isEqualToString:@"updated title"], @"Updated title is incorrect");
//                          STAssertTrue([updatedAuthor.value isEqualToString:@"updated author"], @"Updated author is incorrect");
                          
                          id propertyValue = [updatedDocument propertyValueWithName:kCMISPropertyName];
                          if ([propertyValue isKindOfClass:[NSString class]])
                          {
                              NSString *testValue = (NSString *)propertyValue;
                              STAssertTrue([testValue isEqualToString:propertyObjectTestValue], @"we expected that the value would be %@, but we got back %@");
                              super.lastTestSuccessful = YES;
                          }
                          else
                          {
                              super.lastTestSuccessful = NO;
                              super.lastTestFailureMessage = [NSString stringWithFormat:@"we expected a String object back from %@",kCMISPropertyName];
                          }
                      }
                      super.callbackCompleted = YES;
                      
                  }];
             }
             
         } progressBlock:^(NSInteger bytesDownloaded, NSInteger bytesTotal) {
         }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testDeleteNode
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        
        // create a new folder in the repository's root folder so we can delete it
        
        [self.dfService createFolderWithName:@"RemoteAPIDeleteTest" inParentFolder:super.testDocFolder properties:nil
                             completionBlock:^(AlfrescoFolder *folder, NSError *error) 
         {
             
             if (nil == folder) 
             {
                 super.lastTestSuccessful = NO;
                 super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 super.callbackCompleted = YES;
             }
             else 
             {
                 STAssertNotNil(folder, @"folder should not be nil");
                 STAssertTrue([folder.name isEqualToString:@"RemoteAPIDeleteTest"], @"folder name should be RemoteAPIDeleteTest");
                 
                 [self.dfService deleteNode:folder completionBlock:^(BOOL success, NSError *error) 
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
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

/*

- (void)testThumbnailRenditionImage
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        
        AlfrescoDocument *document = [[AlfrescoDocument alloc] init];
        document.identifier = testNodeRef;
        document.name = @"thumbnail.jpg";
        
        // get thumbnail
        [self.dfService retrieveRenditionOfNode:document renditionName:kAlfrescoThumbnailRendition completionBlock:^(AlfrescoContentFile *contentFile, NSError *error){
             if (nil == contentFile) 
             {
                 super.lastTestSuccessful = NO;
                 super.lastTestFailureMessage = @"Failed to retrieve thumbnail image.";
             }
             else 
             {
                 NSData *data = [[NSFileManager defaultManager] contentsAtPath:[contentFile.fileUrl path]];
                 STAssertNotNil(data, @"data should not be nil");
                 STAssertTrue(contentFile.length > 100, @"data should be filled");
                 super.lastTestSuccessful = YES;
             }
             super.callbackCompleted = YES;
             
         }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}
 */

- (void)testRetrievePermissionsOfNode
{
    [super runAllSitesTest:^{
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        [self.dfService retrieveRootFolderWithCompletionBlock:^(AlfrescoFolder *rootFolder, NSError *error)
         {
             if (nil == rootFolder) 
             {
                 super.lastTestSuccessful = NO;
                 super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 super.callbackCompleted = YES;
             }
             else 
             {
                 STAssertNotNil(rootFolder,@"root folder should not be nil");
                 super.lastTestSuccessful = YES;
                 [self.dfService retrievePermissionsOfNode:rootFolder completionBlock:^(AlfrescoPermissions *permissions, NSError *error)
                  {
                      if (nil == permissions) 
                      {
                          super.lastTestSuccessful = NO;
                          super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                      }
                      else 
                      {
                          STAssertNotNil(permissions,@"AlfrescoPermissions should not be nil");
                          if(permissions.canAddChildren)
                          {
                              log(@"Can add children");
                          }
                          else
                          {
                              log(@"Cannot add children");
                          }
                          if(permissions.canDelete)
                          {
                              log(@"Can delete");
                          }
                          else
                          {
                              log(@"Cannot delete");
                          }
                          if(permissions.canEdit)
                          {
                              log(@"Can edit");
                          }
                          else
                          {
                              log(@"Cannot edit");
                          }
                          
                          super.lastTestSuccessful = YES;                          
                      }
                      super.callbackCompleted = YES;
                  }];
             }
             
         }];
        
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}


#pragma mark unit test internal methods

- (BOOL)nodeArray:(NSArray *)nodeArray containsName:(NSString *)name
{
    for (AlfrescoNode *node in nodeArray) {
        if([node.name isEqualToString:name] == YES)
        {
            return YES;
        }
    }
    return NO;
}

@end
