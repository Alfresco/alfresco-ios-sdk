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

#import "AlfrescoSessionTest.h"
#import "AlfrescoListingContext.h"
#import "AlfrescoOAuthData.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoDocumentFolderService.h"
#import "AlfrescoRequest.h"
#import "AlfrescoErrors.h"
#import "AlfrescoLog.h"
@implementation AlfrescoSessionTest

#pragma mark - AlfrescoRepository Specific Tests
/*
 @Unique_TCRef 77F8
 */
- (void)testConnectWithURLWithInvalidCredentials
{
    if (self.setUpSuccess)
    {
        if (!self.isCloud)
        {
            NSString *invalidUserName = @"RepositorySessionTest";
            NSString *invalidPassword = @"12345";
            
            [AlfrescoRepositorySession connectWithUrl:[NSURL URLWithString:self.server]
                                             username:invalidUserName
                                             password:invalidPassword
                                           parameters:nil
                                      completionBlock:^(id<AlfrescoSession> session, NSError *error){
                                          if (error != nil)
                                          {
                                              STAssertNotNil(error, @"Expected an invalid credentials error to be thrown");
                                              STAssertNil(session, @"Expected a session not to be created");
                                              NSLog(@"Desc: %@, Reason: %@", [error localizedDescription], [error localizedFailureReason]);
                                              self.lastTestSuccessful = YES;
                                          }
                                          else
                                          {
                                              self.lastTestSuccessful = NO;
                                          }
                                          self.callbackCompleted = YES;
                                      }];
            [self waitUntilCompleteWithFixedTimeInterval];
            STAssertTrue(self.lastTestSuccessful, @"OnPremise Session authentication succeeded with invalid credentials");
        }
    }
    else
    {
        STFail(@"We could not run this test case");
    }
}

#pragma mark - Cloud Specific Tests
/*
 @Unique_TCRef 70S1
 @Unique_TCRef 70S0
 */

 // Commented until MOBSDK-543 is resolved

/*
- (void)testRetrieveNetworks
{
    [self runAllSitesTest:^{
        
        if (self.isCloud)
        {
            [(AlfrescoCloudSession *)self.currentSession retrieveNetworksWithCompletionBlock:^(NSArray *array, NSError *error) {
                
                if (array == nil || error != nil)
                {
                    self.lastTestSuccessful = NO;
                    self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                    self.callbackCompleted = YES;
                }
                else
                {
                    self.lastTestSuccessful = YES;
                    AlfrescoLogDebug(@"testRetrieveNetworksTest");
                    AlfrescoLogDebug(@"%@", array);
                    
                    for (AlfrescoCloudNetwork *network in array)
                    {
                        AlfrescoLogDebug(@"identifier: %@", network.identifier);
                        AlfrescoLogDebug(@"isHomeNetwork: %i", network.isHomeNetwork);
                        AlfrescoLogDebug(@"isPaidNetwork: %i", network.isPaidNetwork);
                        AlfrescoLogDebug(@"subscriptionLevel: %@", network.subscriptionLevel);
                        AlfrescoLogDebug(@"createdAt: %@", network.createdAt);
                        AlfrescoLogDebug(@"\n\n");
                        
                        STAssertTrue(network.isHomeNetwork, @"network is home network");
                        STAssertNotNil(network.createdAt, @"createdAt property is set");
                    }
                    self.callbackCompleted = YES;
                }
                STAssertTrue(self.lastTestSuccessful, @"Unable to retrieve networks for the current cloud session");
            }];
        }
        
    }];
}
 */

/*
 @Unique_TCRef 74F1
 @Unique_TCRef 75S1
 */
