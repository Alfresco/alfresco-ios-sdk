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

#import "CMISAtomPubPrincipalParser.h"
#import "CMISAtomPubConstants.h"

@interface CMISAtomPubPrincipalParser ()

@property (nonatomic, strong) NSMutableSet *internalAcesSet;
@property (nonatomic, weak) id<NSXMLParserDelegate, CMISAtomPubPrincipalParserDelegate> parentDelegate;
@property (nonatomic, strong) NSMutableString *string;

@end

@implementation CMISAtomPubPrincipalParser


- (id)initPrincipalParserWithParentDelegate:(id<NSXMLParserDelegate, CMISAtomPubPrincipalParserDelegate>)parentDelegate parser:(NSXMLParser *)parser
{
    self = [super init];
    if (self) {
        self.parentDelegate = parentDelegate;
        
        self.principal = [[CMISPrincipal alloc] init];
        [self pushNewCurrentExtensionData:self.principal];
        
        // Setting Child Parser Delegate
        [parser setDelegate:self];
    }
    return self;
}

+(id)principalParserWithParentDelegate:(id<NSXMLParserDelegate,CMISAtomPubPrincipalParserDelegate>)parentDelegate parser:(NSXMLParser *)parser{
    return [[[self class] alloc] initPrincipalParserWithParentDelegate:parentDelegate parser:parser];
}

#pragma mark -
#pragma mark NSXMLParserDelegate Methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict
{
    if ([namespaceURI isEqualToString:kCMISNamespaceCmis]) {
        
        if ([elementName isEqualToString:kCMISAtomEntryPrincipal])  {
            [self setInternalAcesSet:[NSMutableSet set]];
            
            self.principal = [[CMISPrincipal alloc] init];
            [self pushNewCurrentExtensionData:self.principal];
        } else {
            self.string = [NSMutableString string];
        }
    }
    else {
        self.childParserDelegate = [CMISAtomPubExtensionElementParser extensionElementParserWithElementName:elementName namespaceUri:namespaceURI
                                                                                                 attributes:attributeDict parentDelegate:self parser:parser];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [self.string appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([namespaceURI isEqualToString:kCMISNamespaceCmis]) {
        if ([elementName isEqualToString:kCMISAtomEntryPrincipal]) {
            // Save the extension data
            [self saveCurrentExtensionsAndPushPreviousExtensionData];
            
            if (self.parentDelegate) {
                if ([self.parentDelegate respondsToSelector:@selector(principalParser:didFinishParsingPrincipal:)]) {
                    [self.parentDelegate performSelector:@selector(principalParser:didFinishParsingPrincipal:) withObject:self withObject:self.principal];
                }
                
                // Reset Delegate to parent
                [parser setDelegate:self.parentDelegate];
                self.parentDelegate = nil;
            }
        } else if ([elementName isEqualToString:kCMISAtomEntryPrincipalId]) {
            self.principal.principalId = self.string;
        }    }
    
    self.string = nil;
}


@end
