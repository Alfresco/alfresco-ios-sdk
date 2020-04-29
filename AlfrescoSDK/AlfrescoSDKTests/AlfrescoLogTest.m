/*******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
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
 ******************************************************************************/

#import "AlfrescoLogTest.h"
#import "AlfrescoLog.h"

@implementation AlfrescoLogTest

- (void)setUp
{
    self.initialLogLevel = [AlfrescoLog sharedInstance].logLevel;
}

- (void)tearDown
{
    [AlfrescoLog sharedInstance].logLevel = self.initialLogLevel;
}

- (void)testLevels
{
    AlfrescoLog *logger = [AlfrescoLog sharedInstance];
    
    // set level to off, message should not appear
    logger.logLevel = AlfrescoLogLevelOff;
    [logger logTrace:@"** FAIL ** This message should not appear **"];
    
    // set level to error, message should not appear
    logger.logLevel = AlfrescoLogLevelError;
    [logger logTrace:@"** FAIL ** This message should not appear **"];
    
    // set level to warning, message should not appear
    logger.logLevel = AlfrescoLogLevelWarning;
    [logger logTrace:@"** FAIL ** This message should not appear **"];
    
    // set level to info, message should not appear
    logger.logLevel = AlfrescoLogLevelInfo;
    [logger logTrace:@"** FAIL ** This message should not appear **"];
    
    // set level to debug, message should not appear
    logger.logLevel = AlfrescoLogLevelDebug;
    [logger logTrace:@"** FAIL ** This message should not appear **"];
    
    // set level to trace, message should appear
    logger.logLevel = AlfrescoLogLevelTrace;
    [logger logTrace:@"This is a TRACE level message so should appear"];
}

- (void)testMacros
{
    // set level to Trace so all messages appear
    [AlfrescoLog sharedInstance].logLevel = AlfrescoLogLevelTrace;
    
    AlfrescoLogError(@"This is an ERROR message");
    AlfrescoLogWarning(@"This is a WARNING message");
    AlfrescoLogInfo(@"This is an INFO message");
    AlfrescoLogDebug(@"This is a DEBUG message");
    AlfrescoLogTrace(@"This is a TRACE message");
}

- (void)testFormatStrings
{
    // set level to Trace so all messages appear
    AlfrescoLog *logger = [AlfrescoLog sharedInstance];
    logger.logLevel = AlfrescoLogLevelTrace;
    
    NSString *str = @"A string";
    
    AlfrescoLogError(@"ERROR message with parameter: %@", str);
    AlfrescoLogWarning(@"WARNING message with parameter: %@", str);
    AlfrescoLogInfo(@"INFO message with parameter: %@", str);
    AlfrescoLogDebug(@"DEBUG message with parameter: %@", str);
    AlfrescoLogTrace(@"TRACE message with parameter: %@", str);
    
    [logger logError:@"ERROR message with parameter: %@", str];
    [logger logWarning:@"WARNING message with parameter: %@", str];
    [logger logInfo:@"INFO message with parameter: %@", str];
    [logger logDebug:@"DEBUG message with parameter: %@", str];
    [logger logTrace:@"DEBUG message with parameter: %@", str];
}

- (void)testErrors
{
    AlfrescoLog *logger = [AlfrescoLog sharedInstance];
    
    // create an NSError object
    NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
    [errorInfo setValue:@"Error description" forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:@"AlfrescoSDK" code:1 userInfo:errorInfo];
    
    [logger logErrorFromError:error];
}

- (void)testLogEntries
{
    // make sure there are some log entries
    AlfrescoLogInfo(@"First log message");
    AlfrescoLogInfo(@"Second log message");
    AlfrescoLogInfo(@"Third log message");
    AlfrescoLogInfo(@"Fourth log message");
    AlfrescoLogInfo(@"Fifth log message");
 
    AlfrescoLog *logger = [AlfrescoLog sharedInstance];
    
    // request the 5 entries just added
    NSArray *entries = [logger retrieveLogEntriesForApp:@"xctest" numberOfEntries:5];
    XCTAssertTrue(entries.count == 5,
                  @"5 entries test: Expected there to be 5 log entries but there were %lu", (unsigned long)entries.count);
    
    // check all messages contains "xctest", "INFO [AlfrescoLogTest testLogEntries]" and today's date
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *nowString = [dateFormatter stringFromDate:now];
    for (NSString *entry in entries)
    {
        NSLog(@"entry: %@", entry);
        
        if ([entry rangeOfString:@"xctest"].location == NSNotFound)
        {
            XCTFail(@"5 entries test: All entries should contain the app name requested, but entry was: %@", entry);
            break;
        }
        
        if ([entry rangeOfString:@"INFO [AlfrescoLogTest testLogEntries]"].location == NSNotFound)
        {
            XCTFail(@"5 entries test: All entries should contain the log level and method name, but entry was: %@", entry);
            break;
        }
        
        if (![entry hasPrefix:nowString])
        {
            XCTFail(@"5 entries test: All entries should start with the date and time, but entry was: %@", entry);
            break;
        }
    }
    
    // check the first and last object contain the strings above
    NSString *firstEntry = entries.firstObject;
    if ([firstEntry rangeOfString:@"First log message"].location == NSNotFound)
    {
        XCTFail(@"5 entries test: First entry should contain 'First log message' but entry was: %@\nEntries array: %@", firstEntry, entries);
    }
    
    NSString *lastEntry = entries.lastObject;
    if ([lastEntry rangeOfString:@"Fifth log message"].location == NSNotFound)
    {
        XCTFail(@"5 entries test: Last entry should contain 'Fifth log message' but entry was: %@\nEntries array: %@", lastEntry, entries);
    }
    
    // get as many entries as possible
    entries = [logger retrieveLogEntriesForApp:@"xctest" numberOfEntries:-1];
    NSLog(@"All entries for xctest test: Found %lu xctest entries", (unsigned long)entries.count);
    
    // check there are more than 5 entries
    XCTAssertTrue(entries.count > 5,
                  @"All entries for xctest test: Expected there to be more than 5 log entries but there were %lu", (unsigned long)entries.count);
    
    // check the last object contains "Fifth log message"
    lastEntry = entries.lastObject;
    if ([lastEntry rangeOfString:@"Fifth log message"].location == NSNotFound)
    {
        XCTFail(@"All entries for xctest test: Last entry should contain 'Fifth log message' but entry was: %@", lastEntry);
    }
    
    // get all possible entries
    entries = [logger retrieveLogEntriesForApp:nil numberOfEntries:-1];
    NSLog(@"All entries test: Found %lu log entries", (unsigned long)entries.count);
    
    // check at least one of the entries does NOT contain "xctest"
    BOOL foundNonAppEntry = NO;
    for (NSString *entry in entries)
    {
        if ([entry rangeOfString:@"xctest"].location == NSNotFound)
        {
            foundNonAppEntry = YES;
            break;
        }
    }
    XCTAssertTrue(foundNonAppEntry, @"All entries test: Expected to find at least one log entry that was not from xctest");
}

@end