- (void)testRemoveNonExistantParameter
{
    if (self.setUpSuccess)
    {
        if (self.isCloud)
        {
            NSString *nonExistantKeyToRemove = @"testRemoveNonExistantParameter";
            
            NSArray *allParameters = [self.currentSession allParameterKeys];
            
            STAssertNotNil(allParameters, @"Expected parameters not to be nil");
            STAssertTrue([allParameters count] >= 1, @"Expected atleast one paramenter to be returned");
            
            // get the size of the parameters array
            NSUInteger originalNumberOfParameterKeys = [allParameters count];
            
            // attempt to remove non existant parameter
            [self.currentSession removeParameter:nonExistantKeyToRemove];
            
            STAssertTrue(originalNumberOfParameterKeys == [[self.currentSession allParameterKeys] count], @"Removing a non existant parameter seems to have alterered the state of the session's parameters");
            
            // if they are the same. nothing was removed
            if (originalNumberOfParameterKeys == [[self.currentSession allParameterKeys] count])
            {
                self.lastTestSuccessful = YES;
            }
            else
            {
                self.lastTestSuccessful = NO;
            }
            
            STAssertTrue(self.lastTestSuccessful, @"Session base URL did not match that used in the creation of the session");
        }
    }
    else
    {
        STFail(@"We could not run this test case");
    }
}

#pragma mark - Generic Tests
/*
 @Unique_TCRef 79S1
 @Unique_TCRef 62S1
 */
- (void)testRetrieveBaseURL
{
    if (self.setUpSuccess)
    {
        NSURL *sessionBaseURL = [self.currentSession baseUrl];
        STAssertNotNil(sessionBaseURL, @"Expected the base url in the session not to be nil");
        STAssertNotNil(self.server, @"The server base url is nil");
        NSLog(@"Session Base URL is: %@ \nServer is: %@", sessionBaseURL, self.server);
        
        NSString *urlToTest = nil;
        if (!self.isCloud)
        {
            urlToTest = [sessionBaseURL absoluteString];
        }
        else
        {
            urlToTest = [NSString stringWithFormat:@"%@://%@", [sessionBaseURL scheme], [sessionBaseURL host]];
        }
        
        STAssertNotNil(urlToTest, @"The url to test is nil");
        STAssertTrue([self.server isEqualToString:urlToTest], @"Expected the baseURL in the session to be the same as that used to create the session");
        
        if ([self.server isEqualToString:urlToTest])
        {
            self.lastTestSuccessful = YES;
        }
        else
        {
            self.lastTestSuccessful = NO;
        }
        STAssertTrue(self.lastTestSuccessful, @"Session base URL did not match that used in the creation of the session");
    }
    else
    {
        STFail(@"We could not run this test case");
    }
}

/*
 @Unique_TCRef 80S1
 @Unique_TCRef 63S1
 */
- (void)testRetrievePersonalIdentifier
{
    if (self.setUpSuccess)
    {
        NSString *sessionPersonalIdentifier = [self.currentSession personIdentifier];
        STAssertNotNil(sessionPersonalIdentifier, @"Personal Identifier in the session is nil");
        STAssertNotNil(self.userName, @"Username is nil");
        STAssertTrue([self.userName isEqualToString:sessionPersonalIdentifier], @"The appropriate person identifer for the logged in user was not returned");
        
        if ([self.userName isEqualToString:sessionPersonalIdentifier])
        {
            self.lastTestSuccessful = YES;
        }
        else
        {
            self.lastTestSuccessful = NO;
        }
        STAssertTrue(self.lastTestSuccessful, @"OnPremise Session did not return the appropriate personal identifier");
    }
    else
    {
        STFail(@"We could not run this test case");
    }
}

/*
 @Unique_TCRef 81S1
 @Unique_TCRef 64S1
 */
- (void)testRetrieveDefaultListingContext
{
    if (self.setUpSuccess)
    {
        AlfrescoListingContext *defaultListingContext = [self.currentSession defaultListingContext];
        
        NSInteger expectedMaxItems = 50;
        NSInteger expectedSkipCount = 0;
        
        STAssertNotNil(defaultListingContext, @"Expected a default listing context within the current session");
        STAssertNil(defaultListingContext.sortProperty, @"Expected the default sort property to be nil");
        STAssertTrue(defaultListingContext.sortAscending, @"Expected the default sort to be set to ascending, instead got descending");
        STAssertTrue(defaultListingContext.maxItems == expectedMaxItems, @"Expected the default max items to be set to %i instead got %i", expectedMaxItems, defaultListingContext.maxItems);
        STAssertTrue(defaultListingContext.skipCount == expectedSkipCount, @"Expected the default skip count to be %i, instead got %i", expectedSkipCount, defaultListingContext.skipCount);
        
        if (!defaultListingContext.sortProperty && defaultListingContext.sortAscending && defaultListingContext.maxItems == 50 && defaultListingContext.skipCount == 0)
        {
            self.lastTestSuccessful = YES;
        }
        else
        {
            self.lastTestSuccessful = NO;
        }
        STAssertTrue(self.lastTestSuccessful, @"The session's default listing context state was not as expected");
    }
    else
    {
        STFail(@"We could not run this test case");
    }
}

