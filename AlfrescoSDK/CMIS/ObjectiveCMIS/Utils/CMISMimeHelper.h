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

extern NSString * const kCMISMimeHelperDispositionFormDataContent;

@interface CMISMimeHelper : NSObject

/**
 * Encodes the Content-Disposition header value according to RFC 2183 and
 * RFC 2231.
 * <p>
 * See <a href="http://tools.ietf.org/html/rfc2231">RFC 2231</a> for
 * details.
 *
 * @param disposition
 *            the disposition
 * @param filename
 *            the file name
 * @return the encoded header value
 */
+ (NSString *)encodeContentDisposition:(NSString *)disposition fileName:(NSString *)filename;

@end
