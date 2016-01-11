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

#import "CMISBroswerFormDataWriter.h"
#import "CMISConstants.h"
#import "CMISBrowserConstants.h"
#import "CMISEnums.h"
#import "CMISLog.h"
#import "CMISMimeHelper.h"
#import "CMISURLUtil.h"

NSString * const kCMISFormDataContentTypeUrlEncoded = @"application/x-www-form-urlencoded;charset=utf-8";
NSString * const kCMISFormDataContentTypeFormData = @"multipart/form-data; boundary=";

@interface CMISBroswerFormDataWriter ()

@property (nonatomic, strong) NSInputStream *contentStream;
@property (nonatomic, strong) NSMutableDictionary *parameters;
@property (nonatomic, strong) NSString *boundary;
@property (nonatomic, strong) NSString *mediaType;
@property (nonatomic, strong) NSString *fileName;

@end

@implementation CMISBroswerFormDataWriter

- (id)initWithAction:(NSString *)action
{
    return [self initWithAction:action contentStream:nil mediaType:nil];
}

- (id)initWithAction:(NSString *)action contentStream:(NSInputStream *)contentStream mediaType:(NSString *)mediaType
{
    self = [super init];
    if (self) {
        self.parameters = [[NSMutableDictionary alloc] init];
        
        [self addParameter:kCMISBrowserJSONControlCmisAction value:action];
        self.contentStream = contentStream;
        self.mediaType = mediaType;
        self.boundary = [NSString stringWithFormat:@"aPacHeCheMIStryoBjECtivEcmiS%x%a%x", (unsigned int) action.hash, CFAbsoluteTimeGetCurrent(), (unsigned int) self.hash];
        
    }
    return self;
}

- (void)addParameter:(NSString *)name value:(id)value
{
    if(!name || !value) {
        return;
    }
    
    [self.parameters setValue:[value description] forKey:name];
}

- (void)addParameter:(NSString *)name boolValue:(BOOL)value
{
    [self addParameter:name value:(value? kCMISParameterValueTrue : kCMISParameterValueFalse)];
}

- (void)addSuccinctFlag:(BOOL)succinct
{
    if (succinct) {
        [self addParameter:kCMISBrowserJSONParameterSuccinct value:kCMISParameterValueTrue];
    }
}

- (void)addPropertiesParameters:(CMISProperties *)properties
{
    if (!properties) {
        return;
    }
    
    if(!self.fileName){
        self.fileName = [properties propertyValueForId:kCMISPropertyName];   
    }
    
    int idx = 0;
    
    for (CMISPropertyData *prop in properties.propertyList) {
        
        NSString *idxStr = [NSString stringWithFormat:@"[%d]", idx];
        
        
        [self addParameter:[NSString stringWithFormat:@"%@%@", kCMISBrowserJSONControlPropertyId, idxStr] value:prop.identifier];
        
        if (prop.values && prop.values.count > 0) {
            if (prop.values.count == 1) {
                NSString *value = [self convertPropertyValue:prop.firstValue forPropertyType:prop.type];
                [self addParameter:[NSString stringWithFormat:@"%@%@", kCMISBrowserJSONControlPropertyValue, idxStr] value:value];
            } else {
                int vidx = 0;
                for (id obj in prop.values) {
                    NSString *vidxStr = [NSString stringWithFormat:@"[%d]", vidx];
                    NSString *value = [self convertPropertyValue:obj forPropertyType:prop.type];
                    [self addParameter:[NSString stringWithFormat:@"%@%@%@", kCMISBrowserJSONControlPropertyValue, idxStr, vidxStr] value:value];
                    vidx++;
                }
            }
        }
        
        idx++;
    }
}