/*
 @Unique_TCRef 83S1
 @Unique_TCRef 66S1
 */
- (void)testRetrieveRootFolder
{
    if (self.setUpSuccess)
    {
        AlfrescoFolder *sessionRootFolder = [self.currentSession rootFolder];
        
        STAssertNotNil(sessionRootFolder, @"Expected the root folder in the session not to be nil");
        STAssertNotNil([[[sessionRootFolder properties] objectForKey:@"cmis:path"] value], @"Expected the path to the root folder not to be nil");
        STAssertNotNil([[[sessionRootFolder properties] objectForKey:@"cmis:objectId"] value], @"Expected the objectId not to be nil");
        STAssertNotNil([[[sessionRootFolder properties] objectForKey:@"cmis:objectTypeId"] value], @"Expected the objectTypeId not to be nil");
        STAssertTrue([[[[sessionRootFolder properties] objectForKey:@"cmis:objectTypeId"] value] isEqualToString:@"cmis:folder"], @"Expected the objectTypeID to be a cmis folder type");
        
        if (sessionRootFolder &&
            [[[sessionRootFolder properties] objectForKey:@"cmis:path"] value] &&
            [[[sessionRootFolder properties] objectForKey:@"cmis:objectId"] value] &&
            [[[sessionRootFolder properties] objectForKey:@"cmis:objectTypeId"] value] &&
            [[[[sessionRootFolder properties] objectForKey:@"cmis:objectTypeId"] value] isEqualToString:@"cmis:folder"])
        {
            self.lastTestSuccessful = YES;
        }
        else
        {
            self.lastTestSuccessful = NO;
        }
        STAssertTrue(self.lastTestSuccessful, @"The session's root folder did not return correct values");
    }
    else
    {
        STFail(@"We could not run this test case");
    }
}

/*
 @Unique_TCRef 84S1
 @Unique_TCRef 67S1
- (void)testSessionDisconnection
{
    [self removeTestDocument];
    [self runAllSitesTest:^{

//        AlfrescoRepositorySession *currentSession = self.currentSession;
        
        STAssertNotNil(self.currentSession.personIdentifier, @"Expected the personal identifier to not be nil before disconnection");
        STAssertNotNil(self.currentSession.repositoryInfo, @"Expected the repository info to not be nil before disconnection");
        STAssertNotNil(self.currentSession.baseUrl, @"Expected the base URL to not be nil before disconnection");
        STAssertNotNil(self.currentSession.rootFolder, @"Expected the root folder to not be nil before disconnection");
        STAssertNotNil(self.currentSession.defaultListingContext, @"Expected the default listing context to not be nil before disconnection");
        
        
        
        // disconnect the session
        [self.currentSession disconnect];
        
        STAssertNil(self.currentSession.personIdentifier, @"Expected the personal identifier to to be cleared out after disconnection");
        STAssertNil(self.currentSession.repositoryInfo, @"Expected the repository info to to be cleared out after disconnection");
        STAssertNil(self.currentSession.baseUrl, @"Expected the base URL to to be cleared out after disconnection");
        STAssertNil(self.currentSession.rootFolder, @"Expected the root folder to to be cleared out after disconnection");
        STAssertNil(self.currentSession.defaultListingContext, @"Expected the default listing context to to be cleared out after disconnection");
        
        if (!self.currentSession.personIdentifier &&
            !self.currentSession.repositoryInfo &&
            !self.currentSession.baseUrl &&
            !self.currentSession.rootFolder &&
            !self.currentSession.defaultListingContext)
        {
            self.lastTestSuccessful = YES;
        }
        else
        {
            self.lastTestSuccessful = NO;
        }
        
        STAssertTrue(self.lastTestSuccessful, @"The session did not clear out the session variables after disconnection");
    }];
}
 */

