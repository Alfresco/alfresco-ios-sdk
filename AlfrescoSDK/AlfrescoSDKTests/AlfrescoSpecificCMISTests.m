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
#import "CMISFolder.h"
#import "CMISSession.h"
#import "CMISProperties.h"
#import "AlfrescoCMISObjectConverter.h"
#import "CMISISO8601DateFormatter.h"
#import "AlfrescoCMISDocument.h"
#import "CMISDateUtil.h"
#import "CMISStringInOutParameter.h"

// TODO: Maintain these tests on an 'alfresco' branch, also remove the Alfresco specific code from master.

@implementation AlfrescoSpecificCMISTests

- (NSDictionary *)customCmisParameters
{
    // We could just write the class name as a NSString, but that would not refactor if we ever would rename this class
    return [NSDictionary dictionaryWithObject:NSStringFromClass([AlfrescoCMISObjectConverter class]) forKey:kCMISSessionParameterObjectConverterClassName];
}

- (void)testCreateDocumentWithDescription
{
    [self runCMISTest:^
    {
        NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file.txt" ofType:nil];
        NSURL *fileUrl = [NSURL URLWithString:filePath];
        NSString *documentName = [AlfrescoBaseTest testFileNameFromFilename:[fileUrl lastPathComponent]];
        NSString *documentDescription = @"This is a test description";
        NSMutableDictionary *documentProperties = [NSMutableDictionary dictionary];
        [documentProperties setObject:documentName forKey:kCMISPropertyName];
        [documentProperties setObject:@"cmis:document, P:cm:titled" forKey:kCMISPropertyObjectTypeId];
        [documentProperties setObject:documentDescription forKey:@"cm:description"];

        // Create document with description
        [self.cmisRootFolder createDocumentFromFilePath:filePath withMimeType:@"text/plain" withProperties:documentProperties completionBlock:^(NSString *objectId, NSError *error){
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
                        STAssertTrue([doc.name isEqualToString:documentName], @"expected %@ but got %@", documentName, doc.name);
                        [self verifyDocument:doc hasExtensionProperty:@"cm:description" withValue:documentDescription];
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
        STAssertTrue(self.lastTestSuccessful, @"testCreateDocumentWithDescription failed");

        }];
}

/*
- (void)testUpdateDocumentDescription
{
    [self runCMISTest:^
    {
        NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file.txt" ofType:nil];
        NSURL *fileUrl = [NSURL URLWithString:filePath];
        NSString *documentName = [AlfrescoBaseTest testFileNameFromFilename:[fileUrl lastPathComponent]];
        NSMutableDictionary *documentProperties = [NSMutableDictionary dictionary];
        [documentProperties setObject:documentName forKey:kCMISPropertyName];
        
        NSMutableString *objectTypeId = [[NSMutableString alloc] init];
        [objectTypeId appendString:@"cmis:document"];
        [objectTypeId appendFormat:@", P:cm:titled"];
        
        [documentProperties setObject:objectTypeId forKey:kCMISPropertyObjectTypeId];
        [self.cmisRootFolder createDocumentFromFilePath:filePath withMimeType:@"text/plain" withProperties:documentProperties completionBlock:^(NSString *objectId, NSError *error){
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
                        CMISDocument *doc = (CMISDocument *)cmisObject;
                        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                        NSString *description = @"This is a jolly good description!";
                        [properties setObject:description forKey:@"cm:description"];
                        [documentProperties setObject:@"cmis:document, P:cm:titled" forKey:kCMISPropertyObjectTypeId];
                        
                        [self.cmisSession.objectConverter convertProperties:properties forObjectTypeId:cmisObject.objectType completionBlock:^(CMISProperties *convertedProps, NSError *convError){
                            if (nil == convertedProps)
                            {
                                self.lastTestSuccessful = NO;
                                self.callbackCompleted = YES;
                                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [convError localizedDescription], [convError localizedFailureReason]];
                            }
                            else
                            {
                                CMISProperties *updatedProperties = [[CMISProperties alloc] init];
                                NSEnumerator *enumerator = [convertedProps.propertiesDictionary keyEnumerator];
                                for (NSString *cmisKey in enumerator)
                                {
                                    if (![cmisKey isEqualToString:kCMISPropertyObjectTypeId])
                                    {
                                        CMISPropertyData *propData = [convertedProps.propertiesDictionary objectForKey:cmisKey];
                                        [updatedProperties addProperty:propData];
                                    }
                                }
                                updatedProperties.extensions = convertedProps.extensions;
                                CMISStringInOutParameter *inOut = [CMISStringInOutParameter inOutParameterUsingInParameter:cmisObject.identifier];
                                [self.cmisSession.binding.objectService updatePropertiesForObject:inOut withProperties:updatedProperties withChangeToken:nil completionBlock:^(NSError *updError){
                                    if (updError)
                                    {
                                        self.lastTestSuccessful = NO;
                                        self.callbackCompleted = YES;
                                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [convError localizedDescription], [convError localizedFailureReason]];
                                    }
                                    else
                                    {
                                        [self.cmisSession retrieveObject:cmisObject.identifier completionBlock:^(CMISObject *updatedObj, NSError *retrError){
                                            if (nil == updatedObj)
                                            {
                                                self.lastTestSuccessful = NO;
                                                self.callbackCompleted = YES;
                                                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [retrError localizedDescription], [retrError localizedFailureReason]];
                                            }
                                            else
                                            {
                                                CMISDocument *doc = (CMISDocument *)updatedObj;
                                                [self verifyDocument:doc hasExtensionProperty:@"cm:description" withValue:description];
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
                                }];
                            }
                        }];
                        
                    }
                }];
            }
        } progressBlock:^(unsigned long long bytesUploaded, unsigned long long bytesTotal){}];
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, @"testUpdateDocumentDescription failed");

    }];
}
*/
- (void)testRetrieveExifDataUsingExtensions
{
    [self runCMISTest:^
    {
        NSString *testFilePath = nil;
        if (self.isCloud)
        {
            testFilePath = [NSString stringWithFormat:@"%@ios-test/image-with-exif.jpg", self.testFolderPathName];
        }
        else
        {
            testFilePath = @"/ios-test/image-with-exif.jpg";
            
        }
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
                [self verifyDocument:document hasExtensionProperty:@"exif:manufacturer" withValue:@"NIKON"];
                [self verifyDocument:document hasExtensionProperty:@"exif:model" withValue:@"E950"];
                [self verifyDocument:document hasExtensionProperty:@"exif:flash" withValue:@"false"];
                self.callbackCompleted = YES;                
            }
        }];
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, @"testRetrieveExifDataUsingExtensions failed");
    }];
}

