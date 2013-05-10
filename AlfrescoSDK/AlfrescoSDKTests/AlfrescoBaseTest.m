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

NSString * const kAlfrescoTestDataFolder = @"SDKTestDataFolder";
NSString * const kAlfrescoTestNetworkID = @"/alfresco.com";

// START HACK
// Temporarily allow any SSL certificate during testing by overriding method on NSURLRequest.
// Once MOBSDK-495 is implemented this should be removed
/*
@implementation NSURLRequest (IgnoreSSL)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}
@end
 */
// END OF HACK


@interface AlfrescoBaseTest ()
@end

@implementation AlfrescoBaseTest

#pragma mark unit test internal methods

- (NSDictionary *)testEnvironmentDictionary
{
    NSDictionary *environmentVariables = [[NSProcessInfo processInfo] environment];
    NSString *plistFileFromEnvironment = [environmentVariables valueForKey:@"TEST_SERVER_PLIST"];
    NSArray *environmentArray = nil;
    if (plistFileFromEnvironment)
    {
        NSString *folderNameString = [NSString stringWithFormat:@"/Users/%@", NSUserName()];
        if ([plistFileFromEnvironment hasPrefix:folderNameString])
        {
            NSDictionary *listOfEnvironments = [NSDictionary dictionaryWithContentsOfFile:plistFileFromEnvironment];
            environmentArray = [listOfEnvironments objectForKey:@"environments"];
        }
        else
        {
            NSString *pathName = [NSString stringWithFormat:@"%@/%@",folderNameString, plistFileFromEnvironment];
            NSDictionary *listOfEnvironments =  [NSDictionary dictionaryWithContentsOfFile:pathName];
            environmentArray = [listOfEnvironments objectForKey:@"environments"];
        }
    }
    else
    {
        NSString *environmentPath = [NSString stringWithFormat:@"/Users/%@/test-servers.plist", NSUserName()];
        NSDictionary *listOfEnvironments =  [NSDictionary dictionaryWithContentsOfFile:environmentPath];
        environmentArray = [listOfEnvironments objectForKey:@"environments"];
    }
    if (nil == environmentArray)
    {
        return nil;
    }
    else
    {
        return (NSDictionary *)[environmentArray objectAtIndex:0];
    }
}

- (void)setUp
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    self.verySmallTestFile = [bundle pathForResource:@"small_test.txt" ofType:nil];
    NSString *testFilePath = [bundle pathForResource:@"test_file.txt" ofType:nil];
    NSString *testImagePath = [bundle pathForResource:@"millenium-dome.jpg" ofType:nil];
    self.testImageName = [testImagePath lastPathComponent];
    NSDictionary *environment = [self testEnvironmentDictionary];
    [self parseEnvironmentDictionary:environment];
    [self resetTestVariables];
    BOOL success = NO;
    if (self.isCloud)
    {
        success = [self authenticateCloudServer];
        [self resetTestVariables];
    }
    else
    {
        success = [self authenticateOnPremiseServer:nil];
        [self resetTestVariables];
    }
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
    if (nil == self.testAlfrescoDocument || nil == self.currentSession)
    {
        self.lastTestSuccessful = YES;
    }
    else
    {
        self.docFolderService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        [self.docFolderService deleteNode:self.testAlfrescoDocument completionBlock:^(BOOL succeeded, NSError *error){
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
    }
    [self waitUntilCompleteWithFixedTimeInterval];
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
- (BOOL) uploadTestDocument:(NSString *)filePath
{
    NSURL *fileUrl = [NSURL URLWithString:filePath];

    NSString *newName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:[fileUrl lastPathComponent]];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    AlfrescoContentFile *textContentFile = [[AlfrescoContentFile alloc] initWithData:fileData mimeType:@"text/plain"];
    NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:4];
    [props setObject:[kCMISPropertyObjectTypeIdValueDocument stringByAppendingString:@",P:cm:titled,P:cm:author"] forKey:kCMISPropertyObjectTypeId];
    [props setObject:@"test file description" forKey:@"cm:description"];
    [props setObject:@"test file title" forKey:@"cm:title"];
    [props setObject:@"test author" forKey:@"cm:author"];

    __block BOOL success = NO;
    self.docFolderService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
    [self.docFolderService createDocumentWithName:newName
                              inParentFolder:self.testDocFolder
                                 contentFile:textContentFile
                                  properties:props
                             completionBlock:^(AlfrescoDocument *document, NSError *error){
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
                                     if (!self.isCloud)
                                     {
                                         self.testSearchFileName = self.testAlfrescoDocument.name;
                                     }
                                     self.callbackCompleted = YES;
                                     success = YES;
                                 }
                             }
                               progressBlock:^(NSInteger bytesTransferred, NSInteger bytesTotal){
    }];
    
    [self waitUntilCompleteWithFixedTimeInterval];
    STAssertTrue(self.lastTestSuccessful, @"uploadTestDocument failed");
    return success;
}




