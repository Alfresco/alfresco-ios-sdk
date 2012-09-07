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
                 super.lastTestSuccessful = YES;
             }
             super.callbackCompleted = YES;
         }];
        [super waitUntilCompleteWithFixedTimeInterval];
        
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

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
                          NSData *data = [[NSFileManager defaultManager] contentsAtPath:[contentFile.fileUrl path]];
                          STAssertNotNil(data, @"data should not be nil");
                          STAssertTrue(contentFile.length > 100, @"data should be filled");
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