/*
 @Unique_TCRef 84S2
 @Unique_TCRef 72F1
 @Unique_TCRef 72F2
 */
- (void)testAddDuplicateParameterToSession
{
    if (self.setUpSuccess)
    {
        // add a value to the current session
        NSString *key = @"testAddParameterToSession";
        NSNumber *firstValue = [NSNumber numberWithInt:100];
        NSNumber *secondValue = [NSNumber numberWithInt:200];
        int expectedReturnValue = [secondValue intValue];
        
        // add first object followed by the overwriting one
        [self.currentSession setObject:firstValue forParameter:key];
        
        STAssertNotNil([self.currentSession objectForParameter:key], @"The session does not contain any value for the key %@", key);
        
        [self.currentSession setObject:secondValue forParameter:key];
        
        STAssertNotNil([self.currentSession objectForParameter:key], @"The The session does not contain any value for the key %@", key);
        STAssertTrue([[self.currentSession objectForParameter:key] intValue] == expectedReturnValue, @"Expected the value for the parameter %@ to be %i, but instead got back %i", key, expectedReturnValue, [[self.currentSession objectForParameter:key] intValue]);
        
        if ([[self.currentSession objectForParameter:key] intValue] == expectedReturnValue)
        {
            self.lastTestSuccessful = YES;
        }
        else
        {
            self.lastTestSuccessful = NO;
        }
        STAssertTrue(self.lastTestSuccessful, @"The OnPremise Session did not overwrite the value for an existing key");
    }
    else
    {
        STFail(@"We could not run this test case");
    }
}

/*
 @Unique_TCRef 85S9
 @Unique_TCRef 86S7
 @Unique_TCRef 87S5
 @Unique_TCRef 72S7
 @Unique_TCRef 73S7
 @Unique_TCRef 74S5
 */
- (void)testAddAndRemoveCustomObjectParameterToSession
{
    if (self.setUpSuccess)
    {
        int expectedMaxItems = 123;
        int expectedSkipCount = 3;
        
        // Add the custom object
        AlfrescoListingContext *listingContextObject = [[AlfrescoListingContext alloc] initWithMaxItems:expectedMaxItems skipCount:expectedSkipCount];
        
        NSString *key = @"testAddAndRemoveCustomObjectParameterToSession";
        
        [self.currentSession setObject:listingContextObject forParameter:key];
        
        STAssertNotNil([self.currentSession objectForParameter:key], @"The session does not contain any value for the key %@", key);
        
        // Attempt to retrieve the item set
        AlfrescoListingContext *returnedListingContextObject = (AlfrescoListingContext *)[self.currentSession objectForParameter:key];
        
        STAssertNotNil(returnedListingContextObject, @"Expected a listing object to be returned for the key", key);
        STAssertTrue(returnedListingContextObject.maxItems == expectedMaxItems, @"Expected the max items in the listing context stored in the session to return %i, but instead got %i", expectedMaxItems, returnedListingContextObject.maxItems);
        STAssertTrue(returnedListingContextObject.skipCount == expectedSkipCount, @"Expected the skip count in the listing context stored in the session to return %i, but instead got %i", expectedSkipCount, returnedListingContextObject.skipCount);
        
        NSArray *allParamKeys = [self.currentSession allParameterKeys];
        BOOL availableInSession = [allParamKeys containsObject:key];
        
        if (returnedListingContextObject.maxItems == expectedMaxItems && returnedListingContextObject.skipCount == expectedSkipCount && availableInSession)
        {
            // attempt to remove the object
            [self.currentSession removeParameter:key];
            
            id removedObject = [self.currentSession objectForParameter:key];
            
            STAssertNil(removedObject, @"The object should have been removed from the parameters");
            
            if (!removedObject)
            {
                self.lastTestSuccessful = YES;
            }
        }
        else
        {
            self.lastTestSuccessful = NO;
        }
        STAssertTrue(self.lastTestSuccessful, @"The session did not overwrite the value for an existing key");
    }
    else
    {
        STFail(@"We could not run this test case");
    }
}

