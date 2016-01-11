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

#import "CMISAtomEntryParser.h"
#import "CMISAtomLink.h"
#import "CMISRenditionData.h"
#import "CMISAtomPubParserUtil.h"

@interface CMISAtomEntryParser ()

@property (nonatomic, strong, readwrite) CMISObjectData *objectData;

@property (nonatomic, strong) NSData *atomData;
@property (nonatomic, strong) NSString *currentPropertyType;
@property (nonatomic, strong) CMISPropertyData *currentPropertyData;
@property (nonatomic, strong) NSMutableArray *propertyValues;
@property (nonatomic, strong) CMISProperties *currentObjectProperties;
@property (nonatomic, strong) NSMutableSet *currentLinkRelations;
@property (nonatomic, strong) CMISRenditionData *currentRendition;
@property (nonatomic, strong) NSMutableArray *currentRenditions;
@property (nonatomic, strong) NSMutableString *string;
@property (nonatomic, assign) BOOL isExcatAcl;
@property (nonatomic, assign) BOOL parsingRelationship;

@property (nonatomic, weak) id<NSXMLParserDelegate, CMISAtomEntryParserDelegate> parentDelegate;
@property (nonatomic, strong) NSDictionary *entryAttributesDict;

// Designated initializer
- (id)init;
// Initializer used if this parser is a delegated child parser
- (id)initWithAtomEntryAttributes:(NSDictionary *)attributes parentDelegate:(id<NSXMLParserDelegate, CMISAtomEntryParserDelegate>)parentDelegate parser:(NSXMLParser *)parser;

@end


@implementation CMISAtomEntryParser


// Designated Initializer
- (id)init
{
    self = [super init];
    if (self) {
        self.currentLinkRelations = [NSMutableSet set];
        self.parsingRelationship = NO;
    }
    return self;
}

- (id)initWithData:(NSData *)atomData
{
    self = [self init];
    if (self) {
        self.atomData = atomData;
    }
    
    return self;
}

- (BOOL)parseAndReturnError:(NSError **)error;
{
    BOOL parseSuccessful = YES;
    
    // create objects to populate during parse
    self.objectData = [[CMISObjectData alloc] init];
    
    // parse the AtomPub data
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.atomData];
    [parser setShouldProcessNamespaces:YES];
    [parser setDelegate:self];

    parseSuccessful = [parser parse];
    
    if (!parseSuccessful){
        if (error) {
            *error = [parser parserError];
        }
    }
    
    return parseSuccessful;
}

- (id)initWithAtomEntryAttributes:(NSDictionary *)attributes parentDelegate:(id<NSXMLParserDelegate, CMISAtomEntryParserDelegate>)parentDelegate parser:(NSXMLParser *)parser
{
    self = [self init];
    if (self) {
        self.objectData = [[CMISObjectData alloc] init];
        self.entryAttributesDict = attributes;
        self.parentDelegate = parentDelegate;
        self.parsingRelationship = NO;
        
        // Setting ourself, the entry parser, as the delegate, we reset back to our parent when we're done
        [parser setDelegate:self];
    }
    return self;
}

+ (id)atomEntryParserWithAtomEntryAttributes:(NSDictionary *)attributes
                              parentDelegate:(id<NSXMLParserDelegate,CMISAtomEntryParserDelegate>)parentDelegate
                                      parser:(NSXMLParser *)parser
{
    return [[self alloc] initWithAtomEntryAttributes:attributes parentDelegate:parentDelegate parser:parser];
}

