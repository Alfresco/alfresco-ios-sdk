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

#import "AlfrescoLog.h"
#import "CMISLog.h"
#import <asl.h>

@interface AlfrescoLog ()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation AlfrescoLog

#pragma mark - Lifecycle methods

+ (AlfrescoLog *)sharedInstance
{
    static dispatch_once_t predicate = 0;
    __strong static id sharedObject = nil;
    dispatch_once(&predicate, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _logLevel = ALFRESCO_LOG_LEVEL;
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    }
    return self;
}

- (void)setLogLevel:(AlfrescoLogLevel)logLevel
{
    _logLevel = logLevel;
    
    // we also need to ensure the CMISLog is kept in sync
    switch (_logLevel)
    {
        case AlfrescoLogLevelOff:
            [CMISLog sharedInstance].logLevel = CMISLogLevelOff;
            break;
            
        case AlfrescoLogLevelError:
            [CMISLog sharedInstance].logLevel = CMISLogLevelError;
            break;
            
        case AlfrescoLogLevelWarning:
            [CMISLog sharedInstance].logLevel = CMISLogLevelWarning;
            break;
            
        case AlfrescoLogLevelInfo:
            [CMISLog sharedInstance].logLevel = CMISLogLevelInfo;
            break;
            
        case AlfrescoLogLevelDebug:
            [CMISLog sharedInstance].logLevel = CMISLogLevelDebug;
            break;
            
        case AlfrescoLogLevelTrace:
            [CMISLog sharedInstance].logLevel = CMISLogLevelTrace;
            break;
            
        default:
            [CMISLog sharedInstance].logLevel = CMISLogLevelInfo;
            break;
    }
}

#pragma mark - Info methods

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ Log level: %@", [super description], [self stringForLogLevel:self.logLevel]];
}

- (NSString *)stringForLogLevel:(AlfrescoLogLevel)logLevel
{
    NSString *result = nil;
    
    switch(logLevel)
    {
        case AlfrescoLogLevelOff:
            result = @"OFF";
            break;
        case AlfrescoLogLevelError:
            result = @"ERROR";
            break;
        case AlfrescoLogLevelWarning:
            result = @"WARN";
            break;
        case AlfrescoLogLevelInfo:
            result = @"INFO";
            break;
        case AlfrescoLogLevelDebug:
            result = @"DEBUG";
            break;
        case AlfrescoLogLevelTrace:
            result = @"TRACE";
            break;
        default:
            result = @"UNKNOWN";
    }
    
    return result;
}

#pragma mark - Logging methods

- (void)logErrorFromError:(NSError *)error
{
    if (self.logLevel != AlfrescoLogLevelOff)
    {
        NSString *message = [NSString stringWithFormat:@"[%ld] %@", (long)error.code, error.localizedDescription];
        [self logMessage:message forLogLevel:AlfrescoLogLevelError];
    }
}

- (void)logError:(NSString *)format, ...
{
    if (self.logLevel != AlfrescoLogLevelOff)
    {
        // Build log message string from variable args list
        va_list args;
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        [self logMessage:message forLogLevel:AlfrescoLogLevelError];
    }
}

- (void)logWarning:(NSString *)format, ...
{
    if (self.logLevel >= AlfrescoLogLevelWarning)
    {
        // Build log message string from variable args list
        va_list args;
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        [self logMessage:message forLogLevel:AlfrescoLogLevelWarning];
    }
}

- (void)logInfo:(NSString *)format, ...
{
    if (self.logLevel >= AlfrescoLogLevelInfo)
    {
        // Build log message string from variable args list
        va_list args;
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        [self logMessage:message forLogLevel:AlfrescoLogLevelInfo];
    }
}

- (void)logDebug:(NSString *)format, ...
{
    if (self.logLevel >= AlfrescoLogLevelDebug)
    {
        // Build log message string from variable args list
        va_list args;
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        [self logMessage:message forLogLevel:AlfrescoLogLevelDebug];
    }
}

- (void)logTrace:(NSString *)format, ...
{
    if (self.logLevel == AlfrescoLogLevelTrace)
    {
        // Build log message string from variable args list
        va_list args;
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        [self logMessage:message forLogLevel:AlfrescoLogLevelTrace];
    }
}

