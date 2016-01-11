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

#import "CMISAtomPubExtensionElementParser.h"


@interface CMISAtomPubExtensionElementParser ()

// Properties used for Parsing
@property (nonatomic, strong) id<NSXMLParserDelegate, CMISAtomPubExtensionElementParserDelegate> childDelegate;
@property (nonatomic, weak) id<NSXMLParserDelegate, CMISAtomPubExtensionElementParserDelegate> parentDelegate;

// ExtensionElement properties
@property (nonatomic, strong) NSString *extensionName;
@property (nonatomic, strong) NSString *extensionNamespaceUri;
@property (nonatomic, strong) NSMutableString *extensionValue;
@property (nonatomic, strong) NSDictionary *extensionAttributes;
@property (nonatomic, strong) NSMutableArray *extensionChildren;

- (id)initWithElementName:(NSString *)elementName namespaceUri:(NSString *)namespaceUri attributes:(NSDictionary *)attributes parentDelegate:(id<NSXMLParserDelegate, CMISAtomPubExtensionElementParserDelegate>)parentDelegate parser:(NSXMLParser *)parser;
@end

@implementation CMISAtomPubExtensionElementParser


#pragma mark -
#pragma mark Initializers

- (id)initWithElementName:(NSString *)elementName namespaceUri:(NSString *)namespaceUri attributes:(NSDictionary *)attributes parentDelegate:(id<NSXMLParserDelegate, CMISAtomPubExtensionElementParserDelegate>)parentDelegate parser:(NSXMLParser *)parser
{
    self = [super init];
    if (self) {
        self.extensionName = elementName;
        self.extensionNamespaceUri = namespaceUri;
        self.extensionAttributes = attributes;
        self.parentDelegate = parentDelegate;
        
        [parser setDelegate:self];
    }
    return self;
}

+ (id)extensionElementParserWithElementName:(NSString *)elementName namespaceUri:(NSString *)namespaceUri attributes:(NSDictionary *)attributes parentDelegate:(id<NSXMLParserDelegate, CMISAtomPubExtensionElementParserDelegate>)parentDelegate parser:(NSXMLParser *)parser
{
    return  [[self alloc] initWithElementName:elementName namespaceUri:namespaceUri attributes:attributes parentDelegate:parentDelegate parser:parser];
}

#pragma mark -
#pragma mark NSXMLParserDelegate Methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    self.childDelegate = [CMISAtomPubExtensionElementParser extensionElementParserWithElementName:elementName namespaceUri:namespaceURI 
                                                                                       attributes:attributeDict parentDelegate:self parser:parser];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (nil == self.extensionValue) {
        self.extensionValue = [[NSMutableString alloc] init];
    }
    [self.extensionValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:self.extensionName] && [namespaceURI isEqualToString:self.extensionNamespaceUri]) {
        CMISExtensionElement *extElement = nil;
        if ([self.extensionChildren count] > 0) {
            extElement = [[CMISExtensionElement alloc] initNodeWithName:self.extensionName 
                                                           namespaceUri:self.extensionNamespaceUri 
                                                             attributes:self.extensionAttributes 
                                                               children:self.extensionChildren];
        } else {
            extElement = [[CMISExtensionElement alloc] initLeafWithName:self.extensionName 
                                                           namespaceUri:self.extensionNamespaceUri 
                                                             attributes:self.extensionAttributes 
                                                                  value:self.extensionValue];
        }

        [self.parentDelegate extensionElementParser:self didFinishParsingExtensionElement:extElement];
        
        parser.delegate = self.parentDelegate;
        self.parentDelegate = nil;
    }
}

#pragma mark -
#pragma mark CMISAtomPubExtensionElementParser

- (void)extensionElementParser:(CMISAtomPubExtensionElementParser *)parser didFinishParsingExtensionElement:(CMISExtensionElement *)extensionElement
{
    if (self.extensionChildren == nil) {
        self.extensionChildren = [[NSMutableArray alloc] init];
    }
    
    [self.extensionChildren addObject:extensionElement];
}

@end
