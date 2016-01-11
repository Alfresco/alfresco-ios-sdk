/*
  Licensed to the Apache Software Foundation (ASF) under one
  or more contributor license agreements.  See the NOTICE file
  distributed with this work for additional information
  regarding copyright ownership.  The ASF licenses this file
  to you under the Apache License, Version 2.0 (the
  "License"); you may not use this file except in compliance
  with the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an
  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  KIND, either express or implied.  See the License for the
  specific language governing permissions and limitations
  under the License.
 */

#import "CMISAtomPubPropertyDefinitionParser.h"
#import "CMISPropertyDefinition.h"
#import "CMISAtomPubConstants.h"
#import "CMISLog.h"

@interface CMISAtomPubPropertyDefinitionParser ()

@property (nonatomic, strong, readwrite) CMISPropertyDefinition *propertyDefinition;
@property (nonatomic, strong, readwrite) NSString *currentString;
@property (nonatomic, strong, readwrite) NSMutableArray *currentChoices;
@property (nonatomic, strong, readwrite) CMISPropertyChoice *currentChoice;
@property (nonatomic, strong, readwrite) NSMutableArray *currentValues;

// Properties if used as child delegate parser
@property(nonatomic, weak) id <NSXMLParserDelegate, CMISAtomPubPropertyDefinitionDelegate> parentDelegate;

@end


@implementation CMISAtomPubPropertyDefinitionParser


- (id)init
{
    self = [super init];
    if (self) {
        self.propertyDefinition = [[CMISPropertyDefinition alloc] init];
        self.currentValues = [NSMutableArray array];
    }
    return self;
}

- (id)initWithPropertyDefinition:(NSString *)propertyDefinitionElementName
              withParentDelegate:(id <NSXMLParserDelegate, CMISAtomPubPropertyDefinitionDelegate>)parentDelegate
              parser:(NSXMLParser *)parser
{
    self = [self init];
    if (self) {
        self.parentDelegate = parentDelegate;

        // Setting ourself, the entry parser, as the delegate, we reset back to our parent when we're done
        [parser setDelegate:self];

        // Select type based on element name that is passed
        if ([propertyDefinitionElementName isEqualToString:kCMISCorePropertyStringDefinition]) {
            self.propertyDefinition.propertyType = CMISPropertyTypeString;
        } else if ([propertyDefinitionElementName isEqualToString:kCMISCorePropertyIdDefinition]) {
            self.propertyDefinition.propertyType = CMISPropertyTypeId;
        } else if ([propertyDefinitionElementName isEqualToString:kCMISCorePropertyBooleanDefinition]) {
            self.propertyDefinition.propertyType = CMISPropertyTypeBoolean;
        } else if ([propertyDefinitionElementName isEqualToString:kCMISCorePropertyDateTimeDefinition]) {
            self.propertyDefinition.propertyType = CMISPropertyTypeDateTime;
        } else if ([propertyDefinitionElementName isEqualToString:kCMISCorePropertyIntegerDefinition]) {
            self.propertyDefinition.propertyType = CMISPropertyTypeInteger;
        } else if ([propertyDefinitionElementName isEqualToString:kCMISCorePropertyDecimalDefinition]) {
            self.propertyDefinition.propertyType = CMISPropertyTypeDecimal;
        }
    }
    return self;
}

#pragma mark Class methods

+ (id)parserForPropertyDefinition:(NSString *)propertyDefinitionElementName
               withParentDelegate:(id <NSXMLParserDelegate, CMISAtomPubPropertyDefinitionDelegate>)parentDelegate
                           parser:(NSXMLParser *)parser
{
    return [[CMISAtomPubPropertyDefinitionParser alloc] initWithPropertyDefinition:propertyDefinitionElementName withParentDelegate:parentDelegate parser:parser];
}

