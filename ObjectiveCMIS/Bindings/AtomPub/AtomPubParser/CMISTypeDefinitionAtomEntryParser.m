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

#import "CMISTypeDefinitionAtomEntryParser.h"
#import "CMISTypeDefinition.h"
#import "CMISAtomPubConstants.h"

@interface CMISTypeDefinitionAtomEntryParser ()

@property(nonatomic, strong, readwrite) CMISTypeDefinition *typeDefinition;
@property(readwrite) BOOL isParsingTypeDefinition;
@property(nonatomic, strong, readwrite) NSData *atomData;
@property(nonatomic, strong, readwrite) NSString *currentString;

@property (nonatomic, strong) id<NSXMLParserDelegate> childParserDelegate;

@end


@implementation CMISTypeDefinitionAtomEntryParser

@synthesize typeDefinition = _typeDefinition;
@synthesize isParsingTypeDefinition = _isParsingTypeDefinition;
@synthesize atomData = _atomData;
@synthesize currentString = _currentString;
@synthesize childParserDelegate = _childParserDelegate;

- (id)initWithData:(NSData *)atomData
{
    self = [self init];
    if (self)
    {
        self.atomData = atomData;
    }

    return self;
}

- (BOOL)parseAndReturnError:(NSError **)error
{
    BOOL parseSuccessful = YES;

    // parse the AtomPub data
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.atomData];
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

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:kCMISRestAtomType])
    {
        self.typeDefinition = [[CMISTypeDefinition alloc] init];
        self.isParsingTypeDefinition = YES;
    }
    else if ([elementName isEqualToString:kCMISCorePropertyStringDefinition]
            || [elementName isEqualToString:kCMISCorePropertyIdDefinition]
            || [elementName isEqualToString:kCMISCorePropertyBooleanDefinition]
            || [elementName isEqualToString:kCMISCorePropertyIntegerDefinition]
            || [elementName isEqualToString:kCMISCorePropertyDateTimeDefinition])
    {
        self.childParserDelegate = [CMISPropertyDefinitionParser parserForPropertyDefinition:elementName withParentDelegate:self parser:parser];
    }
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSString *cleanedString = [string stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!self.currentString)
    {
        self.currentString = cleanedString;
    }
    else {
        self.currentString = [self.currentString stringByAppendingString:cleanedString];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:kCMISRestAtomType])
    {
        self.isParsingTypeDefinition = NO;
    }
    else if ([elementName isEqualToString:kCMISCoreId])
    {
        if (self.isParsingTypeDefinition)
        {
            self.typeDefinition.id = self.currentString;
        }
    }
    else if ([elementName isEqualToString:kCMISCoreLocalName])
    {
        if (self.isParsingTypeDefinition)
        {
            self.typeDefinition.localName = self.currentString;
        }
    }
    else if ([elementName isEqualToString:kCMISCoreLocalNamespace])
    {
        if (self.isParsingTypeDefinition)
        {
            self.typeDefinition.localNameSpace = self.currentString;
        }
    }
    else if ([elementName isEqualToString:kCMISCoreDisplayName])
    {
        if (self.isParsingTypeDefinition)
        {
            self.typeDefinition.displayName = self.currentString;
        }
    }
    else if ([elementName isEqualToString:kCMISCoreQueryName])
    {
        if (self.isParsingTypeDefinition)
        {
            self.typeDefinition.queryName = self.currentString;
        }
    }
    else if ([elementName isEqualToString:kCMISCoreDescription])
    {
        if (self.isParsingTypeDefinition)
        {
            self.typeDefinition.description = self.currentString;
        }
    }
    else if ([elementName isEqualToString:kCMISCoreBaseId])
    {
        if (self.isParsingTypeDefinition)
        {
            if ([self.currentString isEqualToString:kCMISAtomEntryBaseTypeDocument])
            {
                self.typeDefinition.baseTypeId = CMISBaseTypeDocument;
            }
            else if ([self.currentString isEqualToString:kCMISAtomEntryBaseTypeFolder])
            {
                self.typeDefinition.baseTypeId = CMISBaseTypeFolder;
            }
        }
    }
    else if ([elementName isEqualToString:kCMISCoreCreatable])
    {
        if (self.isParsingTypeDefinition)
        {
            self.typeDefinition.isCreatable = self.currentString.lowercaseString == @"true";
        }
    }
    else if ([elementName isEqualToString:kCMISCoreFileable])
    {
        if (self.isParsingTypeDefinition)
        {
            self.typeDefinition.isFileable = self.currentString.lowercaseString == @"true";
        }
    }
    else if ([elementName isEqualToString:kCMISCoreQueryable])
    {
        if (self.isParsingTypeDefinition)
        {
            self.typeDefinition.isQueryable = self.currentString.lowercaseString == @"true";
        }
    }
    else if ([elementName isEqualToString:kCMISCoreFullTextIndexed])
    {
        if (self.isParsingTypeDefinition)
        {
            self.typeDefinition.isFullTextIndexed = self.currentString.lowercaseString == @"true";
        }
    }
    else if ([elementName isEqualToString:kCMISCoreIncludedInSupertypeQuery])
    {
        if (self.isParsingTypeDefinition)
        {
            self.typeDefinition.isIncludedInSupertypeQuery = self.currentString.lowercaseString == @"true";
        }
    }
    else if ([elementName isEqualToString:kCMISCoreControllableACL])
    {
        if (self.isParsingTypeDefinition)
        {
            self.typeDefinition.isControllableAcl = self.currentString.lowercaseString == @"true";
        }
    }
    else if ([elementName isEqualToString:kCMISCoreControllablePolicy])
    {
        if (self.isParsingTypeDefinition)
        {
            self.typeDefinition.isControllablePolicy = self.currentString.lowercaseString == @"true";
        }
    }

    self.currentString = nil;
}

#pragma mark CMISPropertyDefinitionDelegate delegates

- (void)propertyDefinitionParser:(id)propertyDefinitionParser didFinishParsingPropertyDefinition:(CMISPropertyDefinition *)propertyDefinition
{
    [self.typeDefinition addPropertyDefinition:propertyDefinition];
}


@end