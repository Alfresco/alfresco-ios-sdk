//
//  ObjectiveCMISTests+Environment.m
//  ObjectiveCMIS
//
//  Created by Gi Lee on 5/10/12.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "ObjectiveCMISTests+Environment.h"

NSString * const kCMISTestUsernameKey = @"ObjectiveCMISTestUsername";
NSString * const kCMISTestPasswordKey = @"ObjectiveCMISTestPassword";
NSString * const kCMISTestAtomPubUrlKey = @"ObjectiveCMISTestAtomPubUrl";
NSString * const kCMISTestRepoIdKey = @"ObjectiveCMISTestRepoId";

@implementation ObjectiveCMISTests (Environment)

- (NSString *)environmentStringForKey:(NSString *)envKey defaultValue:(NSString *)defaultValue
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *envValue = [bundle objectForInfoDictionaryKey:envKey];
    if ((nil == envValue) || ([envValue length] == 0))
    {
        return defaultValue;
    }
    return envValue;
}


@end
