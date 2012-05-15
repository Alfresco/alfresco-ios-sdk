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

/**
* The entries contained in the feed.
*/
@property (nonatomic, strong, readonly) NSArray *entries;

/**
* Number of items will be returned when executing a query.
*/
@property (readonly) NSInteger numItems;

- (id)initWithData:(NSData*)feedData;
- (BOOL)parseAndReturnError:(NSError **)error;

@end