/*
 @Unique_TCRef 86F1
 @Unique_TCRef 73F1
 */
- (void)testRetrieveNonExistantParameter
{
    if (self.setUpSuccess)
    {
        NSString *key = @"testRetrieveNonExistantParameter";
        
        id returnedObject = [self.currentSession objectForParameter:key];
        
        STAssertNil(returnedObject, @"There is no key value pair in the parameters for the current session with the key %@, however, an object was returned from objectForParameter:", key);
        
        if (!returnedObject)
        {
            self.lastTestSuccessful = YES;
        }
        else
        {
            self.lastTestSuccessful = NO;
        }
        STAssertTrue(self.lastTestSuccessful, @"The session does not contain an object for the key provided, but still returned a value");
    }
    else
    {
        STFail(@"We could not run this test case");
    }
}

/*
 @Unique_TCRef 76S0
 @Unique_TCRef 76S1
 */
- (void)testAddingDictionaryParametersToSession
{
    if (self.setUpSuccess)
    {
        id alfrescoAuthenticationProviderObject_before = [self.currentSession objectForParameter:kAlfrescoAuthenticationProviderObjectKey];
        id alfrescoGenerateThumbnails_before = [self.currentSession objectForParameter:kAlfrescoThumbnailCreation];
        id alfrescoSessionKey_before = [self.currentSession objectForParameter:kAlfrescoSessionKeyCmisSession];
        id alfrescoExtractMetadata_before = [self.currentSession objectForParameter:kAlfrescoMetadataExtraction];
        
        NSDictionary *test = @{@"firstParam": @"Param1", @"secondParam" : @"Param2", @"thirdParam" : @"Param3"};
        [self.currentSession addParametersFromDictionary:test];
        
        id alfrescoAuthenticationProviderObject_after = [self.currentSession objectForParameter:kAlfrescoAuthenticationProviderObjectKey];
        id alfrescoGenerateThumbnails_after = [self.currentSession objectForParameter:kAlfrescoThumbnailCreation];
        id alfrescoSessionKey_after = [self.currentSession objectForParameter:kAlfrescoSessionKeyCmisSession];
        id alfrescoExtractMetadata_after = [self.currentSession objectForParameter:kAlfrescoMetadataExtraction];
        
        STAssertEqualObjects([self.currentSession objectForParameter:@"firstParam"], test[@"firstParam"], @"Testing if param was added to session and has expected value");
        STAssertEqualObjects([self.currentSession objectForParameter:@"secondParam"], test[@"secondParam"], @"Testing if param was added to session and has expected value");
        STAssertEqualObjects([self.currentSession objectForParameter:@"thirdParam"], test[@"thirdParam"], @"Testing if param was added to session and has expected value");
        
        STAssertEqualObjects(alfrescoAuthenticationProviderObject_before, alfrescoAuthenticationProviderObject_after, @"checking session authentication provider parameter before adding dictionary parameters and after");
        STAssertEqualObjects(alfrescoGenerateThumbnails_before, alfrescoGenerateThumbnails_after, @"checking generate thumbnails session parameter before adding dictionary parameters and after");
        STAssertEqualObjects(alfrescoSessionKey_before, alfrescoSessionKey_after, @"checking session key parameter before adding dictionary parameters and after");
        STAssertEqualObjects(alfrescoExtractMetadata_before, alfrescoExtractMetadata_after, @"checking extract metadata parameter before adding dictionary parameters and after");
        
        self.lastTestSuccessful = YES;
        
        
        STAssertTrue(self.lastTestSuccessful, @"Added all the objects from the given dictionary to the session. Checked that the parameters / values are as desired");
    }
    else
    {
        STFail(@"We could not run this test case");
    }
}

/*
 @Unique_TCRef 76F1
 @Unique_TCRef 76F0
 @Unique_TCRef 74F2
 */
