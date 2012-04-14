//
//  CMISAtomEntryParser.m
//  HybridApp
//
//  Created by Cornwell Gavin on 29/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAtomEntryParser.h"

@interface CMISAtomEntryParser ()
@property (nonatomic, strong, readwrite) NSDictionary *links;
@property (nonatomic, strong, readwrite) CMISObjectData *objectData;

@property (nonatomic, strong) NSData *atomData;
@property (nonatomic, strong) NSString *elementBeingParsed;
@property (nonatomic, strong) CMISPropertyData *currentPropertyData;
@property (nonatomic, strong) CMISProperties *currentObjectProperties;
@end


@implementation CMISAtomEntryParser

@synthesize links = _links;
@synthesize objectData = _objectData;
@synthesize atomData = _atomData;
@synthesize elementBeingParsed = _elementBeingParsed;
@synthesize currentPropertyData = _currentPropertyData;
@synthesize currentObjectProperties = _currentObjectProperties;

- (id)initWithData:(NSData*)atomData
{
    if (self = [super init]) 
    {
        self.atomData = atomData;
    }
    
    return self;
}

- (BOOL)parseAndReturnError:(NSError **)error;
{
    BOOL parseSuccessful = YES;
    
    // create objects to populate during parse
    self.links = [NSMutableDictionary dictionary];
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
        // TODO: define interface for a link, parse link elements and add to dictionary
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
    
    self.elementBeingParsed = nil;
}

@end
