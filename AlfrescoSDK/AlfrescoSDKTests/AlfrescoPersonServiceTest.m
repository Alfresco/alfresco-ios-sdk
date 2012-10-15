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

#import "AlfrescoPersonServiceTest.h"
#import "AlfrescoContentFile.h"

@implementation AlfrescoPersonServiceTest
@synthesize personService = _personService;

/*
 @Unique_TCRef 34S1
 */
- (void)testRetrievePersonForUser
{
    [super runAllSitesTest:^{
        self.personService = [[AlfrescoPersonService alloc] initWithSession:super.currentSession];
        NSString *identifier = super.userName;
        log(@"we are testing the Repo service for user %@",identifier);
        [self.personService retrievePersonWithIdentifier:identifier completionBlock:^(AlfrescoPerson *person, NSError *error)
         {
             if (nil == person) 
             {
                 log(@"person returned nil");
                 super.lastTestSuccessful = NO;
                 super.lastTestFailureMessage = @"Failed to retrieve person.";
             }
             else 
             {
                 log(@"person returned is %@ and first name is %@",person.identifier, person.firstName);
                 STAssertNotNil(person,@"Person should not be nil");
                 STAssertTrue([self.userName isEqualToString:person.identifier],[NSString stringWithFormat:@"person.username is %@ but should be %@",person.identifier, super.userName]);
                 STAssertTrue([self.firstName isEqualToString:person.firstName],[NSString stringWithFormat:@"person.username is %@ but should be %@",person.firstName, super.firstName]);
                 STAssertNotNil(person.lastName, @"Persons last name should not be nil");
                 STAssertNotNil(person.fullName, @"Persons full name sbould not be nil");
                 if (person.avatarIdentifier)
                 {
                     STAssertTrue([person.avatarIdentifier length] > 0, @"Avatar length should be longer than 0");
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
 @Unique_TCRef 34F1
 */
- (void)testRetrievePersonForUserNonExisting
{
    [super runAllSitesTest:^{
        self.personService = [[AlfrescoPersonService alloc] initWithSession:super.currentSession];
        NSString *identifier = @"admin2";
        if (self.isCloud)
        {
            identifier = @"peter.schmidt2@alfresco.com";
        }
        log(@"we are testing the Repo service for user %@",identifier);
        [self.personService retrievePersonWithIdentifier:identifier completionBlock:^(AlfrescoPerson *person, NSError *error)
         {
             if (nil == person)
             {
                 log(@"person returned nil");
                 super.lastTestSuccessful = YES;
                 NSString *errorMsg = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                 log(@"Expected error %@",errorMsg);
             }
             else
             {
                 super.lastTestSuccessful = NO;
                 super.lastTestFailureMessage = @"Should not get back a Person for a non existing user.";
             }
             super.callbackCompleted = YES;
         }];
        [super waitUntilCompleteWithFixedTimeInterval];
        
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}


/*
 @Unique_TCRef 34S1
 @Unique_TCRef 35S2
 */
- (void)testRetrieveAvatarForPerson
{
    [super runAllSitesTest:^{
        
        self.personService = [[AlfrescoPersonService alloc] initWithSession:super.currentSession];
        __weak AlfrescoPersonService *weakPersonService = self.personService;
        
        // get thumbnail
        [self.personService retrievePersonWithIdentifier:super.userName completionBlock:^(AlfrescoPerson *person, NSError *error)
         {
             if (nil == person)
             {
                 log(@"person returned nil");
                 super.lastTestSuccessful = NO;
                 super.lastTestFailureMessage = @"Failed to retrieve person.";
                 super.callbackCompleted = YES;
             }
             else
             {
                 log(@"person returned is %@ and first name is %@",person.identifier, person.firstName);
                 STAssertNotNil(person,@"Person should not be nil");
                 STAssertTrue([self.userName isEqualToString:person.identifier],[NSString stringWithFormat:@"person.username is %@ but should be %@",person.identifier, super.userName]);
                 STAssertTrue([self.firstName isEqualToString:person.firstName],[NSString stringWithFormat:@"person.username is %@ but should be %@",person.firstName, super.firstName]);

                 [weakPersonService retrieveAvatarForPerson:person completionBlock:^(AlfrescoContentFile *contentFile, NSError *error)
                  {
                      if (nil == contentFile)
                      {
                          super.lastTestSuccessful = NO;
                          super.lastTestFailureMessage = @"Failed to retrieve avatar image.";
                      }
                      else
                      {
                          NSError *fileError = nil;
                          NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:[contentFile.fileUrl path] error:&fileError];
                          STAssertNil(fileError, @"expected to get no error in getting attributes for file at path %@", [contentFile.fileUrl path]);
                          unsigned long long size = [[dict valueForKey:NSFileSize] unsignedLongLongValue];
                          STAssertTrue(size > 100, @"data should be filled with at least 100 bytes. Instead we got %llu", size);
                          STAssertNotNil(contentFile.mimeType, @"mimetype should not be nil");
                          STAssertFalse([contentFile.mimeType length] == 0, @"mimetype should not have a length of 0");
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


@end
