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
@property (nonatomic, weak) id childParserDelegate;
@end

@implementation CMISAtomFeedParser

@synthesize feedData = _feedData;
@synthesize internalEntries = _internalEntries;
@synthesize elementBeingParsed = _elementBeingParsed;
@synthesize childParserDelegate = _childParserDelegate;

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
    
    if ([self.elementBeingParsed isEqualToString:@"entry"])
    {
        // Delegate parsing of AtomEntry element to the entry child parser
        self.childParserDelegate = [CMISAtomEntryParser atomEntryParserWithAtomEntryAttributes:attributeDict parentDelegate:self parser:parser];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string 
{
    // Nothing to do here ...
    // TODO Remove method if we're not going to parse anything else
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
   if ([elementName isEqualToString:@"entry"])
    {
        self.childParserDelegate = nil;
    }
    
    self.elementBeingParsed = nil;
}


#pragma mark -
#pragma mark CMISAtomEntryParserDelegate Methods

- (void)cmisAtomEntryParser:(CMISAtomEntryParser *)entryParser didFinishParsingCMISObjectData:(CMISObjectData *)cmisObjectData
{
    [self.internalEntries addObject:cmisObjectData];
}

@end
