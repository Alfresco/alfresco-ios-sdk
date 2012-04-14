//
//  CMISProperties.h
//  HybridApp
//
//  Created by Cornwell Gavin on 22/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISPropertyData.h"

@interface CMISProperties : NSObject

// Dictionary of NSString -> CMISPropertyData
@property (nonatomic, strong, readonly) NSDictionary *properties;

// List of CMISPropertyData objects
@property (nonatomic, strong, readonly) NSArray *propertyList;

// adds a property
- (void)addProperty:(CMISPropertyData *)propertyData;

@end
