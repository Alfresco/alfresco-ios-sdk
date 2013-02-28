/*******************************************************************************
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


@end
