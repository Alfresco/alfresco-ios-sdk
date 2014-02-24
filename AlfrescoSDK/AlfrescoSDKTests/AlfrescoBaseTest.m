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

#import "AlfrescoBaseTest.h"
#import "AlfrescoContentFile.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoCMISObjectConverter.h"
#import "AlfrescoLog.h"
#import "CMISConstants.h"
#import "CMISDocument.h"

// kAlfrescoTestServersConfigDirectory is expected to be found in the user's home folder.
// Note: the entry in userhome can be a symbolic link created via "ln -s"
static NSString * const kAlfrescoTestServersConfigDirectory = @"ios-sdk-test-config";
static NSString * const kAlfrescoTestServersPlist = @"test-servers.plist";


@implementation AlfrescoBaseTest

#pragma mark unit test internal methods

- (NSString *)userTestConfigFolder
{
    NSString *userName = [[NSString alloc] initWithCString:getlogin() encoding:NSUTF8StringEncoding];
    return [NSString pathWithComponents:@[@"/Users", userName, kAlfrescoTestServersConfigDirectory]];
}

- (NSDictionary *)setupEnvironmentParameters
{
    NSDictionary *environment = nil;

    // Expecting a "TEST_SERVER" environment variable via the xcconfig file
#if !defined(TEST_SERVER)
    #warning Missing AlfrescoSDKTests.xcconfig entries. Ensure the project configuration settings are correct.
    #define TEST_SERVER @""
#endif

    NSString *testServer = TEST_SERVER;
    if ([testServer isEqualToString:@""])
    {
        // Try to read directly from environment variables. This allows the test server to be set by
        // a developer via Xcode's "Edit Scheme ⌘<" view
        NSDictionary *environmentVariables = [[NSProcessInfo processInfo] environment];
        testServer = [environmentVariables valueForKey:@"TEST_SERVER"];
        
        // Still nothing? - default to localhost
        if ([testServer isEqualToString:@""])
        {
            testServer = @"localhost";
        }
    }
    
    NSString *plistFilePath = [self.userTestConfigFolder stringByAppendingPathComponent:kAlfrescoTestServersPlist];
    NSDictionary *plistContents =  [NSDictionary dictionaryWithContentsOfFile:plistFilePath];
    NSDictionary *allEnvironments = plistContents[@"environments"];
    if (nil != allEnvironments)
    {
        AlfrescoLogDebug(@"TEST_SERVER specified as: %@", testServer);
        environment = (NSDictionary *)allEnvironments[testServer];
    }

    if (nil == environment)
    {
        AlfrescoLogDebug(@"ERROR: No test environment config specified.");
        STFail(@"FATAL: No test environment specified. Check TEST_SERVER parameter and ~/ios-sdk-test-config/test-servers.plist");
        exit(EXIT_FAILURE);
    }
    else
    {
        self.server = [environment valueForKey:@"server"];
        if ([[environment allKeys] containsObject:@"isCloud"])
        {
            self.isCloud = [[environment valueForKey:@"isCloud"] boolValue];
        }
        else
        {
            self.isCloud = NO;
        }
        self.userName = [environment valueForKey:@"username"];
        self.firstName = [environment valueForKey:@"firstName"];
        self.testSiteName = [environment valueForKey:@"testSite"];
        self.password = [environment valueForKey:@"password"];
        self.testSearchFileName = [environment valueForKey:@"testSearchFile"];
        self.testSearchFileKeywords = [environment valueForKey:@"testSearchFileKeywords"];
        self.textKeyWord = [environment valueForKey:@"textKeyWord"];
        self.unitTestFolder = [environment valueForKey:@"testAddedFolder"];
        self.fixedFileName = [environment valueForKey:@"fixedFileName"];
        self.testFolderPathName = [environment valueForKey:@"docFolder"];
        self.secondUsername = [environment valueForKey:@"secondUsername"];
        self.secondPassword = [environment valueForKey:@"secondPassword"];
        self.moderatedSiteName = [environment valueForKey:@"moderatedSite"];
        self.exifDateTimeOriginalUTC = [environment valueForKey:@"exifDateTimeOriginalUTC"];
    }

    [self resetTestVariables];
    
    return environment;
}

