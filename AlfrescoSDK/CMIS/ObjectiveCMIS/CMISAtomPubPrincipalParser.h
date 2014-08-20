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

#import "CMISAtomPubExtensionDataParserBase.h"
#import "CMISPrincipal.h"

@class CMISAtomPubPrincipalParser;

@protocol CMISAtomPubPrincipalParserDelegate <NSObject>
@required
/// parses principal delegate method
- (void)principalParser:(CMISAtomPubPrincipalParser *)principalParser didFinishParsingPrincipal:(CMISPrincipal *)principal;
@end

@interface CMISAtomPubPrincipalParser : CMISAtomPubExtensionDataParserBase <NSXMLParserDelegate>

@property (nonatomic, strong) CMISPrincipal *principal;

/// Designated Initializer
- (id)initPrincipalParserWithParentDelegate:(id<NSXMLParserDelegate, CMISAtomPubPrincipalParserDelegate>)parentDelegate parser:(NSXMLParser *)parser;

/// parses principals
+(id)principalParserWithParentDelegate:(id<NSXMLParserDelegate, CMISAtomPubPrincipalParserDelegate>)parentDelegate parser:(NSXMLParser *)parser;

@end
