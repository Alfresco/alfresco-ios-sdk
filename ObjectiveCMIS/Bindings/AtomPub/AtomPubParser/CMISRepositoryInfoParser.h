//
//  CMISRepositoryInfoParser.h
//  ObjectiveCMIS
//
//  Created by Gi Lee on 5/17/12.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISRepositoryInfo.h"
#import "CMISAtomPubExtensionDataParserBase.h"

@class CMISRepositoryInfoParser;

@protocol CMISRepositoryInfoParserDelegate <NSObject>
@required
- (void)repositoryInfoParser:(CMISRepositoryInfoParser *)epositoryInfoParser didFinishParsingRepositoryInfo:(CMISRepositoryInfo *)repositoryInfo;
@end


@interface CMISRepositoryInfoParser : CMISAtomPubExtensionDataParserBase <NSXMLParserDelegate>

@property (nonatomic, strong, readonly) CMISRepositoryInfo *currentRepositoryInfo;

- (id)initRepositoryInfoParserWithParentDelegate:(id<NSXMLParserDelegate, CMISRepositoryInfoParserDelegate>)parentDelegate parser:(NSXMLParser *)parser;
+ (id)repositoryInfoParserWithParentDelegate:(id<NSXMLParserDelegate, CMISRepositoryInfoParserDelegate>)parentDelegate parser:(NSXMLParser *)parser;

@end
