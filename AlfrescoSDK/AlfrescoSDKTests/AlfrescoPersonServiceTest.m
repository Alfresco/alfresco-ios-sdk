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

#import "AlfrescoPersonServiceTest.h"

@implementation AlfrescoPersonServiceTest

/*
 @Unique_TCRef 34S1
 */
- (void)testRetrievePersonForUser
{
    if (self.setUpSuccess)
    {
        self.personService = [[AlfrescoPersonService alloc] initWithSession:self.currentSession];
        NSString *identifier = self.userName;
        [self.personService retrievePersonWithIdentifier:identifier completionBlock:^(AlfrescoPerson *person, NSError *error)
         {
             if (nil == person)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = @"Failed to retrieve person.";
             }
             else
             {
                 XCTAssertNotNil(person,@"Person should not be nil");
                 XCTAssertTrue([self.userName isEqualToString:person.identifier],@"person.username is %@ but should be %@", person.identifier, self.userName);
                 XCTAssertTrue([self.firstName isEqualToString:person.firstName],@"person.username is %@ but should be %@", person.firstName, self.firstName);
                 XCTAssertNotNil(person.lastName, @"Persons last name should not be nil");
                 XCTAssertNotNil(person.fullName, @"Persons full name sbould not be nil");
                 if (person.avatarIdentifier)
                 {
                     XCTAssertTrue([person.avatarIdentifier length] > 0, @"Avatar length should be longer than 0");
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

/*
 @Unique_TCRef 34F1
 */
- (void)testRetrievePersonForUserNonExisting
{
    if (self.setUpSuccess)
    {
        self.personService = [[AlfrescoPersonService alloc] initWithSession:self.currentSession];
        NSString *identifier = @"admin2";
        if (self.isCloud)
        {
            identifier = @"peter.schmidt2@alfresco.com";
        }
        [self.personService retrievePersonWithIdentifier:identifier completionBlock:^(AlfrescoPerson *person, NSError *error)
         {
             if (nil == person)
             {
                 self.lastTestSuccessful = YES;
             }
             else
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = @"Should not get back a Person for a non existing user.";
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
 @Unique_TCRef 34S1
 @Unique_TCRef 35S2
 */
- (void)testRetrieveAvatarForPerson
{
    if (self.setUpSuccess)
    {
        self.personService = [[AlfrescoPersonService alloc] initWithSession:self.currentSession];
        //        __weak AlfrescoPersonService *weakPersonService = self.personService;
        
        // get thumbnail
        [self.personService retrievePersonWithIdentifier:self.userName completionBlock:^(AlfrescoPerson *person, NSError *error)
         {
             if (nil == person)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = @"Failed to retrieve person.";
                 self.callbackCompleted = YES;
             }
             else
             {
                 XCTAssertNotNil(person,@"Person should not be nil");
                 XCTAssertTrue([self.userName isEqualToString:person.identifier], @"person.username is %@ but should be %@", person.identifier, self.userName);
                 XCTAssertTrue([self.firstName isEqualToString:person.firstName], @"person.username is %@ but should be %@", person.firstName, self.firstName);
                 
                 [self.personService retrieveAvatarForPerson:person completionBlock:^(AlfrescoContentFile *contentFile, NSError *error)
                  {
                      if (nil == contentFile)
                      {
                          self.lastTestSuccessful = NO;
                          self.lastTestFailureMessage = @"Failed to retrieve avatar image.";
                      }
                      else
                      {
                          NSError *fileError = nil;
                          NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:[contentFile.fileUrl path] error:&fileError];
                          XCTAssertNil(fileError, @"expected to get no error in getting attributes for file at path %@", [contentFile.fileUrl path]);
                          unsigned long long size = [[dict valueForKey:NSFileSize] unsignedLongLongValue];
                          XCTAssertTrue(size > 100, @"data should be filled with at least 100 bytes. Instead we got %llu", size);
                          /*
                           mimeType is not a reliable test here. For OnPremise we set the mimeType after downloading the image. For Cloud however, we do not
                           know the mimeType, neither can we deduce it from the filename (as the image is simply called 'avatar')
                           XCTAssertNotNil(contentFile.mimeType, @"mimetype should not be nil");
                           XCTAssertFalse([contentFile.mimeType length] == 0, @"mimetype should not have a length of 0");
                           */
                          
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
 Test searching people
 */
- (void)testSearchPeople
{
    if (self.setUpSuccess)
    {
        self.personService = [[AlfrescoPersonService alloc] initWithSession:self.currentSession];
        
        if (self.isCloud)
        {
            @try
            {
                [self.personService searchWithKeywords:self.userName completionBlock:nil];
                
                // if we get here the exception was not thrown
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = @"Expected an exception to be thrown as searchWithKeywords is not implemented on the Cloud";
            }
            @catch (NSException *exception)
            {
                self.lastTestSuccessful = YES;
            }
            @finally
            {
                self.callbackCompleted = YES;
            }
            
            XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
        }
        else
        {
            [self.personService searchWithKeywords:self.userName completionBlock:^(NSArray *array, NSError *error) {
                 if (nil == array)
                 {
                     self.lastTestSuccessful = NO;
                     self.lastTestFailureMessage = @"Failed to retrieve person.";
                 }
                 else
                 {
                     XCTAssertNotNil(array,@"Array should not be nil");
                     // Might get multiple search results, so enumerate and find the one we're looking for
                     __block AlfrescoPerson *person = nil;
                     [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                         if ([[(AlfrescoPerson *)obj identifier] isEqualToString:self.userName])
                         {
                             person = (AlfrescoPerson *)obj;
                             *stop = YES;
                         }
                     }];
                     XCTAssertTrue([self.userName isEqualToString:person.identifier],@"person.username is %@ but should be %@", person.identifier, self.userName);
                     XCTAssertTrue([self.firstName isEqualToString:person.firstName],@"person.username is %@ but should be %@", person.firstName, self.firstName);
                     XCTAssertNotNil(person.lastName, @"Persons last name should not be nil");
                     XCTAssertNotNil(person.fullName, @"Persons full name sbould not be nil");
                     if (person.avatarIdentifier)
                     {
                         XCTAssertTrue([person.avatarIdentifier length] > 0, @"Avatar length should be longer than 0");
                     }
                     self.lastTestSuccessful = YES;
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

@end
