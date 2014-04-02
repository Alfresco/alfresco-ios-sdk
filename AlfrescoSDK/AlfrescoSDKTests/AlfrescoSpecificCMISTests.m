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

#import "AlfrescoSpecificCMISTests.h"
#import "CMISConstants.h"
#import "CMISDocument.h"
#import "AlfrescoCMISObjectConverter.h"
#import "CMISDateUtil.h"
#import "AlfrescoCMISDocument.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoCMISUtil.h"

// TODO: Maintain these tests on an 'alfresco' branch, also remove the Alfresco specific code from master.

static NSString * const kAlfrescoTestNetworkID = @"/alfresco.com";

@interface AlfrescoSpecificCMISTests()
@property (nonatomic, strong) NSDictionary *environment;
@end

@implementation AlfrescoSpecificCMISTests

- (void)setUp
{
    self.environment = [self setupEnvironmentParameters];
    BOOL success = [self setUpCMISSession];
    [self resetTestVariables];
    self.setUpSuccess = success;
}

- (void)tearDown
{
    // No-op base class override
}

- (BOOL)setUpCMISSession
{
    __block BOOL success = NO;
    NSString *urlString = nil;
    if (self.isCloud)
    {
        urlString = [self.server stringByAppendingString:[NSString stringWithFormat:@"%@%@", kAlfrescoTestNetworkID, kAlfrescoCloudCMISPath]];
    }
    else
    {
        if ([[self.environment valueForKey:@"useWebscriptEndpointForAlfrescoSpecificCMISTests"] boolValue])
        {
            // Use the webscript binding for this server
            urlString = [self.server stringByAppendingString:kAlfrescoOnPremiseCMISPath];
        }
        else
        {
            urlString = [self.server stringByAppendingString:kAlfrescoOnPremise4_xCMISPath];
        }
    }
    __block CMISSessionParameters *params = [[CMISSessionParameters alloc]
                                             initWithBindingType:CMISBindingTypeAtomPub];
    params.username = self.userName;
    params.password = self.password;
    params.atomPubUrl = [NSURL URLWithString:urlString];
    [CMISSession arrayOfRepositories:params completionBlock:^(NSArray *repositories, NSError *error){
        if (nil == repositories)
        {
            self.lastTestSuccessful = NO;
            self.callbackCompleted = YES;
            self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
        }
        else if( 0 == repositories.count)
        {
            self.lastTestSuccessful = NO;
            self.callbackCompleted = YES;
            self.lastTestFailureMessage = @"!!! NO VALID REPO FOUND !!!";
        }
        else
        {
            CMISRepositoryInfo *repoInfo = repositories[0];
            params.repositoryId = repoInfo.identifier;
            [params setObject:NSStringFromClass([AlfrescoCMISObjectConverter class]) forKey:kCMISSessionParameterObjectConverterClassName];
            [CMISSession connectWithSessionParameters:params completionBlock:^(CMISSession *cmisSession, NSError *cmisError){
                if (nil == cmisSession)
                {
                    self.lastTestSuccessful = NO;
                    self.callbackCompleted = YES;
                    self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [cmisError localizedDescription], [cmisError localizedFailureReason]];
                }
                else
                {
                    self.cmisSession = cmisSession;
                    [cmisSession retrieveObjectByPath:self.testFolderPathName completionBlock:^(CMISObject *object, NSError *folderError){
                        if (nil == object)
                        {
                            self.lastTestSuccessful = NO;
                            self.callbackCompleted = YES;
                            self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [folderError localizedDescription], [folderError localizedFailureReason]];
                        }
                        else
                        {
                            CMISFolder *rootFolder = (CMISFolder *)object;
                            self.lastTestSuccessful = YES;
                            self.callbackCompleted = YES;
                            self.cmisRootFolder = rootFolder;
                            success = YES;
                        }
                    }];
                }
            }];
        }
    }];
    [self waitUntilCompleteWithFixedTimeInterval];
    XCTAssertTrue(self.lastTestSuccessful, @"setUpCMISSession failed");
    return success;
}

