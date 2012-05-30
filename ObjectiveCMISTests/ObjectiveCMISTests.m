//
//  ObjectiveCMISTests.m
//  ObjectiveCMISTests
//
//  Created by Cornwell Gavin on 17/03/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveCMISTests.h"
#import "ObjectiveCMISTests+Environment.h"
#import "CMISSession.h"
#import "CMISConstants.h"
#import "CMISDocument.h"
#import "CMISFileUtil.h"
#import "CMISAtomLink.h"
#import "CMISAtomPubConstants.h"
#import "CMISObjectList.h"
#import "CMISQueryResult.h"
#import "CMISStringInOutParameter.h"
#import "CMISTypeDefinition.h"
#import "CMISPropertyDefinition.h"
#import "CMISObjectConverter.h"
#import "ISO8601DateFormatter.h"
#import "CMISOperationContext.h"
#import "CMISPagedResult.h"

@interface ObjectiveCMISTests()

@property (nonatomic, strong) CMISSession *session;
@property (nonatomic, strong) CMISFolder *rootFolder;
@property BOOL callbackCompleted;

@end

@implementation ObjectiveCMISTests

@synthesize parameters = _parameters;
@synthesize repositoryId = _repositoryId;
@synthesize rootFolderId = _rootFolderId;
@synthesize session = _session;
@synthesize rootFolder = _rootFolder;
@synthesize callbackCompleted = _callbackCompleted;


- (void)setUp
{
    [super setUp];
    
    NSString *urlString = [self environmentStringForKey:kCMISTestAtomPubUrlKey defaultValue:@"http://ec2-79-125-44-131.eu-west-1.compute.amazonaws.com/alfresco/service/api/cmis"];
    
    self.parameters = [[CMISSessionParameters alloc] initWithBindingType:CMISBindingTypeAtomPub];
    self.parameters.username = [self environmentStringForKey:kCMISTestUsernameKey defaultValue:@"admin"];
    self.parameters.password = [self environmentStringForKey:kCMISTestPasswordKey defaultValue:@"alzheimer"];
    self.parameters.atomPubUrl = [[NSURL alloc] initWithString:urlString];
    self.parameters.repositoryId = [self environmentStringForKey:kCMISTestRepoIdKey defaultValue:@"246b1d64-9a1f-4c56-8900-594a4b85bd05"];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testRepositories
{
    NSError *error = nil;
    NSArray *repos = [CMISSession arrayOfRepositories:self.parameters error:&error];
    STAssertNil(error, @"Error when calling arrayOfRepositories : %@", [error description]);
    STAssertNotNil(repos, @"repos object should not be nil");
    STAssertTrue(repos.count > 0, @"There should be at least one repository");
}

- (void)testAuthenticateWithInvalidCredentials
{
    self.parameters.username = @"bogus";
    self.parameters.password = @"sugob";

    CMISSession *session = [[CMISSession alloc] initWithSessionParameters:self.parameters];
    STAssertNotNil(session, @"session object should not be nil");

    NSError *error = nil;
    if (![session authenticateAndReturnError:&error]) {
        log(@"*** testAuthenticateWithInvalidCredentials: error domain is %@, error code is %d and error description is %@",[error domain], [error code], [error description]);
        NSError *underlyingError = [[error userInfo] valueForKey:NSUnderlyingErrorKey];
        if (underlyingError) {
            log(@"There is an underlying error with reason %@ and error code %d",[underlyingError localizedDescription], [underlyingError code]);
        }
    }
    STAssertFalse(session.isAuthenticated, @"session should NOT be authenticated");
    STAssertNotNil(error, @"Error should not be nil");
}

- (void)testGetRootFolder
{
    [self setupCmisSession];

    // make sure the repository info is available immediately after authentication
    CMISRepositoryInfo *repoInfo = self.session.repositoryInfo;
    STAssertNotNil(repoInfo, @"repoInfo object should not be nil");

    // check the repository info is what we expect
    STAssertTrue([repoInfo.productVersion rangeOfString:@"4.0.0"].length > 0, @"Product Version should be 4.0.0 (b @build-number@), but was %@", repoInfo.productVersion);
    STAssertTrue([repoInfo.vendorName isEqualToString:@"Alfresco"], @"Vendor name should be Alfresco");

    // retrieve the root folder
    CMISFolder *rootFolder = [self.session rootFolder];
    STAssertNotNil(rootFolder, @"rootFolder object should not be nil");
    NSString *rootName = rootFolder.name;
    STAssertTrue([rootName isEqualToString:@"Company Home"], @"rootName should be Company Home, but was %@", rootName);

    // check it was modified and created by System and the dates are not nil
    NSString *createdBy = rootFolder.createdBy;
    STAssertTrue([createdBy isEqualToString:@"System"], @"root folder should be created by System");

    NSString *modifiedBy = rootFolder.lastModifiedBy;
    STAssertTrue([modifiedBy isEqualToString:@"System"], @"root folder should be modified by System");

    NSDate *createdDate = rootFolder.creationDate;
    STAssertNotNil(createdDate, @"created date should not be nil");

    NSDate *modifiedDate = rootFolder.lastModificationDate;
    STAssertNotNil(modifiedDate, @"modified date should not be nil");

    // retrieve the children of the root folder, there should be more than 10!
    NSError *error = nil;
    CMISPagedResult *pagedResult = [rootFolder retrieveChildrenAndReturnError:&error];
    STAssertNil(error, @"Got error while retrieving children: %@", [error description]);
    STAssertNotNil(pagedResult, @"Return result should not be nil");

    NSArray *children = pagedResult.resultArray;
    STAssertNotNil(children, @"children should not be nil");
    NSLog(@"There are %d children", [children count]);
    STAssertTrue([children count] > 5, @"There should be at least 5 children");
}

- (void)testRetrieveFolderChildrenUsingPaging
{
    [self setupCmisSession];
    NSError *error = nil;

    // Fetch 2 children at a time
    CMISOperationContext *operationContext = [CMISOperationContext defaultOperationContext];
    operationContext.skipCount = 0;
    operationContext.maxItemsPerPage = 2;
    CMISPagedResult *pagedResult = [self.rootFolder retrieveChildrenWithOperationContext:operationContext andReturnError:&error];
    STAssertNil(error, @"Got error while retrieving children: %@", [error description]);
    STAssertTrue(pagedResult.hasMoreItems, @"There should still be more children");
    STAssertTrue(pagedResult.numItems > 2, @"The test repository should have more than 2 objects");
    STAssertTrue(pagedResult.resultArray.count == 2, @"Expected 2 children in the page, but got %d", pagedResult.resultArray.count);

    // Save object ids for checking the next pages
    NSMutableArray *objectIds = [NSMutableArray array];
    for (CMISObject *object in pagedResult.resultArray)
    {
        [objectIds addObject:object.identifier];
    }

    // Fetch second page
    CMISPagedResult *secondPageResult = [pagedResult fetchNextPageAndReturnError:&error];
    STAssertNil(error, @"Got error while retrieving children: %@", [error description]);
    STAssertTrue(secondPageResult.hasMoreItems, @"There should still be more children");
    STAssertTrue(secondPageResult.numItems > 2, @"The test repository should have more than 4 objects");
    STAssertTrue(secondPageResult.resultArray.count == 2, @"Expected 2 children in the page, but got %d", pagedResult.resultArray.count);

    // Verify if no double object ids were found
    for (CMISObject *object in secondPageResult.resultArray)
    {
        STAssertTrue(![objectIds containsObject:object.identifier], @"Object was already returned in a previous page. This is a serious impl bug!");
        [objectIds addObject:object.identifier];
    }

    // Fetch third page, just to be sure
    CMISPagedResult *thirdPageResult = [secondPageResult fetchNextPageAndReturnError:&error];
    STAssertNil(error, @"Got error while retrieving children: %@", [error description]);
    STAssertTrue(thirdPageResult.hasMoreItems, @"There should still be more children");
    STAssertTrue(thirdPageResult.numItems > 2, @"The test repository should have more than 6 objects");
    STAssertTrue(thirdPageResult.resultArray.count == 2, @"Expected 2 children in the page, but got %d", pagedResult.resultArray.count);

    // Verify if no double object ids were found
    for (CMISObject *object in thirdPageResult.resultArray)
    {
        STAssertTrue(![objectIds containsObject:object.identifier], @"Object was already returned in a previous page. This is a serious impl bug!");
        [objectIds addObject:object.identifier];
    }
}

- (void)testDocumentProperties
{
    [self setupCmisSession];

    // Get some random document
    CMISDocument *document = [self retrieveVersionedTestDocument];

    // Verify properties
    STAssertNotNil(document.name, @"Document name should not be nil");
    STAssertNotNil(document.identifier, @"Document identifier should not be nil");
    STAssertNotNil(document.objectType, @"Document object type should not be nil");

    STAssertNotNil(document.createdBy, @"Document created by should not be nil");
    STAssertNotNil(document.creationDate, @"Document creation date should not be nil");

    STAssertNotNil(document.lastModificationDate, @"Document last modification date should not be nil");
    STAssertNotNil(document.lastModifiedBy, @"Document last modified by should not be nil");

    STAssertNotNil(document.versionLabel, @"Document version label should not be nil");
    STAssertNotNil(document.versionSeriesId, @"Document version series id should not be nil");
    STAssertTrue(document.isLatestVersion, @"Document should be latest version");
    STAssertFalse(document.isLatestMajorVersion, @"Document should be latest major version");
    STAssertFalse(document.isMajorVersion, @"Document should be major version");

    STAssertNotNil(document.contentStreamId, @"Document content stream id should not be nil");
    STAssertNotNil(document.contentStreamFileName, @"Document content stream file name should not be nil");
    STAssertNotNil(document.contentStreamMediaType, @"Document content stream media type should not be nil");
    STAssertTrue(document.contentStreamLength > 0, @"Document content stream length should be set");
}


- (void)testRetrieveAllowableActions
{
    [self setupCmisSession];
    CMISDocument *document = [self uploadTestFile];

    STAssertNotNil(document.allowableActions, @"Allowable actions should not be nil");
    STAssertTrue(document.allowableActions.allowableActionsSet.count > 0, @"Expected at least one allowable action");

    // Cleanup
    [self deleteDocumentAndVerify:document];
}

- (void)testFileDownload
{

    NSError *error = nil;
    [self setupCmisSession];

    CMISFolder *rootFolder = [self.session rootFolder];
    STAssertNotNil(rootFolder, @"rootFolder object should not be nil");

    CMISOperationContext *operationContext = [CMISOperationContext defaultOperationContext];
    operationContext.maxItemsPerPage = 100;
    CMISPagedResult *childrenResult = [rootFolder retrieveChildrenWithOperationContext:operationContext andReturnError:&error];
    STAssertNil(error, @"Got error while retrieving children: %@", [error description]);
    STAssertNotNil(childrenResult, @"childrenCollection should not be nil");

    NSArray *children = childrenResult.resultArray;
    STAssertNotNil(children, @"children should not be nil");
    STAssertTrue([children count] > 5, @"There should be at least 5 children");

    CMISDocument *randomDoc = nil;
    for (CMISObject *object in children)
    {
        if ([object class] == [CMISDocument class])
        {
            randomDoc = (CMISDocument *)object;
        }
    }

    STAssertNotNil(randomDoc, @"Can only continue test if root folder contains at least one document");
    NSLog(@"Fetching content stream for document %@", randomDoc.name);

    // Writing content of CMIS document to local file
    NSString *filePath = @"testfile";
    [randomDoc downloadContentToFile:filePath completionBlock:^{
        self.callbackCompleted = YES;
    } failureBlock:^(NSError *failureError) {
        STAssertNil(failureError, @"Error while writing content: %@", [error description]);
        self.callbackCompleted = YES;
    } progressBlock:nil];
    [self waitForCompletion:60];

    // Assert File exists and check file length
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:filePath], @"File does not exist");
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
    STAssertNil(error, @"Could not verify attributes of file %@: %@", filePath, [error description]);
    STAssertTrue([fileAttributes fileSize] > 10, @"Expected a file of at least 10 bytes, but found one of %d bytes", [fileAttributes fileSize]);

    // Nice boys clean up after themselves
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    STAssertNil(error, @"Could not remove file %@: %@", filePath, [error description]);

}

