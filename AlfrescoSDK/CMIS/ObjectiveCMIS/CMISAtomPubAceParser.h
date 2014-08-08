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
#import "CMISAtomPubExtensionDataParserBase.h"
#import "CMISAce.h"
#import "CMISAtomPubPrincipalParser.h"

@class CMISAtomPubAceParser;

@protocol CMISAtomPubAceParserDelegate <NSObject>
@required
/// parses access control entry delegate method
- (void)aceParser:(CMISAtomPubAceParser *)aceParser didFinishParsingAce:(CMISAce *)ace;
@end

@interface CMISAtomPubAceParser : CMISAtomPubExtensionDataParserBase <NSXMLParserDelegate, CMISAtomPubPrincipalParserDelegate>


@property (nonatomic, strong) CMISAce *ace;

/// Designated Initializer
- (id)initAceParserWithParentDelegate:(id<NSXMLParserDelegate, CMISAtomPubAceParserDelegate>)parentDelegate parser:(NSXMLParser *)parser;

/// parses access control entries
+(id)aceParserWithParentDelegate:(id<NSXMLParserDelegate, CMISAtomPubAceParserDelegate>)parentDelegate parser:(NSXMLParser *)parser;

@end