- (void)testCreateDocumentWithDescription
{
    if(self.setUpSuccess)
    {
        NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file.txt" ofType:nil];
        NSURL *fileUrl = [NSURL URLWithString:filePath];
        NSString *documentName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:[fileUrl lastPathComponent]];
        NSString *documentDescription = @"This is a test description";
        NSMutableDictionary *documentProperties = [NSMutableDictionary dictionary];
        documentProperties[kCMISPropertyName] = documentName;
        documentProperties[kCMISPropertyObjectTypeId] = @"cmis:document, P:cm:titled";
        documentProperties[@"cm:description"] = documentDescription;
        
        // Create document with description
        [self.cmisRootFolder createDocumentFromFilePath:filePath mimeType:@"text/plain" properties:documentProperties completionBlock:^(NSString *objectId, NSError *error){
            if (nil == objectId)
            {
                self.lastTestSuccessful = NO;
                self.callbackCompleted = YES;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                [self.cmisSession retrieveObject:objectId completionBlock:^(CMISObject *object, NSError *objError){
                    if (nil == object)
                    {
                        self.lastTestSuccessful = NO;
                        self.callbackCompleted = YES;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [objError localizedDescription], [objError localizedFailureReason]];
                    }
                    else
                    {
                        CMISDocument *doc = (CMISDocument *)object;
                        XCTAssertTrue([doc.name isEqualToString:documentName], @"expected %@ but got %@", documentName, doc.name);
                        [self verifyDocument:doc hasExtensionProperty:@"cm:description" withValue:documentDescription forAspect:@"cm:titled"];
                        [doc deleteAllVersionsWithCompletionBlock:^(BOOL documentDeleted, NSError *deleteError){
                            if (deleteError)
                            {
                                self.lastTestSuccessful = NO;
                                self.callbackCompleted = YES;
                                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [deleteError localizedDescription], [deleteError localizedFailureReason]];
                            }
                            else
                            {
                                self.lastTestSuccessful = YES;
                                self.callbackCompleted = YES;
                            }
                        }];
                    }
                }];
            }
        } progressBlock:^(unsigned long long bytesUploaded, unsigned long long bytesTotal){
        }];
        
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"testCreateDocumentWithDescription failed");        
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRetrieveExifDataUsingExtensions
{
    if (self.setUpSuccess)
    {
        NSString *testFilePath = [self.testFolderPathName stringByAppendingPathComponent:@"image-with-exif.jpg"];
        [self.cmisSession retrieveObjectByPath:testFilePath completionBlock:^(CMISObject *cmisObject, NSError *error){
            if (nil == cmisObject)
            {
                self.lastTestSuccessful = NO;
                self.callbackCompleted = YES;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                CMISDocument *document = (CMISDocument *)cmisObject;
                self.lastTestSuccessful = YES;
                [self verifyDocument:document hasExtensionProperty:@"exif:manufacturer" withValue:@"NIKON" forAspect:@"exif:exif"];
                [self verifyDocument:document hasExtensionProperty:@"exif:model" withValue:@"E950" forAspect:@"exif:exif"];
                [self verifyDocument:document hasExtensionProperty:@"exif:flash" withValue:@"false" forAspect:@"exif:exif"];
                self.callbackCompleted = YES;
            }
        }];
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"testRetrieveExifDataUsingExtensions failed");
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testRetrieveExifDataUsingProperties
{
    if (self.setUpSuccess)
    {
        NSString *testFilePath = [self.testFolderPathName stringByAppendingPathComponent:@"image-with-exif.jpg"];
        [self.cmisSession retrieveObjectByPath:testFilePath completionBlock:^(CMISObject *cmisObject, NSError *error){
            if (nil == cmisObject)
            {
                self.lastTestSuccessful = NO;
                self.callbackCompleted = YES;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                CMISDocument *document = (CMISDocument *)cmisObject;
                self.lastTestSuccessful = YES;
                XCTAssertEqualObjects([document.properties propertyValueForId:@"exif:manufacturer"], @"NIKON");
                XCTAssertEqualObjects([document.properties propertyValueForId:@"exif:model"], @"E950");
                XCTAssertEqualObjects([document.properties propertyValueForId:@"exif:flash"], [NSNumber numberWithBool:NO]);
                XCTAssertEqualObjects([document.properties propertyValueForId:@"exif:pixelXDimension"], @800);
                // It seems different EXIF metadata extractors vary in precision, so just check the first 16 digits of exposureTime
                NSString *trimmedExposureTime = [[NSString stringWithFormat:@"%@", [document.properties propertyValueForId:@"exif:exposureTime"]] substringToIndex:16];
                XCTAssertEqualObjects(trimmedExposureTime, @"0.01298701298701");
                // Note: EXIF dates are considered to be in the local timezone, therefore the expected UTC-equivalent date is now specified in the test parameters
                XCTAssertEqualObjects([document.properties propertyValueForId:@"exif:dateTimeOriginal"], [CMISDateUtil dateFromString:self.exifDateTimeOriginalUTC]);
                self.callbackCompleted = YES;
            }
        }];
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"testRetrieveExifDataUsingProperties failed");
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}
 
- (void)testCreateDocumentWithExif
{
    if (self.setUpSuccess)
    {
        NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file.txt" ofType:nil];
        NSURL *fileUrl = [NSURL URLWithString:filePath];
        NSString *documentName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:[fileUrl lastPathComponent]];
        NSMutableDictionary *documentProperties = [NSMutableDictionary dictionary];
        documentProperties[kCMISPropertyObjectTypeId] = @"cmis:document, P:cm:titled, P:exif:exif";
        documentProperties[kCMISPropertyName] = documentName;
        documentProperties[@"exif:model"] = @"UberCam";
        
        [self.cmisRootFolder createDocumentFromFilePath:filePath mimeType:@"text/plain" properties:documentProperties completionBlock:^(NSString *objectId, NSError *error){
            if (nil == objectId)
            {
                self.lastTestSuccessful = NO;
                self.callbackCompleted = YES;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                [self.cmisSession retrieveObject:objectId completionBlock:^(CMISObject *cmisObject, NSError *retrieveError){
                    if (nil == cmisObject)
                    {
                        self.lastTestSuccessful = NO;
                        self.callbackCompleted = YES;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrieveError localizedDescription], [retrieveError localizedFailureReason]];
                    }
                    else
                    {
                        CMISDocument *doc = (CMISDocument *)cmisObject;
                        [self verifyDocument:doc hasExtensionProperty:@"exif:model" withValue:@"UberCam" forAspect:@"exif:exif"];
                        [doc deleteAllVersionsWithCompletionBlock:^(BOOL deleted, NSError *deleteError){
                            if (deleteError)
                            {
                                self.lastTestSuccessful = NO;
                                self.callbackCompleted = YES;
                                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [deleteError localizedDescription], [deleteError localizedFailureReason]];
                            }
                            else
                            {
                                self.lastTestSuccessful = YES;
                                self.callbackCompleted = YES;
                            }
                        }];
                    }
                }];
            }
        } progressBlock:^(unsigned long long bytesUploaded, unsigned long long bytesTotal){}];
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"testCreateDocumentWithExif failed");
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testAddAspectToDocument
{
    if (self.setUpSuccess)
    {
        NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file.txt" ofType:nil];
        NSURL *fileUrl = [NSURL URLWithString:filePath];
        NSString *documentName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:[fileUrl lastPathComponent]];
        NSMutableDictionary *documentProperties = [NSMutableDictionary dictionary];
        documentProperties[kCMISPropertyName] = documentName;
        documentProperties[kCMISPropertyObjectTypeId] = kCMISPropertyObjectTypeIdValueDocument;
        
        [self.cmisRootFolder createDocumentFromFilePath:filePath mimeType:@"text/plain" properties:documentProperties completionBlock:^(NSString *objectId, NSError *error){
            if (nil == objectId)
            {
                self.lastTestSuccessful = NO;
                self.callbackCompleted = YES;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                [self.cmisSession retrieveObject:objectId completionBlock:^(CMISObject *cmisObject, NSError *objError){
                    if (nil == cmisObject)
                    {
                        self.lastTestSuccessful = NO;
                        self.callbackCompleted = YES;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [objError localizedDescription], [objError localizedFailureReason]];
                        
                    }
                    else
                    {
                        AlfrescoCMISDocument *cmisDocument = (AlfrescoCMISDocument *)cmisObject;
                        XCTAssertFalse([cmisDocument hasAspect:@"P:exif:exif"], @"We should not be able to find P:exif:exif aspect - but we do");
                        [cmisDocument.aspectTypes addObject:@"P:exif:exif"];
                        [cmisDocument updateProperties:@{} completionBlock:^(CMISObject *updatedObj, NSError *updError){
                            if (nil == updatedObj)
                            {
                                self.lastTestSuccessful = NO;
                                self.callbackCompleted = YES;
                                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [updError localizedDescription], [updError localizedFailureReason]];
                            }
                            else
                            {
                                AlfrescoCMISDocument *updatedDoc = (AlfrescoCMISDocument *)updatedObj;
                                XCTAssertTrue([updatedDoc hasAspect:@"P:exif:exif"], @"We should be able to find P:exif:exif aspect - but we don't");
                                [updatedDoc deleteAllVersionsWithCompletionBlock:^(BOOL docDeleted, NSError *deleteError){
                                    if (deleteError)
                                    {
                                        self.lastTestSuccessful = NO;
                                        self.callbackCompleted = YES;
                                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [deleteError localizedDescription], [deleteError localizedFailureReason]];
                                    }
                                    else
                                    {
                                        self.lastTestSuccessful = YES;
                                        self.callbackCompleted = YES;
                                    }
                                }];
                            }
                        }];
                    }
                }];
            }
        } progressBlock:^(unsigned long long bytesUploaded, unsigned long long bytesTotal){}];
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"testAddAspectToDocument failed");
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testApostropheInDescription
{
    if (self.setUpSuccess)
    {
        NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file.txt" ofType:nil];
        NSURL *fileUrl = [NSURL URLWithString:filePath];
        NSString *documentName = [AlfrescoBaseTest addTimeStampToFileOrFolderName:[fileUrl lastPathComponent]];
        __block NSMutableDictionary *documentProperties = [NSMutableDictionary dictionary];
        documentProperties[kCMISPropertyName] = documentName;
        documentProperties[kCMISPropertyObjectTypeId] = @"cmis:document, P:cm:titled, P:cm:author";
        
        [self.cmisRootFolder createDocumentFromFilePath:filePath mimeType:@"text/plain" properties:documentProperties completionBlock:^(NSString *objectId, NSError *error){
            if (nil == objectId)
            {
                self.lastTestSuccessful = NO;
                self.callbackCompleted = YES;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                [self.cmisSession retrieveObject:objectId completionBlock:^(CMISObject *cmisObject, NSError *objError){
                    if (nil == cmisObject)
                    {
                        self.lastTestSuccessful = NO;
                        self.callbackCompleted = YES;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [objError localizedDescription], [objError localizedFailureReason]];
                    }
                    else
                    {
                        NSString *description = @"This is a 'test'";
                        documentProperties[@"cm:description"] = description;
                        documentProperties[@"cm:title"] = description;
                        AlfrescoCMISDocument *cmisDoc = (AlfrescoCMISDocument *)cmisObject;
                        [cmisDoc updateProperties:documentProperties completionBlock:^(CMISObject *updObj, NSError *updError){
                            if (nil == updObj)
                            {
                                self.lastTestSuccessful = NO;
                                self.callbackCompleted = YES;
                                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [updError localizedDescription], [updError localizedFailureReason]];
                            }
                            else
                            {
                                AlfrescoCMISDocument *updatedDoc = (AlfrescoCMISDocument *)updObj;
                                XCTAssertEqualObjects([updatedDoc.properties propertyValueForId:@"cm:description"], description, @"We expected the description on properties %@ to be equal to description %@, but got differences",[updatedDoc.properties propertyValueForId:@"cm:description"], description );
                                XCTAssertEqualObjects([updatedDoc.properties propertyValueForId:@"cm:title"], description);
                                [updatedDoc deleteAllVersionsWithCompletionBlock:^(BOOL deleted, NSError *deleteError){
                                    if (deleteError)
                                    {
                                        self.lastTestSuccessful = NO;
                                        self.callbackCompleted = YES;
                                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [deleteError localizedDescription], [deleteError localizedFailureReason]];
                                    }
                                    else
                                    {
                                        self.lastTestSuccessful = YES;
                                        self.callbackCompleted = YES;
                                    }
                                }];
                            }
                        }];
                    }
                }];
            }
        } progressBlock:^(unsigned long long bytesUploaded, unsigned long long bytesTotal){}];
        [self waitUntilCompleteWithFixedTimeInterval];
        XCTAssertTrue(self.lastTestSuccessful, @"testApostropheInDescription failed");
    }
    else
    {
        XCTFail(@"Could not run test case: %@", NSStringFromSelector(_cmd));
    }
}

