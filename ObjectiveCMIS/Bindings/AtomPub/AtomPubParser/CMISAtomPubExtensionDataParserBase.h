//
//  CMISAtomPubExtensionDataParserBase.h
//  ObjectiveCMIS
//
//  Created by Gi Lee on 6/11/12.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISAtomPubExtensionElementParser.h"
#import "CMISExtensionData.h"

@interface CMISAtomPubExtensionDataParserBase : NSObject <CMISAtomPubExtensionElementParserDelegate>

@property (nonatomic, weak) id<NSXMLParserDelegate> childParserDelegate;
@property (nonatomic, strong) NSMutableArray *currentExtensions;
@property (nonatomic, strong) CMISExtensionData *currentExtensionData;
@property (nonatomic, strong) NSMutableArray *previousExtensionDataArray;

- (id)init;

// Saves the current extensionData and extensions state and sets the messaged object as the new current extensionData object
- (void)pushNewCurrentExtensionData:(CMISExtensionData *)extensionDataObject;
//  Saves the current extensions on the extensionData object and makes the previous extensionData and extensions the current objects
- (void)saveCurrentExtensionsAndPushPreviousExtensionData;

@end
