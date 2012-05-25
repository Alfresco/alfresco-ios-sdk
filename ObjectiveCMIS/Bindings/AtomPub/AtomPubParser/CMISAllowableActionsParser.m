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

@property (nonatomic, strong) NSMutableDictionary *internalAllowableActionsDict;
@property (nonatomic, weak) id<NSXMLParserDelegate, CMISAllowableActionsParserDelegate> parentDelegate;
@property (nonatomic, strong) NSMutableString *string;
@property (nonatomic, strong) NSString *elementBeingParsed;
@property (nonatomic, strong) NSData *atomData;
@property (nonatomic, strong) NSMutableArray *currentExtensions;
@property (nonatomic, weak) id<NSXMLParserDelegate> childParserDelegate;

// Private init Used for child delegate parser
- (id)initWithParentDelegate:(id<NSXMLParserDelegate, CMISAllowableActionsParserDelegate>)parentDelegate parser:(NSXMLParser *)parser;
@end


@implementation CMISAllowableActionsParser

@synthesize internalAllowableActionsDict = _internalAllowableActionsDict;
@synthesize parentDelegate = _parentDelegate;
@synthesize string = _string;
@synthesize elementBeingParsed = _elementBeingParsed;
@synthesize atomData = _atomData;
@synthesize currentExtensions = _currentExtensions;
@synthesize childParserDelegate = _childParserDelegate;


#pragma mark - 
#pragma mark Init/Create methods

- (id)initWithParentDelegate:(id<NSXMLParserDelegate, CMISAllowableActionsParserDelegate>)parentDelegate parser:(NSXMLParser *)parser 
{
    self = [self init];
    if (self) 
    {
        [self setParentDelegate:parentDelegate];
        [self setInternalAllowableActionsDict:[NSMutableDictionary dictionary]];
        
        // Setting Child Parser Delegate
        [parser setDelegate:self];
    }
    return self;
}

+ (id)allowableActionsParserWithParentDelegate:(id<NSXMLParserDelegate, CMISAllowableActionsParserDelegate>)parentDelegate parser:(NSXMLParser *)parser
{
    return [[[self class] alloc] initWithParentDelegate:parentDelegate parser:parser];
}

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
#pragma mark Properties

- (CMISAllowableActions *)allowableActions
{
    return [[CMISAllowableActions alloc] initWithAllowableActionsDictionary:[self.internalAllowableActionsDict copy] 
                                                      extensionElementArray:[self.currentExtensions copy]];
}


#pragma mark - 
#pragma mark NSXMLParserDelegate Methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
        namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
        attributes:(NSDictionary *)attributeDict 
{
    self.elementBeingParsed = elementName;
    
    if ([namespaceURI isEqualToString:kCMISNamespaceCmis])
    {
    
    if ([elementName isEqualToString:kCMISAtomEntryAllowableActions]) 
    {
        [self setInternalAllowableActionsDict:[NSMutableDictionary dictionary]];
    }
    else
    {
        self.string = [NSMutableString string];
    }
    }
    else 
    {
        self.childParserDelegate = [CMISAtomPubExtensionElementParser extensionElementParserWithElementName:elementName namespaceUri:namespaceURI 
                                                                                                 attributes:attributeDict parentDelegate:self parser:parser];
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
    if ([namespaceURI isEqualToString:kCMISNamespaceCmis])
    {
        if ([elementName isEqualToString:kCMISAtomEntryAllowableActions])
        {
            if (self.parentDelegate)
            {
                if ([self.parentDelegate respondsToSelector:@selector(allowableActionsParser:didFinishParsingAllowableActions:)])
                {
                    [self.parentDelegate performSelector:@selector(allowableActionsParser:didFinishParsingAllowableActions:) withObject:self withObject:self.allowableActions];
                }
                
                // Reset Delegate to parent
                [parser setDelegate:self.parentDelegate];
                // Message the parent that the element ended
                [self.parentDelegate parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
                
                self.parentDelegate = nil;
            }
        }
        else
        {
            [self.internalAllowableActionsDict setObject:self.string forKey:elementName];
        }
    }

    self.elementBeingParsed = nil;
    self.string = nil;
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
