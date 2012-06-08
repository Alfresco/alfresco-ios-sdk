//
//  CMISAtomEntryParser.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 29/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAtomEntryParser.h"
#import "CMISISO8601DateFormatter.h"
#import "CMISAtomLink.h"
#import "CMISRenditionData.h"

@interface CMISAtomEntryParser ()

@property (nonatomic, strong, readwrite) CMISObjectData *objectData;

@property (nonatomic, strong) NSData *atomData;
@property (nonatomic, strong) NSString *elementBeingParsed;
@property (nonatomic, strong) NSString *currentPropertyType;
@property (nonatomic, strong) CMISPropertyData *currentPropertyData;
@property (nonatomic, strong) CMISProperties *currentObjectProperties;
@property (nonatomic, strong) NSMutableSet *currentLinkRelations;
@property (nonatomic, strong) CMISRenditionData *currentRendition;
@property (nonatomic, strong) NSMutableArray *currentRenditions;

@property (nonatomic, strong) NSMutableArray *currentExtensions;
@property (nonatomic, strong) CMISExtensionData *currentExtensionData;
@property (nonatomic, strong) NSMutableArray *previousExtensionDataArray;

@property (nonatomic, strong) CMISISO8601DateFormatter *dateFormatter;

// Properties used if child parser
@property (nonatomic, weak) id<NSXMLParserDelegate> childParserDelegate;
@property (nonatomic, weak) id<NSXMLParserDelegate, CMISAtomEntryParserDelegate> parentDelegate;
@property (nonatomic, strong) NSDictionary *entryAttributesDict;

// Designated initializer
- (id)init;
// Initializer used if this parser is a delegated child parser
- (id)initWithAtomEntryAttributes:(NSDictionary *)attributes parentDelegate:(id<NSXMLParserDelegate, CMISAtomEntryParserDelegate>)parentDelegate parser:(NSXMLParser *)parser;

// Saves the current extensionData and extensions state and sets the messaged object as the new current extensionData object
- (void)pushNewCurrentExtensionData:(CMISExtensionData *)extensionDataObject;
//  Saves the current extensions on the extensionData object and makes the previous extensionData and extensions the current objects
- (void)saveCurrentExtensionsAndPushPreviousExtensionData;
@end


@implementation CMISAtomEntryParser

@synthesize objectData = _objectData;
@synthesize atomData = _atomData;
@synthesize elementBeingParsed = _elementBeingParsed;
@synthesize currentPropertyType = _currentPropertyType;
@synthesize currentPropertyData = _currentPropertyData;
@synthesize currentObjectProperties = _currentObjectProperties;
@synthesize currentLinkRelations = _currentLinkRelations;
@synthesize currentExtensions = _currentExtensions;
@synthesize currentExtensionData = _currentExtensionData;
@synthesize previousExtensionDataArray = _previousExtensionDataArray;
@synthesize dateFormatter = _dateFormatter;
@synthesize childParserDelegate = _childParserDelegate;
@synthesize parentDelegate = _parentDelegate;
@synthesize entryAttributesDict = _entryAttributesDict;
@synthesize currentRendition = _currentRendition;
@synthesize currentRenditions = _currentRenditions;

// Designated Initializer
- (id)init
{
    self = [super init];
    if (self)
    {
        self.currentLinkRelations = [NSMutableSet set];
        self.previousExtensionDataArray = [NSMutableArray array];
    }
    return self;
}

