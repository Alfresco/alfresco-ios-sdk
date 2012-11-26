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

#import "AlfrescoBaseTest.h"
#import "AlfrescoContentFile.h"
#import "CMISConstants.h"

NSString * const kAlfrescoTestDataFolder = @"SDKTestDataFolder";

@interface AlfrescoBaseTest ()
@property (nonatomic, strong) NSString * testPassword;
- (void) uploadTestDocument:(NSString *)filePath;
- (void) parseEnvironmentDictionary:(NSDictionary *)plistDictionary;
- (void) setUpTestImageFile:(NSString *)filePath;
- (void) setUpTestChildFolder;
- (void) resetTestVariables;
@end

@implementation AlfrescoBaseTest

@synthesize isCloud = _isCloud;
@synthesize callbackCompleted = _callbackCompleted;
@synthesize lastTestSuccessful = _lastTestSuccessful;
@synthesize lastTestFailureMessage = _lastTestFailureMessage;
@synthesize testAlfrescoDocument = _testAlfrescoDocument;
@synthesize alfrescoDocumentFolderService = _alfrescoDocumentFolderService;
@synthesize currentRootFolder = _currentRootFolder;
@synthesize testDocFolder = _testDocFolder;
@synthesize currentSession = _currentSession;
@synthesize userName = _userName; 
@synthesize firstName = _firstName;
@synthesize testSiteName = _testSiteName;
@synthesize server = _server;
@synthesize testPassword = _testPassword;
@synthesize testSearchFileName = _testSearchFileName;
@synthesize textKeyWord = _textKeyWord;
@synthesize unitTestFolder = _unitTestFolder;
@synthesize testChildFolder = _testChildFolder;
@synthesize testChildFolderName = _testChildFolderName;
@synthesize testFolderPathName = _testFolderPathName;
@synthesize fixedFileName = _fixedFileName;
@synthesize testImageFile = _testImageFile;
#pragma mark unit test internal methods


- (void)setUp
{

}

- (void)tearDown
{
    
}

+ (NSString *)testFileNameFromFilename:(NSString *)filename
{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd'T'HH-mm-ss-SSS'"];
    NSString *newName = [filename stringByReplacingOccurrencesOfString:@".txt" withString:[formatter stringFromDate:currentDate]];
    return [NSString stringWithFormat:@"%@.txt",newName]; 
}


/*
 @Unique_TCRef 33S1
 */
- (void) uploadTestDocument:(NSString *)filePath
{
    NSURL *fileUrl = [NSURL URLWithString:filePath];

    NSString *newName = [AlfrescoBaseTest testFileNameFromFilename:[fileUrl lastPathComponent]];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    AlfrescoContentFile *textContentFile = [[AlfrescoContentFile alloc] initWithData:fileData mimeType:@"text/plain"];
    NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:4];
    [props setObject:[kCMISPropertyObjectTypeIdValueDocument stringByAppendingString:@",P:cm:titled,P:cm:author"] forKey:kCMISPropertyObjectTypeId];
    [props setObject:@"test file description" forKey:@"cm:description"];
    [props setObject:@"test file title" forKey:@"cm:title"];
    [props setObject:@"test author" forKey:@"cm:author"];
    log(@"***************** uploadTestDocument Session with base URL %@ *****************", [self.currentSession.baseUrl absoluteString]);

    AlfrescoDocumentFolderService *docFolderService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
    [docFolderService createDocumentWithName:newName
                              inParentFolder:self.testDocFolder
                                 contentFile:textContentFile
                                  properties:props
                             completionBlock:^(AlfrescoDocument *document, NSError *error){
                                 if (nil == document)
                                 {
                                     log(@"We failed uploading the document with name %@",newName);
                                     self.lastTestSuccessful = NO;
                                     self.lastTestFailureMessage = [NSString stringWithFormat:@"Could not upload test document. Error %@",[error localizedDescription]];
                                     self.callbackCompleted = YES;
                                 }
                                 else
                                 {
                                     STAssertNotNil(document, @"document should not be nil");
                                     self.lastTestSuccessful = YES;
                                     self.testAlfrescoDocument = document;
                                     log(@"<<<<< Test Document with name %@ has nodeID %@ >>>>>>",document.name, document.identifier);
                                     if (!self.isCloud)
                                     {
                                         self.testSearchFileName = self.testAlfrescoDocument.name;
                                     }
                                     self.callbackCompleted = YES;
                                 }
                             }
                               progressBlock:^(NSInteger bytesTransferred, NSInteger bytesTotal){
    }];
    
    [self waitUntilCompleteWithFixedTimeInterval];
    STAssertTrue(self.lastTestSuccessful, @"uploadTestDocument failed");
}




/*
 @Unique_TCRef 24S1
 */