- (void)testCreateAndDeleteDocument
{
    NSError *error = nil;
    [self setupCmisSession];

    // Check if test file exists
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file.txt" ofType:nil];
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:filePath],
        @"Test file 'test_file.txt' cannot be found as resource for the test");

    // Upload test file
    NSString *documentName = [NSString stringWithFormat:@"test_file_%@.txt", [self stringFromCurrentDate]];
    NSMutableDictionary *documentProperties = [NSMutableDictionary dictionary];
    [documentProperties setObject:documentName forKey:kCMISPropertyName];
    [documentProperties setObject:kCMISPropertyObjectTypeIdValueDocument forKey:kCMISPropertyObjectTypeId];

    NSString *objectId = [self.rootFolder createDocumentFromFilePath:filePath withMimeType:@"text/plain" withProperties:documentProperties error:&error];
    STAssertNil(error, @"Got error while creating document: %@", [error description]);
    STAssertNotNil(objectId, @"Object id received should be non-nil");

    // Verify created
    CMISDocument *document = (CMISDocument *) [self.session retrieveObject:objectId error:&error];
    STAssertTrue([documentName isEqualToString:document.name],
        @"Document name of created document is wrong: should be %@, but was %@", documentName, document.name);

    // Cleanup after ourselves
    BOOL documentDeleted = [document deleteAllVersionsAndReturnError:&error];
    STAssertNil(error, @"Error while deleting created document: %@", [error description]);
    STAssertTrue(documentDeleted, @"Document was not deleted");
}

