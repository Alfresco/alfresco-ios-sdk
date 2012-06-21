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



@implementation CMISBaseTest

@synthesize parameters = _parameters;
@synthesize session = _session;
@synthesize rootFolder = _rootFolder;
@synthesize callbackCompleted = _callbackCompleted;


- (void) runTest:(CMISTestBlock)testBlock
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
        [self setupCmisSession:url repositoryId:repositoryId username:username password:password];
        self.callbackCompleted = NO;

        log(@"Running test against %@", url);
        testBlock();
    }
}

- (void)setupCmisSession:(NSString *)url repositoryId:(NSString *)repositoryId username:(NSString *)username password:(NSString *)password
{
    self.parameters = [[CMISSessionParameters alloc] initWithBindingType:CMISBindingTypeAtomPub];
    self.parameters.username = username;
    self.parameters.password = password;
    self.parameters.atomPubUrl = [NSURL URLWithString:url];
    self.parameters.repositoryId = repositoryId;

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

@end