- (void) removeTestDocument
{
    if (nil == self.testAlfrescoDocument)
    {
        self.lastTestSuccessful = YES;
        log(@"It turns out the self.testAlfrescoDocument is NIL already");
    }
    else
    {
        log(@"***************** removeTestDocument Session with base URL %@ *****************", [self.currentSession.baseUrl absoluteString]);
        AlfrescoDocumentFolderService *docFolderService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        [docFolderService deleteNode:self.testAlfrescoDocument completionBlock:^(BOOL succeeded, NSError *error){
            if (!succeeded)
            {
                log(@"We failed to delete the document on the server");
                self.testAlfrescoDocument = nil;
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"Could not delete test document. Error message %@ and code %d",[error localizedDescription], [error code]];
                self.callbackCompleted = YES;
            }
            else
            {
                log(@"We succeeded to delete the document %@ on the server with base URL %@", self.testAlfrescoDocument.name, [self.currentSession.baseUrl absoluteString]);
                self.lastTestSuccessful = YES;
                self.testAlfrescoDocument = nil;
                self.callbackCompleted = YES;
            }
        }];
    }
    [self waitUntilCompleteWithFixedTimeInterval];
    STAssertTrue(self.lastTestSuccessful, @"removeTestDocument failed");
}



/*
 @Unique_TCRef 77S1
 */
- (void)authenticateOnPremiseServer
{
    [AlfrescoRepositorySession connectWithUrl:[NSURL URLWithString:self.server]
                                     username:self.userName
                                     password:self.testPassword
                                     parameters:nil
                              completionBlock:^(id<AlfrescoSession> session, NSError *error){
                                  if (nil == session)
                                  {
                                      self.lastTestSuccessful = NO;
                                      self.lastTestFailureMessage = [NSString stringWithFormat:@"Session could not be authenticated. Error %@",[error localizedDescription]];
                                      self.callbackCompleted = YES;
                                  }
                                  else
                                  {
                                      if (self.currentSession)
                                      {
                                          self.currentSession = nil;
                                      }
                                      STAssertNotNil(session,@"Session should not be nil");
                                      self.lastTestSuccessful = YES;
                                      self.currentSession = session;
                                      log(@"***************** authenticateOnPremiseServer Session with base URL %@ *****************", [self.currentSession.baseUrl absoluteString]);
                                      self.callbackCompleted = YES;
                                      self.currentRootFolder = self.currentSession.rootFolder;
                                  }
    }];
    
    
    [self waitUntilCompleteWithFixedTimeInterval];
    STAssertTrue(self.lastTestSuccessful, @"OnPremise Session authentication failed");
}


/*
 @Unique_TCRef 59S1
 */
- (void)authenticateCloudServer
{
    log(@"In authenticateCloudServer");
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:self.server forKey:@"org.alfresco.mobile.internal.session.cloud.url"];
    [parameters setValue:[NSNumber numberWithBool:YES] forKey:@"org.alfresco.mobile.internal.session.cloud.basic"];
    [parameters setValue:self.userName forKey:@"org.alfresco.mobile.internal.session.username"];
    [parameters setValue:self.testPassword forKey:@"org.alfresco.mobile.internal.session.password"];
    
    [AlfrescoCloudSession connectWithOAuthData:nil parameters:parameters completionBlock:^(id<AlfrescoSession> cloudSession, NSError *error){
        if (nil == cloudSession)
        {
            log(@"AlfrescoBaseTest::authenticateCloudServer - cloudSession returns NIL");
            self.lastTestSuccessful = NO;
            self.lastTestFailureMessage = [NSString stringWithFormat:@"Cloud session could not be authenticated. Error %@",[error localizedDescription]];
            self.callbackCompleted = YES;
        }
        else
        {
            if (self.currentSession)
            {
                self.currentSession = nil;
            }
            STAssertNotNil(cloudSession, @"Cloud session should not be nil");
            log(@"AlfrescoBaseTest::authenticateCloudServer - cloudSession returns **NOT** NIL");
            self.lastTestSuccessful = YES;
            self.currentSession = cloudSession;
            self.callbackCompleted = YES;
        }
    }];
    

    [self waitUntilCompleteWithFixedTimeInterval];
    STAssertTrue(self.lastTestSuccessful, @"Cloud authentication failed");
}





/*
 @Unique_TCRef 51S0
 */
- (void)retrieveAlfrescoTestFolder
{
         
    if (self.isCloud)
    {
        STAssertTrue([self.currentSession isKindOfClass:[AlfrescoCloudSession class]], @"expected cloud session");
        log(@"***************** retrieveAlfrescoTestFolder Session with base URL %@", [self.currentSession.baseUrl absoluteString]);
        AlfrescoSiteService *siteService = [[AlfrescoSiteService alloc] initWithSession:self.currentSession];
        [siteService retrieveDocumentLibraryFolderForSite:self.testSiteName completionBlock:^(AlfrescoFolder *folder, NSError *error){
            if (nil == folder)
            {
                log(@"AlfrescoBaseTest::retrieveAlfrescoTestFolder - documentLibrary folder for cloud returns nil");
                self.lastTestSuccessful = NO;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"Could not get the root folder in the DocLib for site %@. Error %@",self.testSiteName, [error localizedDescription]];
                self.callbackCompleted = YES;
            }
            else
            {
                STAssertNotNil(folder, @"DocLib root folder should not be nil");
                self.lastTestSuccessful = YES;
                self.testDocFolder = folder;
                self.currentRootFolder = folder;
                self.callbackCompleted = YES;
            }
        }];
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, @"Cloud authentication failed");
    }
    else
    {
        log(@"***************** retrieveAlfrescoTestFolder Session with base URL %@ *****************", [self.currentSession.baseUrl absoluteString]);
        STAssertTrue([self.currentSession isKindOfClass:[AlfrescoRepositorySession class]], @"expected OnPremise session");
        self.testDocFolder = self.currentSession.rootFolder;
        self.currentRootFolder = self.currentSession.rootFolder;
    }
}

