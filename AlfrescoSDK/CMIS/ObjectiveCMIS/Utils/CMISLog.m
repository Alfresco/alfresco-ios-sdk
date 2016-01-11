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

#import "CMISLog.h"

@implementation CMISLog

#pragma mark - Lifecycle methods

+ (CMISLog *)sharedInstance
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
    return [self initWithLogLevel:CMIS_LOG_LEVEL];
}

- (id)initWithLogLevel:(CMISLogLevel)logLevel
{
    self = [super init];
    if (self)
    {
        _logLevel = logLevel;
    }
    return self;
}

#pragma mark - Info methods

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ Log level: %@", [super description], [self stringForLogLevel:self.logLevel]];
}

- (NSString *)stringForLogLevel:(CMISLogLevel)logLevel
{
    NSString *result = nil;
    
    switch(logLevel)
    {
        case CMISLogLevelOff:
            result = @"OFF";
            break;
        case CMISLogLevelError:
            result = @"ERROR";
            break;
        case CMISLogLevelWarning:
            result = @"WARN";
            break;
        case CMISLogLevelInfo:
            result = @"INFO";
            break;
        case CMISLogLevelDebug:
            result = @"DEBUG";
            break;
        case CMISLogLevelTrace:
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
    if (self.logLevel != CMISLogLevelOff)
    {
        NSString *message = [NSString stringWithFormat:@"[%ld] %@", (long)error.code, error.localizedDescription];
        [self logMessage:message forLogLevel:CMISLogLevelError];
    }
}

- (void)logError:(NSString *)format, ...
{
    if (self.logLevel != CMISLogLevelOff)
    {
        // Build log message string from variable args list
        va_list args;
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        [self logMessage:message forLogLevel:CMISLogLevelError];
    }
}

- (void)logWarning:(NSString *)format, ...
{
    if (self.logLevel >= CMISLogLevelWarning)
    {
        // Build log message string from variable args list
        va_list args;
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        [self logMessage:message forLogLevel:CMISLogLevelWarning];
    }
}

- (void)logInfo:(NSString *)format, ...
{
    if (self.logLevel >= CMISLogLevelInfo)
    {
        // Build log message string from variable args list
        va_list args;
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        [self logMessage:message forLogLevel:CMISLogLevelInfo];
    }
}

- (void)logDebug:(NSString *)format, ...
{
    if (self.logLevel >= CMISLogLevelDebug)
    {
        // Build log message string from variable args list
        va_list args;
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        [self logMessage:message forLogLevel:CMISLogLevelDebug];
    }
}

- (void)logTrace:(NSString *)format, ...
{
    if (self.logLevel == CMISLogLevelTrace)
    {
        // Build log message string from variable args list
        va_list args;
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        [self logMessage:message forLogLevel:CMISLogLevelTrace];
    }
}

#pragma mark - Helper methods

- (void)logMessage:(NSString *)message forLogLevel:(CMISLogLevel)logLevel
{
    NSString *callingMethod = [self methodNameFromCallStack:[[NSThread callStackSymbols] objectAtIndex:2]];
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

@end