- (void)testCreateBigDocument
{
    NSError *error = nil;
    [self setupCmisSession];

    // Check if test file exists
    NSString *fileToUploadPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"cmis-spec-v1.0.pdf" ofType:nil];
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:fileToUploadPath],
        @"Test file 'cmis-spec-v1.0.pdf' cannot be found as resource for the test");

    // Upload test file
    NSString *documentName = @"cmis-spec-v1.0.pdf";
    NSMutableDictionary *documentProperties = [NSMutableDictionary dictionary];
    [documentProperties setObject:documentName forKey:kCMISPropertyName];
    [documentProperties setObject:kCMISPropertyObjectTypeIdValueDocument forKey:kCMISPropertyObjectTypeId];

    NSString *objectId = [self.rootFolder createDocumentFromFilePath:fileToUploadPath withMimeType:@"application/pdf" withProperties:documentProperties error:&error];
    STAssertNil(error, @"Got error while creating document: %@", [error description]);
    STAssertNotNil(objectId, @"Object id received should be non-nil");

    // Verify created file by downloading it again
    CMISDocument *document = (CMISDocument *) [self.session retrieveObject:objectId error:&error];
    STAssertTrue([documentName isEqualToString:document.name],
        @"Document name of created document is wrong: should be %@, but was %@", documentName, document.name);

   __block NSInteger previousBytesDownloaded = -1;
    NSString *downloadedFilePath = @"testfile.pdf";
    [document downloadContentToFile:downloadedFilePath completionBlock:^{
        NSLog(@"File upload completed");
        self.callbackCompleted = YES;
    } failureBlock:^(NSError *failureError) {
        STAssertNil(failureError, @"Error while writing content: %@", [error description]);
        self.callbackCompleted = YES;
    } progressBlock:^(NSInteger bytesDownloaded, NSInteger bytesTotal) {
        STAssertTrue(bytesDownloaded > previousBytesDownloaded, @"No progress in downloading file");
        previousBytesDownloaded = bytesDownloaded;
    }];
    [self waitForCompletion:60];

    // Compare file sizes
    long long originalFileSize = [FileUtil fileSizeForFileAtPath:fileToUploadPath error:&error];
    STAssertNil(error, @"Got error while getting file size for %@: %@", fileToUploadPath, [error description]);
    long long downloadedFileSize = [FileUtil fileSizeForFileAtPath:downloadedFilePath error:&error];
    STAssertNil(error, @"Got error while getting file size for %@: %@", downloadedFilePath, [error description]);
    STAssertTrue(originalFileSize == downloadedFileSize, @"Original file size (%lld) is not equal to downloaded file size (%lld)", originalFileSize, downloadedFilePath);

    // Cleanup after ourselves
    BOOL documentDeleted = [document deleteAllVersionsAndReturnError:&error];
    STAssertNil(error, @"Error while deleting created document: %@", [error description]);
    STAssertTrue(documentDeleted, @"Document was not deleted");

    [[NSFileManager defaultManager] removeItemAtPath:downloadedFilePath error:&error];
    STAssertNil(error, @"Could not remove file %@: %@", downloadedFilePath, [error description]);
}

- (void)testCreateAndDeleteFolder
{
    [self setupCmisSession];
    NSError *error = nil;

    // Create a test folder
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    [properties setObject:@"test-folder" forKey:kCMISPropertyName];
    [properties setObject:kCMISPropertyObjectTypeIdValueFolder forKey:kCMISPropertyObjectTypeId];

    NSString *newFolderObjectId = [self.rootFolder createFolder:properties error:&error];
    STAssertNil(error, @"Error while creating folder in root folder: %@", [error description]);

    // Delete the test folder again
    CMISFolder *newFolder = (CMISFolder *) [self.session retrieveObject:newFolderObjectId error:&error];
    STAssertNil(error, @"Error while retrieving newly created folder: %@", [error description]);
    STAssertNotNil(newFolder, @"New folder should not be nil");
    [newFolder deleteTreeAndReturnError:&error];
    STAssertNil(error, @"Error while deleting newly created folder: %@", [error description]);
}

- (void)testRetrieveAllVersionsOfDocument
{
    [self setupCmisSession];
    NSError *error = nil;

    // First find the document which we know that has some versions
    CMISDocument *document = [self retrieveVersionedTestDocument];

    // Get all the versions of the document
    CMISCollection *allVersionsOfDocument = [document retrieveAllVersionsAndReturnError:&error];
    STAssertNil(error, @"Error while retrieving all versions of document : %@", [error description]);
    STAssertTrue(allVersionsOfDocument.items.count == 5, @"Expected 5 versions of document, but was %d", allVersionsOfDocument.items.count);

    // Print out the version labels and verify them, while also verifying that they are ordered by creation date, descending
    NSDate *previousModifiedDate = document.lastModificationDate;
    for (CMISDocument *versionOfDocument in allVersionsOfDocument.items)
    {
        NSLog(@"%@ - version %@", versionOfDocument.name, versionOfDocument.versionLabel);

        if (!versionOfDocument.isLatestVersion) // latest version is the one we got originally
        {
            STAssertTrue([document.name isEqualToString:versionOfDocument.name], @"Other version of same document does not have the same name");
            STAssertFalse([document.versionLabel isEqualToString:versionOfDocument.versionLabel], @"Other version of same document should have different version label");
            STAssertTrue([previousModifiedDate compare:versionOfDocument.lastModificationDate] == NSOrderedDescending,
                       @"Versions of document should be ordered descending by creation date");
            previousModifiedDate = versionOfDocument.lastModificationDate;
        }


    }

    // Take an older version, and verify its version properties
    CMISDocument *olderVersionOfDocument = [allVersionsOfDocument.items objectAtIndex:3]; // In the test data, this should be version 1.0 of doc.
    STAssertFalse(olderVersionOfDocument.isLatestVersion, @"Older version of document should have 'false' for the property 'isLatestVersion");
    STAssertFalse(olderVersionOfDocument.isLatestMajorVersion, @"Older version of document should have 'false' for the property 'isLatestMajorVersion");
    STAssertTrue(olderVersionOfDocument.isMajorVersion, @"Older version of document should have 'true' for the property 'isMajorVersion");
}