- (void)testRetrieveExifDataUsingProperties
{
    [self runCMISTest:^
    {

        NSString *testFilePath = nil;
        if (self.isCloud)
        {
            testFilePath = [NSString stringWithFormat:@"%@ios-test/image-with-exif.jpg", self.testFolderPathName];
        }
        else
        {
            testFilePath = @"/ios-test/image-with-exif.jpg";
            
        }
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
                STAssertEqualObjects([document.properties propertyValueForId:@"exif:manufacturer"], @"NIKON", nil);
                STAssertEqualObjects([document.properties propertyValueForId:@"exif:model"], @"E950", nil);
                STAssertEqualObjects([document.properties propertyValueForId:@"exif:flash"], [NSNumber numberWithBool:NO], nil);
                STAssertEqualObjects([document.properties propertyValueForId:@"exif:pixelXDimension"], [NSNumber numberWithInt:800], nil);
                STAssertEqualObjects([document.properties propertyValueForId:@"exif:exposureTime"], [NSNumber numberWithFloat:0.012987012987013f], nil);
                STAssertEqualObjects([document.properties propertyValueForId:@"exif:dateTimeOriginal"], [[CMISDateUtil defaultDateFormatter] dateFromString:@"2012-10-19T00:00:00.000Z"], nil);
                self.callbackCompleted = YES;
            }
        }];
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, @"testRetrieveExifDataUsingProperties failed");
    }];
}

