//
//  CMISAllowableActionsParser.h
//  ObjectiveCMIS
//
//  Created by Gi Lee on 5/6/12.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMISAllowableActionsParser : NSObject <NSXMLParserDelegate>

// TODO: Define AllowableActions Interface and populate

// Simple Model to hold parsed AllowableActions
@property (nonatomic, copy) NSMutableDictionary *allowableActionsArray;

- (id)initWithData:(NSData*)atomData;
- (BOOL)parseAndReturnError:(NSError **)error;

+ (id)elementWithName:(NSString *)elementName attributes:(NSDictionary *)attributesDict parent:(id<NSXMLParserDelegate>)parent parser:(NSXMLParser *)parser;

@end
