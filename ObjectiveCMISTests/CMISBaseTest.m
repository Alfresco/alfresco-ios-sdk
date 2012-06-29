/*
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
 */
#import "CMISBaseTest.h"
#import "CMISFolder.h"
#import "CMISSession.h"
#import "CMISConstants.h"


@implementation CMISBaseTest

@synthesize parameters = _parameters;
@synthesize session = _session;
@synthesize rootFolder = _rootFolder;
@synthesize callbackCompleted = _callbackCompleted;


- (void) runTest:(CMISTestBlock)testBlock
{
    [self runTest:testBlock withExtraSessionParameters:nil];
}

- (void) runTest:(CMISTestBlock)testBlock withExtraSessionParameters:(NSDictionary *)extraSessionParameters
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    STAssertNotNil(bundle, @"Bundle is nil!");

    NSString *envsPListPath = [bundle pathForResource:@"env-cfg" ofType:@"plist"];
    STAssertNotNil(envsPListPath, @"envsPListPath is nil!");

    NSDictionary *environmentsDict = [[NSDictionary alloc] initWithContentsOfFile:envsPListPath];
    STAssertNotNil(environmentsDict, @"environmentsDict is nil!");

    NSArray *environmentArray = [environmentsDict objectForKey:@"environments"];
    STAssertNotNil(environmentArray, @"environmentArray is nil!");

    for (NSDictionary *envDict in environmentArray)
    {
        NSString *url = [envDict valueForKey:@"url"];
        NSString *repositoryId = [envDict valueForKey:@"repositoryId"];
        NSString *username = [envDict valueForKey:@"username"];
        NSString *password = [envDict valueForKey:@"password"];

        self.callbackCompleted = NO;
        [self setupCmisSession:url repositoryId:repositoryId username:username password:password extraSessionParameters:extraSessionParameters];
        self.callbackCompleted = NO;

        log(@">------------------- Running test against %@ -------------------<", url);

        testBlock();
    }
}

- (void)setupCmisSession:(NSString *)url repositoryId:(NSString *)repositoryId username:(NSString *)username
                  password:(NSString *)password extraSessionParameters:(NSDictionary *)extraSessionParameters
{
    self.parameters = [[CMISSessionParameters alloc] initWithBindingType:CMISBindingTypeAtomPub];
    self.parameters.username = username;
    self.parameters.password = password;
    self.parameters.atomPubUrl = [NSURL URLWithString:url];
    self.parameters.repositoryId = repositoryId;

    if (extraSessionParameters != nil)
    {
        for (id extraSessionParamKey in extraSessionParameters)
        {
            [self.parameters setObject:[extraSessionParameters objectForKey:extraSessionParamKey] forKey:extraSessionParamKey];
        }
    }

    self.session = [[CMISSession alloc] initWithSessionParameters:self.parameters];
    STAssertNotNil(self.session, @"Session should not be nil");
    STAssertFalse(self.session.isAuthenticated, @"Session should not yet be authenticated");

    NSError *error = nil;
    [self.session authenticateAndReturnError:&error];
    STAssertTrue(self.session.isAuthenticated, @"Session should be authenticated");

    self.rootFolder = [self.session retrieveRootFolderAndReturnError:&error];
    STAssertNil(error, @"Error while retrieving root folder: %@", [error description]);
    STAssertNotNil(self.rootFolder, @"rootFolder object should not be nil");
}

#pragma mark Helper Methods

- (CMISDocument *)retrieveVersionedTestDocument
{
    NSError *error = nil;
    CMISDocument *document = (CMISDocument *) [self.session retrieveObjectByPath:@"/ios-test/versioned-quote.txt" error:&error];
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
    __block NSInteger previousUploadedBytes = -1;
    __block NSString *objectId = nil;
    [self.rootFolder createDocumentFromFilePath:filePath
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

- (void)waitForCompletion:(NSTimeInterval)timeoutSecs
{
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    do
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if ([timeoutDate timeIntervalSinceNow] < 0.0)
            break;
    } while (!self.callbackCompleted);

    self.callbackCompleted = NO;
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