/*
- (void)testUpdateExifData
{
    [self runCMISTest:^
    {
        NSString *originalModelName = @"E950";

        NSDate *originalDate = [[CMISDateUtil defaultDateFormatter] dateFromString:@"2012-10-19T00:00:00.000Z"];
        NSDate *now = [NSDate date];
        
        [self.cmisSession retrieveObjectByPath:@"/ios-test/image-with-exif.jpg" completionBlock:^(CMISObject *cmisObject, NSError *error){
            if (nil == cmisObject)
            {
                self.lastTestSuccessful = NO;
                self.callbackCompleted = YES;
                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else
            {
                CMISDocument *document = (CMISDocument *)cmisObject;
                [self verifyDocument:document hasExtensionProperty:@"exif:model" withValue:originalModelName];
                [self verifyDocument:document hasExtensionProperty:@"exif:pixelYDimension" withValue:@"600"];
                [self verifyDocument:document hasExtensionProperty:@"exif:flash" withValue:@"false"];
                [self verifyDocument:document hasExtensionProperty:@"exif:dateTimeOriginal" withValue:[[CMISDateUtil defaultDateFormatter] stringFromDate:originalDate]];

                
                NSMutableDictionary *properties = [NSMutableDictionary dictionary];
                NSString *newModelName = @"Ultimate Flash Model 101";
                [properties setValue:newModelName forKey:@"exif:model"];
                [properties setValue:[NSNumber numberWithInt:101] forKey:@"exif:pixelYDimension"];
                [properties setValue:[NSNumber numberWithBool:YES] forKey:@"exif:flash"];
                [properties setValue:now forKey:@"exif:dateTimeOriginal"];
                
                [document updateProperties:properties completionBlock:^(CMISObject *updatedObject, NSError *updateError){
                    if (nil == updatedObject)
                    {
                        self.lastTestSuccessful = NO;
                        self.callbackCompleted = YES;
                        self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [updateError localizedDescription], [updateError localizedFailureReason]];
                    }
                    else
                    {
                        [self verifyDocument:document hasExtensionProperty:@"exif:model" withValue:newModelName];
                        [self verifyDocument:document hasExtensionProperty:@"exif:pixelYDimension" withValue:@"101"];
                        [self verifyDocument:document hasExtensionProperty:@"exif:flash" withValue:@"true"];
                        [self verifyDocument:document hasExtensionProperty:@"exif:dateTimeOriginal" withValue:[[CMISDateUtil defaultDateFormatter] stringFromDate:now]];
                        
                        NSMutableDictionary *resetProperties = [NSMutableDictionary dictionary];
                        [resetProperties setValue:originalModelName forKey:@"exif:model"];
                        [resetProperties setValue:[NSNumber numberWithInt:600] forKey:@"exif:pixelYDimension"];
                        [resetProperties setValue:[NSNumber numberWithBool:NO] forKey:@"exif:flash"];
                        [resetProperties setValue:originalDate forKey:@"exif:dateTimeOriginal"];
                        
                        CMISDocument *updatedDoc = (CMISDocument *)updatedObject;
                        [updatedDoc updateProperties:resetProperties completionBlock:^(CMISObject *resetObj, NSError *resetError){
                            if (nil == resetObj)
                            {
                                self.lastTestSuccessful = NO;
                                self.callbackCompleted = YES;
                                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [resetError localizedDescription], [resetError localizedFailureReason]];
                            }
                            else
                            {
                                
                                self.lastTestSuccessful = YES;
                                [self verifyDocument:document hasExtensionProperty:@"exif:model" withValue:originalModelName];
                                [self verifyDocument:document hasExtensionProperty:@"exif:pixelYDimension" withValue:@"600"];
                                [self verifyDocument:document hasExtensionProperty:@"exif:flash" withValue:@"false"];
                                [self verifyDocument:document hasExtensionProperty:@"exif:dateTimeOriginal" withValue:[[CMISDateUtil defaultDateFormatter] stringFromDate:originalDate]];
                                self.callbackCompleted = YES;
                            }
                        }];
                    }
                }];
                
            }
        }];
        [self waitUntilCompleteWithFixedTimeInterval];
        STAssertTrue(self.lastTestSuccessful, @"testUpdateExifData failed");
        
    }];
}
*/
 
