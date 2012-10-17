//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "AlfrescoSpecificCMISTests.h"
#import "CMISConstants.h"
#import "CMISDocument.h"
#import "CMISFolder.h"
#import "CMISSession.h"
#import "AlfrescoCMISObjectConverter.h"

// TODO: Maintain these tests on an 'alfresco' branch, also remove the Alfresco specific code from master.

@implementation AlfrescoSpecificCMISTests

- (NSDictionary *)customCmisParameters
{
    // We could just write the class name as a NSString, but that would not refactor if we ever would rename this class
    return [NSDictionary dictionaryWithObject:NSStringFromClass([AlfrescoCMISObjectConverter class]) forKey:kCMISSessionParameterObjectConverterClassName];
}

- (void)testCreateDocumentWithDescription
{
    [self runTest:^
    {
        NSString *documentName = [NSString stringWithFormat:@"temp_test_file_alfresco_%@.txt", [self stringFromCurrentDate]];
        NSString *documentDescription = @"This is a test description";
        NSMutableDictionary *documentProperties = [NSMutableDictionary dictionary];
        [documentProperties setObject:documentName forKey:kCMISPropertyName];
        [documentProperties setObject:@"cmis:document, P:cm:titled" forKey:kCMISPropertyObjectTypeId];
        [documentProperties setObject:documentDescription forKey:@"cm:description"];

        // Create document with description
        __block NSInteger previousBytesUploaded = -1;
        NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file.txt" ofType:nil];
        [self.testFolder createDocumentFromFilePath:filePath withMimeType:@"text/plain"
                withProperties:documentProperties
                completionBlock:^ (NSString *objectId)
                {
                    STAssertNotNil(objectId, @"Object id received should be non-nil");

                    // Verify creation
                    NSError *retrievalError = nil;
                    CMISDocument *document = (CMISDocument *) [self.session retrieveObject:objectId error:&retrievalError];
                    STAssertTrue([documentName isEqualToString:document.name],
                        @"Document name of created document is wrong: should be %@, but was %@", documentName, document.name);

                    [self verifyDocument:document hasExtensionProperty:@"cm:description" withValue:documentDescription];

                    // Cleanup after ourselves
                    NSError *deleteError = nil;
                    BOOL documentDeleted = [document deleteAllVersionsAndReturnError:&deleteError];
                    STAssertNil(deleteError, @"Error while deleting created document: %@", [deleteError description]);
                    STAssertTrue(documentDeleted, @"Document was not deleted");

                    self.callbackCompleted = YES;
                }
                failureBlock: ^ (NSError *uploadError)
                {
                   STAssertNil(uploadError, @"Got error while creating document: %@", [uploadError description]);
                }
                progressBlock: ^ (NSInteger bytesUploaded, NSInteger bytesTotal)
                {
                    STAssertTrue(bytesUploaded > previousBytesUploaded, @"No progress was made");
                    previousBytesUploaded = bytesUploaded;
                }
        ];
        [self waitForCompletion:20];

        }];
}

- (void)testUpdateDocumentDescription
{
    [self runTest:^
    {
        NSError *error = nil;
        CMISDocument *document = [self uploadTestFileWithAspects];

        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        NSString *description = @"This is a jolly good description!";
        [properties setObject:description forKey:@"cm:description"];

        document = (CMISDocument *) [document updateProperties:properties error:&error];
        STAssertNil(error, @"Got error while retrieving document with updated description: %@", [error description]);

        [self verifyDocument:document hasExtensionProperty:@"cm:description" withValue:description];

        // Cleanup
        [self deleteDocumentAndVerify:document];
    }];
}

- (void)testRetrieveExifData
{
    [self runTest:^
    {
        NSError *error = nil;
        CMISDocument *document = (CMISDocument *) [self.session retrieveObjectByPath:@"/ios-test/image-with-exif.jpg" error:&error];

        [self verifyDocument:document hasExtensionProperty:@"exif:manufacturer" withValue:@"NIKON"];
        [self verifyDocument:document hasExtensionProperty:@"exif:model" withValue:@"E950"];
        [self verifyDocument:document hasExtensionProperty:@"exif:flash" withValue:@"false"];
    }];
}

