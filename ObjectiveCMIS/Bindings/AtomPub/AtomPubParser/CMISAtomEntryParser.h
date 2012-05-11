//
//  CMISAtomEntryParser.h
//  HybridApp
//
//  Created by Cornwell Gavin on 29/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISAtomPubConstants.h"
#import "CMISObjectData.h"
#import "CMISPropertyData.h"
#import "CMISProperties.h"
#import "CMISAllowableActionsParser.h"

@protocol CMISAtomEntryParserDelegate;

@interface CMISAtomEntryParser : NSObject <NSXMLParserDelegate, CMISAllowableActionsParserDelegate>

@property (nonatomic, strong, readonly) CMISObjectData *objectData;

// Designated Initializer
- (id)initWithData:(NSData *)atomData;
- (BOOL)parseAndReturnError:(NSError **)error;

// Initializes a child parser for an Atom Entry and takes over parsing control while parsing the Atom Entry
+ (id)atomEntryParserWithAtomEntryAttributes:(NSDictionary *)attributes parentDelegate:(id<NSXMLParserDelegate, CMISAtomEntryParserDelegate>)parentDelegate parser:(NSXMLParser *)parser;

@end


@protocol CMISAtomEntryParserDelegate <NSObject>
@optional
- (void)cmisAtomEntryParser:(id)entryParser didFinishParsingCMISObjectData:(CMISObjectData *)cmisObjectData;

@end
