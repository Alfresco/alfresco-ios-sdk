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
 
#import "CMISURLUtil.h"
#import "CMISConstants.h"

NSString * const kCMISRFC7232Reserved = @";?:@&=+$,[]";
NSString * const kCMISRFC3986Reserved = @"!*'();:@&=+$,/?%#[]";


@implementation CMISURLUtil

+ (NSString *)urlStringByAppendingParameter:(NSString *)parameterName boolValue:(BOOL)parameterValue urlString:(NSString *)urlString
{
    return [CMISURLUtil urlStringByAppendingParameter:parameterName value:parameterValue ? kCMISParameterValueTrue : kCMISParameterValueFalse urlString:urlString];
}

+ (NSString *)urlStringByAppendingParameter:(NSString *)parameterName numberValue:(NSNumber *)parameterValue urlString:(NSString *)urlString
{
    return [CMISURLUtil urlStringByAppendingParameter:parameterName value:[parameterValue stringValue] urlString:urlString];
}

+ (NSString *)urlStringByAppendingParameter:(NSString *)parameterName value:(NSString *)parameterValue urlString:(NSString *)urlString
{
    if (parameterName == nil || parameterValue == nil || urlString == nil) {
        return urlString;
    }

    NSMutableString *result = [NSMutableString stringWithString:urlString];

    // Append '?' if not yet in url, else append ampersand
    if ([result rangeOfString:@"?"].location == NSNotFound) {
        [result appendString:@"?"];
    } else {
        if([result rangeOfString:@"?"].location != result.length -1){ // Only add ampersand if there is already a parameter added
            [result appendString:@"&"];
        }
    }

    // Append param
    [result appendString:parameterName];
    [result appendString:@"="];
    [result appendString:[CMISURLUtil encodeUrlParameterValue:parameterValue]];

    return result;
}

+ (NSString *)urlStringByAppendingPath:(NSString *)path urlString:(NSString *)urlString
{
    if(!path){
        return urlString;
    }
    
    if([path rangeOfString:@"/"].location == 0) {
        path = [path substringFromIndex:1];
    }
    
    NSURL *url = [[NSURL URLWithString:urlString] URLByAppendingPathComponent:path];

    // quote some additional reserved characters
    path = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                     (CFStringRef)url.path,
                                                                     NULL,
                                                                     (CFStringRef)kCMISRFC7232Reserved,
                                                                     kCFStringEncodingUTF8));
    
    return [self replacePathInUrl:[url absoluteString] withPath:path];
}

+ (NSURL *)urlStringByAppendingParameter:(NSString *)parameterName value:(NSString *)parameterValue url:(NSURL *)url
{
    return [NSURL URLWithString:[CMISURLUtil urlStringByAppendingParameter:parameterName value:parameterValue urlString:[url absoluteString]]];
}

+ (NSString *)encodeUrlParameterValue:(NSString *)value
{
    NSString *encodedValue = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                       (CFStringRef)value,
                                                                                       NULL,
                                                                                       (CFStringRef)kCMISRFC3986Reserved,
                                                                                       kCFStringEncodingUTF8));
    return encodedValue;
}

#pragma mark -
#pragma mark Private helper methods

+ (NSString *)replacePathInUrl:(NSString *)url withPath:(NSString *)replacementPath
{
    NSMutableString *serverUrl = [[NSMutableString alloc] init];
    
    NSURL *tmp = [[NSURL alloc] initWithString:url];
    
    if(tmp.scheme){
        [serverUrl appendFormat:@"%@://", tmp.scheme];
    }
    if(tmp.host){
        [serverUrl appendString:tmp.host];
    }
    if(tmp.port){
        [serverUrl appendFormat:@":%@", [tmp.port stringValue]];
    }
    if(replacementPath){
        [serverUrl appendString:replacementPath];
    }
    if(tmp.query){
        [serverUrl appendFormat:@"?%@", tmp.query];
    }
    
    if(serverUrl.length == 0){ //this happens when it's not a valid url
        [serverUrl appendString:url];
    }
    
    return serverUrl;
}

@end