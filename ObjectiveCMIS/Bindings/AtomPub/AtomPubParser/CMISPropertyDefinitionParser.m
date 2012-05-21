//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISPropertyDefinitionParser.h"
#import "CMISPropertyDefinition.h"
#import "CMISAtomPubConstants.h"


@interface CMISPropertyDefinitionParser ()

@property(nonatomic, strong, readwrite) CMISPropertyDefinition *propertyDefinition;
@property(nonatomic, strong, readwrite) NSString *currentString;

// Properties if used as child delegate parser
@property(nonatomic, weak) id <NSXMLParserDelegate, CMISPropertyDefinitionDelegate> parentDelegate;

@end


@implementation CMISPropertyDefinitionParser

@synthesize propertyDefinition = _propertyDefinition;
@synthesize currentString = _currentString;
@synthesize parentDelegate = _parentDelegate;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.propertyDefinition = [[CMISPropertyDefinition alloc] init];
    }
    return self;
}

- (id)initWithData:(NSData *)atomData
{
    return nil;
}

- (BOOL)parseAndReturnError:(NSError **)error
{
    return NO;
}

- (id)initWithPropertyDefinition:(NSString *)propertyDefinitionElementName
              withParentDelegate:(id <NSXMLParserDelegate, CMISPropertyDefinitionDelegate>)parentDelegate
              parser:(NSXMLParser *)parser
{
    self = [self init];
    if (self)
    {
        self.parentDelegate = parentDelegate;

        // Setting ourself, the entry parser, as the delegate, we reset back to our parent when we're done
        [parser setDelegate:self];

        // Select type based on element name that is passed
        if ([propertyDefinitionElementName isEqualToString:kCMISCorePropertyStringDefinition])
        {
            self.propertyDefinition.propertyType = CMISPropertyTypeString;
        }
        else if ([propertyDefinitionElementName isEqualToString:kCMISCorePropertyIdDefinition])
        {
            self.propertyDefinition.propertyType = CMISPropertyTypeId;
        }
        else if ([propertyDefinitionElementName isEqualToString:kCMISCorePropertyBooleanDefinition])
        {
            self.propertyDefinition.propertyType = CMISPropertyTypeBoolean;
        }
        else if ([propertyDefinitionElementName isEqualToString:kCMISCorePropertyDateTimeDefinition])
        {
            self.propertyDefinition.propertyType = CMISPropertyTypeDateTime;
        }
        else if ([propertyDefinitionElementName isEqualToString:kCMISCorePropertyIntegerDefinition])
        {
            self.propertyDefinition.propertyType = CMISPropertyTypeInteger;
        }
    }
    return self;
}

#pragma mark Class methods

+ (id)parserForPropertyDefinition:(NSString *)propertyDefinitionElementName
               withParentDelegate:(id <NSXMLParserDelegate, CMISPropertyDefinitionDelegate>)parentDelegate
                           parser:(NSXMLParser *)parser
{
    return [[CMISPropertyDefinitionParser alloc] initWithPropertyDefinition:propertyDefinitionElementName withParentDelegate:parentDelegate parser:parser];
}

#pragma mark NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (!self.currentString)
    {
        self.currentString = string;
    }
    else {
        self.currentString = [self.currentString stringByAppendingString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:kCMISCorePropertyStringDefinition]
            || [elementName isEqualToString:kCMISCorePropertyIdDefinition]
            || [elementName isEqualToString:kCMISCorePropertyBooleanDefinition]
            || [elementName isEqualToString:kCMISCorePropertyIntegerDefinition]
            || [elementName isEqualToString:kCMISCorePropertyDateTimeDefinition])
    {
        if (self.parentDelegate)
        {
            if ([self.parentDelegate respondsToSelector:@selector(propertyDefinitionParser:didFinishParsingPropertyDefinition:)])
            {
                [self.parentDelegate performSelector:@selector(propertyDefinitionParser:didFinishParsingPropertyDefinition:) withObject:self withObject:self.propertyDefinition];
            }

            // Reset Delegate to parent
            [parser setDelegate:self.parentDelegate];
            // Message the parent that the element ended
            [self.parentDelegate parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];

            self.parentDelegate = nil;
        }
    }
    else if ([elementName isEqualToString:kCMISCoreId])
    {
        self.propertyDefinition.id = self.currentString;
    }
    else if ([elementName isEqualToString:kCMISCoreLocalName])
    {
        self.propertyDefinition.localName = self.currentString;
    }
    else if ([elementName isEqualToString:kCMISCoreLocalNamespace])
    {
        self.propertyDefinition.localNamespace = self.currentString;
    }
    else if ([elementName isEqualToString:kCMISCoreDisplayName])
    {
        self.propertyDefinition.displayName = self.currentString;
    }
    else if ([elementName isEqualToString:kCMISCoreQueryName])
    {
        self.propertyDefinition.queryName = self.currentString;
    }
    else if ([elementName isEqualToString:kCMISCoreDescription])
    {
        self.propertyDefinition.description = self.currentString;
    }
    else if ([elementName isEqualToString:kCMISCoreCardinality])
    {
        if ([self.currentString isEqualToString:@"multi"])
        {
            self.propertyDefinition.cardinality = CMISCardinalityMulti;
        }
        else if ([self.currentString isEqualToString:@"multi"])
        {
            self.propertyDefinition.cardinality = CMISCardinalitySingle;
        }
        else
        {
            log(@"Invalid value for property definition cardinality : '%@'", self.currentString);
        }

    }
    else if ([elementName isEqualToString:kCMISCoreUpdatability])
    {
        if ([self.currentString.lowercaseString isEqualToString:@"readonly"])
        {
            self.propertyDefinition.updatability = CMISUpdatabilityReadOnly;
        }
        else if ([self.currentString.lowercaseString isEqualToString:@"readwrite"])
        {
            self.propertyDefinition.updatability = CMISUpdatabilityReadWrite;
        }
        else if ([self.currentString.lowercaseString isEqualToString:@"whencheckedout"])
        {
            self.propertyDefinition.updatability = CMISUpdatabilityWhenCheckedOut;
        }
        else if ([self.currentString.lowercaseString isEqualToString:@"oncreate"])
        {
            self.propertyDefinition.updatability = CMISUpdatabilityOnCreate;
        }
        else
        {
            log(@"Invalid value for property definition updatability : '%@'", self.currentString);
        }
    }
    else if ([elementName isEqualToString:kCMISCoreInherited])
    {
        self.propertyDefinition.isInherited = [self parseBooleanValue:self.currentString];
    }
    else if ([elementName isEqualToString:kCMISCoreRequired])
    {
        self.propertyDefinition.isRequired = [self parseBooleanValue:self.currentString];
    }
    else if ([elementName isEqualToString:kCMISCoreQueryable])
    {
        self.propertyDefinition.isQueryable = [self parseBooleanValue:self.currentString];
    }
    else if ([elementName isEqualToString:kCMISCoreOrderable])
    {
        self.propertyDefinition.isOrderable = [self parseBooleanValue:self.currentString];
    }
    else if ([elementName isEqualToString:kCMISCoreOpenChoice])
    {
        self.propertyDefinition.isOpenChoice = [self parseBooleanValue:self.currentString];
    }


}

#pragma mark Helper methods

- (BOOL)parseBooleanValue:(NSString *)value
{
    return [value.lowercaseString isEqualToString:@"true"];
}


@end