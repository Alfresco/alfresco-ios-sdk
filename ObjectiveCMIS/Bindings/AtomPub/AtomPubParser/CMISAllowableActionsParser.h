//
//  CMISAllowableActionsParser.h
//  ObjectiveCMIS
//
//  Created by Gi Lee on 5/6/12.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CMISAllowableActionsParserDelegate;


@interface CMISAllowableActionsParser : NSObject <NSXMLParserDelegate>
// Simple Model to hold parsed AllowableActions, The keys are the action type names and the value for each key is 'true' or 'false'
@property (nonatomic, strong, readonly) NSDictionary *allowableActionsDict;

- (id)initWithData:(NSData*)atomData;
- (BOOL)parseAndReturnError:(NSError **)error;

// Delegates parsing to child parser, ensure that the Element is 'allowableActions'
+ (id)allowableActionsParserWithParentDelegate:(id<NSXMLParserDelegate, CMISAllowableActionsParserDelegate>)parentDelegate parser:(NSXMLParser *)parser;

@end


@protocol CMISAllowableActionsParserDelegate <NSObject>
@optional
- (void)allowableActionsParser:(CMISAllowableActionsParser *)parser didFinishParsingAllowableActionsDict:(NSDictionary *)allowableActionsDict;
@end
