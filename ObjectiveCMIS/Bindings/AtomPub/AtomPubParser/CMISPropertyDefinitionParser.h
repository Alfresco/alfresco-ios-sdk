//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMISPropertyDefinition;
@protocol CMISPropertyDefinitionDelegate;

@interface CMISPropertyDefinitionParser : NSObject <NSXMLParserDelegate>

// Designated Initializer
- (id)initWithData:(NSData *)atomData;
- (BOOL)parseAndReturnError:(NSError **)error;

// Initializes a child parser for an Atom Entry and takes over parsing control while parsing the Atom Entry
+ (id)parserForPropertyDefinition:(NSString *)propertyDefinitionElementName
               withParentDelegate:(id<NSXMLParserDelegate, CMISPropertyDefinitionDelegate>)parentDelegate
               parser:(NSXMLParser *)parser;

@end

@protocol CMISPropertyDefinitionDelegate <NSObject>

@optional
- (void)propertyDefinitionParser:(id)propertyDefinitionParser didFinishParsingPropertyDefinition:(CMISPropertyDefinition *)propertyDefinition;

@end