- (void)testAddingEmptyDictionaryToSession
{
    if (self.setUpSuccess)
    {
        NSDictionary *test_before = @{};
        [self.currentSession setObject:test_before forParameter:@"test_dict"];
        
        NSDictionary *test_after = [self.currentSession objectForParameter:@"test_dict"];
        
        STAssertNotNil(test_after, @"checking if added dictionary exists in session parameters");
        STAssertTrue([[test_after allKeys] count] == 0, @"dictionary count should be zero as added dictionary was empty");
        
        self.lastTestSuccessful = YES;
        
        
        STAssertTrue(self.lastTestSuccessful, @"Adding empty dictionary, empty list is returned");
    }
    else
    {
        STFail(@"We could not run this test case");
    }
}

/*
 @Unique_TCRef 74F2
 @unique_TCRef 87F2
 */
/*
 
 // Commented until MOBSDK-541 is resolved
 
- (void)testRemovingInternalParameterFromSession
{
    [self runAllSitesTest:^
     {
         id alfrescoAuthenticationProviderObject_before = [self.currentSession objectForParameter:kAlfrescoAuthenticationProviderObjectKey];
         
         [self.currentSession removeParameter:kAlfrescoAuthenticationProviderObjectKey];
         
         id alfrescoAuthenticationProviderObject_after = [self.currentSession objectForParameter:kAlfrescoAuthenticationProviderObjectKey];
         
         STAssertNotNil(alfrescoAuthenticationProviderObject_after, @"check aflresco authentication paramter is not nil after removing the parameter from session");
         STAssertEqualObjects(alfrescoAuthenticationProviderObject_before, alfrescoAuthenticationProviderObject_after, @"check authentication parameter is same before and after removing session auth param from session");
         
         self.lastTestSuccessful = YES;
         
 
         STAssertTrue(self.lastTestSuccessful, @"Internal Parameter is not removed, Returns previous value");
     }
     ];
}
 */

/*
 @Unique_TCRef 78S2
 @Unique_TCRef 61S1
 */