- (void)testObjectTypeIdHelper
{
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    
    // test just the folder parameter being set
    NSString *objectTypeId = [AlfrescoCMISUtil prepareObjectTypeIdForProperties:nil type:nil aspects:nil folder:YES];
    XCTAssertTrue([objectTypeId isEqualToString:kCMISPropertyObjectTypeIdValueFolder],
                  @"Expected objectTypeId to be %@ but it was %@", kCMISPropertyObjectTypeIdValueFolder, objectTypeId);
    
    objectTypeId = [AlfrescoCMISUtil prepareObjectTypeIdForProperties:nil type:nil aspects:nil folder:NO];
    XCTAssertTrue([objectTypeId isEqualToString:kCMISPropertyObjectTypeIdValueDocument],
                  @"Expected objectTypeId to be %@ but it was %@", kCMISPropertyObjectTypeIdValueDocument, objectTypeId);
    
    // test just cm:content as type
    objectTypeId = [AlfrescoCMISUtil prepareObjectTypeIdForProperties:nil type:kAlfrescoContentModelTypeContent aspects:nil folder:NO];
    XCTAssertTrue([objectTypeId isEqualToString:kCMISPropertyObjectTypeIdValueDocument],
                  @"Expected objectTypeId to be %@ but it was %@", kCMISPropertyObjectTypeIdValueDocument, objectTypeId);
    
    // test just cm:folder as type
    objectTypeId = [AlfrescoCMISUtil prepareObjectTypeIdForProperties:nil type:kAlfrescoContentModelTypeFolder aspects:nil folder:NO];
    XCTAssertTrue([objectTypeId isEqualToString:kCMISPropertyObjectTypeIdValueFolder],
                  @"Expected objectTypeId to be %@ but it was %@", kCMISPropertyObjectTypeIdValueFolder, objectTypeId);
    
    // test just cmis:document as type
    objectTypeId = [AlfrescoCMISUtil prepareObjectTypeIdForProperties:nil type:kCMISPropertyObjectTypeIdValueDocument aspects:nil folder:NO];
    XCTAssertTrue([objectTypeId isEqualToString:kCMISPropertyObjectTypeIdValueDocument],
                  @"Expected objectTypeId to be %@ but it was %@", kCMISPropertyObjectTypeIdValueDocument, objectTypeId);
    
    // test just cmis:folder as type
    objectTypeId = [AlfrescoCMISUtil prepareObjectTypeIdForProperties:nil type:kCMISPropertyObjectTypeIdValueFolder aspects:nil folder:NO];
    XCTAssertTrue([objectTypeId isEqualToString:kCMISPropertyObjectTypeIdValueFolder],
                  @"Expected objectTypeId to be %@ but it was %@", kCMISPropertyObjectTypeIdValueFolder, objectTypeId);
    
    // test just custom type
    objectTypeId = [AlfrescoCMISUtil prepareObjectTypeIdForProperties:nil type:@"fdk:everything" aspects:nil folder:NO];
    XCTAssertTrue([objectTypeId isEqualToString:@"D:fdk:everything"],
                  @"Expected objectTypeId to be D:fdk:everything but it was %@", objectTypeId);
    
    objectTypeId = [AlfrescoCMISUtil prepareObjectTypeIdForProperties:nil type:@"st:site" aspects:nil folder:YES];
    XCTAssertTrue([objectTypeId isEqualToString:@"F:st:site"],
                  @"Expected objectTypeId to be F:st:site but it was %@", objectTypeId);
    
    // test just aspects
    objectTypeId = [AlfrescoCMISUtil prepareObjectTypeIdForProperties:nil type:nil aspects:@[kAlfrescoContentModelAspectTitled, kAlfrescoContentModelAspectAuthor] folder:NO];
    XCTAssertTrue([objectTypeId isEqualToString:@"cmis:document,P:cm:titled,P:cm:author"],
                  @"Expected objectTypeId to be cmis:document,P:cm:titled,P:cm:author but it was %@", objectTypeId);
    
    // test aspect and type
    objectTypeId = [AlfrescoCMISUtil prepareObjectTypeIdForProperties:nil type:kAlfrescoContentModelTypeFolder aspects:@[kAlfrescoContentModelAspectTitled] folder:NO];
    XCTAssertTrue([objectTypeId isEqualToString:@"cmis:folder,P:cm:titled"],
                  @"Expected objectTypeId to be cmis:folder,P:cm:titled but it was %@", objectTypeId);
    
    // test custom type and aspect
    objectTypeId = [AlfrescoCMISUtil prepareObjectTypeIdForProperties:nil type:@"fdk:everything" aspects:@[kAlfrescoContentModelAspectTitled] folder:NO];
    XCTAssertTrue([objectTypeId isEqualToString:@"D:fdk:everything,P:cm:titled"],
                  @"Expected objectTypeId to be D:fdk:everything,P:cm:titled but it was %@", objectTypeId);
    
    // test cmis:objectTypeId already being set i.e. no adverse effects
    properties[kCMISPropertyObjectTypeId] = @"cmis:document,P:cm:titled";
    objectTypeId = [AlfrescoCMISUtil prepareObjectTypeIdForProperties:properties type:nil aspects:nil folder:NO];
    XCTAssertTrue([objectTypeId isEqualToString:@"cmis:document,P:cm:titled"],
                  @"Expected objectTypeId to be cmis:document,P:cm:titled but it was %@", objectTypeId);
    
    // test cmis:objectTypeId already being set (to Alfresco type) plus a given aspect
    properties[kCMISPropertyObjectTypeId] = @"cm:content,P:cm:titled";
    objectTypeId = [AlfrescoCMISUtil prepareObjectTypeIdForProperties:properties type:nil aspects:@[kAlfrescoContentModelAspectAuthor] folder:NO];
    XCTAssertTrue([objectTypeId isEqualToString:@"cmis:document,P:cm:titled,P:cm:author"],
                  @"Expected objectTypeId to be cmis:document,P:cm:titled,P:cm:author but it was %@", objectTypeId);
    
    // test aspects being applied by their presence in the dictionary
    properties[kAlfrescoContentModelPropertyTitle] = @"A Title";
    objectTypeId = [AlfrescoCMISUtil prepareObjectTypeIdForProperties:properties type:kAlfrescoContentModelTypeContent aspects:nil folder:NO];
    XCTAssertTrue([objectTypeId isEqualToString:@"cmis:document,P:cm:titled"],
                  @"Expected objectTypeId to be cmis:document,P:cm:titled but it was %@", objectTypeId);
    
    properties[kAlfrescoContentModelPropertyLatitude] = @(51.52255);
    objectTypeId = [AlfrescoCMISUtil prepareObjectTypeIdForProperties:properties type:kAlfrescoContentModelTypeContent aspects:nil folder:NO];
    XCTAssertTrue([objectTypeId isEqualToString:@"cmis:document,P:cm:titled,P:cm:geographic"],
                  @"Expected objectTypeId to be cmis:document,P:cm:titled,P:cm:geographic but it was %@", objectTypeId);
    
    // test aspects being applied by their presence in the dictionary and given as a parameter
    objectTypeId = [AlfrescoCMISUtil prepareObjectTypeIdForProperties:properties type:kAlfrescoContentModelTypeContent aspects:@[kAlfrescoContentModelAspectAuthor] folder:NO];
    XCTAssertTrue([objectTypeId isEqualToString:@"cmis:document,P:cm:author,P:cm:titled,P:cm:geographic"],
                  @"Expected objectTypeId to be cmis:document,P:cm:author,P:cm:titled,P:cm:geographic but it was %@", objectTypeId);
    
    // test that we don't get duplicated aspects or system aspects
    objectTypeId = [AlfrescoCMISUtil prepareObjectTypeIdForProperties:properties
                                                                 type:kAlfrescoContentModelTypeContent
                                                              aspects:@[kAlfrescoContentModelAspectTitled,
                                                                        kAlfrescoContentModelAspectAuthor,
                                                                        kAlfrescoContentModelAspectGeographic,
                                                                        kAlfrescoSystemModelAspectLocalized]
                                                               folder:NO];
    XCTAssertTrue([objectTypeId isEqualToString:@"cmis:document,P:cm:titled,P:cm:author,P:cm:geographic"],
                  @"Expected objectTypeId to be cmis:document,P:cm:titled,P:cm:author,P:cm:geographic but it was %@", objectTypeId);
}