-(void)testRetrieveLatestVersionOfDocument
{
    [self setupCmisSession];
    NSError *error = nil;

     // First find the document which we know that has some versions
    CMISDocument *document = [self retrieveVersionedTestDocument];

    // Check if the document retrieved is the latest version
    CMISDocument *latestVersionOfDocument = [document retrieveObjectOfLatestVersionAndReturnError:&error];
    STAssertNil(error, @"Error while retrieving latest version of document");
    STAssertTrue([document.versionLabel isEqualToString:latestVersionOfDocument.versionLabel], @"Version label should match");
    STAssertTrue([document.creationDate isEqual:latestVersionOfDocument.creationDate], @"Creation dates should be equal");

    // Retrieve an older version, and check if we get the right one back if we call the 'retrieveLatest' on it
    CMISCollection *allVersionsOfDocument = [document retrieveAllVersionsAndReturnError:&error];
    STAssertNil(error, @"Error while retrieving all versions: %@", [error description]);

    CMISDocument *olderVersionOfDocument = [allVersionsOfDocument.items objectAtIndex:1];
    STAssertFalse([document.versionLabel isEqualToString:olderVersionOfDocument.versionLabel], @"Version label should NOT match");
    STAssertTrue([document.creationDate isEqualToDate:olderVersionOfDocument.creationDate], @"Creation dates should match");
    STAssertFalse([document.lastModificationDate isEqual:olderVersionOfDocument.lastModificationDate], @"Creation dates should NOT match");

    latestVersionOfDocument = [olderVersionOfDocument retrieveObjectOfLatestVersionAndReturnError:&error];
    STAssertNil(error, @"Error while retrieving latest version of document");
    STAssertNotNil(latestVersionOfDocument, @"Latest version should not be nil");
    STAssertTrue([document.name isEqualToString:latestVersionOfDocument.name], @"Name should match: expected %@ but was %@", document.name, latestVersionOfDocument.name);
    STAssertTrue([document.versionLabel isEqualToString:latestVersionOfDocument.versionLabel], @"Version label should match");
    STAssertTrue([document.lastModificationDate isEqual:latestVersionOfDocument.lastModificationDate], @"Creation dates should be equal");
}

- (void)testLinkRelations
{
    NSMutableSet *setup = [NSMutableSet set];
    [setup addObject:[[CMISAtomLink alloc] initWithRelation:@"down" type:kCMISMediaTypeChildren href:@"http://down/children"]];
    [setup addObject:[[CMISAtomLink alloc] initWithRelation:@"down" type:kCMISMediaTypeDescendants href:@"http://down/descendants"]];
    [setup addObject:[[CMISAtomLink alloc] initWithRelation:@"up" type:kCMISMediaTypeChildren href:@"http://up/children"]];
    [setup addObject:[[CMISAtomLink alloc] initWithRelation:@"up" type:kCMISMediaTypeEntry href:@"http://up/entry"]];
    [setup addObject:[[CMISAtomLink alloc] initWithRelation:@"service" type:nil href:@"http://service"]];
    CMISLinkRelations *linkRelations = [[CMISLinkRelations alloc] initWithLinkRelationSet:setup];
    
    STAssertNil([linkRelations linkHrefForRel:@"down"], @"Expected nil since there are more link relations with the down relations");
    STAssertEquals([linkRelations linkHrefForRel:@"service"], @"http://service", @"The Service link should have been returned");
    STAssertEquals([linkRelations linkHrefForRel:@"down" type:kCMISMediaTypeChildren], @"http://down/children", @"The down relation for the children media type should have been returned");
    STAssertEquals([linkRelations linkHrefForRel:@"down" type:kCMISMediaTypeDescendants], @"http://down/descendants", @"The down relation for the descendants media type should have been returned");
}

- (void)testQueryThroughDiscoveryService
{
    [self setupCmisSession];
    NSError *error = nil;

    id<CMISDiscoveryService> discoveryService = self.session.binding.discoveryService;
    STAssertNotNil(discoveryService, @"Discovery service should not be nil");

    // Basic check if the service returns results that are usable
    CMISObjectList *objectList = [discoveryService query:@"SELECT * FROM cmis:document" searchAllVersions:NO
                                                includeRelationShips:CMISIncludeRelationshipNone
                                                renditionFilter:nil
                                                includeAllowableActions:YES
                                                maxItems:[NSNumber numberWithInt:3]
                                                skipCount:[NSNumber numberWithInt:0]
                                                error:&error];
    STAssertNil(error, @"Got an error while executing query: %@", [error description]);
    STAssertNotNil(objectList, @"Object list after query should not be nil");
    STAssertTrue(objectList.numItems > 100, @"Expecting at least 100 items when querying for all documents, but got %d", objectList.numItems);
    STAssertTrue(objectList.objects.count == 3, @"Expected 3 items to be returned, but was %d", objectList.objects.count);

    for (CMISObjectData *objectData in objectList.objects)
    {
        STAssertTrue(objectData.properties.propertiesDictionary.count > 10, @"Expecting properties to be passed when querying");
    }

    // Doing a query without any maxItems or skipCount, and also only requesting one property 'column'
    objectList = [discoveryService query:@"SELECT cmis:name FROM cmis:document WHERE cmis:name LIKE '%quote%'"
                       searchAllVersions:NO
                       includeRelationShips:CMISIncludeRelationshipNone
                       renditionFilter:nil
                       includeAllowableActions:YES
                       maxItems:nil skipCount:nil error:&error];
    STAssertNil(error, @"Got an error while executing query: %@", [error description]);
    STAssertNotNil(objectList, @"Object list after query should not be nil");
    STAssertTrue(objectList.objects.count > 0, @"Returned # objects is repo specific, but should be at least 1");

    CMISObjectData *firstResult = [objectList.objects objectAtIndex:0];
    STAssertTrue(firstResult.properties.propertiesDictionary.count == 1, @"Only querying for 1 property, but got %d properties back", firstResult.properties.propertiesDictionary.count);

}