- (void)testUpdateExifData
{
    [self runTest:^
    {
        NSError *error = nil;
        CMISDocument *document = (CMISDocument *) [self.session retrieveObjectByPath:@"/ios-test/image-with-exif.jpg" error:&error];
        NSString *originalModelName = @"E950";
        [self verifyDocument:document hasExtensionProperty:@"exif:model" withValue:originalModelName];
        [self verifyDocument:document hasExtensionProperty:@"exif:pixelYDimension" withValue:@"600"];
//        [self verifyDocument:document hasExtensionProperty:@"exif:fNumber" withValue:@"5.5"];
        [self verifyDocument:document hasExtensionProperty:@"exif:flash" withValue:@"false"];

        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        NSString *newModelName = @"Ultimate Flash Model 101";
        [properties setValue:newModelName forKey:@"exif:model"];
        [properties setValue:[NSNumber numberWithInt:101] forKey:@"exif:pixelYDimension"];
        [properties setValue:[NSNumber numberWithDouble:101.101] forKey:@"exif:fNumber"];
        [properties setValue:[NSNumber numberWithBool:YES] forKey:@"exif:flash"];

        document = (CMISDocument *) [document updateProperties:properties error:&error];
        STAssertNil(error, @"Got error while retrieving document with updated description: %@", [error description]);
        [self verifyDocument:document hasExtensionProperty:@"exif:model" withValue:newModelName];
        [self verifyDocument:document hasExtensionProperty:@"exif:pixelYDimension" withValue:@"101"];
//        [self verifyDocument:document hasExtensionProperty:@"exif:fNumber" withValue:@"101.101"];

        // Reset image exif data again
        [properties setValue:originalModelName forKey:@"exif:model"];
        [properties setValue:[NSNumber numberWithInt:600] forKey:@"exif:pixelYDimension"];
//        [properties setValue:[NSNumber numberWithDouble:5.5] forKey:@"exif:fNumber"];
        [properties setValue:[NSNumber numberWithBool:NO] forKey:@"exif:flash"];
        document = (CMISDocument *) [document updateProperties:properties error:&error];

        STAssertNil(error, @"Got error while retrieving document with updated description: %@", [error description]);
        [self verifyDocument:document hasExtensionProperty:@"exif:model" withValue:originalModelName];
        [self verifyDocument:document hasExtensionProperty:@"exif:pixelYDimension" withValue:@"600"];
//        [self verifyDocument:document hasExtensionProperty:@"exif:fNumber" withValue:@"5.5"];
        [self verifyDocument:document hasExtensionProperty:@"exif:flash" withValue:@"false"];
    }];
}

- (void)testCreateDocumentWithExif
{
    [self runTest:^
    {

        NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file.txt" ofType:nil];
        NSString *documentName = [NSString stringWithFormat:@"test_file_%@.txt", [self stringFromCurrentDate]];

        NSMutableDictionary *documentProperties = [NSMutableDictionary dictionary];
        [documentProperties setObject:@"cmis:document, P:cm:titled, P:exif:exif" forKey:kCMISPropertyObjectTypeId];
        [documentProperties setObject:documentName forKey:kCMISPropertyName];
        [documentProperties setObject:@"UberCam" forKey:@"exif:model"];

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

        [self waitForCompletion:60];

        NSError *error = nil;
        CMISDocument *document = (CMISDocument *) [self.session retrieveObject:objectId error:&error];
        STAssertNil(error, @"Got error while creating document: %@", [error description]);
        STAssertNotNil(objectId, @"Object id received should be non-nil");
        STAssertNotNil(document, @"Retrieved document should not be nil");
        [self verifyDocument:document hasExtensionProperty:@"exif:model" withValue:@"UberCam"];

    }];

}

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
        @"Document property value does not match: was %@ but expected %@", valueElement.value, expectedValue);
}


- (CMISDocument *)uploadTestFileWithAspects
{
    // Set properties on test file
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file.txt" ofType:nil];
    NSString *documentName = [NSString stringWithFormat:@"test_file_%@.txt", [self stringFromCurrentDate]];
    NSMutableDictionary *documentProperties = [NSMutableDictionary dictionary];
    [documentProperties setObject:documentName forKey:kCMISPropertyName];
    [documentProperties setObject:@"cmis:document, P:cm:titled" forKey:kCMISPropertyObjectTypeId];

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

    [self waitForCompletion:60];

    NSError *error = nil;
    CMISDocument *document = (CMISDocument *) [self.session retrieveObject:objectId error:&error];
    STAssertNil(error, @"Got error while creating document: %@", [error description]);
    STAssertNotNil(objectId, @"Object id received should be non-nil");
    STAssertNotNil(document, @"Retrieved document should not be nil");

    return document;
}



@end