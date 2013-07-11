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

#import "AlfrescoSessionCustomCMISTests.h"
#import "AlfrescoListingContext.h"
#import "AlfrescoOAuthData.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoDocumentFolderService.h"
#import "AlfrescoRequest.h"
#import "AlfrescoErrors.h"
#import "AlfrescoLog.h"

@implementation AlfrescoSessionCustomCMISTests

- (void)setUp
{
    NSDictionary *customParameters = [NSDictionary dictionaryWithObject:@"/service/cmis" forKey:kAlfrescoCMISBindingURL];
    [self setupEnvironmentParameters];
    BOOL success = NO;
    if (!self.isCloud)
    {
        success = [self authenticateOnPremiseServer:customParameters];
        [self resetTestVariables];
    }
    if (success)
    {
        success = [self retrieveAlfrescoTestFolder];
        [self resetTestVariables];
    }
    self.setUpSuccess = success;
}

/**
 * Setting custom CMIS binding, addressing MOBSDK-542
 */
- (void)testCustomCMISBindingSession
{
    if (self.setUpSuccess)
    {
        AlfrescoDocumentFolderService *dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        [dfService retrieveChildrenInFolder:self.testDocFolder completionBlock:^(NSArray *children, NSError *error) {
            if (nil == children)
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                self.callbackCompleted = YES;
            }
            else
            {
                STAssertTrue(0 < children.count, @"we should have more than one element in the children's array");
                CMISSession *cmisSession = [self.currentSession objectForParameter:kAlfrescoSessionKeyCmisSession];
                if (cmisSession)
                {
                    CMISSessionParameters *parameters = cmisSession.sessionParameters;
                    NSString *atomPubUrl = [parameters.atomPubUrl absoluteString];
                    STAssertFalse(NSNotFound == [atomPubUrl rangeOfString:kAlfrescoOnPremiseCMISPath].location, @"should have found the /service/cmis string in atomPubURl");
                    
                }
                self.lastTestSuccessful = YES;
                self.callbackCompleted = YES;
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

@end