- (void)testQueryThroughSession
{
   [self setupCmisSession];
    NSError *error = nil;

    // Query all properties
    CMISPagedResult *result = [self.session query:@"SELECT * FROM cmis:document WHERE cmis:name LIKE '%quote%'" searchAllVersions:YES error:&error];
    STAssertNil(error, @"Got an error while executing query: %@", [error description]);
    STAssertTrue(result.resultArray.count > 0, @"Expected at least one result for query");

    CMISQueryResult *firstResult = [result.resultArray objectAtIndex:0];
    STAssertNotNil([firstResult.properties propertyForId:kCMISPropertyName], @"Name property should not be nil");
    STAssertNotNil([firstResult.properties propertyForId:kCMISPropertyVersionLabel], @"Version label property should not be nil");
    STAssertNotNil([firstResult.properties propertyForId:kCMISPropertyCreationDate], @"Creation date property should not be nil");
    STAssertNotNil([firstResult.properties propertyForId:kCMISPropertyContentStreamLength], @"Content stream length property should not be nil");

    STAssertNotNil([firstResult.properties propertyForQueryName:kCMISPropertyName], @"Name property should not be nil");
    STAssertNotNil([firstResult.properties propertyForQueryName:kCMISPropertyVersionLabel], @"Version label property should not be nil");
    STAssertNotNil([firstResult.properties propertyForQueryName:kCMISPropertyCreationDate], @"Creation date property should not be nil");
    STAssertNotNil([firstResult.properties propertyForQueryName:kCMISPropertyContentStreamLength], @"Content stream length property should not be nil");

    // Query a limited set of properties
    result = [self.session query:@"SELECT cmis:name, cmis:creationDate FROM cmis:document WHERE cmis:name LIKE '%activiti%'" searchAllVersions:NO error:&error];
    STAssertNil(error, @"Got an error while executing query: %@", [error description]);
    STAssertTrue(result.resultArray.count > 0, @"Expected at least one result for query");

    firstResult = [result.resultArray objectAtIndex:0];
    STAssertNotNil([firstResult.properties propertyForId:kCMISPropertyName], @"Name property should not be nil");
    STAssertNotNil([firstResult.properties propertyForId:kCMISPropertyCreationDate], @"Creation date property should not be nil");
    STAssertNil([firstResult.properties propertyForId:kCMISPropertyVersionLabel], @"Version label property should be nil");
    STAssertNil([firstResult.properties propertyForId:kCMISPropertyContentStreamLength], @"Content stream length property should be nil");
    STAssertNotNil(firstResult.allowableActions, @"By default, allowable actions whould be included");
    STAssertTrue(firstResult.allowableActions.allowableActionsSet.count > 0, @"Expected at least one allowable action");

    // With operationContext
    CMISOperationContext *context = [[CMISOperationContext alloc] init];
    context.isIncludeAllowableActions = NO;
    result = [self.session query:@"SELECT * FROM cmis:document WHERE cmis:name LIKE '%quote%'"
                searchAllVersions:YES operationContext:context error:&error];
    firstResult = [result.resultArray objectAtIndex:0];
    STAssertNil(error, @"Got an error while executing query: %@", [error description]);
    STAssertTrue(result.resultArray.count > 0, @"Expected at least one result for query");
    STAssertTrue(firstResult.allowableActions.allowableActionsSet.count == 0,
        @"Expected allowable actions, as the operation ctx excluded them, but found %d allowable actions", firstResult.allowableActions.allowableActionsSet.count);
}

- (void)testQueryWithPaging
{
    [self setupCmisSession];
     NSError *error = nil;

    // Fetch first page
    CMISOperationContext *context = [[CMISOperationContext alloc] init];
    context.maxItemsPerPage = 5;
    context.skipCount = 0;
    CMISPagedResult *firstPageResult = [self.session query:@"SELECT * FROM cmis:document" searchAllVersions:YES operationContext:context error:&error];
    STAssertNil(error, @"Got an error while executing query: %@", [error description]);
    STAssertTrue(firstPageResult.resultArray.count == 5, @"Expected 5 results, but got %d back", firstPageResult.resultArray.count);

    // Save all the ids to check them later
    NSMutableArray *idsOfFirstPage = [NSMutableArray array];
    for (CMISQueryResult *queryresult in firstPageResult.resultArray)
    {
        [idsOfFirstPage addObject:[queryresult propertyForId:kCMISPropertyObjectId]];
    }

    // Fetch second page
    CMISPagedResult *secondPageResults = [firstPageResult fetchNextPageAndReturnError:&error];
    STAssertNil(error, @"Got an error while executing query: %@", [error description]);
    STAssertTrue(secondPageResults.resultArray.count == 5, @"Expected 5 results, but got %d back", secondPageResults.resultArray.count);

    for (CMISQueryResult *queryResult in secondPageResults.resultArray)
    {
        STAssertFalse([idsOfFirstPage containsObject:[queryResult propertyForId:kCMISPropertyObjectId]], @"Found same object in first and second page");
    }

    // Fetch last element by specifying a page which is just lastelement-1
    context.skipCount = secondPageResults.numItems - 1;
    CMISPagedResult *thirdPageResults = [self.session query:@"SELECT * FROM cmis:document"
                                            searchAllVersions:YES operationContext:context error:&error];
    STAssertNil(error, @"Got an error while executing query: %@", [error description]);
    STAssertTrue(thirdPageResults.resultArray.count == 1, @"Expected 1 result, but got %d back", thirdPageResults.resultArray.count);
}

- (void)testRetrieveParents
{
    [self setupCmisSession];
    NSError *error = nil;

    // First, do a query for our test document
    NSString *queryStmt = @"SELECT * FROM cmis:document WHERE cmis:name = 'thumbsup-ios-test-retrieve-parents.gif'";
    CMISPagedResult *results = [self.session query:queryStmt searchAllVersions:NO error:&error];
    STAssertNil(error, @"Got an error while executing query: %@", [error description]);
    STAssertTrue(results.resultArray.count == 1, @"Expected one result for query");
    CMISQueryResult *result = [results.resultArray objectAtIndex:0];

    // Retrieve the document as CMISDocument
    NSString *objectId = [[result propertyForId:kCMISPropertyObjectId] firstValue];
    CMISDocument *document = (CMISDocument *) [self.session retrieveObject:objectId error:&error];
    STAssertNil(error, @"Got an error while retrieving test document: %@", [error description]);
    STAssertNotNil(document, @"Test document should not be nil");

    // Verify the parents of this document
    CMISFileableObject *currentObject = document;
    NSArray *expectedParentFolderNames = [NSArray arrayWithObjects:@"ios-subsubfolder", @"ios-subfolder", @"ios-test", @"Company Home", nil];

    for (NSString *expectedFolderName in expectedParentFolderNames)
    {
        NSArray *parentFolders = [currentObject retrieveParentsAndReturnError:&error];
        STAssertNil(error, @"Got an error while retrieving parent folders: %@", [error description]);
        STAssertTrue(parentFolders.count == 1, @"Expecting only 1 parent, but found %d parents", parentFolders.count);
        currentObject = [parentFolders objectAtIndex:0];
        STAssertEqualObjects(expectedFolderName, currentObject.name, @"Wrong parent folder");
    }

    // Check if the root folder parent is empty
    NSArray *parentFolders = [currentObject retrieveParentsAndReturnError:&error];
    STAssertNil(error, @"Got an error while retrieving parent folders: %@", [error description]);
    STAssertTrue(parentFolders.count == 0, @"Root folder should not have any parents");
}

- (void)testRetrieveNonExistingObject
{
    [self setupCmisSession];
    NSError *error = nil;

    // test with non existing object id
    CMISDocument *document = (CMISDocument *) [self.session retrieveObject:@"bogus" error:&error];
    STAssertNil(error, @"Error while retrieving object by bogus id");
    STAssertNil(document, @"Document should be nil");

     // Test with a non existing path
    NSString *path = @"/bogus/i_do_not_exist.pdf";
    document = (CMISDocument *) [self.session retrieveObjectByPath:path error:&error];
    STAssertNil(error, @"Error while retrieving object with path %@", path);
    STAssertNil(document, @"Document should be nil");
}

