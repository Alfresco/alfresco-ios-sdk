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

#import "CMISAtomPubAceParser.h"
#import "CMISAtomPubConstants.h"

@interface CMISAtomPubAceParser ()

@property (nonatomic, strong) NSMutableSet *internalPermissionsSet;
@property (nonatomic, weak) id<NSXMLParserDelegate, CMISAtomPubAceParserDelegate> parentDelegate;
@property (nonatomic, strong) NSMutableString *string;

@end

@implementation CMISAtomPubAceParser


- (id)initAceParserWithParentDelegate:(id<NSXMLParserDelegate, CMISAtomPubAceParserDelegate>)parentDelegate parser:(NSXMLParser *)parser
{
    self = [super init];
    if (self) {
        self.parentDelegate = parentDelegate;
        
        self.internalPermissionsSet = [[NSMutableSet alloc] init];
        self.ace = [[CMISAce alloc] init];
        [self pushNewCurrentExtensionData:self.ace];
        
        // Setting Child Parser Delegate
        [parser setDelegate:self];
    }
    return self;
}

+(id)aceParserWithParentDelegate:(id<NSXMLParserDelegate,CMISAtomPubAceParserDelegate>)parentDelegate parser:(NSXMLParser *)parser{
    return [[[self class] alloc] initAceParserWithParentDelegate:parentDelegate parser:parser];
}

#pragma mark -
#pragma mark NSXMLParserDelegate Methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict
{
    if ([namespaceURI isEqualToString:kCMISNamespaceCmis]) {
        
        if ([elementName isEqualToString:kCMISAtomEntryPermission])  {
            [self setInternalPermissionsSet:[NSMutableSet set]];
            
            [self pushNewCurrentExtensionData:self.ace];
            self.string = [NSMutableString string];
        } else if ([elementName isEqualToString:kCMISAtomEntryPrincipal]) {
            self.childParserDelegate = [CMISAtomPubPrincipalParser principalParserWithParentDelegate:self parser:parser];
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
        if ([elementName isEqualToString:kCMISAtomEntryPermission] && !self.string) { //if string is not set it's the parent permission element
            // Save the extension data
            [self saveCurrentExtensionsAndPushPreviousExtensionData];
            
            if (self.parentDelegate) {
                if ([self.parentDelegate respondsToSelector:@selector(aceParser:didFinishParsingAce:)]) {
                    [self.parentDelegate performSelector:@selector(aceParser:didFinishParsingAce:) withObject:self withObject:self.ace];
                }
                
                // Reset Delegate to parent
                [parser setDelegate:self.parentDelegate];
                self.parentDelegate = nil;
            }
        } else if ([elementName isEqualToString:kCMISAtomEntryPermission]) {
            [self.internalPermissionsSet addObject:self.string];
            self.ace.permissions = [self.internalPermissionsSet copy];
        } else if ([elementName isEqualToString:kCMISAtomEntryDirect]) {
            self.ace.isDirect = [self.string isEqualToString:@"true"] ? YES : NO;
        }
    }
    
    self.string = nil;
}


#pragma mark - CMISPrincipalParserDelegate Methods
-(void)principalParser:(CMISAtomPubPrincipalParser *)principalParser didFinishParsingPrincipal:(CMISPrincipal *)principal {
    self.ace.principal = principal;
}


@end
