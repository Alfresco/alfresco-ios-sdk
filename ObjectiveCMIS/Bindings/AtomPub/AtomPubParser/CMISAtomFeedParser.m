/*
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
 */

#import "CMISAtomFeedParser.h"
#import "CMISAtomLink.h"

@interface CMISAtomFeedParser ()
@property (nonatomic, strong, readwrite) NSData *feedData;
@property (nonatomic, strong, readwrite) NSMutableArray *internalEntries;
@property (readwrite) NSInteger numItems;
@property (nonatomic, strong, readwrite) NSString *elementBeingParsed;
@property (nonatomic, strong, readwrite) NSMutableSet *feedLinkRelations;
@property (nonatomic, strong, readwrite) id childParserDelegate;
@end

@implementation CMISAtomFeedParser

@synthesize feedData = _feedData;
@synthesize internalEntries = _internalEntries;
@synthesize numItems = _numItems;
@synthesize elementBeingParsed = _elementBeingParsed;
@synthesize feedLinkRelations = _feedLinkRelations;
@synthesize childParserDelegate = _childParserDelegate;

- (id)initWithData:(NSData*)feedData
{
    self = [super init];
    if (self)
    {
        self.feedData = feedData;
        self.feedLinkRelations = [NSMutableSet set];
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

- (CMISLinkRelations *)linkRelations
{
    return [[CMISLinkRelations alloc] initWithLinkRelationSet:self.feedLinkRelations];
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
        if (error)
        {
            *error = [parser parserError];
        }
    }

    return parseSuccessful;
}

#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
{
    self.elementBeingParsed = elementName;
    
    if ([self.elementBeingParsed isEqualToString:kCMISAtomEntry])
    {
        // Delegate parsing of AtomEntry element to the entry child parser
        self.childParserDelegate = [CMISAtomEntryParser atomEntryParserWithAtomEntryAttributes:attributeDict parentDelegate:self parser:parser];
    }
    else if ([self.elementBeingParsed isEqualToString:kCMISAtomEntryLink])
    {
        CMISAtomLink *link = [[CMISAtomLink alloc] init];
        [link setValuesForKeysWithDictionary:attributeDict];
        [self.feedLinkRelations addObject:link];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ([self.elementBeingParsed isEqualToString:kCMISAtomFeedNumItems])
    {
        self.numItems = [string integerValue];
    }
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
   if ([elementName isEqualToString:kCMISAtomEntry])
    {
//        self.childParserDelegate = nil;
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