- (void)testRetrieveObjectByPath
{
    [self setupCmisSession];
    NSError *error = nil;

    // Use a document that has spaces in them (should be correctly encoded)
    NSString *path = [NSString stringWithFormat:@"%@activiti logo big.png", self.rootFolder.path];
    CMISDocument *document = (CMISDocument *) [self.session retrieveObjectByPath:path error:&error];
    STAssertNil(error, @"Error while retrieving object with path %@", path);
    STAssertNotNil(document, @"Document should not be nil");
    STAssertEqualObjects(@"activiti logo big.png", document.name, @"When retrieving document by path, name does not match");

    // Test with a few folders
    path = @"/ios-test/ios-subfolder/ios-subsubfolder/activiti-logo.png";
    document = (CMISDocument *) [self.session retrieveObjectByPath:path error:&error];
    STAssertNil(error, @"Error while retrieving object with path %@", path);
    STAssertNotNil(document, @"Document should not be nil");
}

// In this test, we'll upload a test file
// Change the content of that test file
// And verify of the content is correct
- (void)testChangeContentOfDocument
{
    [self setupCmisSession];
    NSError *error = nil;

    // Upload test file
    CMISDocument *originalDocument = [self uploadTestFile];

    // Change content of test file using overwrite
    NSString *newContentFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file_2.txt" ofType:nil];
    [self.session.binding.objectService changeContentOfObject:[CMISStringInOutParameter inOutParameterUsingInParameter:originalDocument.identifier]
                                        toContentOfFile:newContentFilePath
                                        withOverwriteExisting:YES
                                        withChangeToken:nil
                                        error:&error];
    STAssertNil(error, @"Got error while changing content of document: %@", [error description]);

    // Verify content of document
    NSString *tempDownloadFilePath = @"temp_download_file.txt";
    CMISDocument *latestVersionOfDocument = [originalDocument retrieveObjectOfLatestVersionAndReturnError:&error]; // some repos will up the version when uploading new content
    [latestVersionOfDocument downloadContentToFile:tempDownloadFilePath completionBlock:^{
        self.callbackCompleted = YES;
    } failureBlock:^(NSError *failureError) {
        STAssertNil(failureError, @"Error while writing content: %@", [error description]);
        self.callbackCompleted = YES;
    } progressBlock:nil];
    [self waitForCompletion:60];

    NSString *contentOfDownloadedFile = [NSString stringWithContentsOfFile:tempDownloadFilePath encoding:NSUTF8StringEncoding error:nil];
    STAssertEqualObjects(@"In theory, there is no difference between theory and practice. But in practice, there is.",
        contentOfDownloadedFile, @"Downloaded file content does not match: '%@'", contentOfDownloadedFile);

    // Delete downloaded file
    [[NSFileManager defaultManager] removeItemAtPath:tempDownloadFilePath error:&error];
    STAssertNil(error, @"Error when deleting temporary downloaded file: %@", [error description]);

    // Delete test document from server
    [self deleteDocumentAndVerify:originalDocument];
}

- (void)testDeleteContentStream
{
    [self setupCmisSession];
    NSError *error = nil;

    // Upload test file
    CMISDocument *originalDocument = [self uploadTestFile];

    // Delete its content
    [originalDocument deleteContentAndReturnError:&error];
    STAssertNil(error, @"Got error while deleting content of document: %@", [error description]);

    // Get latest version and verify content length
    CMISDocument *latestVersion = [originalDocument retrieveObjectOfLatestVersionAndReturnError:&error];
    STAssertNil(error, @"Got error while getting latest version of documet: %@", [error description]);
    STAssertTrue(latestVersion.contentStreamLength == 0, @"Expected zero content length for document with no content, but was %d", latestVersion.contentStreamLength);

    // Delete test document from server
    [self deleteDocumentAndVerify:originalDocument];
}

- (void)testRetrieveTypeDefinition
{
    [self setupCmisSession];
    NSError *error = nil;

    CMISTypeDefinition *typeDefinition = [self.session.binding.repositoryService retrieveTypeDefinition:@"cmis:document" error:&error];
    STAssertNil(error, @"Got error while retrieving type definition: %@", [error description]);

    // Check type definition properties
    STAssertNotNil(typeDefinition, @"Type definition should not be nil");
    STAssertTrue(typeDefinition.baseTypeId == CMISBaseTypeDocument, @"Unexpected base type id");
    STAssertNotNil(typeDefinition.description, @"Type description should not be nil");
    STAssertNotNil(typeDefinition.displayName, @"Type displayName should not be nil");
    STAssertNotNil(typeDefinition.id, @"Type id should not be nil");
    STAssertTrue([typeDefinition.id isEqualToString:@"cmis:document"], @"Wrong id for type");
    STAssertNotNil(typeDefinition.localName, @"Type local name should not be nil");
    STAssertNotNil(typeDefinition.localNameSpace, @"Type local namespace should not be nil");
    STAssertNotNil(typeDefinition.queryName, @"Type query name should not be nil");

    // Check property definitions
    STAssertTrue(typeDefinition.propertyDefinitions.count > 0, @"Expected at least one propery definition, but got %d", typeDefinition.propertyDefinitions.count);
    for (id key in typeDefinition.propertyDefinitions)
    {
        CMISPropertyDefinition *propertyDefinition = [typeDefinition.propertyDefinitions objectForKey:key];
        STAssertNotNil(propertyDefinition.description, @"Property definition description should not be nil");
        STAssertNotNil(propertyDefinition.displayName, @"Property definition display name should not be nil");
        STAssertNotNil(propertyDefinition.id, @"Property definition id should not be nil");
        STAssertNotNil(propertyDefinition.localName, @"Property definition local name should not be nil");
        STAssertNotNil(propertyDefinition.localNamespace, @"Property definition local namespace should not be nil");
        STAssertNotNil(propertyDefinition.queryName, @"Property definition query name should not be nil");
    }
}

- (void)testUpdateDocumentPropertiesThroughObjectService
{
    [self setupCmisSession];
    NSError *error = nil;

    id<CMISObjectService> objectService = self.session.binding.objectService;

    // Create test document
    CMISDocument *document = [self uploadTestFile];

    // Prepare params
    CMISStringInOutParameter *objectIdInOutParam = [CMISStringInOutParameter inOutParameterUsingInParameter:document.identifier];
    CMISProperties *properties = [[CMISProperties alloc] init];
    [properties addProperty:[CMISPropertyData createPropertyForId:kCMISPropertyName withStringValue:@"name_has_changed"]];

    // Update properties and verify
    [objectService updatePropertiesForObject:objectIdInOutParam withProperties:properties withChangeToken:nil error:&error];
    STAssertNil(error, @"Got error while updating properties: %@", [error description]);
    STAssertNotNil(objectIdInOutParam.outParameter, @"When updating properties, the object id should be returned");

    NSString *newObjectId = objectIdInOutParam.outParameter;
    document = (CMISDocument *) [self.session retrieveObject:newObjectId error:&error];
    STAssertNil(error, @"Got error while retrieving test document: %@", [error description]);
    STAssertEqualObjects(document.name, @"name_has_changed", @"Name was not updated");

    // Cleanup
    [self deleteDocumentAndVerify:document];
}

