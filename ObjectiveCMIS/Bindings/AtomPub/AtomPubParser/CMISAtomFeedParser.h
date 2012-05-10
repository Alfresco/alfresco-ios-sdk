//
//  CMISAtomFeedParser.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 11/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISAtomPubConstants.h"
#import "CMISObjectData.h"
#import "CMISPropertyData.h"
#import "CMISProperties.h"
#import "CMISAtomEntryParser.h"

@interface CMISAtomFeedParser : NSObject <NSXMLParserDelegate, CMISAtomEntryParserDelegate>

@property (nonatomic, strong, readonly) NSArray *entries;

- (id)initWithData:(NSData*)feedData;
- (BOOL)parseAndReturnError:(NSError **)error;

@end