/*
 @Unique_TCRef 15S3
 */
- (void) setUpTestChildFolder
{
    if (self.isCloud)
    {
        log(@"***************** setUpTestChildFolder Session with base URL %@ *****************", [self.currentSession.baseUrl absoluteString]);
        AlfrescoDocumentFolderService *docService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.currentSession];
        NSString *folderPath = [NSString stringWithFormat:@"%@%@",self.testFolderPathName, self.testChildFolderName];
        [docService retrieveNodeWithFolderPath:folderPath completionBlock:^(AlfrescoNode *node, NSError *error){
            if (nil == node)
            {
                log(@"AlfrescoBaseTest::retrieveAlfrescoTestFolder - couldn't find node in path %@",folderPath);
                self.lastTestSuccessful = NO;
                self.callbackCompleted = YES;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                STAssertNotNil(node, @"node should not be nil");
                self.lastTestSuccessful = YES;
                self.testChildFolder = (AlfrescoFolder *)node;
                self.callbackCompleted = YES;
                
            }
        }];
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, @"setUpTestChildFolder failed");
    }
    else
    {
        log(@"***************** setUpTestChildFolder Session with base URL %@ *****************", [self.currentSession.baseUrl absoluteString]);
        self.testChildFolder = self.currentSession.rootFolder;
    }
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



- (void) runAllSitesTest:(AlfrescoTestBlock)sessionTestBlock
{
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *envsPListPath = [bundle pathForResource:@"environments" ofType:@"plist"];
    NSString *testFilePath = [bundle pathForResource:@"test_file.txt" ofType:nil];
    NSString *testImagePath = [bundle pathForResource:@"millenium-dome.jpg" ofType:nil];
    NSDictionary *environmentsDict = [[NSDictionary alloc] initWithContentsOfFile:envsPListPath];
    NSArray *environmentArray = [environmentsDict objectForKey:@"environments"];

    [self resetTestVariables];
    for (NSDictionary *environment in environmentArray)
    {
        [self parseEnvironmentDictionary:environment];
        
        if (self.isCloud)
        {
            log(@"***************** Running test against Cloud server: %@ with username: %@ *****************", self.server, self.userName);
            [self authenticateCloudServer];
            [self resetTestVariables];
        }
        else
        {
            log(@"***************** Running test against OnPremise server: %@ with username: %@ *****************", self.server, self.userName);
            [self authenticateOnPremiseServer];
            [self resetTestVariables];
        }

        [self retrieveAlfrescoTestFolder];
        [self resetTestVariables];
        
        
        [self uploadTestDocument:testFilePath];
        [self resetTestVariables];
        
        [self setUpTestImageFile:testImagePath];
        [self resetTestVariables];
        
        [self setUpTestChildFolder];
        [self resetTestVariables];
        
        log(@"***************** About to start test run for server: %@ *****************", self.server);
        sessionTestBlock();
        [self resetTestVariables];
        
        [self removeTestDocument];
        [self resetTestVariables];
    }
    
}

- (void) resetTestVariables
{
    self.callbackCompleted = NO;
    self.lastTestSuccessful = NO;
    self.lastTestFailureMessage = @"Test failed in runAllSitesTest method";    
}


- (void)setUpTestImageFile:(NSString *)filePath
{
    log(@"***************** setUpTestImageFile Session with base URL %@ *****************", [self.currentSession.baseUrl absoluteString]);
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    AlfrescoContentFile *textContentFile = [[AlfrescoContentFile alloc] initWithData:fileData mimeType:@"image/jpeg"];
    self.testImageFile = textContentFile;
}


- (void)waitForCompletion
{
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:20];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
    } while ([timeoutDate timeIntervalSinceNow] > 0);
    
    
}

- (void)waitUntilCompleteWithFixedTimeInterval
{
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:TIMEINTERVAL];    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
    } while (!self.callbackCompleted && [timeoutDate timeIntervalSinceNow] > 0 );
    STAssertTrue(self.callbackCompleted, @"TIME OUT: callback did not complete within %d seconds", TIMEINTERVAL);
    log(@"<<<<<<<<< waitUntilCompleteWithFixedTimeInterval >>>>>>>>>>>>");
}



@end