- (void)setUp
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    self.verySmallTestFile = [bundle pathForResource:@"small_test.txt" ofType:nil];
    NSString *testFilePath = [bundle pathForResource:@"test_file.txt" ofType:nil];
    NSString *testImagePath = [bundle pathForResource:@"millenium-dome.jpg" ofType:nil];
    self.testImageName = [testImagePath lastPathComponent];
    [self setupEnvironmentParameters];
    BOOL success = NO;
    if (self.isCloud)
    {
        success = [self authenticateCloudServer];
    }
    else
    {
        success = [self authenticateOnPremiseServer:nil];
    }
    [self resetTestVariables];

    if (success)
    {
        success = [self retrieveAlfrescoTestFolder];
        [self resetTestVariables];
        if (success)
        {
            success = [self uploadTestDocument:testFilePath];
            [self resetTestVariables];
            
            [self setUpTestImageFile:testImagePath];
        }
    }
    self.setUpSuccess = success;
}

- (void)tearDown
{
    [self resetTestVariables];
    if (nil == self.testAlfrescoDocument || nil == self.currentSession)
    {
        self.lastTestSuccessful = YES;
    }
    else
    {
        AlfrescoDocumentFolderService *docFolderService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        [docFolderService deleteNode:self.testAlfrescoDocument completionBlock:^(BOOL succeeded, NSError *error){
            if (!succeeded)
            {
                self.testAlfrescoDocument = nil;
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"Could not delete test document. Error message %@ and code %d",[error localizedDescription], [error code]];
                self.callbackCompleted = YES;
            }
            else
            {
                self.lastTestSuccessful = YES;
                self.testAlfrescoDocument = nil;
                self.callbackCompleted = YES;
            }
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
    }
    STAssertTrue(self.lastTestSuccessful, @"removeTestDocument failed");
}

+ (NSString *)addTimeStampToFileOrFolderName:(NSString *)filename
{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH-mm-ss-SSS'"];
    
    NSString *pathExt = [filename pathExtension];
    NSString *strippedString = [filename stringByDeletingPathExtension];
    
    if (![pathExt isEqualToString:@""])
    {
        return [NSString stringWithFormat:@"%@%@.%@", strippedString, [formatter stringFromDate:currentDate], pathExt];
    }
    
    return [NSString stringWithFormat:@"%@%@", strippedString, [formatter stringFromDate:currentDate]];
}


/*
 @Unique_TCRef 33S1
 */
- (BOOL)uploadTestDocument:(NSString *)filePath
{
    NSURL *fileUrl = [NSURL URLWithString:filePath];

    NSString *newName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:[fileUrl lastPathComponent]];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    AlfrescoContentFile *textContentFile = [[AlfrescoContentFile alloc] initWithData:fileData mimeType:@"text/plain"];
    NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:4];
    props[kCMISPropertyObjectTypeId] = [kCMISPropertyObjectTypeIdValueDocument stringByAppendingString:@",P:cm:titled,P:cm:author"];
    props[@"cm:description"] = @"test file description";
    props[@"cm:title"] = @"test file title";
    props[@"cm:author"] = @"test author";

    __block BOOL success = NO;
    AlfrescoDocumentFolderService *docFolderService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
    [docFolderService createDocumentWithName:newName inParentFolder:self.testDocFolder contentFile:textContentFile properties:props completionBlock:^(AlfrescoDocument *document, NSError *error) {
        if (nil == document)
        {
            self.lastTestSuccessful = NO;
            self.lastTestFailureMessage = [NSString stringWithFormat:@"Could not upload test document. Error %@",[error localizedDescription]];
            self.callbackCompleted = YES;
        }
        else
        {
            STAssertNotNil(document, @"document should not be nil");
            STAssertTrue([document.type isEqualToString:@"cm:content"], @"The test document should be of type cm:content but it is %@", document.type);
            self.lastTestSuccessful = YES;
            self.testAlfrescoDocument = document;
            self.callbackCompleted = YES;
            success = YES;
        }
    } progressBlock:^(unsigned long long bytesTransferred, unsigned long long bytesTotal) {
        // No-op
    }];
    
    [self waitUntilCompleteWithFixedTimeInterval];
    STAssertTrue(self.lastTestSuccessful, @"uploadTestDocument failed");
    return success;
}




