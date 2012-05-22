//
//  CMISAtomPubExtensionElementParser.h
//  ObjectiveCMIS
//
//  Created by Gi Lee on 5/21/12.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISExtensionElement.h"

@class CMISAtomPubExtensionElementParser;

@protocol CMISAtomPubExtensionElementParserDelegate <NSObject>
@required
- (void)extensionElementParser:(CMISAtomPubExtensionElementParser *)parser didFinishParsingExtensionElement:(CMISExtensionElement *)extensionElement;
@end
                                                                                                

@interface CMISAtomPubExtensionElementParser : NSObject <NSXMLParserDelegate, CMISAtomPubExtensionElementParserDelegate>

+ (id)extensionElementParserWithElementName:(NSString *)elementName namespaceUri:(NSString *)namespaceUri attributes:(NSDictionary *)attributes parentDelegate:(id<NSXMLParserDelegate, CMISAtomPubExtensionElementParserDelegate>)parentDelegate parser:(NSXMLParser *)parser;

@end
