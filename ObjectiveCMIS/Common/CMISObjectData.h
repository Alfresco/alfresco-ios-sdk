//
//  CMISObjectData.h
//  HybridApp
//
//  Created by Cornwell Gavin on 22/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISEnums.h"
#import "CMISProperties.h"
#import "CMISAllowableActions.h"

@interface CMISObjectData : NSObject

@property (nonatomic, strong) NSString *identifier; 
@property (nonatomic, assign) CMISBaseType baseType;
@property (nonatomic, strong) CMISProperties *properties;
@property (nonatomic, strong) NSMutableDictionary *links;
@property (nonatomic, strong) NSURL *contentUrl;
@property (nonatomic, strong) CMISAllowableActions *allowableActions;

@end
