//
//  ObjectiveCMISTests+Environment.h
//  ObjectiveCMIS
//
//  Created by Gi Lee on 5/10/12.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

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
