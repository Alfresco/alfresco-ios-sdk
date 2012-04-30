//
//  ServiceDoc.h
//  HybridApp
//
//  Created by Cornwell Gavin on 17/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISRepositoryInfo.h"

@interface CMISServiceDocumentParser : NSObject <NSXMLParserDelegate>

// Available after parsing the service document
@property (nonatomic, strong, readonly) NSArray *workspaces;

- (id)initWithData:(NSData*)atomData;
- (BOOL)parseAndReturnError:(NSError **)error;

@end
