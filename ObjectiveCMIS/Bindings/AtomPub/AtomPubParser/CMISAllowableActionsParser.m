//
//  CMISAllowableActionsParser.m
//  ObjectiveCMIS
//
//  Created by Gi Lee on 5/6/12.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAllowableActionsParser.h"
#import "CMISAtomPubConstants.h"

@interface CMISAllowableActionsParser ()
@property (nonatomic, weak) id<NSXMLParserDelegate> parent;
@property (nonatomic, strong) NSMutableString *string;
@property (nonatomic, strong) NSString *elementBeingParsed;
@property (nonatomic, strong) NSData *atomData;

// Private Init Used for child delegate parser
- (id)initWithName:(NSString *)elementName attributes:(NSDictionary *)attributes parent:(id)parent parser:(NSXMLParser *)parser;
@end


@implementation CMISAllowableActionsParser

@synthesize parent = _parent;
@synthesize string = _string;
@synthesize elementBeingParsed = _elementBeingParsed;
@synthesize atomData = _atomData;
@synthesize allowableActionsArray = _allowableActionsArray;


#pragma mark - 
#pragma Init Methods - allowableActions Delegated Child Parser

- (id)initWithName:(NSString *)elementName attributes:(NSDictionary *)attributes parent:(id)parent parser:(NSXMLParser *)parser 
{
    self = [self init];
    if (self) 
    {
        [self setParent:parent];
        [self setAllowableActionsArray:[NSMutableDictionary dictionary]];
        [self setAllowableActionsArray:[NSMutableDictionary dictionary]];
        
        // Setting Child Parser Delegate
        [parser setDelegate:self];
    }
    return self;
}

#pragma mark Init for Standalone allowableActions Parser

- (id)initWithData:(NSData*)atomData
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
#pragma mark NSXMLParserDelegate Methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
        namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
        attributes:(NSDictionary *)attributeDict 
{
    self.elementBeingParsed = elementName;
    
    if ([elementName isEqualToString:kCMISAtomEntryAllowableActions]) 
    {
        [self setAllowableActionsArray:[NSMutableDictionary dictionary]];
    }
    else
    {
        self.string = [NSMutableString string];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string 
{
    if (self.string)
    {
        [self.string appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
    if ([elementName isEqualToString:kCMISAtomEntryAllowableActions])
    {
        if (self.parent)
        {
            // Reset Delegate to parent
            [parser setDelegate:self.parent];
            // Message the parent that the element ended
            [self.parent parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
            
            self.parent = nil;
        }
    }
    else
    {
        // TODO: Should check that the elements are valid AllowableActions?
        [self.allowableActionsArray setObject:self.string forKey:elementName];
    }

    self.elementBeingParsed = nil;
    self.string = nil;
}


#pragma mark - 
#pragma mark TODO 

+ (id)elementWithName:(NSString *)elementName attributes:(NSDictionary *)attributesDict parent:(id<NSXMLParserDelegate>)parent parser:(NSXMLParser *)parser;
{
    return [[[self class] alloc] initWithName:elementName attributes:attributesDict parent:parent parser:parser];
}

@end
