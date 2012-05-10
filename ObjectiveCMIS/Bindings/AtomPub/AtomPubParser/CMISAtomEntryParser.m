//
//  CMISAtomEntryParser.m
//  HybridApp
//
//  Created by Cornwell Gavin on 29/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAtomEntryParser.h"
#import "CMISAllowableActions.h"

@interface CMISAtomEntryParser ()

@property (nonatomic, strong, readwrite) CMISObjectData *objectData;

@property (nonatomic, strong) NSData *atomData;
@property (nonatomic, strong) NSString *elementBeingParsed;
@property (nonatomic, strong) CMISPropertyData *currentPropertyData;
@property (nonatomic, strong) CMISProperties *currentObjectProperties;
// Properties used if child parser
@property (nonatomic, weak) id<NSXMLParserDelegate> childParserDelegate;
@property (nonatomic, weak) id<NSXMLParserDelegate, CMISAtomEntryParserDelegate> parentDelegate;
@property (nonatomic, strong) NSDictionary *entryAttributesDict;

- (id)initWithAtomEntryAttributes:(NSDictionary *)attributes parentDelegate:(id<NSXMLParserDelegate, CMISAtomEntryParserDelegate>)parentDelegate parser:(NSXMLParser *)parser;
@end


@implementation CMISAtomEntryParser

@synthesize objectData = _objectData;
@synthesize atomData = _atomData;
@synthesize elementBeingParsed = _elementBeingParsed;
@synthesize currentPropertyData = _currentPropertyData;
@synthesize currentObjectProperties = _currentObjectProperties;
@synthesize childParserDelegate = _childParserDelegate;
@synthesize parentDelegate = _parentDelegate;
@synthesize entryAttributesDict = _entryAttributesDict;

