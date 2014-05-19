/*
 ******************************************************************************
 * Copyright (C) 2005-2014 Alfresco Software Limited.
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
 *****************************************************************************
 */

#import "AlfrescoReachability.h"
#import <netinet/in.h>
#import "AlfrescoLog.h"

@import SystemConfiguration;

static AlfrescoReachability * internetReachability = NULL;

@interface AlfrescoReachability ()

@property (nonatomic, assign) SCNetworkReachabilityRef internetReachabilityRef;

@end

@implementation AlfrescoReachability

+ (instancetype)internetReachability
{
    if (internetReachability == NULL)
    {
        struct sockaddr_in zeroAddress;
        bzero(&zeroAddress, sizeof(zeroAddress));
        zeroAddress.sin_len = sizeof(zeroAddress);
        zeroAddress.sin_family = AF_INET;
        internetReachability = [self reachabilityWithAddress:&zeroAddress];
        SCNetworkReachabilityFlags currentFlags = 0;
        if (SCNetworkReachabilityGetFlags(internetReachability->_internetReachabilityRef, &currentFlags))
        {
            handleFlags(currentFlags);
        }
    }
    return internetReachability;
}

- (void)dealloc
{
    [self stopNotifier];
    if (self.internetReachabilityRef != NULL)
    {
        CFRelease(self.internetReachabilityRef);
    }
}

#pragma mark - Private Functions

static void ReachabilityChangedCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void * info)
{
    handleFlags(flags);
}

void handleFlags(SCNetworkReachabilityFlags flags)
{
    // At the moment we only care if we have internet access
#if TARGET_OS_IPHONE
    BOOL reachable = (flags & kSCNetworkReachabilityFlagsReachable) || (flags & kSCNetworkReachabilityFlagsIsWWAN);
#elif TARGET_OS_MAC
    BOOL reachable = (flags & kSCNetworkReachabilityFlagsReachable);
#endif
    
    BOOL connected = !(flags & kSCNetworkReachabilityFlagsConnectionRequired);
    
    if (reachable && connected)
    {
        internetReachability->_internetConnection = YES;
    }
    else
    {
        internetReachability->_internetConnection = NO;
    }
    
    if ([AlfrescoLog sharedInstance].logLevel == AlfrescoLogLevelDebug)
    {
        AlfrescoLogDebug(@"Internet reachable: %@", (reachable && connected) ? @"YES" : @"NO");
    }
}

+ (instancetype)reachabilityWithAddress:(const struct sockaddr_in *)hostAddress;
{
    AlfrescoReachability *returnReachability = NULL;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)hostAddress);
    
    if (reachability != NULL)
    {
        returnReachability = [[self alloc] init];
        if (returnReachability != NULL)
        {
            returnReachability.internetReachabilityRef = reachability;
            [returnReachability startNotifier];
        }
    }
    
    return returnReachability;
}

- (BOOL)startNotifier
{
    BOOL started = NO;
    
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    if (SCNetworkReachabilitySetCallback(self.internetReachabilityRef, ReachabilityChangedCallback, &context))
    {
        if (SCNetworkReachabilityScheduleWithRunLoop(self.internetReachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
        {
            started = YES;
        }
    }
    
    return started;
}

- (BOOL)stopNotifier
{
    BOOL stopped = NO;
    
    if (self.internetReachabilityRef != NULL)
    {
        SCNetworkReachabilityUnscheduleFromRunLoop(self.internetReachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
    
    return stopped;
}

@end
