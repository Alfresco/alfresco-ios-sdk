//
//  CMISAtomPubExtensionElementParser.m
//  ObjectiveCMIS
//
//  Created by Gi Lee on 5/21/12.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAtomPubExtensionElementParser.h"


@interface CMISAtomPubExtensionElementParser ()

// Properties used for Parsing
@property (nonatomic, weak) id<NSXMLParserDelegate, CMISAtomPubExtensionElementParserDelegate> childDelegate;
@property (nonatomic, weak) id<NSXMLParserDelegate, CMISAtomPubExtensionElementParserDelegate> parentDelegate;

// ExtensionElement properties
@property (nonatomic, strong) NSString *extensionName;
@property (nonatomic, strong) NSString *extensionNamespaceUri;
@property (nonatomic, strong) NSString *extensionValue;
@property (nonatomic, strong) NSDictionary *extensionAttributes;
@property (nonatomic, strong) NSMutableArray *extensionChildren;

/// Designated Initializer
- (id)initWithElementName:(NSString *)elementName namespaceUri:(NSString *)namespaceUri attributes:(NSDictionary *)attributes parentDelegate:(id<NSXMLParserDelegate, CMISAtomPubExtensionElementParserDelegate>)parentDelegate parser:(NSXMLParser *)parser;
@end

@implementation CMISAtomPubExtensionElementParser

@synthesize childDelegate = _childDelegate;
@synthesize parentDelegate = _parentDelegate;
@synthesize extensionName = _extensionName;
@synthesize extensionNamespaceUri = _extensionNamespaceUri;
@synthesize extensionValue = _extensionValue;
@synthesize extensionAttributes = _extensionAttributes;
@synthesize extensionChildren = _extensionChildren;

#pragma mark -
#pragma mark Initializers

- (id)initWithElementName:(NSString *)elementName namespaceUri:(NSString *)namespaceUri attributes:(NSDictionary *)attributes parentDelegate:(id<NSXMLParserDelegate, CMISAtomPubExtensionElementParserDelegate>)parentDelegate parser:(NSXMLParser *)parser
{
    self = [super init];
    if (self)
    {
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
    self.extensionValue = string;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:self.extensionName] && [namespaceURI isEqualToString:self.extensionNamespaceUri])
    {
        CMISExtensionElement *extElement = nil;
        if ([self.extensionChildren count] > 0)
        {
            extElement = [[CMISExtensionElement alloc] initNodeWithName:self.extensionName 
                                                           namespaceUri:self.extensionNamespaceUri 
                                                             attributes:self.extensionAttributes 
                                                               children:self.extensionChildren];
        }
        else 
        {
            extElement = [[CMISExtensionElement alloc] initLeafWithName:self.extensionName 
                                                           namespaceUri:self.extensionNamespaceUri 
                                                             attributes:self.extensionAttributes 
                                                                  value:self.extensionValue];
        }
        [self.parentDelegate extensionElementParser:self didFinishParsingExtensionElement:extElement];
        
        [parser setDelegate:self.parentDelegate];
        [self.parentDelegate parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
        self.parentDelegate = nil;
    }
    else 
    {
        self.childDelegate = nil;
    }
}

#pragma mark -
#pragma mark CMISAtomPubExtensionElementParser

- (void)extensionElementParser:(CMISAtomPubExtensionElementParser *)parser didFinishParsingExtensionElement:(CMISExtensionElement *)extensionElement
{
    if (self.extensionChildren == nil)
    {
        self.extensionChildren = [[NSMutableArray alloc] init];
    }
    
    [self.extensionChildren addObject:extensionElement];
}

@end