- (void)testRetrieveSessionRepositoryInformation
{
    if (self.setUpSuccess)
    {
        if (!self.isCloud)
        {
            AlfrescoRepositoryInfo *sessionRepositoryInfo = [self.currentSession repositoryInfo];
            
            STAssertNotNil(sessionRepositoryInfo, @"Expected the session repositary information to not be nil");
            STAssertNotNil(sessionRepositoryInfo.name, @"Expected the name of the repository not to be nil");
            STAssertNotNil(sessionRepositoryInfo.identifier, @"Expected the identifier of the repository not to be nil");
            STAssertNotNil(sessionRepositoryInfo.summary, @"Expected the summary of the repository not to be nil");
            STAssertNotNil(sessionRepositoryInfo.edition, @"Expected the edition of the repository not to be nil");
            STAssertNotNil(sessionRepositoryInfo.majorVersion, @"Expected the major version of the repository not to be nil");
            STAssertNotNil(sessionRepositoryInfo.minorVersion, @"Expected the minor version of the repository not to be nil");
            STAssertNotNil(sessionRepositoryInfo.maintenanceVersion, @"Expected the maintenance version of the repository not to be nil");
            STAssertNotNil(sessionRepositoryInfo.buildNumber, @"Expected the build number of the repository not to be nil");
            STAssertNotNil(sessionRepositoryInfo.version, @"Expected the version of the repository not to be nil");
            STAssertNotNil(sessionRepositoryInfo.capabilities, @"Expected the capabilities of the repository not to be nil");
            
            BOOL isRunningOnVersion4 = [sessionRepositoryInfo.capabilities doesSupportCapability:kAlfrescoCapabilityLike];
            
            STAssertTrue([sessionRepositoryInfo.edition isEqualToString:@"Enterprise"], @"Expected the edition to be Enterprise edition");
            
            if (isRunningOnVersion4)
            {
                STAssertTrue([sessionRepositoryInfo.majorVersion intValue] == 4, @"Expected the major version to be 4");
                
                STAssertTrue([sessionRepositoryInfo.minorVersion intValue] >= 0, @"Expected the minor version to be 0 or more");
                
                STAssertTrue([sessionRepositoryInfo.capabilities doesSupportCapability:kAlfrescoCapabilityLike], @"Version 4 of the OnPremise server should support the like capability");
                STAssertTrue([sessionRepositoryInfo.capabilities doesSupportCapability:kAlfrescoCapabilityCommentsCount], @"Version 4 of the OnPremise server should support comments count capability");
            }
            else
            {
                STAssertTrue([sessionRepositoryInfo.majorVersion intValue] == 3, @"Expected the major version to be 3");
                
                STAssertTrue([sessionRepositoryInfo.minorVersion intValue] >= 4, @"Expected the minor version to be 4 or more");
                
                STAssertFalse([sessionRepositoryInfo.capabilities doesSupportCapability:kAlfrescoCapabilityLike], @"Version 3 of the OnPremise server should not support the like capability");
                STAssertFalse([sessionRepositoryInfo.capabilities doesSupportCapability:kAlfrescoCapabilityCommentsCount], @"Version 3 of the OnPremise server should not support comments count capability");
            }
            
            self.lastTestSuccessful = YES;
        }
        else
        {
            // CURRENTLY WILL FAIL - MOBSDK-392
            AlfrescoRepositoryInfo *sessionRepositoryInfo = [self.currentSession repositoryInfo];
            
            STAssertNotNil(sessionRepositoryInfo, @"Expected the session repositary information to not be nil");
            STAssertNotNil(sessionRepositoryInfo.name, @"Expected the name of the repository not to be nil");
            STAssertNotNil(sessionRepositoryInfo.identifier, @"Expected the identifier of the repository not to be nil");
            STAssertNotNil(sessionRepositoryInfo.summary, @"Expected the summary of the repository not to be nil");
            STAssertNotNil(sessionRepositoryInfo.capabilities, @"Expected the capabilities of the repository not to be nil");
            
            STAssertTrue([sessionRepositoryInfo.edition isEqualToString:@"Alfresco in the Cloud"], @"Expected the edition to be cloud edition, but instead got %@", sessionRepositoryInfo.edition);
            
            STAssertNil(sessionRepositoryInfo.majorVersion, @"Expected the major version of the repository item to be nil, instead got back %@", sessionRepositoryInfo.majorVersion);
            STAssertNil(sessionRepositoryInfo.minorVersion, @"Expected the minor version of the repository item to be nil, but instead got %@", sessionRepositoryInfo.minorVersion);
            STAssertNil(sessionRepositoryInfo.maintenanceVersion, @"Expected the maintenance version of the repository item to be nil, but instead got %@", sessionRepositoryInfo.maintenanceVersion);
            STAssertNil(sessionRepositoryInfo.version, @"Expected the version of the repository item to be nil, but instead got %@", sessionRepositoryInfo.version);
            
            self.lastTestSuccessful = YES;
        }
        STAssertTrue(self.lastTestSuccessful, @"The session does not contain valid respository information");
    }
    else
    {
        STFail(@"We could not run this test case");
    }
}

