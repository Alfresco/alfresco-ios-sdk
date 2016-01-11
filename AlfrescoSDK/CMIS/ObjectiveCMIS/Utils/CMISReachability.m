/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "CMISReachability.h"
#import <netinet/in.h>
#import "CMISLog.h"

@import SystemConfiguration;

static CMISReachability *networkReachability = NULL;

@interface CMISReachability ()

@property (nonatomic, assign) SCNetworkReachabilityRef networkReachabilityRef;

@end

@implementation CMISReachability

+ (instancetype)networkReachability
{
    if (networkReachability == NULL) {
        struct sockaddr_in zeroAddress;
        bzero(&zeroAddress, sizeof(zeroAddress));
        zeroAddress.sin_len = sizeof(zeroAddress);
        zeroAddress.sin_family = AF_INET;
        networkReachability = [self reachabilityWithAddress:&zeroAddress];
        SCNetworkReachabilityFlags currentFlags = 0;
        if (SCNetworkReachabilityGetFlags(networkReachability->_networkReachabilityRef, &currentFlags)) {
            handleFlags(currentFlags);
        }
    }
    return networkReachability;
}

- (void)dealloc
{
    [self stopNotifier];
    if (self.networkReachabilityRef != NULL) {
        CFRelease(self.networkReachabilityRef);
    }
}

#pragma mark - Private Functions

static void ReachabilityChangedCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void * info)
{
    handleFlags(flags);
}

void handleFlags(SCNetworkReachabilityFlags flags)
{
    // At the moment we only care if we have network access
#if TARGET_OS_IPHONE
    BOOL reachable = (flags & kSCNetworkReachabilityFlagsReachable) || (flags & kSCNetworkReachabilityFlagsIsWWAN);
#elif TARGET_OS_MAC
    BOOL reachable = (flags & kSCNetworkReachabilityFlagsReachable);
#endif
    
    BOOL connected = !(flags & kSCNetworkReachabilityFlagsConnectionRequired);
    
    if (reachable && connected) {
        networkReachability->_networkConnection = YES;
    }
    else {
        networkReachability->_networkConnection = NO;
    }
    
    if ([CMISLog sharedInstance].logLevel == CMISLogLevelDebug) {
        CMISLogDebug(@"Network reachable: %@", (reachable && connected) ? @"YES" : @"NO");
    }
}

+ (instancetype)reachabilityWithAddress:(const struct sockaddr_in *)hostAddress;
{
    CMISReachability *returnReachability = NULL;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)hostAddress);
    
    if (reachability != NULL) {
        returnReachability = [[self alloc] init];
        if (returnReachability != NULL) {
            returnReachability.networkReachabilityRef = reachability;
            [returnReachability startNotifier];
        }
    }
    else {
        CMISLogWarning(@"Failed to create reachability reference for address %@", hostAddress);
    }
    
    return returnReachability;
}

- (BOOL)startNotifier
{
    BOOL started = NO;
    
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    if (SCNetworkReachabilitySetCallback(self.networkReachabilityRef, ReachabilityChangedCallback, &context)) {
        if (SCNetworkReachabilityScheduleWithRunLoop(self.networkReachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
            started = YES;
        }
        else {
            CMISLogWarning(@"Failed to schedule network reachability with run loop");
        }
    }
    else {
        CMISLogWarning(@"Failed to set network reachability callback");
    }
    
    return started;
}

- (BOOL)stopNotifier
{
    BOOL stopped = NO;
    
    if (self.networkReachabilityRef != NULL) {
        if (SCNetworkReachabilityUnscheduleFromRunLoop(self.networkReachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
            stopped = YES;
        }
        else {
            CMISLogWarning(@"Failed to unschedule network reachability from run loop");
        }
    }
    
    return stopped;
}

@end