- (id)initWithData:(NSData *)atomData
{
    self = [super init];
    if (self)
    {
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
    
    if (!parseSuccessful)
    {
        *error = [parser parserError];
    }
    
    return parseSuccessful;
}

- (id)initWithAtomEntryAttributes:(NSDictionary *)attributes parentDelegate:(id<NSXMLParserDelegate, CMISAtomEntryParserDelegate>)parentDelegate parser:(NSXMLParser *)parser
{
    self = [self initWithData:nil];
    if (self)
    {
        self.objectData = [[CMISObjectData alloc] init];
        self.entryAttributesDict = attributes;
        self.parentDelegate = parentDelegate;
        
        // Setting ourself, the entry parser, as the delegate, we reset back to our parent when we're done
        [parser setDelegate:self];
    }
    return self;
}

+ (id)atomEntryParserWithAtomEntryAttributes:(NSDictionary *)attributes parentDelegate:(id<NSXMLParserDelegate,CMISAtomEntryParserDelegate>)parentDelegate parser:(NSXMLParser *)parser
{
    return [[self alloc] initWithAtomEntryAttributes:attributes parentDelegate:parentDelegate parser:parser];
}

#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
{
    self.elementBeingParsed = elementName;
    
    if ([self.elementBeingParsed isEqualToString:kCMISAtomEntryPropertyId] ||
        [self.elementBeingParsed isEqualToString:kCMISAtomEntryPropertyString] ||
        [self.elementBeingParsed isEqualToString:kCMISAtomEntryPropertyDateTime])
    {
        // store attribute values in CMISPropertyData object
        self.currentPropertyData = [[CMISPropertyData alloc] init];
        self.currentPropertyData.identifier = [attributeDict objectForKey:kCMISAtomEntryPropertyDefId];
        self.currentPropertyData.queryName = [attributeDict objectForKey:kCMISAtomEntryQueryName];
        self.currentPropertyData.displayName = [attributeDict objectForKey:kCMISAtomEntryDisplayName];
    }
    else if ([self.elementBeingParsed isEqualToString:kCMISAtomEntryObject])
    {
        // create the CMISProperties object to hold all property data
        self.currentObjectProperties = [[CMISProperties alloc] init];
    }
    else if ([self.elementBeingParsed isEqualToString:kCMISAtomEntryLink])
    {
        // TODO: this is quick-and-dirty parsing for the 'down' link
        NSString *linkType = [attributeDict objectForKey:kCMISAtomEntryType];
        NSString *rel = [attributeDict objectForKey:kCMISAtomEntryRel];
        if (linkType != nil
            && [linkType isEqualToString:kCMISMediaTypeChildren]
            && rel != nil
            && [rel isEqualToString:@"down"])
        {
            if (self.objectData.links == nil)
            {
                self.objectData.links = [[NSMutableDictionary alloc] init];
            }
            
            
            [self.objectData.links setObject:[attributeDict objectForKey:kCMISAtomEntryHref] forKey:rel];
        }
        
        
        // TODO: Quick-hack to get service url
        if (rel != nil && [rel isEqualToString:@"service"])
        {
            if (self.objectData.links == nil)
            {
                self.objectData.links = [[NSMutableDictionary alloc] init];
            }
            [self.objectData.links setObject:[attributeDict objectForKey:kCMISAtomEntryHref] forKey:@"service"];
        }
    }
    else if ([self.elementBeingParsed isEqualToString:@"content"])
    {
        self.objectData.contentUrl = [NSURL URLWithString:[attributeDict objectForKey:@"src"]];
    }
    else if ([self.elementBeingParsed isEqualToString:kCMISAtomEntryAllowableActions]) 
    {
        // Delegate parsing to child parser for allowableActions element
        self.childParserDelegate = [CMISAllowableActionsParser allowableActionsParserWithParentDelegate:self parser:parser];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string 
{
    if ([self.elementBeingParsed isEqualToString:kCMISAtomEntryValue])
    {
        // TODO: Deal with multi-valued properties
        
        // add the value to the current property
        self.currentPropertyData.values = [NSArray arrayWithObject:string];
    }
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
    if ([elementName isEqualToString:kCMISAtomEntryPropertyId] ||
        [elementName isEqualToString:kCMISAtomEntryPropertyString] ||
        [elementName isEqualToString:kCMISAtomEntryPropertyDateTime])
    {
        // TODO: distinguish between core CMIS properties and ExtensionData properties
        
        // add the property to the properties dictionary
        [self.currentObjectProperties addProperty:self.currentPropertyData];
        self.currentPropertyData = nil;
    }
    else if ([elementName isEqualToString:kCMISAtomEntryObject])
    {
        // set the properties on the objectData object
        self.objectData.properties = self.currentObjectProperties;
        
        // set the objectData identifier
        CMISPropertyData *objectId = [self.currentObjectProperties.properties objectForKey:kCMISAtomEntryObjectId];
        self.objectData.identifier = [objectId firstValue];
        
        // set the objectData baseType
        CMISPropertyData *baseTypeProperty = [self.currentObjectProperties.properties objectForKey:kCMISAtomEntryBaseTypeId];
        NSString *baseType = [baseTypeProperty firstValue];
        if ([baseType isEqualToString:@"cmis:document"])
        {
            self.objectData.baseType = CMISBaseTypeDocument;
        }
        else if ([baseType isEqualToString:@"cmis:folder"])
        {
            self.objectData.baseType = CMISBaseTypeFolder;
        }
        
        self.currentObjectProperties = nil;
    }
    else if ([elementName isEqualToString:kCMISAtomEntryAllowableActions]) 
    {
        self.childParserDelegate = nil;
    }
    else if (self.parentDelegate && [elementName isEqualToString:@"entry"])
    {
        if ([self.parentDelegate respondsToSelector:@selector(cmisAtomEntryParser:didFinishParsingCMISObjectData:)])
        {
            // Message the parent delegate the parsed ObjectData
            [self.parentDelegate performSelector:@selector(cmisAtomEntryParser:didFinishParsingCMISObjectData:) 
                                      withObject:self withObject:self.objectData];
        }
        
        // Reseting our parent as the delegate since we're done
        [parser setDelegate:self.parentDelegate];
        
        // Message the parent that the element ended
        [self.parentDelegate parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
        self.parentDelegate = nil;
    }
    
    self.elementBeingParsed = nil;
}

#pragma mark -
#pragma mark CMISAllowableActionsParserDelegate Methods

- (void)allowableActionsParser:(CMISAllowableActionsParser *)parser didFinishParsingAllowableActionsDict:(NSDictionary *)allowableActionsDict
{
    self.objectData.allowableActions = [[CMISAllowableActions alloc] initWithAllowableActionsDictionary:allowableActionsDict];
}

@end
