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

#import "CMISMimeHelper.h"
#import "CMISLog.h"

NSString * const kCMISMimeHelperDispositionFormDataContent = @"form-data; name=\"content\"";
NSString * const kCMISMimeHelperDispositionAttachment = @"attachment";
NSString * const kCMISMimeHelperDispositionFilename = @"filename";
NSString * const kCMISMimeHelperRFC2231Specials = @"*'%()<>@,;:\\\"/[]?=\t ";
NSString * const kCMISMimeHelperHexDigits = @"0123456789ABCDEF";

@implementation CMISMimeHelper

+ (NSString *)encodeContentDisposition:(NSString *)disposition fileName:(NSString *)filename
{
    if (disposition == nil) {
        disposition = kCMISMimeHelperDispositionAttachment;
    }
    return [NSString stringWithFormat:@"%@%@", disposition, [CMISMimeHelper encodeRFC2231Key:kCMISMimeHelperDispositionFilename value:filename]];
}

+ (NSString *)encodeRFC2231Key:(NSString *)key value:(NSString *)value
{
    NSMutableString *buf = [[NSMutableString alloc] init];
    BOOL encoded = [CMISMimeHelper encodeRFC2231value:value buffer:buf];
    if (encoded) {
        return [NSString stringWithFormat:@"; %@*=%@", key, buf];
    } else {
        return [NSString stringWithFormat:@"; %@=%@", key, value];
    }
}

+ (BOOL)encodeRFC2231value:(NSString *)value buffer:(NSMutableString *)buf
{
    assert(value);
    
    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
    
    NSUInteger len = [data length];
    Byte *bytes = (Byte*)malloc(len);
    memcpy(bytes, [data bytes], len);
    
    static NSCharacterSet *rfc2231Specials = nil;
    if (!rfc2231Specials) {
        rfc2231Specials = [NSCharacterSet characterSetWithCharactersInString:kCMISMimeHelperRFC2231Specials];
    }
    
    static const char *hexDigits = nil;
    if(!hexDigits) {
        hexDigits = [kCMISMimeHelperHexDigits UTF8String];
    }
    
    [buf appendString:@"UTF-8"];
    [buf appendString:@"''"]; // no language
    
    BOOL encoded = NO;
    for (int i = 0; i < len; i++) {
        int ch = bytes[i] & 0xff;
        unichar character = (char) ch;
        if (ch <= 32 || ch >= 127 || [rfc2231Specials characterIsMember:character]) {
            [buf appendString:@"%"];
            character = hexDigits[ch >> 4];
            [buf appendString:[NSString stringWithCharacters:&character length:1]];
            character = hexDigits[ch & 0xf];
            [buf appendString:[NSString stringWithCharacters:&character length:1]];
            encoded = YES;
        } else {
            [buf appendString:[NSString stringWithCharacters:&character length:1]];
        }
    }
    
    free(bytes);
    
    return encoded;
}

@end
