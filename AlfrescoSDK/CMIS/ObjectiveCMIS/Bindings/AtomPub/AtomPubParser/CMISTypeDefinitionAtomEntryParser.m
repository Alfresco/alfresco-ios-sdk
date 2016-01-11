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

#import "CMISTypeDefinitionAtomEntryParser.h"
#import "CMISTypeDefinition.h"
#import "CMISDocumentTypeDefinition.h"
#import "CMISAtomPubConstants.h"
#import "CMISConstants.h"

@interface CMISTypeDefinitionAtomEntryParser ()

@property(nonatomic, strong, readwrite) CMISTypeDefinition *typeDefinition;
@property(readwrite) BOOL isParsingTypeDefinition;
@property(nonatomic, strong, readwrite) NSData *atomData;
@property(nonatomic, strong, readwrite) NSString *currentString;

@end


@implementation CMISTypeDefinitionAtomEntryParser


- (id)initWithData:(NSData *)atomData
{
    self = [self init];
    if (self) {
        self.atomData = atomData;
    }

    return self;
}

- (BOOL)parseAndReturnError:(NSError **)error
{
    BOOL parseSuccessful = YES;

    // parse the AtomPub data
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.atomData];
    [parser setShouldProcessNamespaces:YES];
    [parser setDelegate:self];

    parseSuccessful = [parser parse];

    if (!parseSuccessful) {
        if (error) {
            *error = [parser parserError];
        }
    }

    return parseSuccessful;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([namespaceURI isEqualToString:kCMISNamespaceCmisRestAtom]) {
        if ([elementName isEqualToString:kCMISRestAtomType]) {
            __block BOOL documentType = NO;
            [attributeDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([key hasSuffix:@"type"] && [obj hasSuffix:@"cmisTypeDocumentDefinitionType"]) {
                    documentType = YES;
                }
            }];
            
            if (documentType) {
                self.typeDefinition = [[CMISDocumentTypeDefinition alloc] init];
            } else {
                self.typeDefinition = [[CMISTypeDefinition alloc] init];
            }
            self.isParsingTypeDefinition = YES;
            
            [self pushNewCurrentExtensionData:self.typeDefinition];
        }
    } else if ([namespaceURI isEqualToString:kCMISNamespaceCmis]) {
        if ([elementName isEqualToString:kCMISCorePropertyStringDefinition] ||
            [elementName isEqualToString:kCMISCorePropertyIdDefinition] ||
            [elementName isEqualToString:kCMISCorePropertyBooleanDefinition] ||
            [elementName isEqualToString:kCMISCorePropertyIntegerDefinition] ||
            [elementName isEqualToString:kCMISCorePropertyDateTimeDefinition] ||
            [elementName isEqualToString:kCMISCorePropertyDecimalDefinition]) {
            self.childParserDelegate = [CMISAtomPubPropertyDefinitionParser parserForPropertyDefinition:elementName withParentDelegate:self parser:parser];
        }
    } else if ([namespaceURI isEqualToString:kCMISNamespaceApp] ||
               [namespaceURI isEqualToString:kCMISNamespaceAtom]) {
        // do nothing with these namespaces
    } else {
        // parse extension data
        if (self.currentExtensionData != nil) {
            self.childParserDelegate = [CMISAtomPubExtensionElementParser extensionElementParserWithElementName:elementName namespaceUri:namespaceURI
                                                                                                     attributes:attributeDict parentDelegate:self parser:parser];
        }
    }
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSString *cleanedString = [string stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!self.currentString) {
        self.currentString = cleanedString;
    } else {
        self.currentString = [self.currentString stringByAppendingString:cleanedString];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:kCMISRestAtomType]) {
        self.isParsingTypeDefinition = NO;
    } else if ([elementName isEqualToString:kCMISCoreId]) {
        if (self.isParsingTypeDefinition){
            self.typeDefinition.identifier = self.currentString;
        }
    } else if ([elementName isEqualToString:kCMISCoreLocalName]) {
        if (self.isParsingTypeDefinition) {
            self.typeDefinition.localName = self.currentString;
        }
    } else if ([elementName isEqualToString:kCMISCoreLocalNamespace]) {
        if (self.isParsingTypeDefinition) {
            self.typeDefinition.localNamespace = self.currentString;
        }
    } else if ([elementName isEqualToString:kCMISCoreDisplayName]) {
        if (self.isParsingTypeDefinition) {
            self.typeDefinition.displayName = self.currentString;
        }
    } else if ([elementName isEqualToString:kCMISCoreQueryName]) {
        if (self.isParsingTypeDefinition) {
            self.typeDefinition.queryName = self.currentString;
        }
    } else if ([elementName isEqualToString:kCMISCoreDescription]) {
        if (self.isParsingTypeDefinition) {
            self.typeDefinition.summary = self.currentString;
        }
    } else if ([elementName isEqualToString:kCMISCoreBaseId]) {
        if (self.isParsingTypeDefinition) {
            if ([self.currentString isEqualToString:kCMISPropertyObjectTypeIdValueDocument]) {
                self.typeDefinition.baseTypeId = CMISBaseTypeDocument;
            } else if ([self.currentString isEqualToString:kCMISPropertyObjectTypeIdValueFolder]) {
                self.typeDefinition.baseTypeId = CMISBaseTypeFolder;
            } else if ([self.currentString isEqualToString:kCMISPropertyObjectTypeIdValuePolicy]) {
                self.typeDefinition.baseTypeId = CMISBaseTypePolicy;
            } else if ([self.currentString isEqualToString:kCMISPropertyObjectTypeIdValueItem]) {
                self.typeDefinition.baseTypeId = CMISBaseTypeItem;
            } else if ([self.currentString isEqualToString:kCMISPropertyObjectTypeIdValueSecondary]) {
                self.typeDefinition.baseTypeId = CMISBaseTypeSecondary;
            } else if ([self.currentString isEqualToString:kCMISPropertyObjectTypeIdValueRelationship]) {
                self.typeDefinition.baseTypeId = CMISBaseTypeRelationship;
            }
        }
    } else if ([elementName isEqualToString:kCMISCoreParentId]) {
        if (self.isParsingTypeDefinition) {
            self.typeDefinition.parentTypeId = self.currentString;
        }
    } else if ([elementName isEqualToString:kCMISCoreCreatable]) {
        if (self.isParsingTypeDefinition) {
            self.typeDefinition.creatable = [self.currentString.lowercaseString isEqualToString:kCMISAtomEntryValueTrue];
        }
    } else if ([elementName isEqualToString:kCMISCoreFileable]) {
        if (self.isParsingTypeDefinition) {
            self.typeDefinition.fileable = [self.currentString.lowercaseString isEqualToString:kCMISAtomEntryValueTrue];
        }
    } else if ([elementName isEqualToString:kCMISCoreQueryable]) {
        if (self.isParsingTypeDefinition) {
            self.typeDefinition.queryable = [self.currentString.lowercaseString isEqualToString:kCMISAtomEntryValueTrue];
        }
    } else if ([elementName isEqualToString:kCMISCoreFullTextIndexed]) {
        if (self.isParsingTypeDefinition) {
            self.typeDefinition.fullTextIndexed = [self.currentString.lowercaseString isEqualToString:kCMISAtomEntryValueTrue];
        }
    } else if ([elementName isEqualToString:kCMISCoreIncludedInSupertypeQuery]) {
        if (self.isParsingTypeDefinition) {
            self.typeDefinition.includedInSupertypeQuery = [self.currentString.lowercaseString isEqualToString:kCMISAtomEntryValueTrue];
        }
    } else if ([elementName isEqualToString:kCMISCoreControllableACL]) {
        if (self.isParsingTypeDefinition) {
            self.typeDefinition.controllableAcl = [self.currentString.lowercaseString isEqualToString:kCMISAtomEntryValueTrue];
        }
    } else if ([elementName isEqualToString:kCMISCoreControllablePolicy]) {
        if (self.isParsingTypeDefinition) {
            self.typeDefinition.controllablePolicy = [self.currentString.lowercaseString isEqualToString:kCMISAtomEntryValueTrue];
        }
    } else if ([elementName isEqualToString:kCMISCoreVersionable]) {
        if (self.isParsingTypeDefinition && [self.typeDefinition isKindOfClass:CMISDocumentTypeDefinition.class]) {
            ((CMISDocumentTypeDefinition*)self.typeDefinition).versionable = [self.currentString.lowercaseString isEqualToString:kCMISAtomEntryValueTrue];
        }
    } else if ([elementName isEqualToString:kCMISCoreContentStreamAllowed]) {
        if (self.isParsingTypeDefinition && [self.typeDefinition isKindOfClass:CMISDocumentTypeDefinition.class]) {
            if ([self.currentString isEqualToString:kCMISCoreAllowed]) {
                ((CMISDocumentTypeDefinition*)self.typeDefinition).contentStreamAllowed = CMISContentStreamAllowed;
            } else if ([self.currentString isEqualToString:kCMISCoreNotAllowed]) {
                ((CMISDocumentTypeDefinition*)self.typeDefinition).contentStreamAllowed = CMISContentStreamNotAllowed;
            } else if ([self.currentString isEqualToString:kCMISCoreRequired]) {
                ((CMISDocumentTypeDefinition*)self.typeDefinition).contentStreamAllowed = CMISContentStreamRequired;
            }
        }
    } else if ([elementName isEqualToString:kCMISAtomEntry]) {
        // set the extensionData
        [self saveCurrentExtensionsAndPushPreviousExtensionData];
    }

    self.currentString = nil;
}

#pragma mark CMISPropertyDefinitionDelegate delegates

- (void)propertyDefinitionParser:(id)propertyDefinitionParser didFinishParsingPropertyDefinition:(CMISPropertyDefinition *)propertyDefinition
{
    [self.typeDefinition addPropertyDefinition:propertyDefinition];
}


@end