//
//  CMISAtomEntryParser.m
//  HybridApp
//
//  Created by Cornwell Gavin on 29/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAtomEntryParser.h"
#import "CMISAllowableActions.h"
#import "ISO8601DateFormatter.h"

@interface CMISAtomEntryParser ()

@property (nonatomic, weak) id<NSXMLParserDelegate, CMISAtomEntryParserDelegate> parentDelegate;

@property (nonatomic, strong, readwrite) CMISObjectData *objectData;
@property (nonatomic, strong) NSData *atomData;
@property (nonatomic, strong) NSString *currentPropertyType;
@property (nonatomic, strong) NSString *elementBeingParsed;
@property (nonatomic, strong) CMISPropertyData *currentPropertyData;
@property (nonatomic, strong) CMISProperties *currentObjectProperties;

@property (nonatomic, strong) ISO8601DateFormatter *dateFormatter;
@property (nonatomic, weak) id<NSXMLParserDelegate> childParserDelegate;

// Private Init Used for child delegate parser
- (id)initWithParentDelegate:(id<NSXMLParserDelegate, CMISAtomEntryParserDelegate>)parentDelegate parser:(NSXMLParser *)parser;

@end


@implementation CMISAtomEntryParser

@synthesize parentDelegate = _parentDelegate;
@synthesize objectData = _objectData;
@synthesize atomData = _atomData;
@synthesize elementBeingParsed = _elementBeingParsed;
@synthesize currentPropertyData = _currentPropertyData;
@synthesize currentObjectProperties = _currentObjectProperties;
@synthesize childParserDelegate = _childParserDelegate;
@synthesize dateFormatter = _dateFormatter;
@synthesize currentPropertyType = _currentPropertyType;


- (id)initWithData:(NSData*)atomData
{
    self = [super init];
    if (self)
    {
        self.atomData = atomData;
    }
    
    return self;
}

- (id)initWithParentDelegate:(id <NSXMLParserDelegate, CMISAtomEntryParserDelegate>)parentDelegate parser:(NSXMLParser *)parser
{
    self = [self init];
    if (self)
    {
        [self setParentDelegate:parentDelegate];
        self.objectData = [[CMISObjectData alloc] init];

        // Setting Child Parser Delegate, parser events will now be captured by this class
        [parser setDelegate:self];
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

#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
{
    self.elementBeingParsed = elementName;
    
    if ([self.elementBeingParsed isEqualToString:kCMISAtomEntryPropertyId] ||
        [self.elementBeingParsed isEqualToString:kCMISAtomEntryPropertyString] ||
        [self.elementBeingParsed isEqualToString:kCMISAtomEntryPropertyInteger] ||
        [self.elementBeingParsed isEqualToString:kCMISAtomEntryPropertyDateTime] ||
        [self.elementBeingParsed isEqualToString:kCMISAtomEntryPropertyBoolean])
    {
        // store attribute values in CMISPropertyData object
        self.currentPropertyType = self.elementBeingParsed;
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
        // TODO: this is quick-and-dirty parsing
        NSString *linkType = [attributeDict objectForKey:kCMISAtomEntryType];
        NSString *rel = [attributeDict objectForKey:kCMISAtomEntryRel];

        if (linkType == nil || (linkType != nil && [linkType isEqualToString:kCMISAtomEntryLinkTypeAtomFeed]))
        {

            if (self.objectData.links == nil)
            {
                self.objectData.links = [[NSMutableDictionary alloc] init];
            }

            [self.objectData.links setObject:[attributeDict objectForKey:kCMISAtomEntryHref] forKey:rel];
        }

    }
    else if ([self.elementBeingParsed isEqualToString:kCMISAtomEntryContent])
    {
        self.objectData.contentUrl = [NSURL URLWithString:[attributeDict objectForKey:kCMISAtomEntrySrc]];
    }
    else if ([self.elementBeingParsed isEqualToString:kCMISAtomEntryAllowableActions])
    {
        self.childParserDelegate = [CMISAllowableActionsParser parent:self parser:parser];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string 
{
    if ([self.elementBeingParsed isEqualToString:kCMISAtomEntryValue])
    {
        // TODO: Deal with multi-valued properties
        
        // add the value to the current property
        if ([self.currentPropertyType isEqualToString:kCMISAtomEntryPropertyString] ||
                [self.currentPropertyType isEqualToString:kCMISAtomEntryPropertyId])
        {
            self.currentPropertyData.values = [NSArray arrayWithObject:string];
        }
        else if ([self.currentPropertyType isEqualToString:kCMISAtomEntryPropertyInteger])
        {
            self.currentPropertyData.values = [NSArray arrayWithObject:[NSNumber numberWithInt:[string intValue]]];
        }
        else if ([self.currentPropertyType isEqualToString:kCMISAtomEntryPropertyBoolean])
        {
            self.currentPropertyData.values = [NSArray arrayWithObject:[NSNumber numberWithBool:[string isEqualToString:kCMISAtomEntryValueTrue]]];
        }
        else if ([self.currentPropertyType isEqualToString:kCMISAtomEntryPropertyDateTime])
        {
            if (!self.dateFormatter)
            {
                self.dateFormatter = [[ISO8601DateFormatter alloc] init];
            }
            self.currentPropertyData.values = [NSArray arrayWithObject:[self.dateFormatter dateFromString:string]];
        }
    }
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
    if ([elementName isEqualToString:kCMISAtomEntry])
    {
        if (self.parentDelegate)
        {
            if ([self.parentDelegate respondsToSelector:@selector(atomEntryParserDidFinish:)])
            {
                [self.parentDelegate performSelector:@selector(atomEntryParserDidFinish:) withObject:self];
            }

            // Reset Delegate to parent, now funneling events to the parent again
            [parser setDelegate:self.parentDelegate];
            // Message the parent that the element ended
            [self.parentDelegate parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];

            self.parentDelegate = nil;
        }
    }
    else if ([elementName isEqualToString:kCMISAtomEntryPropertyId] ||
        [elementName isEqualToString:kCMISAtomEntryPropertyString] ||
        [elementName isEqualToString:kCMISAtomEntryPropertyInteger] ||
        [elementName isEqualToString:kCMISAtomEntryPropertyDateTime] ||
        [elementName isEqualToString:kCMISAtomEntryPropertyBoolean])
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
        if ([baseType isEqualToString:kCMISAtomEntryBaseTypeDocument])
        {
            self.objectData.baseType = CMISBaseTypeDocument;
        }
        else if ([baseType isEqualToString:kCMISAtomEntryBaseTypeFolder])
        {
            self.objectData.baseType = CMISBaseTypeFolder;
        }
        
        self.currentObjectProperties = nil;
    }
    else if ([elementName isEqualToString:kCMISAtomEntryAllowableActions]) 
    {
        self.childParserDelegate = nil;
    }
    
    self.elementBeingParsed = nil;
}

#pragma mark -
#pragma mark CMISAllowableActionsParserDelegate Methods
- (void)allowableActionsParserDidFinish:(CMISAllowableActionsParser *)parser
{
    NSDictionary *parsedAllowableActionsDict = [parser allowableActionsArray];
    self.objectData.allowableActions = [[CMISAllowableActions alloc] initWithAllowableActionsDictionary:parsedAllowableActionsDict];
}

#pragma mark Parser delegation

+ (id)delegateToAtomEntryParserFrom:(id <NSXMLParserDelegate, CMISAtomEntryParserDelegate>)parentParserDelegate withParser:(NSXMLParser *)parser
{
    return [[[self class] alloc] initWithParentDelegate:parentParserDelegate parser:parser];
}


@end