- (id)initWithData:(NSData *)atomData
{
    self = [self init];
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
    self = [self init];
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
    self.elementBeingParsed = elementName;
    
    if ([namespaceURI isEqualToString:kCMISNamespaceCmis])
    {
        if ([elementName isEqualToString:kCMISAtomEntryPropertyId] ||
            [elementName isEqualToString:kCMISAtomEntryPropertyString] ||
            [elementName isEqualToString:kCMISAtomEntryPropertyInteger] ||
            [elementName isEqualToString:kCMISAtomEntryPropertyDateTime] ||
            [elementName isEqualToString:kCMISAtomEntryPropertyBoolean])
        {
            // store attribute values in CMISPropertyData object
            self.currentPropertyType = elementName;
            self.currentPropertyData = [[CMISPropertyData alloc] init];
            self.currentPropertyData.identifier = [attributeDict objectForKey:kCMISAtomEntryPropertyDefId];
            self.currentPropertyData.queryName = [attributeDict objectForKey:kCMISAtomEntryQueryName];
            self.currentPropertyData.displayName = [attributeDict objectForKey:kCMISAtomEntryDisplayName];
        }
        else if ([elementName isEqualToString:kCMISCoreProperties])
        {
            // create the CMISProperties object to hold all property data
            self.currentObjectProperties = [[CMISProperties alloc] init];
            
            // Set ObjectProperties as the current extensionData object
            [self pushNewCurrentExtensionData:self.currentObjectProperties];
        }
        else if ([elementName isEqualToString:kCMISCoreRendition])
        {
            self.currentRendition = [[CMISRenditionData alloc] init];
        }
        else if ([elementName isEqualToString:kCMISAtomEntryAllowableActions]) 
        {
            // Delegate parsing to child parser for allowableActions element
            self.childParserDelegate = [CMISAllowableActionsParser allowableActionsParserWithParentDelegate:self parser:parser];
        }
    }
    else if ([namespaceURI isEqualToString:kCMISNamespaceCmisRestAtom])
    {
        if ([elementName isEqualToString:kCMISAtomEntryObject])
        {
            // Set object data as the current extensionData object
            [self pushNewCurrentExtensionData:self.objectData];
        }
    }
    else if ([namespaceURI isEqualToString:kCMISNamespaceAtom])
    {
        if ([elementName isEqualToString:kCMISAtomEntryLink])
        {
            NSString *linkType = [attributeDict objectForKey:kCMISAtomEntryType];
            NSString *rel = [attributeDict objectForKey:kCMISAtomEntryRel];
            NSString *href = [attributeDict objectForKey:kCMISAtomEntryHref]; 
            
            CMISAtomLink *link = [[CMISAtomLink alloc] initWithRelation:rel type:linkType href:href];
            [self.currentLinkRelations addObject:link];
        }
        else if ([elementName isEqualToString:kCMISAtomEntryContent])
        {
            self.objectData.contentUrl = [NSURL URLWithString:[attributeDict objectForKey:kCMISAtomEntrySrc]];
        }
    }
    else if ([namespaceURI isEqualToString:kCMISNamespaceApp])
    {
        // Nothing to do in this namespace
    }
    else 
    {
        if (self.currentExtensionData != nil)
        {
            self.childParserDelegate = [CMISAtomPubExtensionElementParser extensionElementParserWithElementName:elementName namespaceUri:namespaceURI 
                                                                                                     attributes:attributeDict parentDelegate:self parser:parser];
        }
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
                self.dateFormatter = [[CMISISO8601DateFormatter alloc] init];
            }
            self.currentPropertyData.values = [NSArray arrayWithObject:[self.dateFormatter dateFromString:string]];
        }
    }
    else if (self.currentRendition != nil)
    {
        if ([self.elementBeingParsed isEqualToString:kCMISCoreStreamId])
        {
            self.currentRendition.streamId = string;
        }
        else if ([self.elementBeingParsed isEqualToString:kCMISCoreMimetype])
        {
            self.currentRendition.mimeType = string;
        }
        else if ([self.elementBeingParsed isEqualToString:kCMISCoreLength])
        {
            self.currentRendition.length = [NSNumber numberWithInteger:[string integerValue]];
        }
        else if ([self.elementBeingParsed isEqualToString:kCMISCoreTitle])
        {
            self.currentRendition.title = string;
        }
        else if ([self.elementBeingParsed isEqualToString:kCMISCoreKind])
        {
            self.currentRendition.kind = string;
        }
        else if ([self.elementBeingParsed isEqualToString:kCMISCoreHeight])
        {
            self.currentRendition.height = [NSNumber numberWithInteger:[string integerValue]];
        }
        else if ([self.elementBeingParsed isEqualToString:kCMISCoreWidth])
        {
            self.currentRendition.width = [NSNumber numberWithInteger:[string integerValue]];
        }
        else if ([self.elementBeingParsed isEqualToString:kCMISCoreRenditionDocumentId])
        {
            self.currentRendition.renditionDocumentId = string;
        }
    }
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
    
    if ([namespaceURI isEqualToString:kCMISNamespaceCmis])
    {
        if ([elementName isEqualToString:kCMISAtomEntryPropertyId] ||
            [elementName isEqualToString:kCMISAtomEntryPropertyString] ||
            [elementName isEqualToString:kCMISAtomEntryPropertyInteger] ||
            [elementName isEqualToString:kCMISAtomEntryPropertyDateTime] ||
            [elementName isEqualToString:kCMISAtomEntryPropertyBoolean])
        {            
            // add the property to the properties dictionary
            [self.currentObjectProperties addProperty:self.currentPropertyData];
            self.currentPropertyData = nil;
        }
        else if ([elementName isEqualToString:kCMISCoreProperties])
        {
            // Finished parsing Properties & its ExtensionData
            [self saveCurrentExtensionsAndPushPreviousExtensionData];
        }
        else if ([elementName isEqualToString:kCMISCoreRendition])
        {
            if (self.currentRenditions == nil)
            {
                self.currentRenditions = [[NSMutableArray alloc] init];
            }
            [self.currentRenditions addObject:self.currentRendition];
            self.currentRendition = nil;
        }
    }
    else if ([namespaceURI isEqualToString:kCMISNamespaceCmisRestAtom])
    {
        if ([elementName isEqualToString:kCMISAtomEntryObject])
        {
            // set the properties on the objectData object
            self.objectData.properties = self.currentObjectProperties;
            
            // set the link relations on the objectData object
            self.objectData.linkRelations = [[CMISLinkRelations alloc] initWithLinkRelationSet:[self.currentLinkRelations copy]];

            // set the renditions on the objectData object
            self.objectData.renditions = self.currentRenditions;
            
            // set the objectData identifier
            CMISPropertyData *objectId = [self.currentObjectProperties.propertiesDictionary objectForKey:kCMISAtomEntryObjectId];
            self.objectData.identifier = [objectId firstValue];
            
            // set the objectData baseType
            CMISPropertyData *baseTypeProperty = [self.currentObjectProperties.propertiesDictionary objectForKey:kCMISAtomEntryBaseTypeId];
            NSString *baseType = [baseTypeProperty firstValue];
            if ([baseType isEqualToString:kCMISAtomEntryBaseTypeDocument])
            {
                self.objectData.baseType = CMISBaseTypeDocument;
            }
            else if ([baseType isEqualToString:kCMISAtomEntryBaseTypeFolder])
            {
                self.objectData.baseType = CMISBaseTypeFolder;
            }
            
            // set the extensionData
            [self saveCurrentExtensionsAndPushPreviousExtensionData];
            
            self.currentObjectProperties = nil;
        }
    }
    else if ([namespaceURI isEqualToString:kCMISNamespaceAtom])
    {
        if (self.parentDelegate && [elementName isEqualToString:kCMISAtomEntry])
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
    }
    else if ([namespaceURI isEqualToString:kCMISNamespaceApp])
    {
        // Nothing to do in this namespace
    }
    else 
    {
        // TODO other namespaces?
    }
    
    self.elementBeingParsed = nil;
}