/*
 @Unique_TCRef 24S1
 */
- (BOOL) removeTestDocument
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
- (BOOL)authenticateOnPremiseServer:(NSDictionary *)parameters
{
    __block BOOL success = NO;
    if (self.currentSession)
    {
        self.currentSession = nil;
    }
    [AlfrescoRepositorySession connectWithUrl:[NSURL URLWithString:self.server]
                                     username:self.userName
                                     password:self.testPassword
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
    [parameters setValue:[NSNumber numberWithBool:YES] forKey:@"org.alfresco.mobile.internal.session.cloud.basic"];
    [parameters setValue:self.userName forKey:@"org.alfresco.mobile.internal.session.username"];
    [parameters setValue:self.testPassword forKey:@"org.alfresco.mobile.internal.session.password"];
    
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


- (void) parseEnvironmentDictionary:(NSDictionary *)plistDictionary
{
    self.server = nil;
    self.userName = nil;
    self.firstName = nil;
    self.testPassword = nil;
    self.testSiteName = nil;
    self.testSearchFileName = nil;
    self.textKeyWord = nil;
    self.unitTestFolder = nil;
    self.fixedFileName = nil;
    self.testChildFolderName = nil;
    self.testFolderPathName = nil;
    
    
    if (nil == plistDictionary)
    {
        //use the HTTPS link to test SSL certificates etc.
        //self.server = @"https://localhost:8443/alfresco";
        self.server = @"http://localhost:8080/alfresco";
        self.isCloud = NO;
        self.userName = @"admin";
        self.firstName = @"Administrator";
        self.testSiteName = @"remoteapi";
        self.testPassword = @"admin";
        self.testSearchFileName = @"unknown";
        self.textKeyWord = @"Rooney";
        self.unitTestFolder = @"SDKUnitTestFolder";
        self.testChildFolderName = @"unknown";
        self.fixedFileName = @"versioned-quote.txt";
        self.testFolderPathName = @"/ios-test";
    }
    else
    {
        self.server = [plistDictionary valueForKey:@"server"];
        if ([[plistDictionary allKeys] containsObject:@"isCloud"])
        {
            self.isCloud = [[plistDictionary valueForKey:@"isCloud"] boolValue];
        }
        else
        {
            self.isCloud = NO;
        }
        self.userName = [plistDictionary valueForKey:@"username"];
        self.firstName = [plistDictionary valueForKey:@"firstName"];
        self.testSiteName = [plistDictionary valueForKey:@"testSite"];
        self.testPassword = [plistDictionary valueForKey:@"password"];
        self.testSearchFileName = [plistDictionary valueForKey:@"testSearchFile"];
        self.textKeyWord = [plistDictionary valueForKey:@"textKeyWord"];
        self.unitTestFolder = [plistDictionary valueForKey:@"testAddedFolder"];
        self.testChildFolderName= [plistDictionary valueForKey:@"testChildFolder"];
        self.fixedFileName = [plistDictionary valueForKey:@"fixedFileName"];
        self.testFolderPathName = [plistDictionary valueForKey:@"docFolder"];        
    }
    
}


- (void) resetTestVariables
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
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:TIMEINTERVAL];    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
    } while (!self.callbackCompleted && [timeoutDate timeIntervalSinceNow] > 0 );
    STAssertTrue(self.callbackCompleted, @"TIME OUT: callback did not complete within %d seconds", TIMEINTERVAL);
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