- (void)testCreateDocumentWithExif
{
    [self runCMISTest:^
    {

        NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file.txt" ofType:nil];
        NSURL *fileUrl = [NSURL URLWithString:filePath];
        NSString *documentName = [AlfrescoBaseTest testFileNameFromFilename:[fileUrl lastPathComponent]];
        NSMutableDictionary *documentProperties = [NSMutableDictionary dictionary];
        [documentProperties setObject:@"cmis:document, P:cm:titled, P:exif:exif" forKey:kCMISPropertyObjectTypeId];
        [documentProperties setObject:documentName forKey:kCMISPropertyName];
        [documentProperties setObject:@"UberCam" forKey:@"exif:model"];

        [self.cmisRootFolder createDocumentFromFilePath:filePath withMimeType:@"text/plain" withProperties:documentProperties completionBlock:^(NSString *objectId, NSError *error){
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
                        [self verifyDocument:doc hasExtensionProperty:@"exif:model" withValue:@"UberCam"];
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
        STAssertTrue(self.lastTestSuccessful, @"testCreateDocumentWithExif failed");

    }];

}

- (void)testAddAspectToDocument
{
    [self runCMISTest:^
    {
        NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file.txt" ofType:nil];
        NSURL *fileUrl = [NSURL URLWithString:filePath];
        NSString *documentName = [AlfrescoBaseTest testFileNameFromFilename:[fileUrl lastPathComponent]];
        NSMutableDictionary *documentProperties = [NSMutableDictionary dictionary];
        [documentProperties setObject:documentName forKey:kCMISPropertyName];
        [documentProperties setObject:kCMISPropertyObjectTypeIdValueDocument forKey:kCMISPropertyObjectTypeId];
        
        [self.cmisRootFolder createDocumentFromFilePath:filePath withMimeType:@"text/plain" withProperties:documentProperties completionBlock:^(NSString *objectId, NSError *error){
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
                        STAssertFalse([cmisDocument hasAspect:@"P:exif:exif"], nil);
                        [cmisDocument.aspectTypes addObject:@"P:exif:exif"];
                        [cmisDocument updateProperties:[NSDictionary dictionary] completionBlock:^(CMISObject *updatedObj, NSError *updError){
                            if (nil == updatedObj)
                            {
                                self.lastTestSuccessful = NO;
                                self.callbackCompleted = YES;
                                self.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [updError localizedDescription], [updError localizedFailureReason]];
                            }
                            else
                            {
                                AlfrescoCMISDocument *updatedDoc = (AlfrescoCMISDocument *)updatedObj;
                                STAssertTrue([updatedDoc hasAspect:@"P:exif:exif"], nil);
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
        STAssertTrue(self.lastTestSuccessful, @"testAddAspectToDocument failed");

    }];
}

- (void)testApostropheInDescription
{
    [self runCMISTest:^
    {
        NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file.txt" ofType:nil];
        NSURL *fileUrl = [NSURL URLWithString:filePath];
        NSString *documentName = [AlfrescoBaseTest testFileNameFromFilename:[fileUrl lastPathComponent]];
        __block NSMutableDictionary *documentProperties = [NSMutableDictionary dictionary];
        [documentProperties setObject:documentName forKey:kCMISPropertyName];
        [documentProperties setObject:@"cmis:document, P:cm:titled, P:cm:author" forKey:kCMISPropertyObjectTypeId];
        
        [self.cmisRootFolder createDocumentFromFilePath:filePath withMimeType:@"text/plain" withProperties:documentProperties completionBlock:^(NSString *objectId, NSError *error){
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
                        [documentProperties setObject:description forKey:@"cm:description"];
                        [documentProperties setObject:description forKey:@"cm:title"];
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
                                STAssertEqualObjects([updatedDoc.properties propertyValueForId:@"cm:description"], description, nil);
                                STAssertEqualObjects([updatedDoc.properties propertyValueForId:@"cm:title"], description, nil);
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
        STAssertTrue(self.lastTestSuccessful, @"testApostropheInDescription failed");

    }];
}

//- (void)testCreateDocumentWithJapaneseProperties
//{
//    [self runTest:^
//    {
//        NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file.txt" ofType:nil];
//
//        NSMutableDictionary *documentProperties = [NSMutableDictionary dictionary];
//        [documentProperties setObject:@"cmis:document, P:cm:titled, P:cm:author" forKey:kCMISPropertyObjectTypeId];
//
//        NSString *documentName = @"ラヂオコmプタ";
//        [documentProperties setObject:documentName forKey:kCMISPropertyName];
//
//        NSString *title = @"わさび";
//        [documentProperties setObject:title forKey:@"cm:title"];
//
//        NSString *description = @"ありがと　にほんご";
//        [documentProperties setObject:description forKey:@"cm:description"];
//
//        // Upload test file
//        __block NSString *objectId = nil;
//        [self.testFolder createDocumentFromFilePath:filePath
//                withMimeType:@"text/plain"
//                withProperties:documentProperties
//                completionBlock: ^ (NSString *newObjectId)
//                {
//                    STAssertNotNil(newObjectId, @"Object id should not be nil");
//                    objectId = newObjectId;
//                    self.callbackCompleted = YES;
//                }
//                failureBlock: ^ (NSError *failureError)
//                {
//                    STAssertNil(failureError, @"Got error while uploading document: %@", [failureError description]);
//                }
//                progressBlock:nil];
//
//        [self waitForCompletion:60];
//
//        NSError *error = nil;
//        CMISDocument *document = (CMISDocument *) [self.session retrieveObject:objectId error:&error];
//        STAssertNil(error, @"Got error while creating document: %@", [error description]);
//        STAssertEquals([document.properties propertyValueForId:@"cm:title"], title, @"Expected %@, but was %@", [document.properties propertyValueForId:@"cm:title"], title);
//        STAssertEquals([document.properties propertyValueForId:@"cm:description"], description, @"Expected %@, but was %@", [document.properties propertyValueForId:@"cm:description"], description);
//
//        // Clean up
//        [self deleteDocumentAndVerify:document];
//    }];
//}

#pragma mark Helper methods

- (void)verifyDocument:(CMISDocument *)document hasExtensionProperty:(NSString *)expectedProperty withValue:(id)expectedValue
{
    // Let's do some extension juggling
    STAssertNotNil(document.properties.extensions, @"Expected extensions");
    STAssertTrue(document.properties.extensions.count > 0, @"Expected at least one property extension");

    // Verify root extension element
    CMISExtensionElement *rootExtensionElement = (CMISExtensionElement *) [document.properties.extensions objectAtIndex:0];
    STAssertTrue([rootExtensionElement.name isEqualToString:@"aspects"], @"root element of extensions should be 'aspects'");

    // Find properties extension element
    CMISExtensionElement *propertiesExtensionElement = nil;
    for (CMISExtensionElement *childExtensionElement in rootExtensionElement.children)
    {
        if ([childExtensionElement.name isEqualToString:@"properties"])
        {
            propertiesExtensionElement = childExtensionElement;
            break;
        }
    }
    STAssertNotNil(propertiesExtensionElement, @"No properties extension element found");

    // Find description property
    CMISExtensionElement *propertyElement = nil;
    for (CMISExtensionElement *childExtensionElement in propertiesExtensionElement.children)
    {
        if (childExtensionElement.attributes != nil &&
                ([[childExtensionElement.attributes objectForKey:@"propertyDefinitionId"] isEqualToString:expectedProperty]))
        {
            propertyElement = childExtensionElement;
            break;
        }
    }
    STAssertNotNil(propertyElement, [NSString stringWithFormat:@"No property '%@' was found", expectedProperty]);

    // Finally, verify the value
    CMISExtensionElement *valueElement = [propertyElement.children objectAtIndex:0];
    STAssertNotNil(valueElement, @"There is no value element for the property");
    STAssertTrue([valueElement.value isEqual:expectedValue],
        @"Document property '%@' value does not match: was %@ but expected %@", expectedProperty, valueElement.value, expectedValue);
}

/*
- (CMISDocument *)uploadTestFileWithAspects:(NSArray *)aspectTypeIds
{
    // Set properties on test file
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file.txt" ofType:nil];
    NSString *documentName = [NSString stringWithFormat:@"test_file_%@.txt", [self stringFromCurrentDate]];
    NSMutableDictionary *documentProperties = [NSMutableDictionary dictionary];
    [documentProperties setObject:documentName forKey:kCMISPropertyName];

    NSMutableString *objectTypeId = [[NSMutableString alloc] init];
    [objectTypeId appendString:@"cmis:document"];
    for (NSString *aspectTypeId in aspectTypeIds)
    {
        [objectTypeId appendFormat:@", %@", aspectTypeId];
    }
    [documentProperties setObject:objectTypeId forKey:kCMISPropertyObjectTypeId];

    // Upload test file
    __block NSInteger previousUploadedBytes = -1;
    __block NSString *objectId = nil;
    [self.testFolder createDocumentFromFilePath:filePath
            withMimeType:@"text/plain"
            withProperties:documentProperties
            completionBlock: ^ (NSString *newObjectId)
            {
                STAssertNotNil(newObjectId, @"Object id should not be nil");
                objectId = newObjectId;
                self.callbackCompleted = YES;
            }
            failureBlock: ^ (NSError *failureError)
            {
                STAssertNil(failureError, @"Got error while uploading document: %@", [failureError description]);
            }
            progressBlock: ^ (NSInteger uploadedBytes, NSInteger totalBytes)
            {
                STAssertTrue(uploadedBytes > previousUploadedBytes, @"no progress");
                previousUploadedBytes = uploadedBytes;
            }];

    [self waitUntilCompleteWithFixedTimeInterval];

    NSError *error = nil;
    CMISDocument *document = (CMISDocument *) [self.session retrieveObject:objectId error:&error];
    STAssertNil(error, @"Got error while creating document: %@", [error description]);
    STAssertNotNil(objectId, @"Object id received should be non-nil");
    STAssertNotNil(document, @"Retrieved document should not be nil");

    return document;
}
*/


@end