#pragma mark -
#pragma mark Private Methods

- (void)pushNewCurrentExtensionData:(CMISExtensionData *)extensionDataObject
{
    // Save the current state of the extensionData objects used for parsing
    if (self.currentExtensionData)
    {
        if (self.currentExtensions)
        {
            self.currentExtensionData.extensions = [self.currentExtensions copy];
        }
        
        [self.previousExtensionDataArray addObject:self.currentExtensionData];
    }
    
    // Set the new extensionData object provided to be the current
    self.currentExtensionData = extensionDataObject;
    // extensions are nil'ed out since we have a new extensionData object
    self.currentExtensions = nil;
}

- (void)saveCurrentExtensionsAndPushPreviousExtensionData
{
    // set the current extensions 
    self.currentExtensionData.extensions = [self.currentExtensions copy];
    self.currentExtensionData = nil;
    
    // set the previous extensionData object, note - we don't mind that the return values are nil
    self.currentExtensionData = self.previousExtensionDataArray.lastObject;
    self.currentExtensions = [self.currentExtensionData.extensions mutableCopy];
    
    // if previous actually existed, remvoe last object
    if (self.currentExtensionData)
    {
        [self.previousExtensionDataArray removeLastObject];
    }
}

#pragma mark -
#pragma mark CMISAllowableActionsParserDelegate Methods

- (void)allowableActionsParser:(CMISAllowableActionsParser *)parser didFinishParsingAllowableActions:(CMISAllowableActions *)allowableActions
{
    self.objectData.allowableActions = allowableActions;

    self.childParserDelegate = nil;
}

#pragma mark -
#pragma mark CMISAtomPubExtensionElementParserDelegate Method

- (void)extensionElementParser:(CMISAtomPubExtensionElementParser *)parser didFinishParsingExtensionElement:(CMISExtensionElement *)extensionElement
{
    // TODO Should abstract the ExtensionData parsing as this pattern is repeated everywhere ExtensionData is getting parsed.
    
    if (self.currentExtensions == nil)
    {
        self.currentExtensions = [[NSMutableArray alloc] init];
    }
    
    [self.currentExtensions addObject:extensionElement];

    self.childParserDelegate = nil;
}

@end
