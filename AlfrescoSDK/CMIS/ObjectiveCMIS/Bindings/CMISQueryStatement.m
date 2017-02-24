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

#import "CMISQueryStatement.h"

static NSDateFormatter *cmisQueryStatementTimeStampFormatter;

@interface CMISQueryStatement ()

@property (nonatomic, strong) NSString* statement;
@property (nonatomic, strong) NSMutableDictionary *parametersDictionary;

@end

@implementation CMISQueryStatement

- (id)initWithStatement:(NSString*)statement {
    self = [super init];
    if (self) {
        self.statement = statement;
        self.parametersDictionary = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)setTypeAtIndex:(NSUInteger)parameterIndex type:(NSString*)type {
    if (type && type.length > 0) {
        self.parametersDictionary[@(parameterIndex)] = [CMISQueryStatement escapeString:type withSurroundingQuotes:NO];
    }
}

- (void)setPropertyAtIndex:(NSUInteger)parameterIndex property:(NSString*)property {
    if (property && property.length > 0) {
        self.parametersDictionary[@(parameterIndex)] = [CMISQueryStatement escapeString:property withSurroundingQuotes:NO];
    }
}

- (void)setNumberAtIndex:(NSUInteger)parameterIndex number:(NSNumber*)number {
    if (number) {
        self.parametersDictionary[@(parameterIndex)] = number;
    }
}

- (void)setStringAtIndex:(NSUInteger)parameterIndex string:(NSString*)string {
    if (string && string.length > 0) {
        self.parametersDictionary[@(parameterIndex)] = [CMISQueryStatement escapeString:string withSurroundingQuotes:YES];
    }
}

- (void)setStringLikeAtIndex:(NSUInteger)parameterIndex string:(NSString*)string {
    if (string && string.length > 0) {
        self.parametersDictionary[@(parameterIndex)] = [CMISQueryStatement escapeLike:string];
    }
}

- (void)setStringContainsAtIndex:(NSUInteger)parameterIndex string:(NSString*)string {
    if (string && string.length > 0) {
        self.parametersDictionary[@(parameterIndex)] = [CMISQueryStatement escapeContains:string];
    }
}

- (void)setStringArrayAtIndex:(NSUInteger)parameterIndex stringArray:(NSArray*)stringArray {
    NSMutableString *paramStr = [NSMutableString string];
    for (NSString *value in stringArray) {
        if ([value isKindOfClass:NSString.class] && value.length > 0) {
            [paramStr appendFormat:@"%@, ", [CMISQueryStatement escapeString:value withSurroundingQuotes:YES]];
        }
    }
    if (paramStr.length > 2) {
        self.parametersDictionary[@(parameterIndex)] = [paramStr substringToIndex:paramStr.length-2];
    } else {
        self.parametersDictionary[@(parameterIndex)] = [NSString string]; // Empty list
    }
}

- (void)setUrlAtIndex:(NSUInteger)parameterIndex url:(NSURL*)url {
    if (url) {
        NSError *error;
        NSString *urlString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        if (!error && urlString && urlString.length >0) {
            self.parametersDictionary[@(parameterIndex)] = [CMISQueryStatement escapeString:urlString withSurroundingQuotes:YES];
        }
    }
}

- (void)setBooleanAtIndex:(NSUInteger)parameterIndex boolean:(BOOL)boolean {
    self.parametersDictionary[@(parameterIndex)] = boolean ? @"TRUE" : @"FALSE";
}

- (void)setDateTimeAtIndex:(NSUInteger)parameterIndex date:(NSDate*)date {
    if (date) {
        self.parametersDictionary[@(parameterIndex)] = [NSString stringWithFormat:@"TIMESTAMP '%@'", [CMISQueryStatement convert:date]];
    }
}


- (NSString*)queryString {
    BOOL inStr = false;
    NSUInteger parameterIndex = 0;
    
    NSMutableString *retStr = [NSMutableString string];
    
    for (NSUInteger i = 0; i < self.statement.length; i++) {
        unichar c = [self.statement characterAtIndex:i];
        
        if (c == '\'') {
            if (inStr && [retStr characterAtIndex:i - 1] == '\\') {
                inStr = true;
            } else {
                inStr = !inStr;
            }
            [retStr appendString:[NSString stringWithCharacters:&c length:1]];
        } else if (c == '?' && !inStr) {
            parameterIndex++;
            NSObject *parameter = self.parametersDictionary[@(parameterIndex)];
            NSString *paramValue = nil;
            if ([parameter isKindOfClass:NSString.class]) {
                paramValue = (NSString*)parameter;
            } else if ([parameter isKindOfClass:NSNumber.class]) {
                paramValue = [(NSNumber*)parameter stringValue];
            }
            if (paramValue) {
                // Replace placeholder
                [retStr appendString:paramValue];
            }
        } else {
            [retStr appendString:[NSString stringWithCharacters:&c length:1]];
        }
    }
    
    return retStr;
}

#pragma mark - Escaping methods

+ (NSString*)escapeString:(NSString*)string withSurroundingQuotes:(BOOL)quotes {
    NSMutableString *escapedString = [NSMutableString string];
    [escapedString appendString:quotes ? @"'" : @"" ];
    for (NSUInteger i = 0; i < string.length; i++) {
        unichar c = [string characterAtIndex:i];
        
        if (c == '\'' || c == '\\') {
            [escapedString appendString:@"\\"];
        }
        
        [escapedString appendString:[NSString stringWithCharacters:&c length:1]];
    }
    
    if (quotes) {
        [escapedString appendString:@"\'"];
    }
    
    return escapedString;
}

+ (NSString*)escapeLike:(NSString*)string {
    NSMutableString *escapedString = [NSMutableString stringWithString:@"'"];
    for (NSUInteger i = 0; i < string.length; i++) {
        unichar c = [string characterAtIndex:i];
        
        if (c == '\'') {
            [escapedString appendString:@"\\"];
        } else if (c == '\\') {
            if (i + 1 < string.length && ([string characterAtIndex:(i + 1)] == '%' || [string characterAtIndex:(i + 1)] == '_')) {
                // no additional back slash
            } else {
                [escapedString appendString:@"\\"];
            }
        }
        
        [escapedString appendString:[NSString stringWithCharacters:&c length:1]];
    }
    
    [escapedString appendString:@"\'"];
    return escapedString;
}

+ (NSString*)escapeContains:(NSString*)string {
    NSMutableString *escapedString = [NSMutableString stringWithString:@"'"];
    for (NSUInteger i = 0; i < string.length; i++) {
        unichar c = [string characterAtIndex:i];
        
        if (c == '\\') {
            [escapedString appendString:@"\\"];
        } else if (c == '\'' || c == '\"') {
            [escapedString appendString:@"\\\\\\"];
        }
        
        [escapedString appendString:[NSString stringWithCharacters:&c length:1]];
    }
    
    [escapedString appendString:@"\'"];
    return escapedString;
}

+ (NSString*)convert:(NSDate*)date {
    if (!cmisQueryStatementTimeStampFormatter) {
        cmisQueryStatementTimeStampFormatter = [[NSDateFormatter alloc] init];
        cmisQueryStatementTimeStampFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
        cmisQueryStatementTimeStampFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        cmisQueryStatementTimeStampFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    }

    return [cmisQueryStatementTimeStampFormatter stringFromDate:date];
}

@end
