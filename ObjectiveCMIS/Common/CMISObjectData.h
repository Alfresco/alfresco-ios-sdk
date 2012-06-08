//
//  CMISObjectData.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 22/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISEnums.h"
#import "CMISProperties.h"
#import "CMISAllowableActions.h"
#import "CMISLinkRelations.h"
#import "CMISExtensionData.h"

@class CMISRenditionData;

@interface CMISObjectData : CMISExtensionData

@property (nonatomic, strong) NSString *identifier; 
@property (nonatomic, assign) CMISBaseType baseType;
@property (nonatomic, strong) CMISProperties *properties;
@property (nonatomic, strong) CMISLinkRelations *linkRelations;
@property (nonatomic, strong) NSURL *contentUrl;
@property (nonatomic, strong) CMISAllowableActions *allowableActions;
@property (nonatomic, strong) NSArray *renditions; // An array containing CMISRenditionData objects

@end