- (void)testUpdateFolderPropertiesThroughObjectService
{
    [self setupCmisSession];
    NSError *error = nil;

    // Create a temporary test folder
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    [properties setObject:@"temp_test_folder" forKey:kCMISPropertyName];
    [properties setObject:kCMISPropertyObjectTypeIdValueFolder forKey:kCMISPropertyObjectTypeId];

    NSString *folderId = [self.rootFolder createFolder:properties error:&error];
    STAssertNil(error, @"Got error while creating folder: %@", [error description]);

    // Update name of test folder through object service
    id<CMISObjectService> objectService = self.session.binding.objectService;
    CMISStringInOutParameter *objectIdParam = [CMISStringInOutParameter inOutParameterUsingInParameter:folderId];
    CMISProperties *updateProperties = [[CMISProperties alloc] init];
    [updateProperties addProperty:[CMISPropertyData createPropertyForId:kCMISPropertyName withStringValue:@"temp_test_folder_renamed"]];
    [objectService updatePropertiesForObject:objectIdParam withProperties:updateProperties withChangeToken:nil error:&error];
    STAssertNil(error, @"Got error while updating folder properties: %@", [error description]);
    STAssertNotNil(objectIdParam.outParameter, @"Returned object id should not be nil");

    // Retrieve folder again and check if name has actually changed
    CMISFolder *renamedFolder = (CMISFolder *) [self.session retrieveObject:objectIdParam.outParameter error:&error];
    STAssertNil(error, @"Got error while retrieving renamed folder: %@", [error description]);
    STAssertEqualObjects(renamedFolder.name, @"temp_test_folder_renamed", @"Folder was not renamed, name is %@", renamedFolder.name);

    // Delete test folder
    [renamedFolder deleteTreeAndReturnError:&error];
    STAssertNil(error, @"Error while deleting newly created folder: %@", [error description]);
}

- (void)testUpdatePropertiesThroughCmisObject
{
    [self setupCmisSession];
    NSError *error = nil;

    // Create test document
    CMISDocument *document = [self uploadTestFile];

    // Prepare properties
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    NSString *newName = @"testUpdatePropertiesThroughCmisObject";
    [properties setObject:newName forKey:kCMISPropertyName];
    document = (CMISDocument *) [document updateProperties:properties error:&error];
    STAssertNil(error, @"Got error while retrieving renamed folder: %@", [error description]);
    STAssertEqualObjects(newName, document.name, @"Name was not updated");
    STAssertEqualObjects(newName, [document.properties propertyValueForId:kCMISPropertyName], @"Name property was not updated");

    // Cleanup
    [self deleteDocumentAndVerify:document];
}

- (void)testExtensionData
{
    [self setupCmisSession];
//    NSError *error = nil;
    
    // Test RepositoryInfo Extensions
    CMISRepositoryInfo *repoInfo = self.session.repositoryInfo;
    NSArray *repoExtensions = repoInfo.extensions;
    STAssertTrue(1 == repoExtensions.count, @"RepositoryInfo should only have one extension");
    CMISExtensionElement *element = [repoExtensions objectAtIndex:0];
    STAssertTrue([@"Version 1.0 OASIS Standard" isEqualToString:element.value], @"");
    STAssertTrue([@"http://www.alfresco.org" isEqualToString:element.namespaceUri], @"");
    STAssertTrue([@"cmisSpecificationTitle" isEqualToString:element.name], @"");
    STAssertFalse([element.children count], @"");
    STAssertFalse([element.attributes count], @"");
    
    // Test Properties Extension
    
//    TODO Add unit tests for the test server
//    
//    CMISObject *object = [self.session retrieveObject:@"workspace://SpacesStore/ad483fe8-7695-46e9-80d1-52036c114560" error:&error];
//    NSArray *extElements = object.properties.extensions;
//    STAssertNotNil(extElements, @"");
}

- (void)testPropertiesConversion
{
    [self setupCmisSession];
    NSError *error = nil;

    NSDate *testDate = [NSDate date];
    ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
    dateFormatter.includeTime = YES;

    // Create converter
    CMISObjectConverter *converter = [[CMISObjectConverter alloc] initWithSession:self.session];

    // Try to convert with already CMISPropertyData. This should work just fine.
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setObject:[CMISPropertyData createPropertyForId:kCMISPropertyName withStringValue:@"testName"] forKey:kCMISPropertyName];
    [properties setObject:[CMISPropertyData createPropertyForId:kCMISPropertyObjectTypeId withIdValue:@"cmis:document"] forKey:kCMISPropertyObjectTypeId];
    [properties setObject:[CMISPropertyData createPropertyForId:kCMISPropertyCreationDate withDateTimeValue:testDate] forKey:kCMISPropertyCreationDate];
    [properties setObject:[CMISPropertyData createPropertyForId:kCMISPropertyIsLatestVersion withBoolValue:YES] forKey:kCMISPropertyIsLatestVersion];
    [properties setObject:[CMISPropertyData createPropertyForId:kCMISPropertyContentStreamLength withIntegerValue:5] forKey:kCMISPropertyContentStreamLength];

    CMISProperties *convertedProperties = [converter convertProperties:properties forObjectTypeId:@"cmis:document" error:&error];
    STAssertNil(error, @"Error while converting properties: %@", [error description]);
    STAssertNotNil(convertedProperties, @"Conversion failed, nil was returned");
    STAssertTrue(convertedProperties.propertyList.count == 5, @"Expected 5 converted properties, but was %d", convertedProperties.propertyList.count);
    STAssertEqualObjects(@"testName", [[convertedProperties propertyForId:kCMISPropertyName]propertyStringValue], @"Converted property value did not match");
    STAssertEqualObjects(@"cmis:document", [[convertedProperties propertyForId:kCMISPropertyObjectTypeId] propertyIdValue], @"Converted property value did not match");
    STAssertEqualObjects(testDate, [[convertedProperties propertyForId:kCMISPropertyCreationDate] propertyDateTimeValue], @"Converted property value did not match");
    STAssertEqualObjects([NSNumber numberWithBool:YES], [[convertedProperties propertyForId:kCMISPropertyIsLatestVersion] propertyBooleanValue], @"Converted property value did not match");
    STAssertEqualObjects([NSNumber numberWithInteger:5], [[convertedProperties propertyForId:kCMISPropertyContentStreamLength] propertyIntegerValue], @"Converted property value did not match");

    // Test with non-CMISPropertyData values
    properties = [[NSMutableDictionary alloc] init];
    [properties setObject:@"test" forKey:kCMISPropertyName];
    [properties setObject:@"cmis:document" forKey:kCMISPropertyObjectTypeId];
    [properties setObject:[dateFormatter stringFromDate:testDate] forKey:kCMISPropertyCreationDate];
    [properties setObject:[NSNumber numberWithBool:NO] forKey:kCMISPropertyIsLatestVersion];
    [properties setObject:[NSNumber numberWithInt:4] forKey:kCMISPropertyContentStreamLength];

    convertedProperties = [converter convertProperties:properties forObjectTypeId:@"cmis:document" error:&error];
    STAssertNil(error, @"Error while converting properties: %@", [error description]);
    STAssertNotNil(convertedProperties, @"Conversion failed, nil was returned");
    STAssertTrue(convertedProperties.propertyList.count == 5, @"Expected 5 converted properties, but was %d", convertedProperties.propertyList.count);
    STAssertEqualObjects(@"test", [[convertedProperties propertyForId:kCMISPropertyName] propertyStringValue], @"Converted property value did not match");
    STAssertEqualObjects(@"cmis:document", [[convertedProperties propertyForId:kCMISPropertyObjectTypeId] propertyIdValue], @"Converted property value did not match");

    // NSDate is using sub-second precision ... and the formatter is not.
    // ... sigh ... hence we test if the dates are 'relatively' (ie 1 second) close
    NSDate *convertedDate = [[convertedProperties propertyForId:kCMISPropertyCreationDate] propertyDateTimeValue];
    STAssertTrue(testDate.timeIntervalSince1970 - 1000 <= convertedDate.timeIntervalSince1970
            && convertedDate.timeIntervalSince1970 <= testDate.timeIntervalSince1970 + 1000, @"Converted property value did not match");
    STAssertEqualObjects([NSNumber numberWithBool:NO], [[convertedProperties propertyForId:kCMISPropertyIsLatestVersion] propertyBooleanValue], @"Converted property value did not match");
    STAssertEqualObjects([NSNumber numberWithInteger:4], [[convertedProperties propertyForId:kCMISPropertyContentStreamLength] propertyIntegerValue], @"Converted property value did not match");

    // Test error return
    STAssertNil([converter convertProperties:nil forObjectTypeId:@"doesntmatter" error:nil], @"Should be nil");

    error = nil;
    properties = [[NSMutableDictionary alloc] init];
    [properties setObject:@"test" forKey:kCMISPropertyContentStreamLength];
    convertedProperties = [converter convertProperties:properties forObjectTypeId:@"cmis:document" error:&error];
    STAssertNotNil(error, @"Expecting an error when converting");
    STAssertNil(convertedProperties, @"When conversion goes wrong, should return nil");

    error = nil;
    properties = [[NSMutableDictionary alloc] init];
    [properties setObject:[NSNumber numberWithBool:YES] forKey:kCMISPropertyName];
    convertedProperties = [converter convertProperties:properties forObjectTypeId:@"cmis:document" error:&error];
    STAssertNotNil(error, @"Expecting an error when converting");
    STAssertNil(convertedProperties, @"When conversion goes wrong, should return nil");
}

