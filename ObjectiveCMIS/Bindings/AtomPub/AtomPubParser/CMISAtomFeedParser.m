//
//  CMISAtomFeedParser.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 11/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAtomFeedParser.h"

@interface CMISAtomFeedParser ()
@property (nonatomic, strong) NSData *feedData;
@property (nonatomic, strong) NSMutableArray *internalEntries;
@property (nonatomic, strong) NSString *elementBeingParsed;
@property (nonatomic, strong) CMISPropertyData *currentPropertyData;
@property (nonatomic, strong) CMISProperties *currentObjectProperties;
@property (nonatomic, strong) CMISObjectData *currentObjectData;
@end

@implementation CMISAtomFeedParser

@synthesize feedData = _feedData;
@synthesize internalEntries = _internalEntries;
@synthesize elementBeingParsed = _elementBeingParsed;
@synthesize currentPropertyData = _currentPropertyData;
@synthesize currentObjectProperties = _currentObjectProperties;
@synthesize currentObjectData = _currentObjectData;

- (id)initWithData:(NSData*)feedData
{
    if (self = [super init]) 
    {
        self.feedData = feedData;
    }
    
    return self;
}

- (NSArray *)entries
{
    if (self.internalEntries != nil)
    {
        return [NSArray arrayWithArray:self.internalEntries];
    }
    else 
    {
        return nil;
    }
}

- (BOOL)parseAndReturnError:(NSError **)error;
{
    BOOL parseSuccessful = YES;
    
    // create objects to populate during parse
    self.internalEntries = [NSMutableArray array];
    
    // parse the AtomPub data
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.feedData];
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
//    else if ([self.elementBeingParsed isEqualToString:kCMISAtomEntryObject])
    // [JORAM]: links are part of entry, not of object...
    else if ([self.elementBeingParsed isEqualToString:@"entry"])
    {
        // create the current object data object
        self.currentObjectData = [[CMISObjectData alloc] init];
        
        // create the CMISProperties object to hold all property data
        self.currentObjectProperties = [[CMISProperties alloc] init];
    }
    else if ([self.elementBeingParsed isEqualToString:kCMISAtomEntryLink])
    {
          // TODO: this is quick-and-dirty parsing for the 'down' link
        NSString *linkType = [attributeDict objectForKey:@"type"];
        NSString *rel = [attributeDict objectForKey:kCMISAtomEntryRel];
        if (linkType != nil
                && [linkType isEqualToString:@"application/atom+xml;type=feed"]
                && rel != nil
                && [rel isEqualToString:@"down"])
        {

            if (self.currentObjectData.links == nil)
            {
                self.currentObjectData.links = [[NSMutableDictionary alloc] init];
            }

            [self.currentObjectData.links setObject:[attributeDict objectForKey:kCMISAtomEntryHref] forKey:@"down"];
        }


        // TODO: Quick-hack to get service url
        if (rel != nil && [rel isEqualToString:@"service"])
        {
            if (self.currentObjectData.links == nil)
            {
                self.currentObjectData.links = [[NSMutableDictionary alloc] init];
            }
            [self.currentObjectData.links setObject:[attributeDict objectForKey:kCMISAtomEntryHref] forKey:@"service"];
        }
    } else if ([self.elementBeingParsed isEqualToString:@"content"])
    {
        self.currentObjectData.contentUrl = [NSURL URLWithString:[attributeDict objectForKey:@"src"]];
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
        self.currentObjectData.properties = self.currentObjectProperties;
        
        // set the objectData identifier
        CMISPropertyData *objectId = [self.currentObjectProperties.properties objectForKey:kCMISAtomEntryObjectId];
        self.currentObjectData.identifier = [objectId firstValue];
        
        // set the objectData baseType
        CMISPropertyData *baseTypeProperty = [self.currentObjectProperties.properties objectForKey:kCMISAtomEntryBaseTypeId];
        NSString *baseType = [baseTypeProperty firstValue];
        if ([baseType isEqualToString:@"cmis:document"])
        {
            self.currentObjectData.baseType = CMISBaseTypeDocument;
        }
        else if ([baseType isEqualToString:@"cmis:folder"])
        {
            self.currentObjectData.baseType = CMISBaseTypeFolder;
        }
        
        // add the currentObjectData object to the entries array
        [self.internalEntries addObject:self.currentObjectData];
        
        self.currentObjectProperties = nil;
        self.currentObjectData = nil;
    }
    
    self.elementBeingParsed = nil;
}

@end
