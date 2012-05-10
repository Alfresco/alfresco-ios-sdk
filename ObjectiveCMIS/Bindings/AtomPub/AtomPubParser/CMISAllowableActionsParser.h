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

// TODO: Define AllowableActions Interface and populate

// Simple Model to hold parsed AllowableActions
@property (nonatomic, strong) NSMutableDictionary *allowableActionsArray;

- (id)initWithData:(NSData*)atomData;
- (BOOL)parseAndReturnError:(NSError **)error;

+ (id)parent:(id<NSXMLParserDelegate, CMISAllowableActionsParserDelegate>)parent parser:(NSXMLParser *)parser;

@end


@protocol CMISAllowableActionsParserDelegate <NSObject>
@required
- (void)allowableActionsParserDidFinish:(CMISAllowableActionsParser *)parser;
@end
