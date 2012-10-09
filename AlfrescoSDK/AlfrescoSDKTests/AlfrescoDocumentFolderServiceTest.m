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
/**
 @Unique_TCRef 32S0 - 32S2
 @Unique_TCRef 24S0
 */
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

/**
 @Unique_TCRef 32S0
 @Unique_TCRef 32F0
 @Unique_TCRef 24S0
 */
- (void)testCreateFolderInNonExistingFolder
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;

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
                 __block AlfrescoFolder *strongFolder = folder;
                 
                 [weakService deleteNode:folder completionBlock:^(BOOL success, NSError *error)
                  {
                      if (!success)
                      {
                          super.lastTestSuccessful = NO;
                          super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                          super.callbackCompleted = YES;
                      }
                      else
                      {
                          [weakService createFolderWithName:@"SomeTestFolder" inParentFolder:strongFolder properties:props completionBlock:^(AlfrescoFolder *nonFolder, NSError *error){
                              if (nil == nonFolder)
                              {
                                  self.lastTestSuccessful = YES;
                                  NSString *errorMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                  log(@"Expected failure. Message = %@",errorMessage);
                              }
                              else
                              {
                                  super.lastTestSuccessful = NO;
                                  super.lastTestFailureMessage = @"We should not be able to create a folder in a nonexisting folder";
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



/**
 @Unique_TCRef 32S0
 @Unique_TCRef 13F1
 @Unique_TCRef 24S0
 */
- (void)testRetrieveChildrenInFolderNonExisting
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
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
                 __block AlfrescoFolder *strongFolder = folder;
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
                          super.callbackCompleted = YES;
                      }
                      else
                      {
                          [weakService retrieveChildrenInFolder:strongFolder completionBlock:^(NSArray *array, NSError *error){
                              if (nil == array)
                              {
                                  self.lastTestSuccessful = YES;
                                  NSString *errorMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                  log(@"We expected this to fail with %@",errorMessage);
                              }
                              else
                              {
                                  super.lastTestSuccessful = NO;
                                  self.lastTestFailureMessage = @"We expected the folder not to be accessible after we deleted it";                                  
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

/**
 @Unique_TCRef 32S0
 @Unique_TCRef 19F1
 @Unique_TCRef 24S0
 */
- (void)testRetrieveDocumentsInFolderNonExisting
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
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
                 __block AlfrescoFolder *strongFolder = folder;
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
                          super.callbackCompleted = YES;
                      }
                      else
                      {
                          [weakService retrieveDocumentsInFolder:strongFolder completionBlock:^(NSArray *array, NSError *error){
                              if (nil == array)
                              {
                                  self.lastTestSuccessful = YES;
                                  NSString *errorMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                  log(@"We expected this to fail with %@",errorMessage);
                              }
                              else
                              {
                                  super.lastTestSuccessful = NO;
                                  self.lastTestFailureMessage = @"We expected the folder not to be accessible after we deleted it";
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

/**
 @Unique_TCRef 32S0
 @Unique_TCRef 20F1
 @Unique_TCRef 24S0
 */
- (void)testRetrieveFoldersInFolderNonExisting
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
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
                 __block AlfrescoFolder *strongFolder = folder;
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
                          super.callbackCompleted = YES;
                      }
                      else
                      {
                          [weakService retrieveFoldersInFolder:strongFolder completionBlock:^(NSArray *array, NSError *error){
                              if (nil == array)
                              {
                                  self.lastTestSuccessful = YES;
                                  NSString *errorMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                  log(@"We expected this to fail with %@",errorMessage);
                              }
                              else
                              {
                                  super.lastTestSuccessful = NO;
                                  self.lastTestFailureMessage = @"We expected the folder not to be accessible after we deleted it";
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



/**
 @Unique_TCRef 24S0, 32S0 - 32S5
 */
- (void)testCreateFolderWithSpecialEUCharacters
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        __block NSString *description = @"Übersicht Ändern Östrogen und das mit ß";
        __block NSString *title = @"Änderungswünsche";
        __block NSString *name = @"ÜÄÖTestsOrdner";
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:2];
        [props setObject:description forKey:@"cm:description"];
        [props setObject:title forKey:@"cm:title"];
        
        // create a new folder in the repository's root folder
        [self.dfService createFolderWithName:name inParentFolder:super.testDocFolder properties:props
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
                 STAssertTrue([folder.name isEqualToString:name], @"folder name should be %@, but instead we got %@",name, folder.name);
                 
                 // check the properties were added at creation time
                 NSDictionary *newFolderProps = folder.properties;
                 AlfrescoProperty *newDescriptionProp = [newFolderProps objectForKey:@"cm:description"];
                 AlfrescoProperty *newTitleProp = [newFolderProps objectForKey:@"cm:title"];
                 STAssertTrue([newDescriptionProp.value isEqualToString:description], @"cm:description property value does not match expected value %@",description);
                 STAssertTrue([newTitleProp.value isEqualToString:title], @"cm:title property value does not match expected value %@",title);
                 
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

/**
 @Unique_TCRef 24S0, 32S0 - 32S5
 */
- (void)testCreateFolderWithSpecialJPCharacters
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        __block NSString *description = @"ありがと　にほんご";
        __block NSString *title = @"わさび";
        __block NSString *name = @"ラヂオコmプタ";
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:2];
        [props setObject:description forKey:@"cm:description"];
        [props setObject:title forKey:@"cm:title"];
        
        // create a new folder in the repository's root folder
        [self.dfService createFolderWithName:name inParentFolder:super.testDocFolder properties:props
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
                 STAssertTrue([folder.name isEqualToString:name], @"folder name should be %@, but instead we got %@",name, folder.name);
                 
                 // check the properties were added at creation time
                 NSDictionary *newFolderProps = folder.properties;
                 AlfrescoProperty *newDescriptionProp = [newFolderProps objectForKey:@"cm:description"];
                 AlfrescoProperty *newTitleProp = [newFolderProps objectForKey:@"cm:title"];
                 STAssertTrue([newDescriptionProp.value isEqualToString:description], @"cm:description property value does not match expected value %@",description);
                 STAssertTrue([newTitleProp.value isEqualToString:title], @"cm:title property value does not match expected value %@",title);
                 
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

/**
 @Unique_TCRef 24S0, 32S0, 32F3
 */
- (void)testCreateFolderWithEmptyName
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        __block NSString *description = @"";
        __block NSString *title = @"";
        __block NSString *name = @"";
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:2];
        [props setObject:description forKey:@"cm:description"];
        [props setObject:title forKey:@"cm:title"];
        
        // create a new folder in the repository's root folder
        [self.dfService createFolderWithName:name inParentFolder:super.testDocFolder properties:props
                             completionBlock:^(AlfrescoFolder *folder, NSError *error)
         {
             if (nil == folder)
             {
                 super.lastTestSuccessful = YES;
                 log(@"%@",[NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]]);
                 super.callbackCompleted = YES;
             }
             else
             {
                 super.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = @"We should not succeed creating a folder with an empty name";
                 STAssertTrue([folder.name isEqualToString:name], @"folder name should be %@, but instead we got %@",name, folder.name);
                 
                 
                 [self.dfService deleteNode:folder completionBlock:^(BOOL success, NSError *error)
                  {
                      if (!success)
                      {
                          super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                      }
                      else
                      {
                      }
                      
                      super.callbackCompleted = YES;
                  }];
             }
             
             
             
         }];
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

/**
 @Unique_TCRef 24S0, 32S0, 32F5 - 32F13
 */
- (void)testCreateFolderWithSpecialCharactersInName
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        __block NSString *description = @"";
        __block NSString *title = @"";
        __block NSString *name = @"NameWIth.and\and/and?and\"and*<and>and|and!";
        NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:2];
        [props setObject:description forKey:@"cm:description"];
        [props setObject:title forKey:@"cm:title"];
        
        // create a new folder in the repository's root folder
        [self.dfService createFolderWithName:name inParentFolder:super.testDocFolder properties:props
                             completionBlock:^(AlfrescoFolder *folder, NSError *error)
         {
             if (nil == folder)
             {
                 super.lastTestSuccessful = YES;
                 log(@"%@",[NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]]);
                 super.callbackCompleted = YES;
             }
             else
             {
                 super.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = @"We should not succeed creating a folder with an empty name";
                 STAssertTrue([folder.name isEqualToString:name], @"folder name should be %@, but instead we got %@",name, folder.name);
                 
                 
                 [self.dfService deleteNode:folder completionBlock:^(BOOL success, NSError *error)
                  {
                      if (!success)
                      {
                          super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                      }
                      else
                      {
                      }
                      
                      super.callbackCompleted = YES;
                  }];
             }
             
             
             
         }];
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

/**
 @Unique_TCRef 22S0, 22S1
 */
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

/**
 @Unique_TCRef 13S5.
 */
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

/**
 @Unique_TCRef 14S1
 */
- (void)testRetrieveChildrenInFolderWithNoChildren
{
    [super runAllSitesTest:^{
       
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
        
        NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:2];
        [properties setObject:@"Test Description" forKey:@"cm:description"];
        [properties setObject:@"Test Title" forKey:@"cm:title"];
        
        [self.dfService createFolderWithName:super.unitTestFolder inParentFolder:super.testDocFolder properties:properties completionBlock:^(AlfrescoFolder *folder, NSError *error) {
            
            if (folder == nil)
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                STAssertNotNil(folder, @"Folder should not be nil");
                STAssertTrue([folder.name isEqualToString:super.unitTestFolder], @"Folder name should be %@", super.unitTestFolder);
                
                // check the properties of the foder are correct
                NSDictionary *newFolderProps = folder.properties;
                AlfrescoProperty *newDescriptionProp = [newFolderProps objectForKey:@"cm:description"];
                AlfrescoProperty *newTitleProp = [newFolderProps objectForKey:@"cm:title"];
                STAssertTrue([newDescriptionProp.value isEqualToString:@"Test Description"], @"cm:description property value does not match");
                STAssertTrue([newTitleProp.value isEqualToString:@"Test Title"], @"cm:title property value does not match");
                
                // serach folder using paging
                AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:100 skipCount:0];
                __block AlfrescoFolder *blockFolder = folder;
                [weakService retrieveChildrenInFolder:blockFolder listingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
                    if (pagingResult == nil)
                    {
                        super.lastTestSuccessful = NO;
                        super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                    }
                    else
                    {
                        STAssertTrue(pagingResult.totalItems == 0, @"Expected 0 folder children, got back %i", pagingResult.totalItems);
                        NSLog(@"total items %i", pagingResult.objects.count);
                        
                        [weakService deleteNode:blockFolder completionBlock:^(BOOL success, NSError *error)
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

/**
 @Unique_TCRef 14F4
 */
- (void)testRetrieveChildrenInFolderWithEmptyPaging
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:0 skipCount:0];
        
        [self.dfService retrieveChildrenInFolder:super.testDocFolder listingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
            
            if (pagingResult == nil)
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                STAssertTrue(pagingResult.totalItems > 0, @"Expected children to be returned");
                NSLog(@"Total Items: %i", pagingResult.objects.count);
                super.lastTestSuccessful = YES;
            }
            super.callbackCompleted = YES;
        }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

/**
 Unique_TCRef 14S3
 */
- (void)testRetrieveChildrenInFolderWithUpdatedContentFirst
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        
        AlfrescoListingContext *pagingAndSort = [[AlfrescoListingContext alloc] initWithMaxItems:10 skipCount:0 sortProperty:kAlfrescoSortByModifiedAt sortAscending:NO];
        
        [self.dfService retrieveChildrenInFolder:super.testDocFolder listingContext:pagingAndSort completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) {
            
            if (pagingResult == nil)
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                STAssertTrue(pagingResult.objects.count > 0, @"Expecting to return more than one result");
                STAssertTrue(pagingResult.objects.count <= 10, @"Expecting a maximum of 10 results, instead got %i", pagingResult.objects.count);
                
                // check if array is sorted correctly
                NSArray *sortedArray = [pagingResult.objects sortedArrayUsingComparator:^(id a, id b) {
                    
                    AlfrescoNode *node1 = (AlfrescoNode *)a;
                    AlfrescoNode *node2 = (AlfrescoNode *)b;
                    
                    return [node2.modifiedAt compare:node1.modifiedAt];
                }];
                
                NSLog(@"Paging Array: %@", pagingResult.objects);
                NSLog(@"Sorted Array: %@", sortedArray);
                
                BOOL isResultSortedAccordingToModifiedDate = [pagingResult.objects isEqualToArray:sortedArray];
                
                STAssertTrue(isResultSortedAccordingToModifiedDate, @"The results where not sorted in descending order according to the modified date");
                
                super.lastTestSuccessful = YES;
            }
            super.callbackCompleted = YES;
        }];
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
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
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        
        NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:4];
        [properties setObject:[kCMISPropertyObjectTypeIdValueDocument stringByAppendingString:@",P:cm:titled,P:cm:author"] forKey:kCMISPropertyObjectTypeId];
        [properties setObject:@"Test Description" forKey:@"cm:description"];
        [properties setObject:@"Test Title" forKey:@"cm:title"];
        [properties setObject:@"Test Author" forKey:@"cm:author"];
        
        __weak AlfrescoDocumentFolderService *weakFolderServer = self.dfService;
        
        // check document with * in the file name
        [self.dfService createDocumentWithName:@"createDocumentTest*.jpg" inParentFolder:super.testDocFolder contentFile:super.testImageFile properties:properties completionBlock:^(AlfrescoDocument *document, NSError *error) {
            if (error == nil)
            {
                STAssertTrue(error != nil, @"Expected an error to be thrown");
                super.lastTestSuccessful = NO;
            }
            else
            {
                NSLog(@"The following error occured trying to create the file: %@ - %@", [error localizedDescription], [error localizedFailureReason]);
                STAssertFalse(document != nil, @"Expected the document not to be created");
                
                // check document with " in the file name
                [weakFolderServer createDocumentWithName:@"createDocumentTest\".jpg" inParentFolder:super.testDocFolder contentFile:super.testImageFile properties:properties completionBlock:^(AlfrescoDocument *document, NSError *error) {
                    if (error == nil)
                    {
                        STAssertTrue(error != nil, @"Expected an error to be thrown");
                        super.lastTestSuccessful = NO;
                    }
                    else
                    {
                        NSLog(@"The following error occured trying to create the file: %@ - %@", [error localizedDescription], [error localizedFailureReason]);
                        STAssertFalse(document != nil, @"Expected the document not to be created");
                        
                        // check document with / and \ in the file name
                        [weakFolderServer createDocumentWithName:@"createDocumentTest\\.jpg" inParentFolder:super.testDocFolder contentFile:super.testImageFile properties:properties completionBlock:^(AlfrescoDocument *document, NSError *error) {
                            if (error == nil)
                            {
                                STAssertTrue(error != nil, @"Expected an error to be thrown");
                                super.lastTestSuccessful = NO;
                            }
                            else
                            {
                                NSLog(@"The following error occured trying to create the file: %@ - %@", [error localizedDescription], [error localizedFailureReason]);
                                STAssertFalse(document != nil, @"Expected the document not to be created");
                                
                                // check document with empty name
                                [weakFolderServer createDocumentWithName:@"createDocument//Test.jpg" inParentFolder:super.testDocFolder contentFile:super.testImageFile properties:properties completionBlock:^(AlfrescoDocument *document, NSError *error) {
                                    if (error == nil)
                                    {
                                        STAssertTrue(error != nil, @"Expected an error to be thrown");
                                        super.lastTestSuccessful = NO;
                                    }
                                    else
                                    {
                                        NSLog(@"The following error occured trying to create the file: %@ - %@", [error localizedDescription], [error localizedFailureReason]);
                                        STAssertFalse(document != nil, @"Expected the document not to be created");
                                        
                                        // check document with empty name
                                        [weakFolderServer createDocumentWithName:@"" inParentFolder:super.testDocFolder contentFile:super.testImageFile properties:properties completionBlock:^(AlfrescoDocument *document, NSError *error) {
                                            if (error == nil)
                                            {
                                                STAssertTrue(error != nil, @"Expected an error to be thrown");
                                                super.lastTestSuccessful = NO;
                                            }
                                            else
                                            {
                                                NSLog(@"The following error occured trying to create the file: %@ - %@", [error localizedDescription], [error localizedFailureReason]);
                                                STAssertFalse(document != nil, @"Expected the document not to be created");
                                                if (!document)
                                                {
                                                    super.lastTestSuccessful = YES;
                                                }
                                            }
                                            super.callbackCompleted = YES;
                                        }
                                        progressBlock:^(NSInteger bytesTransferred, NSInteger bytesTotal) {
                                                                       
                                        }];
                                    }
                                }
                                progressBlock:^(NSInteger bytesTransferred, NSInteger bytesTotal) {
                                                               
                                }];
                            }
                        }
                        progressBlock:^(NSInteger bytesTransferred, NSInteger bytesTotal) {
                                                       
                        }];
                    }
                }
                progressBlock:^(NSInteger bytesTransferred, NSInteger bytesTotal) {
                    
                }];
            }
        }
        progressBlock:^(NSInteger bytesTransferred, NSInteger bytesTotal) {
                                     
        }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

/**
 @Unique_TCRef 24S0
 @Unique_TCRef 13S1.
 */
- (void)testRetrieveFolderWithNoChildren
{
    [super runAllSitesTest:^{
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
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
                 __block AlfrescoFolder *blockFolder = folder;
                 [weakService retrieveChildrenInFolder:blockFolder completionBlock:^(NSArray *children, NSError *error){
                     if(nil == children)
                     {
                         super.lastTestSuccessful = NO;
                         super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                         super.callbackCompleted = YES;
                     }
                     else
                     {
                         STAssertTrue(children.count == 0, @"folder should be empty, instead we get %d entries",children.count);
                         [weakService deleteNode:blockFolder completionBlock:^(BOOL success, NSError *error)
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


/**
 @Unique_TCRef 24S0
 @Unique_TCRef 18S2. 
 */
- (void)testRetrieveFolderWithNoDocuments
{
    [super runAllSitesTest:^{
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
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
                 __block AlfrescoFolder *blockFolder = folder;
                 [weakService retrieveDocumentsInFolder:blockFolder completionBlock:^(NSArray *children, NSError *error){
                     if(nil == children)
                     {
                         super.lastTestSuccessful = NO;
                         super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                         super.callbackCompleted = YES;
                     }
                     else
                     {
                         STAssertTrue(children.count == 0, @"folder should contain no documents, instead we get %d entries",children.count);
                         [weakService deleteNode:blockFolder completionBlock:^(BOOL success, NSError *error)
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

/**
 @Unique_TCRef 24S0
 @Unique_TCRef 20S2
 */
- (void)testRetrieveFolderWithNoFolders
{
    [super runAllSitesTest:^{
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
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
                 __block AlfrescoFolder *blockFolder = folder;
                 [weakService retrieveFoldersInFolder:blockFolder completionBlock:^(NSArray *children, NSError *error){
                     if(nil == children)
                     {
                         super.lastTestSuccessful = NO;
                         super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                         super.callbackCompleted = YES;
                     }
                     else
                     {
                         STAssertTrue(children.count == 0, @"folder should contain no folders, instead we get %d entries",children.count);
                         [weakService deleteNode:blockFolder completionBlock:^(BOOL success, NSError *error)
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



/**
 @Unique_TCRef 14S0
 */
- (void)testRetrieveChildrenInFolderWithPaging
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:1 skipCount:0];
        
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
                 log(@"total items %i", pagingResult.objects.count);
                 
                 super.lastTestSuccessful = YES;
             }
             super.callbackCompleted = YES;
         }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

/**
 @Unique_TCRef 14F5,14F6
 */
- (void)testRetrieveChildrenInFolderWithBogusPaging
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:-1 skipCount:-99];
        
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
                 STAssertTrue(pagingResult.objects.count > 0, @"Expected at least 1 folder children returned, but we got %d instead", pagingResult.objects.count);
                 if (pagingResult.totalItems > 50)
                 {
                     STAssertTrue(pagingResult.hasMoreItems, @"Expected that there are more items left");
                 }
                 else
                 {
                     STAssertFalse(pagingResult.hasMoreItems, @"We should not have more than 50 items in total, but instead we have %d",pagingResult.totalItems);
                 }
                 log(@"total items %i", pagingResult.objects.count);
                 
                 super.lastTestSuccessful = YES;
             }
             super.callbackCompleted = YES;
         }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}



/**
 @Unique_TCRef 15S0
 */
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

/**
 @Unique_TCRef 15F0, 15F1
 */
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

/**
 @Unique_TCRef 18S0
 */
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
                             STAssertFalse([document.title isEqualToString:@""], @"title should NOT be an empty string");
                             STAssertFalse([document.title isEqualToString:@"(null)"], @"title should return string (null)");
                            
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

/**
 @Unique_TCRef 19S0
 */
- (void)testRetrieveDocumentsInFolderWithPaging
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:2 skipCount:1];
        
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

/**
 @Unique_TCRef 19F4, 19F5
 */
- (void)testRetrieveDocumentsInFolderWithBogusPaging
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:-2 skipCount:-1];
        
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
                 STAssertTrue(pagingResult.objects.count > 0, @"Expected more than 0 documents, but instead we got %d",pagingResult.objects.count);
                 STAssertTrue(pagingResult.totalItems > 2, @"Expected more than 2 documents in total");
                 
                 super.lastTestSuccessful = YES;
             }
             super.callbackCompleted = YES;
             
         }];
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

/**
 @Unique_TCRef 20S0
 */

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

/**
 @Unique_TCRef 21S1
 */
- (void)testRetrieveFoldersInFolderWithPaging
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] initWithMaxItems:1 skipCount:0];
        
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

/**
 @Unique_TCRef 17S1
 */
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

/**
 @Unique_TCRef 32S0
 @Unique_TCRef 17F1
 @Unique_TCRef 24S0
 */
- (void)testRetrieveNodeWithIdentifierNonExisting
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
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
                 __block AlfrescoFolder *strongFolder = folder;
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
                          super.callbackCompleted = YES;
                      }
                      else
                      {
                          [weakService retrieveNodeWithIdentifier:strongFolder.identifier completionBlock:^(AlfrescoNode *node, NSError *error){
                              if (nil == node)
                              {
                                  self.lastTestSuccessful = YES;
                                  NSString *errorMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                  log(@"We expected this to fail with %@",errorMessage);
                              }
                              else
                              {
                                  super.lastTestSuccessful = NO;
                                  self.lastTestFailureMessage = @"We expected the folder not to be accessible after we deleted it";
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


/**
 @Unique_TCRef 16S1
 */
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

/**
 @Unique_TCRef 32S0
 @Unique_TCRef 16F1
 @Unique_TCRef 24S0
 */
- (void)testRetrieveNodeWithFolderPathNonExisting
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
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
                 __block NSString *folderPath = [NSString stringWithFormat:@"%@%@",super.testFolderPathName, super.unitTestFolder];
                 // check the properties were added at creation time
                 [self.dfService deleteNode:folder completionBlock:^(BOOL success, NSError *error)
                  {
                      if (!success)
                      {
                          super.lastTestSuccessful = NO;
                          super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                          super.callbackCompleted = YES;
                      }
                      else
                      {
                          [weakService retrieveNodeWithFolderPath:folderPath completionBlock:^(AlfrescoNode *node, NSError *error){
                              if (nil == node)
                              {
                                  self.lastTestSuccessful = YES;
                                  NSString *errorMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                  log(@"We expected this to fail with %@",errorMessage);
                              }
                              else
                              {
                                  super.lastTestSuccessful = NO;
                                  self.lastTestFailureMessage = @"We expected the folder not to be accessible after we deleted it";
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


/**
 @Unique_TCRef 23S2
 */
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


/**
 @Unique_TCRef 18S0
 @Unique_TCRef 27S3
 */
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
                          log(@"progress %i/%i", bytesDownloaded, bytesTotal);
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

/**
 @Unique_TCRef 33S0
 @Unique_TCRef 27F1
 @Unique_TCRef 24S0
 */
- (void)testDownloadDocumentNonExisting
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
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
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
                                       
                                       
                                       __block AlfrescoDocument *strongDocument = document;
                                       
                                       // delete the test document
                                       [weakService deleteNode:document completionBlock:^(BOOL success, NSError *error)
                                        {
                                            if (!success)
                                            {
                                                super.lastTestSuccessful = NO;
                                                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                                super.callbackCompleted = YES;
                                            }
                                            else
                                            {
                                                [weakService retrieveContentOfDocument:strongDocument completionBlock:^(AlfrescoContentFile *contentFile, NSError *error){
                                                    if (nil == contentFile)
                                                    {
                                                        super.lastTestSuccessful = YES;
                                                        NSString *errorMsg = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                                        log(@"Expected failure %@",errorMsg);
                                                    }
                                                    else
                                                    {
                                                        super.lastTestSuccessful = NO;
                                                        super.lastTestFailureMessage = @"We should not be able to get content for a deleted/nonexisting document";
                                                        
                                                    }
                                                    super.callbackCompleted = YES;
                                                } progressBlock:^(NSInteger down, NSInteger total){}];
                                            }
                                        }];
                                   }
                               } progressBlock:^(NSInteger bytesUploaded, NSInteger bytesTotal){
                               }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
    
}



/**
 @Unique_TCRef 33S0
 @Unique_TCRef 24S0
 */
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
 @Unique_TCRef 27S1
 @Unique_TCRef 30S1
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
                         log(@"progress %i/%i", bytesDownloaded, bytesTotal);
                     }];
                }
            }
            
        } progressBlock:^(NSInteger bytesDownloaded, NSInteger bytesTotal) {
            log(@"progress %i/%i", bytesDownloaded, bytesTotal);
        }];
        
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
    
}

/**
 @Unique_TCRef 33S0
 @Unique_TCRef 30F1
 @Unique_TCRef 24S0
 */
- (void)testUpdateContentForDocumentNonExisting
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
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
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
                                       
                                       
                                       __block AlfrescoDocument *strongDocument = document;
                                       
                                       // delete the test document
                                       [weakService deleteNode:document completionBlock:^(BOOL success, NSError *error)
                                        {
                                            if (!success)
                                            {
                                                super.lastTestSuccessful = NO;
                                                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                                super.callbackCompleted = YES;
                                            }
                                            else
                                            {
                                                __block NSString *updatedContent = [NSString stringWithFormat:@"and we added some text."];
                                                NSData *data = [updatedContent dataUsingEncoding:NSASCIIStringEncoding];
                                                __block AlfrescoContentFile *updatedContentFile = [[AlfrescoContentFile alloc] initWithData:data mimeType:@"text/plain"];
                                                [weakService updateContentOfDocument:strongDocument contentFile:updatedContentFile completionBlock:^(AlfrescoDocument *updatedDoc, NSError *error){
                                                    if (nil == updatedDoc)
                                                    {
                                                        super.lastTestSuccessful = YES;
                                                        NSString *errorMsg = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                                        log(@"Expected failure %@",errorMsg);
                                                    }
                                                    else
                                                    {
                                                        super.lastTestSuccessful = NO;
                                                        super.lastTestFailureMessage = @"We should not be able to update a deleted/nonexisting document";
                                                        
                                                    }
                                                    super.callbackCompleted = YES;
                                                } progressBlock:^(NSInteger bytesTransferred, NSInteger bytesTotal){}];
//                                                super.lastTestSuccessful = YES;
                                            }
                                        }];
                                   }
                               } progressBlock:^(NSInteger bytesUploaded, NSInteger bytesTotal){
                               }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
    
}


/*
 @Unique_TCRef 27S1
 @Unique_TCRef 31S1
 */
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
//                          AlfrescoProperty *updatedAuthor = [updatedProps objectForKey:@"cm:author"];
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

/**
 @Unique_TCRef 33S1
 @Unique_TCRef 31F1
 @Unique_TCRef 24S0
 */
- (void)testUpdatePropertiesForDocumentNonExisting
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
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
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
                                       __block NSString *propertyObjectTestValue = @"millenium-dome.jpg";
                                       __block NSMutableDictionary *propDict = [NSMutableDictionary dictionaryWithCapacity:8];
                                       //                 [propDict setObject:[kCMISPropertyObjectTypeIdValueDocument stringByAppendingString:@",P:cm:titled,P:cm:author"]
                                       //                              forKey:kCMISPropertyObjectTypeId];
                                       [propDict setObject:propertyObjectTestValue forKey:kCMISPropertyName];
                                       [propDict setObject:@"updated description" forKey:@"cm:description"];
                                       [propDict setObject:@"updated title" forKey:@"cm:title"];
                                       
                                       
                                       __block AlfrescoDocument *strongDocument = document;
                                       
                                       // delete the test document
                                       [weakService deleteNode:document completionBlock:^(BOOL success, NSError *error)
                                        {
                                            if (!success)
                                            {
                                                super.lastTestSuccessful = NO;
                                                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                                super.callbackCompleted = YES;
                                            }
                                            else
                                            {
                                                [weakService updatePropertiesOfNode:strongDocument properties:propDict completionBlock:^(AlfrescoNode *updatedNode, NSError *error){
                                                    if (nil == updatedNode)
                                                    {
                                                        super.lastTestSuccessful = YES;
                                                        NSString *errorMsg = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                                        log(@"Expected failure %@",errorMsg);
                                                    }
                                                    else
                                                    {
                                                        super.lastTestSuccessful = NO;
                                                        super.lastTestFailureMessage = @"We should not be able to update properties for a deleted node";
                                                        
                                                    }
                                                    super.callbackCompleted = YES;
                                                }];
                                            }
                                        }];
                                   }
                               } progressBlock:^(NSInteger bytesUploaded, NSInteger bytesTotal){
                               }];
        
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
    
}


/*
 @Unique_TCRef 24S1
 */
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

/**
 @Unique_TCRef 32S0 - 32S2
 @Unique_TCRef 24S0
 */
- (void)testDeleteFolderWithContent
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;

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
                 __block AlfrescoFolder *strongFolder = folder;
                 
                 [weakService createFolderWithName:@"SomeTestFolder" inParentFolder:strongFolder properties:props completionBlock:^(AlfrescoFolder *internalFolder, NSError *internalError){
                     if (nil == internalFolder)
                     {
                         super.lastTestSuccessful = NO;
                         super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [internalError localizedDescription], [internalError localizedFailureReason]];
                         super.callbackCompleted = YES;
                     }
                     else
                     {
                         __block AlfrescoFolder *strongInternalFolder = internalFolder;
                         [weakService deleteNode:strongFolder completionBlock:^(BOOL success, NSError *innerError)
                          {
                              if (!success)
                              {
                                  NSString *errorMessage = [NSString stringWithFormat:@"%@ - %@", [innerError localizedDescription], [innerError localizedFailureReason]];
                                  log(@"Expected error %@",errorMessage);
 
                                  [weakService deleteNode:strongInternalFolder completionBlock:^(BOOL internalSuccess, NSError *anotherError){
                                      if (!internalSuccess)
                                      {
                                          super.lastTestSuccessful = NO;
                                          super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [anotherError localizedDescription], [anotherError localizedFailureReason]];
                                          super.callbackCompleted = YES;
                                      }
                                      else
                                      {
                                          [weakService deleteNode:strongFolder completionBlock:^(BOOL innermostSuccess, NSError *innermostError){
                                              if (!innermostSuccess)
                                              {
                                                  super.lastTestSuccessful = NO;
                                                  super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [innermostError localizedDescription], [innermostError localizedFailureReason]];
                                              }
                                              else
                                              {
                                                  self.lastTestSuccessful = YES;
                                                  
                                              }
                                              super.callbackCompleted = YES;
                                          }];
                                      }
                                  }];
                              }
                              else
                              {
                                  super.lastTestSuccessful = NO;
                                  super.lastTestFailureMessage = @"You should not be able to delete a folder with content";
                                  super.callbackCompleted = YES;
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
 @Unique_TCRef 24S0
 @Unique_TCRef 24F0
 */
- (void)testDeleteNodeNonExisting
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        
        // create a new folder in the repository's root folder so we can delete it
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
        
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
                 __block AlfrescoFolder *strongFolder = folder;
                 [weakService deleteNode:folder completionBlock:^(BOOL success, NSError *error)
                  {
                      if (!success)
                      {
                          super.lastTestSuccessful = NO;
                          super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                          super.callbackCompleted = YES;
                      }
                      else
                      {
                          [weakService deleteNode:strongFolder completionBlock:^(BOOL success, NSError *error)
                           {
                               if (!success)
                               {
                                   super.lastTestSuccessful = YES;
                                   NSString *errorMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                   log(@"expected error: %@",errorMessage);
                               }
                               else
                               {
                                   
                                   super.lastTestSuccessful = NO;
                                   super.lastTestFailureMessage = @"We should not be able to delete a node that is already deleted";
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
 @Unique_TCRef 29S2
 @Unique_TCRef 13S0. 
 */
- (void)testThumbnailRenditionImage
{
    [super runAllSitesTest:^{
        
        self.dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:super.currentSession];
        __weak AlfrescoDocumentFolderService *weakSelf = self.dfService;
        
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
                     log(@"*************** testThumbnailRenditionImage ISCLOUD");
                     STAssertTrue([self nodeArray:array containsName:@"Sample Filesrr"], @"Folder children should contain Sample Filesrr");
                 }
                 else
                 {
                     STAssertTrue([self nodeArray:array containsName:@"Sites"], @"Folder children should contain Sites");
                 }
                 AlfrescoDocument *testVersionedDoc = nil;
                 for (AlfrescoNode *node in array)
                 {
                     if ([node isKindOfClass:[AlfrescoDocument class]])
                     {
                         NSString *name = node.name;
                         if ([name isEqualToString:@"versioned-quote.txt"])
                         {
                             log(@"*************** WE FOUND versioned-quote.txt");
                             testVersionedDoc = (AlfrescoDocument *)node;
                         }

                     }
                 }
                 if (nil != testVersionedDoc)
                 {
                     log(@"*************** BEFORE CALLING retrieveRenditionOfNode");
                     [weakSelf retrieveRenditionOfNode:testVersionedDoc renditionName:kAlfrescoThumbnailRendition completionBlock:^(AlfrescoContentFile *contentFile, NSError *error){
                         log(@"*************** IN COMPLETIONBLOCK OF retrieveRenditionOfNode");
                         if (nil == contentFile)
                         {
                             super.lastTestSuccessful = NO;
                             super.lastTestFailureMessage = [NSString stringWithFormat:@"Failed to retrieve thumbnail image. %@ - %@", [error localizedDescription], [error localizedFailureReason]];
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
                 }
                 else
                 {
                     super.lastTestSuccessful = NO;
                     super.lastTestFailureMessage = @"Failed to retrieve versioned-quote.txt file.";
                     super.lastTestSuccessful = YES;                     
                 }
             }
//             super.callbackCompleted = YES;
             
         }];
        [super waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
        
/*
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
 */
    }];
}
 

/*
 @Unique_TCRef 22S0
 @Unique_TCRef 25S0
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


/*
 @Unique_TCRef 25F1
 @Unique_TCRef 33S1
 @Unique_TCRef 24S1
 */
- (void)testRetrievePermissionsOfNodeNonExisting
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
        __weak AlfrescoDocumentFolderService *weakService = self.dfService;
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
                                       
                                                                              
                                       // delete the test document
                                       [weakService deleteNode:document completionBlock:^(BOOL success, NSError *error)
                                        {
                                            if (!success)
                                            {
                                                super.lastTestSuccessful = NO;
                                                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                                super.callbackCompleted = YES;
                                            }
                                            else
                                            {
                                                [weakService retrievePermissionsOfNode:document
                                                                       completionBlock:^(AlfrescoPermissions *perms, NSError *error){
                                                                           if (nil == perms)
                                                                           {
                                                                               super.lastTestSuccessful = YES;
                                                                               NSString *errorMsg = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                                                               log(@"Expected failure %@",errorMsg);
                                                                           }
                                                                           else
                                                                           {
                                                                               super.lastTestSuccessful = NO;
                                                                               super.lastTestFailureMessage = @"We should not be able to get permissions for a deleted/nonexisting document";
                                                                               
                                                                           }
                                                                           super.callbackCompleted = YES;
                                                                       }];
                                            }
                                        }];
                                   }
                               } progressBlock:^(NSInteger bytesUploaded, NSInteger bytesTotal){
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