- (void)testOperationContextForRetrievingObject
{
    [self setupCmisSession];
    NSError *error = nil;

    // Create some test document
    CMISDocument *testDocument = [self uploadTestFile];

    // Use YES for retrieving the allowable actions
    CMISOperationContext *ctx = [[CMISOperationContext alloc] init];
    ctx.isIncludeAllowableActions = YES;
    CMISDocument *document = (CMISDocument *) [self.session retrieveObject:testDocument.identifier withOperationContext:ctx error:&error];
    STAssertNil(error, @"Got error while retrieving object : %@", [error description]);
    STAssertNotNil(document.allowableActions, @"Allowable actions should not be nil");
    STAssertTrue(document.allowableActions.allowableActionsSet.count > 0, @"Expected at least one allowable action");

    //Use NO for allowable actions
    ctx = [[CMISOperationContext alloc] init];
    ctx.isIncludeAllowableActions = NO;
    document = (CMISDocument *) [self.session retrieveObject:testDocument.identifier withOperationContext:ctx error:&error];
    STAssertNil(error, @"Got error while retrieving object : %@", [error description]);
    STAssertNil(document.allowableActions, @"Allowable actions should be nil");
    STAssertTrue(document.allowableActions.allowableActionsSet.count == 0, @"Expected zero allowable actions");

    // Cleanup
    [self deleteDocumentAndVerify:testDocument];
}

#pragma mark Helper Methods

- (void)setupCmisSession
{
    self.session = [[CMISSession alloc] initWithSessionParameters:self.parameters];
    STAssertNotNil(self.session, @"Session should not be nil");
    STAssertFalse(self.session.isAuthenticated, @"Session should not yet be authenticated");

    NSError *error = nil;
    [self.session authenticateAndReturnError:&error];
    STAssertTrue(self.session.isAuthenticated, @"Session should be authenticated");

    self.rootFolder = [self.session rootFolder];
    STAssertNotNil(self.rootFolder, @"rootFolder object should not be nil");
}

- (CMISDocument *)retrieveVersionedTestDocument
{
    [self setupCmisSession];
    NSError *error = nil;
    CMISDocument *document = (CMISDocument *) [self.session retrieveObjectByPath:@"/versioned-quote.txt" error:&error];
    STAssertNotNil(document, @"Did not find test document for versioning test");
    STAssertTrue(document.isLatestVersion, @"Should have 'true' for the property 'isLatestVersion");
    STAssertFalse(document.isLatestMajorVersion, @"Should have 'false' for the property 'isLatestMajorVersion"); // the latest version is a minor one
    STAssertFalse(document.isMajorVersion, @"Should have 'false' for the property 'isMajorVersion");

    return document;
}

- (CMISDocument *)uploadTestFile
{
    // Set properties on test file
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_file.txt" ofType:nil];
    NSString *documentName = [NSString stringWithFormat:@"test_file_%@.txt", [self stringFromCurrentDate]];
    NSMutableDictionary *documentProperties = [NSMutableDictionary dictionary];
    [documentProperties setObject:documentName forKey:kCMISPropertyName];
    [documentProperties setObject:kCMISPropertyObjectTypeIdValueDocument forKey:kCMISPropertyObjectTypeId];

    // Upload test file
    NSError *error = nil;
    NSString *objectId = [self.rootFolder createDocumentFromFilePath:filePath withMimeType:@"text/plain"
                                                      withProperties:documentProperties error:&error];
    CMISDocument *document = (CMISDocument *) [self.session retrieveObject:objectId error:&error];
    STAssertNil(error, @"Got error while creating document: %@", [error description]);
    STAssertNotNil(objectId, @"Object id received should be non-nil");
    STAssertNotNil(document, @"Retrieved document should not be nil");

    return document;
}

- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs
{
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    do
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if ([timeoutDate timeIntervalSinceNow] < 0.0)
            break;
    } while (!self.callbackCompleted);

    return self.callbackCompleted;
}

- (void)deleteDocumentAndVerify:(CMISDocument *)document
{
    NSError *error = nil;
    BOOL documentDeleted = [document deleteAllVersionsAndReturnError:&error];
    STAssertNil(error, @"Error while deleting created document: %@", [error description]);
    STAssertTrue(documentDeleted, @"Document was not deleted");
}

- (NSDateFormatter *)testDateFormatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd'T'HH-mm-ss-Z'"];
    return formatter;
}

- (NSString *)stringFromCurrentDate
{
    return [[self testDateFormatter] stringFromDate:[NSDate date]];
}

@end
