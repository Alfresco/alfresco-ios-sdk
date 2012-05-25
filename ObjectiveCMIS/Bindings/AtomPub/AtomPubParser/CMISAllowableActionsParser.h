//
//  CMISAllowableActionsParser.h
//  ObjectiveCMIS
//
//  Created by Gi Lee on 5/6/12.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISAtomPubExtensionElementParser.h"
#import "CMISAllowableActions.h"

@class CMISAllowableActionsParser;

@protocol CMISAllowableActionsParserDelegate <NSObject>

@optional
- (void)allowableActionsParser:(CMISAllowableActionsParser *)parser didFinishParsingAllowableActions:(CMISAllowableActions *)allowableActions;

@end


@interface CMISAllowableActionsParser : NSObject <NSXMLParserDelegate, CMISAtomPubExtensionElementParserDelegate>

@property (nonatomic, strong, readonly) CMISAllowableActions *allowableActions;

- (id)initWithData:(NSData*)atomData;
- (BOOL)parseAndReturnError:(NSError **)error;

// Delegates parsing to child parser, ensure that the Element is 'allowableActions'
+ (id)allowableActionsParserWithParentDelegate:(id<NSXMLParserDelegate, CMISAllowableActionsParserDelegate>)parentDelegate parser:(NSXMLParser *)parser;

@end