/*
 @Unique_TCRef 24S1
 */
- (BOOL)removeTestDocument
{
    __block BOOL success = NO;
    if (nil == self.testAlfrescoDocument)
    {
        self.lastTestSuccessful = YES;
        success = YES;
    }
    else
    {
        AlfrescoDocumentFolderService *docFolderService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        [docFolderService deleteNode:self.testAlfrescoDocument completionBlock:^(BOOL succeeded, NSError *error){
            if (!succeeded)
            {
                self.testAlfrescoDocument = nil;
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"Could not delete test document. Error message %@ and code %d",[error localizedDescription], [error code]];
                self.callbackCompleted = YES;
            }
            else
            {
                self.lastTestSuccessful = YES;
                self.testAlfrescoDocument = nil;
                self.callbackCompleted = YES;
                success = YES;
            }
        }];
    }
    [self waitUntilCompleteWithFixedTimeInterval];
    STAssertTrue(self.lastTestSuccessful, @"removeTestDocument failed");
    return success;
}



/*
 @Unique_TCRef 77S1
 */
- (BOOL)authenticateOnPremiseServer:(NSMutableDictionary *)parameters
{
    __block BOOL success = NO;
    if (self.currentSession)
    {
        self.currentSession = nil;
    }
    
    /**
     * FIXME: Running unit tests from the command line doesn't unlock the keychain which in turn
     *        doesn't allow SSL connections to be made. Apple Bug rdar://10406441 and rdar://8385355
     *        (latter can be viewed at http://openradar.appspot.com/8385355 )
     */
    if (nil == parameters)
    {
        parameters = [NSMutableDictionary dictionary];
    }
    [parameters setValue:@YES forKey:kAlfrescoAllowUntrustedSSLCertificate];
    
    [AlfrescoRepositorySession connectWithUrl:[NSURL URLWithString:self.server]
                                     username:self.userName
                                     password:self.password
                                     parameters:parameters
                              completionBlock:^(id<AlfrescoSession> session, NSError *error){
                                  if (nil == session)
                                  {
                                      self.lastTestSuccessful = NO;
                                      self.lastTestFailureMessage = [NSString stringWithFormat:@"Session could not be authenticated. Error %@",[error localizedDescription]];
                                      self.callbackCompleted = YES;
                                  }
                                  else
                                  {
                                      STAssertNotNil(session,@"Session should not be nil");
                                      self.lastTestSuccessful = YES;
                                      self.currentSession = session;
                                      self.callbackCompleted = YES;
                                      self.currentRootFolder = self.currentSession.rootFolder;
                                      success = YES;
                                  }
    }];
    
    
    [self waitUntilCompleteWithFixedTimeInterval];
    STAssertTrue(self.lastTestSuccessful, @"OnPremise Session authentication failed");
    return success;
}


/*
 @Unique_TCRef 59S1
 */
