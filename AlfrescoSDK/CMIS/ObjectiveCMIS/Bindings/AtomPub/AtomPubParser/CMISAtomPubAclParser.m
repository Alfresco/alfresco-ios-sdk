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

#import "CMISAtomPubAclParser.h"
#import "CMISAtomPubConstants.h"
#import "CMISAtomPubAceParser.h"

@interface CMISAtomPubAclParser ()

@property (nonatomic, strong) NSMutableSet *internalAcesSet;
@property (nonatomic, weak) id<NSXMLParserDelegate, CMISAtomPubAclParserDelegate> parentDelegate;
@property (nonatomic, strong) NSMutableString *string;

@end

@implementation CMISAtomPubAclParser


- (id)initAclParserWithParentDelegate:(id<NSXMLParserDelegate, CMISAtomPubAclParserDelegate>)parentDelegate parser:(NSXMLParser *)parser
{
    self = [super init];
    if (self)  {
        self.parentDelegate = parentDelegate;
        self.internalAcesSet = [[NSMutableSet alloc] init];
        
        self.acl = [[CMISAcl alloc] init];
        [self pushNewCurrentExtensionData:self.acl];
        
        // Setting Child Parser Delegate
        [parser setDelegate:self];
    }
    return self;
}

+(id)aclParserWithParentDelegate:(id<NSXMLParserDelegate,CMISAtomPubAclParserDelegate>)parentDelegate parser:(NSXMLParser *)parser{
    return [[[self class] alloc] initAclParserWithParentDelegate:parentDelegate parser:parser];
}

#pragma mark -
#pragma mark NSXMLParserDelegate Methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict
{
    if ([namespaceURI isEqualToString:kCMISNamespaceCmis]) {
        
        if ([elementName isEqualToString:kCMISAtomEntryAcl])  {
            
            self.acl = [[CMISAcl alloc] init];
            [self pushNewCurrentExtensionData:self.acl];
        } else if ([elementName isEqualToString:kCMISAtomEntryPermission]) {
            self.childParserDelegate = [CMISAtomPubAceParser aceParserWithParentDelegate:self parser:parser];
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
        if ([elementName isEqualToString:kCMISAtomEntryAcl]) {
            // Save the extension data
            [self saveCurrentExtensionsAndPushPreviousExtensionData];
            
            if (self.parentDelegate) {
                if ([self.parentDelegate respondsToSelector:@selector(aclParser:didFinishParsingAcl:)]) {
                    [self.parentDelegate performSelector:@selector(aclParser:didFinishParsingAcl:) withObject:self withObject:self.acl];
                }
                
                // Reset Delegate to parent
                [parser setDelegate:self.parentDelegate];
                self.parentDelegate = nil;
            }
        }
    }
    
    self.string = nil;
}

#pragma mark - CMISAceParserDelegate Methods
-(void)aceParser:(CMISAtomPubAceParser *)aceParser didFinishParsingAce:(CMISAce *)ace{
    [self.internalAcesSet addObject:ace];
    self.acl.aces = [self.internalAcesSet copy];
}

@end