// TODO should this method be part of CMISPropertyData class (as class method?)
- (NSString *)convertPropertyValue:(id)value forPropertyType:(CMISPropertyType)type
{
    if (!value) {
        return nil;
    }
    
    if (type == CMISPropertyTypeBoolean) {
        return [value boolValue] ? kCMISParameterValueTrue : kCMISParameterValueFalse;
    } else if (type == CMISPropertyTypeDateTime) {
        if ([value isKindOfClass:NSDate.class]) {
            return [NSNumber numberWithUnsignedLongLong:[(NSDate *)value timeIntervalSince1970] * 1000].description; //seconds to milliseconds
        } else {
            CMISLogWarning(@"value is not a date!");
        }
    }
    return value;
}

- (NSDictionary *)headers
{
    NSString *contentType = self.contentStream == nil ? kCMISFormDataContentTypeUrlEncoded : [NSString stringWithFormat:@"%@%@", kCMISFormDataContentTypeFormData, self.boundary];
    return @{@"Content-Type" : contentType};
}

- (NSData *)body
{
    if (self.contentStream == nil) {
        BOOL first = YES;
        NSData *amp = [@"&" dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableData *data = [[NSMutableData alloc] init];
        
        for (NSString *parameterKey in self.parameters) {
            if (first) {
                first = NO;
            } else {
                [data appendData:amp];
            }
            NSString *encodedParameterValue = [CMISURLUtil encodeUrlParameterValue:self.parameters[parameterKey]];
            NSString *parameter = [NSString stringWithFormat:@"%@=%@", parameterKey, encodedParameterValue];
            [data appendData:[parameter dataUsingEncoding:NSUTF8StringEncoding]];
        }

        return data;
    } else {
        CMISLogError(@"this method should not be called when content stream is set. Use startData and endData method to retrieve the data.");
        return nil;
    }
}

- (NSData *)startData
{
    if (self.contentStream) {
        NSMutableData *data = [[NSMutableData alloc] init];

        [self appendLine:data];
        
        // parameters
        for (NSString *paramKey in self.parameters) {
            [self appendLine:data string:[NSString stringWithFormat:@"--%@", self.boundary]];
            [self appendLine:data string:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"", paramKey]];
            [self appendLine:data string:@"Content-Type: text/plain; charset=utf-8"];
            [self appendLine:data];
            [self appendLine:data string:self.parameters[paramKey]];
        }
        
        // content
        if (self.fileName == nil || self.fileName.length == 0) {
            self.fileName = @"content";
        }
        
        if (self.mediaType == nil ||
            [self.mediaType rangeOfString:@"/"].location < 1 ||
            [self.mediaType rangeOfString:@"\n"].location > -1 ||
            [self.mediaType rangeOfString:@"\r"].location > -1) {
            self.mediaType = kCMISMediaTypeOctetStream;
        }

        [self appendLine:data string:[NSString stringWithFormat:@"--%@", self.boundary]];
        [self appendLine:data string:[NSString stringWithFormat:@"Content-Disposition: %@",
                  [CMISMimeHelper encodeContentDisposition:kCMISMimeHelperDispositionFormDataContent fileName:self.fileName]]];
        [self appendLine:data string:[NSString stringWithFormat:@"Content-Type: %@", self.mediaType]];
        [self appendLine:data string:@"Content-Transfer-Encoding: binary"];
        [self appendLine:data];
        
        return data;
    } else {
        CMISLogError(@"this method should not be called when content stream is nil. Use body method to retrieve the data.");
        return nil;
    }
}

- (NSData *)endData
{
    if (self.contentStream) {
        NSMutableData *data = [[NSMutableData alloc] init];
        
        [self appendLine:data];
        [self appendLine:data string:[NSString stringWithFormat:@"--%@--", self.boundary]];
        
        return data;
    } else {
        CMISLogError(@"this method should not be called when content stream is nil. Use body method to retrieve the data.");
        return nil;
    }
}

- (void)appendLine:(NSMutableData *)data
{
    [self appendLine:data string:nil];
}

- (void)appendLine:(NSMutableData *)data string:(NSString *)s
{
    s = s ? [NSString stringWithFormat:@"%@\r\n", s] : @"\r\n";
    [data appendData:[s dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