#pragma mark NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSString *cleanedString = [string stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!self.currentString) {
        self.currentString = cleanedString;
    } else {
        self.currentString = [self.currentString stringByAppendingString:cleanedString];
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:kCMISCoreChoice] || [elementName isEqualToString:kCMISCoreChoiceString]) {
        if (self.currentChoices == nil)
        {
            self.currentChoices = [NSMutableArray array];
        }
        
        self.currentChoice = [CMISPropertyChoice new];
        self.currentChoice.displayName = attributeDict[kCMISAtomEntryDisplayName];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:kCMISCorePropertyStringDefinition]
        || [elementName isEqualToString:kCMISCorePropertyIdDefinition]
        || [elementName isEqualToString:kCMISCorePropertyBooleanDefinition]
        || [elementName isEqualToString:kCMISCorePropertyIntegerDefinition]
        || [elementName isEqualToString:kCMISCorePropertyDateTimeDefinition]
        || [elementName isEqualToString:kCMISCorePropertyDecimalDefinition]) {
        
        // store any choice objects
        self.propertyDefinition.choices = self.currentChoices;
        
        if (self.parentDelegate) {
            if ([self.parentDelegate respondsToSelector:@selector(propertyDefinitionParser:didFinishParsingPropertyDefinition:)]) {
                [self.parentDelegate performSelector:@selector(propertyDefinitionParser:didFinishParsingPropertyDefinition:) withObject:self withObject:self.propertyDefinition];
            }

            // Reset Delegate to parent
            parser.delegate = self.parentDelegate;
            self.parentDelegate = nil;
        }
    } else if ([elementName isEqualToString:kCMISCoreId]) {
        self.propertyDefinition.identifier = self.currentString;
    } else if ([elementName isEqualToString:kCMISCoreLocalName]) {
        self.propertyDefinition.localName = self.currentString;
    } else if ([elementName isEqualToString:kCMISCoreLocalNamespace]) {
        self.propertyDefinition.localNamespace = self.currentString;
    } else if ([elementName isEqualToString:kCMISCoreDisplayName]) {
        self.propertyDefinition.displayName = self.currentString;
    } else if ([elementName isEqualToString:kCMISCoreQueryName]) {
        self.propertyDefinition.queryName = self.currentString;
    } else if ([elementName isEqualToString:kCMISCoreDescription]) {
        self.propertyDefinition.summary = self.currentString;
    } else if ([elementName isEqualToString:kCMISCoreCardinality]) {
        if ([self.currentString isEqualToString:@"multi"]) {
            self.propertyDefinition.cardinality = CMISCardinalityMulti;
        } else if ([self.currentString isEqualToString:@"single"]) {
            self.propertyDefinition.cardinality = CMISCardinalitySingle;
        } else {
            CMISLogError(@"Invalid value for property definition cardinality : '%@'", self.currentString);
        }

    } else if ([elementName isEqualToString:kCMISCoreUpdatability]) {
        if ([self.currentString.lowercaseString isEqualToString:@"readonly"]) {
            self.propertyDefinition.updatability = CMISUpdatabilityReadOnly;
        } else if ([self.currentString.lowercaseString isEqualToString:@"readwrite"]) {
            self.propertyDefinition.updatability = CMISUpdatabilityReadWrite;
        } else if ([self.currentString.lowercaseString isEqualToString:@"whencheckedout"]) {
            self.propertyDefinition.updatability = CMISUpdatabilityWhenCheckedOut;
        } else if ([self.currentString.lowercaseString isEqualToString:@"oncreate"]) {
            self.propertyDefinition.updatability = CMISUpdatabilityOnCreate;
        } else {
            CMISLogError(@"Invalid value for property definition updatability : '%@'", self.currentString);
        }
    } else if ([elementName isEqualToString:kCMISCoreInherited]) {
        self.propertyDefinition.inherited = [self parseBooleanValue:self.currentString];
    } else if ([elementName isEqualToString:kCMISCoreRequired]) {
        self.propertyDefinition.required = [self parseBooleanValue:self.currentString];
    } else if ([elementName isEqualToString:kCMISCoreQueryable]) {
        self.propertyDefinition.queryable = [self parseBooleanValue:self.currentString];
    } else if ([elementName isEqualToString:kCMISCoreOrderable]) {
        self.propertyDefinition.orderable = [self parseBooleanValue:self.currentString];
    } else if ([elementName isEqualToString:kCMISCoreOpenChoice]) {
        self.propertyDefinition.openChoice = [self parseBooleanValue:self.currentString];
    } else if ([elementName isEqualToString:kCMISAtomEntryValue]) {
        if (self.currentString != nil) {
            [self.currentValues addObject:self.currentString];
        } else {
            // a value element being present without a value signifies an empty string
            [self.currentValues addObject:@""];
        }
    } else if ([elementName isEqualToString:kCMISCoreChoice] || [elementName isEqualToString:kCMISCoreChoiceString]) {
        // there should only ever be one value for a single choice element
        if (self.currentValues.count == 1) {
            self.currentChoice.value = self.currentValues[0];
            [self.currentChoices addObject:self.currentChoice];
        }
        [self.currentValues removeAllObjects];
    } else if ([elementName isEqualToString:kCMISCoreDefaultValue]) {
        self.propertyDefinition.defaultValues = [NSArray arrayWithArray:self.currentValues];
        [self.currentValues removeAllObjects];
    }
    
    self.currentString = nil;
}

#pragma mark Helper methods

- (BOOL)parseBooleanValue:(NSString *)value
{
    return [value.lowercaseString isEqualToString:@"true"];
}


@end