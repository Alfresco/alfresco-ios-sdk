//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISPropertyDefinitionParser.h"

@class CMISTypeDefinition;

// TODO: should we merge this parser with the generic AtomEntry parser?
@interface CMISTypeDefinitionAtomEntryParser : NSObject <NSXMLParserDelegate, CMISPropertyDefinitionDelegate>

/**
* Available after a successful parse.
*/
@property (nonatomic, strong, readonly) CMISTypeDefinition *typeDefinition;

- (id)initWithData:(NSData *)atomData;
- (BOOL)parseAndReturnError:(NSError **)error;

@end