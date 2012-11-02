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

#import <SenTestingKit/SenTestingKit.h>
#import "AlfrescoRepositorySession.h"
#import "AlfrescoCloudSession.h"
#import "AlfrescoDocument.h"
#import "AlfrescoDocumentFolderService.h"
#import "AlfrescoSiteService.h"

#define TIMEINTERVAL 120

typedef void (^AlfrescoTestBlock)(void);
typedef void (^AlfrescoSessionTestBlock)(id<AlfrescoSession> session);

extern NSString * const kAlfrescoTestDataFolder;
@interface AlfrescoBaseTest : SenTestCase

@property (nonatomic, assign) BOOL callbackCompleted;
@property (nonatomic, assign) BOOL lastTestSuccessful;
@property (nonatomic, strong) NSString *lastTestFailureMessage;
@property (nonatomic, strong) AlfrescoDocument *testAlfrescoDocument;
@property (nonatomic, strong) AlfrescoDocumentFolderService *alfrescoDocumentFolderService;
@property (nonatomic, strong) AlfrescoFolder *currentRootFolder;
@property (nonatomic, strong) AlfrescoFolder *testDocFolder;
@property (nonatomic, strong) AlfrescoFolder *testChildFolder;
@property (nonatomic, strong) NSString * unitTestFolder;
@property (nonatomic, strong) id<AlfrescoSession> currentSession;
@property (nonatomic, strong) NSString *testSearchFileName;
@property (nonatomic, strong) NSString *textKeyWord;

@property (nonatomic, strong) NSString *server;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *testSiteName;
@property (nonatomic, strong) NSString *testChildFolderName;
@property (nonatomic, strong) NSString *testFolderPathName;
@property (nonatomic, strong) NSString *fixedFileName;
@property (nonatomic, strong) AlfrescoContentFile *testImageFile;

@property (nonatomic, assign) BOOL isCloud;

- (void) runAllSitesTest:(AlfrescoTestBlock)sessionTestBlock;
- (void)authenticateOnPremiseServer;
- (void)authenticateCloudServer;

- (void)retrieveAlfrescoTestFolder;
- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs;
- (void)waitUntilCompleteWithFixedTimeInterval;
- (void) removeTestDocument;
@end
