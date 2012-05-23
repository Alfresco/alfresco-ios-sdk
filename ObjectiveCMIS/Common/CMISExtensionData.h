//
//  CMISExtensionData.h
//  ObjectiveCMIS
//
//  Created by Gi Lee on 5/21/12.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISExtensionElement.h"

@interface CMISExtensionData : NSObject

/** 
 * Returns an Array of CMISExtensionElements 
 */
@property (nonatomic, strong) NSArray *extensions;

@end