#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
                                            qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([namespaceURI isEqualToString:kCMISNamespaceCmis] && !self.parsingRelationship) {
        if ([elementName isEqualToString:kCMISAtomEntryPropertyId] ||
            [elementName isEqualToString:kCMISAtomEntryPropertyString] ||
            [elementName isEqualToString:kCMISAtomEntryPropertyInteger] ||
            [elementName isEqualToString:kCMISAtomEntryPropertyDateTime] ||
            [elementName isEqualToString:kCMISAtomEntryPropertyBoolean] ||
            [elementName isEqualToString:kCMISAtomEntryPropertyUri] ||
            [elementName isEqualToString:kCMISAtomEntryPropertyHtml] ||
            [elementName isEqualToString:kCMISAtomEntryPropertyDecimal]) {
            self.propertyValues = [NSMutableArray array];
            // store attribute values in CMISPropertyData object
            self.currentPropertyType = elementName;
            self.currentPropertyData = [[CMISPropertyData alloc] init];
            self.currentPropertyData.identifier = [attributeDict objectForKey:kCMISAtomEntryPropertyDefId];
            self.currentPropertyData.queryName = [attributeDict objectForKey:kCMISAtomEntryQueryName];
            self.currentPropertyData.displayName = [attributeDict objectForKey:kCMISAtomEntryDisplayName];
            self.currentPropertyData.type = [CMISAtomPubParserUtil atomPubTypeToInternalType:self.currentPropertyType];
        } else if ([elementName isEqualToString:kCMISCoreProperties]) {
            // create the CMISProperties object to hold all property data
            self.currentObjectProperties = [[CMISProperties alloc] init];
            
            // Set ObjectProperties as the current extensionData object
            [self pushNewCurrentExtensionData:self.currentObjectProperties];
        } else if ([elementName isEqualToString:kCMISCoreRendition]) {
            self.currentRendition = [[CMISRenditionData alloc] init];
        } else if ([elementName isEqualToString:kCMISAtomEntryAllowableActions]) {
            // Delegate parsing to child parser for allowableActions element
            self.childParserDelegate = [CMISAtomPubAllowableActionsParser allowableActionsParserWithParentDelegate:self parser:parser];
        } else if ([elementName isEqualToString:kCMISAtomEntryAcl]) {
            // Delegate parsing to child parser for acl element
            self.childParserDelegate = [CMISAtomPubAclParser aclParserWithParentDelegate:self parser:parser];
        } else if ([elementName isEqualToString:kCMISCoreRelationship]) {
            // NOTE: we're currently ignoring the relationship element so set a flag to check
            self.parsingRelationship = YES;
        }
    } else if ([namespaceURI isEqualToString:kCMISNamespaceCmisRestAtom]) {
        if ([elementName isEqualToString:kCMISAtomEntryObject]) {
            // Set object data as the current extensionData object
            [self pushNewCurrentExtensionData:self.objectData];
        }
    } else if ([namespaceURI isEqualToString:kCMISNamespaceAtom]) {
        if ([elementName isEqualToString:kCMISAtomEntryLink]) {
            NSString *linkType = [attributeDict objectForKey:kCMISAtomEntryType];
            NSString *rel = [attributeDict objectForKey:kCMISAtomEntryRel];
            NSString *href = [attributeDict objectForKey:kCMISAtomEntryHref]; 
            
            CMISAtomLink *link = [[CMISAtomLink alloc] initWithRelation:rel type:linkType href:href];
            [self.currentLinkRelations addObject:link];
        } else if ([elementName isEqualToString:kCMISAtomEntryContent]) {
            self.objectData.contentUrl = [NSURL URLWithString:[attributeDict objectForKey:kCMISAtomEntrySrc]];
        }
    } else if ([namespaceURI isEqualToString:kCMISNamespaceApp]) {
        // Nothing to do in this namespace
    } else {
        if (self.currentExtensionData != nil) {
            self.childParserDelegate = [CMISAtomPubExtensionElementParser extensionElementParserWithElementName:elementName namespaceUri:namespaceURI 
                                                                                                     attributes:attributeDict parentDelegate:self parser:parser];
        }
    }
    
    self.string = [NSMutableString string];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [self.string appendString:string];
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
   
    if ([elementName isEqualToString:kCMISAtomEntryValue]) {
        [CMISAtomPubParserUtil parsePropertyValue:self.string propertyType:self.currentPropertyType addToArray:self.propertyValues];
    } else if (self.currentRendition != nil) {
        if ([elementName isEqualToString:kCMISCoreStreamId]) {
            self.currentRendition.streamId = self.string;
        } else if ([elementName isEqualToString:kCMISCoreMimetype]) {
            self.currentRendition.mimeType = self.string;
        } else if ([elementName isEqualToString:kCMISCoreLength]) {
            self.currentRendition.length = [NSNumber numberWithInteger:[self.string integerValue]];
        } else if ([elementName isEqualToString:kCMISCoreTitle]) {
            self.currentRendition.title = self.string;
        } else if ([elementName isEqualToString:kCMISCoreKind]) {
            self.currentRendition.kind = self.string;
        } else if ([elementName isEqualToString:kCMISCoreHeight]) {
            self.currentRendition.height = [NSNumber numberWithInteger:[self.string integerValue]];
        } else if ([elementName isEqualToString:kCMISCoreWidth]) {
            self.currentRendition.width = [NSNumber numberWithInteger:[self.string integerValue]];
        } else if ([elementName isEqualToString:kCMISCoreRenditionDocumentId]) {
            self.currentRendition.renditionDocumentId = self.string;
        }
    }
    
    if ([namespaceURI isEqualToString:kCMISNamespaceCmis]) {
        if (!self.parsingRelationship)
        {
            // ignore the properties within the relationship element
            if ([elementName isEqualToString:kCMISAtomEntryPropertyId] ||
                [elementName isEqualToString:kCMISAtomEntryPropertyString] ||
                [elementName isEqualToString:kCMISAtomEntryPropertyInteger] ||
                [elementName isEqualToString:kCMISAtomEntryPropertyDateTime] ||
                [elementName isEqualToString:kCMISAtomEntryPropertyBoolean] ||
                [elementName isEqualToString:kCMISAtomEntryPropertyUri] ||
                [elementName isEqualToString:kCMISAtomEntryPropertyHtml] ||
                [elementName isEqualToString:kCMISAtomEntryPropertyDecimal]) {            
                // add the property to the properties dictionary
                self.currentPropertyData.values = self.propertyValues;
                self.propertyValues = nil;
                [self.currentObjectProperties addProperty:self.currentPropertyData];
                self.currentPropertyData = nil;
            } else if ([elementName isEqualToString:kCMISCoreProperties]) {
                // Finished parsing Properties & its ExtensionData
                [self saveCurrentExtensionsAndPushPreviousExtensionData];
            } else if ([elementName isEqualToString:kCMISCoreRendition]) {
                if (self.currentRenditions == nil) {
                    self.currentRenditions = [[NSMutableArray alloc] init];
                }
                if (self.currentRendition != nil) {
                    [self.currentRenditions addObject:self.currentRendition];
                }
                self.currentRendition = nil;
        	} else if ([elementName isEqualToString:kCMISAtomEntryExactACL]) {
            	self.isExcatAcl = [self.string isEqualToString:@"true"] ? YES : NO;
            	if(self.objectData.acl){
                	[self.objectData.acl setIsExact:self.isExcatAcl];
            	}
			}
        }
        
        // the relationship element has ended
        if ([elementName isEqualToString:kCMISCoreRelationship]) {
            self.parsingRelationship = NO;
        }
        
    } else if ([namespaceURI isEqualToString:kCMISNamespaceAtom]) {
        if ( [elementName isEqualToString:kCMISAtomEntry]) {
            // set the properties on the objectData object
            self.objectData.properties = self.currentObjectProperties;

            // set the link relations on the objectData object
            self.objectData.linkRelations = [[CMISLinkRelations alloc] initWithLinkRelationSet:[self.currentLinkRelations copy]];

            // set the renditions on the objectData object
            self.objectData.renditions = self.currentRenditions;

            // set the objectData identifier
            CMISPropertyData *objectId = [self.currentObjectProperties.propertiesDictionary objectForKey:kCMISPropertyObjectId];
            self.objectData.identifier = [objectId firstValue];

            // set the objectData baseType
            CMISPropertyData *baseTypeProperty = [self.currentObjectProperties.propertiesDictionary objectForKey:kCMISPropertyBaseTypeId];
            NSString *baseType = [baseTypeProperty firstValue];
            if ([baseType isEqualToString:kCMISPropertyObjectTypeIdValueDocument]) {
                self.objectData.baseType = CMISBaseTypeDocument;
            } else if ([baseType isEqualToString:kCMISPropertyObjectTypeIdValueFolder]) {
                self.objectData.baseType = CMISBaseTypeFolder;
            }

            // set the extensionData
            [self saveCurrentExtensionsAndPushPreviousExtensionData];

            self.currentObjectProperties = nil;

            if (self.parentDelegate) {
                if ([self.parentDelegate respondsToSelector:@selector(cmisAtomEntryParser:didFinishParsingCMISObjectData:)]) {
                    // Message the parent delegate the parsed ObjectData
                    [self.parentDelegate performSelector:@selector(cmisAtomEntryParser:didFinishParsingCMISObjectData:)
                                              withObject:self withObject:self.objectData];
                }

                // Resetting our parent as the delegate since we're done
                parser.delegate = self.parentDelegate;
                self.parentDelegate = nil;
            }
        }
    } else if ([namespaceURI isEqualToString:kCMISNamespaceApp]) {
        // Nothing to do in this namespace
    } else {
        // TODO other namespaces?
    }

    self.string = nil;
}

#pragma mark -
#pragma mark CMISAllowableActionsParserDelegate Methods

- (void)allowableActionsParser:(CMISAtomPubAllowableActionsParser *)parser didFinishParsingAllowableActions:(CMISAllowableActions *)allowableActions
{
    self.objectData.allowableActions = allowableActions;
}

#pragma mark - CMISAclParserDelegate Methods
-(void)aclParser:(CMISAtomPubAclParser *)aclParser didFinishParsingAcl:(CMISAcl *)acl{
    self.objectData.acl = acl;
    [self.objectData.acl setIsExact:self.isExcatAcl];
}

@end
