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
#import "AlfrescoInternalConstants.h"
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
                                              XCTAssertNotNil(error, @"Expected an invalid credentials error to be thrown");
                                              XCTAssertNil(session, @"Expected a session not to be created");
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
            XCTAssertTrue(self.lastTestSuccessful, @"OnPremise Session authentication succeeded with invalid credentials");
        }
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
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
                        
                        XCTAssertTrue(network.isHomeNetwork, @"network is home network");
                        XCTAssertNotNil(network.createdAt, @"createdAt property is set");
                    }
                    self.callbackCompleted = YES;
                }
                XCTAssertTrue(self.lastTestSuccessful, @"Unable to retrieve networks for the current cloud session");
            }];
        }
        
    }];
}
 */

/*
 @Unique_TCRef 74F1
 @Unique_TCRef 75S1
 */
- (void)testRemoveNonExistentParameter
{
    if (self.setUpSuccess)
    {
        if (self.isCloud)
        {
            NSString *nonExistentKeyToRemove = @"testRemoveNonExistentParameter";
            
            NSArray *allParameters = [self.currentSession allParameterKeys];
            
            XCTAssertNotNil(allParameters, @"Expected parameters not to be nil");
            XCTAssertTrue([allParameters count] >= 1, @"Expected atleast one paramenter to be returned");
            
            // get the size of the parameters array
            NSUInteger originalNumberOfParameterKeys = [allParameters count];
            
            // attempt to remove non existent parameter
            [self.currentSession removeParameter:nonExistentKeyToRemove];
            
            XCTAssertTrue(originalNumberOfParameterKeys == [[self.currentSession allParameterKeys] count], @"Removing a non existent parameter seems to have alterered the state of the session's parameters");
            
            // if they are the same. nothing was removed
            self.lastTestSuccessful = originalNumberOfParameterKeys == [[self.currentSession allParameterKeys] count];
            
            XCTAssertTrue(self.lastTestSuccessful, @"Session base URL did not match that used in the creation of the session");
        }
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
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
        XCTAssertNotNil(sessionBaseURL, @"Expected the base url in the session not to be nil");
        XCTAssertNotNil(self.server, @"The server base url is nil");
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
        
        XCTAssertNotNil(urlToTest, @"The url to test is nil");
        XCTAssertTrue([self.server isEqualToString:urlToTest], @"Expected the baseURL in the session to be the same as that used to create the session");

        self.lastTestSuccessful = [self.server isEqualToString:urlToTest];
        XCTAssertTrue(self.lastTestSuccessful, @"Session base URL did not match that used in the creation of the session");
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
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
        XCTAssertNotNil(sessionPersonalIdentifier, @"Personal Identifier in the session is nil");
        XCTAssertNotNil(self.userName, @"Username is nil");
        XCTAssertTrue([self.userName isEqualToString:sessionPersonalIdentifier], @"The appropriate person identifer for the logged in user was not returned");

        self.lastTestSuccessful = [self.userName isEqualToString:sessionPersonalIdentifier];
        XCTAssertTrue(self.lastTestSuccessful, @"OnPremise Session did not return the appropriate personal identifier");
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
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
        
        int expectedMaxItems = 50;
        int expectedSkipCount = 0;
        
        XCTAssertNotNil(defaultListingContext, @"Expected a default listing context within the current session");
        XCTAssertNil(defaultListingContext.sortProperty, @"Expected the default sort property to be nil");
        XCTAssertTrue(defaultListingContext.sortAscending, @"Expected the default sort to be set to ascending, instead got descending");
        XCTAssertTrue(defaultListingContext.maxItems == expectedMaxItems, @"Expected the default max items to be set to %i instead got %i", expectedMaxItems, defaultListingContext.maxItems);
        XCTAssertTrue(defaultListingContext.skipCount == expectedSkipCount, @"Expected the default skip count to be %i, instead got %i", expectedSkipCount, defaultListingContext.skipCount);

        self.lastTestSuccessful = !defaultListingContext.sortProperty && defaultListingContext.sortAscending && defaultListingContext.maxItems == 50 && defaultListingContext.skipCount == 0;
        XCTAssertTrue(self.lastTestSuccessful, @"The session's default listing context state was not as expected");
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
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
        
        XCTAssertNotNil(sessionRootFolder, @"Expected the root folder in the session not to be nil");
        XCTAssertNotNil([[sessionRootFolder properties][@"cmis:path"] value], @"Expected the path to the root folder not to be nil");
        XCTAssertNotNil([[sessionRootFolder properties][@"cmis:objectId"] value], @"Expected the objectId not to be nil");
        XCTAssertNotNil([[sessionRootFolder properties][@"cmis:objectTypeId"] value], @"Expected the objectTypeId not to be nil");
        XCTAssertTrue([[[sessionRootFolder properties][@"cmis:objectTypeId"] value] isEqualToString:@"cmis:folder"], @"Expected the objectTypeID to be a cmis folder type");

        self.lastTestSuccessful = sessionRootFolder &&
            [[sessionRootFolder properties][@"cmis:path"] value] &&
            [[sessionRootFolder properties][@"cmis:objectId"] value] &&
            [[sessionRootFolder properties][@"cmis:objectTypeId"] value] &&
            [[[sessionRootFolder properties][@"cmis:objectTypeId"] value] isEqualToString:@"cmis:folder"];
        XCTAssertTrue(self.lastTestSuccessful, @"The session's root folder did not return correct values");
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
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
        
        XCTAssertNotNil(self.currentSession.personIdentifier, @"Expected the personal identifier to not be nil before disconnection");
        XCTAssertNotNil(self.currentSession.repositoryInfo, @"Expected the repository info to not be nil before disconnection");
        XCTAssertNotNil(self.currentSession.baseUrl, @"Expected the base URL to not be nil before disconnection");
        XCTAssertNotNil(self.currentSession.rootFolder, @"Expected the root folder to not be nil before disconnection");
        XCTAssertNotNil(self.currentSession.defaultListingContext, @"Expected the default listing context to not be nil before disconnection");
        
        
        
        // disconnect the session
        [self.currentSession disconnect];
        
        XCTAssertNil(self.currentSession.personIdentifier, @"Expected the personal identifier to to be cleared out after disconnection");
        XCTAssertNil(self.currentSession.repositoryInfo, @"Expected the repository info to to be cleared out after disconnection");
        XCTAssertNil(self.currentSession.baseUrl, @"Expected the base URL to to be cleared out after disconnection");
        XCTAssertNil(self.currentSession.rootFolder, @"Expected the root folder to to be cleared out after disconnection");
        XCTAssertNil(self.currentSession.defaultListingContext, @"Expected the default listing context to to be cleared out after disconnection");
        
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
        
        XCTAssertTrue(self.lastTestSuccessful, @"The session did not clear out the session variables after disconnection");
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
        NSNumber *firstValue = @100;
        NSNumber *secondValue = @200;
        int expectedReturnValue = [secondValue intValue];
        
        // add first object followed by the overwriting one
        [self.currentSession setObject:firstValue forParameter:key];
        
        XCTAssertNotNil([self.currentSession objectForParameter:key], @"The session does not contain any value for the key %@", key);
        
        [self.currentSession setObject:secondValue forParameter:key];
        
        XCTAssertNotNil([self.currentSession objectForParameter:key], @"The session does not contain any value for the key %@", key);
        XCTAssertTrue([[self.currentSession objectForParameter:key] intValue] == expectedReturnValue, @"Expected the value for the parameter %@ to be %i, but instead got back %i", key, expectedReturnValue, [[self.currentSession objectForParameter:key] intValue]);

        self.lastTestSuccessful = [[self.currentSession objectForParameter:key] intValue] == expectedReturnValue;
        XCTAssertTrue(self.lastTestSuccessful, @"The session did not overwrite the value for an existing key");
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
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
        
        XCTAssertNotNil([self.currentSession objectForParameter:key], @"The session does not contain any value for the key %@", key);
        
        // Attempt to retrieve the item set
        AlfrescoListingContext *returnedListingContextObject = (AlfrescoListingContext *)[self.currentSession objectForParameter:key];
        
        XCTAssertNotNil(returnedListingContextObject, @"Expected a listing object to be returned for the key: %@", key);
        XCTAssertTrue(returnedListingContextObject.maxItems == expectedMaxItems, @"Expected the max items in the listing context stored in the session to return %i, but instead got %i", expectedMaxItems, returnedListingContextObject.maxItems);
        XCTAssertTrue(returnedListingContextObject.skipCount == expectedSkipCount, @"Expected the skip count in the listing context stored in the session to return %i, but instead got %i", expectedSkipCount, returnedListingContextObject.skipCount);
        
        NSArray *allParamKeys = [self.currentSession allParameterKeys];
        BOOL availableInSession = [allParamKeys containsObject:key];
        
        if (returnedListingContextObject.maxItems == expectedMaxItems && returnedListingContextObject.skipCount == expectedSkipCount && availableInSession)
        {
            // attempt to remove the object
            [self.currentSession removeParameter:key];
            
            id removedObject = [self.currentSession objectForParameter:key];
            
            XCTAssertNil(removedObject, @"The object should have been removed from the parameters");
            
            if (!removedObject)
            {
                self.lastTestSuccessful = YES;
            }
        }
        else
        {
            self.lastTestSuccessful = NO;
        }
        XCTAssertTrue(self.lastTestSuccessful, @"The session did not overwrite the value for an existing key");
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 @Unique_TCRef 86F1
 @Unique_TCRef 73F1
 */
- (void)testRetrieveNonExistentParameter
{
    if (self.setUpSuccess)
    {
        NSString *key = @"testRetrieveNonExistentParameter";
        
        id returnedObject = [self.currentSession objectForParameter:key];
        
        XCTAssertNil(returnedObject, @"There is no key value pair in the parameters for the current session with the key %@, however, an object was returned from objectForParameter:", key);

        self.lastTestSuccessful = !returnedObject;
        XCTAssertTrue(self.lastTestSuccessful, @"The session does not contain an object for the key provided, but still returned a value");
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
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
        
        XCTAssertEqualObjects([self.currentSession objectForParameter:@"firstParam"], test[@"firstParam"], @"Testing if param was added to session and has expected value");
        XCTAssertEqualObjects([self.currentSession objectForParameter:@"secondParam"], test[@"secondParam"], @"Testing if param was added to session and has expected value");
        XCTAssertEqualObjects([self.currentSession objectForParameter:@"thirdParam"], test[@"thirdParam"], @"Testing if param was added to session and has expected value");
        
        XCTAssertEqualObjects(alfrescoAuthenticationProviderObject_before, alfrescoAuthenticationProviderObject_after, @"checking session authentication provider parameter before adding dictionary parameters and after");
        XCTAssertEqualObjects(alfrescoGenerateThumbnails_before, alfrescoGenerateThumbnails_after, @"checking generate thumbnails session parameter before adding dictionary parameters and after");
        XCTAssertEqualObjects(alfrescoSessionKey_before, alfrescoSessionKey_after, @"checking session key parameter before adding dictionary parameters and after");
        XCTAssertEqualObjects(alfrescoExtractMetadata_before, alfrescoExtractMetadata_after, @"checking extract metadata parameter before adding dictionary parameters and after");
        
        self.lastTestSuccessful = YES;
        
        
        XCTAssertTrue(self.lastTestSuccessful, @"Added all the objects from the given dictionary to the session. Checked that the parameters / values are as desired");
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
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
        
        XCTAssertNotNil(test_after, @"checking if added dictionary exists in session parameters");
        XCTAssertTrue([[test_after allKeys] count] == 0, @"dictionary count should be zero as added dictionary was empty");
        
        self.lastTestSuccessful = YES;
        
        
        XCTAssertTrue(self.lastTestSuccessful, @"Adding empty dictionary, empty list is returned");
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

/*
 @Unique_TCRef 74F2
 @unique_TCRef 87F2
 */
 
 // Commented until MOBSDK-541 is resolved
 
- (void)testRemovingInternalParameterFromSession
{
    if (self.setUpSuccess)
    {
        id alfrescoSessionCMISSession_before = [self.currentSession objectForParameter:kAlfrescoSessionKeyCmisSession];
        id alfrescoAuthenticationProvider_before = [self.currentSession objectForParameter:kAlfrescoAuthenticationProviderObjectKey];
        
        [self.currentSession removeParameter:kAlfrescoSessionKeyCmisSession];
        [self.currentSession removeParameter:kAlfrescoAuthenticationProviderObjectKey];
        
        id alfrescoSessionCMISSession_after = [self.currentSession objectForParameter:kAlfrescoSessionKeyCmisSession];
        id alfrescoAuthenticationProvider_after = [self.currentSession objectForParameter:kAlfrescoAuthenticationProviderObjectKey];
        
        XCTAssertNotNil(alfrescoSessionCMISSession_after, @"The CMIS Session should not be nil");
        XCTAssertEqualObjects(alfrescoSessionCMISSession_before, alfrescoSessionCMISSession_after, @"The CMIS Session has been modified");
        XCTAssertNotNil(alfrescoAuthenticationProvider_after, @"The authentication provider should not be nil");
        XCTAssertEqualObjects(alfrescoAuthenticationProvider_before, alfrescoAuthenticationProvider_after, @"The authentication provider has been modified");
        
        self.lastTestSuccessful = YES;
        
        XCTAssertTrue(self.lastTestSuccessful, @"Internal Parameter is not removed, Returns previous value");
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

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
            
            XCTAssertNotNil(sessionRepositoryInfo, @"Expected the session repositary information to not be nil");
            XCTAssertNotNil(sessionRepositoryInfo.name, @"Expected the name of the repository not to be nil");
            XCTAssertNotNil(sessionRepositoryInfo.identifier, @"Expected the identifier of the repository not to be nil");
            XCTAssertNotNil(sessionRepositoryInfo.summary, @"Expected the summary of the repository not to be nil");
            XCTAssertNotNil(sessionRepositoryInfo.edition, @"Expected the edition of the repository not to be nil");
            XCTAssertNotNil(sessionRepositoryInfo.majorVersion, @"Expected the major version of the repository not to be nil");
            XCTAssertNotNil(sessionRepositoryInfo.minorVersion, @"Expected the minor version of the repository not to be nil");
            XCTAssertNotNil(sessionRepositoryInfo.maintenanceVersion, @"Expected the maintenance version of the repository not to be nil");
            XCTAssertNotNil(sessionRepositoryInfo.buildNumber, @"Expected the build number of the repository not to be nil");
            XCTAssertNotNil(sessionRepositoryInfo.version, @"Expected the version of the repository not to be nil");
            XCTAssertNotNil(sessionRepositoryInfo.capabilities, @"Expected the capabilities of the repository not to be nil");
            
            BOOL isRunningOnVersion4 = [sessionRepositoryInfo.capabilities doesSupportCapability:kAlfrescoCapabilityLike];
            
            XCTAssertTrue([sessionRepositoryInfo.edition isEqualToString:kAlfrescoRepositoryEditionEnterprise] || [sessionRepositoryInfo.edition isEqualToString:kAlfrescoRepositoryEditionCommunity], @"Expected the edition to be Enterprise or Community but it is %@", sessionRepositoryInfo.edition);
            
            if (isRunningOnVersion4)
            {
                XCTAssertTrue([sessionRepositoryInfo.majorVersion intValue] == 4, @"Expected the major version to be 4");
                
                XCTAssertTrue([sessionRepositoryInfo.minorVersion intValue] >= 0, @"Expected the minor version to be 0 or more");
                
                XCTAssertTrue([sessionRepositoryInfo.capabilities doesSupportCapability:kAlfrescoCapabilityLike],
                              @"Version 4 of the OnPremise server should support the like capability");
                XCTAssertTrue([sessionRepositoryInfo.capabilities doesSupportCapability:kAlfrescoCapabilityCommentsCount],
                              @"Version 4 of the OnPremise server should support comments count capability");
                XCTAssertTrue([sessionRepositoryInfo.capabilities doesSupportCapability:kAlfrescoCapabilityActivitiWorkflowEngine],
                              @"Version 4 of the OnPremise server should support the Activiti workflow engine");
                XCTAssertFalse([sessionRepositoryInfo.capabilities doesSupportCapability:kAlfrescoCapabilityJBPMWorkflowEngine],
                               @"Version 4 of the OnPremise server should not support the JBPM engine");
                
                if ([sessionRepositoryInfo.edition isEqualToString:kAlfrescoRepositoryEditionEnterprise] &&
                    [sessionRepositoryInfo.minorVersion intValue] == 0)
                {
                    XCTAssertFalse([sessionRepositoryInfo.capabilities doesSupportCapability:kAlfrescoCapabilityPublicAPI],
                                  @"Version 4.0 of the Enterprise server should not support the public API");
                }
                
                if ([sessionRepositoryInfo.edition isEqualToString:kAlfrescoRepositoryEditionEnterprise] &&
                    [sessionRepositoryInfo.minorVersion intValue] >= 2)
                {
                    XCTAssertTrue([sessionRepositoryInfo.capabilities doesSupportCapability:kAlfrescoCapabilityPublicAPI],
                                  @"Version 4.2 or later of the Enterprise server should support the public API");
                }
                
                if ([sessionRepositoryInfo.edition isEqualToString:kAlfrescoRepositoryEditionCommunity] &&
                         [sessionRepositoryInfo.minorVersion intValue] >= 3)
                {
                    XCTAssertTrue([sessionRepositoryInfo.capabilities doesSupportCapability:kAlfrescoCapabilityPublicAPI],
                                  @"Version 4.3 or later of the Community server should support the public API");
                }
            }
            else
            {
                XCTAssertTrue([sessionRepositoryInfo.majorVersion intValue] == 3, @"Expected the major version to be 3");
                
                XCTAssertTrue([sessionRepositoryInfo.minorVersion intValue] >= 4, @"Expected the minor version to be 4 or more");
                
                XCTAssertFalse([sessionRepositoryInfo.capabilities doesSupportCapability:kAlfrescoCapabilityLike], @"Version 3 of the OnPremise server should not support the like capability");
                XCTAssertFalse([sessionRepositoryInfo.capabilities doesSupportCapability:kAlfrescoCapabilityCommentsCount], @"Version 3 of the OnPremise server should not support comments count capability");
                XCTAssertFalse([sessionRepositoryInfo.capabilities doesSupportCapability:kAlfrescoCapabilityPublicAPI], @"Version 3 of the OnPremise server should not support the public API");
                XCTAssertFalse([sessionRepositoryInfo.capabilities doesSupportCapability:kAlfrescoCapabilityActivitiWorkflowEngine], @"Version 3 of the OnPremise server should not support the Activiti workflow engine");
                XCTAssertTrue([sessionRepositoryInfo.capabilities doesSupportCapability:kAlfrescoCapabilityJBPMWorkflowEngine], @"Version 3 of the OnPremise server should support the JBPM engine");
            }
            
            self.lastTestSuccessful = YES;
        }
        else
        {
            AlfrescoRepositoryInfo *sessionRepositoryInfo = [self.currentSession repositoryInfo];
            
            XCTAssertNotNil(sessionRepositoryInfo, @"Expected the session repositary information to not be nil");
            XCTAssertNotNil(sessionRepositoryInfo.name, @"Expected the name of the repository not to be nil");
            XCTAssertNotNil(sessionRepositoryInfo.identifier, @"Expected the identifier of the repository not to be nil");
            XCTAssertNotNil(sessionRepositoryInfo.summary, @"Expected the summary of the repository not to be nil");
            XCTAssertNotNil(sessionRepositoryInfo.capabilities, @"Expected the capabilities of the repository not to be nil");
            
            XCTAssertTrue([sessionRepositoryInfo.edition isEqualToString:kAlfrescoRepositoryEditionCloud], @"Expected the edition to be cloud edition, but instead got %@", sessionRepositoryInfo.edition);
            
            XCTAssertNil(sessionRepositoryInfo.majorVersion, @"Expected the major version of the repository item to be nil, instead got back %@", sessionRepositoryInfo.majorVersion);
            XCTAssertNil(sessionRepositoryInfo.minorVersion, @"Expected the minor version of the repository item to be nil, but instead got %@", sessionRepositoryInfo.minorVersion);
            XCTAssertNil(sessionRepositoryInfo.maintenanceVersion, @"Expected the maintenance version of the repository item to be nil, but instead got %@", sessionRepositoryInfo.maintenanceVersion);
            XCTAssertNil(sessionRepositoryInfo.version, @"Expected the version of the repository item to be nil, but instead got %@", sessionRepositoryInfo.version);
            
            // test capabilities
            AlfrescoRepositoryCapabilities *capabilities = sessionRepositoryInfo.capabilities;
            XCTAssertTrue(capabilities.doesSupportLikingNodes, @"Expected liking nodes to be supported");
            XCTAssertTrue(capabilities.doesSupportCommentCounts, @"Expected comment counts to be supported");
            XCTAssertTrue(capabilities.doesSupportPublicAPI, @"Expected the public API to be supported");
            XCTAssertTrue(capabilities.doesSupportActivitiWorkflowEngine, @"Expected the Activiti workflow engine to be supported");
            XCTAssertFalse(capabilities.doesSupportJBPMWorkflowEngine, @"Did not expect the JBPM workflow engine to be supported");
            
            self.lastTestSuccessful = YES;
        }
        XCTAssertTrue(self.lastTestSuccessful, @"The session does not contain valid respository information");
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
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
        NSNumber *expiresIn = @3600;
        NSString *tokenType = @"Bearer";
        NSString *scope = @"pub_api";
        
        dictionary[kAlfrescoJSONAccessToken] = accessToken;
        dictionary[kAlfrescoJSONRefreshToken] = refreshToken;
        
        dictionary[kAlfrescoJSONExpiresIn] = expiresIn;
        dictionary[kAlfrescoJSONTokenType] = tokenType;
        dictionary[kAlfrescoJSONScope] = scope;
        
        AlfrescoOAuthData *origOAuthData = [[AlfrescoOAuthData alloc] initWithAPIKey:apiKey secretKey:secretKey redirectURI:redirect jsonDictionary:dictionary];
        NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:origOAuthData];
        
        AlfrescoOAuthData *archivedOAuthData = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
        XCTAssertTrue([apiKey isEqualToString:archivedOAuthData.apiKey], @"apiKey should be the same but we got %@", archivedOAuthData.apiKey);
        XCTAssertTrue([secretKey isEqualToString:archivedOAuthData.secretKey], @"secretKey should be the same but we got %@", archivedOAuthData.secretKey);
        XCTAssertTrue([redirect isEqualToString:archivedOAuthData.redirectURI], @"redirect should be the same but we got %@", archivedOAuthData.redirectURI);
        XCTAssertTrue([accessToken isEqualToString:archivedOAuthData.accessToken], @"accessToken should be the same but we got %@", archivedOAuthData.accessToken);
        XCTAssertTrue([refreshToken isEqualToString:archivedOAuthData.refreshToken], @"refreshToken should be the same but we got %@", archivedOAuthData.refreshToken);
        XCTAssertTrue([tokenType isEqualToString:archivedOAuthData.tokenType], @"tokenType should be the same but we got %@", archivedOAuthData.tokenType);
        XCTAssertTrue([scope isEqualToString:archivedOAuthData.scope], @"scope should be the same but we got %@", archivedOAuthData.scope);
        XCTAssertEqual(3600, [archivedOAuthData.expiresIn intValue], @"Expires in should be 3600, but instead it is %d",[archivedOAuthData.expiresIn intValue]);
     }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
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
                                                    XCTAssertTrue(array.count > 0, @"Expected more than 0 documents");
                                                    if (array.count > 0)
                                                    {
                                                        request = [weakDfService retrieveContentOfDocument:array[0] completionBlock:^(AlfrescoContentFile *contentFile, NSError *error)
                                                                   {
                                                                       if (nil == contentFile)
                                                                       {
                                                                           self.lastTestSuccessful = YES;
                                                                           /// The CMIS error code for cancelled requests is kCMISErrorCodeCancelled = 6
                                                                           XCTAssertEqual([error code], kAlfrescoErrorCodeNetworkRequestCancelled, @"The expected error code is %ld, but instead we get %ld", (long)kAlfrescoErrorCodeNetworkRequestCancelled, (long)[error code]);
                                                                       }
                                                                       else
                                                                       {
                                                                           self.lastTestSuccessful = NO;
                                                                           self.lastTestFailureMessage = @"Request should have been cancelled. Instead we get a valid content file back";
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
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}


@end
