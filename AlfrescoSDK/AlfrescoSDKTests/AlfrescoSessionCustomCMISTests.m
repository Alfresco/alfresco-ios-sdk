/*******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
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
#import "AlfrescoInternalConstants.h"
#import "AlfrescoErrors.h"

@implementation AlfrescoSessionCustomCMISTests

- (void)setUp
{
    // override the base class setup as we need to control
    // the session creation in the test below
    [self setupEnvironmentParameters];
}

/**
 * Setting custom CMIS binding, addressing MOBSDK-542
 */
- (void)testCustomCMISBindingSession
{
    if (!self.isCloud)
    {
        /**
         * FIXME: Running unit tests from the command line doesn't unlock the keychain which in turn
         *        doesn't allow SSL connections to be made. Apple Bug rdar://10406441 and rdar://8385355
         *        (latter can be viewed at http://openradar.appspot.com/8385355 )
         */
        NSDictionary *customParameters = @{kAlfrescoCMISBindingURL: @"/service/cmis",
                                           kAlfrescoAllowUntrustedSSLCertificate: @YES};
        
        [AlfrescoRepositorySession connectWithUrl:[NSURL URLWithString:self.server] username:self.userName password:self.password parameters:customParameters completionBlock:^(id<AlfrescoSession> session, NSError *sessionError){
            if (nil == session)
            {
                if (sessionError.code == kAlfrescoErrorCodeRequestedNodeNotFound)
                {
                    // if the error has a "not found" error code it's because the end point is missing
                    // i.e. it's a 5.0+ server, just abandon the test and mark it as successful.
                    self.lastTestSuccessful = YES;
                }
                else
                {
                    self.lastTestSuccessful = NO;
                    self.lastTestFailureMessage = [NSString stringWithFormat:@"OnPremise session could not be authenticated: %@",
                                                   [self failureMessageFromError:sessionError]];
                }
                
                self.callbackCompleted = YES;
            }
            else
            {
                XCTAssertNotNil(session,@"Session should not be nil");
                self.currentSession = session;
                
                AlfrescoDocumentFolderService *dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
                [dfService retrieveNodeWithFolderPath:self.testFolderPathName completionBlock:^(AlfrescoNode *node, NSError *folderError){
                    if (!node)
                    {
                        self.lastTestSuccessful = NO;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"Could not get the folder %@ in the DocLib: %@",
                                                       self.testFolderPathName, [self failureMessageFromError:folderError]];
                        self.callbackCompleted = YES;
                    }
                    else
                    {
                        // check the CMIS session being used is using the overridden URL
                        CMISSession *cmisSession = [self.currentSession objectForParameter:kAlfrescoSessionKeyCmisSession];
                        if (cmisSession)
                        {
                            CMISSessionParameters *parameters = cmisSession.sessionParameters;
                            NSString *atomPubUrl = [parameters.atomPubUrl absoluteString];
                            XCTAssertFalse(NSNotFound == [atomPubUrl rangeOfString:kAlfrescoLegacyCMISPath].location, @"should have found the /service/cmis string in atomPubURl");
                            
                        }
                        
                        self.lastTestSuccessful = YES;
                        self.callbackCompleted = YES;
                    }
                }];
            }
        }];
    
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"%@", self.lastTestFailureMessage);
    }
}

@end