- (NSArray *)retrieveLogEntriesForApp:(NSString *)appName numberOfEntries:(int)entries
{
    // setup a query message
    aslmsg q = asl_new(ASL_TYPE_QUERY);
    
    // limit search to application, if provided
    if (appName)
    {
        const char *sender = [appName UTF8String];
        asl_set_query(q, ASL_KEY_SENDER, sender, ASL_QUERY_OP_EQUAL);
    }
    
    aslmsg m;
    const char *msg, *time, *pid, *sender, *thread;
    
    // NOTE: There's no way to order results so we have to get everything
    //       and then just return what was requested (as the most recent log
    //       entries are at the end!)
    
    // perform search
    NSMutableArray *allEntries = [NSMutableArray array];
    aslresponse r = asl_search(NULL, q);
    while (NULL != (m = asl_next(r)))
    {
        // get the message
        msg = asl_get(m, ASL_KEY_MSG);
        
        // if there's no message skip this entry
        if (msg)
        {
            NSString *entryTime;
            
            // try and get "CFLog Local Time" key first as it is more accurate
            time = asl_get(m, [@"CFLog Local Time" UTF8String]);
            if (time)
            {
                entryTime = [NSString stringWithUTF8String:time];
            }
            else
            {
                // retrieve the Time key representing time interval and format it
                time = asl_get(m, ASL_KEY_TIME);
                NSString *timeString = [NSString stringWithUTF8String:time];
                NSTimeInterval timeInterval = [timeString doubleValue];
                NSDate *time = [NSDate dateWithTimeIntervalSince1970:timeInterval];
                entryTime = [self.dateFormatter stringFromDate:time];
            }
            
            // always start with the time
            NSMutableString *entryString = [NSMutableString stringWithFormat:@"%@ ", entryTime];
            
            // add the sender, if present
            sender = asl_get(m, ASL_KEY_SENDER);
            if (sender)
            {
                [entryString appendString:[NSString stringWithUTF8String:sender]];
            }
            
            [entryString appendString:@"["];
            
            // add the process id, if present
            pid = asl_get(m, ASL_KEY_PID);
            if (pid)
            {
                [entryString appendString:[NSString stringWithUTF8String:pid]];
            }
            
            // add the thread, if present
            thread = asl_get(m, [@"CFLog Thread" UTF8String]);
            if (thread)
            {
                [entryString appendFormat:@":%@", [NSString stringWithUTF8String:thread]];
            }
            
            // add the message
            [entryString appendFormat:@"] %@", [NSString stringWithUTF8String:msg]];
            
            [allEntries addObject:entryString];
        }
    }
    
    // release response and query message
    asl_release(r);
    asl_release(q);
    
    NSArray *requestedEntries = allEntries;
    
    // extract requested entries if appropriate
    if (entries > 0 && allEntries.count > entries)
    {
        NSRange range;
        range.location = allEntries.count - entries;
        range.length = entries;
        requestedEntries = [allEntries subarrayWithRange:range];
    }
    
    return requestedEntries;
}

#pragma mark - Helper methods

- (void)logMessage:(NSString *)message forLogLevel:(AlfrescoLogLevel)logLevel
{
    NSString *callingMethod = [self methodNameFromCallStack:[NSThread callStackSymbols][2]];
    NSLog(@"%@ %@ %@", [self stringForLogLevel:logLevel], callingMethod, message);
}

- (NSString *)methodNameFromCallStack:(NSString *)topOfStack
{
    NSString *methodName = nil;
    
    if (topOfStack != nil)
    {
        NSRange startBracketRange = [topOfStack rangeOfString:@"[" options:NSBackwardsSearch];
        if (NSNotFound != startBracketRange.location)
        {
            NSString *start = [topOfStack substringFromIndex:startBracketRange.location];
            NSRange endBracketRange = [start rangeOfString:@"]" options:NSBackwardsSearch];
            if (NSNotFound != endBracketRange.location)
            {
                methodName = [start substringToIndex:endBracketRange.location + 1];
            }
        }
    }
    
    return methodName;
}

#pragma mark - Logging class methods

+ (void)logError:(NSString *)message
{
    AlfrescoLogError(message);
}

+ (void)logWarning:(NSString *)message
{
    AlfrescoLogWarning(message);
}

+ (void)logInfo:(NSString *)message
{
    AlfrescoLogInfo(message);
}

+ (void)logDebug:(NSString *)message
{
    AlfrescoLogDebug(message);
}

+ (void)logTrace:(NSString *)message
{
    AlfrescoLogTrace(message);
}

@end