- (BOOL)authenticateCloudServer
{
    __block BOOL success = NO;
    if (self.currentSession)
    {
        self.currentSession = nil;
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:self.server forKey:@"org.alfresco.mobile.internal.session.cloud.url"];
    [parameters setValue:@YES forKey:@"org.alfresco.mobile.internal.session.cloud.basic"];
    [parameters setValue:self.userName forKey:@"org.alfresco.mobile.internal.session.username"];
    [parameters setValue:self.password forKey:@"org.alfresco.mobile.internal.session.password"];
    
    /**
     * FIXME: Running unit tests from the command line doesn't unlock the keychain which in turn
     *        doesn't allow SSL connections to be made. Apple Bug rdar://10406441 and rdar://8385355
     *        (latter can be viewed at http://openradar.appspot.com/8385355 )
     */
    [parameters setValue:@YES forKey:kAlfrescoAllowUntrustedSSLCertificate];
    
    [AlfrescoCloudSession connectWithOAuthData:nil parameters:parameters completionBlock:^(id<AlfrescoSession> cloudSession, NSError *error){
        if (nil == cloudSession)
        {
            self.lastTestSuccessful = NO;
            self.lastTestFailureMessage = [NSString stringWithFormat:@"Cloud session could not be authenticated. Error %@",[error localizedDescription]];
            AlfrescoLogDebug(@"*** The returned cloudSession is NIL with error message %@ ***",self.lastTestFailureMessage);
            self.callbackCompleted = YES;
        }
        else
        {
            AlfrescoLogDebug(@"*** Cloud session is NOT nil ***");
//            STAssertNotNil(cloudSession, @"Cloud session should not be nil");
            self.lastTestSuccessful = YES;
            self.currentSession = cloudSession;
            self.callbackCompleted = YES;
            success = YES;
        }
    }];
    

    [self waitUntilCompleteWithFixedTimeInterval];
    STAssertTrue(self.lastTestSuccessful, @"Cloud authentication failed");
    return success;
}





/*
 @Unique_TCRef 51S0
 */
- (BOOL)retrieveAlfrescoTestFolder
{
    __block BOOL success = NO;
    AlfrescoDocumentFolderService *dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
    [dfService retrieveNodeWithFolderPath:self.testFolderPathName completionBlock:^(AlfrescoNode *node, NSError *error){
        if (nil == node)
        {
            self.lastTestSuccessful = NO;
            self.lastTestFailureMessage = [NSString stringWithFormat:@"Could not get the folder %@ in the DocLib . Error %@",self.testFolderPathName, [error localizedDescription]];
            self.callbackCompleted = YES;
        }
        else
        {
            
            if ([node isKindOfClass:[AlfrescoFolder class]])
            {
                self.lastTestSuccessful = YES;
                self.testDocFolder = (AlfrescoFolder *)node;
                self.currentRootFolder = (AlfrescoFolder *)node;
                success = YES;
            }
            else
            {
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = @"the found node appears to be a document and NOT a folder";
            }
            self.callbackCompleted = YES;
        }
    }];
    [self waitUntilCompleteWithFixedTimeInterval];
    STAssertTrue(self.lastTestSuccessful, @"Failure to retrieve test folder");
    return success;
}


- (void)resetTestVariables
{
    self.callbackCompleted = NO;
    self.lastTestSuccessful = NO;
    self.lastTestFailureMessage = @"Test failed";    
}


- (void)setUpTestImageFile:(NSString *)filePath
{
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    AlfrescoContentFile *textContentFile = [[AlfrescoContentFile alloc] initWithData:fileData mimeType:@"image/jpeg"];
    self.testImageFile = textContentFile;
}

- (void)waitAtTheEnd
{
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:TIMEGAP];
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
    } while ([timeoutDate timeIntervalSinceNow] > 0 );
//    STAssertTrue(self.callbackCompleted, @"TIME OUT: callback did not complete within %d seconds", TIMEGAP);
}

- (void)waitUntilCompleteWithFixedTimeInterval
{
    if (!self.callbackCompleted)
    {
        NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:TIMEINTERVAL];
        do {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        } while (!self.callbackCompleted && [timeoutDate timeIntervalSinceNow] > 0 );
        STAssertTrue(self.callbackCompleted, @"TIME OUT: callback did not complete within %d seconds", TIMEINTERVAL);
    }
}

- (void)removePreExistingUnitTestFolder
{
    AlfrescoDocumentFolderService *dfService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
    __weak AlfrescoDocumentFolderService *weakDocumentService = dfService;
    
    [dfService retrieveNodeWithFolderPath:self.unitTestFolder relativeToFolder:self.currentSession.rootFolder completionBlock:^(AlfrescoNode *node, NSError *error) {
        if (node)
        {
            [weakDocumentService deleteNode:node completionBlock:^(BOOL succeeded, NSError *error) {
                // intentionally do nothing
            }];
        }
    }];
}

@end
