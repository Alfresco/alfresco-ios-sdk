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

@interface CMISAtomEntryParser : NSObject <NSXMLParserDelegate>

@property (nonatomic, strong, readonly) NSDictionary *links;
@property (nonatomic, strong, readonly) CMISObjectData *objectData;

- (id)initWithData:(NSData*)atomData;
- (BOOL)parseAndReturnError:(NSError **)error;

@end