- (void)testOAuthSerialization
{
    if (self.setUpSuccess)
    {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        NSString *apiKey = @"ThisIsMyAPIKey-For-Alfresco-In-The-Cloud";
        NSString *secretKey = @"ThisIsMySecretKey-For-Alfresco-In-The-Cloud";
        NSString *redirect = @"http://www.alfresco.com";
        
        NSString *accessToken = @"6dbe853d-8390-4a69-b3d5-20e2125fb6e4";
        NSString *refreshToken = @"087ed018-c29e-4b69-8c94-95805dd03a4f";
        NSNumber *expiresIn = [NSNumber numberWithInt:3600];
        NSString *tokenType = @"Bearer";
        NSString *scope = @"pub_api";
        
        [dictionary setObject:accessToken forKey:kAlfrescoJSONAccessToken];
        [dictionary setObject:refreshToken forKey:kAlfrescoJSONRefreshToken];
        
        [dictionary setObject:expiresIn forKey:kAlfrescoJSONExpiresIn];
        [dictionary setObject:tokenType forKey:kAlfrescoJSONTokenType];
        [dictionary setObject:scope forKey:kAlfrescoJSONScope];
        
        AlfrescoOAuthData *origOAuthData = [[AlfrescoOAuthData alloc] initWithAPIKey:apiKey secretKey:secretKey redirectURI:redirect jsonDictionary:dictionary];
        NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:origOAuthData];
        
        AlfrescoOAuthData *archivedOAuthData = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
        STAssertTrue([apiKey isEqualToString:archivedOAuthData.apiKey], @"apiKey should be the same but we got %@", archivedOAuthData.apiKey);
        STAssertTrue([secretKey isEqualToString:archivedOAuthData.secretKey], @"secretKey should be the same but we got %@", archivedOAuthData.secretKey);
        STAssertTrue([redirect isEqualToString:archivedOAuthData.redirectURI], @"redirect should be the same but we got %@", archivedOAuthData.redirectURI);
        STAssertTrue([accessToken isEqualToString:archivedOAuthData.accessToken], @"accessToken should be the same but we got %@", archivedOAuthData.accessToken);
        STAssertTrue([refreshToken isEqualToString:archivedOAuthData.refreshToken], @"refreshToken should be the same but we got %@", archivedOAuthData.refreshToken);
        STAssertTrue([tokenType isEqualToString:archivedOAuthData.tokenType], @"tokenType should be the same but we got %@", archivedOAuthData.tokenType);
        STAssertTrue([scope isEqualToString:archivedOAuthData.scope], @"scope should be the same but we got %@", archivedOAuthData.scope);
        STAssertEquals(3600, [archivedOAuthData.expiresIn intValue], @"Expires in should be 3600, but instead it is %d",[archivedOAuthData.expiresIn intValue]);
     }
    else
    {
        STFail(@"We could not run this test case");
    }
}

- (void)testCancelDownloadRequest
{
    if (self.setUpSuccess)
    {
        __block AlfrescoDocumentFolderService *dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        __weak AlfrescoDocumentFolderService *weakDfService = dfService;
        __block AlfrescoRequest *request = [dfService retrieveDocumentsInFolder:self.testDocFolder
                                                                completionBlock:^(NSArray *array, NSError *error)
                                            {
                                                if (nil == array)
                                                {
                                                    self.lastTestSuccessful = NO;
                                                    self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                                                    self.callbackCompleted = YES;
                                                }
                                                else
                                                {
                                                    STAssertTrue(array.count > 0, @"Expected more than 0 documents");
                                                    if (array.count > 0)
                                                    {
                                                        request = [weakDfService retrieveContentOfDocument:[array objectAtIndex:0] completionBlock:^(AlfrescoContentFile *contentFile, NSError *error)
                                                                   {
                                                                       if (nil == contentFile)
                                                                       {
                                                                           self.lastTestSuccessful = YES;
                                                                           /// The CMIS error code for cancelled requests is kCMISErrorCodeCancelled = 6
                                                                           STAssertEquals([error code], kAlfrescoErrorCodeNetworkRequestCancelled, @"The expected error code is %d, but instead we get %d", kAlfrescoErrorCodeNetworkRequestCancelled, [error code]);
                                                                       }
                                                                       else
                                                                       {
                                                                           self.lastTestSuccessful = NO;
                                                                           self.lastTestFailureMessage = @"Request should have been cancelled. Instead we get a valid content file back";
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
                                                                       
                                                                       self.callbackCompleted = YES;
                                                                       
                                                                   } progressBlock:^(NSInteger bytesDownloaded, NSInteger bytesTotal) {
                                                                       AlfrescoLogDebug(@"progress %i/%i", bytesDownloaded, bytesTotal);
                                                                       if (0 < bytesDownloaded && request)
                                                                       {
                                                                           [request cancel];
                                                                       }
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
        STAssertTrue(self.lastTestSuccessful, self.lastTestFailureMessage);
    }
    else
    {
        STFail(@"We could not run this test case");
    }
}


@end
