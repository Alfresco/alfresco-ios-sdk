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

#import "ObjectiveCMISTests.h"

/*
 To take advantage of your environment values for test, set the environment.plist keys shown below in your environment.plist file, which can be located at the given path:
 
    ~/.MacOSX/environment.plist
 
 If it does not exist, create one.  For the environment values to take, you will then need to log out and log back in (also applies if you update).
 
 ObjectiveCMISTestUsername ->   environment.plist Key: OBJECTIVE_CMIS_TEST_USERNAME
 ObjectiveCMISTestPassword ->   environment.plist Key: OBJECTIVE_CMIS_TEST_PASSWORD
 ObjectiveCMISTestAtomPubUrl -> environment.plist Key: OBJECTIVE_CMIS_TEST_ATOMPUB_URL
 ObjectiveCMISTestRepoId  ->    environment.plist Key: OBJECTIVE_CMIS_TEST_REPOID
 
 The keys on the left can be found in the ObjectiveCMISTests-Info.plist.
 */

extern NSString * const kCMISTestUsernameKey;
extern NSString * const kCMISTestPasswordKey;
extern NSString * const kCMISTestAtomPubUrlKey;
extern NSString * const kCMISTestRepoIdKey;


@interface ObjectiveCMISTests (Environment)

// Fetches and provides the environemnt value for the key provided.  If no value is found, the default value is returned.
- (NSString *)environmentStringForKey:(NSString *)envKey defaultValue:(NSString *)defaultValue;

@end
