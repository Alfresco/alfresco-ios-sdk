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

#import "AlfrescoDocumentFolderServiceTest.h"
#import "AlfrescoProperty.h"
#import "AlfrescoListingContext.h"
#import "AlfrescoPermissions.h"
#import "AlfrescoLog.h"
#import "AlfrescoErrors.h"
#import "CMISConstants.h"
#import "AlfrescoContentStream.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoRepositorySession.h"
#import "AlfrescoTaggingService.h"

@implementation AlfrescoDocumentFolderServiceTest
/*
 */

/**
 @Unique_TCRef 32S0 - 32S2
 @Unique_TCRef 24S0
 */
- (void)testCreateFolder
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:2];
        //        [documentProperties setObject:@"cmis:document, P:cm:titled" forKey:kCMISPropertyObjectTypeId];
        props[@"cm:description"] = @"test description";
        props[@"cm:title"] = @"test title";
        
        // create a new folder in the repository's root folder
        NSString *folderName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.unitTestFolder];
        [self.dfService createFolderWithName:folderName inParentFolder:self.testDocFolder properties:props
                             completionBlock:^(AlfrescoFolder *folder, NSError *error)
         {
             if (nil == folder)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 self.callbackCompleted = YES;
             }
             else
             {
                 XCTAssertNotNil(folder, @"folder should not be nil");
                 XCTAssertTrue([folder.name isEqualToString:folderName], @"folder name should be %@",folderName);
                 
                 // check the properties were added at creation time
                 NSDictionary *newFolderProps = folder.properties;
                 AlfrescoProperty *newDescriptionProp = newFolderProps[@"cm:description"];
                 AlfrescoProperty *newTitleProp = newFolderProps[@"cm:title"];
                 XCTAssertTrue([newDescriptionProp.value isEqualToString:@"test description"], @"cm:description property value does not match");
                 XCTAssertTrue([newTitleProp.value isEqualToString:@"test title"], @"cm:title property value does not match");
                 
                 [self.dfService deleteNode:folder completionBlock:^(BOOL success, NSError *error)
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
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testCreateFolderWithObjectTypeId
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        NSString *testDescription = @"test description";
        NSString *testTitle = @"test title";
        
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:3];
        props[kCMISPropertyObjectTypeId] = @"cm:folder, P:cm:titled";
        props[@"cm:description"] = testDescription;
        props[@"cm:title"] = testTitle;
        
        // create a new folder in the repository's root folder
        NSString *folderName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.unitTestFolder];
        [self.dfService createFolderWithName:folderName inParentFolder:self.testDocFolder properties:props completionBlock:^(AlfrescoFolder *folder, NSError *error) {
            if (nil == folder)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"#1 %@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(folder, @"Folder should not be nil");
                XCTAssertTrue([folder.name isEqualToString:folderName], @"Folder name: %@ does not match %@", folder.name, folderName);
                XCTAssertTrue([folder.type isEqualToString:kAlfrescoTypeFolder], @"Folder type: %@ does not match %@", folder.type, kAlfrescoTypeFolder);
                
                // check the properties were added at creation time
                NSDictionary *newFolderProps = folder.properties;
                AlfrescoProperty *newDescriptionProp = newFolderProps[@"cm:description"];
                AlfrescoProperty *newTitleProp = newFolderProps[@"cm:title"];
                XCTAssertTrue([newDescriptionProp.value isEqualToString:testDescription], @"cm:description: %@ does not match %@", newDescriptionProp.value, testDescription);
                XCTAssertTrue([newTitleProp.value isEqualToString:testTitle], @"cm:title: %@ does not match %@", newTitleProp.value, testTitle);
                
                [self.dfService deleteNode:folder completionBlock:^(BOOL success, NSError *error) {
                    if (!success)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"#2 %@ - %@", [error localizedDescription], [error localizedFailureReason]];
                    }
                    else
                    {
                        self.lastTestSuccessful = YES;
                    }
                    self.callbackCompleted = YES;
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


- (void)testCreateFolderDuplicate
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        NSString *testDescription = @"test description";
        NSString *testTitle = @"test title";
        
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:2];
        props[@"cm:description"] = testDescription;
        props[@"cm:title"] = testTitle;
        
        // create a new folder in the repository's root folder
        NSString *folderName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.unitTestFolder];
        [self.dfService createFolderWithName:folderName inParentFolder:self.testDocFolder properties:props completionBlock:^(AlfrescoFolder *folder, NSError *error) {
            if (nil == folder)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"#1 %@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(folder, @"Folder should not be nil");
                XCTAssertTrue([folder.name isEqualToString:folderName], @"Folder name: %@ does not match %@", folder.name, folderName);
                
                // check the properties were added at creation time
                NSDictionary *newFolderProps = folder.properties;
                AlfrescoProperty *newDescriptionProp = newFolderProps[@"cm:description"];
                AlfrescoProperty *newTitleProp = newFolderProps[@"cm:title"];
                XCTAssertTrue([newDescriptionProp.value isEqualToString:testDescription], @"cm:description: %@ does not match %@", newDescriptionProp.value, testDescription);
                XCTAssertTrue([newTitleProp.value isEqualToString:testTitle], @"cm:title: %@ does not match %@", newTitleProp.value, testTitle);
                
                [self.dfService createFolderWithName:folderName inParentFolder:self.testDocFolder properties:props completionBlock:^(AlfrescoFolder *duplicatedFolder, NSError *dupError) {
                    if (nil == duplicatedFolder)
                    {
                        self.lastTestSuccessful = YES;
                        XCTAssertNotNil(dupError, @"Expected a valid error object");
                        if (nil != dupError)
                        {
                            AlfrescoLogDebug(@"Returned error message is %@ with error code %d", [dupError localizedDescription], [dupError code]);
                        }
                    }
                    else
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = @"We should NOT be able to create a duplicate folder";
                    }
                    
                    [self.dfService deleteNode:folder completionBlock:^(BOOL success, NSError *deleteError) {
                        if (!success)
                        {
                            self.lastTestSuccessful = NO;
                            self.lastTestFailureMessage = [NSString stringWithFormat:@"#2 %@ - %@", [deleteError localizedDescription], [deleteError localizedFailureReason]];
                        }
                        else
                        {
                            self.lastTestSuccessful = YES;
                        }
                        self.callbackCompleted = YES;
                    }];
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



/**
 @Unique_TCRef 32S0
 @Unique_TCRef 32F0
 @Unique_TCRef 24S0
 */
- (void)testCreateFolderInNonExistingFolder
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
        
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:2];
        props[@"cm:description"] = @"test description";
        props[@"cm:title"] = @"test title";
        
        // create a new folder in the repository's root folder
        NSString *folderName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.unitTestFolder];
        [self.dfService createFolderWithName:folderName inParentFolder:self.testDocFolder properties:props
                             completionBlock:^(AlfrescoFolder *folder, NSError *error)
         {
             if (nil == folder)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 self.callbackCompleted = YES;
             }
             else
             {
                 XCTAssertNotNil(folder, @"folder should not be nil");
                 XCTAssertTrue([folder.name isEqualToString:folderName], @"folder name should be %@",folderName);
                 __block AlfrescoFolder *strongFolder = folder;
                 
                 [weakService deleteNode:folder completionBlock:^(BOOL success, NSError *error)
                  {
                      if (!success)
                      {
                          self.lastTestSuccessful = NO;
                          self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                          self.callbackCompleted = YES;
                      }
                      else
                      {
                          NSString *subfolder = [AlfrescoBaseTest addTimeStampToFileOrFolderName:@"SomeTestFolder"];
                          [weakService createFolderWithName:subfolder inParentFolder:strongFolder properties:props completionBlock:^(AlfrescoFolder *nonFolder, NSError *error){
                              if (nil == nonFolder)
                              {
                                  self.lastTestSuccessful = YES;
                              }
                              else
                              {
                                  self.lastTestSuccessful = NO;
                                  self.lastTestFailureMessage = @"We should not be able to create a folder in a nonexisting folder";
                              }
                              self.callbackCompleted = YES;
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



/**
 @Unique_TCRef 32S0
 @Unique_TCRef 13F1
 @Unique_TCRef 24S0
 */
- (void)testRetrieveChildrenInFolderNonExisting
{
    if (self.setUpSuccess)
    {
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:2];
        props[@"cm:description"] = @"test description";
        props[@"cm:title"] = @"test title";
        
        // create a new folder in the repository's root folder
        NSString *folderName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.unitTestFolder];
        [self.dfService createFolderWithName:folderName inParentFolder:self.testDocFolder properties:props completionBlock:^(AlfrescoFolder *unitTestFolder, NSError *error) {
            if (nil == unitTestFolder)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"#1 %@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(unitTestFolder, @"folder should not be nil");
                XCTAssertTrue([unitTestFolder.name isEqualToString:folderName], @"folder name should be %@",folderName);
                __block AlfrescoFolder *strongFolder = unitTestFolder;
                // check the properties were added at creation time
                NSDictionary *newFolderProps = unitTestFolder.properties;
                AlfrescoProperty *newDescriptionProp = newFolderProps[@"cm:description"];
                AlfrescoProperty *newTitleProp = newFolderProps[@"cm:title"];
                XCTAssertTrue([newDescriptionProp.value isEqualToString:@"test description"], @"cm:description property value does not match");
                XCTAssertTrue([newTitleProp.value isEqualToString:@"test title"], @"cm:title property value does not match");
                
                [self.dfService deleteNode:unitTestFolder completionBlock:^(BOOL success, NSError *deleteError) {
                    if (!success)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"#2 %@ - %@", [deleteError localizedDescription], [deleteError localizedFailureReason]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        [weakService retrieveChildrenInFolder:strongFolder completionBlock:^(NSArray *array, NSError *accessError) {
                            if (nil == array)
                            {
                                self.lastTestSuccessful = YES;
                            }
                            else
                            {
                                self.lastTestSuccessful = NO;
                                self.lastTestFailureMessage = @"Expected the folder not to be accessible after it was deleted.";
                            }
                            self.callbackCompleted = YES;
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

/**
 @Unique_TCRef 32S0
 @Unique_TCRef 19F1
 @Unique_TCRef 24S0
 */
- (void)testRetrieveDocumentsInFolderNonExisting
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:2];
        props[@"cm:description"] = @"test description";
        props[@"cm:title"] = @"test title";
        
        // create a new folder in the repository's root folder
        NSString *folderName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.unitTestFolder];
        [self.dfService createFolderWithName:folderName inParentFolder:self.testDocFolder properties:props completionBlock:^(AlfrescoFolder *folder, NSError *error) {
            if (nil == folder)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(folder, @"folder should not be nil");
                XCTAssertTrue([folder.name isEqualToString:folderName], @"folder name should be %@",folderName);
                __block AlfrescoFolder *strongFolder = folder;
                // check the properties were added at creation time
                NSDictionary *newFolderProps = folder.properties;
                AlfrescoProperty *newDescriptionProp = newFolderProps[@"cm:description"];
                AlfrescoProperty *newTitleProp = newFolderProps[@"cm:title"];
                XCTAssertTrue([newDescriptionProp.value isEqualToString:@"test description"], @"cm:description property value does not match");
                XCTAssertTrue([newTitleProp.value isEqualToString:@"test title"], @"cm:title property value does not match");
                
                /**
                 * FIXME: 07/Jun/2013 - Potential transaction completion race condition here..?
                 */
                
                [self.dfService deleteNode:folder completionBlock:^(BOOL success, NSError *error) {
                    if (!success)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        [weakService retrieveDocumentsInFolder:strongFolder completionBlock:^(NSArray *array, NSError *error) {
                            if (nil == array)
                            {
                                self.lastTestSuccessful = YES;
                            }
                            else
                            {
                                self.lastTestSuccessful = NO;
                                self.lastTestFailureMessage = @"We expected the folder not to be accessible after we deleted it";
                            }
                            self.callbackCompleted = YES;
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

/**
 @Unique_TCRef 32S0
 @Unique_TCRef 20F1
 @Unique_TCRef 24S0
 */
- (void)testRetrieveFoldersInFolderNonExisting
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:2];
        props[@"cm:description"] = @"test description";
        props[@"cm:title"] = @"test title";
        
        // create a new folder in the repository's root folder
        NSString *folderName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.unitTestFolder];
        [self.dfService createFolderWithName:folderName inParentFolder:self.testDocFolder properties:props
                             completionBlock:^(AlfrescoFolder *folder, NSError *error)
         {
             if (nil == folder)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 self.callbackCompleted = YES;
             }
             else
             {
                 XCTAssertNotNil(folder, @"folder should not be nil");
                 XCTAssertTrue([folder.name isEqualToString:folderName], @"folder name should be %@",folderName);
                 __block AlfrescoFolder *strongFolder = folder;
                 // check the properties were added at creation time
                 NSDictionary *newFolderProps = folder.properties;
                 AlfrescoProperty *newDescriptionProp = newFolderProps[@"cm:description"];
                 AlfrescoProperty *newTitleProp = newFolderProps[@"cm:title"];
                 XCTAssertTrue([newDescriptionProp.value isEqualToString:@"test description"], @"cm:description property value does not match");
                 XCTAssertTrue([newTitleProp.value isEqualToString:@"test title"], @"cm:title property value does not match");
                 
                 [self.dfService deleteNode:folder completionBlock:^(BOOL success, NSError *error)
                  {
                      if (!success)
                      {
                          self.lastTestSuccessful = NO;
                          self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                          self.callbackCompleted = YES;
                      }
                      else
                      {
                          [weakService retrieveFoldersInFolder:strongFolder completionBlock:^(NSArray *array, NSError *error){
                              if (nil == array)
                              {
                                  self.lastTestSuccessful = YES;
                              }
                              else
                              {
                                  self.lastTestSuccessful = NO;
                                  self.lastTestFailureMessage = @"We expected the folder not to be accessible after we deleted it";
                              }
                              self.callbackCompleted = YES;
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



/**
 @Unique_TCRef 24S0, 32S0 - 32S5
 */
- (void)testCreateFolderWithSpecialEUCharacters
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        __block NSString *description = @"Übersicht Ändern Östrogen und das mit ß";
        __block NSString *title = @"Änderungswünsche";
        __block NSString *name = @"ÜÄÖTestsOrdner";
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:2];
        props[@"cm:description"] = description;
        props[@"cm:title"] = title;
        
        // create a new folder in the repository's root folder
        [self.dfService createFolderWithName:name inParentFolder:self.testDocFolder properties:props
                             completionBlock:^(AlfrescoFolder *folder, NSError *error)
         {
             if (nil == folder)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 self.callbackCompleted = YES;
             }
             else
             {
                 XCTAssertNotNil(folder, @"folder should not be nil");
                 XCTAssertTrue([folder.name isEqualToString:name], @"folder name should be %@, but instead we got %@",name, folder.name);
                 
                 // check the properties were added at creation time
                 NSDictionary *newFolderProps = folder.properties;
                 AlfrescoProperty *newDescriptionProp = newFolderProps[@"cm:description"];
                 AlfrescoProperty *newTitleProp = newFolderProps[@"cm:title"];
                 XCTAssertTrue([newDescriptionProp.value isEqualToString:description], @"cm:description property value does not match expected value %@",description);
                 XCTAssertTrue([newTitleProp.value isEqualToString:title], @"cm:title property value does not match expected value %@",title);
                 
                 [self.dfService deleteNode:folder completionBlock:^(BOOL success, NSError *error)
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
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/**
 @Unique_TCRef 24S0, 32S0 - 32S5
 */
- (void)testCreateFolderWithSpecialJPCharacters
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        __block NSString *description = @"ありがとにほんご";
        __block NSString *title = @"わさび";
        __block NSString *name = @"ラヂオコmプタ";
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:2];
        props[@"cm:description"] = description;
        props[@"cm:title"] = title;
        
        // create a new folder in the repository's root folder
        [self.dfService createFolderWithName:name inParentFolder:self.testDocFolder properties:props completionBlock:^(AlfrescoFolder *folder, NSError *error) {
            if (nil == folder)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"#1 %@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(folder, @"folder should not be nil");
                XCTAssertTrue([folder.name isEqualToString:name], @"folder name should be %@, but instead we got %@",name, folder.name);
                
                // check the properties were added at creation time
                NSDictionary *newFolderProps = folder.properties;
                AlfrescoProperty *newDescriptionProp = newFolderProps[@"cm:description"];
                AlfrescoProperty *newTitleProp = newFolderProps[@"cm:title"];
                XCTAssertTrue([newDescriptionProp.value isEqualToString:description], @"cm:description property value does not match expected value %@. Instead we get %@",description, newDescriptionProp.value);
                XCTAssertTrue([newTitleProp.value isEqualToString:title], @"cm:title property value does not match expected value %@. Instead we get %@",title, newTitleProp.value);
                
                [self.dfService deleteNode:folder completionBlock:^(BOOL success, NSError *error) {
                    if (!success)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"#2 %@ - %@", [error localizedDescription], [error localizedFailureReason]];
                    }
                    else
                    {
                        self.lastTestSuccessful = YES;
                    }
                    
                    self.callbackCompleted = YES;
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

/**
 @Unique_TCRef 24S0, 32S0, 32F3
 */
- (void)testCreateFolderWithEmptyName
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        __block NSString *description = @"";
        __block NSString *title = @"";
        __block NSString *name = @"";
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:2];
        props[@"cm:description"] = description;
        props[@"cm:title"] = title;
        
        // create a new folder in the repository's root folder
        [self.dfService createFolderWithName:name inParentFolder:self.testDocFolder properties:props
                             completionBlock:^(AlfrescoFolder *folder, NSError *error)
         {
             if (nil == folder)
             {
                 self.lastTestSuccessful = YES;
                 self.callbackCompleted = YES;
             }
             else
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = @"We should not succeed creating a folder with an empty name";
                 XCTAssertTrue([folder.name isEqualToString:name], @"folder name should be %@, but instead we got %@",name, folder.name);
                 
                 
                 [self.dfService deleteNode:folder completionBlock:^(BOOL success, NSError *error)
                  {
                      if (!success)
                      {
                          self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                      }
                      else
                      {
                      }
                      
                      self.callbackCompleted = YES;
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

/**
 @Unique_TCRef 24S0, 32S0, 32F5 - 32F13
 */
- (void)testCreateFolderWithSpecialCharactersInName
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        __block NSString *description = @"";
        __block NSString *title = @"";
        __block NSString *name = @"NameWIth.and\and/and?and\"and*<and>and|and!";
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:2];
        props[@"cm:description"] = description;
        props[@"cm:title"] = title;
        
        // create a new folder in the repository's root folder
        [self.dfService createFolderWithName:name inParentFolder:self.testDocFolder properties:props
                             completionBlock:^(AlfrescoFolder *folder, NSError *error)
         {
             if (nil == folder)
             {
                 self.lastTestSuccessful = YES;
                 self.callbackCompleted = YES;
             }
             else
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = @"We should not succeed creating a folder this special set of characters";
                 XCTAssertTrue([folder.name isEqualToString:name], @"folder name should be %@, but instead we got %@",name, folder.name);
                 
                 
                 [self.dfService deleteNode:folder completionBlock:^(BOOL success, NSError *error)
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
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/**
 @Unique_TCRef 22S0, 22S1
 */
- (void)testRetrieveRootFolder
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        [self.dfService retrieveRootFolderWithCompletionBlock:^(AlfrescoFolder *rootFolder, NSError *error)
         {
             if (nil == rootFolder)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else
             {
                 XCTAssertNotNil(rootFolder,@"root folder should not be nil");
                 self.lastTestSuccessful = YES;
             }
             self.callbackCompleted = YES;
             
         }];
        
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/**
 @Unique_TCRef 13S5.
 */
- (void)testRetrieveChildrenInFolder
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        // get the children of the repository's root folder
        [self.dfService retrieveChildrenInFolder:self.currentSession.rootFolder completionBlock:^(NSArray *array, NSError *error)
         {
             if (nil == array)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else
             {
                 XCTAssertTrue(array.count > 0, @"Expected folder children but got %i", array.count);
                 if (self.isCloud)
                 {
                     XCTAssertTrue([self nodeArray:array containsName:@"Sites"], @"Folder children should contain Sites");
                 }
                 else
                 {
                     XCTAssertTrue([self nodeArray:array containsName:@"Data Dictionary"], @"Folder children should contain Data Dictionary");
                 }
                 
                 self.lastTestSuccessful = YES;
             }
             self.callbackCompleted = YES;
             
         }];
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/**
 @Unique_TCRef 14S1
 */
- (void)testRetrieveChildrenInFolderWithNoChildren
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
        
        NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:2];
        properties[@"cm:description"] = @"Test Description";
        properties[@"cm:title"] = @"Test Title";
        
        NSString *folderName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.unitTestFolder];
        [self.dfService createFolderWithName:folderName inParentFolder:self.testDocFolder properties:properties completionBlock:^(AlfrescoFolder *folder, NSError *error) {
            
            if (folder == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"#1 %@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(folder, @"Folder should not be nil");
                XCTAssertTrue([folder.name isEqualToString:folderName], @"Folder name should be %@", folderName);
                
                // check the properties of the foder are correct
                NSDictionary *newFolderProps = folder.properties;
                AlfrescoProperty *newDescriptionProp = newFolderProps[@"cm:description"];
                AlfrescoProperty *newTitleProp = newFolderProps[@"cm:title"];
                XCTAssertTrue([newDescriptionProp.value isEqualToString:@"Test Description"], @"cm:description property value does not match");
                XCTAssertTrue([newTitleProp.value isEqualToString:@"Test Title"], @"cm:title property value does not match");
                
                // serach folder using paging
                AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:100 skipCount:0];
                __block AlfrescoFolder *blockFolder = folder;
                [weakService retrieveChildrenInFolder:blockFolder listingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
                    if (pagingResult == nil)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"#2 %@ - %@", [error localizedDescription], [error localizedFailureReason]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        XCTAssertTrue(pagingResult.totalItems == 0, @"Expected 0 folder children, got back %i", pagingResult.totalItems);
                        
                        [weakService deleteNode:blockFolder completionBlock:^(BOOL success, NSError *error)
                         {
                             if (!success)
                             {
                                 self.lastTestSuccessful = NO;
                                 self.lastTestFailureMessage = [NSString stringWithFormat:@"#3 %@ - %@", [error localizedDescription], [error localizedFailureReason]];
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
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/**
 @Unique_TCRef 14F4
 */
- (void)testRetrieveChildrenInFolderWithEmptyPaging
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:0 skipCount:0];
        
        [self.dfService retrieveChildrenInFolder:self.testDocFolder listingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
            
            if (pagingResult == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                XCTAssertTrue(pagingResult.totalItems > 0, @"Expected children to be returned");
                self.lastTestSuccessful = YES;
            }
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/**
 Unique_TCRef 14S3
 */
- (void)testRetrieveChildrenInFolderWithUpdatedContentFirst
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        AlfrescoListingContext *pagingAndSort = [[AlfrescoListingContext alloc] initWithMaxItems:10 skipCount:0 sortProperty:kAlfrescoSortByModifiedAt sortAscending:NO];
        
        [self.dfService retrieveChildrenInFolder:self.testDocFolder listingContext:pagingAndSort completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
            
            if (pagingResult == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                XCTAssertTrue(pagingResult.objects.count > 0, @"Expecting to return more than one result");
                XCTAssertTrue(pagingResult.objects.count <= 10, @"Expecting a maximum of 10 results, instead got %i", pagingResult.objects.count);
                
                // check if array is sorted correctly
                NSArray *sortedArray = [pagingResult.objects sortedArrayUsingComparator:^(id a, id b) {
                    
                    AlfrescoNode *node1 = (AlfrescoNode *)a;
                    AlfrescoNode *node2 = (AlfrescoNode *)b;
                    
                    return [node2.modifiedAt compare:node1.modifiedAt];
                }];
                
                AlfrescoLogDebug(@"Paging Array: %@", pagingResult.objects);
                AlfrescoLogDebug(@"Sorted Array: %@", sortedArray);
                
                BOOL isResultSortedAccordingToModifiedDate = [pagingResult.objects isEqualToArray:sortedArray];
                
                XCTAssertTrue(isResultSortedAccordingToModifiedDate, @"The results where not sorted in descending order according to the modified date");
                
                self.lastTestSuccessful = YES;
            }
            self.callbackCompleted = YES;
        }];
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testCreateVerySmallDocument
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:4];
        properties[kCMISPropertyObjectTypeId] = [kAlfrescoTypeContent stringByAppendingString:@",P:cm:titled,P:cm:author"];
        properties[@"cm:description"] = @"Test Description";
        properties[@"cm:title"] = @"Test Title";
        properties[@"cm:author"] = @"Test Author";
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *sizeError = nil;
        NSDictionary *attributes = [fileManager attributesOfItemAtPath:self.verySmallTestFile error:&sizeError];
        XCTAssertNotNil(attributes, @"should be able to get the file attributes");
        if (!attributes)
        {
            self.lastTestSuccessful = NO;
            self.callbackCompleted = YES;
            return;
        }
        
        unsigned long long fileSize = [attributes fileSize];
        NSString *mimeType = @"text/plain";
        
        NSInputStream *fileInputStream = [[NSInputStream alloc] initWithFileAtPath:self.verySmallTestFile];
        AlfrescoContentStream *contentStream = [[AlfrescoContentStream alloc] initWithStream:fileInputStream mimeType:mimeType length:fileSize];
        
        XCTAssertNotNil(fileInputStream, @"we should have been able to create the input stream to the small file");
        if (!fileInputStream)
        {
            self.lastTestSuccessful = NO;
            self.callbackCompleted = YES;
            return;
        }
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat: @"yyyy-MM-dd'T'HH-mm-ss-SSS'"];
        NSString *documentName = [NSString stringWithFormat:@"small_file_test_%@.txt",[formatter stringFromDate:[NSDate date]]];
        __weak AlfrescoDocumentFolderService *weakFolderServer = self.dfService;
        [self.dfService createDocumentWithName:documentName
                                inParentFolder:self.testDocFolder
                                 contentStream:contentStream
                                    properties:properties
                               completionBlock:^(AlfrescoDocument *document, NSError *error){
                                   if (nil == document)
                                   {
                                       AlfrescoLogError(@"The following error occured trying to create the file: %@ - %@", [error localizedDescription], [error localizedFailureReason]);
                                       self.lastTestFailureMessage = [NSString stringWithFormat:@"Could not upload test document. Error %@",[error localizedDescription]];
                                       self.lastTestSuccessful = NO;
                                       self.callbackCompleted = YES;
                                   }
                                   else
                                   {
                                       XCTAssertNotNil(document, @"document should not be nil");
                                       XCTAssertTrue([document.name isEqualToString:documentName], @"folder name should be %@ but instead we got %@",documentName, document.name);
                                       XCTAssertTrue([document.type isEqualToString:kAlfrescoTypeContent], @"object type should be cm:content but instead we got %@", document.type);
                                       // check the properties were added at creation time
                                       NSDictionary *newFolderProps = document.properties;
                                       AlfrescoProperty *newDescriptionProp = newFolderProps[@"cm:description"];
                                       AlfrescoProperty *newTitleProp = newFolderProps[@"cm:title"];
                                       XCTAssertTrue([newDescriptionProp.value isEqualToString:@"Test Description"], @"cm:description property value does not match - we got %@", newDescriptionProp.value);
                                       XCTAssertTrue([newTitleProp.value isEqualToString:@"Test Title"], @"cm:title property value does not match - we got %@", newTitleProp.value);
                                       [weakFolderServer deleteNode:document completionBlock:^(BOOL succeeded, NSError *error){
                                           if (succeeded)
                                           {
                                               self.lastTestSuccessful = YES;
                                           }
                                           else
                                           {
                                               AlfrescoLogError(@"The following error occured trying to create the file: %@ - %@", [error localizedDescription], [error localizedFailureReason]);
                                               self.lastTestFailureMessage = [NSString stringWithFormat:@"Could not delete very small test document. Error %@",[error localizedDescription]];
                                               self.lastTestSuccessful = NO;
                                           }
                                           self.callbackCompleted = YES;
                                       }];
                                       
                                   }
                               } progressBlock:^(unsigned long long transferred, unsigned long long total){}];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/**
 Unique_TCRef 33F3
 Unique_TCRef 33F5
 Unique_TCRef 33F7
 Unique_TCRef 33F10
 Unique_TCRef 33F11
 */
- (void)testCreateDocumentWithNameUsingInvalidCharacters
{
    if (self.setUpSuccess)
    {
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:4];
        properties[kCMISPropertyObjectTypeId] = [kCMISPropertyObjectTypeIdValueDocument stringByAppendingString:@",P:cm:titled,P:cm:author"];
        properties[@"cm:description"] = @"Test Description";
        properties[@"cm:title"] = @"Test Title";
        properties[@"cm:author"] = @"Test Author";
        
        __weak AlfrescoDocumentFolderService *weakFolderServer = self.dfService;
        
        // check document with * in the file name
        [self.dfService createDocumentWithName:@"createDocumentTest*.jpg" inParentFolder:self.testDocFolder contentFile:self.testImageFile properties:properties completionBlock:^(AlfrescoDocument *document, NSError *error) {
            if (error == nil)
            {
                XCTAssertTrue(error != nil, @"Expected an error to be thrown");
                self.lastTestSuccessful = NO;
                self.callbackCompleted = YES;
            }
            else
            {
                AlfrescoLogError(@"The following error occured trying to create the file: %@ - %@", [error localizedDescription], [error localizedFailureReason]);
                XCTAssertFalse(document != nil, @"Expected the document not to be created");
                
                // check document with " in the file name
                [weakFolderServer createDocumentWithName:@"createDocumentTest\".jpg" inParentFolder:self.testDocFolder contentFile:self.testImageFile properties:properties completionBlock:^(AlfrescoDocument *document, NSError *error) {
                    if (error == nil)
                    {
                        XCTAssertTrue(error != nil, @"Expected an error to be thrown");
                        self.lastTestSuccessful = NO;
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        AlfrescoLogError(@"The following error occured trying to create the file: %@ - %@", [error localizedDescription], [error localizedFailureReason]);
                        XCTAssertFalse(document != nil, @"Expected the document not to be created");
                        
                        // check document with / and \ in the file name
                        [weakFolderServer createDocumentWithName:@"createDocumentTest\\.jpg" inParentFolder:self.testDocFolder contentFile:self.testImageFile properties:properties completionBlock:^(AlfrescoDocument *document, NSError *error) {
                            if (error == nil)
                            {
                                XCTAssertTrue(error != nil, @"Expected an error to be thrown");
                                self.lastTestSuccessful = NO;
                                self.callbackCompleted = YES;
                            }
                            else
                            {
                                AlfrescoLogError(@"The following error occured trying to create the file: %@ - %@", [error localizedDescription], [error localizedFailureReason]);
                                XCTAssertFalse(document != nil, @"Expected the document not to be created");
                                
                                // check document with empty name
                                [weakFolderServer createDocumentWithName:@"createDocument//Test.jpg" inParentFolder:self.testDocFolder contentFile:self.testImageFile properties:properties completionBlock:^(AlfrescoDocument *document, NSError *error) {
                                    if (error == nil)
                                    {
                                        XCTAssertTrue(error != nil, @"Expected an error to be thrown");
                                        self.lastTestSuccessful = NO;
                                        self.callbackCompleted = YES;
                                    }
                                    else
                                    {
                                        AlfrescoLogError(@"The following error occured trying to create the file: %@ - %@", [error localizedDescription], [error localizedFailureReason]);
                                        XCTAssertFalse(document != nil, @"Expected the document not to be created");
                                        
                                        // check document with empty name
                                        [weakFolderServer createDocumentWithName:@"" inParentFolder:self.testDocFolder contentFile:self.testImageFile properties:properties completionBlock:^(AlfrescoDocument *document, NSError *error) {
                                            if (error == nil)
                                            {
                                                XCTAssertTrue(error != nil, @"Expected an error to be thrown");
                                                self.lastTestSuccessful = NO;
                                            }
                                            else
                                            {
                                                AlfrescoLogError(@"The following error occured trying to create the file: %@ - %@", [error localizedDescription], [error localizedFailureReason]);
                                                XCTAssertFalse(document != nil, @"Expected the document not to be created");
                                                if (!document)
                                                {
                                                    self.lastTestSuccessful = YES;
                                                }
                                            }
                                            self.callbackCompleted = YES;
                                        }
                                                                   progressBlock:^(unsigned long long bytesTransferred, unsigned long long bytesTotal) {
                                                                       
                                                                   }];
                                    }
                                }
                                                           progressBlock:^(unsigned long long bytesTransferred, unsigned long long bytesTotal) {
                                                               
                                                           }];
                            }
                        }
                                                   progressBlock:^(unsigned long long bytesTransferred, unsigned long long bytesTotal) {
                                                       
                                                   }];
                    }
                }
                                           progressBlock:^(unsigned long long bytesTransferred, unsigned long long bytesTotal) {
                                               
                                           }];
            }
        }
                                 progressBlock:^(unsigned long long bytesTransferred, unsigned long long bytesTotal) {
                                     
                                 }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/**
 @Unique_TCRef 24S0
 @Unique_TCRef 13S1.
 */
- (void)testRetrieveFolderWithNoChildren
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:2];
        props[@"cm:description"] = @"test description";
        props[@"cm:title"] = @"test title";
        
        // create a new folder in the repository's root folder
        NSString *folderName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.unitTestFolder];
        [self.dfService createFolderWithName:folderName inParentFolder:self.testDocFolder properties:props
                             completionBlock:^(AlfrescoFolder *folder, NSError *error)
         {
             if (nil == folder)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 self.callbackCompleted = YES;
             }
             else
             {
                 XCTAssertNotNil(folder, @"folder should not be nil");
                 XCTAssertTrue([folder.name isEqualToString:folderName], @"folder name should be %@",folderName);
                 
                 // check the properties were added at creation time
                 NSDictionary *newFolderProps = folder.properties;
                 AlfrescoProperty *newDescriptionProp = newFolderProps[@"cm:description"];
                 AlfrescoProperty *newTitleProp = newFolderProps[@"cm:title"];
                 XCTAssertTrue([newDescriptionProp.value isEqualToString:@"test description"], @"cm:description property value does not match");
                 XCTAssertTrue([newTitleProp.value isEqualToString:@"test title"], @"cm:title property value does not match");
                 __block AlfrescoFolder *blockFolder = folder;
                 [weakService retrieveChildrenInFolder:blockFolder completionBlock:^(NSArray *children, NSError *error){
                     if(nil == children)
                     {
                         self.lastTestSuccessful = NO;
                         self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                         self.callbackCompleted = YES;
                     }
                     else
                     {
                         XCTAssertTrue(children.count == 0, @"folder should be empty, instead we get %d entries",children.count);
                         [weakService deleteNode:blockFolder completionBlock:^(BOOL success, NSError *error)
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
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}


/**
 @Unique_TCRef 24S0
 @Unique_TCRef 18S2. 
 */
- (void)testRetrieveFolderWithNoDocuments
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:2];
        props[@"cm:description"] = @"test description";
        props[@"cm:title"] = @"test title";
        
        // create a new folder in the repository's root folder
        NSString *folderName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.unitTestFolder];
        [self.dfService createFolderWithName:folderName inParentFolder:self.testDocFolder properties:props
                             completionBlock:^(AlfrescoFolder *folder, NSError *error)
         {
             if (nil == folder)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 self.callbackCompleted = YES;
             }
             else
             {
                 XCTAssertNotNil(folder, @"folder should not be nil");
                 XCTAssertTrue([folder.name isEqualToString:folderName], @"folder name should be %@",folderName);
                 
                 // check the properties were added at creation time
                 NSDictionary *newFolderProps = folder.properties;
                 AlfrescoProperty *newDescriptionProp = newFolderProps[@"cm:description"];
                 AlfrescoProperty *newTitleProp = newFolderProps[@"cm:title"];
                 XCTAssertTrue([newDescriptionProp.value isEqualToString:@"test description"], @"cm:description property value does not match");
                 XCTAssertTrue([newTitleProp.value isEqualToString:@"test title"], @"cm:title property value does not match");
                 __block AlfrescoFolder *blockFolder = folder;
                 [weakService retrieveDocumentsInFolder:blockFolder completionBlock:^(NSArray *children, NSError *error){
                     if(nil == children)
                     {
                         self.lastTestSuccessful = NO;
                         self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                         self.callbackCompleted = YES;
                     }
                     else
                     {
                         XCTAssertTrue(children.count == 0, @"folder should contain no documents, instead we get %d entries",children.count);
                         [weakService deleteNode:blockFolder completionBlock:^(BOOL success, NSError *error)
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
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/**
 @Unique_TCRef 24S0
 @Unique_TCRef 20S2
 */
- (void)testRetrieveFolderWithNoFolders
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:2];
        props[@"cm:description"] = @"test description";
        props[@"cm:title"] = @"test title";
        
        // create a new folder in the repository's root folder
        NSString *folderName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.unitTestFolder];
        [self.dfService createFolderWithName:folderName inParentFolder:self.testDocFolder properties:props
                             completionBlock:^(AlfrescoFolder *folder, NSError *error)
         {
             if (nil == folder)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 self.callbackCompleted = YES;
             }
             else
             {
                 XCTAssertNotNil(folder, @"folder should not be nil");
                 XCTAssertTrue([folder.name isEqualToString:folderName], @"folder name should be %@",folderName);
                 
                 // check the properties were added at creation time
                 NSDictionary *newFolderProps = folder.properties;
                 AlfrescoProperty *newDescriptionProp = newFolderProps[@"cm:description"];
                 AlfrescoProperty *newTitleProp = newFolderProps[@"cm:title"];
                 XCTAssertTrue([newDescriptionProp.value isEqualToString:@"test description"], @"cm:description property value does not match");
                 XCTAssertTrue([newTitleProp.value isEqualToString:@"test title"], @"cm:title property value does not match");
                 __block AlfrescoFolder *blockFolder = folder;
                 [weakService retrieveFoldersInFolder:blockFolder completionBlock:^(NSArray *children, NSError *error){
                     if(nil == children)
                     {
                         self.lastTestSuccessful = NO;
                         self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                         self.callbackCompleted = YES;
                     }
                     else
                     {
                         XCTAssertTrue(children.count == 0, @"folder should contain no folders, instead we get %d entries",children.count);
                         [weakService deleteNode:blockFolder completionBlock:^(BOOL success, NSError *error)
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
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}



/**
 @Unique_TCRef 14S0
 */
- (void)testRetrieveChildrenInFolderWithPaging
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        __block int maxItems = 1;
        __block int skipCount = 0;
        __block AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:maxItems skipCount:skipCount];
        
        //        __weak AlfrescoDocumentFolderService *weakSelf = self.dfService;
        
        [self.dfService retrieveChildrenInFolder:self.testDocFolder completionBlock:^(NSArray *array, NSError *error){
            if (nil == array)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                __block int numberOfChildren = array.count;
                XCTAssertFalse(0 == numberOfChildren, @"There should be at least 1 child element in the folder");
                [self.dfService retrieveChildrenInFolder:self.testDocFolder listingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error)
                 {
                     if (nil == pagingResult)
                     {
                         self.lastTestSuccessful = NO;
                         self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                     }
                     else
                     {
                         XCTAssertTrue(pagingResult.totalItems <= numberOfChildren, @"We expected that the total number of items should be less equal %d, but instead we got %d", numberOfChildren, pagingResult.totalItems);
                         
                         XCTAssertTrue(pagingResult.objects.count == 1 , @"We are asking for %d maxItems but got back %d", maxItems, pagingResult.objects.count);
                         
                         if (numberOfChildren > maxItems)
                         {
                             XCTAssertTrue(pagingResult.hasMoreItems, @"Expected that there are more items left");
                         }
                         else
                         {
                             XCTAssertFalse(pagingResult.hasMoreItems, @"the folder has exactly 1 item, so we would not expect to get more back");
                         }
                         
                         self.lastTestSuccessful = YES;
                     }
                     self.callbackCompleted = YES;
                 }];
            }
        }];
        
        // get the children of the repository's root folder
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/**
 maxItems == -1 is a special value indicating as many items as possible (and no server side paging for Cloud).
 @Unique_TCRef 14F5,14F6
 */
- (void)testRetrieveChildrenInFolderWithBogusPaging
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:-4 skipCount:-99];
        
        // get the children of the repository's root folder
        [self.dfService retrieveChildrenInFolder:self.testDocFolder listingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error)
         {
             if (nil == pagingResult)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else
             {
                 XCTAssertTrue(pagingResult.totalItems > 0, @"Expected folder children");
                 XCTAssertTrue(pagingResult.objects.count > 0, @"Expected at least 1 folder children returned, but we got %d instead", pagingResult.objects.count);
                 if (pagingResult.totalItems > 50)
                 {
                     XCTAssertTrue(pagingResult.hasMoreItems, @"Expected that there are more items left");
                 }
                 else
                 {
                     XCTAssertFalse(pagingResult.hasMoreItems, @"We should not have more than 50 items in total, but instead we have %d",pagingResult.totalItems);
                 }
                 
                 self.lastTestSuccessful = YES;
             }
             self.callbackCompleted = YES;
         }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}



/**
 @Unique_TCRef 15S0
 */
- (void)testRetrieveNodeWithFolderPathRelative
{
    if (self.setUpSuccess)
    {
        __block AlfrescoFolder *rootFolder = nil;
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        rootFolder = self.currentSession.rootFolder;
        
        // get the Sites child of the repository's root folder
        [self.dfService retrieveNodeWithFolderPath:@"Sites" relativeToFolder:rootFolder completionBlock:^(AlfrescoNode *node, NSError *error)
         {
             if (nil == node)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else
             {
                 XCTAssertNotNil(node, @"node should not be nil");
                 XCTAssertTrue([node.name isEqualToString:@"Sites"], @"node name should be Sites and not %@", node.name);
                 
                 self.lastTestSuccessful = YES;
             }
             self.callbackCompleted = YES;
             
         }];
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/**
 @Unique_TCRef 15F0, 15F1
 */
- (void)testRetrieveNodeWithNonExistingFolderPathRelative
{
    if (self.setUpSuccess)
    {
        __block AlfrescoFolder *rootFolder = nil;
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        rootFolder = self.currentSession.rootFolder;
        
        // get the Sites child of the repository's root folder
        NSString *name = @"Sites2";
        [self.dfService retrieveNodeWithFolderPath:name relativeToFolder:rootFolder completionBlock:^(AlfrescoNode *node, NSError *error)
         {
             if (nil == node)
             {
                 XCTAssertNotNil(error, @"error should not be nil");
                 self.lastTestSuccessful = YES;
             }
             else
             {
                 XCTAssertNil(node, @"Expected empty node");
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 self.lastTestSuccessful = NO;
             }
             self.callbackCompleted = YES;
             
         }];
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/**
 @Unique_TCRef 18S0
 */
- (void)testRetrieveDocumentsInFolder
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        // get the documents of the repository's root folder
        [self.dfService retrieveDocumentsInFolder:self.testDocFolder completionBlock:^(NSArray *array, NSError *error)
         {
             if (nil == array)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else
             {
                 XCTAssertTrue(array.count > 0, @"Expected more than 0 documents");
                 if (array.count > 0)
                 {
                     for (AlfrescoDocument *document in array) {
                         if([document.name isEqualToString:@"versioned-quote.txt"])
                         {
                             XCTAssertNotNil(document.type, @"type should be filled");
                             XCTAssertNotNil(document.contentMimeType, @"contentMimeType should be filled");
                             XCTAssertNotNil(document.versionLabel, @"versionLabel should be filled");
                             XCTAssertTrue(document.contentLength > 0, @"contentLength should be filled");
                             XCTAssertTrue(document.isLatestVersion, @"isLatestVersion should be filled");
                             XCTAssertTrue([document.contentMimeType isEqualToString:@"text/plain"], @"Expected text mimetype");
                             XCTAssertNotNil(document.title, @"At least the document title should NOT be nil");
                             XCTAssertFalse([document.title isEqualToString:@""], @"title should NOT be an empty string");
                             XCTAssertFalse([document.title isEqualToString:@"(null)"], @"title should return string (null)");
                             
                         }
                     }
                     self.lastTestSuccessful = YES;
                 }
                 else
                 {
                     self.lastTestSuccessful = NO;
                     self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 }
                 
             }
             self.callbackCompleted = YES;
             
         }];
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/**
 * TEST Alfresco Node SERIALIZATION
 */
- (void)testAlfrescoNodeSerialization
{
    if (self.setUpSuccess)
    {
        if (!self.isCloud)
        {
            __block AlfrescoDocumentFolderService *documentService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
            
            NSString *versionedFile = [self.testFolderPathName stringByAppendingPathComponent:@"multiple-versions.txt"];
            [documentService retrieveNodeWithFolderPath:versionedFile completionBlock:^(AlfrescoNode *node, NSError *error)
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
                     self.lastTestSuccessful = YES;
                     
                     AlfrescoDocument *doc = (AlfrescoDocument *)node;
                     AlfrescoProperty *docProperty = [doc.properties valueForKey:kCMISPropertyName];
                     
                     NSString *docName = doc.name;
                     NSString *docCreatedBy = doc.createdBy;
                     BOOL isDocDocument = node.isDocument;
                     NSString *docMimeType = doc.contentMimeType;
                     NSString *docVersion = doc.versionLabel;
                     
                     NSMutableArray *myObject = [NSMutableArray array];
                     [myObject addObject:doc];
                     
                     NSString *filePath = [[self userTestConfigFolder] stringByAppendingPathComponent:@"serialized-object.txt"];
                     [NSKeyedArchiver archiveRootObject:myObject toFile:filePath];
                     
                     NSMutableArray* myArray = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
                     
                     if ([myArray count] > 0)
                     {
                         AlfrescoDocument *serializedDoc = myArray[0];
                         AlfrescoProperty *serializedDocProperty = [doc.properties valueForKey:kCMISPropertyName];
                         
                         XCTAssertEqualObjects(docName, serializedDoc.name, @"name should match");
                         XCTAssertEqualObjects(docCreatedBy, serializedDoc.createdBy, @"createdBy should match");
                         XCTAssertNotNil(serializedDoc.properties, @"properties should not be nil");
                         XCTAssertEqualObjects(docProperty.value, serializedDocProperty.value, @"checking AlfrescoProperty Serialization. values should match");
                         XCTAssertEqual(isDocDocument, serializedDoc.isDocument, @"isDocument should match");
                         XCTAssertEqualObjects(docMimeType, serializedDoc.contentMimeType, @"docMimeType should match");
                         XCTAssertEqualObjects(docVersion, serializedDoc.versionLabel, @"docVersion should match");
                     }
                     
                     documentService = nil;
                 }
                 
                 self.callbackCompleted = YES;
             }];
            
            [self waitUntilCompleteWithFixedTimeInterval];
            XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
        }
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/**
 @Unique_TCRef 19S0
 */
- (void)testRetrieveDocumentsInFolderWithPaging
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        __block int maxItems = 2;
        __block int skipCount = 1;
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:maxItems skipCount:skipCount];
        //        __weak AlfrescoDocumentFolderService *weakSelf = self.dfService;
        [self.dfService retrieveDocumentsInFolder:self.testDocFolder completionBlock:^(NSArray *foundDocuments, NSError *error){
            if (nil == foundDocuments)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                __block int numberOfDocs = foundDocuments.count;
                XCTAssertFalse(0 == numberOfDocs, @"We should have at least 1 document in the folder. Instead we got none");
                [self.dfService retrieveDocumentsInFolder:self.testDocFolder listingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error)
                 {
                     if (nil == pagingResult)
                     {
                         self.lastTestSuccessful = NO;
                         self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                     }
                     else
                     {
                         XCTAssertTrue(pagingResult.totalItems == numberOfDocs, @"Expected more than %d documents in total, but got %d",maxItems, pagingResult.totalItems);
                         int maxToBeFound = numberOfDocs - skipCount;
                         if (maxToBeFound < 0)
                         {
                             maxToBeFound = 0;
                         }
                         if (maxItems <= maxToBeFound)
                         {
                             XCTAssertTrue(pagingResult.objects.count == maxItems, @"Expected %d documents, but got %d", maxItems, pagingResult.objects.count);
                             if (maxItems < maxToBeFound)
                             {
                                 XCTAssertTrue(pagingResult.hasMoreItems, @"we should have more items than we got back");
                             }
                             else
                             {
                                 XCTAssertFalse(pagingResult.hasMoreItems, @"we should not have more than %d items", maxItems);
                             }
                         }
                         else
                         {
                             XCTAssertTrue(pagingResult.objects.count == maxToBeFound, @"Expected %d documents, but got %d", maxToBeFound, pagingResult.objects.count);
                             XCTAssertFalse(pagingResult.hasMoreItems, @"we should not have more than %d items", maxItems);
                         }
                         
                         
                         self.lastTestSuccessful = YES;
                     }
                     self.callbackCompleted = YES;
                     
                 }];
                
            }
        }];
        
        // get the documents of the repository's root folder
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/**
 @Unique_TCRef 19F4, 19F5
 */
- (void)testRetrieveDocumentsInFolderWithBogusPaging
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:-2 skipCount:-1];
        
        // get the documents of the repository's root folder
        [self.dfService retrieveDocumentsInFolder:self.testDocFolder listingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error)
         {
             if (nil == pagingResult)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else
             {
                 XCTAssertTrue(pagingResult.objects.count > 0, @"Expected more than 0 documents, but instead we got %d",pagingResult.objects.count);
                 XCTAssertTrue(pagingResult.totalItems > 2, @"Expected more than 2 documents in total");
                 
                 self.lastTestSuccessful = YES;
             }
             self.callbackCompleted = YES;
             
         }];
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/**
 @Unique_TCRef 20S0
 */

- (void)testRetrieveFoldersInFolder
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        // get the documents of the repository's root folder
        [self.dfService retrieveFoldersInFolder:self.testDocFolder completionBlock:^(NSArray *array, NSError *error)
         {
             if (nil == array)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else
             {
                 XCTAssertTrue(array.count > 0, @"Expected more than 0 folders");
                 if (array.count > 0)
                 {
                     for (AlfrescoFolder *folder in array) {
                         if([folder.name isEqualToString:@"Guest Home"])
                         {
                             XCTAssertNotNil(folder.createdBy, @"createdBy should be filled");
                             XCTAssertNotNil(folder.type, @"type should be filled");
                             XCTAssertNotNil(folder.title, @"title should be filled");
                             XCTAssertTrue(folder.isFolder, @"isFolder should be filled");
                             XCTAssertFalse(folder.isDocument, @"isDocument should be filled");
                             XCTAssertNotNil(folder.createdBy, @"createdBy should be filled");
                             XCTAssertNotNil(folder.createdAt, @"creationDate should be filled");
                             XCTAssertNotNil(folder.modifiedBy, @"modifiedBy should be filled");
                             XCTAssertNotNil(folder.modifiedAt, @"modificationDate should be filled");
                             XCTAssertTrue([folder.title isEqualToString:@"Guest Home"], @"Expected Guest Home as title");
                         }
                     }
                     self.lastTestSuccessful = YES;
                 }
                 else
                 {
                     self.lastTestSuccessful = NO;
                     self.lastTestFailureMessage = @"Empty array.";
                 }
                 
             }
             self.callbackCompleted = YES;
             
         }];
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/**
 @Unique_TCRef 21S1
 */
- (void)testRetrieveFoldersInFolderWithPaging
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        __block int maxItems = 1;
        __block int skipCount = 0;
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:1 skipCount:skipCount];
        
        //        __weak AlfrescoDocumentFolderService *weakSelf = self.dfService;
        [self.dfService retrieveFoldersInFolder:self.testDocFolder completionBlock:^(NSArray *foundFolders, NSError *error){
            if (nil == foundFolders)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                __block int numberOfFolders = foundFolders.count;
                [self.dfService retrieveFoldersInFolder:self.testDocFolder listingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error)
                 {
                     if (nil == pagingResult)
                     {
                         self.lastTestSuccessful = NO;
                         self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                     }
                     else
                     {
                         XCTAssertTrue(pagingResult.totalItems == numberOfFolders, @"Expected %d folders in total, but we have %d",numberOfFolders, pagingResult.totalItems);
                         
                         if (numberOfFolders > maxItems)
                         {
                             XCTAssertTrue(pagingResult.objects.count == maxItems, @"Expected at least %d folders, but got back %d", maxItems, pagingResult.objects.count);
                             if (numberOfFolders == maxItems)
                             {
                                 XCTAssertFalse(pagingResult.hasMoreItems, @"Expected no more folders available, but instead it says there are more items");
                             }
                             else
                             {
                                 XCTAssertTrue(pagingResult.hasMoreItems, @"Expected more folders available, but instead it says there are no more items");
                             }
                         }
                         else
                         {
                             XCTAssertTrue(pagingResult.objects.count == numberOfFolders, @"Expected at least %d folders, but got back %d", numberOfFolders, pagingResult.objects.count);
                             XCTAssertFalse(pagingResult.hasMoreItems, @"Expected no more folders available, but instead it says there are more items");
                         }
                         self.lastTestSuccessful = YES;
                     }
                     self.callbackCompleted = YES;
                     
                 }];
                
            }
        }];
        
        // get the documents of the repository's root folder
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/**
 @Unique_TCRef 17S1
 */
- (void)testRetrieveNodeWithIdentifier
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        
        [self.dfService retrieveNodeWithIdentifier:self.testDocFolder.identifier completionBlock:^(AlfrescoNode *node, NSError *error)
         {
             if (nil == node)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else
             {
                 XCTAssertNotNil(node, @"node should not be nil");
                 XCTAssertNotNil(node.identifier, @"nodeRef should not be nil");
                 XCTAssertTrue([node.identifier isEqualToString:self.testDocFolder.identifier], @"nodeRef should be the same as root folder");
                 
                 self.lastTestSuccessful = YES;
             }
             self.callbackCompleted = YES;
         }];
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/**
 @Unique_TCRef 32S0
 @Unique_TCRef 17F1
 @Unique_TCRef 24S0
 */
- (void)testRetrieveNodeWithIdentifierNonExisting
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:2];
        props[@"cm:description"] = @"test description";
        props[@"cm:title"] = @"test title";
        
        // create a new folder in the repository's root folder
        NSString *folderName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.unitTestFolder];
        [self.dfService createFolderWithName:folderName inParentFolder:self.testDocFolder properties:props
                             completionBlock:^(AlfrescoFolder *folder, NSError *error)
         {
             if (nil == folder)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 self.callbackCompleted = YES;
             }
             else
             {
                 XCTAssertNotNil(folder, @"folder should not be nil");
                 XCTAssertTrue([folder.name isEqualToString:folderName], @"folder name should be %@",folderName);
                 __block AlfrescoFolder *strongFolder = folder;
                 // check the properties were added at creation time
                 NSDictionary *newFolderProps = folder.properties;
                 AlfrescoProperty *newDescriptionProp = newFolderProps[@"cm:description"];
                 AlfrescoProperty *newTitleProp = newFolderProps[@"cm:title"];
                 XCTAssertTrue([newDescriptionProp.value isEqualToString:@"test description"], @"cm:description property value does not match");
                 XCTAssertTrue([newTitleProp.value isEqualToString:@"test title"], @"cm:title property value does not match");
                 
                 [self.dfService deleteNode:folder completionBlock:^(BOOL success, NSError *error)
                  {
                      if (!success)
                      {
                          self.lastTestSuccessful = NO;
                          self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                          self.callbackCompleted = YES;
                      }
                      else
                      {
                          [weakService retrieveNodeWithIdentifier:strongFolder.identifier completionBlock:^(AlfrescoNode *node, NSError *error){
                              if (nil == node)
                              {
                                  self.lastTestSuccessful = YES;
                              }
                              else
                              {
                                  self.lastTestSuccessful = NO;
                                  self.lastTestFailureMessage = @"We expected the folder not to be accessible after we deleted it";
                              }
                              self.callbackCompleted = YES;
                              
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


/**
 @Unique_TCRef 16S1
 */
- (void)testRetrieveNodeWithFolderPath
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        NSString *folderPath = [self.testFolderPathName stringByAppendingPathComponent:self.fixedFileName];
        [self.dfService retrieveNodeWithFolderPath:folderPath completionBlock:^(AlfrescoNode *node, NSError *error) {
            if (nil == node)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                XCTAssertNotNil(node, @"node should not be nil");
                XCTAssertNotNil(node.identifier, @"nodeRef should not be nil");
                XCTAssertTrue([node.name isEqualToString:self.fixedFileName], @"name should be equal to %@",self.fixedFileName);
                // REMOVED UNTIL BUG MOBSDK-462 IS RESOLVED
                //                XCTAssertTrue(node.isFolder, @"Node should be a folder");
                //                XCTAssertFalse(node.isDocument, @"Node should not be a document");
                
                self.lastTestSuccessful = YES;
            }
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/**
 @Unique_TCRef 32S0
 @Unique_TCRef 16F1
 @Unique_TCRef 24S0
 */
- (void)testRetrieveNodeWithFolderPathNonExisting
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:2];
        props[@"cm:description"] = @"test description";
        props[@"cm:title"] = @"test title";
        
        // create a new folder in the repository's root folder
        NSString *folderName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.unitTestFolder];
        [self.dfService createFolderWithName:folderName inParentFolder:self.testDocFolder properties:props
                             completionBlock:^(AlfrescoFolder *folder, NSError *error)
         {
             if (nil == folder)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 self.callbackCompleted = YES;
             }
             else
             {
                 XCTAssertNotNil(folder, @"folder should not be nil");
                 XCTAssertTrue([folder.name isEqualToString:folderName], @"folder name should be %@",folderName);
                 __block NSString *folderPath = [self.testFolderPathName stringByAppendingPathComponent:folderName];
                 // check the properties were added at creation time
                 [self.dfService deleteNode:folder completionBlock:^(BOOL success, NSError *error)
                  {
                      if (!success)
                      {
                          self.lastTestSuccessful = NO;
                          self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                          self.callbackCompleted = YES;
                      }
                      else
                      {
                          [weakService retrieveNodeWithFolderPath:folderPath completionBlock:^(AlfrescoNode *node, NSError *error){
                              if (nil == node)
                              {
                                  self.lastTestSuccessful = YES;
                              }
                              else
                              {
                                  self.lastTestSuccessful = NO;
                                  self.lastTestFailureMessage = @"We expected the folder not to be accessible after we deleted it";
                              }
                              self.callbackCompleted = YES;
                              
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


/**
 @Unique_TCRef 23S2
 */
- (void)testRetrieveParentNode
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        [self.dfService retrieveParentFolderOfNode:self.testAlfrescoDocument completionBlock:^(AlfrescoFolder *folder, NSError *error){
            if (nil == folder)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                XCTAssertNotNil(folder, @"node should not be nil");
                XCTAssertNotNil(folder.identifier, @"nodeRef should not be nil");
                XCTAssertTrue([folder.identifier isEqualToString:self.testDocFolder.identifier], @"nodeRef should be the same as root folder");
                
                self.lastTestSuccessful = YES;
            }
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}


/**
 @Unique_TCRef 18S0
 @Unique_TCRef 27S3
 */
- (void)testDownloadDocument
{
    if (self.setUpSuccess)
    {
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        // get the documents of the repository's root folder
        __weak AlfrescoDocumentFolderService *weakDfService = self.dfService;
        [self.dfService retrieveDocumentsInFolder:self.testDocFolder completionBlock:^(NSArray *array, NSError *error)
         {
             if (nil == array)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 self.callbackCompleted = YES;
             }
             else
             {
                 XCTAssertTrue(array.count > 0, @"Expected more than 0 documents");
                 if (array.count > 0)
                 {
                     [weakDfService retrieveContentOfDocument:array[0] completionBlock:^(AlfrescoContentFile *contentFile, NSError *error)
                      {
                          if (nil == contentFile)
                          {
                              self.lastTestSuccessful = NO;
                              self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                          }
                          else
                          {
                              self.lastTestSuccessful = YES;
                              // Assert File exists and check file length
                              NSString *filePath = [contentFile.fileUrl path];
                              XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:filePath], @"File does not exist");
                              NSError *error;
                              NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
                              XCTAssertNil(error, @"Could not verify attributes of file %@: %@", filePath, [error description]);
                              XCTAssertTrue([fileAttributes fileSize] > 100, @"Expected a file large than 100 bytes, but found one of %f kb", [fileAttributes fileSize]/1024.0);
                              
                              // Nice boys clean up after themselves
                              [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                              XCTAssertNil(error, @"Could not remove file %@: %@", filePath, [error description]);
                          }
                          
                          self.callbackCompleted = YES;
                          
                      } progressBlock:^(unsigned long long bytesDownloaded, unsigned long long bytesTotal) {
                          AlfrescoLogDebug(@"progress %i/%i", bytesDownloaded, bytesTotal);
                      }];
                 }
                 else
                 {
                     self.lastTestSuccessful = NO;
                     self.lastTestFailureMessage = @"Failed to download document.";
                     self.callbackCompleted = YES;
                 }
                 
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

/**
 @Unique_TCRef 33S0
 @Unique_TCRef 27F1
 @Unique_TCRef 24S0
 */
- (void)testDownloadDocumentNonExisting
{
    if (self.setUpSuccess)
    {
        NSString *filename = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.testImageName];
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:4];
        // provide the objectTypeId so we can specify the cm:author aspect
        props[kCMISPropertyObjectTypeId] = [kCMISPropertyObjectTypeIdValueDocument stringByAppendingString:@",P:cm:titled,P:cm:author"];
        props[@"cm:description"] = @"test description";
        props[@"cm:title"] = @"test title";
        props[@"cm:author"] = @"test author";
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
        [self.dfService createDocumentWithName:filename inParentFolder:self.testDocFolder contentFile:self.testImageFile properties:props completionBlock:^(AlfrescoDocument *document, NSError *blockError) {
            if (nil == document)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"#1 %@ - %@", [blockError localizedDescription], [blockError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(document.identifier, @"document identifier should be filled");
                XCTAssertTrue(document.contentLength > 100, @"expected content to be filled");
                
                // check the properties were added at creation time
                NSDictionary *newDocProps = document.properties;
                AlfrescoProperty *newDescriptionProp = newDocProps[@"cm:description"];
                AlfrescoProperty *newTitleProp = newDocProps[@"cm:title"];
                AlfrescoProperty *newAuthorProp = newDocProps[@"cm:author"];
                XCTAssertTrue([newDescriptionProp.value isEqualToString:@"test description"], @"cm:description property value does not match");
                XCTAssertTrue([newTitleProp.value isEqualToString:@"test title"], @"cm:title property value does not match");
                XCTAssertTrue([newAuthorProp.value isEqualToString:@"test author"], @"cm:author property value does not match");
                
                __block AlfrescoDocument *strongDocument = document;
                
                // delete the test document
                [weakService deleteNode:document completionBlock:^(BOOL success, NSError *error) {
                    if (!success)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"#2 %@ - %@", [error localizedDescription], [error localizedFailureReason]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        [weakService retrieveContentOfDocument:strongDocument completionBlock:^(AlfrescoContentFile *contentFile, NSError *error){
                            if (nil == contentFile)
                            {
                                self.lastTestSuccessful = YES;
                            }
                            else
                            {
                                self.lastTestSuccessful = NO;
                                self.lastTestFailureMessage = @"We should not be able to get content for a deleted/nonexisting document";
                            }
                            self.callbackCompleted = YES;
                        } progressBlock:^(unsigned long long down, unsigned long long total) {
                            // No-op
                        }];
                    }
                }];
            }
        } progressBlock:^(unsigned long long bytesUploaded, unsigned long long bytesTotal) {
            // No-op
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}



/**
 @Unique_TCRef 33S0
 @Unique_TCRef 24S0
 */
- (void)testUploadImage
{
    if (self.setUpSuccess)
    {
        NSString *filename = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.testImageName];
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:4];
        // provide the objectTypeId so we can specify the cm:author aspect
        props[kCMISPropertyObjectTypeId] = [kCMISPropertyObjectTypeIdValueDocument stringByAppendingString:@",P:cm:titled,P:cm:author"];
        props[@"cm:description"] = @"test description";
        props[@"cm:title"] = @"test title";
        props[@"cm:author"] = @"test author";
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        [self.dfService createDocumentWithName:filename inParentFolder:self.testDocFolder
                                   contentFile:self.testImageFile
                                    properties:props
                               completionBlock:^(AlfrescoDocument *document, NSError *blockError){
                                   if (nil == document)
                                   {
                                       self.lastTestSuccessful = NO;
                                       self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [blockError localizedDescription], [blockError localizedFailureReason]];
                                       self.callbackCompleted = YES;
                                   }
                                   else
                                   {
                                       XCTAssertNotNil(document.identifier, @"document identifier should be filled");
                                       XCTAssertTrue(document.contentLength > 100, @"expected content to be filled");
                                       
                                       // check the properties were added at creation time
                                       NSDictionary *newDocProps = document.properties;
                                       AlfrescoProperty *newDescriptionProp = newDocProps[@"cm:description"];
                                       AlfrescoProperty *newTitleProp = newDocProps[@"cm:title"];
                                       AlfrescoProperty *newAuthorProp = newDocProps[@"cm:author"];
                                       XCTAssertTrue([newDescriptionProp.value isEqualToString:@"test description"], @"cm:description property value does not match");
                                       XCTAssertTrue([newTitleProp.value isEqualToString:@"test title"], @"cm:title property value does not match");
                                       XCTAssertTrue([newAuthorProp.value isEqualToString:@"test author"], @"cm:author property value does not match");
                                       
                                       XCTAssertTrue(newDescriptionProp.type == AlfrescoPropertyTypeString, @"cm:description property should be of string type");
                                       XCTAssertFalse(newDescriptionProp.isMultiValued, @"isMultiValued property should not be nil");
                                       XCTAssertTrue(newTitleProp.type == AlfrescoPropertyTypeString, @"cm:title property should be of string type");
                                       XCTAssertFalse(newTitleProp.isMultiValued, @"isMultiValued property should not be nil");
                                       XCTAssertTrue(newAuthorProp.type == AlfrescoPropertyTypeString, @"cm:author property should be of string type");
                                       XCTAssertFalse(newAuthorProp.isMultiValued, @"isMultiValued property should not be nil");
                                       
                                       // delete the test document
                                       [self.dfService deleteNode:document completionBlock:^(BOOL success, NSError *error)
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
                               } progressBlock:^(unsigned long long bytesUploaded, unsigned long long bytesTotal){
                               }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
    
}
/*
 @Unique_TCRef 27S1
 @Unique_TCRef 30S1
*/
- (void)testUpdateContentForDocument
{
    /**
     * FIXME: Alfresco v4.x servers (including cloud) don't auto version and require a checkout/checkin sequence in order to pass this test.
     *        Currently there is no COCI feature in ObjectiveCMIS, so this test cannot currently pass on those earlier repositories.
     */
    AlfrescoRepositoryInfo *repositoryInfo = [self.currentSession repositoryInfo];
    if ([repositoryInfo.majorVersion integerValue] == 4 || [repositoryInfo.edition isEqualToString:kAlfrescoRepositoryEditionCloud])
    {
        return;
    }
    
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        __weak AlfrescoDocumentFolderService *weakDfService = self.dfService;
        [self.dfService retrieveContentOfDocument:self.testAlfrescoDocument completionBlock:^(AlfrescoContentFile *contentFile, NSError *error){
            if (nil == contentFile)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(contentFile,@"created content file should not be nil");
                NSError *fileError = nil;
                //                NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[contentFile.fileUrl path] error:&fileError];
                XCTAssertNil(fileError, @"expected no error in getting file attributes for contentfile at path %@",[contentFile.fileUrl path]);
                //                unsigned long long size = [[fileAttributes valueForKey:NSFileSize] unsignedLongLongValue];
                NSError *readError = nil;
                __block NSString *stringContent = [NSString stringWithContentsOfFile:[contentFile.fileUrl path] encoding:NSUTF8StringEncoding error:&readError];
                if (nil == stringContent)
                {
                    self.lastTestSuccessful = NO;
                    self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [readError localizedDescription], [readError localizedFailureReason]];
                    self.callbackCompleted = YES;
                }
                else
                {
                    __block NSString *updatedContent = [NSString stringWithFormat:@"%@ - and we added some text.",stringContent];
                    NSData *data = [updatedContent dataUsingEncoding:NSUTF8StringEncoding];
                    __block AlfrescoContentFile *updatedContentFile = [[AlfrescoContentFile alloc] initWithData:data mimeType:contentFile.mimeType];
                    
                    float previousVersionNumber = [self.testAlfrescoDocument.versionLabel floatValue];
                    NSDate *previousLastModificationDate = self.testAlfrescoDocument.modifiedAt;
                    
                    // need to delay updating the content to ensure that an updated modifiedAt date is returned
                    [NSThread sleepForTimeInterval:1];
                    
                    [weakDfService updateContentOfDocument:self.testAlfrescoDocument contentFile:updatedContentFile
                                           completionBlock:^(AlfrescoDocument *updatedDocument, NSError *error)
                     {
                         
                         if (nil == updatedDocument)
                         {
                             self.lastTestSuccessful = NO;
                             self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                             self.callbackCompleted = YES;
                         }
                         else
                         {
                             XCTAssertNotNil(updatedDocument.identifier, @"document identifier should be filled");
                             XCTAssertTrue(updatedDocument.contentLength > 100, @"expected content to be filled");
                             
                             float updatedVersionNumber = [updatedDocument.versionLabel floatValue];
                             
                             XCTAssertTrue(previousVersionNumber < updatedVersionNumber, @"expected the updated AlfrescoDocument object to have a higher version number, but previous %f is not less than %f", previousVersionNumber, updatedVersionNumber);
                             XCTAssertTrue([previousLastModificationDate compare:updatedDocument.modifiedAt] == NSOrderedAscending, @"expected the returned AlfrescoDocument object to have a newer last modification date");
                             
                             [weakDfService retrieveContentOfDocument:updatedDocument completionBlock:^(AlfrescoContentFile *checkContentFile, NSError *error){
                                 if (nil == checkContentFile)
                                 {
                                     self.lastTestSuccessful = NO;
                                     self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                 }
                                 else
                                 {
                                     NSError *fileError = nil;
                                     NSDictionary *fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:[checkContentFile.fileUrl path] error:&fileError];
                                     XCTAssertNil(fileError, @"expected no error with getting file attributes for content file at path %@",[checkContentFile.fileUrl path]);
                                     unsigned long long size = [[fileDict valueForKey:NSFileSize] unsignedLongLongValue];
                                     XCTAssertTrue(size > 0, @"checkContentFile length should be greater than 0. We got %llu",size);
                                     NSError *checkError = nil;
                                     NSString *checkContentString = [NSString stringWithContentsOfFile:[checkContentFile.fileUrl path]
                                                                                              encoding:NSUTF8StringEncoding
                                                                                                 error:&checkError];
                                     if (nil == checkContentString)
                                     {
                                         self.lastTestSuccessful = NO;
                                         self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [checkError localizedDescription], [checkError localizedFailureReason]];
                                     }
                                     else
                                     {
                                         XCTAssertTrue([checkContentString isEqualToString:updatedContent],@"We should get back the updated content, instead we get %@",updatedContent);
                                         self.lastTestSuccessful = YES;
                                     }
                                     
                                 }
                                 self.callbackCompleted = YES;
                             } progressBlock:^(unsigned long long bytesTransferred, unsigned long long bytesTotal) {
                                 AlfrescoLogDebug(@"progress %i/%i", bytesTransferred, bytesTotal);
                             }];
                         }
                     } progressBlock:^(unsigned long long bytesDownloaded, unsigned long long bytesTotal) {
                         AlfrescoLogDebug(@"progress %i/%i", bytesDownloaded, bytesTotal);
                     }];
                }
            }
            
        } progressBlock:^(unsigned long long bytesDownloaded, unsigned long long bytesTotal) {
            AlfrescoLogDebug(@"progress %i/%i", bytesDownloaded, bytesTotal);
        }];
        
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/**
 @Unique_TCRef 33S0
 @Unique_TCRef 30F1
 @Unique_TCRef 24S0
 */
- (void)testUpdateContentForDocumentNonExisting
{
    if (self.setUpSuccess)
    {
        NSString *filename = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.testImageName];
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:4];
        // provide the objectTypeId so we can specify the cm:author aspect
        props[kCMISPropertyObjectTypeId] = [kCMISPropertyObjectTypeIdValueDocument stringByAppendingString:@",P:cm:titled,P:cm:author"];
        props[@"cm:description"] = @"test description";
        props[@"cm:title"] = @"test title";
        props[@"cm:author"] = @"test author";
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
        [self.dfService createDocumentWithName:filename inParentFolder:self.testDocFolder contentFile:self.testImageFile properties:props completionBlock:^(AlfrescoDocument *document, NSError *blockError) {
            if (nil == document)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"#1 %@ - %@", [blockError localizedDescription], [blockError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(document.identifier, @"document identifier should be filled");
                XCTAssertTrue(document.contentLength > 100, @"expected content to be filled");
                
                // check the properties were added at creation time
                NSDictionary *newDocProps = document.properties;
                AlfrescoProperty *newDescriptionProp = newDocProps[@"cm:description"];
                AlfrescoProperty *newTitleProp = newDocProps[@"cm:title"];
                AlfrescoProperty *newAuthorProp = newDocProps[@"cm:author"];
                XCTAssertTrue([newDescriptionProp.value isEqualToString:@"test description"], @"cm:description property value does not match");
                XCTAssertTrue([newTitleProp.value isEqualToString:@"test title"], @"cm:title property value does not match");
                XCTAssertTrue([newAuthorProp.value isEqualToString:@"test author"], @"cm:author property value does not match");
                
                __block AlfrescoDocument *strongDocument = document;
                
                // delete the test document
                [weakService deleteNode:document completionBlock:^(BOOL success, NSError *error) {
                    if (!success)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"#2 %@ - %@", [error localizedDescription], [error localizedFailureReason]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        __block NSString *updatedContent = [NSString stringWithFormat:@"and we added some text."];
                        NSData *data = [updatedContent dataUsingEncoding:NSUTF8StringEncoding];
                        __block AlfrescoContentFile *updatedContentFile = [[AlfrescoContentFile alloc] initWithData:data mimeType:@"text/plain"];
                        [weakService updateContentOfDocument:strongDocument contentFile:updatedContentFile completionBlock:^(AlfrescoDocument *updatedDoc, NSError *error) {
                            if (nil == updatedDoc)
                            {
                                self.lastTestSuccessful = YES;
                            }
                            else
                            {
                                self.lastTestSuccessful = NO;
                                self.lastTestFailureMessage = @"It should not be possible to update a deleted/nonexisting document";
                            }
                            self.callbackCompleted = YES;
                        } progressBlock:^(unsigned long long bytesTransferred, unsigned long long bytesTotal) {
                            // No-op
                        }];
                    }
                }];
            }
        } progressBlock:^(unsigned long long bytesUploaded, unsigned long long bytesTotal) {
            // No-op
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRenameNode
{
    if (self.setUpSuccess)
    {
        NSString *filename = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.testImageName];
        __block NSString *testDescription = @"Peter's test description";
        __block NSString *testTitle = @"test title";
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:4];
        // provide the objectTypeId so we can specify the cm:author aspect
        props[kCMISPropertyObjectTypeId] = [kCMISPropertyObjectTypeIdValueDocument stringByAppendingString:@",P:cm:titled,P:cm:author"];
        props[@"cm:description"] = testDescription;
        props[@"cm:title"] = testTitle;
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        __weak AlfrescoDocumentFolderService *weakDfService = self.dfService;
        
        [self.dfService createDocumentWithName:filename inParentFolder:self.testDocFolder contentFile:self.testImageFile properties:props completionBlock:^(AlfrescoDocument *imageDoc, NSError *blockError) {
            if (nil == imageDoc)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"#1 %@ - %@", [blockError localizedDescription], [blockError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                NSString *updatedName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.testImageName];
                NSMutableDictionary *updateProperties = [NSMutableDictionary dictionary];
                updateProperties[@"cm:name"] = updatedName;
                [weakDfService updatePropertiesOfNode:imageDoc properties:updateProperties completionBlock:^(AlfrescoNode *node, NSError *updateError){
                    if (nil == node)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"#2 %@ - %@", [updateError localizedDescription], [blockError localizedFailureReason]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        XCTAssertTrue([node isKindOfClass:[AlfrescoDocument class]], @"the node should be of type AlfrescoDocument");
                        AlfrescoDocument *updatedDoc = (AlfrescoDocument *)node;
                        XCTAssertTrue([updatedDoc.name isEqualToString:updatedName], @"The name of the document should be %@, but instead we got %@", updatedName, updatedDoc.name);
                        AlfrescoProperty *description = (updatedDoc.properties)[@"cm:description"];
                        AlfrescoProperty *title = (updatedDoc.properties)[@"cm:title"];
                        XCTAssertTrue([description.value isEqualToString:testDescription], @"expected description %@, but got %@", testDescription, description.value);
                        XCTAssertTrue([title.value isEqualToString:testTitle], @"expected title %@, but got %@", testTitle, title.value);
                        [weakDfService deleteNode:node completionBlock:^(BOOL succeeded, NSError *deleteError){
                            if (!succeeded)
                            {
                                self.lastTestSuccessful = NO;
                                self.lastTestFailureMessage = [NSString stringWithFormat:@"#3 %@ - %@", [updateError localizedDescription], [blockError localizedFailureReason]];
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
        } progressBlock:^(unsigned long long bytesTransferred, unsigned long long bytesTotal) {
            // No-op
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testEmptyTitleAndDescriptionProperties
{
    if (self.setUpSuccess)
    {
        NSString *filename = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.testImageName];
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        //        __weak AlfrescoDocumentFolderService *weakSelf = self.dfService;
        [self.dfService
         createDocumentWithName:filename
         inParentFolder:self.testDocFolder
         contentFile:self.testImageFile
         properties:nil
         completionBlock:^(AlfrescoDocument *doc, NSError *error){
             if (nil == doc)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 self.callbackCompleted = YES;
             }
             else
             {
                 [self.dfService retrieveNodeWithIdentifier:doc.identifier completionBlock:^(AlfrescoNode *node, NSError *propError) {
                     if (nil == node)
                     {
                         self.lastTestSuccessful = NO;
                         self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [propError localizedDescription], [propError localizedFailureReason]];
                         self.callbackCompleted = YES;
                     }
                     else
                     {
                         XCTAssertTrue([node isKindOfClass:[AlfrescoDocument class]], @"expected AlfrescoDocument");
                         AlfrescoDocument *doc = (AlfrescoDocument *)node;
                         NSString *description = doc.summary;
                         NSString *title = doc.title;
                         XCTAssertNil(description, @"expected description to be NIL");
                         XCTAssertNil(title, @"expected title to be NIL");
                         [self.dfService deleteNode:node completionBlock:^(BOOL succeeded, NSError *deleteError){
                             if (!succeeded)
                             {
                                 self.lastTestSuccessful = NO;
                                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [deleteError localizedDescription], [deleteError localizedFailureReason]];
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
         }
         progressBlock:^(unsigned long long bytesTransferred, unsigned long long total){}];
        
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 @Unique_TCRef 27S1
 @Unique_TCRef 31S1
 @Unique_TCRef 31S3
 */
- (void)testUpdatePropertiesForDocument
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        
        __weak AlfrescoDocumentFolderService *weakDfService = self.dfService;
        
        [self.dfService retrieveContentOfDocument:self.testAlfrescoDocument completionBlock:^(AlfrescoContentFile *contentFile, NSError *error)
         {
             
             if (nil == contentFile)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 self.callbackCompleted = YES;
             }
             else
             {
                 __block NSString *propertyObjectTestValue = @"version-download-test-updated.txt";
                 NSMutableDictionary *propDict = [NSMutableDictionary dictionaryWithCapacity:8];
                 propDict[kCMISPropertyName] = propertyObjectTestValue;
                 propDict[@"cm:description"] = @"updated description";
                 propDict[@"cm:title"] = @"updated title";
                 propDict[@"cm:author"] = @"updated author";
                 
                 [weakDfService updatePropertiesOfNode:self.testAlfrescoDocument properties:propDict completionBlock:^(AlfrescoNode *updatedNode, NSError *error)
                  {
                      
                      if (nil == updatedNode)
                      {
                          self.lastTestSuccessful = NO;
                          self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                      }
                      else
                      {
                          AlfrescoDocument *updatedDocument = (AlfrescoDocument *)updatedNode;
                          XCTAssertNotNil(updatedDocument.identifier, @"document identifier should be filled");
                          XCTAssertTrue([updatedDocument.name isEqualToString:@"version-download-test-updated.txt"], @"name should be updated");
                          XCTAssertTrue(updatedDocument.contentLength > 100, @"expected content to be filled");
                          XCTAssertTrue([updatedDocument.type isEqualToString:@"cm:content"], @"type should be cm:content, but is %@", updatedDocument.type);
                          
                          // check the updated properties
                          NSDictionary *updatedProps = updatedDocument.properties;
                          AlfrescoProperty *updatedDescription = updatedProps[@"cm:description"];
                          AlfrescoProperty *updatedTitle = updatedProps[@"cm:title"];
                          AlfrescoProperty *updatedAuthor = updatedProps[@"cm:author"];
                          XCTAssertTrue([updatedDescription.value isEqualToString:@"updated description"], @"Updated description is incorrect");
                          XCTAssertTrue([updatedTitle.value isEqualToString:@"updated title"], @"Updated title is incorrect");
                          XCTAssertTrue([updatedAuthor.value isEqualToString:@"updated author"], @"Updated author is incorrect");
                          
                          id propertyValue = [updatedDocument propertyValueWithName:kCMISPropertyName];
                          if ([propertyValue isKindOfClass:[NSString class]])
                          {
                              NSString *testValue = (NSString *)propertyValue;
                              XCTAssertTrue([testValue isEqualToString:propertyObjectTestValue], @"Updated name is incorrect");
                              self.lastTestSuccessful = YES;
                          }
                          else
                          {
                              self.lastTestSuccessful = NO;
                              self.lastTestFailureMessage = [NSString stringWithFormat:@"we expected a String object back from %@",kCMISPropertyName];
                          }
                      }
                      self.callbackCompleted = YES;
                      
                  }];
             }
             
         } progressBlock:^(unsigned long long bytesDownloaded, unsigned long long bytesTotal) {
         }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/**
 @Unique_TCRef 33S1
 @Unique_TCRef 31F1
 @Unique_TCRef 24S0
 */
- (void)testUpdatePropertiesForDocumentNonExisting
{
    if (self.setUpSuccess)
    {
        NSString *filename = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.testImageName];
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:4];
        // provide the objectTypeId so we can specify the cm:author aspect
        props[kCMISPropertyObjectTypeId] = [kCMISPropertyObjectTypeIdValueDocument stringByAppendingString:@",P:cm:titled,P:cm:author"];
        props[@"cm:description"] = @"test description";
        props[@"cm:title"] = @"test title";
        props[@"cm:author"] = @"test author";
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
        [self.dfService createDocumentWithName:filename inParentFolder:self.testDocFolder
                                   contentFile:self.testImageFile
                                    properties:props
                               completionBlock:^(AlfrescoDocument *document, NSError *blockError){
                                   if (nil == document)
                                   {
                                       self.lastTestSuccessful = NO;
                                       self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [blockError localizedDescription], [blockError localizedFailureReason]];
                                       self.callbackCompleted = YES;
                                   }
                                   else
                                   {
                                       XCTAssertNotNil(document.identifier, @"document identifier should be filled");
                                       XCTAssertTrue(document.contentLength > 100, @"expected content to be filled");
                                       
                                       // check the properties were added at creation time
                                       __block NSString *propertyObjectTestValue = filename;
                                       __block NSMutableDictionary *propDict = [NSMutableDictionary dictionaryWithCapacity:8];
                                       //                 [propDict setObject:[kCMISPropertyObjectTypeIdValueDocument stringByAppendingString:@",P:cm:titled,P:cm:author"]
                                       //                              forKey:kCMISPropertyObjectTypeId];
                                       propDict[kCMISPropertyName] = propertyObjectTestValue;
                                       propDict[@"cm:description"] = @"updated description";
                                       propDict[@"cm:title"] = @"updated title";
                                       
                                       
                                       __block AlfrescoDocument *strongDocument = document;
                                       
                                       // delete the test document
                                       [weakService deleteNode:document completionBlock:^(BOOL success, NSError *error)
                                        {
                                            if (!success)
                                            {
                                                self.lastTestSuccessful = NO;
                                                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                                self.callbackCompleted = YES;
                                            }
                                            else
                                            {
                                                [weakService updatePropertiesOfNode:strongDocument properties:propDict completionBlock:^(AlfrescoNode *updatedNode, NSError *error){
                                                    if (nil == updatedNode)
                                                    {
                                                        self.lastTestSuccessful = YES;
                                                    }
                                                    else
                                                    {
                                                        self.lastTestSuccessful = NO;
                                                        self.lastTestFailureMessage = @"We should not be able to update properties for a deleted node";
                                                        
                                                    }
                                                    self.callbackCompleted = YES;
                                                }];
                                            }
                                        }];
                                   }
                               } progressBlock:^(unsigned long long bytesUploaded, unsigned long long bytesTotal){
                               }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
    
}


/*
 @Unique_TCRef 24S1
 */
- (void)testDeleteNode
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        // create a new folder in the repository's root folder so we can delete it
        
        NSString *folderName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:@"RemoteAPIDeleteTest"];
        [self.dfService createFolderWithName:folderName inParentFolder:self.testDocFolder properties:nil
                             completionBlock:^(AlfrescoFolder *folder, NSError *error)
         {
             
             if (nil == folder)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 self.callbackCompleted = YES;
             }
             else
             {
                 XCTAssertNotNil(folder, @"folder should not be nil");
                 XCTAssertTrue([folder.name isEqualToString:folderName], @"folder name should be %@", folderName);
                 
                 [self.dfService deleteNode:folder completionBlock:^(BOOL success, NSError *error)
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
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/**
 @Unique_TCRef 32S0 - 32S2
 @Unique_TCRef 24S0
 */
- (void)testDeleteFolderWithContent
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
        
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:2];
        props[@"cm:description"] = @"test description";
        props[@"cm:title"] = @"test title";
        
        // create a new folder in the repository's root folder
        NSString *folderName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.unitTestFolder];
        [self.dfService createFolderWithName:folderName inParentFolder:self.testDocFolder properties:props
                             completionBlock:^(AlfrescoFolder *unitTestFolder, NSError *error)
         {
             if (nil == unitTestFolder)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 self.callbackCompleted = YES;
             }
             else
             {
                 XCTAssertNotNil(unitTestFolder, @"folder should not be nil");
                 XCTAssertTrue([unitTestFolder.name isEqualToString:folderName], @"folder name should be %@",folderName);
                 NSString *subtestFolder = [AlfrescoBaseTest addTimeStampToFileOrFolderName:@"SomeTestFolder"];
                 [weakService createFolderWithName:subtestFolder inParentFolder:unitTestFolder properties:props completionBlock:^(AlfrescoFolder *internalFolder, NSError *internalError){
                     if (nil == internalFolder)
                     {
                         self.lastTestSuccessful = NO;
                         self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [internalError localizedDescription], [internalError localizedFailureReason]];
                         self.callbackCompleted = YES;
                     }
                     else
                     {
                         [weakService deleteNode:unitTestFolder completionBlock:^(BOOL success, NSError *innerError)
                          {
                              if (!success)
                              {
                                  self.lastTestSuccessful = NO;
                                  self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [innerError localizedDescription], [innerError localizedFailureReason]];
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
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}


/*
 @Unique_TCRef 24S0
 @Unique_TCRef 24F0
 */
- (void)testDeleteNodeNonExisting
{
    if (self.setUpSuccess)
    {
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        // create a new folder in the repository's root folder so we can delete it
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
        
        NSString *folderName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:@"RemoteAPIDeleteTest"];
        [self.dfService createFolderWithName:folderName inParentFolder:self.testDocFolder properties:nil
                             completionBlock:^(AlfrescoFolder *folder, NSError *error)
         {
             
             if (nil == folder)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 self.callbackCompleted = YES;
             }
             else
             {
                 XCTAssertNotNil(folder, @"folder should not be nil");
                 XCTAssertTrue([folder.name isEqualToString:folderName], @"folder name should be %@", folderName);
                 __block AlfrescoFolder *strongFolder = folder;
                 [weakService deleteNode:folder completionBlock:^(BOOL success, NSError *error)
                  {
                      if (!success)
                      {
                          self.lastTestSuccessful = NO;
                          self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                          self.callbackCompleted = YES;
                      }
                      else
                      {
                          [weakService deleteNode:strongFolder completionBlock:^(BOOL success, NSError *error)
                           {
                               if (!success)
                               {
                                   self.lastTestSuccessful = YES;
                               }
                               else
                               {
                                   
                                   self.lastTestSuccessful = NO;
                                   self.lastTestFailureMessage = @"We should not be able to delete a node that is already deleted";
                               }
                               self.callbackCompleted = YES;
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



/*
 @Unique_TCRef 29S2
 @Unique_TCRef 13S0. 
 */
- (void)testThumbnailRenditionImage
{
    if (self.setUpSuccess)
    {
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        //        __weak AlfrescoDocumentFolderService *weakSelf = self.dfService;
        
        // get the children of the repository's root folder
        [self.dfService retrieveChildrenInFolder:self.testDocFolder completionBlock:^(NSArray *array, NSError *error)
         {
             if (nil == array)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 self.callbackCompleted = YES;
             }
             else
             {
                 XCTAssertTrue(array.count > 0, @"Expected folder children but got %i", array.count);
                 XCTAssertTrue([self nodeArray:array containsName:@"Unit Test Subfolder"], @"Folder children should contain 'Unit Test Subfolder'");
                 AlfrescoDocument *testVersionedDoc = nil;
                 for (AlfrescoNode *node in array)
                 {
                     if ([node isKindOfClass:[AlfrescoDocument class]])
                     {
                         NSString *name = node.name;
                         if ([name isEqualToString:@"versioned-quote.txt"])
                         {
                             testVersionedDoc = (AlfrescoDocument *)node;
                             break;
                         }
                         
                     }
                 }
                 if (nil != testVersionedDoc)
                 {
                     [self.dfService retrieveRenditionOfNode:testVersionedDoc renditionName:kAlfrescoThumbnailRendition completionBlock:^(AlfrescoContentFile *contentFile, NSError *error){
                         if (nil == contentFile)
                         {
                             self.lastTestSuccessful = NO;
                             self.lastTestFailureMessage = [NSString stringWithFormat:@"Failed to retrieve thumbnail image. %@ - %@", [error localizedDescription], [error localizedFailureReason]];
                         }
                         else
                         {
                             NSError *fileError = nil;
                             NSDictionary *fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:[contentFile.fileUrl path] error:&fileError];
                             XCTAssertNil(fileError, @"expected no error in getting attributes for file at path %@",[contentFile.fileUrl path]);
                             unsigned long long size = [[fileDict valueForKey:NSFileSize] unsignedLongLongValue];
                             XCTAssertTrue(size > 100, @"data should be filled and more than 100 bytes. Instead we get %llu",size);
                             self.lastTestSuccessful = YES;
                         }
                         self.callbackCompleted = YES;
                     }];
                 }
                 else
                 {
                     self.lastTestSuccessful = NO;
                     self.lastTestFailureMessage = @"Failed to retrieve versioned-quote.txt file.";
                     self.callbackCompleted = YES;
                 }
             }
             //             self.callbackCompleted = YES;
             
         }];
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
        
        /*
         AlfrescoDocument *document = [[AlfrescoDocument alloc] init];
         document.identifier = testNodeRef;
         document.name = @"thumbnail.jpg";
         
         // get thumbnail
         [self.dfService retrieveRenditionOfNode:document renditionName:kAlfrescoThumbnailRendition completionBlock:^(AlfrescoContentFile *contentFile, NSError *error){
         if (nil == contentFile)
         {
         self.lastTestSuccessful = NO;
         self.lastTestFailureMessage = @"Failed to retrieve thumbnail image.";
         }
         else
         {
         NSData *data = [[NSFileManager defaultManager] contentsAtPath:[contentFile.fileUrl path]];
         XCTAssertNotNil(data, @"data should not be nil");
         XCTAssertTrue(contentFile.length > 100, @"data should be filled");
         self.lastTestSuccessful = YES;
         }
         self.callbackCompleted = YES;
         
         }];
         
         [self waitUntilCompleteWithFixedTimeInterval];
         XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
         */
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}
 

/*
 @Unique_TCRef 22S0
 @Unique_TCRef 25S0
 */
- (void)testRetrievePermissionsOfNode
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        [self.dfService retrieveRootFolderWithCompletionBlock:^(AlfrescoFolder *rootFolder, NSError *error)
         {
             if (nil == rootFolder)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 self.callbackCompleted = YES;
             }
             else
             {
                 XCTAssertNotNil(rootFolder,@"root folder should not be nil");
                 self.lastTestSuccessful = YES;
                 [self.dfService retrievePermissionsOfNode:rootFolder completionBlock:^(AlfrescoPermissions *permissions, NSError *error)
                  {
                      if (nil == permissions)
                      {
                          self.lastTestSuccessful = NO;
                          self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                      }
                      else
                      {
                          XCTAssertNotNil(permissions,@"AlfrescoPermissions should not be nil");
                          if(permissions.canAddChildren)
                          {
                              AlfrescoLogDebug(@"Can add children");
                          }
                          else
                          {
                              AlfrescoLogDebug(@"Cannot add children");
                          }
                          if(permissions.canDelete)
                          {
                              AlfrescoLogDebug(@"Can delete");
                          }
                          else
                          {
                              AlfrescoLogDebug(@"Cannot delete");
                          }
                          if(permissions.canEdit)
                          {
                              AlfrescoLogDebug(@"Can edit");
                          }
                          else
                          {
                              AlfrescoLogDebug(@"Cannot edit");
                          }
                          if (permissions.canComment)
                          {
                              AlfrescoLogDebug(@"Can comment");
                          }
                          else
                          {
                              AlfrescoLogDebug(@"Cannot comment");
                          }
                          
                          self.lastTestSuccessful = YES;
                      }
                      self.callbackCompleted = YES;
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


/*
 With the new version of the SDK, we get the permissions of the node directly without making a CMIS call.
 This means, that this test will no longer pass as it relies on the retrievePermissions method to make this CMIS call.
 Instead we need to think about a way of a.) marking/notifying the node that it has been deleted or b.) rely on the developer to clean up after the delete has happened.
 @Unique_TCRef 25F1
 @Unique_TCRef 33S1
 @Unique_TCRef 24S1
- (void)testRetrievePermissionsOfNodeNonExisting
{
    [self runAllSitesTest:^{
        
        NSString *filename = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.testImageName];
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:4];
        // provide the objectTypeId so we can specify the cm:author aspect
        [props setObject:[kCMISPropertyObjectTypeIdValueDocument stringByAppendingString:@",P:cm:titled,P:cm:author"]
                  forKey:kCMISPropertyObjectTypeId];
        [props setObject:@"test description" forKey:@"cm:description"];
        [props setObject:@"test title" forKey:@"cm:title"];
        [props setObject:@"test author" forKey:@"cm:author"];
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
        [self.dfService createDocumentWithName:filename inParentFolder:self.testDocFolder
                                   contentFile:self.testImageFile
                                    properties:props
                               completionBlock:^(AlfrescoDocument *document, NSError *blockError){
                                   if (nil == document)
                                   {
                                       self.lastTestSuccessful = NO;
                                       self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [blockError localizedDescription], [blockError localizedFailureReason]];
                                       self.callbackCompleted = YES;
                                   }
                                   else
                                   {
                                       XCTAssertNotNil(document.identifier, @"document identifier should be filled");
                                       XCTAssertTrue(document.contentLength > 100, @"expected content to be filled");
                                       
                                                                              
                                       // delete the test document
                                       [weakService deleteNode:document completionBlock:^(BOOL success, NSError *error)
                                        {
                                            if (!success)
                                            {
                                                self.lastTestSuccessful = NO;
                                                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                                self.callbackCompleted = YES;
                                            }
                                            else
                                            {
                                                [weakService retrievePermissionsOfNode:document
                                                                       completionBlock:^(AlfrescoPermissions *perms, NSError *error){
                                                                           if (nil == perms)
                                                                           {
                                                                               self.lastTestSuccessful = YES;
                                                                           }
                                                                           else
                                                                           {
                                                                               self.lastTestSuccessful = NO;
                                                                               self.lastTestFailureMessage = @"We should not be able to get permissions for a deleted/nonexisting document";
                                                                               
                                                                           }
                                                                           self.callbackCompleted = YES;
                                                                       }];
                                            }
                                        }];
                                   }
                               } progressBlock:^(NSInteger bytesUploaded, NSInteger bytesTotal){
                               }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }];
    
}
 */

- (void)testUpdateImageWithExifData
{
    if (self.setUpSuccess)
    {
        if (!self.isCloud)
        {
            NSString *documentName = @"millenium-dome-exif.jpg";
            
            self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
            
            __weak AlfrescoDocumentFolderService *weakFolderService = self.dfService;
            
            [self.dfService retrieveNodeWithFolderPath:documentName relativeToFolder:self.testDocFolder completionBlock:^(AlfrescoNode *node, NSError *error){
                
                if (node == nil)
                {
                    self.lastTestSuccessful = NO;
                    self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                    self.callbackCompleted = YES;
                }
                else
                {
                    XCTAssertNotNil(node, @"document node should not be nil");
                    XCTAssertTrue([node.name isEqualToString:documentName], @"Document name is not the same as requested. We expected %@, but got %@", documentName, node.name);
                    
                    XCTAssertNotNil(node.identifier, @"The identifier of the node should not be nil");
                    XCTAssertNotNil(node.name, @"The name of the node should not be nil");
                    XCTAssertNotNil(node.title, @"The title should not be nil");
                    XCTAssertTrue(node.isDocument, @"The node retrieved should be a document");
                    XCTAssertFalse(node.isFolder, @"The node retrieved should not be a folder");
                    XCTAssertNotNil(node.properties, @"The node properties should not be nil");
                    XCTAssertNotNil(node.aspects, @"The node aspects should not be nil");
                    XCTAssertNotNil(node.createdAt, @"The creation date/time should not be nil");
                    
                    // generate randomness
                    NSDate *dateTimeOriginal = [NSDate date];
                    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:dateTimeOriginal];
                    NSInteger day = [components day];
                    NSInteger month = [components month];
                    NSInteger year = [components year];
                    NSInteger hour = [components hour];
                    NSInteger minute = [components minute];
                    NSInteger second = [components second];
                    NSNumber *imagePixelXDimension = @(arc4random()%512);
                    NSNumber *imagePixelYDimension = @(arc4random()%382);
                    NSDecimalNumber *imageExposureTime =[NSDecimalNumber decimalNumberWithDecimal:[@((arc4random()%100)/100.0) decimalValue]];
                    NSDecimalNumber *imageFNumber = [NSDecimalNumber decimalNumberWithDecimal:[@((arc4random()%100)/100.0) decimalValue]];
                    NSNumber *imageFlash = @YES;
                    NSDecimalNumber *imageFocalLength = [NSDecimalNumber decimalNumberWithDecimal:[@((arc4random()%100)/100.0) decimalValue]];
                    NSString *imageISOSpeedRating = [NSString stringWithFormat:@"ISO Setting %i", arc4random()%2000];
                    NSString *imageManufacturer = [NSString stringWithFormat:@"Nikon %i", arc4random()%1000];
                    NSString *imageModel = [NSString stringWithFormat:@"D Series %i", arc4random()%999];;
                    NSString *imageSoftware = [NSString stringWithFormat:@"Photoshop %i", arc4random()%10];;
                    NSNumber *imageOrientation = @(arc4random()%1);
                    NSNumber *imageXResolution = @(arc4random()%512);
                    NSNumber *imageYResolution = @(arc4random()%382);
                    NSString *imageResolutionUnit = [NSString stringWithFormat:@"ISO Setting %i", arc4random()%5000];;
                    
                    // create property
                    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                    properties[kCMISPropertyObjectTypeId] = [kCMISPropertyObjectTypeIdValueDocument stringByAppendingString:@",P:cm:titled,P:cm:author,P:exif:exif"];
                    // exif
                    properties[@"exif:dateTimeOriginal"] = dateTimeOriginal;
                    properties[@"exif:pixelXDimension"] = imagePixelXDimension;
                    properties[@"exif:pixelYDimension"] = imagePixelYDimension;
                    properties[@"exif:exposureTime"] = imageExposureTime;
                    properties[@"exif:fNumber"] = imageFNumber;
                    properties[@"exif:flash"] = imageFlash;
                    properties[@"exif:focalLength"] = imageFocalLength;
                    properties[@"exif:isoSpeedRatings"] = imageISOSpeedRating;
                    properties[@"exif:manufacturer"] = imageManufacturer;
                    properties[@"exif:model"] = imageModel;
                    properties[@"exif:software"] = imageSoftware;
                    properties[@"exif:orientation"] = imageOrientation;
                    properties[@"exif:xResolution"] = imageXResolution;
                    properties[@"exif:yResolution"] = imageYResolution;
                    properties[@"exif:resolutionUnit"] = imageResolutionUnit;
                    
                    [weakFolderService updatePropertiesOfNode:node properties:properties completionBlock:^(AlfrescoNode *modifiedNode, NSError *modifiedError) {
                        if (modifiedNode == nil || modifiedError != nil) {
                            self.lastTestSuccessful = NO;
                            self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [modifiedError localizedDescription], [modifiedError localizedFailureReason]];
                            self.callbackCompleted = YES;
                        }
                        else
                        {
                            XCTAssertNotNil(modifiedNode, @"document node should not be nil");
                            XCTAssertTrue([modifiedNode.name isEqualToString:documentName], @"Modified node name is not the same as requested. We expected %@ but got %@", documentName, modifiedNode.name);
                            
                            // check the properties were changed
                            NSDictionary *modifiedProperties = modifiedNode.properties;
                            
                            AlfrescoProperty *modifiedDateTimeOriginal = modifiedProperties[@"exif:dateTimeOriginal"];
                            AlfrescoProperty *modifiedImagePixelXDimension = modifiedProperties[@"exif:pixelXDimension"];
                            AlfrescoProperty *modifiedImagePixelYDimension = modifiedProperties[@"exif:pixelYDimension"];
                            AlfrescoProperty *modifiedImageExposureTime = modifiedProperties[@"exif:exposureTime"];
                            AlfrescoProperty *modifiedImageFNumber = modifiedProperties[@"exif:fNumber"];
                            AlfrescoProperty *modifiedImageFlash = modifiedProperties[@"exif:flash"];
                            AlfrescoProperty *modifiedImageFocalLength = modifiedProperties[@"exif:focalLength"];
                            AlfrescoProperty *modifiedImageISOSpeedRating= modifiedProperties[@"exif:isoSpeedRatings"];
                            AlfrescoProperty *modifiedImageManufacturer = modifiedProperties[@"exif:manufacturer"];
                            AlfrescoProperty *modifiedImageModel = modifiedProperties[@"exif:model"];
                            AlfrescoProperty *modifiedImageSoftware = modifiedProperties[@"exif:software"];
                            AlfrescoProperty *modifiedImageOrientation = modifiedProperties[@"exif:orientation"];
                            AlfrescoProperty *modifiedImageXResolution = modifiedProperties[@"exif:xResolution"];
                            AlfrescoProperty *modifiedImageYResolution = modifiedProperties[@"exif:yResolution"];
                            AlfrescoProperty *modifiedImageResolutionUnit = modifiedProperties[@"exif:resolutionUnit"];
                            
                            //exif
                            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:modifiedDateTimeOriginal.value];
                            NSInteger modifiedDay = [components day];
                            NSInteger modifiedMonth = [components month];
                            NSInteger modifiedYear = [components year];
                            NSInteger modifiedHour = [components hour];
                            NSInteger modifiedMinute = [components minute];
                            NSInteger modifiedSecond = [components second];
                            XCTAssertTrue(modifiedDay == day, @"Day: modified %ld differs from original %ld", (long)modifiedDay, (long)day);
                            XCTAssertTrue(modifiedMonth == month, @"Month: modified %ld differs from original %ld", (long)modifiedMonth, (long)month);
                            XCTAssertTrue(modifiedYear == year, @"Year: modified %ld differs from original %ld", (long)modifiedYear, (long)year);
                            XCTAssertTrue(modifiedHour == hour, @"Hour: modified %ld differs from original %ld", (long)modifiedHour, (long)hour);
                            XCTAssertTrue(modifiedMinute == minute, @"Minute: modified %ld differs from original %ld", (long)modifiedMinute, (long)minute);
                            XCTAssertTrue(modifiedSecond == second, @"Second: modified %ld differs from original %ld", (long)modifiedSecond, (long)second);
                            
                            XCTAssertTrue([modifiedImagePixelXDimension.value isEqualToNumber:imagePixelXDimension], @"Pixel X Dimension: modified %@ differs from original %@", modifiedImagePixelXDimension.value, imagePixelXDimension);
                            XCTAssertTrue([modifiedImagePixelYDimension.value isEqualToNumber:imagePixelYDimension], @"Pixel Y Dimension: modified %@ differs from original %@", modifiedImagePixelYDimension.value, imagePixelYDimension);
                            XCTAssertTrue([modifiedImageExposureTime.value isEqualToNumber:imageExposureTime], @"Exposure Time: modified %@ differs from original %@", modifiedImageExposureTime.value, imageExposureTime);
                            XCTAssertTrue([modifiedImageFNumber.value isEqualToNumber:imageFNumber], @"F Number: modified %@ differs from original %@", modifiedImageFNumber.value, imageFNumber);
                            XCTAssertTrue([modifiedImageFlash.value isEqualToNumber:imageFlash], @"Flash: modified %@ differs from original %@", BOOL_TO_STRING(modifiedImageFlash.value), BOOL_TO_STRING(imageFocalLength));
                            XCTAssertTrue([modifiedImageFocalLength.value isEqualToNumber:imageFocalLength], @"Focal Length: modified %@ differs from original %@", modifiedImageFocalLength.value, imageFocalLength);
                            XCTAssertTrue([modifiedImageISOSpeedRating.value isEqualToString:imageISOSpeedRating], @"ISO Speed Rating: modified %@ differs from original %@", modifiedImageISOSpeedRating.value, imageISOSpeedRating);
                            XCTAssertTrue([modifiedImageManufacturer.value isEqualToString:imageManufacturer], @"Manufacturer: modified %@ differs from original %@", modifiedImageManufacturer.value, imageManufacturer);
                            XCTAssertTrue([modifiedImageModel.value isEqualToString:imageModel], @"Model: modified %@ differs from original %@", modifiedImageModel.value, imageModel);
                            XCTAssertTrue([modifiedImageSoftware.value isEqualToString:imageSoftware], @"Software: modified %@ differs from original %@", modifiedImageSoftware.value, imageSoftware);
                            XCTAssertTrue([modifiedImageOrientation.value isEqualToNumber:imageOrientation], @"Orientation: modified %@ differs from original %@", modifiedImageOrientation.value, imageOrientation);
                            XCTAssertTrue([modifiedImageXResolution.value isEqualToNumber:imageXResolution], @"X Resolution: modified %@ differs from original %@", modifiedImageXResolution.value, imageXResolution);
                            XCTAssertTrue([modifiedImageYResolution.value isEqualToNumber:imageYResolution], @"Y Resolution: modified %@ differs from original %@", modifiedImageYResolution.value, imageYResolution);
                            XCTAssertTrue([modifiedImageResolutionUnit.value isEqualToString:imageResolutionUnit], @"Resolution Unit: modified %@ differs from original %@", modifiedImageResolutionUnit.value, imageResolutionUnit);
                            
                            self.lastTestSuccessful = YES;
                        }
                        self.callbackCompleted = YES;
                    }];
                    
                }
                
            }];
            
            [self waitUntilCompleteWithFixedTimeInterval];
            XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
        }
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}


- (void)testListingContextAfterInstantiation
{
    if (self.setUpSuccess)
    {
        
        AlfrescoListingContext *listingContext = nil;
        
        listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:10 skipCount:3];
        XCTAssertTrue(listingContext.maxItems == 10, @"Expected maxItems to be 10");
        XCTAssertTrue(listingContext.skipCount == 3, @"Expected the skip count to be 3");
        
        listingContext = [[AlfrescoListingContext alloc] initWithSortProperty:kAlfrescoSortByDescription sortAscending:NO];
        XCTAssertTrue(listingContext.sortProperty == kAlfrescoSortByDescription, @"Expected the sort property to be set to sort by description at option");
        XCTAssertFalse(listingContext.sortAscending, @"Expected the sort by ascending property to be set to no");
        
        listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:25 skipCount:2 sortProperty:kAlfrescoSortByCreatedAt sortAscending:YES];
        XCTAssertTrue(listingContext.maxItems == 25, @"Expected maxItems to be 25");
        XCTAssertTrue(listingContext.skipCount == 2, @"Expected the skip count to be 2");
        XCTAssertTrue(listingContext.sortProperty == kAlfrescoSortByCreatedAt, @"Expected the sort property to be set to sort by created at option");
        XCTAssertTrue(listingContext.sortAscending, @"Expected the sort by ascending property to be set to yes");
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}


- (void)testAspectPrefix
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        NSString *filename = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.testImageName];
        NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:4];
        properties[kCMISPropertyObjectTypeId] = [kCMISPropertyObjectTypeIdValueDocument stringByAppendingString:@",P:cm:titled,P:cm:author"];
        properties[@"cm:description"] = @"test description";
        properties[@"cm:title"] = @"test title";
        properties[@"cm:author"] = @"test author";
        
        __weak AlfrescoDocumentFolderService *weakDfService = self.dfService;
        
        [self.dfService createDocumentWithName:filename inParentFolder:self.testDocFolder contentFile:self.testImageFile properties:properties completionBlock:^(AlfrescoDocument *document, NSError *error) {
            
            if (document == nil && error != nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(document, @"The created document is nil");
                NSArray *documentAspects = document.aspects;
                
                for (NSString *aspectName in documentAspects)
                {
                    XCTAssertFalse([aspectName hasPrefix:@"P:"], @"The aspect %@ has a prefix of P: which is not as expected", aspectName);
                }
                
                XCTAssertTrue([document hasAspectWithName:@"cm:titled"], @"The document should have the title aspect associated to it");
                
                [weakDfService deleteNode:document completionBlock:^(BOOL success, NSError *error) {
                    
                    if (success)
                    {
                        self.lastTestSuccessful = YES;
                    }
                    else
                    {
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                        self.lastTestSuccessful = NO;
                    }
                    self.callbackCompleted = YES;
                }];
            }
            
        } progressBlock:^(unsigned long long bytesTransferred, unsigned long long totalBytes) {
                                     
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 @Unique_TCRef 25S2
 @Unique_TCRef 32S9
 */
- (void)testRetrievePermissionsForFolder
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
        
        NSString *folderName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.unitTestFolder];
        [self.dfService createFolderWithName:folderName inParentFolder:self.testDocFolder properties:nil completionBlock:^(AlfrescoFolder *folder, NSError *error) {
            
            if (folder == nil || error != nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(folder, @"The folder is nil");
                
                [weakService retrievePermissionsOfNode:folder completionBlock:^(AlfrescoPermissions *permissions, NSError *error) {
                    
                    if (permissions == nil && error != nil)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        XCTAssertTrue(permissions.canAddChildren, @"Expected to be able to add children to folder");
                        XCTAssertTrue(permissions.canComment, @"Expected to be able to comment on the folder");
                        XCTAssertTrue(permissions.canDelete, @"Expected to be able to delete the folder");
                        XCTAssertTrue(permissions.canEdit, @"Expected to be able to edit the folder");
                        
                        [weakService deleteNode:folder completionBlock:^(BOOL success, NSError *error) {
                            
                            if (success)
                            {
                                self.lastTestSuccessful = YES;
                                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                            }
                            else
                            {
                                self.lastTestSuccessful = NO;
                            }
                            
                            self.callbackCompleted = YES;
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

/*
 @Unique_TCRef 25S2
 */
- (void)testRetrievePermissionsForDocument
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
        NSString *folderPath = [self.testFolderPathName stringByAppendingPathComponent:self.fixedFileName];
        
        // Running as admin, read and write access should be true
        [self.dfService retrieveNodeWithFolderPath:folderPath completionBlock:^(AlfrescoNode *documentNode, NSError *error) {
            
            if (documentNode == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(documentNode, @"Document node is nil");
                XCTAssertTrue(documentNode.isDocument, @"Expected the node returned to be a document");
                
                [weakService retrievePermissionsOfNode:documentNode completionBlock:^(AlfrescoPermissions *permissions, NSError *error) {
                    
                    if (permissions == nil && error != nil)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        XCTAssertTrue(permissions.canAddChildren, @"Expected to be able to add children to folder");
                        XCTAssertTrue(permissions.canComment, @"Expected to be able to comment on the folder");
                        XCTAssertTrue(permissions.canDelete, @"Expected to be able to delete the folder");
                        XCTAssertTrue(permissions.canEdit, @"Expected to be able to edit the folder");
                        
                        self.lastTestSuccessful = YES;
                    }
                    self.callbackCompleted = YES;
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

/*
 @Unique_TCRef 14S5
 */
- (void)testRetrieveChildrenInFolderWithListingContext
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        __weak AlfrescoDocumentFolderService *weakDfService = self.dfService;
        
        [self.dfService retrieveChildrenInFolder:self.testDocFolder completionBlock:^(NSArray *entireArray, NSError *entireError) {
            
            if (entireArray == nil || entireError != nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [entireError localizedDescription], [entireError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(entireArray, @"Expetced array to not be nil");
                XCTAssertTrue([entireArray count] >= 5, @"Expected the entire array to return more than or equal to 5 items, but instead got back %i", [entireArray count]);
                
                AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:3 skipCount:2];
                
                [weakDfService retrieveChildrenInFolder:self.testDocFolder listingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
                    
                    if (pagingResult == nil || error != nil)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [entireError localizedDescription], [entireError localizedFailureReason]];
                    }
                    else
                    {
                        XCTAssertNotNil(pagingResult.objects, @"Expecting the objects array not to be nil");
                        XCTAssertTrue([pagingResult.objects count] == 3, @"Expected the results of the objects array to contain 3 items, instead got back %i", [pagingResult.objects count]);
                        
                        int matchedNodes = 0;
                        
                        for (int i = 0; i < [pagingResult.objects count]; i++)
                        {
                            AlfrescoNode *pagedNode = (AlfrescoNode *)(pagingResult.objects)[i];
                            for (int j = 0; j < entireArray.count; j++)
                            {
                                AlfrescoNode *listedNode = (AlfrescoNode *)entireArray[j];
                                if ([pagedNode.identifier isEqualToString:listedNode.identifier])
                                {
                                    matchedNodes++;
                                }
                            }
                        }
                        
                        XCTAssertTrue(matchedNodes == pagingResult.objects.count, @"We expected to match the number of paged nodes with the original list. Expected %d but got %d", pagingResult.objects.count, matchedNodes);
                        
                        self.lastTestSuccessful = YES;
                    }
                    self.callbackCompleted = YES;
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

/*
 @Unique_TCRef 23S1
 */
- (void)testRetrieveRootFolderParentFolder
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        AlfrescoFolder *topFolder = self.currentSession.rootFolder;
        
        [self.dfService retrieveParentFolderOfNode:topFolder completionBlock:^(AlfrescoFolder *parentFolder, NSError *error) {
            
            if (parentFolder != nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = @"We have a valid parent folder, where in fact we shouldn't have as we should be in Root.";
            }
            else
            {
                XCTAssertNil(parentFolder, @"Expected the parent folder of the root folder to be nil");
                XCTAssertNotNil(error, @"Expected an error to be thrown");
                self.lastTestSuccessful = YES;
            }
            
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 @Unique_TCRef 27S6
 */
- (void)testRetrieveContentOfDocumentWithDoubleByteCharacters
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        __weak AlfrescoDocumentFolderService *weakDfService = self.dfService;
        
        [self.dfService retrieveContentOfDocument:self.testAlfrescoDocument completionBlock:^(AlfrescoContentFile *contentFile, NSError *error){
            
            if (contentFile == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"#1 %@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(contentFile,@"created content file should not be nil");
                NSError *fileError = nil;
                XCTAssertNil(fileError, @"expected no error in getting file attributes for contentfile at path %@",[contentFile.fileUrl path]);
                NSError *readError = nil;
                
                __block NSString *stringContent = [NSString stringWithContentsOfFile:[contentFile.fileUrl path] encoding:NSUTF8StringEncoding error:&readError];
                
                if (stringContent == nil)
                {
                    self.lastTestSuccessful = NO;
                    self.lastTestFailureMessage = [NSString stringWithFormat:@"#2 %@ - %@", [readError localizedDescription], [readError localizedFailureReason]];
                    self.callbackCompleted = YES;
                }
                else
                {
                    __block NSString *updatedContent = [NSString stringWithFormat:@"%@ - and we added some double byte characters ありがと　にほんご", stringContent];
                    NSData *data = [updatedContent dataUsingEncoding:NSUTF8StringEncoding];
                    __block AlfrescoContentFile *updatedContentFile = [[AlfrescoContentFile alloc] initWithData:data mimeType:contentFile.mimeType];

                    [weakDfService updateContentOfDocument:self.testAlfrescoDocument contentFile:updatedContentFile completionBlock:^(AlfrescoDocument *updatedDocument, NSError *error) {
                        if (updatedDocument == nil)
                        {
                            self.lastTestSuccessful = NO;
                            self.lastTestFailureMessage = [NSString stringWithFormat:@"#3 %@ - %@", [error localizedDescription], [error localizedFailureReason]];
                            self.callbackCompleted = YES;
                        }
                        else
                        {
                            XCTAssertNotNil(updatedDocument.identifier, @"Updated document identifier is nil");
                            XCTAssertTrue(updatedDocument.contentLength > 100, @"Content length is not > 100 - actual value %llu", updatedDocument.contentLength);
                            
                            [weakDfService retrieveContentOfDocument:updatedDocument completionBlock:^(AlfrescoContentFile *checkContentFile, NSError *error){
                                if (checkContentFile == nil)
                                {
                                    self.lastTestSuccessful = NO;
                                    self.lastTestFailureMessage = [NSString stringWithFormat:@"#4 %@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                }
                                else
                                {
                                    NSError *fileError = nil;
                                    NSDictionary *fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:[checkContentFile.fileUrl path] error:&fileError];
                                    XCTAssertNil(fileError, @"File attributes request for content file at path %@ returned error %@ - %@", [checkContentFile.fileUrl path], [fileError localizedDescription], [fileError localizedFailureReason]);
                                    unsigned long long size = [[fileDict valueForKey:NSFileSize] unsignedLongLongValue];
                                    XCTAssertTrue(size > 0, @"checkContentFile length should be > 0 - actual value %llu", size);
                                    NSError *checkError = nil;
                                    NSString *checkContentString = [NSString stringWithContentsOfFile:[checkContentFile.fileUrl path] encoding:NSUTF8StringEncoding error:&checkError];
                                    if (checkContentString == nil)
                                    {
                                        self.lastTestSuccessful = NO;
                                        self.lastTestFailureMessage = [NSString stringWithFormat:@"#5 %@ - %@", [checkError localizedDescription], [checkError localizedFailureReason]];
                                    }
                                    else
                                    {
                                        XCTAssertTrue([checkContentString isEqualToString:updatedContent],@"Expected content [%@] differs actual string [%@]", updatedContent, checkContentString);
                                        self.lastTestSuccessful = YES;
                                    }
                                    
                                }
                                self.callbackCompleted = YES;
                            } progressBlock:^(unsigned long long bytesTransferred, unsigned long long bytesTotal) {
                                AlfrescoLogDebug(@"#3 Progress %llu/%llu", bytesTransferred, bytesTotal);
                            }];
                        }
                    } progressBlock:^(unsigned long long bytesTransferred, unsigned long long bytesTotal) {
                        AlfrescoLogDebug(@"#2 Progress %llu/%llu", bytesTransferred, bytesTotal);
                    }];
                }
            }
        } progressBlock:^(unsigned long long bytesTransferred, unsigned long long bytesTotal) {
            AlfrescoLogDebug(@"#1 Progress %llu/%llu", bytesTransferred, bytesTotal);
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }

}

/*
 @Unique_TCRef 31S6
 */
- (void)testUpdatePropertiesOfFolderNode
{
    if (self.setUpSuccess)
    {
        NSString *originalDescriptionString = @"Original Description";
        NSString *originalTitleString = @"Original Title";
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"ddMMyyyyHHmmss"];
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        
        NSString *updatedDescriptionString = [NSString stringWithFormat:@"Updated Description %@", dateString];
        NSString *updatedTitleString = [NSString stringWithFormat:@"Updated Title %@", dateString];
        NSString *updatedNameString = [NSString stringWithFormat:@"Updated Name %@", dateString];
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        NSMutableDictionary *originalProperties = [NSMutableDictionary dictionary];
        originalProperties[@"cm:description"] = originalDescriptionString;
        originalProperties[@"cm:title"] = originalTitleString;
        
        //        __weak AlfrescoDocumentFolderServiceTest *weakSelf = self;
        
        NSString *folderName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.unitTestFolder];
        [self.dfService createFolderWithName:folderName inParentFolder:self.testDocFolder properties:originalProperties completionBlock:^(AlfrescoFolder *folder, NSError *error) {
            
            if (folder == nil || error != nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(folder, @"Expected the folder not to be nil");
                XCTAssertNotNil(folder.properties, @"The folders properties are nil");
                
                NSDictionary *folderProperties = folder.properties;
                AlfrescoProperty *originalDescription = folderProperties[@"cm:description"];
                AlfrescoProperty *originalTitle = folderProperties[@"cm:title"];
                AlfrescoProperty *originalName = folderProperties[@"cmis:name"];
                
                XCTAssertNotNil(originalDescription, @"Expected the original description not to be nil");
                XCTAssertNotNil(originalTitle, @"Expected the original title not to be nil");
                XCTAssertNotNil(originalName, @"Expected the original name not to be nil");
                
                NSMutableDictionary *newFolderProperties = [NSMutableDictionary dictionary];
                newFolderProperties[@"cm:description"] = updatedDescriptionString;
                newFolderProperties[@"cm:title"] = updatedTitleString;
                newFolderProperties[@"cmis:name"] = updatedNameString;
                
                [self.dfService updatePropertiesOfNode:folder properties:newFolderProperties completionBlock:^(AlfrescoNode *node, NSError *err) {
                    
                    if (node == nil || err != nil)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                    }
                    else
                    {
                        XCTAssertNotNil(node, @"Expected the returned node not to be nil");
                        XCTAssertNotNil(node.properties, @"Expected the returned nodes property not to be nil");
                        
                        NSDictionary *nodeProperties = node.properties;
                        AlfrescoProperty *modifiedDescription = nodeProperties[@"cm:description"];
                        AlfrescoProperty *modifiedTitle = nodeProperties[@"cm:title"];
                        AlfrescoProperty *modifiedName = nodeProperties[@"cmis:name"];
                        
                        XCTAssertNotNil(modifiedDescription, @"Expected the modified description not to be nil");
                        XCTAssertNotNil(modifiedTitle, @"Expected the modified title not to be nil");
                        XCTAssertNotNil(modifiedName, @"Expected the modified name not to be nil");
                        
                        XCTAssertTrue([modifiedDescription.value isEqualToString:updatedDescriptionString], @"Modified description was expected to be %@", updatedDescriptionString);
                        XCTAssertTrue([modifiedTitle.value isEqualToString:updatedTitleString], @"Modified title was expected to be %@", updatedTitleString);
                        XCTAssertTrue([modifiedName.value isEqualToString:updatedNameString], @"Modified name was expected to be %@", updatedNameString);
                        
                        self.lastTestSuccessful = YES;
                    }
                    
                    [self.dfService deleteNode:folder completionBlock:^(BOOL success, NSError *error) {
                        
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


- (void)testRetrieveNodeWithFolderPathRelativeToFolder
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        [self.dfService retrieveNodeWithFolderPath:self.fixedFileName relativeToFolder:self.currentRootFolder completionBlock:^(AlfrescoNode *node, NSError *error){
            if (nil == node)
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
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 @Unique_TCRef 29F3
- (void)testRetrieveRenditionOfDocumentNodeWithInvalidRenditionName
{
    [self runAllSitesTest:^{

        NSString *invalidRenditionName = @"InvalidRenditionName";
       
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        [self.dfService retrieveRenditionOfNode:self.testAlfrescoDocument renditionName:invalidRenditionName completionBlock:^(AlfrescoContentFile *fileContent, NSError *error) {
            
            if (fileContent)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                XCTAssertNotNil(error, @"Error should occur for the invalid rendition name");
                
                self.lastTestSuccessful = YES;
            }
            
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }];
}
 */

/*
 @Unique_TCRef 29F4
 */
- (void)testRetrieveRenditionOfFolderNodeWithValidRenditionName
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        [self.dfService retrieveRenditionOfNode:self.testDocFolder renditionName:kAlfrescoThumbnailRendition completionBlock:^(AlfrescoContentFile *fileContent, NSError *error) {
            
            if (fileContent)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                XCTAssertNotNil(error, @"Error should occur whilst trying to get a rendition of a folder using doclib");
                
                self.lastTestSuccessful = YES;
            }
            
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

// REMOVED DUE TO ERROR SEEN ONLY WHEN RUNNING ON SERVER 4.1
///*
// @Unique_TCRef 31F4
// */
//- (void)testUpdatePropertiesOfNodeToPreExistingName
//{
//    // Working on local server, however, removal of the test document fails when testing against 4.x server on amazon servers
//    [self runAllSitesTest:^{
//        
//        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
//        
//        __weak AlfrescoDocumentFolderService *weakFolderService = self.dfService;
//                
//        [self.dfService retrieveNodeWithFolderPath:@"Sites" relativeToFolder:self.testDocFolder completionBlock:^(AlfrescoNode *node, NSError *error) {
//            
//            if (node == nil)
//            {
//                self.lastTestSuccessful = NO;
//                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
//            }
//            else
//            {
//                XCTAssertNotNil(node, @"The alfresco node should be returned");
//                
//                NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
//                [properties setObject:self.fixedFileName forKey:@"cmis:name"];
//                
//                [weakFolderService updatePropertiesOfNode:node properties:properties completionBlock:^(AlfrescoNode *updateNode, NSError *updateError) {
//                    
//                    if (updateError == nil)
//                    {
//                        self.lastTestSuccessful = NO;
//                    }
//                    else
//                    {
//                        XCTAssertNotNil(updateError, @"Expected an error to occur when trying to rename the node to and existing name");
//                        XCTAssertFalse([updateNode.name isEqualToString:self.fixedFileName], @"The node should not have been updated to the existing node's name");
//                        
//                        self.lastTestSuccessful = YES;
//                    }
//                    self.callbackCompleted = YES;
//                }];
//            }
//        }];
//        
//        [self waitUntilCompleteWithFixedTimeInterval];
//        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
//    }];
//}

// REMOVED DUE TO ERROR SEEN ONLY WHEN RUNNING ON SERVER 4.1
///*
// @Unique_TCRef 31F5
// */
//- (void)testUpdatePropertiesOfNodeWithInvalidName
//{
//    // Working on local server, however, removal of the test document fails when testing against 4.x server on amazon servers
//    [self runAllSitesTest:^{
//        
//        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
//        
//        __weak AlfrescoDocumentFolderService *weakFolderService = self.dfService;
//        
//        [self.dfService retrieveNodeWithFolderPath:@"Sites" relativeToFolder:self.testDocFolder completionBlock:^(AlfrescoNode *node, NSError *error) {
//            
//            if (node == nil)
//            {
//                self.lastTestSuccessful = NO;
//                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
//            }
//            else
//            {
//                XCTAssertNotNil(node, @"An Alfresco node should have been returned");
//                
//                NSString *invalidName = @"Invalid*";
//                
//                NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
//                [properties setObject:invalidName forKey:@"cmis:name"];
//                
//                [weakFolderService updatePropertiesOfNode:node properties:properties completionBlock:^(AlfrescoNode *updateNode, NSError *updateError) {
//                    
//                    if (updateError == nil)
//                    {
//                        self.lastTestSuccessful = NO;
//                    }
//                    else
//                    {
//                        XCTAssertNotNil(updateError, @"Expected an error to occur when trying to rename the node to an invalid name");
//                        XCTAssertFalse([updateNode.name isEqualToString:invalidName], @"The node should not have been updated to the invalid name");
//                        
//                        self.lastTestSuccessful = YES;
//                    }
//                    self.callbackCompleted = YES;
//                }];
//            }
//        }];
//        
//        [self waitUntilCompleteWithFixedTimeInterval];
//        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
//    }];
//}

// REMOVED DUE TO ERROR SEEN RELATED TO MOBSDK-466
/*
 @Unique_TCRef 32F4
 */
//- (void)testCreateDuplicateFolderName
//{
//    [self runAllSitesTest:^{
//        
//        NSString *folderName = [self addTimeStampToFileOrFolderName:self.unitTestFolder];
//        
//        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
//        
//        __weak AlfrescoDocumentFolderService *weakFolderService = self.dfService;
//        
//        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
//        [properties setObject:@"test description" forKey:@"cm:description"];
//        [properties setObject:@"test title" forKey:@"cm:title"];
//        [properties setObject:folderName forKey:@"cmis:name"];
//        
//        // create a new folder in the repository's root folder
//        [self.dfService createFolderWithName:folderName inParentFolder:self.testDocFolder properties:properties completionBlock:^(AlfrescoFolder *folder, NSError *error) {
//            
//            if (folder == nil)
//            {
//                self.lastTestSuccessful = NO;
//                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
//                self.callbackCompleted = YES;
//            }
//            else
//            {
//                XCTAssertNil(error, @"Error should not have occured trying to create the folder the first time");
//                
//                NSMutableDictionary *props = [NSMutableDictionary dictionary];
//                [props setObject:folderName forKey:@"cmis:name"];
//                
//                // attempt to create the folder again
//                [weakFolderService createFolderWithName:folderName inParentFolder:self.testDocFolder properties:props completionBlock:^(AlfrescoFolder *folder2, NSError *error2) {
//                    
//                    if (error2 == nil)
//                    {
//                        self.lastTestSuccessful = NO;
//                        self.callbackCompleted = YES;
//                    }
//                    else
//                    {
//                        XCTAssertNotNil(error2, @"Trying to create another folder with the same name should produce an error");
//                        
//                        // delete the orginal we created - cleanup
//                        [weakFolderService deleteNode:folder completionBlock:^(BOOL succeeded, NSError *deleteError) {
//                            
//                            XCTAssertNil(deleteError, @"Error occured trying to delete the folder node");
//                            
//                            self.lastTestSuccessful = succeeded;
//                            
//                            self.callbackCompleted = YES;
//                        }];
//                    }
//                }];
//            }
//            
//        }];
//        
//        [self waitUntilCompleteWithFixedTimeInterval];
//        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
//    }];
//}

/*
 @Unique_TCRef 33F4
 */
- (void)testCreateDuplicateDocumentName
{
    if (self.setUpSuccess)
    {
        NSString *duplicateFileName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:@"Duplicate.jpg"];
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        __weak AlfrescoDocumentFolderService *weakFolderService = self.dfService;
        
        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        properties[@"cm:description"] = @"test description";
        properties[@"cm:title"] = @"test title";
        properties[@"cmis:name"] = duplicateFileName;
        
        [self.dfService createDocumentWithName:duplicateFileName inParentFolder:self.testDocFolder contentFile:self.testImageFile properties:properties completionBlock:^(AlfrescoDocument *document, NSError *error) {
            
            if (document == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                XCTAssertNil(error, @"Error occured trying to create document the first time");
                
                NSMutableDictionary *props = [NSMutableDictionary dictionary];
                props[@"cmis:name"] = duplicateFileName;
                
                [weakFolderService createDocumentWithName:duplicateFileName inParentFolder:self.testDocFolder contentFile:self.testImageFile properties:props completionBlock:^(AlfrescoDocument *duplicateDocument, NSError *duplicateError) {
                    
                    if (duplicateError == nil)
                    {
                        self.lastTestSuccessful = NO;
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        XCTAssertNotNil(duplicateError, @"Trying to create another file with the same name should produce an error");
                        
                        // delete the orginal we created - cleanup
                        [weakFolderService deleteNode:document completionBlock:^(BOOL succeeded, NSError *deleteError) {
                            
                            XCTAssertNil(deleteError, @"Error occured trying to delete the folder node");
                            
                            self.lastTestSuccessful = succeeded;
                            
                            self.callbackCompleted = YES;
                        }];
                    }
                } progressBlock:^(unsigned long long bytesTransferred, unsigned long long totalBytes) {
                
                }];
            }
            
        } progressBlock:^(unsigned long long bytesTransferred, unsigned long long totalBytes) {
            
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 @Unique_TCRef 16F2
 */
- (void)testRetrieveNodeWithFolderPathWithInvalidRelativePath
{
    if (self.setUpSuccess)
    {
        NSString *invalidPath = @"InvalidPathFolder/nonExistantFile.txt";
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        [self.dfService retrieveNodeWithFolderPath:invalidPath relativeToFolder:self.testDocFolder completionBlock:^(AlfrescoNode *node, NSError *error) {
            
            if (node)
            {
                self.lastTestSuccessful = NO;
            }
            else
            {
                XCTAssertNotNil(error, @"Error should have occurred trying to access an invalid file path");
                
                self.lastTestSuccessful = YES;
            }
            
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 @Unique_TCRef 32F14
 */
- (void)testCreateFolderWithYesterdayCreationDate
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        NSDate *now = [NSDate date];
        int daysToAdd = -1;
        
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setDay:daysToAdd];
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *yesterday = [gregorian dateByAddingComponents:components toDate:now options:0];
        
        NSMutableDictionary *props = [NSMutableDictionary dictionary];
        props[@"cm:description"] = @"test description";
        props[@"cm:title"] = @"test title";
        // set the created value to yesterday
        props[@"cm:created"] = yesterday;
        
        // create a new folder in the repository's root folder
        NSString *folderName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.unitTestFolder];
        [self.dfService createFolderWithName:folderName inParentFolder:self.testDocFolder properties:props completionBlock:^(AlfrescoFolder *folder, NSError *error) {
            
            if (folder)
            {
                self.lastTestSuccessful = NO;
                [self.dfService deleteNode:folder completionBlock:^(BOOL succeeded, NSError *error){
                    if (nil != error)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = @"Failure to delete node";
                    }
                    else
                    {
                        self.lastTestSuccessful = YES;
                    }
                    self.callbackCompleted = YES;
                }];
            }
            else
            {
                XCTAssertNil(folder, @"Folder should be nil as it should not have been created successfully due to invalid properties");
                XCTAssertNotNil(error, @"Error should have occured trying to set the created date");
                
                self.lastTestSuccessful = YES;
                self.callbackCompleted = YES;
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

/*
 @Unique_TCRef 33F14
 */
- (void)testCreateDocumentWithYesterdayCreationDate
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        NSDate *now = [NSDate date];
        int daysToAdd = -1;
        
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setDay:daysToAdd];
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *yesterday = [gregorian dateByAddingComponents:components toDate:now options:0];
        
        NSMutableDictionary *props = [NSMutableDictionary dictionary];
        props[@"cm:description"] = @"test description";
        props[@"cm:title"] = @"test title";
        // set the created value to yesterday
        props[@"cm:created"] = yesterday;
        
        [self.dfService createDocumentWithName:@"testDocument.jpg" inParentFolder:self.testDocFolder contentFile:self.testImageFile properties:props completionBlock:^(AlfrescoDocument *document, NSError *error) {
            
            if (document)
            {
                self.lastTestSuccessful = NO;
                [self.dfService deleteNode:document completionBlock:^(BOOL succeeded, NSError *error){
                    if (nil != error)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = @"Failure to delete node";
                    }
                    else
                    {
                        self.lastTestSuccessful = YES;
                    }
                    self.callbackCompleted = YES;
                }];
            }
            else
            {
                XCTAssertNil(document, @"Document should be nil as it should not have been created successfully due to invalid properties");
                XCTAssertNotNil(error, @"Error should have occured trying to set the created date");
                
                self.lastTestSuccessful = YES;
                self.callbackCompleted = YES;
            }
            
        } progressBlock:^(unsigned long long bytesTransferred, unsigned long long totalBytes) {
        
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 @Unique_TCRef 19F3
 */
- (void)testRetrieveDocumentsInFolderWithIncorrectSortProperty
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:5 skipCount:0 sortProperty:@"***" sortAscending:NO];
        
        [self.dfService retrieveDocumentsInFolder:self.testDocFolder listingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
            
            if (error)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                XCTAssertNil(error, @"The retrieval should not have caused an error");
                XCTAssertNotNil(pagingResult, @"Paging result should not be nil");
                XCTAssertTrue([pagingResult.objects count] <= 5, @"The objects array should contain 5 or less result objects, but instead got back %i", [pagingResult.objects count]);
                
                for (AlfrescoNode *node in pagingResult.objects)
                {
                    NSString *name = node.name;
                    AlfrescoLogInfo(@"*** pagingResult: %@", name);
                }
                
                // check if array is sorted correctly
                NSArray *sortedArray = [pagingResult.objects sortedArrayUsingComparator:^(id a, id b) {
                    
                    AlfrescoNode *node1 = (AlfrescoNode *)a;
                    AlfrescoNode *node2 = (AlfrescoNode *)b;
                    
                    return [node2.name compare:node1.name options:NSCaseInsensitiveSearch];
                }];
                
                for (AlfrescoNode *node in sortedArray)
                {
                    NSString *name = node.name;
                    AlfrescoLogInfo(@"*** local sort: %@", name);
                }
                
                BOOL isResultSortedInDescendingOrderByName = [pagingResult.objects isEqualToArray:sortedArray];
                XCTAssertTrue(isResultSortedInDescendingOrderByName, @"The returned array was not sorted in descending order by name");
                
                // check properties
                [pagingResult.objects enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
                    AlfrescoDocument *document = (AlfrescoDocument *)object;
                    XCTAssertNotNil(document.contentMimeType, @"Mime Type for the object with the name \"%@\" and identifier \"%@\" has no mime type", document.name, document.identifier);
                    XCTAssertTrue(document.contentLength > 0, @"Content Length for the object with the name \"%@\" and identifier \"%@\" was less than or equal to 0", document.name, document.identifier);
                    XCTAssertNotNil(document.versionLabel, @"Version Label for the object with the name \"%@\" and identifier \"%@\" was nil", document.name, document.identifier);
                    //                    Need clearification to the purpose of this property, currently returning nil for all documents
                    //                    XCTAssertNotNil(document.versionComment, @"Version Comment for the object with the name \"%@\" and identifier \"%@\" was nil", document.name, document.identifier);
                    XCTAssertTrue(document.isLatestVersion, @"isLatestVersion for the object with the name \"%@\" and identifier \"%@\" should be true", document.name, document.identifier);
                }];
                
                self.lastTestSuccessful = YES;
            }
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 @Unique_TCRef 21F3
 */
- (void)testRetrieveFoldersInFolderWithIncorrectSortProperty
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        AlfrescoListingContext *listingConext = [[AlfrescoListingContext alloc] initWithMaxItems:5 skipCount:0 sortProperty:@"***" sortAscending:NO];
        
        [self.dfService retrieveFoldersInFolder:self.testDocFolder listingContext:listingConext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
            
            if (error)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                XCTAssertNil(error, @"The retrieval should not have caused an error");
                XCTAssertNotNil(pagingResult, @"Paging result should not be nil");
                XCTAssertTrue([pagingResult.objects count] <= 5, @"The objects array should contain 5 or less result objects, but instead got back %i", [pagingResult.objects count]);

                for (AlfrescoNode *node in pagingResult.objects)
                {
                    NSString *name = node.name;
                    AlfrescoLogInfo(@"*** pagingResult: %@", name);
                }

                // check if array is sorted correctly
                NSArray *sortedArray = [pagingResult.objects sortedArrayUsingComparator:^(id a, id b) {
                    
                    AlfrescoNode *node1 = (AlfrescoNode *)a;
                    AlfrescoNode *node2 = (AlfrescoNode *)b;
                    
                    return [node2.name compare:node1.name options:NSCaseInsensitiveSearch];
                }];
                
                for (AlfrescoNode *node in sortedArray)
                {
                    NSString *name = node.name;
                    AlfrescoLogInfo(@"*** local sort: %@", name);
                }
                
                BOOL isResultSortedInDescendingOrderByName = [pagingResult.objects isEqualToArray:sortedArray];
                XCTAssertTrue(isResultSortedInDescendingOrderByName, @"The returned array was not sorted in descending order by name");
                
                self.lastTestSuccessful = YES;
            }
            self.callbackCompleted = YES;
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/**
 @Unique_TCRef 13S3
 */
- (void)testRetrieveChildrenInFolderWithOneSubFolder
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        __weak AlfrescoDocumentFolderService *weakFolderService = self.dfService;
        
        NSString *parentFolderDescription = @"Test Description";
        NSString *parentFolderTitle = @"Test Title";
        
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:2];
        props[@"cm:description"] = parentFolderDescription;
        props[@"cm:title"] = parentFolderTitle;
        
        // create a new folder in the repository's root folder
        NSString *folderName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.unitTestFolder];
        [self.dfService createFolderWithName:folderName inParentFolder:self.testDocFolder properties:props completionBlock:^(AlfrescoFolder *folder, NSError *error) {
            if (error)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"#1 %@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(folder, @"Folder should have successfully been created");
                
                NSString *subFolderName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:@"SubFolder"];
                NSString *subFolderDescription = @"Test Description";
                NSString *subFolderTitle = @"Test Title";
                
                NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:2];
                properties[@"cm:description"] = subFolderDescription;
                properties[@"cm:title"] = subFolderTitle;
                
                [weakFolderService createFolderWithName:subFolderName inParentFolder:folder properties:properties completionBlock:^(AlfrescoFolder *subFolder, NSError *subFolderError) {
                    if (subFolderError)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"#2 %@ - %@", [subFolderError localizedDescription], [subFolderError localizedFailureReason]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        NSDate *actualCreation = subFolder.createdAt;
                        
                        // do a retrieve of the unit test folder
                        [weakFolderService retrieveChildrenInFolder:folder completionBlock:^(NSArray *childrenArray, NSError *childrenError) {
                            if (childrenError)
                            {
                                self.lastTestSuccessful = NO;
                                self.lastTestFailureMessage = [NSString stringWithFormat:@"#3 %@ - %@", [childrenError localizedDescription], [childrenError localizedFailureReason]];
                            }
                            else
                            {
                                XCTAssertNotNil(childrenArray, @"The array returned should not be nil");
                                
                                XCTAssertTrue([childrenArray count] == 1, @"Expected only one node to be returned");
                                
                                AlfrescoNode *subFolderNode = childrenArray[0];
                                XCTAssertTrue(subFolderNode.isFolder, @"The node returned should be a folder");
                                XCTAssertFalse(subFolderNode.isDocument, @"The node returned should not be a document");
                                XCTAssertNotNil(subFolderNode.identifier, @"The node's identifier should not be nil");
                                XCTAssertTrue([subFolderNode.name isEqualToString:subFolderName], @"The node's name should be %@, but instead is called %@", subFolderName, subFolderNode.name);
                                XCTAssertTrue([subFolderNode.summary isEqualToString:parentFolderDescription], @"The node's description should be %@, but instead got back %@", subFolderDescription, subFolderNode.summary);
                                XCTAssertTrue([subFolderNode.title isEqualToString:parentFolderTitle], @"The node's title should be %@, but instead got back %@", subFolderTitle, subFolderNode.title);
                                XCTAssertNotNil(subFolderNode.type , @"Type should be filled");
                                XCTAssertNotNil(subFolderNode.createdBy, @"CreatedBy should not be a nil value");
                                XCTAssertTrue([subFolderNode.createdAt isEqualToDate:actualCreation], @"The creation dates of the folders do not match");
                                XCTAssertNotNil(subFolderNode.properties, @"The properties of the subfolder should not be nil");
                                XCTAssertNotNil(subFolderNode.aspects, @"The aspects of the subfolder should not be nil");
                            }
                            
                            [weakFolderService deleteNode:folder completionBlock:^(BOOL succeeded, NSError *error) {
                                if (error == nil)
                                {
                                    self.lastTestSuccessful = succeeded;
                                }
                                
                                self.callbackCompleted = YES;
                            }];
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

/**
 @Unique_TCRef 13S4
 */
- (void)testRetrieveChildrenInFolderWithOneDocument
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        __weak AlfrescoDocumentFolderService *weakFolderService = self.dfService;
        
        NSString *parentFolderDescription = @"Test Description";
        NSString *parentFolderTitle = @"Test Title";
        
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:2];
        props[@"cm:description"] = parentFolderDescription;
        props[@"cm:title"] = parentFolderTitle;
        NSString *folderName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.unitTestFolder];
        // create a new folder in the repository's root folder
        [self.dfService createFolderWithName:folderName inParentFolder:self.testDocFolder properties:props completionBlock:^(AlfrescoFolder *folder, NSError *error) {
            if (error)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(folder, @"Folder should have successfully been created");
                
                NSString *documentName = @"Testing.jpg";
                NSString *documentDescription = @"Test Description";
                NSString *documentTitle = @"Test Title";
                NSString *documentAuthor = @"Test Author";
                
                NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:4];
                properties[kCMISPropertyObjectTypeId] = [kCMISPropertyObjectTypeIdValueDocument stringByAppendingString:@",P:cm:titled,P:cm:author"];
                properties[@"cm:description"] = documentDescription;
                properties[@"cm:title"] = documentTitle;
                properties[@"cm:author"] = documentAuthor;
                
                [weakFolderService createDocumentWithName:documentName inParentFolder:folder contentFile:self.testImageFile properties:properties completionBlock:^(AlfrescoDocument *document, NSError *docError) {
                    if (docError)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"#1 %@ - %@", [docError localizedDescription], [docError localizedFailureReason]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        NSDate *actualCreation = document.createdAt;
                        
                        // do a retrieve of the unit test folder
                        [weakFolderService retrieveChildrenInFolder:folder completionBlock:^(NSArray *childrenArray, NSError *childrenError) {
                            
                            if (childrenError)
                            {
                                self.lastTestSuccessful = NO;
                                self.lastTestFailureMessage = [NSString stringWithFormat:@"#2 %@ - %@", [childrenError localizedDescription], [childrenError localizedFailureReason]];
                            }
                            else
                            {
                                XCTAssertNotNil(childrenArray, @"The array returned should not be nil");
                                
                                XCTAssertTrue([childrenArray count] == 1, @"Expected only one node to be returned");
                                
                                AlfrescoNode *document = childrenArray[0];
                                XCTAssertFalse(document.isFolder, @"The node returned should not be a folder");
                                XCTAssertTrue(document.isDocument, @"The node returned should be a document");
                                XCTAssertNotNil(document.identifier, @"The node's identifier should not be nil");
                                XCTAssertTrue([document.name isEqualToString:documentName], @"The node's name should be %@, but instead is called %@", documentName, document.name);
                                XCTAssertTrue([document.summary isEqualToString:documentDescription], @"The node's description should be %@, but instead got back %@", documentDescription, document.summary);
                                XCTAssertTrue([document.title isEqualToString:parentFolderTitle], @"The node's title should be %@, but instead got back %@", documentTitle, document.title);
                                XCTAssertNotNil(document.type , @"Type should be filled");
                                XCTAssertNotNil(document.createdBy, @"CreatedBy should not be a nil value");
                                XCTAssertTrue([document.createdAt isEqualToDate:actualCreation], @"The creation dates of the folders do not match");
                                XCTAssertNotNil(document.properties, @"The properties of the subfolder should not be nil");
                                XCTAssertNotNil(document.aspects, @"The aspects of the subfolder should not be nil");
                            }
                            
                            double delayInSeconds = 1.0;
                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                [weakFolderService deleteNode:folder completionBlock:^(BOOL succeeded, NSError *error) {
                                    if (error == nil)
                                    {
                                        self.lastTestSuccessful = succeeded;
                                    }
                                    
                                    self.lastTestFailureMessage = [NSString stringWithFormat:@"#3 %@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                    self.callbackCompleted = YES;
                                }];
                            });
                        }];
                    }
                } progressBlock:^(unsigned long long bytesTransfered, unsigned long long totalBytes) {
                    
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

/**
 @Unique_TCRef 17S5
 */
- (void)testRetrieveNodeWithIdentifierForFolderNode
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        __weak AlfrescoDocumentFolderService *weakFolderService = self.dfService;
        
        NSString *subFolderDescription = @"Test Description";
        NSString *subFolderTitle = @"Test Title";
        
        NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:2];
        properties[@"cm:description"] = subFolderDescription;
        properties[@"cm:title"] = subFolderTitle;
        
        NSString *folderName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.unitTestFolder];
        [self.dfService createFolderWithName:folderName inParentFolder:self.testDocFolder properties:properties completionBlock:^(AlfrescoFolder *folder, NSError *error) {
            if (error)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                // check values here
                NSString *createdIdentifier = folder.identifier;
                NSString *createdName = folder.name;
                NSString *createdTitle = folder.title;
                NSString *createdSummary = folder.summary;
                NSString *createdType = folder.type;
                NSDate *createdDate = folder.createdAt;
                NSString *createdBy = folder.createdBy;
                NSDictionary *createdProperties = folder.properties;
                NSArray *createdAspects = folder.aspects;
                
                [weakFolderService retrieveNodeWithIdentifier:folder.identifier completionBlock:^(AlfrescoNode *retrievedNode, NSError *retrievedError) {
                    if (retrievedError)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrievedError localizedDescription], [retrievedError localizedFailureReason]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        // check with created
                        XCTAssertTrue([retrievedNode.identifier isEqualToString:createdIdentifier], @"Expected the identifier of the node to be %@, instead got back %@", createdIdentifier, retrievedNode.identifier);
                        XCTAssertTrue([retrievedNode.name isEqualToString:createdName], @"Expected the name of the node to be %@, instead got back %@", createdName, retrievedNode.name);
                        XCTAssertTrue([retrievedNode.title isEqualToString:createdTitle], @"Expected the title of the node to be %@, instead got back %@", createdTitle, retrievedNode.title);
                        XCTAssertTrue([retrievedNode.summary isEqualToString:createdSummary], @"Expected the summary of the node to be %@, instead got back %@", createdSummary, retrievedNode.summary);
                        XCTAssertTrue([retrievedNode.type isEqualToString:createdType], @"Expected the created of the node to be %@, instead got back %@", createdType, retrievedNode.type);
                        XCTAssertTrue([retrievedNode.createdAt isEqualToDate:createdDate], @"Expected the created date of the node to be %@, instead got back %@", createdDate, retrievedNode.createdAt);
                        XCTAssertTrue([retrievedNode.createdBy isEqualToString:createdBy], @"Expected the created by of the node to be %@, instead got back %@", createdBy, retrievedNode.createdBy);
                        XCTAssertTrue([retrievedNode.properties count] == [createdProperties count], @"Expected the properties count of the node to be %lu, instead got back %lu", (unsigned long)[createdProperties count], (unsigned long)[retrievedNode.properties count]);
                        XCTAssertTrue([retrievedNode.aspects isEqualToArray:createdAspects], @"Expected the aspects of the node to be %@, instead got back %@", createdAspects, retrievedNode.aspects);
                        XCTAssertTrue(retrievedNode.isFolder, @"Expected the identifier of the node to be %i, instead got back %i", YES, retrievedNode.isFolder);
                        XCTAssertFalse(retrievedNode.isDocument, @"Expected the identifier of the node to be %i, instead got back %i", NO, retrievedNode.isDocument);
                        
                        [weakFolderService deleteNode:folder completionBlock:^(BOOL succeeded, NSError *deleteError) {
                            if (!deleteError)
                            {
                                self.lastTestSuccessful = succeeded;
                            }
                            self.callbackCompleted = YES;
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

/**
 @Unique_TCRef 21S6
 */
- (void)testRetrieveFoldersInFolderWithListingContext
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        int maxItemsExpected = 5;
        int skipCountExpected = 0;
        
        AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:maxItemsExpected skipCount:skipCountExpected sortProperty:kAlfrescoSortByTitle sortAscending:NO];
        
        [self.dfService retrieveFoldersInFolder:self.testDocFolder listingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
            
            if (error)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                XCTAssertNotNil(pagingResult, @"The paging result should not be nil");
                
                XCTAssertTrue([pagingResult.objects count] == maxItemsExpected, @"Expected the objects array to be of size %i, instead got back a size %i", maxItemsExpected, [pagingResult.objects count]);
                XCTAssertTrue(pagingResult.hasMoreItems, @"Expected the paging result to have more items");
                XCTAssertTrue(pagingResult.totalItems > maxItemsExpected, @"Expected the paging result to have more than %i items as the total number, but instead got back %i", maxItemsExpected, pagingResult.totalItems);
                
                // check if array is sorted correctly
                NSArray *sortedArray = [pagingResult.objects sortedArrayUsingComparator:^(id a, id b) {
                    
                    AlfrescoNode *node1 = (AlfrescoNode *)a;
                    AlfrescoNode *node2 = (AlfrescoNode *)b;
                    
                    return [node2.title compare:node1.title options:NSCaseInsensitiveSearch];
                }];
                
                BOOL isResultSortedInDescendingOrderByName = [pagingResult.objects isEqualToArray:sortedArray];
                
                XCTAssertTrue(isResultSortedInDescendingOrderByName, @"The returned array was not sorted in descending order by name");
                
                self.lastTestSuccessful = YES;
            }
            self.callbackCompleted = YES;
        }];
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 @Unique_TCRef 27S2
 @Unique_TCRef 30S4
 */
- (void)testRetrieveContentOfEmptyDocument
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        __weak AlfrescoDocumentFolderService *weakDocumentService = self.dfService;
        
        [self.dfService retrieveContentOfDocument:self.testAlfrescoDocument completionBlock:^(AlfrescoContentFile *contentFile, NSError *error) {
            
            if (contentFile == nil)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(contentFile,@"created content file should not be nil");
                NSError *fileError = nil;
                //                NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[contentFile.fileUrl path] error:&fileError];
                XCTAssertNil(fileError, @"expected no error in getting file attributes for contentfile at path %@",[contentFile.fileUrl path]);
                //                unsigned long long size = [[fileAttributes valueForKey:NSFileSize] unsignedLongLongValue];
                NSError *readError = nil;
                
                __block NSString *stringContent = [NSString stringWithContentsOfFile:[contentFile.fileUrl path] encoding:NSUTF8StringEncoding error:&readError];
                
                if (stringContent == nil)
                {
                    self.lastTestSuccessful = NO;
                    self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [readError localizedDescription], [readError localizedFailureReason]];
                    self.callbackCompleted = YES;
                }
                else
                {
                    // update the content to an empty document
                    __block NSString *updatedContent = @"\0";
                    NSData *data = [updatedContent dataUsingEncoding:NSUTF8StringEncoding];
                    
                    __block AlfrescoContentFile *updatedContentFile = [[AlfrescoContentFile alloc] initWithData:data mimeType:contentFile.mimeType];
                    
                    [weakDocumentService updateContentOfDocument:self.testAlfrescoDocument contentFile:updatedContentFile completionBlock:^(AlfrescoDocument *updatedDocument, NSError *error) {
                        
                        if (updatedDocument == nil)
                        {
                            self.lastTestSuccessful = NO;
                            self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                            self.callbackCompleted = YES;
                        }
                        else
                        {
                            XCTAssertNotNil(updatedDocument.identifier, @"document identifier should be filled");
                            
                            [weakDocumentService retrieveContentOfDocument:updatedDocument completionBlock:^(AlfrescoContentFile *checkContentFile, NSError *checkError){
                                
                                if (checkContentFile == nil)
                                {
                                    self.lastTestSuccessful = NO;
                                    self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [checkError localizedDescription], [checkError localizedFailureReason]];
                                }
                                else
                                {
                                    XCTAssertNotNil(checkContentFile, @"Should have returned a content file object");
                                    // document content size should be the same as that of the updated content (empty document)
                                    XCTAssertTrue(checkContentFile.length == updatedDocument.contentLength, @"Expected the length of the content file to be %llu, but instead got back %llu", updatedDocument.contentLength, checkContentFile.length);
                                    XCTAssertTrue([checkContentFile.mimeType isEqualToString:@"text/plain"], @"Expected the mime type to be %@, but instead got back %@", @"text/plain", contentFile.mimeType);
                                    
                                    self.lastTestSuccessful = YES;
                                }
                                self.callbackCompleted = YES;
                            } progressBlock:^(unsigned long long bytesTransferred, unsigned long long bytesTotal) {
                                
                            }];
                        }
                    } progressBlock:^(unsigned long long bytesDownloaded, unsigned long long bytesTotal) {
                        AlfrescoLogDebug(@"progress %i/%i", bytesDownloaded, bytesTotal);
                    }];
                }
            }
            
        } progressBlock:^(unsigned long long bytesDownloaded, unsigned long long totalBytes) {
            
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testCreateDocumentWithCustomType
{
    if (self.setUpSuccess)
    {
        if (!self.isCloud)
        {
            //            [AlfrescoLog sharedInstance].logLevel = AlfrescoLogLevelTrace;
            NSMutableDictionary *props = [NSMutableDictionary dictionary];
            NSString *title = @"CustomType Example";
            NSString *description = @"An example to demonstrate the creation of docs with custom types";
            props[@"cm:title"] = title;
            props[@"cm:description"] = description;
            
            NSString *customTypeTestFileName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:@"everything.txt"];
            
            // create a ContentFile object file for the content
            NSString *contentString = @"This is the content for the custom type";
            AlfrescoContentFile *contentFile = [[AlfrescoContentFile alloc] initWithData:[contentString dataUsingEncoding:NSUTF8StringEncoding]
                                                                                mimeType:@"text/plain"];
            
            self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
            
            [self.dfService createDocumentWithName:customTypeTestFileName inParentFolder:self.testDocFolder contentFile:contentFile properties:props aspects:nil type:@"fdk:everything" completionBlock:^(AlfrescoDocument *document, NSError *error){
                if (nil == document)
                {
                    self.lastTestSuccessful = NO;
                    self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                    self.callbackCompleted = YES;
                }
                else
                {
                    XCTAssertNotNil(document.identifier, @"document identifier should be filled");
                    XCTAssertTrue([document.type isEqualToString:@"fdk:everything"], @"Custom type is incorrect");
                    XCTAssertTrue([document.name isEqualToString:customTypeTestFileName], @"document name is incorrect");
                    XCTAssertTrue(document.contentLength > 10, @"expected content to be filled");
                    
                    // delete the test document
                    [self.dfService deleteNode:document completionBlock:^(BOOL success, NSError *error)
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
            } progressBlock:^(unsigned long long bytesTransferred, unsigned long long bytesTotal){}];
            
            [self waitUntilCompleteWithFixedTimeInterval];
            XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
        }
        //        [AlfrescoLog sharedInstance].logLevel = AlfrescoLogLevelDebug;
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 */
- (void)testUpdatePropertiesForDocumentWithCustomType
{
    if (self.setUpSuccess)
    {
        if (!self.isCloud)
        {
            NSMutableDictionary *props = [NSMutableDictionary dictionary];
            NSString *title = @"CustomType Example";
            NSString *description = @"An example to demonstrate the creation of docs with custom types";
            NSString *fdkText = @"Custom text property";
            NSArray *fdkTextMultiple = @[@"first", @"second", @"third"];
            props[@"cm:title"] = title;
            props[@"cm:description"] = description;
            props[@"fdk:text"] = fdkText;
            props[@"fdk:textMultiple"] = fdkTextMultiple;
            
            NSString *customTypeTestFileName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:@"everything.txt"];
            
            // create a ContentFile object file for the content
            NSString *contentString = @"This is the content for the custom type";
            AlfrescoContentFile *contentFile = [[AlfrescoContentFile alloc] initWithData:[contentString dataUsingEncoding:NSUTF8StringEncoding]
                                                                                mimeType:@"text/plain"];
            
            self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
            
            [self.dfService createDocumentWithName:customTypeTestFileName inParentFolder:self.testDocFolder contentFile:contentFile properties:props aspects:nil type:@"fdk:everything" completionBlock:^(AlfrescoDocument *document, NSError *error){
                if (nil == document)
                {
                    self.lastTestSuccessful = NO;
                    self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                    self.callbackCompleted = YES;
                }
                else
                {
                    // check builtin properties
                    XCTAssertNotNil(document.identifier, @"document identifier should be filled");
                    XCTAssertTrue([document.type isEqualToString:@"fdk:everything"], @"Custom type is incorrect");
                    XCTAssertTrue([document.name isEqualToString:customTypeTestFileName], @"document name is incorrect");
                    XCTAssertTrue(document.contentLength > 10, @"expected content to be filled");
                    
                    // check custom properties
                    AlfrescoProperty *fdkTextProperty = document.properties[@"fdk:text"];
                    XCTAssertNotNil(fdkTextProperty, @"Expected to find the fdk:text property");
                    XCTAssertTrue([fdkTextProperty.value isEqualToString:fdkText], @"Expected fdk:text property to be %@ but it was %@", fdkText, fdkTextProperty.value);
                    
                    AlfrescoProperty *fdkTextMultipleProperty = document.properties[@"fdk:textMultiple"];
                    XCTAssertNotNil(fdkTextMultipleProperty, @"Expected to find fdk:textMultiple property");
                    XCTAssertTrue(fdkTextMultipleProperty.isMultiValued, @"Expected fdk:textMultiple to be a multi valued property");
                    XCTAssertTrue([fdkTextMultipleProperty.value isKindOfClass:[NSArray class]], @"Expected the fdk:textMultiple property value to be an array");
                    NSArray *values = (NSArray *)fdkTextMultipleProperty.value;
                    XCTAssertTrue(values.count == 3, @"Expected 3 values for the fdk:textMultiple property but there were %d", values.count);
                    NSString *firstValue = [values firstObject];
                    XCTAssertTrue([firstValue isEqualToString:@"first"], @"Expected first value for the fdk:textMultiple property to be 'first' but it was '%@'", firstValue);
                    
                    // now update some custom properties
                    NSString *text = [NSString stringWithFormat:@"Text %i", arc4random()%10];
                    NSNumber *number = @(arc4random()%512);
                    NSArray *multiple = @[@"first", @"second", @"third", @"fourth"];
                    
                    NSMutableDictionary *propDict = [NSMutableDictionary dictionaryWithCapacity:2];
                    propDict[@"fdk:text"] = text;
                    propDict[@"fdk:int"] = number;
                    propDict[@"fdk:textMultiple"] = multiple;
                    [self.dfService updatePropertiesOfNode:document properties:propDict completionBlock:^(AlfrescoNode *updatedNode, NSError *updateError) {
                        
                        if (nil == updatedNode)
                        {
                            self.lastTestSuccessful = NO;
                            self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [updateError localizedDescription], [updateError localizedFailureReason]];
                            self.callbackCompleted = YES;
                        }
                        else
                        {
                            AlfrescoDocument *updatedDocument = (AlfrescoDocument *)updatedNode;
                            XCTAssertNotNil(updatedDocument.identifier, @"document identifier should be filled");
                            XCTAssertTrue([updatedDocument.type isEqualToString:@"fdk:everything"], @"Custom type is incorrect. Expected fdk:everything but got back %@", updatedDocument.type);
                            
                            // check the updated properties
                            NSDictionary *updatedProps = updatedDocument.properties;
                            AlfrescoProperty *updatedText = updatedProps[@"fdk:text"];
                            AlfrescoProperty *updatedNumber = updatedProps[@"fdk:int"];
                            AlfrescoProperty *updatedMultiValued = updatedProps[@"fdk:textMultiple"];
                            XCTAssertNotNil(updatedText, @"Expected to find the updated fdk:text property");
                            XCTAssertNotNil(updatedNumber, @"Expected to find the updated fdk:int property");
                            XCTAssertNotNil(updatedMultiValued, @"Expected to find the updated fdk:textMultiple property");
                            XCTAssertTrue([updatedText.value isEqualToString:text], @"Updated fdk:text property is incorrect");
                            XCTAssertTrue([updatedNumber.value isEqualToNumber:number], @"Updated fdk:int property is incorrect");
                            XCTAssertTrue(updatedMultiValued.isMultiValued, @"Expected fdk:textMultiple to still be a multi valued property");
                            NSArray *updatedValues = (NSArray *)updatedMultiValued.value;
                            XCTAssertTrue(updatedValues.count == 4, @"Expected 4 values for the fdk:textMultiple property but there were %d", updatedValues.count);
                            
                            // delete the test document
                            [self.dfService deleteNode:document completionBlock:^(BOOL success, NSError *deleteError)
                             {
                                 if (!success)
                                 {
                                     self.lastTestSuccessful = NO;
                                     self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [deleteError localizedDescription], [deleteError localizedFailureReason]];
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
            } progressBlock:^(unsigned long long bytesTransferred, unsigned long long bytesTotal){}];
            
            [self waitUntilCompleteWithFixedTimeInterval];
            XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
        }
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testCreateFolderCancellation
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        // create a new folder in the repository's root folder
        NSString *folderName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:self.unitTestFolder];
        AlfrescoRequest *request = [self.dfService createFolderWithName:folderName inParentFolder:self.testDocFolder properties:nil completionBlock:^(AlfrescoFolder *folder, NSError *error) {
            if (nil == folder)
            {
                // Should also get a cancellation error code
                XCTAssertEqual(error.localizedDescription, kAlfrescoErrorDescriptionNetworkRequestCancelled, @"Expected cancellation error description, not \"%@\"", error.localizedDescription);
                self.lastTestSuccessful = YES;
                
                // Try to clean-up as it's possible the folder will have got created anyway
                [self.dfService retrieveNodeWithFolderPath:folderName relativeToFolder:self.testDocFolder completionBlock:^(AlfrescoNode *node, NSError *error) {
                    if (nil != node)
                    {
                        // delete the folder to clean up
                        [self.dfService deleteNode:node completionBlock:^(BOOL success, NSError *error) {
                            self.callbackCompleted = YES;
                        }];
                    }
                }];
            }
            else
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = @"The request to create a folder was not cancelled correctly.";

                // delete the folder to clean up
                [self.dfService deleteNode:folder completionBlock:^(BOOL success, NSError *error) {
                    if (!success)
                    {
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                    }
                    
                    self.callbackCompleted = YES;
                }];
            }
        }];
        
        // immediately cancel the folder creation request
        [request cancel];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testCreateDocumentCancellation
{
    if (self.setUpSuccess)
    {
        NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"test_file.txt" ofType:nil];
        NSURL *fileUrl = [NSURL URLWithString:filePath];
        NSString *documentName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:[fileUrl lastPathComponent]];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        AlfrescoContentFile *textContentFile = [[AlfrescoContentFile alloc] initWithData:fileData mimeType:@"text/plain"];
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        AlfrescoRequest *request = [self.dfService createDocumentWithName:documentName inParentFolder:self.testDocFolder contentFile:textContentFile properties:nil completionBlock:^(AlfrescoDocument *document, NSError *error) {
            if (nil == document)
            {
                // Should also get a cancellation error code
                XCTAssertEqual(error.localizedDescription, kAlfrescoErrorDescriptionNetworkRequestCancelled, @"Expected cancellation error description, not \"%@\"", error.localizedDescription);
                self.lastTestSuccessful = YES;

                // Try to clean-up as it's possible the document will have got created anyway
                [self.dfService retrieveNodeWithFolderPath:documentName relativeToFolder:self.testDocFolder completionBlock:^(AlfrescoNode *node, NSError *error) {
                    if (nil != node)
                    {
                        // delete the document to clean up
                        [self.dfService deleteNode:node completionBlock:^(BOOL success, NSError *error) {
                            self.callbackCompleted = YES;
                        }];
                    }
                }];
            }
            else
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = @"The request to create a document was not cancelled correctly.";
                
                // delete the document to clean up
                [self.dfService deleteNode:document completionBlock:^(BOOL success, NSError *error) {
                    if (!success)
                    {
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                    }
                    
                    self.callbackCompleted = YES;
                }];
            }
        } progressBlock:^(unsigned long long bytesTransferred, unsigned long long bytesTotal) {
            // No-op
        }];
        
        // immediately cancel the document creation request
        [request cancel];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRetrieveFavoriteDocuments
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        [self.dfService retrieveFavoriteDocumentsWithCompletionBlock:^(NSArray *array, NSError *error) {
            if (error)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                XCTAssertNotNil(array, @"The result array should not be nil");
                XCTAssertTrue(array.count > 0, @"The array should not be empty");
                
                AlfrescoLogDebug(@"Favorites Documents: %@", [array valueForKeyPath:@"name"]);
                self.lastTestSuccessful = YES;
            }
            self.callbackCompleted = YES;
        }];
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }   
}

- (void)testRetrieveFavoriteDocumentsWithListingContext
{
    /**
     * Note: This test assumes each repository has AT LEAST TWO DOCUMENTS marked as favorites for the default unit test user
     */
    NSInteger numberOfFavoriteDocuments = 2;
    
    if (self.setUpSuccess)
    {
        AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:numberOfFavoriteDocuments];
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        [self.dfService retrieveFavoriteDocumentsWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
            if (error)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                XCTAssertNotNil(pagingResult, @"The paging result should not be nil");
                XCTAssertTrue([pagingResult.objects count] == numberOfFavoriteDocuments, @"Expected the objects array to be of size %i, instead got back a size %i", numberOfFavoriteDocuments, [pagingResult.objects count]);

                AlfrescoLogDebug(@"Favorites Documents with Listing Context: %@", [pagingResult.objects valueForKeyPath:@"name"]);
                self.lastTestSuccessful = YES;
            }
            self.callbackCompleted = YES;
        }];
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRetrieveFavoriteFolders
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        [self.dfService retrieveFavoriteFoldersWithCompletionBlock:^(NSArray *array, NSError *error) {
            if (error)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                XCTAssertNotNil(array, @"The result array should not be nil");
                XCTAssertTrue(array.count > 0, @"The array should not be empty");
                
                AlfrescoLogDebug(@"Favorites Folders: %@", [array valueForKeyPath:@"name"]);
                self.lastTestSuccessful = YES;
            }
            self.callbackCompleted = YES;
        }];
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRetrieveFavoriteFoldersWithListingContext
{
    /**
     * Note: This test assumes each repository has AT LEAST ONE FOLDER marked as favorites for the default unit test user
     */
    NSInteger numberOfFavoriteFolders = 1;
    
    if (self.setUpSuccess)
    {
        AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:numberOfFavoriteFolders];
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        [self.dfService retrieveFavoriteFoldersWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
            if (error)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                XCTAssertNotNil(pagingResult, @"The paging result should not be nil");
                XCTAssertTrue([pagingResult.objects count] == numberOfFavoriteFolders, @"Expected the objects array to be of size %i, instead got back a size %i", numberOfFavoriteFolders, [pagingResult.objects count]);
                
                AlfrescoLogDebug(@"Favorites Folders with Listing Context: %@", [pagingResult.objects valueForKeyPath:@"name"]);
                self.lastTestSuccessful = YES;
            }
            self.callbackCompleted = YES;
        }];
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRetrieveFavoriteNodes
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        [self.dfService retrieveFavoriteNodesWithCompletionBlock:^(NSArray *array, NSError *error) {
            if (error)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                XCTAssertNotNil(array, @"The result array should not be nil");
                XCTAssertTrue(array.count > 0, @"The array should not be empty");
                
                AlfrescoLogDebug(@"Favorites Nodes: %@", [array valueForKeyPath:@"name"]);
                self.lastTestSuccessful = YES;
            }
            self.callbackCompleted = YES;
        }];
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRetrieveFavoriteNodesWithListingContext
{
    /**
     * Note: This test assumes each repository has AT LEAST THREE NODES marked as favorites for the default unit test user
     */
    NSInteger numberOfFavoriteNodes = 3;
    
    if (self.setUpSuccess)
    {
        AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:numberOfFavoriteNodes];
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        [self.dfService retrieveFavoriteNodesWithListingContext:listingContext completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
            if (error)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                XCTAssertNotNil(pagingResult, @"The paging result should not be nil");
                XCTAssertTrue([pagingResult.objects count] == numberOfFavoriteNodes, @"Expected the objects array to be of size %i, instead got back a size %i", numberOfFavoriteNodes, [pagingResult.objects count]);

                AlfrescoLogDebug(@"Favorites Nodes with Listing Context: %@", [pagingResult.objects valueForKeyPath:@"name"]);
                self.lastTestSuccessful = YES;
            }
            self.callbackCompleted = YES;
        }];
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testIsNodeFavorite
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        __weak AlfrescoDocumentFolderService *weakDfService = self.dfService;
        [weakDfService addFavorite:self.testAlfrescoDocument completionBlock:^(BOOL succeeded, BOOL isFavorited, NSError *error) {
            if (!succeeded)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertTrue(isFavorited, @"Document should be marked as favorite");
                if (!isFavorited)
                {
                    self.lastTestSuccessful = NO;
                    self.callbackCompleted = YES;
                }
                else
                {
                    [weakDfService isFavorite:self.testAlfrescoDocument completionBlock:^(BOOL succeeded, BOOL isFavorited, NSError *error) {
                        if (!succeeded)
                        {
                            self.lastTestSuccessful = NO;
                            self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                        }
                        else
                        {
                            XCTAssertTrue(isFavorited, @"Documented should be flagged as favorited");
                            self.lastTestSuccessful = YES;
                        }
                        self.callbackCompleted = YES;
                    }];
                }
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

- (void)testAddFavorite
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        __weak AlfrescoDocumentFolderService *weakDfService = self.dfService;
        [weakDfService addFavorite:self.testAlfrescoDocument completionBlock:^(BOOL succeeded, BOOL isFavorited, NSError *error) {
            if (!succeeded)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                XCTAssertTrue(isFavorited, @"node should be marked as favorite");
                self.lastTestSuccessful = YES;
            }
            self.callbackCompleted = YES;
        }];
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRemoveFavorite
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        __weak AlfrescoDocumentFolderService *weakDfService = self.dfService;
        [weakDfService addFavorite:self.testAlfrescoDocument completionBlock:^(BOOL succeeded, BOOL isFavorited, NSError *error) {
            if (!succeeded)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertTrue(isFavorited, @"Document should be marked as favorite");
                if (!isFavorited)
                {
                    self.lastTestSuccessful = NO;
                    self.callbackCompleted = YES;
                }
                else
                {
                    [weakDfService removeFavorite:self.testAlfrescoDocument completionBlock:^(BOOL succeeded, BOOL isFavorited, NSError *error) {
                        if (!succeeded)
                        {
                            self.lastTestSuccessful = NO;
                            self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                        }
                        else
                        {
                            XCTAssertFalse(isFavorited, @"Document should no longer be marked as favorite");
                            self.lastTestSuccessful = YES;
                        }
                        self.callbackCompleted = YES;
                    }];
                }
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

/**
 Test to validate fix for MOBSDK-616
 */
- (void)testMultiValuedAspectProperties
{
    if (self.setUpSuccess)
    {
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        AlfrescoTaggingService *taggingService = [[AlfrescoTaggingService alloc] initWithSession:self.currentSession];
        
        // tag the test document with 3 tags
        NSArray *tags = @[@"one", @"two", @"three"];
        [taggingService addTags:tags toNode:self.testAlfrescoDocument completionBlock:^(BOOL succeeded, NSError *taggingError) {
            if (!succeeded)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [taggingError localizedDescription], [taggingError localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                // retrieve the test document again
                [self.dfService retrieveNodeWithIdentifier:self.testAlfrescoDocument.identifier completionBlock:^(AlfrescoNode *node, NSError *retrieveError) {
                    if (node == nil)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveError localizedDescription], [retrieveError localizedFailureReason]];
                    }
                    else
                    {
                        XCTAssertNotNil(node, @"node should not be nil");
                        
                        // retrieve the cm:taggable property and check it is multivalued
                        AlfrescoProperty *taggable = node.properties[@"cm:taggable"];
                        XCTAssertNotNil(taggable, @"Expected to find the cm:taggable property");
                        XCTAssertTrue(taggable.isMultiValued, @"Expected the cm:taggable to be multi valued");
                        
                        // check there are 3 values
                        NSArray *values = (NSArray *)taggable.value;
                        XCTAssertTrue(values.count == 3, @"Expected to find 3 values but found %d", values.count);
                        
                        self.lastTestSuccessful = YES;
                    }
                    self.callbackCompleted = YES;
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
