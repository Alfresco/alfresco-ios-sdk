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
#import "AlfrescoContentFile.h"

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
                 STAssertNotNil(person,@"Person should not be nil");
                 STAssertTrue([self.userName isEqualToString:person.identifier],@"person.username is %@ but should be %@", person.identifier, self.userName);
                 STAssertTrue([self.firstName isEqualToString:person.firstName],@"person.username is %@ but should be %@", person.firstName, self.firstName);
                 STAssertNotNil(person.lastName, @"Persons last name should not be nil");
                 STAssertNotNil(person.fullName, @"Persons full name sbould not be nil");
                 if (person.avatarIdentifier)
                 {
                     STAssertTrue([person.avatarIdentifier length] > 0, @"Avatar length should be longer than 0");
                 }
                 self.lastTestSuccessful = YES;
             }
             self.callbackCompleted = YES;
         }];
        [self waitUntilCompleteWithFixedTimeInterval];
        
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
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
        
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
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
                 STAssertNotNil(person,@"Person should not be nil");
                 STAssertTrue([self.userName isEqualToString:person.identifier], @"person.username is %@ but should be %@", person.identifier, self.userName);
                 STAssertTrue([self.firstName isEqualToString:person.firstName], @"person.username is %@ but should be %@", person.firstName, self.firstName);
                 
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
                          STAssertNil(fileError, @"expected to get no error in getting attributes for file at path %@", [contentFile.fileUrl path]);
                          unsigned long long size = [[dict valueForKey:NSFileSize] unsignedLongLongValue];
                          STAssertTrue(size > 100, @"data should be filled with at least 100 bytes. Instead we got %llu", size);
                          /*
                           mimeType is not a reliable test here. For OnPremise we set the mimeType after downloading the image. For Cloud however, we do not
                           know the mimeType, neither can we deduce it from the filename (as the image is simply called 'avatar')
                           STAssertNotNil(contentFile.mimeType, @"mimetype should not be nil");
                           STAssertFalse([contentFile.mimeType length] == 0, @"mimetype should not have a length of 0");
                           */
                          
                          self.lastTestSuccessful = YES;
                      }
                      self.callbackCompleted = YES;
                      
                  }];
             }
         }];
        
        
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
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
        [self.personService search:@"b" completionBlock:^(NSArray *array, NSError *error) {
             if (nil == array)
             {
                 self.lastTestSuccessful = NO;
                 self.lastTestFailureMessage = @"Failed to retrieve person.";
             }
             else
             {
                 STAssertNotNil(array,@"Array should not be nil");
                 /*
                 STAssertTrue([self.userName isEqualToString:person.identifier],@"person.username is %@ but should be %@", person.identifier, self.userName);
                 STAssertTrue([self.firstName isEqualToString:person.firstName],@"person.username is %@ but should be %@", person.firstName, self.firstName);
                 STAssertNotNil(person.lastName, @"Persons last name should not be nil");
                 STAssertNotNil(person.fullName, @"Persons full name sbould not be nil");
                 if (person.avatarIdentifier)
                 {
                     STAssertTrue([person.avatarIdentifier length] > 0, @"Avatar length should be longer than 0");
                 }
                  */
                 self.lastTestSuccessful = YES;
             }
             self.callbackCompleted = YES;
         }];
        [self waitUntilCompleteWithFixedTimeInterval];
        
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testUpdateProfile
{
    if (self.setUpSuccess)
    {
        self.personService = [[AlfrescoPersonService alloc] initWithSession:self.currentSession];
        
        NSString *jobTitle = @"Software Engineer";
        NSString *location = @"London";
        NSString *description = @"Developing people APIs";

        NSDictionary *newProperties = @{kAlfrescoPersonPropertyJobTitle: jobTitle, kAlfrescoPersonPropertyLocation: location, kAlfrescoPersonPropertyDescription: description};

        [self.personService updateProfile:newProperties completionBlock:^(AlfrescoPerson *person, NSError *error) {
          
            if (nil == person)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = @"Failed to retrieve person.";
            }
            else
            {
                 STAssertTrue([person.jobTitle isEqualToString:jobTitle],@"person.jobTitle is %@ but should be %@", person.jobTitle, jobTitle);
                 STAssertTrue([person.location isEqualToString:location],@"person.location is %@ but should be %@", person.location, location);
                 //STAssertTrue([person.description isEqualToString:description],@"person.description is %@ but should be %@", person.description, description);
                
                self.lastTestSuccessful = YES;
            }
            self.callbackCompleted = YES;
        }];
        [self waitUntilCompleteWithFixedTimeInterval];
        
        STAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}


@end
