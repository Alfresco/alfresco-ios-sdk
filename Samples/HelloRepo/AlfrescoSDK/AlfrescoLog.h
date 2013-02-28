/*
 ******************************************************************************
 * Copyright (C) 2005-2013 Alfresco Software Limited.
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

/**
 * Convenience macros
 */
#define AlfrescoLogError(...)   [[AlfrescoLog sharedInstance] logError:__VA_ARGS__]
#define AlfrescoLogWarning(...) [[AlfrescoLog sharedInstance] logWarning:__VA_ARGS__]
#define AlfrescoLogInfo(...)    [[AlfrescoLog sharedInstance] logInfo:__VA_ARGS__]
#define AlfrescoLogDebug(...)   [[AlfrescoLog sharedInstance] logDebug:__VA_ARGS__]
#define AlfrescoLogTrace(...)   [[AlfrescoLog sharedInstance] logTrace:__VA_ARGS__]

/**
 * Default logging level
 *
 * The default logging level is Info for release builds and Debug for debug builds.
 * The recommended way to override the default is to #include this header file in your app's .pch file
 * and then redefine the ALFRESCO_LOG_LEVEL macro to suit, e.g.
 *     #undef ALFRESCO_LOG_LEVEL
 *     #define ALFRESCO_LOG_LEVEL AlfrescoLogLevelTrace
 */
#if !defined(ALFRESCO_LOG_LEVEL)
    #if DEBUG
        #define ALFRESCO_LOG_LEVEL AlfrescoLogLevelDebug
    #else
        #define ALFRESCO_LOG_LEVEL AlfrescoLogLevelInfo
    #endif
#endif

#import <Foundation/Foundation.h>


@interface AlfrescoLog : NSObject

typedef NS_ENUM(NSUInteger, AlfrescoLogLevel)
{
    AlfrescoLogLevelOff = 0,
    AlfrescoLogLevelError,
    AlfrescoLogLevelWarning,
    AlfrescoLogLevelInfo,
    AlfrescoLogLevelDebug,
    AlfrescoLogLevelTrace
};

@property (nonatomic, assign) AlfrescoLogLevel logLevel;

/**
 * Returns the shared singleton
 */
+ (AlfrescoLog *)sharedInstance;

/**
 * Designated initializer. Can be used when not instantiating this class in singleton mode.
 */
- (id)initWithLogLevel:(AlfrescoLogLevel)logLevel;

- (NSString *)stringForLogLevel:(AlfrescoLogLevel)logLevel;

- (void)logErrorFromError:(NSError *)error;

- (void)logError:(NSString *)format, ...;

- (void)logWarning:(NSString *)format, ...;

- (void)logInfo:(NSString *)format, ...;

- (void)logDebug:(NSString *)format, ...;

- (void)logTrace:(NSString *)format, ...;


@end