#pragma mark Helper methods

- (void)verifyDocument:(CMISDocument *)document hasExtensionProperty:(NSString *)expectedProperty withValue:(id)expectedValue forAspect:(NSString *)aspect
{
    // Let's do some extension juggling
    XCTAssertNotNil(document.properties.extensions, @"Expected extensions");
    XCTAssertTrue(document.properties.extensions.count > 0, @"Expected at least one property extension");

    // Verify root extension element
    CMISExtensionElement *rootExtensionElement = (CMISExtensionElement *) (document.properties.extensions)[0];
    XCTAssertTrue([rootExtensionElement.name isEqualToString:@"aspects"], @"root element of extensions should be 'aspects'");

    // Find properties extension element
    CMISExtensionElement *propertiesExtensionElement = nil;
    BOOL aspectFound = NO;
    for (CMISExtensionElement *childExtensionElement in rootExtensionElement.children)
    {
        if (!aspectFound)
        {
            // Loop round looking for the aspect we're interested in. Use hasSuffix as they will be preceded with "P:"
            if ([childExtensionElement.name isEqualToString:@"appliedAspects"] && [childExtensionElement.value hasSuffix:aspect])
            {
                aspectFound = YES;
                continue;
            }
        }
        else
        {
            // Aspect found so now only interested in next properties element
            if ([childExtensionElement.name isEqualToString:@"properties"])
            {
                propertiesExtensionElement = childExtensionElement;
                break;
            }
        }
    }
    XCTAssertTrue(aspectFound, @"The aspect %@ was not found on this node", aspect);

    // Find the property requested
    CMISExtensionElement *propertyElement = nil;
    for (CMISExtensionElement *childExtensionElement in propertiesExtensionElement.children)
    {
        if (childExtensionElement.attributes != nil &&
                ([(childExtensionElement.attributes)[@"propertyDefinitionId"] isEqualToString:expectedProperty]))
        {
            propertyElement = childExtensionElement;
            break;
        }
    }
    XCTAssertNotNil(propertyElement, @"No property '%@' was found", expectedProperty);

    // Finally, verify the value
    CMISExtensionElement *valueElement = (propertyElement.children)[0];
    XCTAssertNotNil(valueElement, @"There is no value element for the property");
    XCTAssertTrue([valueElement.value isEqual:expectedValue],
        @"Document property '%@' value does not match: was %@ but expected %@", expectedProperty, valueElement.value, expectedValue);
}

@end
