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

#import <Foundation/Foundation.h>
#import "CMISProperties.h"

@interface CMISBroswerFormDataWriter : NSObject

- (id)initWithAction:(NSString *)action;

- (id)initWithAction:(NSString *)action contentStream:(NSInputStream *)contentStream mediaType:(NSString *)mediaType;

- (void)addParameter:(NSString *)name value:(id)value;

- (void)addParameter:(NSString *)name boolValue:(BOOL)value;

/// if the fileName is not set the value of the property with id kCMISPropertyName will be used for the form data content name
- (void)addPropertiesParameters:(CMISProperties *)properties;

- (void)addSuccinctFlag:(BOOL)succinct;

/// the filenName will be used for the form data content name
- (void)setFileName:(NSString *)fileName;

- (NSDictionary *)headers;

/// call this method to get the http request body form data if no content stream is used
- (NSData *)body;

/// call this method to get the start of the http request body form data if a content stream is set
- (NSData *)startData;

/// call this method to get the end of the http request body form data if a content stream is set
- (NSData *)endData;

@end
